//
//  UIImageExt.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    open func scale(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size);
        self.draw(in: CGRect(origin: .zero, size: size))
        let newimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimg!
    }
    
    open func crop(rect:CGRect) -> UIImage {
        let newImage = self.cgImage?.cropping(to: rect)
        return UIImage(cgImage: newImage!)
    }
    
    //Reference: https://onevcat.com/2013/04/using-blending-in-ios/
    open func image(withTint color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let bounds = CGRect(origin: .zero, size: size)
        UIRectFill(bounds)
        draw(in: bounds, blendMode: .destinationIn, alpha: 1)
        let tinted = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tinted!
    }
    
}
