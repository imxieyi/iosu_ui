//
//  ContainerViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/9.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class ContainerViewController:UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    
    public static var current:ContainerViewController? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        ContainerViewController.current = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ContainerViewController.current = self
    }
    
    public func updateimg(image:UIImage?) {
        if image != nil {
            //Reference: http://www.hangge.com/blog/cache/detail_1424.html
            let filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(10, forKey: kCIInputRadiusKey)
            filter?.setValue(CIImage(image: image!), forKey: kCIInputImageKey)
            let outciimage = filter?.outputImage!
            let rect = CGRect(origin: .zero, size: (image?.size)!)
            let cgimage = CIContext().createCGImage(outciimage!, from: rect)
            UIView.transition(with: imgView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.imgView.image = UIImage(cgImage: cgimage!)
            }, completion: nil)
        } else {
            UIView.transition(with: imgView, duration: 0.3, options: .curveEaseOut, animations: {
                self.imgView.alpha = 0
            }, completion: { b in
                self.imgView.image = nil
                self.imgView.alpha = 1
            })
        }
    }
    
}
