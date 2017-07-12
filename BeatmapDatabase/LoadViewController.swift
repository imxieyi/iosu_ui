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

class LoadViewController: UIViewController {
    
    @IBOutlet var loadLabel: UILabel!
    @IBOutlet var loadProgress: UIProgressView!
    @IBOutlet var progLabel: UILabel!
    
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
                        self.progLabel.text = entry.osufile
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
            self.progLabel.text = "Updating thumbnail cache..."
        }
        try db.updateThumbCache()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint(LiteBeatmap.docURL)
        self.loadLabel.backgroundColor = UIColor(colorLiteralRed: 0.398, green: 0.797, blue: 1, alpha: BeatmapList.globalAlpha)
        self.view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0.192, blue: 0.285, alpha: BeatmapList.globalAlpha)
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
                self.progLabel.text = "Loading beatmap list..."
            }.wait()
            Async.main {
                let story = UIStoryboard(name: "Main", bundle: Bundle.main)
                let listview = story.instantiateViewController(withIdentifier: "listview") as! ListViewController
                ContainerViewController.current?.updateimg(image: nil)
                self.navigationController?.pushViewController(listview, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

