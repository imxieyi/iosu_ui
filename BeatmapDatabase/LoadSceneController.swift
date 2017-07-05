//
//  LoginSceneController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/5.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class LoadSceneController:UIViewController {
    
    override func viewDidLoad() {
        let view = self.view as! SKView
        view.autoresizesSubviews = true
        view.showsFPS=true
        view.showsNodeCount=true
        view.showsDrawCount=true
        view.showsQuadCount=true
        view.ignoresSiblingOrder=true
        view.allowsTransparency=true
        let scene = LoadScene(size: self.view.bounds.size)
        scene.scaleMode = .aspectFit
        view.presentScene(scene)
    }
    
}
