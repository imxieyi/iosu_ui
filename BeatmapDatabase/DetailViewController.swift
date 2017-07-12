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
    @IBOutlet var playBtn: UIButton!
    
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
        backBtn.setImage(backBtn.imageView?.image?.image(withTint: DetailViewController.model!.fg), for: .normal)
        playBtn.setImage(playBtn.imageView?.image?.image(withTint: DetailViewController.model!.fg), for: .normal)
        detailView.backgroundColor = DetailViewController.model?.bg.lightenByPercentage(0.1)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playPressed(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: Bundle.main)
        let gameloadview = story.instantiateViewController(withIdentifier: "gameload")
        ListViewController.current?.navigationController?.pushViewController(gameloadview, animated: true)
        var stack = self.navigationController?.viewControllers
        stack?.remove(at: 1)
        self.navigationController?.setViewControllers(stack!, animated: false)
        ContainerViewController.current?.setblur(false)
    }
    
    @IBAction func edgeSwiped(_ sender: Any) {
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
        self.fg = fg.lightenByPercentage(0.1)
        self.bg = bg
    }
    
}
