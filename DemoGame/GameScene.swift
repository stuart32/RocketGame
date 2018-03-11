import SpriteKit

var monstersDestroyed = 0

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}



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




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 1
    let player = SKSpriteNode(imageNamed: "rocket")
    let background = SKSpriteNode(imageNamed: "space")
    
    
    
    override func didMove(to view: SKView) {
        // 2
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.zPosition = 0
        let size = CGSize(width: frame.size.width, height: frame.size.height)
        background.scale(to: size)
        addChild(background)
        // backgroundColor = SKColor.white
        // 3
        player.position = CGPoint(x: size.width/2, y: size.height/2)
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size) // 1
        player.physicsBody?.isDynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        player.physicsBody?.affectedByGravity = true
        // 4
        addChild(player)
        
        
        physicsWorld.gravity = CGVector.init(dx: 0.0, dy: -9.81)
        physicsWorld.contactDelegate = self
        

        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addItem),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
    }
    
    
    
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    /*
    func addMonster() {
        
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the X axis
        let actualX = random(min: 0, max: size.width )
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: actualX , y: size.height + monster.size.height/2)
        monster.zPosition = 1
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
       // monster.run(SKAction.sequence([actionMove, actionMoveDone]))
     
        let loseAction = SKAction.run() {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
 
    }
    */
    
    
    
    func addProjectile(){
        

    }
    
    
    
    func addPerson(){
        
        
    }
    
    
    
    func addItem(){
        let x = self.random(min:0,max:100)
        if(x > 20){
            let projectile = SKSpriteNode(imageNamed: "fire2")
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            projectile.physicsBody?.affectedByGravity = false
            
            
            // Determine where to spawn the monster along the X axis
            let actualX = random(min: 0, max: size.width)
            
            // Position the monster slightly off-screen along the right edge,
            // and along a random position along the Y axis as calculated above
            projectile.position = CGPoint(x: actualX , y: size.height + projectile.size.height/2)
            projectile.zPosition = 1
            let endLocationX = random(min: 200, max: size.width - 200)
            let endLocation = CGPoint(x: endLocationX, y: 0)
            let offset = endLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            //if (offset.x < 0) { return }
            
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            //projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
            
            let loseAction = SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            projectile.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        }
        else{
            let projectile = SKSpriteNode(imageNamed: "green")
            
            projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
            projectile.physicsBody?.isDynamic = true
            projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
            projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            projectile.physicsBody?.usesPreciseCollisionDetection = true
            projectile.physicsBody?.affectedByGravity = false
            
            
            // Determine where to spawn the monster along the X axis
            let actualX = random(min: 0, max: size.width)
            
            // Position the monster slightly off-screen along the right edge,
            // and along a random position along the Y axis as calculated above
            projectile.position = CGPoint(x: actualX , y: size.height + projectile.size.height/2)
            projectile.zPosition = 1
            let endLocationX = random(min: 200, max: size.width - 200)
            let endLocation = CGPoint(x: endLocationX, y: 0)
            let offset = endLocation - projectile.position
            
            // 4 - Bail out if you are shooting down or backwards
            //if (offset.x < 0) { return }
            
            addChild(projectile)
            
            // 6 - Get the direction of where to shoot
            let direction = offset.normalized()
            
            // 7 - Make it shoot far enough to be guaranteed off screen
            let shootAmount = direction * 1000
            
            // 8 - Add the shoot amount to the current position
            let realDest = shootAmount + projectile.position
            
            // 9 - Create the actions
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            //projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
            
            let loseAction = SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            projectile.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        }
    }
    
    var leftTouch = false
    var rightTouch = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for obj in touches {
            let location = obj.location(in: self)
            if(location.x < size.width/2){
                leftTouch = true
            }
            else if(location.x > size.width/2){
                rightTouch = true
            }
        }
        
        

    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for obj in touches {
            let location = obj.location(in: self)
            if(location.x < size.width/2){
                leftTouch = false
            }
            else if(location.x > size.width/2){
                rightTouch = false
            }
        }
       
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if(leftTouch == true && rightTouch == true){
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: 3000))
            print("up")
        }
            
        if(leftTouch == true && rightTouch == false){
            player.physicsBody?.applyForce(CGVector(dx: 2000, dy: 2000))
            print("right")
        }
        if(leftTouch == false && rightTouch == true){
            player.physicsBody?.applyForce(CGVector(dx: -2000, dy: 2000))
            print("left")
        }
        
        
        if(player.position.y < -1 * player.size.height/2){
            let loseAction = SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
            player.run(SKAction.sequence([loseAction]))
        }
    }
    
    
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        projectile.removeFromParent()
       // monster.removeFromParent()
        
        monstersDestroyed += 1
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
    
}
