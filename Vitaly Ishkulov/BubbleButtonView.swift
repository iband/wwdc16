//
//  BubbleButtonView.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class BubbleButtonView: UIButton {
    
    private var color = UIColor.clearColor()
    var colorHex: String? {
        willSet {
            self.color = colorWithHexString(newValue!)
            self.setNeedsDisplay()
        }
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
            //            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
        color.setFill()
        path.fill()
    }

}
