//
//  Thumbnail.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

open class Thumbnail {
    
    open var image:UIImage?
    open var bg:UIColor?
    open var fg:UIColor?
    
    init() {
    }
    
    private static let size = CGSize(width: 50, height: 50)
    
    init(image:UIImage?) {
        if image != nil {
            self.image = image
            let colors = image?.getColors(scaleDownSize: Thumbnail.size)
            self.bg = colors?.backgroundColor
            self.fg = colors?.detailColor
        }
    }
    
}
