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
    
    private static var defaultbg:UIImage? = nil
    
    private var nowimg:UIImage? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        ContainerViewController.current = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ContainerViewController.current = self
    }
    
    override func viewDidLoad() {
        ContainerViewController.defaultbg = imgView.image!
    }
    
    public func updateimg(image:UIImage?) {
        nowimg = image
        var oriimg = image
        if oriimg == nil {
            oriimg = ContainerViewController.defaultbg
        }
        //Reference: http://www.hangge.com/blog/cache/detail_1424.html
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(10, forKey: kCIInputRadiusKey)
        filter?.setValue(CIImage(image: oriimg!), forKey: kCIInputImageKey)
        let outciimage = filter?.outputImage!
        let rect = CGRect(origin: .zero, size: (oriimg?.size)!)
        let cgimage = CIContext().createCGImage(outciimage!, from: rect)
        let newimg = UIImage(cgImage: cgimage!)
        UIView.transition(with: imgView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.imgView.image = newimg
        }, completion: nil)
    }
    
    public func setblur(_ isBlur:Bool) {
        if isBlur {
            updateimg(image: nowimg)
        } else {
            var img = nowimg
            if img == nil {
                img = ContainerViewController.defaultbg
            }
            UIView.transition(with: imgView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.imgView.image = img
            }, completion: nil)
        }
    }
    
}
