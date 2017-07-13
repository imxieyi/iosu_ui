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
    @IBOutlet var backBtn: UIButton!
    
    override func viewDidLoad() {
        self.headLabel.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha)
        let image = backBtn.imageView?.image!.image(withTint: UIColor("#0071A9FF"))
        backBtn.setImage(image, for: .normal)
    }
    
    @IBAction func edgeSwiped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
