//
//  FirstViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController {

    @IBOutlet weak var cardsScrollView: CardsScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsScrollView.frame = self.view.frame
        print(self.view.frame)
        
        cardsScrollView.contentOffset.x = cardsScrollView.contentSize.width / 2 - self.view.frame.size.width / 2
        cardsScrollView.contentOffset.y = cardsScrollView.contentSize.height / 2 - self.view.frame.size.height / 2
        
        cardsScrollView.buttonsSetUp()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cardsScrollView.animateButtons()
    }

}

