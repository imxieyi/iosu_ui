//
//  AiModtpDifficulty.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/6.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

enum DifficultyType {
    case speed
    case aim
    public func num() -> Int {
        if self == .speed {
            return 0
        } else {
            return 1
        }
    }
}

class AiModtpDifficulty {
    
    // We will store the HitObjects as a member variable.
    var tpHitObjects:[TpHitObject] = []
    
    private static let STAR_SCALING_FACTOR:Double = 0.045
    private static let EXTREME_SCALING_FACTOR:Double = 0.5
    private static let PLAYFIELD_WIDTH:Float = 512
    
    private var speedDifficulty:Double = 0
    private var aimDifficulty:Double = 0
    private var speedStars:Double = 0
    private var aimStars:Double = 0
    public var starRating:Double = 0
    
    init(bm:LiteBeatmap) {
        
        // Fill our custom tpHitObject class, that carries additional information
        let circleRadius:Float = (AiModtpDifficulty.PLAYFIELD_WIDTH / 16.0) * (1.0 - 0.7 * Float(bm.cs - 5.0) / 5.0)
        
        for obj in bm.hitobjects {
            tpHitObjects.append(TpHitObject(baseHitObject: obj, circleRadius: circleRadius))
        }
        
        // Sort tpHitObjects by StartTime of the HitObjects - just to make sure.
        tpHitObjects.sort(by: { (a, b) -> Bool in
            return a.baseHitObject.time < b.baseHitObject.time
        })
        
        if calculateStrainValues() == false {
            debugPrint("Could not compute strain values. Aborting difficulty calculation.")
            return
        }
        
        speedDifficulty = calculateDifficulty(type: .speed)
        aimDifficulty = calculateDifficulty(type: .aim)
        
        // The difficulty can be scaled by any desired metric.
        // In osu!tp it gets squared to account for the rapid increase in difficulty as the limit of a human is approached. (Of course it also gets scaled afterwards.)
        // It would not be suitable for a star rating, therefore:
        
        // The following is a proposal to forge a star rating from 0 to 5. It consists of taking the square root of the difficulty, since by simply scaling the easier
        // 5-star maps would end up with one star.
        speedStars = sqrt(speedDifficulty) * AiModtpDifficulty.STAR_SCALING_FACTOR
        aimStars = sqrt(aimDifficulty) * AiModtpDifficulty.STAR_SCALING_FACTOR
        
        // Again, from own observations and from the general opinion of the community a map with high speed and low aim (or vice versa) difficulty is harder, than a map with mediocre difficulty in both. Therefore we can not just add both difficulties together, but will introduce a scaling that favors extremes.
        starRating = speedStars + aimStars + abs(speedStars - aimStars) * AiModtpDifficulty.EXTREME_SCALING_FACTOR
        
    }
    
    // Exceptions would be nicer to handle errors, but for this small project it shall be ignored.
    private func calculateStrainValues() -> Bool {
        // Traverse hitObjects in pairs to calculate the strain value of NextHitObject from the strain value of CurrentHitObject and environment.
        if tpHitObjects.count == 0 {
            return false
        }
        
        //var iterator = tpHitObjects.makeIterator()
        //var current = iterator.next()
        //var next:TpHitObject? = iterator.next()
        var current = tpHitObjects[0]
        var next:TpHitObject
        
        // First hitObject starts at strain 1. 1 is the default for strain values, so we don't need to set it here. See tpHitObject.
        
        //while next != nil {
        //    next?.calculateStrains(previousHitObject: current!)
        //    current = next
        //    next = iterator.next()
        //}
        for i in 1...tpHitObjects.count - 1 {
            next = tpHitObjects[i]
            next.calculateStrains(previousHitObject: current)
            current = next
        }
        
        return true
    }
    
    // In milliseconds. For difficulty calculation we will only look at the highest strain value in each time interval of size STRAIN_STEP.
    // This is to eliminate higher influence of stream over aim by simply having more HitObjects with high strain.
    // The higher this value, the less strains there will be, indirectly giving long beatmaps an advantage.
    private static let STRAIN_STEP:Double = 400
    
    // The weighting of each strain value decays to 0.9 * it's previous value
    private static let DECAY_WEIGHT:Double = 0.9
    
    private func calculateDifficulty(type:DifficultyType) -> Double {
        // Find the highest strain value within each strain step
        var highestStrains:[Double] = []
        var intervalEndTime = AiModtpDifficulty.STRAIN_STEP
        var maximumStrain:Double = 0 // We need to keep track of the maximum strain in the current interval
        
        var prev:TpHitObject? = nil
        
        for hitobject in tpHitObjects {
            // While we are beyond the current interval push the currently available maximum to our strain list
            while Double(hitobject.baseHitObject.time) > intervalEndTime {
                highestStrains.append(maximumStrain)
                
                // The maximum strain of the next interval is not zero by default! We need to take the last hitObject we encountered, take its strain and apply the decay until the beginning of the next interval.
                if prev == nil {
                    maximumStrain = 0
                } else {
                    let decay:Double = pow(TpHitObject.DECAY_BASE[type.num()], (intervalEndTime - Double((prev?.baseHitObject.time)!)) / 1000)
                    maximumStrain = (prev?.strains[type.num()])! * decay
                }
                
                // Go to the next time interval
                intervalEndTime += AiModtpDifficulty.STRAIN_STEP
            }
            
            // Obtain maximum strain
            if hitobject.strains[type.num()] > maximumStrain {
                maximumStrain = hitobject.strains[type.num()]
            }
            
            prev = hitobject
        }
        
        // Build the weighted sum over the highest strains for each interval
        var difficulty:Double = 0
        var weight:Double = 1
        highestStrains.sort(by: { (a, b) -> Bool in
            return a > b
        }) // Sort from highest to lowest strain.
        
        //debugPrint("highest strain: \(highestStrains.first!)")
        
        for strain in highestStrains {
            difficulty += weight * strain
            weight *= AiModtpDifficulty.DECAY_WEIGHT
        }
        
        return difficulty
    }
    
}
