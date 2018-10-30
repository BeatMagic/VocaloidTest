//
//  MusicConverter.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/12.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

// MARK: - 频率相关
class MusicConverter: NSObject {
    /// 给定一个频率 量化到一个音名
    /*
     static func getMusicalAlphabetFrom(frequency: Double) -> String {
     let noteFrequencies = GlobalMusicProperties.NoteFrequencies
     var tmpFrequency = frequency
     
     
     // 确定到音
     while frequency > noteFrequencies[noteFrequencies.count - 1] {
     tmpFrequency /= 2.0
     }
     
     while frequency < noteFrequencies[0] {
     tmpFrequency *= 2.0
     }
     
     var minDistance: Float = 10_000.0
     var index = 0
     
     for i in 0 ..< noteFrequencies.count {
     let distance = fabsf(noteFrequencies[i] - frequency)
     if distance < minDistance {
     index = i
     minDistance = distance
     }
     }
     
     // 获取八度
     let octave = Int(log2f(Float(frequency / tmpFrequency)))
     
     return "\(GlobalMusicProperties.NoteNamesWithSharps[index])\(octave)"
     
     
     }// funcEnd
     */
    
    /// 通过一个音高字符串("C4")获取该音高的频率的数组index
    static func getFrequencyArrayIndexFrom(pitchName: String) -> Int {
        var pitchScale = 0
        
        for index in 0 ..< GlobalMusicProperties.NoteNamesWithSharps.count {
            let scale = GlobalMusicProperties.NoteNamesWithSharps[index]
            
            if (pitchName.range(of: scale) != nil) {
                pitchScale = index
            }
        }
        
        return pitchScale
    }
    
    /// 通过一个音高字符串("C4")获取该音高的频率
    static func getFrequencyFrom(pitchName: String) -> Double {
        let pitchScale = self.getFrequencyArrayIndexFrom(pitchName: pitchName)
        
        let octaveCountString = ToolClass.cutStringWithPlaces(
            pitchName, startPlace: pitchName.count - 1, endPlace: pitchName.count
        )
        
        let needExponentialCoefficient = pow(2, Double(octaveCountString)!)
        
        return GlobalMusicProperties.NoteFrequencies[pitchScale] * needExponentialCoefficient
        
    }
    
    
    
}

// MARK: - 音符相关
extension MusicConverter {
    /// 给定一个音阶与八度信息 返回音高midi音符数字
    static func getMidiNote(_ scaleName: String, octaveCount: Int, isRising: Bool?) -> UInt8 {
        var tmpScale: UInt8 = 0
        let tmpOctaveCount = UInt8(octaveCount)
        
        
        switch scaleName {
        case "A":
            tmpScale = 9
            
        case "B":
            tmpScale = 11
            
        case "C":
            tmpScale = 0
            
        case "D":
            tmpScale = 2
            
        case "E":
            tmpScale = 4
            
        case "F":
            tmpScale = 5
            
        case "G":
            tmpScale = 7
            
        default:
            return 0
        }
        
        if isRising != true {
            return tmpScale + tmpOctaveCount * 12 + 24
            
        }else {
            return tmpScale + tmpOctaveCount * 12 + 1 + 24
            
        }
        
    }// funcEnd
    
    /// 通过一个音符字符串("C4")获取音高
    static func getMidiNoteFromString(_ noteString: String) -> UInt8 {
        let scale = ToolClass.cutStringWithPlaces(
            noteString, startPlace: 0, endPlace: 1
        )
        
        let octaveCountString = ToolClass.cutStringWithPlaces(
            noteString, startPlace: noteString.count - 1, endPlace: noteString.count
        )
        
        let isRising: Bool = {
            if noteString.range(of: "#") == nil {
                return false
                
            }
            
            return true
            
        }()
        
        return self.getMidiNote(scale, octaveCount: Int(octaveCountString)!, isRising: isRising)
        
    }
    
    
    
}
