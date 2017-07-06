//
//  DatabaseAccess.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/3.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import SQLite

open class DBConnection {
    
    private var db:Connection?
    private var beatmap:Table?
    private var thumbnails:Table?
    
    //Beatmap part
    private let id = Expression<Int64>("id")
    private let dir = Expression<String>("dir")
    private let osufile = Expression<String>("osufile")
    private let filesize = Expression<Int64>("filesize")
    private let audio = Expression<String>("audio")
    private let audioprv = Expression<Int64>("audioprv")
    private let bgimg = Expression<String?>("bgimg")
    private let artist = Expression<String?>("artist")
    private let title = Expression<String?>("title")
    private let creator = Expression<String?>("creator")
    private let version = Expression<String?>("version")
    private let hp = Expression<Double>("hp")
    private let cs = Expression<Double>("cs")
    private let od = Expression<Double>("od")
    private let ar = Expression<Double>("ar")
    private let stars = Expression<Double>("stars")
    private let minbpm = Expression<Double>("minbpm")
    private let maxbpm = Expression<Double>("maxbpm")
    private let length = Expression<Double>("length")
    private let video = Expression<Int64>("video") //Count of videos
    private let circle = Expression<Int64>("circle")
    private let slider = Expression<Int64>("slider")
    private let spinner = Expression<Int64>("spinner")
    //Storyboard part
    private let hassb = Expression<Bool>("hassb")
    private let osbfile = Expression<String?>("osbfile")
    private let objects = Expression<Int64>("objects")
    
    //Thumbnails
    private let imgfile = Expression<String>("imgfile")
    private let bgr = Expression<Double?>("bgr")
    private let bgg = Expression<Double?>("bgg")
    private let bgb = Expression<Double?>("bgb")
    private let fgr = Expression<Double?>("fgr")
    private let fgg = Expression<Double?>("fgg")
    private let fgb = Expression<Double?>("fgb")
    
    open static let manager = FileManager.default
    open static let liburl = manager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    
    private static var firstrun = true
    
    init() throws {
        debugPrint(DBConnection.liburl)
        db = try Connection(DBConnection.liburl.appendingPathComponent("iosu.db").path)
        beatmap = Table("beatmap")
        thumbnails = Table("thumbnails")
        if DBConnection.firstrun {
            DBConnection.firstrun = false
            //try db?.run((beatmap?.drop(ifExists: true))!)
            //try db?.run((thumbnails?.drop(ifExists: true))!)
            //try FileManager.default.removeItem(at: DBConnection.liburl.appendingPathComponent("Caches").appendingPathComponent("Thumbnails"))
        }
        
        let builder = beatmap?.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(dir)
            t.column(osufile, unique: true)
            t.column(filesize)
            t.column(audio)
            t.column(audioprv)
            t.column(bgimg)
            t.column(artist)
            t.column(title)
            t.column(creator)
            t.column(version)
            t.column(hp)
            t.column(cs)
            t.column(od)
            t.column(ar)
            t.column(stars)
            t.column(minbpm)
            t.column(maxbpm)
            t.column(length)
            t.column(video)
            t.column(circle)
            t.column(slider)
            t.column(spinner)
            t.column(hassb)
            t.column(osbfile)
            t.column(objects)
        }
        try db?.run(builder!)
        
        let builder2 = thumbnails?.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(dir)
            t.column(imgfile)
            t.column(bgr)
            t.column(bgg)
            t.column(bgb)
            t.column(fgr)
            t.column(fgg)
            t.column(fgb)
        }
        try db?.run(builder2!)
    }
    
    open func insertBeatmap(bm: LiteBeatmap) throws {
        if bm.id != -1 {
            let insert = beatmap?.insert(id <- bm.id, dir <- bm.dir, osufile <- bm.osufile, filesize <- bm.filesize, audio <- bm.audio, audioprv <- bm.audioprv, bgimg <- bm.bgimg, artist <- bm.artist, title <- bm.title, creator <- bm.creator, version <- bm.version, hp <- bm.hp, cs <- bm.cs, od <- bm.od, ar <- bm.ar, stars <- bm.stars, minbpm <- bm.minbpm, maxbpm <- bm.maxbpm, length <- bm.length, video <- bm.video, circle <- bm.circle, slider <- bm.slider, spinner <- bm.spinner, hassb <- bm.hassb, osbfile <- bm.osbfile, objects <- bm.objects)
            try db?.run(insert!)
        } else {
            let insert = beatmap?.insert(dir <- bm.dir, osufile <- bm.osufile, filesize <- bm.filesize, audio <- bm.audio, audioprv <- bm.audioprv, bgimg <- bm.bgimg, artist <- bm.artist, title <- bm.title, creator <- bm.creator, version <- bm.version, hp <- bm.hp, cs <- bm.cs, od <- bm.od, ar <- bm.ar, stars <- bm.stars, minbpm <- bm.minbpm, maxbpm <- bm.maxbpm, length <- bm.length, video <- bm.video, circle <- bm.circle, slider <- bm.slider, spinner <- bm.spinner, hassb <- bm.hassb, osbfile <- bm.osbfile, objects <- bm.objects)
            try db?.run(insert!)
            let query = beatmap?.select(id).filter(osufile == bm.osufile)
            for b in try (db?.prepare(query!))! {
                bm.id = b[id]
            }
        }
    }
    
    open func queryBeatmap(osufile: String) throws -> LiteBeatmap? {
        let query = beatmap?.filter(self.osufile == osufile)
        let beatmaps = try db?.prepare(query!)
        for b in beatmaps! {
            let bm = LiteBeatmap()
            bm.id = b[id]
            bm.dir = b[dir]
            bm.osufile = b[self.osufile]
            bm.filesize = b[filesize]
            bm.audio = b[audio]
            bm.audioprv = b[audioprv]
            bm.bgimg = b[bgimg]
            bm.artist = b[artist]
            bm.title = b[title]
            bm.creator = b[creator]
            bm.version = b[version]
            bm.hp = b[hp]
            bm.cs = b[cs]
            bm.od = b[od]
            bm.ar = b[ar]
            bm.stars = b[stars]
            bm.minbpm = b[minbpm]
            bm.maxbpm = b[maxbpm]
            bm.length = b[length]
            bm.video = b[video]
            bm.circle = b[circle]
            bm.slider = b[slider]
            bm.spinner = b[spinner]
            bm.hassb = b[hassb]
            bm.osbfile = b[osbfile]
            bm.objects = b[objects]
            return bm
        }
        return nil
    }
    
    open func allBeatmaps() throws -> BeatmapSet {
        let query = beatmap?.order(dir)
        let set = BeatmapSet()
        for b in try (db?.prepare(query!))! {
            let bm = LiteBeatmap()
            bm.id = b[id]
            bm.dir = b[dir]
            bm.osufile = b[self.osufile]
            bm.filesize = b[filesize]
            bm.audio = b[audio]
            bm.audioprv = b[audioprv]
            bm.bgimg = b[bgimg]
            bm.artist = b[artist]
            bm.title = b[title]
            bm.creator = b[creator]
            bm.version = b[version]
            bm.hp = b[hp]
            bm.cs = b[cs]
            bm.od = b[od]
            bm.ar = b[ar]
            bm.stars = b[stars]
            bm.minbpm = b[minbpm]
            bm.maxbpm = b[maxbpm]
            bm.length = b[length]
            bm.video = b[video]
            bm.circle = b[circle]
            bm.slider = b[slider]
            bm.spinner = b[spinner]
            bm.hassb = b[hassb]
            bm.osbfile = b[osbfile]
            bm.objects = b[objects]
            set.add(bm: bm)
        }
        return set
    }
    
    open func beatmapExists(dir:String, osufile:String) -> Bool {
        var url = LiteBeatmap.docURL
        url.appendPathComponent(dir)
        url.appendPathComponent(osufile)
        return LiteBeatmap.manager.fileExists(atPath: url.path)
    }
    
    open func removeNonExistBeatmap() throws {
        for bm in try (db?.prepare(beatmap!))! {
            if !beatmapExists(dir: bm[dir], osufile: bm[osufile]) {
                try? deleteBeatmap(id: bm[id])
            }
        }
    }
    
    open func deleteBeatmap(id: Int64) throws {
        let query = beatmap?.filter(self.id == id)
        try db?.run((query?.delete())!)
        
    }
    
    open func countBeatmap() throws -> Int {
        var count = 0
        for _ in try (db?.prepare(beatmap!))! {
            count += 1
        }
        return count
    }
    
    open func queryThumb(bm:LiteBeatmap) throws -> Int {
        if bm.bgimg == nil {
            return -1
        }
        if bm.bgimg == "" {
            return -1
        }
        let query = thumbnails?.filter(dir == bm.dir).filter(imgfile == bm.bgimg!)
        for t in try (db?.prepare(query!))! {
            return Int(t[id])
        }
        return -1
    }
    
    open func queryThumb(id: Int) throws -> Thumbnail {
        let thumb = Thumbnail()
        if id < 0 {
            return thumb
        }
        let query = thumbnails?.filter(self.id == Int64(id))
        for t in try (db?.prepare(query!))! {
            thumb.bg = UIColor(colorLiteralRed: Float(t[bgr]!), green: Float(t[bgg]!), blue: Float(t[bgb]!), alpha: BeatmapList.globalAlpha)
            thumb.fg = UIColor(colorLiteralRed: Float(t[fgr]!), green: Float(t[fgg]!), blue: Float(t[fgb]!), alpha: 1)
        }
        return thumb
    }
    
    open func insertThumbnail(bm:LiteBeatmap) throws {
        if bm.bgimg == nil {
            return
        }
        if bm.bgimg == "" {
            return
        }
        var path = LiteBeatmap.docURL
        path.appendPathComponent(bm.dir)
        path.appendPathComponent(bm.bgimg!)
        if !FileManager.default.fileExists(atPath: path.path) {
            return
        }
        let insert = thumbnails?.insert(dir <- bm.dir, imgfile <- bm.bgimg!)
        try db?.run(insert!)
        let id = try queryThumb(bm: bm)
        do {
            let t = try bm.genThumbnail(id: id)
            let update = thumbnails?.filter(self.id == Int64(id))
            var br:CGFloat = 0
            var bg:CGFloat = 0
            var bb:CGFloat = 0
            var ba:CGFloat = 0
            var fr:CGFloat = 0
            var fg:CGFloat = 0
            var fb:CGFloat = 0
            var fa:CGFloat = 0
            t.bg?.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
            t.fg?.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
            try db?.run((update?.update(bgr <- Double(br), bgg <- Double(bg), bgb <- Double(bb), fgr <- Double(fr), fgg <- Double(fg), fgb <- Double(fb)))!)
        } catch {
            try delThumbnail(bm: bm)
        }
    }
    
    open func delThumbnail(bm: LiteBeatmap) throws {
        let id = try queryThumb(bm: bm)
        if id == -1 {
            return
        }
        var path = DBConnection.liburl
        path.appendPathComponent("Caches")
        path.appendPathComponent("Thumbnails")
        path.appendPathComponent("\(id).png")
        do {
            let delete = thumbnails?.filter(self.id == Int64(id)).delete()
            try db?.run(delete!)
            try FileManager.default.removeItem(at: path)
        } catch {
        }
    }
    
    open func getThumbnail(bm: LiteBeatmap) -> Thumbnail {
        do {
            let id = try queryThumb(bm: bm)
            if id == -1 {
                let thumb = Thumbnail()
                return thumb
            }
            var path = DBConnection.liburl
            path.appendPathComponent("Caches")
            path.appendPathComponent("Thumbnails")
            path.appendPathComponent("\(id).png")
            let thumb = try queryThumb(id: id)
            let raw = try Data(contentsOf: path)
            thumb.image = UIImage(data: raw)
            return thumb
        } catch {
            let thumb = Thumbnail()
            return thumb
        }
    }
    
    open func updateThumbCache() throws {
        for t in try (db?.prepare(thumbnails!))! {
            var path = DBConnection.liburl
            path.appendPathComponent("Caches")
            path.appendPathComponent("Thumbnails")
            path.appendPathComponent("\(t[id]).png")
            if !FileManager.default.fileExists(atPath: path.path) {
                let bm = LiteBeatmap()
                bm.dir = t[dir]
                bm.bgimg = t[imgfile]
                _ = try? bm.genThumbnail(id: Int(t[id]))
            }
        }
    }
    
}
