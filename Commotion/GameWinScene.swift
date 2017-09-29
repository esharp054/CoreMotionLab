//
//  GameWinScene.swift
//  Commotion
//
//  Created by Elena Sharp on 9/26/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit

class GameWinScene: SKScene{
    
    let defaults = UserDefaults.standard
    
    let kGameWinHudName = "gameWinHud"
    let kPlayAgainHudName = "playAgainHud"
    let kReturnHudName = "returnHud"
    var lives = 0
    
    // MARK: View Hierarchy Functions
    override func didMove(to view: SKView){
        lives = defaults.integer(forKey: "lives")
        setupScreen()
    }
    
    func setupScreen() {
        
        let gameWinLabel = SKLabelNode(fontNamed: "Courier")
        gameWinLabel.name = kGameWinHudName
        gameWinLabel.fontSize = 50
        
        // 2
        gameWinLabel.fontColor = SKColor.white
        gameWinLabel.text = String(format: "You Won!")
        
        // 3
        gameWinLabel.position = CGPoint(
            x: self.size.width/2,
            y: 2.0 / 3.0 * self.size.height
        )
        addChild(gameWinLabel)
        
        let livesRemainingLabel = SKLabelNode(fontNamed: "Courier")
        livesRemainingLabel.name = kReturnHudName
        livesRemainingLabel.fontSize = 25
        
        // 2
        livesRemainingLabel.fontColor = SKColor.white
        livesRemainingLabel.text = String(format: "Lives Remaining: %i", lives)
        
        // 3
        livesRemainingLabel.position = CGPoint(
            x: self.size.width/2,
            y: gameWinLabel.frame.origin.y - gameWinLabel.frame.size.height - 40
        )
        addChild(livesRemainingLabel)
        
        let playAgainLabel = SKLabelNode(fontNamed: "Courier")
        playAgainLabel.name = kPlayAgainHudName
        playAgainLabel.fontSize = 25
        
        // 2
        playAgainLabel.fontColor = SKColor.white
        playAgainLabel.text = String(format: "Tap to play again")
        
        // 3
        playAgainLabel.position = CGPoint(
            x: self.size.width/2,
            y: livesRemainingLabel.frame.origin.y - livesRemainingLabel.frame.size.height - 40
        )
        addChild(playAgainLabel)
        
        
    }
    
    // MARK: UI Delegate Functions
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        self.addSprite()
        let gameScene: GameScene = GameScene(size: size)
        
        view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))

    }
}

