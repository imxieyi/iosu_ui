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
    
    private var cells:[UITableViewCell] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
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
            let identifier = "MasterCell"
            var cell:MasterCell? = self.dequeueReusableCell(withIdentifier: identifier) as? MasterCell
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("MasterCell", owner: self, options: nil)
                cell = nib?.last as? MasterCell
            }
            let bm = set?.getMasterMeta(at: i)
            let thumb = db?.getThumbnail(bm: bm!)
            let model = MasterCellModel(thumb: thumb, bm: bm!)
            cell?.updateData(obj: model)
            cells.append(cell!)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint(indexPath.row)
        let sview = superview as! BeatmapList
        let bm = set?.getMasterMeta(at: indexPath.row)
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
        return (set?.getMasterCount())!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
}
