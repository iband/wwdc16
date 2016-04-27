//
//  CardsScrollView.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class CardsScrollView: UIScrollView {
    var buttons: [BubbleButtonView] = []
    private var animator: UIDynamicAnimator!
    var firstLaunch = true
    
    private func setup() {
        self.contentSize = CGSize(width: 1000, height: 1200)
        self.scrollsToTop = false
        animator = UIDynamicAnimator(referenceView: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func refresh() {
        firstLaunch = true
        animateButtons()
    }
    
    private func repositionButtons(offsetX offsetX: CGFloat, offsetY: CGFloat) {
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
        
        self.animator.updateItemUsingCurrentState(button)
    }
    
    private func updateButtons(buttons: [BubbleButtonView]) {
        for button in buttons {
            updateButton(button)
        }
    }
    
}
