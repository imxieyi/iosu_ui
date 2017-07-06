//
//  HitObject.swift
//  iosu
//
//  Created by xieyi on 2017/5/16.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

open class LiteHitObject{
    
    var type:HitObjectType
    var x:Int //0~512
    var y:Int //0~384
    var time:Int //Milliseconds from beginning of song
    var position:Vector2
    
    init(type:HitObjectType,x:Int,y:Int,time:Int) {
        self.type=type
        self.x = x
        self.y = x
        self.position = Vector2(Scalar(x), Scalar(y))
        self.time=time
    }
    
    static func getObjectType(_ num:Int) -> HitObjectType {
        if num==1 || num==5 {
            return HitObjectType.circle
        }
        if num==2 || num==6 {
            return HitObjectType.slider
        }
        if num==8 || num==12 {
            return HitObjectType.spinner
        }
        return HitObjectType.none
    }
    
}
