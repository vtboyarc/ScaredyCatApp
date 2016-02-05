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
}

class GameScene: SKScene {
    
    var Ground = SKSpriteNode()
    var Cat = SKSpriteNode()
    
     var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
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
        Cat.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Cat.physicsBody?.affectedByGravity = false
        Cat.physicsBody?.dynamic = true
        
        Cat.zPosition = 2
        
        self.addChild(Cat)
 
     
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
            let movePipes = SKAction.moveByX(-distance, y: 0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Cat.physicsBody?.velocity = CGVectorMake(0, 0)
            //adjust the y value, higher makes jump higher
            Cat.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        }
        else {
            Cat.physicsBody?.velocity = CGVectorMake(0, 0)
            //adjust the y value, higher makes jump higher
            Cat.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        }
        
    }
    
    func createWalls() {
        
       wallPair = SKNode()
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 + 350)
        btmWall.position = CGPoint(x: self.frame.width, y: self.frame.height / 2 - 350)
        
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
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
