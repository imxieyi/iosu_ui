//
//  ViewController.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/3.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import UIKit
import SQLite
import Async

class ViewController: UIViewController {
    
    @IBOutlet var loadLabel: UILabel!
    @IBOutlet var loadProgress: UIProgressView!
    @IBOutlet var loadPercent: UILabel!
    @IBOutlet var loadStat: UILabel!
    
    private var count = 0
    
    func work() throws {
        let db = try DBConnection()
        
        let docurl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let scan = BeatmapScanner(docurl)
        let total = scan.count
        var count = 0
        
        try? db.removeNonExistBeatmap()
        
        var thumbpath = DBConnection.liburl
        thumbpath.appendPathComponent("Caches")
        thumbpath.appendPathComponent("Thumbnails")
        if !FileManager.default.fileExists(atPath: thumbpath.path) {
            try? FileManager.default.createDirectory(at: thumbpath, withIntermediateDirectories: false, attributes: nil)
        }
        
        while scan.hasnext {
            autoreleasepool {
                let entry = scan.next
                do {
                    count += 1
                    let progress = Float(count) / Float(total)
                    Async.main {
                        self.loadProgress.progress = progress
                        self.loadPercent.text = String(format: "%.1f%%", progress*100)
                        self.loadStat.text = entry.osufile
                    }
                    let attributes = try LiteBeatmap.manager.attributesOfItem(atPath: LiteBeatmap.docURL.appendingPathComponent(entry.dir).appendingPathComponent(entry.osufile).path)
                    let filesize = (attributes[.size])! as! Int64
                    let oldbm = try! db.queryBeatmap(osufile: entry.osufile)
                    if oldbm != nil {
                        if oldbm?.filesize != filesize {
                            try db.deleteBeatmap(id: (oldbm?.id)!)
                            let bm = try LiteBeatmap(entry.dir, osufile:entry.osufile, osbfile:entry.osbfile)
                            bm.id = (oldbm?.id)!
                            bm.filesize = (oldbm?.filesize)!
                            try db.insertBeatmap(bm: bm)
                            try? db.delThumbnail(bm: oldbm!)
                            try? db.insertThumbnail(bm: bm)
                        } else {
                            if try! db.queryThumb(bm: oldbm!) == -1 {
                                try db.insertThumbnail(bm: oldbm!)
                            }
                        }
                    } else {
                        let bm = try LiteBeatmap(entry.dir, osufile:entry.osufile, osbfile:entry.osbfile)
                        bm.filesize = filesize
                        try db.insertBeatmap(bm: bm)
                        try? db.delThumbnail(bm: bm)
                        try? db.insertThumbnail(bm: bm)
                    }
                } catch let error {
                    debugPrint(entry.osufile)
                    debugPrint(error)
                }
            }
        }
        self.count = try db.countBeatmap()
        Async.main {
            self.loadLabel.text = "Updating thumbnail cache"
        }
        try db.updateThumbCache()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(LiteBeatmap.docURL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Async.background {
            do {
                try self.work()
            } catch let error {
                print(error)
            }
            print("finished")
            Async.main {
                self.loadLabel.text = "Load finished: \(self.count)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

