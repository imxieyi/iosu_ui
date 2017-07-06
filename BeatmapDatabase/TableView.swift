//
//  TableView.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/4.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import UIKit

class TableView:UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private var db:DBConnection? = nil
    private var set:BeatmapSet? = nil
    
    private var mastercells:[UITableViewCell] = []
    private var slavecells:[[UITableViewCell]] = []
    private var itemcounts:[Int] = []
    public var selection = -1
    
    public static var current:TableView? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        TableView.current = self
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = .clear
        do {
            db = try DBConnection()
            set = try db?.allBeatmaps()
            loadCells()
        } catch let error {
            print(error)
        }
    }
    
    private func loadCells() {
        for i in 0...(set?.getMasterCount())! - 1 {
            var cell:MasterCell? = self.dequeueReusableCell(withIdentifier: "MasterCell") as? MasterCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MasterCell", owner: self, options: nil)
                cell = nib?.last as? MasterCell
            }
            let bm = set?.getMasterMeta(at: i)
            let thumb = db?.getThumbnail(bm: bm!)
            let model = MasterCellModel(thumb: thumb, bm: bm!)
            cell?.updateData(obj: model)
            cell?.id = i
            mastercells.append(cell!)
            let slaves = (set?.getSlaves(at: i))!
            var slavecells:[UITableViewCell] = []
            for item in slaves {
                var cell:SlaveCell? = self.dequeueReusableCell(withIdentifier: "SlaveCell") as? SlaveCell
                if cell == nil {
                    let nib = Bundle.main.loadNibNamed("SlaveCell", owner: self, options: nil)
                    cell = nib?.last as? SlaveCell
                }
                let model = SlaveCellModel(thumb: thumb, diff: item.stars, title: item.version!)
                cell?.updateData(obj: model)
                slavecells.append(cell!)
            }
            self.slavecells.append(slavecells)
            itemcounts.append(0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return mastercells[section].contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    public func updateImage(index:Int) {
        let sview = superview as! BeatmapList
        let bm = set?.getMasterMeta(at: index)
        if bm?.bgimg != nil {
            if bm?.bgimg != "" {
                var path = LiteBeatmap.docURL
                path.appendPathComponent((bm?.dir)!)
                path.appendPathComponent((bm?.bgimg)!)
                do {
                    let data = try Data(contentsOf: path)
                    let img = UIImage(data: data)
                    sview.updateimg(image: img)
                } catch {
                    sview.updateimg(image: nil)
                }
            } else {
                sview.updateimg(image: nil)
            }
        } else {
            sview.updateimg(image: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemcounts[section]
    }
    
    public func updateSelection(index: Int) {
        if index != selection {
            if selection != -1 {
                var indexpath:[IndexPath] = []
                for i in 0...slavecells[selection].count - 1 {
                    let ip = IndexPath(row: i, section: selection)
                    indexpath.append(ip)
                }
                itemcounts[selection] = 0
                deleteRows(at: indexpath, with: .fade)
            }
            selection = index
            var indexpath:[IndexPath] = []
            for i in 0...slavecells[index].count - 1 {
                let ip = IndexPath(row: i, section: index)
                indexpath.append(ip)
            }
            itemcounts[index] = indexpath.count
            insertRows(at: indexpath, with: .fade)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mastercells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return slavecells[indexPath.section][indexPath.item]
    }
    
}