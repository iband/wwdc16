//
//  definitionViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/26/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        
        let dictionaryBrain = DictionaryBrain()
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
        print("layout:\t\(exampleBackground.frame)")
        self.preferredContentSize = CGSize(width: 0, height: self.exampleBackground.frame.origin.y + self.exampleBackground.frame.size.height + 10)
    }
    
    func pan(a: Int) {
        print("Pan GR")
    }
}
