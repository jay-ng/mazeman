//
//  Scores.swift
//  MazeMan
//
//  Created by Huy Nguyen on 4/7/16.
//  Copyright © 2016 Jay Nguyen. All rights reserved.
//

import Foundation

class Scores: NSObject, NSCoding {
    
    var scores = [Int]()
    
    /*override init() {
        currentScore = 0
        scores.append(0)
    }*/
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        self.scores = (aDecoder.decodeObjectForKey("scores") as? [Int])!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(scores, forKey: "scores")
    }
    
    func add(score: Int) {
        scores.append(score)
        scores.sortInPlace()
    }
    
    func set(scores: [Int]) {
        for i in scores {
            self.add(i)
        }
    }
    
    func get() -> [Int] {
        return scores
    }
    
}