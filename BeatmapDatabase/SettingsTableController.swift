//
//  SettingsTableView.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/13.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableController:UITableViewController {
    
    @IBOutlet var musicLabel: UILabel!
    
    override func viewDidLoad() {
        tableView?.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha).lightenByPercentage(0.1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = .clear
        return cell
    }
    
    @IBAction func musicChanged(_ sender: UISlider) {
        musicLabel.text = String(format: "%.0f%%", sender.value * 100)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerview = view as! UITableViewHeaderFooterView
        headerview.textLabel?.textColor = UIColor("#004263ff")
        headerview.textLabel?.frame = headerview.frame
        headerview.textLabel?.textAlignment = .center
    }
    
}

class MySlider:UISlider {
    
    //Reference: https://stackoverflow.com/questions/23320179/make-uislider-height-larger
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 10
        return newBounds
    }
    
}
