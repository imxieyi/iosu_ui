//
//  BeatmapSet.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

open class BeatmapSet {
    
    private var dict:[String:[LiteBeatmap]] = [:]
    private var titles:[String] = []
    
    open func add(bm:LiteBeatmap) {
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
        if titles.contains(title) {
            dict[title]?.append(bm)
        } else {
            titles.append(title)
            dict[title] = [bm]
        }
    }
    
    open func getMasterMeta(at:Int) -> LiteBeatmap {
        return dict[titles[at]]![0]
    }
    
    open func getMasterCount() -> Int {
        return titles.count
    }
    
}
