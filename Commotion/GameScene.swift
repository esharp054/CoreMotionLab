//
//  GameScene.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion


let targetCategory : UInt32 = 0x1 << 0
let spriteCategory : UInt32 = 0x1 << 1
let borderCategory : UInt32 = 0x1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let defaults = UserDefaults.standard
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    let kSpriteName = "sprite"
    let kTargetName = "target"
    var gameEnding: Bool = false
    var lives = 0
    
    let kLiveHudName = "livesHud"

    
    var timeOfLastMove: CFTimeInterval = 0.0
    // 3
    let timePerMove: CFTimeInterval = 0.1
    
    
    func startMotionUpdates(){
        // some internal inconsistency here: we need to ask the device manager for device
        
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.1
//            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
//    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
//        if let gravity = motionData?.gravity {
//            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
//        }
//    }
    
    // MARK: View Hierarchy Functions
    override func didMove(to view: SKView){
        self.physicsWorld.contactDelegate = self
        
        lives = defaults.integer(forKey: "lives")
        
        motion.startAccelerometerUpdates()
        
        backgroundColor = SKColor.white
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addBorder()
        
        // add some stationary blocks
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.1, y: size.height * 0.25))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.9, y: size.height * 0.25))
//
//        // add a spinning block
//        self.addBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.35))
        
        self.addSprite()
        self.addTarget()
        self.setupHud()
        
    }
    
    // MARK: Create Sprites Functions
    func addSprite(){
        let spriteA = SKSpriteNode(imageNamed: "catForward") // this is literally a sprite bottle... 😎
        spriteA.name = kSpriteName
        
        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
        
        spriteA.position = CGPoint(x: size.width * random(min: CGFloat(0.1), max: CGFloat(0.9)), y: size.height * 0.75)
        
        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
//        spriteA.physicsBody?.restitution = random(min: CGFloat(1.0), max: CGFloat(1.5))
        spriteA.physicsBody!.isDynamic = true
        // 3
        spriteA.physicsBody!.affectedByGravity = false
        
        // 4
        spriteA.physicsBody!.mass = 0.02
        
        spriteA.physicsBody?.allowsRotation = false
        spriteA.physicsBody?.categoryBitMask = spriteCategory
        spriteA.physicsBody?.contactTestBitMask = targetCategory
        spriteA.physicsBody?.collisionBitMask = 0
        
        self.addChild(spriteA)
    }
    
    func addTarget(){
        let target = SKSpriteNode(imageNamed: "butterfly")
        target.name = kTargetName
        
        target.size = CGSize(width:size.width*0.1,height:size.height * 0.1)
        
        target.position = CGPoint(x: size.width * random(min: CGFloat(0.1), max: CGFloat(0.9)), y: size.height * 0.15)
        
        target.physicsBody = SKPhysicsBody(rectangleOf:target.size)
        target.physicsBody?.restitution = random(min: CGFloat(0.1), max: CGFloat(0.6))
        target.physicsBody?.isDynamic = true
        
        target.physicsBody!.affectedByGravity = false
        
        target.physicsBody?.allowsRotation = false
        
        target.physicsBody!.mass = 0.02
        target.physicsBody?.categoryBitMask = targetCategory
        target.physicsBody?.contactTestBitMask = spriteCategory | borderCategory
        target.physicsBody?.collisionBitMask = borderCategory
        
        self.addChild(target)
    }
    
    func addBorder(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bottom = SKSpriteNode()
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bottom.size = CGSize(width:size.width,height:size.height*0.1)
        bottom.position = CGPoint(x:size.width*0.5, y:0)
        
        
        for obj in [left,right,top, bottom]{
            obj.color = UIColor.white
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = true
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            
            obj.physicsBody?.categoryBitMask = borderCategory
            obj.physicsBody?.contactTestBitMask = targetCategory
            obj.physicsBody?.collisionBitMask = targetCategory
            self.addChild(obj)
        }
    }
    
    // Process user input from accelerometer
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let spriteA = childNode(withName: kSpriteName) as? SKSpriteNode {
            if let data = motion.accelerometerData {
                if fabs(data.acceleration.x) > 0.2 || fabs(data.acceleration.y) > 0.2 {
//                    print("Acceleration X: \(data.acceleration.x)")
//                    print("Acceleration Y: \(data.acceleration.y)")
                    spriteA.physicsBody!.applyForce(CGVector(dx: 25 * CGFloat(data.acceleration.x), dy: 25 * CGFloat(data.acceleration.y)))
                    if fabs(data.acceleration.x) > fabs(data.acceleration.y){
                        if data.acceleration.x < 0 {
                            spriteA.texture = SKTexture(imageNamed: "catLeft")
                        }
                        else {
                            spriteA.texture = SKTexture(imageNamed: "catRight")
                        }
                    }
                    else {
                        if data.acceleration.y < 0 {
                            spriteA.texture = SKTexture(imageNamed: "catForward")
                        }
                        else {
                            spriteA.texture = SKTexture(imageNamed: "catBack")
                        }
                    }
                }
//                else if data.acceleration.x < 0.05 && data.acceleration.y < 0.05 {
//                    print("Acceleration: \(data.acceleration.x)")
//                    print("Acceleration: \(data.acceleration.y)")
//                    spriteA.physicsBody!.velocity.dx = 0
//                    spriteA.physicsBody!.velocity.dy = 0
//                }
            }
        }
    }
    
    func setupHud() {
        
        let livesLabel = SKLabelNode(fontNamed: "Courier")
        livesLabel.name = kLiveHudName
        livesLabel.fontSize = 25
        
        // 2
        livesLabel.fontColor = SKColor.blue
        livesLabel.text = String(format: "Lives: %u", lives)
        
        // 3
        livesLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (20 + livesLabel.frame.size.height/2)
        )
        addChild(livesLabel)

    }
    
    func adjustLives() {
        lives -= 1
        defaults.set(lives, forKey:"lives")
        
        if let live = childNode(withName: kLiveHudName) as? SKLabelNode {
            live.text = String(format: "Lives: %u", self.lives)
        }
    }
    
    func moveTarget(forUpdate currentTime: CFTimeInterval) {
        // Only move if time interval for previous move has passed
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        if let target = childNode(withName: kTargetName) as? SKSpriteNode {
            target.physicsBody!.applyForce(CGVector(dx: 40 * random(min: CGFloat(-5), max: CGFloat(5)), dy: 40 * random(min: CGFloat(-5), max: CGFloat(5))))
        }
        
        // Reset Time
        self.timeOfLastMove = currentTime
    }
    
    func collisionBetween(sprite: SKNode, target: SKNode) {
        winGame()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == kSpriteName {
            collisionBetween(sprite: contact.bodyA.node!, target: contact.bodyB.node!)
        }else if contact.bodyB.node?.name == kSpriteName {
            collisionBetween(sprite: contact.bodyB.node!, target: contact.bodyA.node!)
        }
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func loseGame() {
        // 1
        if !gameEnding {
            
            gameEnding = true
            
            adjustLives()
            
            // 2
            motion.stopAccelerometerUpdates()
            
            // 3
            let gameOverScene: GameOverScene = GameOverScene(size: size)
            
            view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
    
    func winGame() {
        // 1
        if !gameEnding {
            
            gameEnding = true
            
            // 2
            motion.stopAccelerometerUpdates()
            
            // 3
            let gameWinScene: GameWinScene = GameWinScene(size: size)
            
            view?.presentScene(gameWinScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        processUserMotion(forUpdate: currentTime)
        moveTarget(forUpdate: currentTime)
        
        
        if let player = childNode(withName: kSpriteName) as? SKSpriteNode {
            if (player.position.x < -player.size.width/2.0 || player.position.x > self.size.width+player.size.width/2.0
                || player.position.y < -player.size.height/2.0 || player.position.y > self.size.height+player.size.height/2.0) {
                loseGame()
            }
        }
        
    }
}
