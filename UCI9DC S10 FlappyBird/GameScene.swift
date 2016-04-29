//
//  GameScene.swift
//  UCI9DC S10 FlappyBird
//
//  Created by Stanislav Sidelnikov on 27/04/16.
//  Copyright (c) 2016 Stanislav Sidelnikov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        addBgNode()
        addBirdNode()
    }

    private func addBirdNode() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)
        bird.zPosition = 1
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.runAction(makeBirdFlap)

        self.addChild(bird)
    }

    private func addBgNode() {
        let bgTexture = SKTexture(imageNamed: "bg.png")
        let moveBg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replaceBg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let moveBgForever = SKAction.repeatActionForever(SKAction.sequence([moveBg, replaceBg]))

        for i in 0..<3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.zPosition = -1
            bg.position = CGPoint(x: bgTexture.size().width / 2 + bgTexture.size().width * CGFloat(i), y: CGRectGetMidY(self.frame))
            bg.size.height = self.frame.height
            bg.runAction(moveBgForever)
            self.addChild(bg)
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
