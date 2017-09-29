//
//  GameOverScene.swift
//  Commotion
//
//  Created by Elena Sharp on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene{
    
    let defaults = UserDefaults.standard
    
    let kGameOverHudName = "gameOverHud"
    let kPlayAgainHudName = "playAgainHud"
    var lives = 0
    
    // MARK: View Hierarchy Functions
    override func didMove(to view: SKView){
        lives = defaults.integer(forKey: "lives")
        setupScreen()
    }
    
    func setupScreen() {
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier")
        gameOverLabel.name = kGameOverHudName
        gameOverLabel.fontSize = 50
        
        // 2
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.text = String(format: "Game Over")
        
        // 3
        gameOverLabel.position = CGPoint(
            x: self.size.width/2,
            y: 2.0 / 3.0 * self.size.height
        )
        addChild(gameOverLabel)
        
        if(lives > 0){
            let playAgainLabel = SKLabelNode(fontNamed: "Courier")
            playAgainLabel.name = kPlayAgainHudName
            playAgainLabel.fontSize = 25
        
            // 2
            playAgainLabel.fontColor = SKColor.white
            playAgainLabel.text = String(format: "Tap to play again")
        
            // 3
            playAgainLabel.position = CGPoint(
                x: self.size.width/2,
                y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40
            )
            addChild(playAgainLabel)
        }
        
    }
    
    // MARK: UI Delegate Functions
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.addSprite()
        if(lives != 0){
            let gameScene: GameScene = GameScene(size: size)
            
            view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
    }
}
