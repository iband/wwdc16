//
//  FirstViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit
import CoreData

class CardsViewController: UIViewController, UIViewControllerPreviewingDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var cardsScrollView: CardsScrollView!
    private let dictionaryBrain: DictionaryBrain
    private let totalWordsCount: Int
    private var buttons: [BubbleButtonView] = []
    private var circleCenters: [CGPoint] = []
    private let circleRadius: CGFloat = 50
    private var globalButtonId = 0
    
    private let defaultCircleColor = "#E3E3E3"
    private let learnedCircleColor = "#A2DB68" //"#C9F0A1" //"#BAFFBC"
    private let failedCircleColor = "#FF7666" //"#FFA69B" //"#FFCABA"
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Word")
        let sortDescriptor = NSSortDescriptor(key: "addedAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private var guessedWords: [Int : Bool] = [:]
    var savedWords: [Int] = []
    
    func updateButtonColors() {
        for button in buttons {
            let id = button.tag
            if guessedWords[id] != nil {
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                button.colorHex = getColorForButtonId(id)
            } else {
                button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
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
    private func updateGuessedWords() {
        guard let objects = fetchedResultsController.fetchedObjects else { return }
        for object in objects {
            let id = object.valueForKey("wordId") as! Int
            let guessed = object.valueForKey("guessed") as! Bool
            guessedWords[id] = guessed
        }
        updateButtonColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        do {
            try self.fetchedResultsController.performFetch()
            updateGuessedWords()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        self.navigationController!.view.backgroundColor = UIColor.whiteColor()
        self.title = "Words"
        
        globalButtonId = Int(arc4random_uniform(UInt32(totalWordsCount))) % totalWordsCount // start with different words on launch
        
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
        updateButtonColors()
    }
    
    @IBAction func refresh() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons = []
        buttonsSetUp()
        cardsScrollView.buttons = buttons
        cardsScrollView.refresh()
        updateButtonColors()
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
            buttonId = globalButtonId % (totalWordsCount - 1) + 1 // show different words on refresh
            
            //data from the dictionary
            let wordTitle = dictionaryBrain.getWordWithNumber(buttonId)

            let frame = getFrameFromCenter(center, radius: circleRadius)
            
            let button = BubbleButtonView(frame: frame)
            button.colorHex = getColorForButtonId(buttonId)

            button.setTitle(wordTitle, forState: .Normal)
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
            }
        }
    }

    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let definitionVC = storyboard?.instantiateViewControllerWithIdentifier("DefinitionViewController") as? DefinitionViewController else { return nil }
        
        let currentButtonView = previewingContext.sourceView
        definitionVC.buttonId = currentButtonView.tag
        definitionVC.isPeeking = true
        return definitionVC
    }
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
        if let definitionVC = viewControllerToCommit as? DefinitionViewController {
            definitionVC.isPeeking = false
        }
    }
    
    // MARK: - Fetched Results Controller Delegate Methods
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.updateButtonColors()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            guard let wordId = anObject.valueForKey("wordId") as? Int, guessed = anObject.valueForKey("guessed") as? Bool else { break }
            guessedWords[wordId] = guessed
            self.updateButtonColors()
            break
        case .Delete:
            if let wordId = anObject.valueForKey("wordId") as? Int {
                guessedWords.removeValueForKey(wordId)
                self.updateButtonColors()
            }
            break
        case .Update:
            guard let wordId = anObject.valueForKey("wordId") as? Int, guessed = anObject.valueForKey("guessed") as? Bool else { break }
            guessedWords[wordId] = guessed
            self.updateButtonColors()
            break
        case .Move:
            break
        }
    }
}

