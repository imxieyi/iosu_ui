//
//  BeatmapProcessor.swift
//  iosu
//
//  Created by xieyi on 2017/3/30.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

open class BeatmapEntry {
    open var dir:String = ""
    open var osufile:String = ""
    open var osbfile:String = ""
}

open class BeatmapScanner {
    
    private var beatmapdirs:[String]=[]
    private var beatmaps:[String]=[]
    private var storyboards=[String:String]()
    
    public init(_ at: URL) {
        let manager=FileManager.default
        let contentsOfPath=try? manager.contentsOfDirectory(atPath: at.path)
        for entry in contentsOfPath!{
            let contentsOfBMPath=try? manager.contentsOfDirectory(atPath: at.appendingPathComponent(entry).path)
            if contentsOfBMPath == nil {
                continue
            }
            for subentry in contentsOfBMPath!{
                if subentry.hasSuffix(".osu"){
                    beatmapdirs.append(entry)
                    beatmaps.append(subentry)
                }
                if subentry.hasSuffix(".osb"){
                    storyboards.updateValue(subentry, forKey: entry)
                }
            }
        }
    }
    
    private var index = 0
    
    open var count:Int {
        return beatmaps.count
    }
    
    open var hasnext:Bool {
        return index < beatmaps.count
    }
    
    open var next:BeatmapEntry {
        let entry = BeatmapEntry()
        entry.dir = beatmapdirs[index]
        entry.osufile = beatmaps[index]
        if storyboards[entry.dir] != nil {
            entry.osbfile = storyboards[entry.dir]!
        }
        index += 1
        return entry
    }
    
}
