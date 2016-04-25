//
//  CardsScrollView.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/25/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import UIKit

class CardsScrollView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.contentSize = CGSize(width: 1000, height: 1000)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.contentSize = CGSize(width: 1000, height: 1000)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
