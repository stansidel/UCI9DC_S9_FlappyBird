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
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        addBgNode()
        addBirdNode()
        addGround()
        addPipes()
        NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(addPipes), userInfo: nil, repeats: true)
    }

    private func addBirdNode() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)

        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.dynamic = true

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

    func addPipes() {
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4

        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])

        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let yOffset = pipeTexture.size().height / 2 + gapHeight / 2

        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.size.width, y: CGRectGetMidY(self.frame) + yOffset + pipeOffset)
        pipe1.zPosition = 2
        pipe1.runAction(moveAndRemovePipes)
        self.addChild(pipe1)

        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.size.width, y: CGRectGetMidY(self.frame) - yOffset + pipeOffset)
        pipe2.zPosition = 2
        pipe2.runAction(moveAndRemovePipes)
        self.addChild(pipe2)

    }

    private func addGround() {
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody!.dynamic = false

        self.addChild(ground)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
