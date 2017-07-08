//
//  SlaveCell.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/6.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit
import BCColor

class SlaveCell:UITableViewCell {
    
    @IBOutlet var stars: UIImageView!
    @IBOutlet var label: UILabel!
    
    static let defaultFGColor = (UIColor.colorWithHex("#9defff", alpha: CGFloat(BeatmapList.globalAlpha))?.lightenByPercentage(0.1))!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = MasterCell.bgcolor.lightenByPercentage(0.1)
    }
    
    func updateData(obj:SlaveCellModel) {
        label.text = obj.title
        if obj.thumb != nil {
            if obj.thumb?.image != nil {
                contentView.backgroundColor = obj.thumb?.bg?.lightenByPercentage(0.1)
                label.textColor = obj.thumb?.fg?.darkenByPercentage(0.1)
                stars.image = stars.image?.image(withTint: gencolor(ori: (obj.thumb?.fg)!))
            } else {
                label.textColor = SlaveCell.defaultFGColor
                stars.image = stars.image?.image(withTint: SlaveCell.defaultFGColor)
            }
        } else {
            label.textColor = SlaveCell.defaultFGColor
            stars.image = stars.image?.image(withTint: SlaveCell.defaultFGColor)
        }
        let oldimg = (stars?.image?.cgImage)!
        var newstars:UIImage? = nil
        if obj.difficulty != 0 {
            newstars = stars?.image?.crop(rect: CGRect(origin: .zero, size: CGSize(width: CGFloat(oldimg.width) / 5 * CGFloat(obj.difficulty), height: CGFloat(oldimg.height))))
            let oldbounds = (stars?.bounds)!
            let oldframe = (stars?.frame)!
            stars?.bounds = CGRect(origin: oldbounds.origin, size: CGSize(width: oldbounds.width / 5 * CGFloat(obj.difficulty), height: oldbounds.height))
            stars.frame.origin = oldframe.origin
        }
        stars.image = newstars
    }
    
    func gencolor(ori:UIColor) -> UIColor {
        if ori.isDark {
            return ori.lightenByPercentage(0.1)
        } else {
            return ori.darkenByPercentage(0.1)
        }
    }
    
}

open class SlaveCellModel:NSObject {
    
    var thumb:Thumbnail? = nil
    var difficulty:Double = 0
    var title:String? = nil
    
    init(thumb:Thumbnail?, diff:Double, title:String) {
        self.difficulty = diff
        self.title = title
        self.thumb = thumb
    }
    
}
