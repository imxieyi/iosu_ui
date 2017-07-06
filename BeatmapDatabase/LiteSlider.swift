//
//  Slider.swift
//  iosu
//
//  Created by xieyi on 2017/5/16.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class LiteSlider:LiteHitObject{
    
    var cx:[Int] = []
    var cy:[Int] = []
    var repe:Int = 0
    var length:Int = 0
    var singleduration:Int = 0
    var stype:SliderType
    let path = UIBezierPath()
    var rpath = UIBezierPath()
    
    init(x:Int,y:Int,slidertype:SliderType,curveX:[Int],curveY:[Int],time:Int,repe:Int,length:Int,tp:LiteTimingPoint,sm:Double) {
        self.cx=curveX
        self.cy=curveY
        self.repe=repe
        self.length=length
        self.stype=slidertype
        //Calculate time
        let pxPerBeat = 100 * sm
        let beatsNumber = Double(length) / pxPerBeat
        singleduration = Int(ceil(beatsNumber * tp.timeperbeat))
        super.init(type: .slider, x: x, y: y, time: time)
    }
    
    public func position(atTime at:Int) -> Vector2 {
        var relativetime = at - time
        let count = relativetime / singleduration
        relativetime %= singleduration
        let percent = CGFloat(relativetime) / CGFloat(singleduration)
        var point:CGPoint
        if count % 2 == 0 {
            point = path.point(atPercentOfLength: percent)
        } else {
            point = rpath.point(atPercentOfLength: percent)
        }
        return Vector2(Scalar(point.x), Scalar(point.y))
    }
    
    //To avoid bugs in drawing advanced curves, assume all sliders are linear
    func genpath() {
        var allx:[CGFloat]=[CGFloat(x)]
        var ally:[CGFloat]=[CGFloat(y)]
        for i in 0...cx.count-1 {
            allx.append(CGFloat(cx[i]))
            ally.append(CGFloat(cy[i]))
        }
        path.move(to: CGPoint(x: allx.first!, y: ally.first!))
        for i in 1...allx.count-1 {
            path.addLine(to: CGPoint(x: allx[i], y: ally[i]))
        }
        rpath = path.reversing()
    }
    
}
