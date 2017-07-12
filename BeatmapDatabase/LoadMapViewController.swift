//
//  LoadMapViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/13.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class LoadMapViewController:UIViewController {
    
    @IBOutlet var loopImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DetailViewController.model?.bg.lightenByPercentage(0.1)
        loopImg.image = loopImg.image?.image(withTint: DetailViewController.model!.fg)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Reference: http://blog.csdn.net/hong1595/article/details/14527069
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(floatLiteral: .pi * 2)
        rotation.duration = 1.5
        rotation.isCumulative = true
        rotation.repeatCount = 100000
        loopImg.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    @IBAction func edgeSwiped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        ContainerViewController.current?.setblur(true)
    }
    
}
