//
//  SettingViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/9.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController:UIViewController {
    
    @IBOutlet var headLabel: UILabel!
    
    override func viewDidLoad() {
        self.headLabel.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha)
    }
    
    @IBAction func edgeSwiped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
