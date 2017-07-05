//
//  LoadScene.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/5.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class LoadScene:SKScene {
    
    var emitter:SKEmitterNode? = nil
    var backprogress:SKShapeNode? = nil
    var foreprogress:SKShapeNode? = nil
    let masknode = SKCropNode()
    var x:CGFloat = 0
    var y:CGFloat = 0
    var w:CGFloat = 0
    var h:CGFloat = 7
    var progress:CGFloat = 0
    
    override func sceneDidLoad() {
        w = size.width / 2
        x = size.width / 4
        y = size.height / 2 - 20
        emitter = SKEmitterNode(fileNamed: "ProgressParticle.sks")
        emitter?.position = CGPoint(x: x, y: y + 3.5)
        emitter?.zPosition = 2
        addChild(emitter!)
        backprogress = SKShapeNode(rect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: 3.5)
        backprogress?.alpha = 0.3
        backprogress?.fillColor = .white
        backprogress?.zPosition = 0
        addChild(backprogress!)
        foreprogress = SKShapeNode(rect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: 3.5)
        foreprogress?.fillColor = .white
        foreprogress?.zPosition = 1
        masknode.addChild(foreprogress!)
        let mask = SKSpriteNode(color: .white, size: CGSize(width: w, height: h))
        mask.alpha = 1
        mask.anchorPoint = .zero
        mask.position = CGPoint(x: x, y: y)
        mask.xScale = 0
        masknode.maskNode = mask
        addChild(masknode)
    }
    
    func setProgress(p: CGFloat) {
        masknode.maskNode?.run(.scaleX(to: p, duration: 0))
        emitter?.run(.moveTo(x: x + w * p, duration: 0))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if progress < 1 {
            progress += 0.002
            setProgress(p: progress)
        }
    }
    
}
