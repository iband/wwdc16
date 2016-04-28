//
//  FirstViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

protocol StoredWordsDataSource {
    var guessedWords: [Int : Bool] { get set }
    func updateButtonColors()
}

class CardsViewController: UIViewController, UIViewControllerPreviewingDelegate, StoredWordsDataSource {

    @IBOutlet weak var cardsScrollView: CardsScrollView!
    private let dictionaryBrain: DictionaryBrain
    private let totalWordsCount: Int
    private var buttons: [BubbleButtonView] = []
    private var circleCenters: [CGPoint] = []
    private let circleRadius: CGFloat = 50
    private var globalButtonId = 0
    
    private let defaultCircleColor = "#D9D9D9"
    private let learnedCircleColor = "#BAFFBC"
    private let failedCircleColor = "#FFCABA"
    
    var guessedWords: [Int : Bool] = [:]
    
    func updateButtonColors() {
        for button in buttons {
            let id = button.tag
            if guessedWords[id] != nil {
                button.colorHex = getColorForButtonId(id)
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        dictionaryBrain = DictionaryBrain()
        totalWordsCount = dictionaryBrain.wordCount()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        dictionaryBrain = DictionaryBrain()
        totalWordsCount = dictionaryBrain.wordCount()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.view.backgroundColor = UIColor.whiteColor()
        
        globalButtonId = Int(arc4random()) % totalWordsCount // start with different words on launch
        
        cardsScrollView.frame = self.view.frame
        cardsScrollView.contentOffset.x = cardsScrollView.contentSize.width / 2 - self.view.frame.size.width / 2
        cardsScrollView.contentOffset.y = cardsScrollView.contentSize.height / 2 - self.view.frame.size.height / 2
        
        buttonsSetUp()
        cardsScrollView.buttons = buttons
    }
    
    func showDetailsView(sender: UIButton) {
        self.performSegueWithIdentifier("showDetails", sender: sender)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cardsScrollView.animateButtons()
    }
    
    @IBAction func refresh() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = []
        buttonsSetUp()
        cardsScrollView.buttons = buttons
        cardsScrollView.refresh()
    }
    
    private func getColorForButtonId(id: Int) -> String {
        if let guessed = guessedWords[id] {
            if guessed {
                return learnedCircleColor
            } else {
                return failedCircleColor
            }
        } else {
            return defaultCircleColor
        }
    }
    
    private func buttonsSetUp() {
        generateCircles()
        
        var buttonId = 0
        
        for center in circleCenters {
//            buttonId += 1
            buttonId = globalButtonId % (totalWordsCount - 1) + 1 // show different words on refresh
            
            //data from the dictionary
            let word = dictionaryBrain.getWordWithNumber(buttonId)

            let frame = getFrameFromCenter(center, radius: circleRadius)
            
            let button = BubbleButtonView(frame: frame)
            button.colorHex = getColorForButtonId(buttonId)

            
            button.setTitle(word, forState: .Normal)
            button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.tag = buttonId
            buttonId += 1
            globalButtonId += 1
            buttons.append(button)
        }
        for button in buttons {
            button.alpha = 0
            button.addTarget(self, action: #selector(CardsViewController.showDetailsView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cardsScrollView.addSubview(button)
            
            registerForPreviewingWithDelegate(self, sourceView: button)
        }
    }
    
    private func getFrameFromCenter(center: CGPoint, radius: CGFloat) -> CGRect {
        return CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
    }
    
    private func generateCircles() {
        // random distribution is based on Poisson Disk algorithm
        circleCenters = []
        let center = CGPointMake(cardsScrollView.contentSize.width / 2, cardsScrollView.contentSize.height / 2)
        let minCentersDistance: CGFloat = circleRadius * 2 + 10
        circleCenters += [center]
        var i = 1
        var failureCounter = 0
        var totalFailureCounter = 0
        var startPointNumber = 0
        
        while true {
            if totalFailureCounter > 5000 { break }
            
            if failureCounter > 20 {
                startPointNumber += 1
                startPointNumber %= (circleCenters.count - 1)
                failureCounter = 0
            }
            
            let basePoint = circleCenters[startPointNumber]
            let angle = Double(arc4random()) % (2 * M_PI)
            let newPoint = CGPoint(x: basePoint.x + minCentersDistance * CGFloat(sin(angle)),
                                   y: basePoint.y + minCentersDistance * CGFloat(cos(angle)))
            var allowed = true
            let borderPadding: CGFloat = 0
            let containerW = cardsScrollView.contentSize.width // fill the whole scrollViewContent
            let containerH = cardsScrollView.contentSize.height
            
            for center in circleCenters {
                let distance: CGFloat = circleRadius * 2 + 2
                let condition1 = pow((center.x - newPoint.x), 2) + pow((center.y - newPoint.y), 2) < pow(distance, 2)
                let condition2 = pow((abs(center.x - newPoint.x) - containerW), 2) + pow((center.y - newPoint.y), 2) < pow(distance, 2)
                let condition3 = pow((center.x - newPoint.x), 2) + pow((abs(center.y - newPoint.y) - containerH), 2) < pow(distance, 2)
                let condition4 = pow((abs(center.x - newPoint.x) - containerW), 2) + pow((abs(center.y - newPoint.y) - containerH), 2) < pow(distance, 2)
                
                if condition1 || condition2 || condition3 || condition4 || newPoint.x <= borderPadding || newPoint.y <= borderPadding || newPoint.x >= cardsScrollView.contentSize.width - borderPadding || newPoint.y >= cardsScrollView.contentSize.height - borderPadding {
                    allowed = false
                    break
                }
            }
            if allowed == false {
                failureCounter += 1
                totalFailureCounter += 1
                continue
            } else {
                i += 1
                circleCenters += [newPoint]
            }
        }
    }
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetails"
        {
            if let destinationVC = segue.destinationViewController as? DefinitionViewController {
                destinationVC.buttonId = sender?.tag
                destinationVC.delegate = self
            }
        }
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let definitionVC = storyboard?.instantiateViewControllerWithIdentifier("DefinitionViewController") as? DefinitionViewController else { return nil }
        
        let currentButtonView = previewingContext.sourceView
        definitionVC.delegate = self
        definitionVC.buttonId = currentButtonView.tag
        definitionVC.isPeeking = true
        
        
        
//        let gr = UIPanGestureRecognizer(target: definitionVC, action: #selector(DefinitionViewController.pan(_:)))
//        gr.delegate = definitionVC
//        definitionVC.view.addGestureRecognizer(gr)
        return definitionVC
    }
//    override func showViewController(vc: UIViewController, sender: AnyObject?) {
//        vc.view.backgroundColor = UIColor.orangeColor()
//        super.showViewController(vc, sender: sender)
//        vc.view.backgroundColor = UIColor.orangeColor()
//    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
//        viewControllerToCommit.view.backgroundColor = UIColor.orangeColor()
//        previewingContext.sourceView.backgroundColor = UIColor.orangeColor()
//        let gr = UIPanGestureRecognizer(target: viewControllerToCommit, action: #selector(DefinitionViewController.pan(_:)))
//        gr.delegate = (viewControllerToCommit as! UIGestureRecognizerDelegate)
//        viewControllerToCommit.view.addGestureRecognizer(gr)
        showViewController(viewControllerToCommit, sender: self)
        if let definitionVC = viewControllerToCommit as? DefinitionViewController {
            definitionVC.isPeeking = false
        }
    }
}

