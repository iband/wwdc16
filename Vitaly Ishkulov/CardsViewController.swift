//
//  FirstViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

protocol DetailsView {
    func showDetailsView(sender: UIButton)
}

class CardsViewController: UIViewController, DetailsView {

    @IBOutlet weak var cardsScrollView: CardsScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsScrollView.controller = self
        cardsScrollView.frame = self.view.frame
        
        self.navigationController!.view.backgroundColor = UIColor.whiteColor()
        
        cardsScrollView.contentOffset.x = cardsScrollView.contentSize.width / 2 - self.view.frame.size.width / 2
        cardsScrollView.contentOffset.y = cardsScrollView.contentSize.height / 2 - self.view.frame.size.height / 2
        
        let dictionaryBrain = DictionaryBrain()
        
        cardsScrollView.totalWordsCount = dictionaryBrain.wordCount()
        
        cardsScrollView.buttonsSetUp()
    }
    
    func showDetailsView(sender: UIButton) {
        self.performSegueWithIdentifier("showDetails", sender: sender)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cardsScrollView.animateButtons()
    }

    
    
}

