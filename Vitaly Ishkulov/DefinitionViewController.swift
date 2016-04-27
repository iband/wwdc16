//
//  definitionViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/26/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController {
    
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var partOfSpeech: UILabel!
    @IBOutlet weak var definition: UILabel!
    @IBOutlet weak var example: UILabel!
    var buttonId: Int?
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.hidden = true
        super.viewDidLoad()
        
        let dictionaryBrain = DictionaryBrain()
        if let element = dictionaryBrain.getElementWithNumber(buttonId!) {
            word.text = element[DictionaryBrain.WordCardField.Word]
            definition.text = element[DictionaryBrain.WordCardField.Definition]
            partOfSpeech.text = element[DictionaryBrain.WordCardField.PartOfSpeech]
            example.text = element[DictionaryBrain.WordCardField.Example]
        }
    }
}
