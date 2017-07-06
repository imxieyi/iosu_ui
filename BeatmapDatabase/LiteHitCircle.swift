//
//  HitCircle.swift
//  iosu
//
//  Created by xieyi on 2017/5/16.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

class LiteHitCircle:LiteHitObject{
    
    var ctype:CircleType = .plain
    
    init(x:Int,y:Int,time:Int) {
        super.init(type: .circle, x: x, y: y, time: time)
    }
    
}
