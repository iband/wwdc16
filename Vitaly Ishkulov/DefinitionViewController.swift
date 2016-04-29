//
//  definitionViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/26/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit
import CoreData

class DefinitionViewController: UIViewController, UIGestureRecognizerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var dictionaryBrain = DictionaryBrain()
    
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var partOfSpeech: UILabel!
    @IBOutlet weak var definition: UILabel!
    @IBOutlet weak var example: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var exampleBackground: UIView!
    
    var buttonId: Int?
    var contentHeight: CGFloat = 0
    var isPeeking = false {
        willSet {
            if newValue == false {
                self.checkButton.alpha = 1
                self.crossButton.alpha = 1
            }
        }
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.hidden = true
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        super.viewDidLoad()
        self.title = "Definition"
        if let element = dictionaryBrain.getElementWithNumber(buttonId!) {
            word.text = element[DictionaryBrain.WordCardField.Word]
            definition.text = element[DictionaryBrain.WordCardField.Definition]
            partOfSpeech.text = element[DictionaryBrain.WordCardField.PartOfSpeech]
            example.text = element[DictionaryBrain.WordCardField.Example]
            number.text = "#\(buttonId!)"
        }
        if isPeeking {
            self.checkButton.alpha = 0
            self.crossButton.alpha = 0
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.preferredContentSize = CGSize(width: 0, height: self.exampleBackground.frame.origin.y + self.exampleBackground.frame.size.height + 20)
    }
    @IBAction func correct() {
        saveWord(self.buttonId!, guessed: true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func incorrect() {
        saveWord(self.buttonId!, guessed: false)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // Preview action items.
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let correctAction = UIPreviewAction(title: "I knew the word", style: .Default) { (action, viewController) -> Void in
            guard let definitionVC = viewController as? DefinitionViewController else { return }
            definitionVC.correct()
        }
        
        let incorrectAction = UIPreviewAction(title: "I didn't know", style: .Destructive) { (action, viewController) -> Void in
            guard let definitionVC = viewController as? DefinitionViewController else { return }
            definitionVC.incorrect()
        }
        
        return [correctAction, incorrectAction]
        
    }
    
    // saving to CoreData
    private func objectExists(wordId: Int, guessed: Bool, fetch: NSFetchRequest) -> Bool {
        do {
            let storedWords = try managedObjectContext.executeFetchRequest(fetch)

            for object in storedWords {
                let id = object.valueForKey("wordId") as! Int
                if id == wordId {
                    object.setValue(guessed, forKey: "guessed")
                    return true
                }
            }
        } catch {}
        return false
    }
    
    private func saveWord(wordId: Int, guessed: Bool) {
        
        let entity =  NSEntityDescription.entityForName("Word", inManagedObjectContext: managedObjectContext)
        let fetch = NSFetchRequest(entityName: "Word")
        
        if !objectExists(wordId, guessed: guessed, fetch: fetch) {
            guard let newWord = dictionaryBrain.getElementWithNumber(wordId) else { return }
            let word = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
            word.setValue(NSDate(), forKey: "addedAt")
            word.setValue(wordId, forKey: "wordId")
            word.setValue(newWord[DictionaryBrain.WordCardField.Word], forKey: "word")
            word.setValue(newWord[DictionaryBrain.WordCardField.PartOfSpeech], forKey: "partOfSpeech")
            word.setValue(newWord[DictionaryBrain.WordCardField.Definition], forKey: "definition")
            word.setValue(guessed, forKey: "guessed")
        }
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}
