//
//  GameOverScene.swift
//  MazeMan
//
//  Created by Huy Nguyen on 4/7/16.
//  Copyright © 2016 Jay Nguyen. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let bgColor = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: self.size.width, height: self.size.height))
        bgColor.zPosition = -1.0
        bgColor.position = CGPointMake(self.size.width/2,self.size.height/2)
        self.addChild(bgColor)
        
        // Get score
        let highScore = Scores()
        let currentScore = NSUserDefaults.standardUserDefaults().integerForKey("currentScore")
        if let savedScoreData = NSUserDefaults.standardUserDefaults().objectForKey("scoresData") as? NSData {
            let scores = NSKeyedUnarchiver.unarchiveObjectWithData(savedScoreData) as? Scores
            highScore.set(scores!.get())
        }
        highScore.add(currentScore)
        let scoreData = NSKeyedArchiver.archivedDataWithRootObject(highScore)
        NSUserDefaults.standardUserDefaults().setObject(scoreData, forKey: "scoresData")
        
        var hsString = ""
        let hsCount = highScore.scores.count
        if (hsCount > 3) {
            hsString = "\(highScore.scores[hsCount-1]) , \(highScore.scores[hsCount-2]) , \(highScore.scores[hsCount-3])"
        } else if (hsCount == 2) {
            hsString = "\(highScore.scores[hsCount-1]) , \(highScore.scores[hsCount-2])"
        } else {
            hsString = "\(highScore.scores[hsCount-1])"
        }
        
        
        let currentLabel = SKLabelNode(fontNamed: "Chalkduster")
        currentLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2+CGFloat(80))
        currentLabel.text = "Current Score is \(currentScore.description)"
        currentLabel.fontSize = 60
        currentLabel.fontColor = UIColor.blueColor()
        self.addChild(currentLabel)
        
        let hsLabel = SKLabelNode(fontNamed: "Chalkduster")
        hsLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        hsLabel.text = "High Scores: \(hsString)"
        hsLabel.fontSize = 45
        hsLabel.fontColor = UIColor.blackColor()
        self.addChild(hsLabel)
        
        let playLabel = SKLabelNode(fontNamed: "Chalkduster")
        playLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2-CGFloat(60))
        playLabel.fontSize = 30
        playLabel.text = "Tap anywhere on screen to play again!"
        playLabel.fontColor = UIColor.greenColor()
        self.addChild(playLabel)

        
        
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(GameScene.singleTap(_:)))
        singleTapGR.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGR)
    }
    
    func singleTap(sender: UITapGestureRecognizer) {
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .AspectFill
        self.view?.presentScene(gameScene, transition: transition)
    }
}
