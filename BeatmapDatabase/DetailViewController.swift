//
//  DetailViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/9.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController:UIViewController {
    
    @IBOutlet var titleView: UIView!
    @IBOutlet var difficultyView: UIView!
    @IBOutlet var backBtn: UIButton!
    
    static var model:DetailViewModel? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleView = DetailViewController.model?.title
        difficultyView = DetailViewController.model?.star
        let fg = DetailViewController.model?.fg.lightenByPercentage(0.1)
        backBtn.imageView?.image = backBtn.imageView?.image?.image(withTint: fg!)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

class DetailViewModel:NSObject {
    
    let title:UIView
    let star:UIView
    let fg:UIColor
    let bg:UIColor
    
    init(_ title:UIView, _ star:UIView, _ fg:UIColor, _ bg:UIColor) {
        self.title = title
        self.star = star
        self.fg = fg
        self.bg = bg
    }
    
}
