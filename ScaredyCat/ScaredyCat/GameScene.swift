//
//  GameScene.swift
//  ScaredyCat
//
//  Created by Adam Carter on 2/4/16.
//  Copyright (c) 2016 Adam Carter. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Cat : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Cat = SKSpriteNode()
    
     var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var died = Bool()
    var restartBtn = SKSpriteNode()
    
    //this function resets everything in the game
    func restartScene() {
        
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    }
    
    func createScene() {
        
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "04b_19"
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 60
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        
        //y set to zero, so ground will be at the bottom of the screen, and slightly above it
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        //the name in quotes HAS to match the name of your image file in assets
        Cat = SKSpriteNode(imageNamed: "Cat")
        Cat.size = CGSize(width: 60, height: 70)
        Cat.position = CGPoint(x: self.frame.width / 2 - Cat.frame.width, y: self.frame.height / 2)
        
        Cat.physicsBody = SKPhysicsBody(circleOfRadius: Cat.frame.height / 2)
        Cat.physicsBody?.categoryBitMask = PhysicsCategory.Cat
        Cat.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Cat.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Cat.physicsBody?.affectedByGravity = false
        Cat.physicsBody?.dynamic = true
        
        Cat.zPosition = 2
        
        self.addChild(Cat)

    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createScene()
     
    }
    
    func createBtn() {
        
        restartBtn = SKSpriteNode(imageNamed: "RestartBtn")
        restartBtn.size = CGSizeMake(200, 100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        
        restartBtn.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Cat || firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Score {
            
            score++
            scoreLabel.text = "\(score)"
        }
        
       else if firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Cat {
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false {
                died = true
                createBtn() //if you die, calls this function
            }
        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.Cat && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Cat {
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false {
                died = true
                createBtn() //if you die, calls this function
            }
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false {
            
            gameStarted = true
            
            Cat.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.createWalls()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Cat.physicsBody?.velocity = CGVectorMake(0, 0)
            //adjust the y value, higher makes jump higher
            Cat.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        }
        else {
            if died == true {
                
            }
            else {
            Cat.physicsBody?.velocity = CGVectorMake(0, 0)
            //adjust the y value, higher makes jump higher
            Cat.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            }
        }
        
        
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if died == true {
                if restartBtn.containsPoint(location) {
                    restartScene()
                }
            }
        }
        
        
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
       // scoreNode.color = SKColor.blueColor()
        
        
       wallPair = SKNode()
       wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Cat
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if gameStarted == true {
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: ({
                   (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 6, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    }
                }))
                
            }
        }
    }
}
