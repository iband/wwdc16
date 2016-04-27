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
    
    enum WordCardField {
        case Word
        case PartOfSpeech
        case Definition
        case Example
    }
    
    init() {
        if let path = NSBundle.mainBundle().pathForResource("dictionary", ofType: "json") {
            do {
                let json = try NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
                let parsedObject = try NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.AllowFragments)
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
    
    func getElementWithNumber(number: Int) -> [WordCardField : String]? {
        if let element = jsonData["\(number)"] as? [String : AnyObject] {
            var result: [WordCardField : String] = [:]
            if let word = element["word"] as? String {
                result[.Word] = word
            }
            if let partOfSpeech = element["part"] as? String {
                result[.PartOfSpeech] = partOfSpeech
            }
            if let definition = element["definition"] as? String {
                result[.Definition] = definition
            }
            if let example = element["example"] as? String {
                result[.Example] = example
            }
            return result
        } else {
            return nil
        }
    }
    
    func getWordWithNumber(number: Int) -> String? {
        let element = self.jsonData["\(number)"] as! NSDictionary
        let word = element["word"] as! String
        return word
    }
}