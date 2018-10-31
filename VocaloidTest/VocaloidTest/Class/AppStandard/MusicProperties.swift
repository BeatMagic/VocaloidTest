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
    static let UnitWAVFileDuration: Double = 4
    
    /// 1. Attack时长
    static let AttackDuration: Double = 3.0
    
    /// 2. Decay时长
    static let DecayDuration: Double = 3.0
    
    /// 3. Sustain时长
    static let SustainLevel: Double = 3.0
    
    /// 4. Release时长
    static let ReleaseDuration: Double = 3.0
    
    /// 字表
    static let wordArray: [String] = [
        "cang_C3","mang_C3","de_C3","tian_C3","ya_C3","shi_C3","wo_C3","de_C3","e_C3","ai_C3","mian_C3","mian_C3","de_C3","qing_C3","shan_C3","jiao_C3","xia_C3","hua_C3","a_C3","zhen_C3","cai_C3"
    ]
    
}

// MARK: - 存储数据
extension MusicProperties {
    /// Sampler字典 主键文字
    static var SamplersDict: [String: AKSampler] = [:]
    
}
