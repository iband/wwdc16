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
// delete this delegate:
    var delegate: StoredWordsDataSource?
    var dictionaryBrain = DictionaryBrain()
    
    var words = [NSManagedObject]()
    
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
    
    private func addWordWithId(id: Int, guessed: Bool) {
        if delegate != nil {
            delegate!.guessedWords[self.buttonId!] = guessed
            saveWord(self.buttonId!)
            
//            print(delegate!.guessedWords)
            delegate!.updateButtonColors()
        }
    }
    @IBAction func correct() {
        addWordWithId(self.buttonId!, guessed: true)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func incorrect() {
        addWordWithId(self.buttonId!, guessed: false)
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
    func saveWord(wordId: Int) {
        
        
        
        guard let newWord = dictionaryBrain.getElementWithNumber(wordId) else { return }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
//        let fetchRequest = NSFetchRequest(entityName: "Word")
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        
//        do {
//            try appDelegate.persistentStoreCoordinator.executeRequest(deleteRequest, withContext: managedContext)
//        } catch _ as NSError {
//            // TODO: handle the error
//        }
        
        let entity =  NSEntityDescription.entityForName("Word", inManagedObjectContext: managedContext)
        let word = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let fetch = NSFetchRequest(entityName: "Word")
        let numberOfStoredWords = managedContext.countForFetchRequest(fetch, error: nil)
        print(numberOfStoredWords)
        word.setValue(numberOfStoredWords, forKey: "id")
        word.setValue(wordId, forKey: "wordId")
        word.setValue(newWord[DictionaryBrain.WordCardField.Word], forKey: "word")
        word.setValue(newWord[DictionaryBrain.WordCardField.PartOfSpeech], forKey: "partOfSpeech")
        word.setValue(newWord[DictionaryBrain.WordCardField.Definition], forKey: "definition")
        
        //4
        do {
            try managedContext.save()
            //5
            words.append(word)
            print(words)
            print(words[0].valueForKey("word"))
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
//    lazy var previewActions: [UIPreviewActionItem] = {
//        func previewActionForTitle(title: String, style: UIPreviewActionStyle = .Destructive) -> UIPreviewAction {
//            return UIPreviewAction(title: title, style: style) { previewAction, viewController in
//                guard let definitionVC = viewController as? DefinitionViewController else { return }
//                
//                switch title {
//                case "I knew the word":
//                    definitionVC.correct()
//                case "I didn't know":
//                    definitionVC.incorrect()
//                default:
//                    break
//                }
//            }
//        }
//        
//        let action1 = previewActionForTitle("I knew the word")
//        let action2 = previewActionForTitle("I didn't know", style: UIPreviewActionStyle.Destructive)
//        
//        return [action1, action2]
//    }()
    
    //TODO: remove pan gesture recogniser
    func pan(a: Int) {
        print("Pan GR")
    }
}
