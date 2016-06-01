//
//  GameScene.swift
//  UCI9DC S10 FlappyBird
//
//  Created by Stanislav Sidelnikov on 27/04/16.
//  Copyright (c) 2016 Stanislav Sidelnikov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var movingObjects = SKSpriteNode()

    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }

    var gameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var timer: NSTimer?

    override func didMoveToView(view: SKView) {
        self.physicsWorld.contactDelegate = self

        self.addChild(movingObjects)

        addBgNode()
        addBirdNode()
        addGround()
        addPipes()
        addScoreLabel()

        startPipesTimer()
    }

    private func startPipesTimer() {
        if let timer = timer {
            timer.invalidate()
        }

        timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(addPipes), userInfo: nil, repeats: true)
    }

    private func addScoreLabel() {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: CGRectGetMidX(frame), y: frame.size.height - 70)
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
    }

    private func addBirdNode() {
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        bird = SKSpriteNode(texture: birdTexture)

        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.dynamic = true
        setObjectPBContacts(bird)
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue

        bird.zPosition = 1
        bird.runAction(makeBirdFlap)
        resetBird()

        self.addChild(bird)
    }

    private func resetBird() {
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody!.allowsRotation = false
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
            movingObjects.addChild(bg)
        }

    }

    func addPipes() {
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4


        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let yOffset = pipeTexture.size().height / 2 + gapHeight / 2

        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.size.width, y: CGRectGetMidY(self.frame) + yOffset + pipeOffset)
        setUpPipe(pipe1)
        movingObjects.addChild(pipe1)

        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.size.width, y: CGRectGetMidY(self.frame) - yOffset + pipeOffset)
        setUpPipe(pipe2)
        movingObjects.addChild(pipe2)

        let gap = SKNode()
        gap.position = CGPoint(x: pipe1.position.x, y: frame.size.height / 2 + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: gapHeight))
        gap.physicsBody!.dynamic = false
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        movingObjects.addChild(gap)
    }

    private lazy var moveAndRemovePipes: SKAction = {
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        return SKAction.sequence([movePipes, removePipes])
    }()

    private func setObjectPBContacts(node: SKNode) {
        if (node.physicsBody != nil) {
            node.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
            node.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
            node.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        }
    }

    private func setUpPipe(pipe: SKSpriteNode) {
        pipe.zPosition = 2
        pipe.runAction(moveAndRemovePipes)
        pipe.physicsBody = SKPhysicsBody(rectangleOfSize: pipe.texture!.size())
        pipe.physicsBody!.dynamic = false
        setObjectPBContacts(pipe)
    }

    private func addGround() {
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody!.dynamic = false
        setObjectPBContacts(ground)

        self.addChild(ground)
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
        } else {
            stopGame()
        }
    }

    private func stopGame() {
        guard !gameOver else {
            return
        }
        gameOver = true
        self.speed = 0
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "Game Over! Tap to play again."
        gameOverLabel.zPosition = 5
        gameOverLabel.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        self.addChild(gameOverLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        if (!gameOver) {
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        } else {
            score = 0
            resetBird()
            movingObjects.removeAllChildren()
            addBgNode()
            addPipes()
            startPipesTimer()
            speed = 1
            gameOver = false
            self.removeChildrenInArray([gameOverLabel])
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
