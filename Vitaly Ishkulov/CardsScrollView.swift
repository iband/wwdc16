//
//  CardsScrollView.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class CardsScrollView: UIScrollView {
    var controller: DetailsView?
    private var buttons: [BubbleButtonView] = []
    private var animator: UIDynamicAnimator!
    private var circleCenters: [CGPoint] = []
    private let circleRadius: CGFloat = 50
    private var globalButtonId = 0
    private var firstLaunch = true
    
    private let defaultCircleColor = "#00BFFF"
    
    var totalWordsCount: Int? // TODO: should be obtained from the dictionary of words
    
    private func setup() {
        self.contentSize = CGSize(width: 1000, height: 1200)
        self.scrollsToTop = false
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    func buttonsSetUp() {
        generateCircles()
        
        var buttonId = 0
        
        for center in circleCenters {
            
            buttonId = globalButtonId % (totalWordsCount! - 1) + 1 // show different words on refresh
            
            /* TODO: data from the dictionary
             let element = self.dataManager.jsonData["\(buttonId)"] as! NSDictionary
             let title = element["title"] as! String
             */
            let frame = getFrameFromCenter(center, radius: circleRadius)
            let button = BubbleButtonView(frame: frame, colorHex: defaultCircleColor)
//            button.setTitle(title, forState: .Normal)
            button.tag = buttonId
            buttonId += 1
            globalButtonId += 1
            buttons.append(button)
        }
        for button in buttons {
            button.alpha = 0
            button.addTarget(self.controller as? AnyObject, action: #selector(CardsViewController.showDetailsView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(button)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func repositionButtons(offsetX offsetX: CGFloat, offsetY: CGFloat) {
        for button in buttons {
            let newCenterX = (button.center.x - offsetX + self.contentSize.width) % self.contentSize.width
            let newCenterY = (button.center.y - offsetY + self.contentSize.height) % self.contentSize.height
            button.center = CGPointMake(newCenterX, newCenterY)
        }
    }
    
    private func recenterIfNecessary() {
        let currentOffset = contentOffset
        let contentWidth = contentSize.width
        let contentHeight = contentSize.height
        let centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0
        let centerOffsetY = (contentHeight - self.bounds.size.height) / 2.0
        
        let distanceFromCenterX = currentOffset.x - centerOffsetX
        let distanceFromCenterY = currentOffset.y - centerOffsetY
        
        if fabs(distanceFromCenterX) > contentWidth / 8.0 || fabs(distanceFromCenterY) > contentHeight / 8.0 {
            self.contentOffset = CGPointMake(centerOffsetX, centerOffsetY)
            repositionButtons(offsetX: distanceFromCenterX, offsetY: distanceFromCenterY)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // update bubble geometry when scrolling
        updateButtons(buttons)
        
        // and infinite scrolling
        recenterIfNecessary()
    }
    
    func animateButtons() {
        if firstLaunch {
            var delay = 0.0
            for button in buttons {
                delay += 0.03
                self.updateButton(button)
                let scaleFactor = sqrt(pow(button.transform.a, 2) + pow(button.transform.c, 2))
                let magnFactor: CGFloat = 1.6
                button.transform = CGAffineTransformMakeScale(magnFactor * scaleFactor, magnFactor * scaleFactor)
                
                UIView.animateWithDuration(0.9, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
                    self.updateButton(button)
                    button.alpha = 1
                    }, completion: nil)
            }
            firstLaunch = false
        }
    }
    
    private func updateButton(button: BubbleButtonView) {
        let e: CGFloat = 100 // padding when we start resizing buttons
        let frameHeight = self.frame.height
        let frameWidth = self.frame.width
        
        let x0 = min(button.center.x - contentOffset.x, frameWidth + contentOffset.x - button.center.x)
        let y0 = min(button.center.y - contentOffset.y, frameHeight + contentOffset.y - button.center.y)
        
        let rOld: CGFloat = 50
        let rMin: CGFloat = 10
        let xMin: CGFloat = 5
        
        // resize button if it's close to the scrollView frame boarder
        if x0 < e || y0 < e {
            let rNew = min(rMin + (rOld - rMin) * max(x0 - xMin, 0) / (e - xMin),
                           rMin + (rOld - rMin) * max(y0 - xMin, 0) / (e - xMin))
            let scaleFactor = rNew/rOld
            button.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
        } else {
            button.transform = CGAffineTransformMakeScale(1, 1)
        }
        
        //        if button.center.x + rMin < 0 {
        //            button.center.x += frameWidth + 2 * rMin
        //        } else if button.center.x - rMin > frameWidth {
        //            button.center.x -= (frameWidth + 2 * rMin)
        //        }
        //        if button.center.y + rMin < 0 {
        //            button.center.y += frameHeight + 2 * rMin
        //        } else if button.center.y - rMin > frameHeight {
        //            button.center.y -= (frameHeight + 2 * rMin)
        //        }
        
        self.animator.updateItemUsingCurrentState(button)
    }
    
    private func updateButtons(buttons: [BubbleButtonView]) {
        for button in buttons {
            updateButton(button)
        }
    }
    
    private func getFrameFromCenter(center: CGPoint, radius: CGFloat) -> CGRect {
        return CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
    }

    private func generateCircles() {
        // random distribution is based on Poisson Disk algorithm
        circleCenters = []
        let center = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2)
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
            let containerW = self.contentSize.width // fill the whole scrollViewContent
            let containerH = self.contentSize.height
            
            for center in circleCenters {
                let distance: CGFloat = circleRadius * 2 + 2
                let condition1 = pow((center.x - newPoint.x), 2) + pow((center.y - newPoint.y), 2) < pow(distance, 2)
                let condition2 = pow((abs(center.x - newPoint.x) - containerW), 2) + pow((center.y - newPoint.y), 2) < pow(distance, 2)
                let condition3 = pow((center.x - newPoint.x), 2) + pow((abs(center.y - newPoint.y) - containerH), 2) < pow(distance, 2)
                let condition4 = pow((abs(center.x - newPoint.x) - containerW), 2) + pow((abs(center.y - newPoint.y) - containerH), 2) < pow(distance, 2)
                
                if condition1 || condition2 || condition3 || condition4 || newPoint.x <= borderPadding || newPoint.y <= borderPadding || newPoint.x >= self.contentSize.width - borderPadding || newPoint.y >= self.contentSize.height - borderPadding {
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
        print("Total button quantity: \(circleCenters.count)")
        if circleCenters.count < 80 {
            generateCircles()
        }
    }
}
