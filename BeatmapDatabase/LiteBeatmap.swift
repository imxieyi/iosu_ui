//
//  BeatmapDecoder.swift
//  iosu
//
//  Created by xieyi on 2017/3/30.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum ScannerError:Error{
    case fileNotFound
    case emptyFile
}

enum BeatmapError:Error{
    case fileNotFound
    case illegalFormat
    case noAudioFile
    case noTimingPoints
    case audioFileNotExist
    case noColor
    case noHitObject
    case notOsuMode
    case noBgimg
}

open class LiteTimingPoint {
    
    var offset:Int
    var timeperbeat:Double //In milliseconds
    var inherited:Bool
    
    init(offset:Int,timeperbeat:Double,inherited:Bool) {
        self.offset=offset
        self.timeperbeat=timeperbeat
        self.inherited=inherited
    }
    
}

open class LiteBeatmap{
    
    open var id:Int64 = -1
    open var dir:String = ""
    open var osufile:String = ""
    open var filesize:Int64 = 0
    open var audio:String = ""
    open var audioprv:Int64 = 0
    open var bgimg:String? = nil
    open var artist:String? = nil
    open var title:String? = nil
    open var creator:String? = nil
    open var version:String? = nil
    open var hp:Double = 0
    open var cs:Double = 0
    open var od:Double = 0
    open var ar:Double = 0
    private var sm:Double = 0
    open var stars:Double = 0
    open var minbpm:Double = 100000
    open var maxbpm:Double = -100000
    open var length:Double = 0
    open var video:Int64 = 0
    open var circle:Int64 = 0
    open var slider:Int64 = 0
    open var spinner:Int64 = 0
    open var hassb:Bool = false
    open var osbfile:String? = nil
    open var objects:Int64 = 0
    open var timingpoints:[LiteTimingPoint] = []
    
    static let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    static var lastosb = ""
    static var osbobj:Int64 = 0
    static var lastaudio = ""
    static var lastlen:Double = 0
    open var hitobjects:[LiteHitObject] = []
    
    static let manager = FileManager.default
    
    init() {
    }
    
    init(_ dir:String, osufile:String, osbfile:String) throws {
        self.dir = dir
        self.osufile = osufile
        let osupath = LiteBeatmap.docURL.appendingPathComponent(dir).appendingPathComponent(osufile)
        var lines = try readfile(path: osupath.path)
        try scanbeatmap(lines: lines)
        let aimod = AiModtpDifficulty(bm: self)
        stars = aimod.starRating
        debugPrint("\(osufile) \(stars)")
        calcbpm()
        let audiopath = (dir as NSString).appending(audio)
        if LiteBeatmap.lastaudio != audiopath {
            try audiolen()
            LiteBeatmap.lastaudio = audiopath
            LiteBeatmap.lastlen = length
        } else {
            length = LiteBeatmap.lastlen
        }
        let osuobj = self.objects
        if osbfile != "" {
            self.osbfile = osbfile
            if osbfile == LiteBeatmap.lastosb {
                objects += LiteBeatmap.osbobj
            } else {
                let osbpath = LiteBeatmap.docURL.appendingPathComponent(dir).appendingPathComponent(osbfile)
                do {
                    lines = try readfile(path: osbpath.path)
                    scanstoryboard(lines: lines)
                } catch {
                    self.osbfile = ""
                }
            }
            LiteBeatmap.lastosb = osbfile
            LiteBeatmap.osbobj = objects - osuobj
        }
        if objects > 0 {
            hassb = true
        }
    }
    
    func readfile(path: String) throws -> ArraySlice<String> {
        let readFile = FileHandle(forReadingAtPath: path)
        if readFile===nil{
            throw ScannerError.fileNotFound
        }
        let bmData=readFile?.readDataToEndOfFile()
        let bmString=String(data: bmData!, encoding: .utf8)
        let rawlines=bmString?.components(separatedBy: CharacterSet.newlines)
        if rawlines?.count==0{
            throw BeatmapError.illegalFormat
        }
        var lines=ArraySlice<String>()
        for line in rawlines! {
            if line != "" {
                if !line.hasPrefix("//"){
                    lines.append(line)
                }
            }
        }
        if lines.count == 0 {
            throw ScannerError.emptyFile
        }
        return lines
    }
    
    func scanbeatmap(lines:ArraySlice<String>) throws {
        var index:Int
        index = -1
        for line in lines{
            index += 1
            switch line {
            case "[General]":
                try parseGeneral(lines.suffix(from: index+1))
                break
            case "[Metadata]":
                parseMetadata(lines.suffix(from: index+1))
                break
            case "[Difficulty]":
                parseDifficulty(lines.suffix(from: index+1))
                break
            case "[Events]":
                parseEvents(lines.suffix(from: index+1))
                break
            case "[TimingPoints]":
                try parseTimingPoints(lines.suffix(from: index+1))
                break
            case "[HitObjects]":
                try parseHitObjects(lines.suffix(from: index+1))
                return
            default:
                continue
            }
        }
    }
    
    func scanstoryboard(lines:ArraySlice<String>) {
        var index:Int
        index = -1
        for line in lines{
            index += 1
            switch line {
            case "[Events]":
                parseEvents(lines.suffix(from: index+1))
                return
            default:
                continue
            }
        }
    }
    
    func parseGeneral(_ lines:ArraySlice<String>) throws -> Void {
        for line in lines{
            if line.hasPrefix("["){
                if(audio==""){
                    throw BeatmapError.noAudioFile
                }
                return
            }
            let splitted=line.components(separatedBy: ":")
            if splitted.count<=1{
                continue
            }
            var value=splitted[1] as NSString
            switch splitted[0] {
            case "AudioFilename":
                while value.substring(to: 1)==" "{
                    value=value.substring(from: 1) as NSString
                }
                audio=value as String
                break
            case "PreviewTime":
                audioprv = Int64(value.intValue)
                break
            case "Mode":
                if value.integerValue != 0 {
                    throw BeatmapError.notOsuMode
                }
            default:break
            }
        }
    }
    
    func parseMetadata(_ lines:ArraySlice<String>) -> Void {
        for line in lines{
            if line.hasPrefix("["){
                break
            }
            let splitted=line.components(separatedBy: ":")
            if splitted.count < 2 {
                continue
            }
            var value = splitted[1]
            if splitted.count > 2 {
                for i in 2...splitted.count - 1 {
                    value.append(":" + splitted[i])
                }
            }
            switch splitted[0] {
            case "Artist":
                artist = value
                break
            case "Title":
                title = value
                break
            case "Creator":
                creator = value
                break
            case "Version":
                version = value
                break
            default:
                break
            }
        }
    }
    
    func parseDifficulty(_ lines:ArraySlice<String>) -> Void {
        var hp:Double = -1
        var cs:Double = -1
        var od:Double = 5
        var ar:Double = -1
        for line in lines{
            if line.hasPrefix("["){
                break
            }
            let splitted=line.components(separatedBy: ":")
            if splitted.count != 2 {
                continue
            }
            let value=(splitted[1] as NSString).doubleValue
            switch splitted[0] {
            case "HPDrainRate":
                hp=value
                break
            case "CircleSize":
                cs=value
                break
            case "OverallDifficulty":
                od=value
                break
            case "ApproachRate":
                ar=value
                break
            case "SliderMultiplier":
                sm=value
                break
            default:
                break
            }
        }
        if(hp == -1){
            hp=od
        }
        if(cs == -1){
            cs=od
        }
        if(ar == -1){
            ar=od
        }
        self.hp = hp
        self.cs = cs
        self.od = od
        self.ar = ar
    }
    
    func parseEvents(_ lines:ArraySlice<String>) -> Void {
        for line in lines {
            if line.hasPrefix("[") {
                return
            }
            let splitted=line.components(separatedBy: ",")
            if splitted.count > 1 {
                switch splitted[0] {
                case "0":
                    var vstr=splitted[2]
                    vstr=(vstr as NSString).replacingOccurrences(of: "\\", with: "/")
                    while vstr.hasPrefix("\"") {
                        vstr=vstr.substring(from: vstr.index(after: vstr.startIndex))
                    }
                    while vstr.hasSuffix("\"") {
                        vstr=vstr.substring(to: vstr.index(before: vstr.endIndex))
                    }
                    bgimg = vstr
                    break
                case "1":
                    video += 1
                    break
                case "Video":
                    video += 1
                    break
                case "Sprite":
                    objects += 1
                    break
                case "Animation":
                    objects += 1
                default:
                    continue
                }
            }
        }
    }
    
    func parseTimingPoints(_ lines:ArraySlice<String>) throws -> Void {
        var lasttimeperbeat:Double = 0
        for line in lines{
            if line.hasPrefix("["){
                if(timingpoints.count==0){
                    throw BeatmapError.noTimingPoints
                }
                return
            }
            var splitted=line.components(separatedBy: ",")
            if splitted.count<8 {
                if splitted.count==6 {
                    splitted.append("1")
                    splitted.append("0")
                } else if splitted.count==7 {
                    splitted.append("0")
                } else {
                    continue
                }
            }
            if splitted[6]=="1" { //Not inherited
                let offset=(splitted[0] as NSString).integerValue
                let timeperbeat=(splitted[1] as NSString).doubleValue
                timingpoints.append(LiteTimingPoint(offset: offset, timeperbeat: timeperbeat, inherited: false))
                lasttimeperbeat=timeperbeat
            }else{ //Inherited
                let offset=(splitted[0] as NSString).integerValue
                let timeperbeat=(splitted[1] as NSString).doubleValue
                timingpoints.append(LiteTimingPoint(offset: offset, timeperbeat: lasttimeperbeat*abs(timeperbeat/100), inherited: true))
            }
        }
    }
    
    func parseHitObjects(_ lines:ArraySlice<String>) throws -> Void {
        for line in lines{
            if line.hasPrefix("["){
                if(circle + slider + spinner == 0){
                    throw BeatmapError.noHitObject
                }
                return
            }
            let splitted=line.components(separatedBy: ",")
            if splitted.count<5{
                continue
            }
            let typenum = (splitted[3] as NSString).integerValue % 16
            switch LiteHitObject.getObjectType(typenum) {
            case .circle:
                circle += 1
                hitobjects.append(LiteHitCircle(x: (splitted[0] as NSString).integerValue, y: (splitted[1] as NSString).integerValue, time: (splitted[2] as NSString).integerValue))
                break
            case .slider:
                slider += 1
                let dslider=decodeSlider(splitted[5])
                let cslider=LiteSlider(x: (splitted[0] as NSString).integerValue, y: (splitted[1] as NSString).integerValue, slidertype: dslider.type, curveX: dslider.cx, curveY: dslider.cy, time: (splitted[2] as NSString).integerValue, repe: (splitted[6] as NSString).integerValue, length:(splitted[7] as NSString).integerValue, tp:getTimingPoint((splitted[2] as NSString).integerValue), sm:sm)
                cslider.genpath()
                hitobjects.append(cslider)
                break
            case .spinner:
                spinner += 1
                hitobjects.append(LiteHitObject(type: .spinner, x: 256, y: 192, time: (splitted[2] as NSString).integerValue))
                break
            case .none:
                continue
            }
        }
    }
    
    func decodeSlider(_ sliderinfo:String) -> DecodedSlider {
        let splitted=sliderinfo.components(separatedBy: "|")
        if splitted.count<=1{
            return DecodedSlider(cx: [], cy: [], type: .none)
        }
        var type=SliderType.none
        switch splitted[0]{
        case "L":
            type = .linear
            break
        case "P":
            type = .passThrough
            break
        case "B":
            type = .bezier
            break
        case "C":
            type = .catmull
            break
        default:
            return DecodedSlider(cx: [], cy: [], type: .none)
        }
        var cx:[Int] = []
        var cy:[Int] = []
        for i in 1...splitted.count-1 {
            let position=splitted[i].components(separatedBy: ":")
            if position.count != 2 {
                continue
            }
            let x=(position[0] as NSString).integerValue
            let y=(position[1] as NSString).integerValue
            cx.append(x)
            cy.append(y)
        }
        return DecodedSlider(cx: cx, cy: cy, type: type)
    }
    
    class DecodedSlider {
        
        open var cx:[Int]
        open var cy:[Int]
        open var type:SliderType
        
        init(cx:[Int],cy:[Int],type:SliderType) {
            self.cx=cx
            self.cy=cy
            self.type=type
        }
        
    }
    
    func calcbpm() {
        for tp in timingpoints {
            let bpm = 60000/tp.timeperbeat
            if bpm > maxbpm {
                maxbpm = bpm
            }
            if bpm < minbpm {
                minbpm = bpm
            }
        }
    }
    
    static let options:[String:Any] = [AVURLAssetPreferPreciseDurationAndTimingKey:true]
    
    func audiolen() throws {
        let path = LiteBeatmap.docURL.appendingPathComponent(dir).appendingPathComponent(audio)
        if FileManager.default.fileExists(atPath: path.path) {
            let au = AVURLAsset(url: path, options: LiteBeatmap.options)
            let duration = au.duration
            length = CMTimeGetSeconds(duration)
        } else {
            throw BeatmapError.audioFileNotExist
        }
    }
    
    //Reference: http://www.jianshu.com/p/4fdb61354fe0
    private static let size = CGSize(width: 128, height: 128)
    open func genThumbnail(id: Int) throws -> Thumbnail {
        if bgimg == nil {
            throw BeatmapError.noBgimg
        }
        if bgimg == "" {
            throw BeatmapError.noBgimg
        }
        let raw = try Data(contentsOf: LiteBeatmap.docURL.appendingPathComponent(dir).appendingPathComponent(bgimg!))
        let img = UIImage(data: raw)
        var thumb:UIImage
        if ((img?.size.width)!*LiteBeatmap.size.height <= (img?.size.height)!*LiteBeatmap.size.width) {
            let width = img?.size.width
            let height = (img?.size.width)! * LiteBeatmap.size.height / LiteBeatmap.size.width
            thumb = (img?.crop(rect: CGRect(x: 0, y: ((img?.size.height)! - height)/2, width: width!, height: height)).scale(size: LiteBeatmap.size))!
        } else {
            let width = (img?.size.height)! * LiteBeatmap.size.width / LiteBeatmap.size.height
            let height = (img?.size.height)!
            thumb = (img?.crop(rect: CGRect(x: ((img?.size.width)! - width)/2, y: 0, width: width, height: height)).scale(size: LiteBeatmap.size))!
        }
        let data = UIImagePNGRepresentation(thumb)
        var path = DBConnection.liburl
        path.appendPathComponent("Caches")
        path.appendPathComponent("Thumbnails")
        path.appendPathComponent("\(id).png")
        try data?.write(to: path)
        return Thumbnail(image: thumb)
    }
    
    func getTimingPoint(_ offset:Int) -> LiteTimingPoint {
        for i in (0...timingpoints.count-1).reversed() {
            if timingpoints[i].offset <= offset {
                return timingpoints[i]
            }
        }
        return timingpoints[0]
    }
    
}
