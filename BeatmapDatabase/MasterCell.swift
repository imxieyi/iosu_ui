//
//  MasterCellController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//
//  Reference: https://grayluo.github.io/WeiFocusIo/cocoa-swift/2015/12/19/swiftpracticeuitableview2

import Foundation
import UIKit
import UIImageColors

class MasterCell:UITableViewCell {
    
    @IBOutlet var thumbImg: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    static let bgcolor = UIColor(colorLiteralRed: 0, green: 0.441, blue: 0.660, alpha: BeatmapList.globalAlpha)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
        self.backgroundColor = MasterCell.bgcolor
    }
    
    func updateData(obj:MasterCellModel) {
        if obj.thumb != nil {
            if obj.thumb?.image != nil {
                thumbImg.contentMode = .scaleToFill
                thumbImg.image = obj.thumb?.image
                self.backgroundColor = obj.thumb?.bg
                titleLabel.textColor = obj.thumb?.fg
            }
        }
        titleLabel.text = obj.title
    }
    
}

open class MasterCellModel:NSObject {
    
    var thumb:Thumbnail? = nil
    var title:String? = nil
    
    init(thumb:Thumbnail?, bm:LiteBeatmap) {
        self.thumb = thumb
        var title = ""
        if bm.artist != nil {
            title.append(bm.artist!)
        }
        if bm.title != nil {
            if bm.artist != nil {
                title.append(" - ")
            }
            title.append(bm.title!)
        }
        self.title = title
    }
    
}
