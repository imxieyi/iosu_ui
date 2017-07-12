//
//  ListViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/9.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class ListViewController:UIViewController {
    
    public static var current:ListViewController? = nil
    @IBOutlet var tableview: TableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        ListViewController.current = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        ListViewController.current = self
    }
    
    @IBAction func settingClicked(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: Bundle.main)
        let detailview = story.instantiateViewController(withIdentifier: "settings") 
        ListViewController.current?.navigationController?.pushViewController(detailview, animated: true)
    }
    
}
