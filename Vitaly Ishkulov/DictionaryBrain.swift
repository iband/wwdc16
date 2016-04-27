//
//  DictionaryBrain.swift
//  Vitaly Ishkulov
//
//  Created by Vitaly Ishkulov on 4/26/16.
//  Copyright © 2016 Vitaly Ishkulov. All rights reserved.
//

import Foundation

class DictionaryBrain {
    var jsonData: [String: AnyObject] = [:]
    
    init() {
        if let path = NSBundle.mainBundle().pathForResource("dictionary", ofType: "json") {
            do {
                let json = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let parsedObject = try NSJSONSerialization.JSONObjectWithData(json,
                                                                              options: NSJSONReadingOptions.AllowFragments)
                if let data = parsedObject as? [String : AnyObject] {
                    self.jsonData = data
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
    func wordCount() -> Int {
        return jsonData.count
    }
    
    func getElementWithNumber(number: Int) -> [String : AnyObject]? {
        if let element = jsonData["\(number)"] as? [String : AnyObject] {
            return element
        } else {
            return nil
        }
    }
}