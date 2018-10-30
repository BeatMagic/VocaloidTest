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
    static let wordArray: [String] = ["a_C4", "a_E4"]
    
}

// MARK: - 存储数据
extension MusicProperties {
    /// Sampler字典 主键文字
    static var SamplersDict: [String: AKSampler] = [:]
    
}
