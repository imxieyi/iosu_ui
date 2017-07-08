//
//  BeatmapListController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit
import UIColor_Hex_Swift

class BeatmapList:UIView {
    
    @IBOutlet var headLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    public static let globalAlpha:Float = 0.7
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headLabel.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha)
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
            UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.imageView.image = UIImage(cgImage: cgimage!)
            }, completion: nil)
        } else {
            UIView.transition(with: imageView, duration: 0.3, options: .curveEaseOut, animations: {
                self.imageView.alpha = 0
            }, completion: { b in
                self.imageView.image = nil
                self.imageView.alpha = 1
            })
        }
    }
    
}
