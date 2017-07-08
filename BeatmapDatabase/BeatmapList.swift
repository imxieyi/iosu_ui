//
//  BeatmapListController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit
import UIColor_Hex_Swift

class BeatmapList:UIView {
    
    @IBOutlet var headLabel: UILabel!
    
    public static var current:BeatmapList? = nil
    
    public static let globalAlpha:Float = 0.7
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        BeatmapList.current = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headLabel.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha)
    }
    
}
