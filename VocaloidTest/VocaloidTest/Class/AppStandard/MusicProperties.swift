//
//  MusicProperties.swift
//  VocaloidTest
//
//  Created by X Young. on 2018/10/30.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import AudioKit

class MusicProperties: NSObject {
    // MARK: - 配置
    /// 单位WAV时长
    static let UnitWAVFileDuration: Double = 4.1
    
    /// 加空白后时长
    static let UnitWAVFileWithBlankDuration: Double = 8
    
    /// 1. Attack时长
    static let AttackDuration: Double = 3.0
    
    /// 2. Decay时长
    static let DecayDuration: Double = 3.0
    
    /// 3. Sustain时长
    static let SustainLevel: Double = 3.0
    
    /// 4. Release时长
    static let ReleaseDuration: Double = 3.0
    
    /// 单字拼音_音高数组
    static let Word_PitchArray: [String] = [
        "cang_A#2","mang_A#2","de_G#2","tian_A#2","ya_A#2",
        "shi_A#2","wo_C#3","de_D#3","e_C#3","ai_A#2",
        "mian_C#3","mian_C#3","de_G#2","qing_C#3","shan_D#3",
        "jiao_F3","xia_G#3","hua_G#3", "a_F3","zheng_D#3",
        "cai_F3"
    ]



    /// 歌词单字拼音数组
    static let LyricWordArray: [String] = [
        "cang_A#2","mang_A#2","de_G#2","tian_A#2","ya_A#2",
        "shi_A#2","wo_C#3","de_D#3","e_C#3","ai_A#2",
        "mian_C#3","mian_C#3","de_G#2","qing_C#3","shan_D#3",
        "jiao_F3","xia_G#3","hua_G#3", "a_F3","zheng_D#3",
        "cai_F3"
    ]
    
    
}

// MARK: - 存储数据
extension MusicProperties {
    /// Sampler字典 主键文字
    static var SamplersDict: [String: AKSampler] = [:]
    
}
