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
    @IBOutlet var starView: UIView!
    @IBOutlet var detailView: UIView!
    @IBOutlet var backBtn: UIButton!
    
    static var model:DetailViewModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let atitle = NSKeyedArchiver.archivedData(withRootObject: DetailViewController.model?.title as Any)
        let astar = NSKeyedArchiver.archivedData(withRootObject: DetailViewController.model?.star as Any)
        let title = NSKeyedUnarchiver.unarchiveObject(with: atitle) as! UIView
        let star = NSKeyedUnarchiver.unarchiveObject(with: astar) as! UIView
        title.frame.origin = .zero
        star.frame.origin = .zero
        titleView.addSubview(title)
        starView.addSubview(star)
        let fg = DetailViewController.model?.fg.lightenByPercentage(0.1)
        backBtn.setImage(backBtn.imageView?.image?.image(withTint: fg!), for: UIControlState.normal)
        detailView.backgroundColor = DetailViewController.model?.bg.lightenByPercentage(0.1)
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
