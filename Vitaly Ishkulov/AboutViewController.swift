//
//  AboutViewController.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/30/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
//    @IBOutlet weak var scrollView: UIScrollView!
    private var scrollView: UIScrollView!
    private var padding: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: self.view.frame)
        padding = self.view.frame.size.height * 0.03125
        self.title = "About"
        self.view.addSubview(scrollView)
        
        addImage("AboutAvatar")
        addText("Hello! My name is Vitaly. My last holidays I spent in Barcelona where I was totally amazed with the mix of cultures, vibrant life and rich history. There I started learning Spanish. \n\nOne of the most important part of learning the new language is building a vocabulary, and one of the most efficient ways to do that is using cards. So I decided to create an app for my WWDC ’16 Scholarship application that allows to explore the most frequently used Spanish words and learn them during this process. \n\nHave fun 3D Touching :)")
        
        self.scrollView.contentSize.height += 50
        
        // Do any additional setup after loading the view.
    }
    
    private func labelWithHeight(text: NSAttributedString, font: UIFont, width: CGFloat) -> UILabel {
        let label: UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.attributedText = text
        label.textColor = UIColor.darkGrayColor()
        label.textAlignment = .Justified
        label.sizeToFit()
        return label
    }
    
    private func addImage(fileName: String) {
        if let image = UIImage(named: fileName) {
            let imageView = UIImageView(image: image)
            imageView.frame.size = CGSize(width: self.view.frame.width, height: imageView.image!.size.height)
            imageView.contentMode = UIViewContentMode.Center
            imageView.clipsToBounds = true
            imageView.frame.origin.y = padding
            padding += imageView.frame.height
            self.scrollView.contentSize.height += imageView.frame.height
            
            self.scrollView.addSubview(imageView)
        }
    }
    
    private func addText(text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        paragraphStyle.hyphenationFactor = 0.9
        
        let attributedString = NSAttributedString(string: text, attributes: [
            NSParagraphStyleAttributeName: paragraphStyle, NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
        
        let font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        let borderSize = 0.125 * self.view.frame.size.width / 2
        let label = labelWithHeight(attributedString, font: font, width: view.frame.width - borderSize * 2)
        label.frame.origin.x = borderSize
        label.frame.origin.y = padding + 20
        self.scrollView.contentSize.height += label.frame.height + 20
        padding += label.frame.height + 20
        
        self.scrollView.addSubview(label)
    }
}
