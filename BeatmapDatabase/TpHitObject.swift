//
//  TpHitObject.swift
//  BeatmapDatabase
//
//  Created by xieyi on 2017/7/6.
//  Copyright © 2017年 xieyi. All rights reserved.
//

import Foundation

class TpHitObject {
    
    // Factor by how much speed / aim strain decays per second. Those values are results of tweaking a lot and taking into account general feedback.
    public static let DECAY_BASE:[Double] = [0.3, 0.15] // Opinionated observation: Speed is easier to maintain than accurate jumps.
    
    private static let ALMOST_DIAMETER:Double = 90 // Almost the normed diameter of a circle (104 osu pixel). That is -after- position transforming.
    
    // Pseudo threshold values to distinguish between "singles" and "streams". Of course the border can not be defined clearly, therefore the algorithm has a smooth transition between those values. They also are based on tweaking and general feedback.
    private static let STREAM_SPACING_TRESHOLD:Double = 110
    private static let SINGLE_SPACING_TRESHOLD:Double = 125
    
    // Scaling values for weightings to keep aim and speed difficulty in balance. Found from testing a very large map pool (containing all ranked maps) and keeping the average values the same.
    private static let SPACING_WEIGHT_SCALING:[Double] = [1400, 26.25]
    
    // In milliseconds. The smaller the value, the more accurate sliders are approximated. 0 leads to an infinite loop, so use something bigger.
    private static let LAZY_SLIDER_STEP_LENGTH:Int = 1
    
    public var baseHitObject:LiteHitObject
    public var strains:[Double] = [1, 1]
    private var normalizedStartPosition = Vector2(0, 0)
    private var normalizedEndPosition = Vector2(0, 0)
    private var lazySliderLengthFirst:Double = 0
    private var lazySliderLengthSubsequent:Double = 0
    
    init(baseHitObject:LiteHitObject, circleRadius:Float) {
        self.baseHitObject = baseHitObject
        
        // We will scale everything by this factor, so we can assume a uniform CircleSize among beatmaps.
        let scalingFactor:Float = 52.0 / circleRadius
        normalizedStartPosition = baseHitObject.position * scalingFactor
        
        // Calculate approximation of lazy movement on the slider
        if baseHitObject.type == .slider {
            let obj = baseHitObject as! LiteSlider
            let sliderFollowCircleRadius = circleRadius * 3
            
            let segmentLength = obj.singleduration
            var segmentEndTime = obj.time + segmentLength
            
            // For simplifying this step we use actual osu! coordinates and simply scale the length, that we obtain by the ScalingFactor later
            var cursorPos = Vector2(Scalar(obj.x), Scalar(obj.y))
            
            // Actual computation of the first lazy curve
            for time:Int in stride(from: obj.time + TpHitObject.LAZY_SLIDER_STEP_LENGTH, to: segmentEndTime, by: TpHitObject.LAZY_SLIDER_STEP_LENGTH) {
                var difference = obj.position(atTime: time) - cursorPos
                var distance = difference.length
                
                // Did we move away too far?
                if distance > sliderFollowCircleRadius {
                    // Yep, we need to move the cursor
                    difference = difference.normalized() // Obtain the direction of difference. We do no longer need the actual difference
                    distance -= sliderFollowCircleRadius
                    cursorPos = cursorPos + difference * distance // We move the cursor just as far as needed to stay in the follow circle
                    lazySliderLengthFirst += Double(distance)
                }
            }
            
            lazySliderLengthFirst *= Double(scalingFactor)
            // If we have an odd amount of repetitions the current position will be the end of the slider. Note that this will -always- be triggered if BaseHitObject.SegmentCount <= 1, because BaseHitObject.SegmentCount can not be smaller than 1. Therefore NormalizedEndPosition will always be initialized
            if obj.repe % 2 == 1 {
                normalizedEndPosition = cursorPos * scalingFactor
            }
            
            // If we have more than one segment, then we also need to compute the length ob subsequent lazy curves. They are different from the first one, since the first one starts right at the beginning of the slider.
            if obj.repe > 1 {
                // Use the next segment
                segmentEndTime += segmentLength
                
                for time:Int in stride(from: segmentEndTime - segmentLength + TpHitObject.LAZY_SLIDER_STEP_LENGTH, to: segmentEndTime, by: TpHitObject.LAZY_SLIDER_STEP_LENGTH) {
                    var difference = obj.position(atTime: time) - cursorPos
                    var distance = difference.length
                    
                    // Did we move away too far?
                    if distance > sliderFollowCircleRadius {
                        // Yep, we need to move the cursor
                        difference = difference.normalized() // Obtain the direction of difference. We do no longer need the actual difference
                        distance -= sliderFollowCircleRadius
                        cursorPos = cursorPos + difference * distance // We move the cursor just as far as needed to stay in the follow circle
                        lazySliderLengthSubsequent += Double(distance)
                    }
                }
                
                lazySliderLengthSubsequent *= Double(scalingFactor)
                // If we have an even amount of repetitions the current position will be the end of the slider
                if obj.repe % 2 == 0 {
                    normalizedEndPosition = cursorPos * scalingFactor
                }
            }
        } else {
            normalizedEndPosition = normalizedStartPosition.cpy()
        }
    }
    
    public func calculateStrains(previousHitObject prev:TpHitObject) {
        calculateSpecificStrain(previousHitObject: prev, type: .speed)
        calculateSpecificStrain(previousHitObject: prev, type: .aim)
    }
    
    // Caution: The subjective values are strong with this one
    public func spacingWeight(distance:Double, type:DifficultyType) -> Double {
        switch type {
        case .speed:
            var weight:Double = 0
            
            if distance > TpHitObject.SINGLE_SPACING_TRESHOLD {
                weight = 2.5
            } else if distance > TpHitObject.STREAM_SPACING_TRESHOLD {
                weight = 1.6 + 0.9 * (distance - TpHitObject.STREAM_SPACING_TRESHOLD) / (TpHitObject.SINGLE_SPACING_TRESHOLD - TpHitObject.STREAM_SPACING_TRESHOLD)
            } else if distance > TpHitObject.ALMOST_DIAMETER {
                weight = 1.2 + 0.4 * (distance - TpHitObject.ALMOST_DIAMETER) / (TpHitObject.STREAM_SPACING_TRESHOLD - TpHitObject.ALMOST_DIAMETER)
            } else if distance > TpHitObject.ALMOST_DIAMETER / 2 {
                weight = 0.95 + 0.25 * (distance - TpHitObject.ALMOST_DIAMETER / 2) / (TpHitObject.ALMOST_DIAMETER / 2)
            } else {
                weight = 0.95
            }
            return weight
        case .aim:
            return pow(distance, 0.99)
        }
    }
    
    private func calculateSpecificStrain(previousHitObject prev:TpHitObject, type:DifficultyType) {
        var addition:Double = 0
        let timeElapsed:Double = Double(baseHitObject.time) - Double(prev.baseHitObject.time)
        let decay:Double = pow(TpHitObject.DECAY_BASE[type.num()], timeElapsed / 1000)
        
        if baseHitObject.type == .slider {
            var segmentcount:Double = 1
            if prev.baseHitObject.type == .slider {
                segmentcount = Double((prev.baseHitObject as! LiteSlider).repe)
            }
            switch type {
            case .speed:
                // For speed strain we treat the whole slider as a single spacing entity, since "Speed" is about how hard it is to click buttons fast.
                // The spacing weight exists to differentiate between being able to easily alternate or having to single.
                addition = spacingWeight(distance: prev.lazySliderLengthFirst +
                    prev.lazySliderLengthSubsequent * (segmentcount - 1) +
                    distanceTo(other: prev), type: type) *
                    TpHitObject.SPACING_WEIGHT_SCALING[type.num()]
                break
                
            case .aim:
                // For Aim strain we treat each slider segment and the jump after the end of the slider as separate jumps, since movement-wise there is no difference to multiple jumps.
                addition = (
                spacingWeight(distance: prev.lazySliderLengthFirst, type: type) +
                spacingWeight(distance: prev.lazySliderLengthSubsequent, type: type) * (segmentcount - 1) +
                spacingWeight(distance: distanceTo(other: prev), type: type)
                ) * TpHitObject.SPACING_WEIGHT_SCALING[type.num()]
                break
            }
        } else if baseHitObject.type == .circle {
            addition = spacingWeight(distance: distanceTo(other: prev), type: type) * TpHitObject.SPACING_WEIGHT_SCALING[type.num()]
        }
        
        // Scale addition by the time, that elapsed. Filter out HitObjects that are too close to be played anyway to avoid crazy values by division through close to zero.
        // You will never find maps that require this amongst ranked maps.
        addition /= max(timeElapsed, 50)
        
        strains[type.num()] = prev.strains[type.num()] * decay + addition
        
    }
    
    public func distanceTo(other: TpHitObject) -> Double {
        // Scale the distance by circle size.
        return Double((normalizedStartPosition - other.normalizedEndPosition).length)
    }
    
}
