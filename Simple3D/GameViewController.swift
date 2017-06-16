//
//  GameViewController.swift
//  Simple3D
//
//  Created by vinaykumar on 6/15/17.
//  Copyright © 2017 vinaykumar. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var gameView:SCNView!
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    var gamePoint = 0
    var gameLimit = 30
    var timer = Timer()

    @IBOutlet weak var timeLimitLabel: UILabel!
    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initScene()
        self.initCamera()
        self.viewsBringToFront()
        self.startTimer()
    }
    func initView() {
        gameView = SCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), options: nil)
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
        self.view.addSubview(gameView)
    }
    func initScene() {
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true // Endless playing
    }
    func initCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    func viewsBringToFront() {
        self.timeLimitLabel.superview?.bringSubview(toFront: self.timeLimitLabel)

        self.scoreTitleLabel.superview?.bringSubview(toFront: self.scoreTitleLabel)
        self.scoreLabel.superview?.bringSubview(toFront: self.scoreLabel)
        self.gameOverButton.superview?.bringSubview(toFront: self.gameOverButton)
    }
    func createTarget() {
        let geometry:SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red //get random color
        geometry.materials.first?.diffuse.contents = randomColor
        let geometryNode = SCNNode(geometry: geometry)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        if randomColor == UIColor.red {
            geometryNode.name = "enemy"
        } else {
            geometryNode.name = "friend"
        }
        gameScene.rootNode.addChildNode(geometryNode)
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }
    func startTimer() {
        gameLimit = 30
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)

    }
    // called every time interval from the timer
    func timerAction() {
        gameLimit -= 1
        self.timeLimitLabel.text = "\(gameLimit)"
        if gameLimit == 0 {
            timer.invalidate()
            self.gameOverButton.isHidden = false
            gameView.backgroundColor = UIColor.red
            showGameOverStatus(status: false)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanUp()
    }
    func cleanUp() {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    func cleanUpAllNodes() {
        for node in gameScene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch  = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        if let hitObject = hitList.first {
            let node = hitObject.node
            if node.name == "friend" {
                gamePoint += 10
                node.removeFromParentNode()
                gameView.backgroundColor = UIColor.white
            } else {
                gameView.backgroundColor = UIColor.red
                showGameOverStatus(status: false)
            }
        }
        self.scoreLabel.text = String(gamePoint)
    }
    func showGameOverStatus(status:Bool) {
        if !status {
            cleanUpAllNodes()
            gameView.isUserInteractionEnabled = false
            gameOverButton.isUserInteractionEnabled = true
            gameScene.isPaused = true
            gameView.isHidden = true
            timeLimitLabel.isHidden = true
            timer.invalidate()
        } else {
            gameScene.isPaused = false
        }
       //gameView.isPlaying = status
       gameOverButton.isHidden = status
    }
    @IBAction func gameOverAction(_ sender: Any) {
        showGameOverStatus(status: true)
        gamePoint = 0
        gameView.backgroundColor = UIColor.white
        self.view.isUserInteractionEnabled = true
        gameView.isHidden = false
        timeLimitLabel.isHidden = false
        startTimer()
    }
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    }
    override var shouldAutorotate: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
