//
//  GameScene.swift
//  MazeMan
//
//  Created by Huy Nguyen on 4/3/16.
//  Copyright (c) 2016 Jay Nguyen. All rights reserved.
//

import SpriteKit

// Math Vector Operations
// Adding Math operations to CGPoint, exclusively to handle single tap for throwing rock 
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
// End block


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let maxBlockCount = 15
    var time = 1
    var blockTimer = NSTimer()
    var energyTimer = NSTimer()
    var fireTimer = NSTimer()
    var rockTimer = NSTimer()
    var gravityTimer = NSTimer()
    var gameTime = 0
    var slot = Array(count: 12, repeatedValue: Array(count: 16, repeatedValue: false))
    var currentX = 0
    var currentY = 1
    
    var gravityReady = true
    var lives = 3
    var energy = 100
    let maxRock = 20
    var rockCount = 10
    let gravityTime = 1
    var score = 0
    let foodBuff = 50
    let foodTimer = 10
    
    let star = SKSpriteNode(imageNamed: "star.png")
    let food = SKSpriteNode(imageNamed: "food.png")
    let player = SKSpriteNode(imageNamed: "caveman.png")
    let dino1 = SKSpriteNode(imageNamed: "dino1.png")
    let dino1Dmg = -60
    let dino2 = SKSpriteNode(imageNamed: "dino2.png")
    let dino2Dmg = -80
    let dino3 = SKSpriteNode(imageNamed: "dino3.png")
    let dino3Dmg = -100
    let dino4 = SKSpriteNode(imageNamed: "dino4.png")
    let fireDmg = -100
    var fireReady = true
    let annoucementLabel = SKLabelNode(fontNamed: "Chalkduster")
    let heartsLabel = SKLabelNode(fontNamed: "Chalkduster")
    let energyLabel = SKLabelNode(fontNamed: "Chalkduster")
    let rocksLabel = SKLabelNode(fontNamed: "Chalkduster")
    let scoresLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    let right = SKAction.moveByX(64, y: 0, duration: 0.6)
    let left = SKAction.moveByX(-64, y: 0, duration: 0.6)
    let up = SKAction.moveByX(0, y: 64, duration: 0.6)
    let down = SKAction.moveByX(0, y: -64, duration: 0.6)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        let bgImage = SKSpriteNode(imageNamed: "bg.png")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.zPosition = -1.0
        self.addChild(bgImage)
        
        
        // Add Gesture Recognizer
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedRight(_:)))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedLeft(_:)))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedUp(_:)))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipedDown(_:)))
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(GameScene.singleTap(_:)))
        singleTapGR.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTapGR)
        // End block
        
        // Add Sprites
        addDefaultBlock()
        addPlayer()
        addDino1()
        addDino2()
        addDino3()
        addDino4()
        addFood()
        addStar()
        // End block
        
        // Timers set
        fireTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.dino4Firing), userInfo: nil, repeats: true)
        
        blockTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.addRandomBlock), userInfo: nil, repeats: true)
        energyTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.constantEnergyChange), userInfo: nil, repeats: true)
        rockTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(GameScene.addRock), userInfo: nil, repeats: true)
        gravityTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(GameScene.gravity), userInfo: nil, repeats: true)
        // End block
        
        self.physicsWorld.contactDelegate = self
        
    }
    
    // not needed
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
    }
   
    // not needed, but interesting
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    // Contact test
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //print(firstBody.description)
        //print(secondBody.description)
        //if (!contacted) {
            if (firstBody.categoryBitMask == PhysicsCategory.Block && secondBody.categoryBitMask == PhysicsCategory.Hero) {
                print("player contacts block")
                player.removeActionForKey("playerMove")
                print("player stopped moving")
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Frame){
                print("player contacts wall/frame")
                player.removeActionForKey("playerMove")
                print("player stopped moving")
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Dino1) {
                print("player contacts dino1 - takes damage")
                self.runAction(SKAction.playSoundFileNamed("hits.wav", waitForCompletion: false))
                energyChange(dino1Dmg)
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Dino2) {
                print("player contacts dino2 - takes damage")
                self.runAction(SKAction.playSoundFileNamed("hits.wav", waitForCompletion: false))
                energyChange(dino2Dmg)
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Dino3) {
                print("player contacts dino3 - takes damage")
                self.runAction(SKAction.playSoundFileNamed("hits.wav", waitForCompletion: false))
                energyChange(dino3Dmg)
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Water) {
                print("player contacts water - game over")
                player.removeFromParent()
                annoucementLabel.text = "You can't swim, Game Over!"
                self.runAction(SKAction.playSoundFileNamed("gameover.wav", waitForCompletion: true))
                NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.gameOver), userInfo: nil, repeats: false)
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Fire) {
                print("player contacts fire - takes damage")
                self.runAction(SKAction.playSoundFileNamed("hits.wav", waitForCompletion: false))
                energyChange(fireDmg)
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Food) {
                print("player contacts food - increase health")
                energyChange(foodBuff)
                self.runAction(SKAction.playSoundFileNamed("bite.wav", waitForCompletion: false))
                food.removeFromParent()
                addFood()
                annoucementLabel.text = "You gain energy."
            } else if (firstBody.categoryBitMask == PhysicsCategory.Hero && secondBody.categoryBitMask == PhysicsCategory.Star) {
                print("player contacts star - increase score")
                self.runAction(SKAction.playSoundFileNamed("success.wav", waitForCompletion: false))
                score += 1
                scoresLabel.text = score.description
                star.removeFromParent()
                addStar()
                annoucementLabel.text = "You gain a point."
            } else if (firstBody.categoryBitMask == PhysicsCategory.Dino3 && secondBody.categoryBitMask == PhysicsCategory.Frame) {
                print("dino3 contacts frame")
                dino3.removeActionForKey("dino3Move")
                dino3Movement()
            } else if (firstBody.categoryBitMask == PhysicsCategory.Block && secondBody.categoryBitMask == PhysicsCategory.Dino3) {
                print("dino3 contacts block")
                dino3.removeActionForKey("dino3Move")
                dino3Movement()
            } else if ((firstBody.categoryBitMask == PhysicsCategory.Dino1) || (firstBody.categoryBitMask == PhysicsCategory.Dino2) || (firstBody.categoryBitMask == PhysicsCategory.Dino3)) && (secondBody.categoryBitMask == PhysicsCategory.Food) {
                print("dino contacts food")
                self.runAction(SKAction.playSoundFileNamed("bite.wav", waitForCompletion: false))
                food.removeFromParent()
                NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(GameScene.addFood), userInfo: nil, repeats: false)
                annoucementLabel.text = "Enemy ate your food, respawn in 10s"
            } else if (firstBody.categoryBitMask == PhysicsCategory.Dino1 && secondBody.categoryBitMask == PhysicsCategory.Rock) {
                dino1.removeFromParent()
                self.runAction(SKAction.playSoundFileNamed("death.wav", waitForCompletion: false))
                let randomRespawn = Double(arc4random_uniform(5)+1)
                print("dino1 hits - respawn in \(randomRespawn.description)s")
                NSTimer.scheduledTimerWithTimeInterval(randomRespawn, target: self, selector: #selector(GameScene.addDino1), userInfo: nil, repeats: false)
                annoucementLabel.text = "You killed Dino 1, respawn in \(Int(randomRespawn).description)s"
            } else if (firstBody.categoryBitMask == PhysicsCategory.Dino2 && secondBody.categoryBitMask == PhysicsCategory.Rock) {
                dino2.removeFromParent()
                self.runAction(SKAction.playSoundFileNamed("death.wav", waitForCompletion: false))
                let randomRespawn = Double(arc4random_uniform(5)+1)
                print("dino2 hits - respawn in \(randomRespawn.description)s")
                NSTimer.scheduledTimerWithTimeInterval(randomRespawn, target: self, selector: #selector(GameScene.addDino2), userInfo: nil, repeats: false)
                annoucementLabel.text = "You killed Dino 2, respawn in \(Int(randomRespawn).description)s"
            } else if (firstBody.categoryBitMask == PhysicsCategory.Dino3 && secondBody.categoryBitMask == PhysicsCategory.Rock) {
                dino3.removeFromParent()
                self.runAction(SKAction.playSoundFileNamed("death.wav", waitForCompletion: false))
                let randomRespawn = Double(arc4random_uniform(5)+1)
                print("dino3 hits - respawn in \(randomRespawn.description)s")
                NSTimer.scheduledTimerWithTimeInterval(randomRespawn, target: self, selector: #selector(GameScene.addDino3), userInfo: nil, repeats: false)
                annoucementLabel.text = "You killed Dino 3, respawn in \(Int(randomRespawn).description)s"
            } else if (firstBody.categoryBitMask == PhysicsCategory.Fire && secondBody.categoryBitMask == PhysicsCategory.Rock) {
                firstBody.node!.removeFromParent()
                print("fire hits")
            }

    }
    // End block
    // Remark: could have simplify this
    
    
    // Handle Gestures
    func swipedRight(sender:UISwipeGestureRecognizer){
        print("swiped right")
        //self.removeActionForKey("playerMove")
        if (player.xScale > 0) {
            player.xScale = player.xScale * -1
        }
        player.runAction(SKAction.repeatActionForever(right), withKey: "playerMove")
    }
    
    func swipedLeft(sender:UISwipeGestureRecognizer){
        print("swiped left")
        //self.removeActionForKey("playerMove")
        if (player.xScale < 0) {
            player.xScale = player.xScale * -1
        }
        player.runAction(SKAction.repeatActionForever(left), withKey: "playerMove")

    }
    
    func swipedUp(sender:UISwipeGestureRecognizer){
        print("swiped up")
        //self.removeActionForKey("playerMove")
        player.runAction(SKAction.repeatActionForever(up), withKey: "playerMove")
    }
    
    func swipedDown(sender:UISwipeGestureRecognizer){
        print("swiped down")
        //self.removeActionForKey("playerMove")
        player.runAction(SKAction.repeatActionForever(down), withKey: "playerMove")
    }
    
    func singleTap(sender:UITapGestureRecognizer) {
        print("single tap")
        var location : CGPoint
            location = sender.locationInView(self.view)
            location = self.convertPointFromView(location)
        if (rockCount > 0) {
            let rock = SKSpriteNode(imageNamed:"rock.png")
            rock.size = CGSize(width: 30, height: 30)
            rock.position = player.position
            rock.zPosition = 0.9
            rock.physicsBody = SKPhysicsBody(rectangleOfSize: rock.size)
            rock.physicsBody?.dynamic = true
            rock.physicsBody?.affectedByGravity = false
            rock.physicsBody?.categoryBitMask = PhysicsCategory.Rock
            rock.physicsBody?.collisionBitMask = PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
            rock.physicsBody?.contactTestBitMask = PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3 | PhysicsCategory.Fire
            
            let offset = location - rock.position
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            rock.runAction(SKAction.repeatActionForever(action))
            self.addChild(rock)
            let direction = offset.normalized()
            let shootAmount = direction*2000
            let dest = rock.position + shootAmount
            self.runAction(SKAction.playSoundFileNamed("throwrock.wav", waitForCompletion: false))
            rock.runAction(SKAction.sequence([SKAction.moveTo(dest, duration: 5),SKAction.removeFromParent()]))
            rockCount -= 1
            rocksLabel.text = rockCount.description
        }
    }
    // End block
    
    // Add Sprites Functions
    func addDefaultBlock() {
        for i in 0 ..< 48 {
            if (i==5 || i==11) {
                let water = SKSpriteNode(imageNamed: "water.png")
                water.size = CGSize(width: 64, height: 58)
                water.position = CGPoint(x: 32+i*64, y: 26)
                water.physicsBody = SKPhysicsBody(rectangleOfSize: water.size)
                water.physicsBody?.dynamic = false
                water.physicsBody?.affectedByGravity = false
                water.physicsBody?.categoryBitMask = PhysicsCategory.Water
                water.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
                //water.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
                water.zPosition = 0.0
                self.addChild(water)
                slot[0][i] = true
            } else if (i < 16) {
                let block = SKSpriteNode(imageNamed: "block.png")
                block.size = CGSize(width: 64, height: 64)
                block.position = CGPoint(x: 32+i*64, y: 32)
                block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
                block.physicsBody?.dynamic = false
                block.physicsBody?.affectedByGravity = false
                block.physicsBody?.categoryBitMask = PhysicsCategory.Frame
                //block.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
                block.zPosition = 0.5
                self.addChild(block)
                slot[0][i] = true
            } else if (i < 32) {
                let block = SKSpriteNode(imageNamed: "block.png")
                block.size = CGSize(width: 64, height: 64)
                block.position = CGPoint(x: 32+(i-16)*64, y: 32+10*64)
                block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
                block.physicsBody?.dynamic = false
                block.physicsBody?.affectedByGravity = false
                block.physicsBody?.categoryBitMask = PhysicsCategory.Frame
                //block.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
                block.zPosition = 0.5
                self.addChild(block)
                slot[10][i-16] = true
            } else if (i < 48) {
                let block = SKSpriteNode(imageNamed: "block.png")
                block.size = CGSize(width: 64, height: 64)
                block.position = CGPoint(x: 32+(i-32)*64, y: 32+11*64)
                block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
                block.physicsBody?.dynamic = false
                block.physicsBody?.affectedByGravity = false
                block.physicsBody?.categoryBitMask = PhysicsCategory.Frame
                //block.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
                block.zPosition = 0.5
                self.addChild(block)
                slot[11][i-32] = true
            }
        }
        
        let scores = SKSpriteNode(imageNamed: "star.png")
        scores.size = CGSize(width: 60, height: 60)
        scores.position = CGPoint(x: 32, y: 32)
        scores.zPosition = 0.6
        self.addChild(scores)
        scoresLabel.text = score.description
        scoresLabel.fontSize = 30
        scoresLabel.position = CGPoint(x: 29, y: 20)
        scoresLabel.zPosition = 0.7
        self.addChild(scoresLabel)
        
        let rocks = SKSpriteNode(imageNamed: "rock.png")
        rocks.size = CGSize(width: 60, height: 60)
        rocks.position = CGPoint(x: 32+64, y: 32)
        rocks.zPosition = 0.6
        self.addChild(rocks)
        rocksLabel.text = rockCount.description
        rocksLabel.fontSize = 30
        rocksLabel.position = CGPoint(x: 29+64, y: 20)
        rocksLabel.zPosition = 0.7
        self.addChild(rocksLabel)
        
        let hearts = SKSpriteNode(imageNamed: "heart.png")
        hearts.size = CGSize(width: 60, height: 60)
        hearts.position = CGPoint(x: 32+128, y: 32)
        hearts.zPosition = 0.6
        self.addChild(hearts)
        heartsLabel.text = lives.description
        heartsLabel.fontSize = 30
        heartsLabel.position = CGPoint(x: 29+128, y: 20)
        heartsLabel.zPosition = 0.7
        self.addChild(heartsLabel)
        
        let enBar = SKSpriteNode(imageNamed: "battery.png")
        enBar.size = CGSize(width: 150, height: 110)
        enBar.position = CGPoint(x: 256, y: 32)
        enBar.zPosition = 0.6
        self.addChild(enBar)
        energyLabel.text = energy.description
        energyLabel.fontSize = 30
        energyLabel.position = CGPoint(x: 192+30+32, y: 20)
        energyLabel.zPosition = 0.7
        self.addChild(energyLabel)
        
        let statBar = SKSpriteNode(imageNamed: "game-status-panel.png")
        statBar.size = CGSize(width: 64*15, height: 128)
        statBar.position = CGPoint(x: self.frame.width/2+CGFloat(10), y: self.frame.height-CGFloat(64))
        statBar.zPosition = 0.6
        self.addChild(statBar)
        
        annoucementLabel.text = "Hello, Welcome to MazeMan!"
        annoucementLabel.fontSize = 35
        annoucementLabel.position = CGPoint(x: self.frame.width/2+CGFloat(10), y: self.frame.height-CGFloat(74))
        annoucementLabel.zPosition = 0.9
        self.addChild(annoucementLabel)
        
        self.physicsBody = SKPhysicsBody.init(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Frame
        //self.physicsBody?.collisionBitMask = PhysicsCategory.Hero | PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
        self.physicsBody?.dynamic = false

    }
    
    func addPlayer() {
        // Player Sprite
        player.size = CGSize(width: 48, height: 48)
        player.position = CGPoint(x: 32, y: 96)
        player.xScale = player.xScale * -1
        player.physicsBody?.allowsRotation = false
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        player.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Frame
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3 | PhysicsCategory.Fire | PhysicsCategory.Food | PhysicsCategory.Star | PhysicsCategory.Water | PhysicsCategory.Block
        player.zPosition = 1.0
        self.addChild(player)
    }
    
    func addDino1() {
        // Dino1
        dino1.size = CGSize(width: 60, height: 60)
        let random1 = Int(arc4random_uniform(2))
        if random1 == 0 {
            dino1.position = CGPoint(x: 32+5*64, y: 32)
        } else {
            dino1.position = CGPoint(x: 32+11*64, y: 32)
        }
        dino1.physicsBody = SKPhysicsBody(rectangleOfSize: dino1.size)
        dino1.physicsBody?.dynamic = true
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.categoryBitMask = PhysicsCategory.Dino1
        dino1.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        dino1.physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.Food
        dino1.zPosition = 1.0
        self.addChild(dino1)
        let dino1Up = SKAction.repeatAction(SKAction.moveByX(0, y: 64, duration: 0.4), count: 9)
        let dino1Down = SKAction.repeatAction(SKAction.moveByX(0, y: -64, duration: 0.4), count: 9)
        let delay1 = SKAction.waitForDuration(1.5, withRange: 3.0)
        let delay12 = SKAction.waitForDuration(1.5, withRange: 3.0)
        dino1.runAction(SKAction.repeatActionForever(SKAction.sequence([dino1Up,delay1,dino1Down,delay12])), withKey: "dino1Move")
    }
    
    func addDino2() {
        // Dino2
        dino2.size = CGSize(width: 60, height: 60)
        let random2 = Int(arc4random_uniform(9))
        dino2.position = CGPoint(x: 32+15*64, y: 32+(random2+1)*64)
        dino2.physicsBody = SKPhysicsBody(rectangleOfSize: dino2.size)
        dino2.physicsBody?.dynamic = true
        dino2.physicsBody?.affectedByGravity = false
        dino2.physicsBody?.categoryBitMask = PhysicsCategory.Dino2
        dino2.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        dino2.physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.Food
        dino2.zPosition = 1.0
        self.addChild(dino2)
        let dino2Left = SKAction.repeatAction(SKAction.moveByX(-64, y: 0, duration: 0.4), count: 15)
        let dino2Right = SKAction.repeatAction(SKAction.moveByX(64, y: 0, duration: 0.4), count: 15)
        let delay2 = SKAction.waitForDuration(1.5, withRange: 3.0)
        let delay22 = SKAction.waitForDuration(1.5, withRange: 3.0)
        let dino2FlipLeft = SKAction.scaleXTo(-1, duration: 0)
        let dino2FlipRight = SKAction.scaleXTo(1, duration: 0)
        dino2.runAction(SKAction.repeatActionForever(SKAction.sequence([dino2Left,dino2FlipLeft,delay2,dino2Right,dino2FlipRight,delay22])), withKey: "dino2Move")
    }
    
    func addDino3() {
        // Dino3
        dino3.size = CGSize(width: 60, height: 60)
        dino3.position = CGPoint(x: 32, y: 32+9*64)
        dino3.physicsBody = SKPhysicsBody(rectangleOfSize: dino3.size)
        dino3.physicsBody?.dynamic = true
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.categoryBitMask = PhysicsCategory.Dino3
        dino3.physicsBody?.collisionBitMask = PhysicsCategory.Frame | PhysicsCategory.Block
        dino3.physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.Frame | PhysicsCategory.Food | PhysicsCategory.Block
        dino3.zPosition = 1.0
        dino3.physicsBody?.allowsRotation = false
        self.addChild(dino3)
        dino3Movement()
    }
    
    // Dino3 Random Movement
    func dino3Movement() {
        let dino3X = (Int(dino3.position.x+16.0) - 32)/64
        let dino3Y = (Int(dino3.position.y+16.0) - 32)/64
        print("\(dino3X.description) , \(dino3Y.description)")
        //let randomX = Int(arc4random_uniform(3)-1)
        //let randomY = Int(arc4random_uniform(3)-1)
        var canR = false
        var canL = false
        var canU = false
        var canD = false
        if  (dino3X < 15){
            if (!slot[dino3Y][dino3X+1]) {
                canR = true
            }
        }
        if (dino3X > 0) {
            if (!slot[dino3Y][dino3X-1]) {
                canL = true
            }
        }
        if (dino3Y > 1) {
            if (!slot[dino3Y-1][dino3X]) {
                canD = true
            }
        }
        if (dino3Y < 9) {
            if (!slot[dino3Y+1][dino3X]) {
                canU = true
            }
        }
        print("R:\(canR), L:\(canL), U:\(canU), D:\(canD)")
        var decided = -1
        while (decided == -1) {
            let randomD = Int(arc4random_uniform(4))
            if (canR && randomD == 0) {
                decided = 0
            }
            if (canL && randomD == 1) {
                decided = 1
            }
            if (canU && randomD == 2) {
                decided = 2
            }
            if (canD && randomD == 3) {
                decided = 3
            }
        }
        switch(decided) {
        case 0: dino3.runAction(SKAction.group([SKAction.repeatActionForever(right),SKAction.rotateToAngle(0, duration: 0.2, shortestUnitArc: true)]), withKey: "dino3Move")
            break
        case 1: dino3.runAction(SKAction.group([SKAction.repeatActionForever(left),SKAction.rotateToAngle(3.14, duration: 0.2, shortestUnitArc: true)]), withKey: "dino3Move")
            break
        case 2: dino3.runAction(SKAction.group([SKAction.repeatActionForever(up),SKAction.rotateToAngle(3.14/2, duration: 0.2, shortestUnitArc: true)]), withKey: "dino3Move")
            break
        case 3: dino3.runAction(SKAction.group([SKAction.repeatActionForever(down),SKAction.rotateToAngle(-3.14/2, duration: 0.2, shortestUnitArc: true)]), withKey: "dino3Move")
            break
        default: break
        }
    }
    // End block
    // Remark: Still unreliable, movement can still stuck at times
    
    func addDino4() {
        // Dino4
        dino4.size = CGSize(width: 60, height: 60)
        dino4.position = CGPoint(x: 32, y: 32+10*64)
        dino4.physicsBody = SKPhysicsBody(rectangleOfSize: dino4.size)
        dino4.physicsBody?.dynamic = false
        dino4.physicsBody?.affectedByGravity = false
        dino4.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        dino4.zPosition = 0.8
        self.addChild(dino4)
        let dino4Left = SKAction.repeatAction(SKAction.moveByX(-64, y: 0, duration: 0.4), count: 15)
        let dino4Right = SKAction.repeatAction(SKAction.moveByX(64, y: 0, duration: 0.4), count: 15)
        dino4.runAction(SKAction.repeatActionForever(SKAction.sequence([dino4Right,dino4Left])), withKey: "dino4Right")
    }
    
    func addRandomBlock() {
        // get player position
        let playerPosition = player.position
        currentX = (Int(playerPosition.x+1.0) - 32)/64
        currentY = (Int(playerPosition.y+1.0) - 32)/64
        
        // print player sprite position according to grid
        // print(time.description + ": " + currentX.description + ", " + currentY.description)
        
        // generate random position for block
        var occupied = false
        var randomX = 0
        var randomY = 0
        while(!occupied) {
            randomX = Int(arc4random_uniform(16))
            randomY = Int(arc4random_uniform(8)) + 1
            if (!slot[randomY][randomX] && (randomX != currentX)) {
                slot[randomY][randomX] = true
                occupied = true
            }
        }
        // print decided block location
        print(time.description + ": " + randomX.description + ", " + randomY.description)
        
        // add block
        let block = SKSpriteNode(imageNamed: "block.png")
        block.size = CGSize(width: 64, height: 64)
        block.position = CGPoint(x: 32+randomX*64, y: 32+randomY*64)
        block.zPosition = 0.5
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.dynamic = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block
        block.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        self.addChild(block)
        
        // invalidate timer when maxblockcount reached
        time += 1
        if (time > maxBlockCount) {
            blockTimer.invalidate()
        }
    }
    
    func dino4Firing() {
        if (fireReady) {
            let randomDelay = Double(arc4random_uniform(6)+5)
            print("\(gameTime.description): fire in \(randomDelay.description) seconds")
            NSTimer.scheduledTimerWithTimeInterval(randomDelay, target: self, selector: #selector(GameScene.dropFire), userInfo: nil, repeats: false)
            fireReady = false
        }
    }
    
    func dropFire() {
        let dino4position = dino4.position
        let fire = SKSpriteNode(imageNamed: "fire.png")
        fire.size = CGSize(width: 48, height: 48)
        fire.position = CGPoint(x: dino4position.x, y: dino4position.y-CGFloat(10))
        fire.zPosition = 0.9
        fire.physicsBody = SKPhysicsBody(rectangleOfSize: fire.size)
        fire.physicsBody?.affectedByGravity = false
        fire.physicsBody?.dynamic = false
        fire.physicsBody?.categoryBitMask = PhysicsCategory.Fire
        fire.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        fire.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        self.addChild(fire)
        let fireDown = SKAction.moveToY(-32.0, duration: 4.0)
        fire.runAction(fireDown, completion: {fire.removeFromParent()})
        print(gameTime.description + ": dino4 fired")
        fireReady = true
    }
    
    func addFood() {
        // get player position
        let playerPosition = player.position
        currentX = (Int(playerPosition.x+1.0) - 32)/64
        currentY = (Int(playerPosition.y+1.0) - 32)/64
        
        var occupied = false
        var randomX = 0
        var randomY = 0
        while(!occupied) {
            randomX = Int(arc4random_uniform(16))
            randomY = Int(arc4random_uniform(8)) + 1
            if (!slot[randomY][randomX] && (randomX != currentX)) {
                slot[randomY][randomX] = true
                occupied = true
            }
        }
        
        food.size = CGSize(width: 64, height: 64)
        food.position = CGPoint(x: 32+randomX*64, y: 32+randomY*64)
        food.zPosition = 0.5
        food.physicsBody = SKPhysicsBody(rectangleOfSize: food.size)
        food.physicsBody?.affectedByGravity = false
        food.physicsBody?.dynamic = false
        food.physicsBody?.categoryBitMask = PhysicsCategory.Food
        food.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        food.physicsBody?.contactTestBitMask = PhysicsCategory.Hero | PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
        self.addChild(food)
    }
    
    func addStar() {
        // get player position
        let playerPosition = player.position
        currentX = (Int(playerPosition.x+1.0) - 32)/64
        currentY = (Int(playerPosition.y+1.0) - 32)/64

        var occupied = false
        var randomX = 0
        var randomY = 0
        while(!occupied) {
            randomX = Int(arc4random_uniform(16))
            randomY = Int(arc4random_uniform(8)) + 1
            if (!slot[randomY][randomX] && (randomX != currentX)) {
                slot[randomY][randomX] = true
                occupied = true
            }
        }
        
        // add star
        star.size = CGSize(width: 64, height: 64)
        star.position = CGPoint(x: 32+randomX*64, y: 32+randomY*64)
        star.zPosition = 0.5
        star.physicsBody = SKPhysicsBody(rectangleOfSize: star.size)
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.dynamic = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.Star
        star.physicsBody?.collisionBitMask = PhysicsCategory.Nothing
        star.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        self.addChild(star)
    }
    
    
    // Starting Functioning Block
    func energyChange(point : Int) {
        if (point < 0) {
            if (energy > (point * -1)) {
                energy += point
            } else if (energy <= (point * -1)) && (lives > 1) {
                lives -= 1
                let leftover = point + energy
                energy = 100 + leftover
            } else if (energy <= (point * -1)) && (lives == 1) {
                print("out of lives and energy - game over")
                lives = 0
                energy = 0
                player.removeFromParent()
                annoucementLabel.text = "You ran out of energy, Game Over!"
                self.runAction(SKAction.playSoundFileNamed("gameover.wav", waitForCompletion: true))
                NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(GameScene.gameOver), userInfo: nil, repeats: false)
            }
        } else if (point > 0){
            if (energy + point > 100 && lives < 3) {
                lives += 1
                let extra = energy + point - 100
                energy = extra
            } else if (energy + point > 100 && lives == 3) {
                energy = 100
            } else {
                energy += point
            }
        }
        energyLabel.text = energy.description
        heartsLabel.text = lives.description
    }
    
    func constantEnergyChange() {
        energyChange(-1)
        gameTime += 1
    }
    
    func addRock() {
        if (rockCount < maxRock) {
            rockCount += 1
        }
    }
    
    func gravity() {
        if (gravityReady) {
            let randomDelay = Double(arc4random_uniform(21)+37)
            NSTimer.scheduledTimerWithTimeInterval(randomDelay, target: self, selector: #selector(GameScene.enableGravity), userInfo: nil, repeats: false)
            gravityReady = false
        }
    }
    
    func enableGravity() {
        annoucementLabel.text = "Gravity time is very close!!!"
        player.runAction(SKAction.sequence([
            SKAction.waitForDuration(3),
            SKAction.runBlock( {
            self.player.physicsBody?.affectedByGravity = true
        } ), SKAction.waitForDuration(1),
            SKAction.runBlock( {
                self.player.physicsBody?.affectedByGravity = false
            } )]), completion: {
                self.annoucementLabel.text = "Gravity time is over."
            })
        gravityReady = true
    }
    
    func gameOver() {
        
        // Save score (Pass data to 2nd scene)
        NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "currentScore")
        NSUserDefaults.standardUserDefaults().synchronize()

        
        //self.removeAllActions()
        self.removeAllChildren()
        blockTimer.invalidate()
        energyTimer.invalidate()
        fireTimer.invalidate()
        rockTimer.invalidate()
        gravityTimer.invalidate()
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.scaleMode = .AspectFill
        self.view?.presentScene(gameOverScene, transition: transition)
    }
    // End block
}

// Struct
struct PhysicsCategory {
    static let Block: UInt32 = 0x1 << 0
    static let Hero: UInt32 = 0x1 << 1
    static let Water: UInt32 = 0x1 << 2
    static let Dino1: UInt32 = 0x1 << 3
    static let Dino2: UInt32 = 0x1 << 4
    static let Dino3: UInt32 = 0x1 << 5
    static let Fire: UInt32 = 0x1 << 6
    static let Star: UInt32 = 0x1 << 7
    static let Food: UInt32 = 0x1 << 8
    static let Rock: UInt32 = 0x1 << 9
    static let Frame: UInt32 = 0x1 << 10
    static let Nothing: UInt32 = 0x1 << 20
}
// End block
// Remark: could have send to another file reduce cluster
