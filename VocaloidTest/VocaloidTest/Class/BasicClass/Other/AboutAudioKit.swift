//
//  AboutAudio.swift
//  VocaloidTest
//
//  Created by X Young. on 2018/10/30.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import AudioKit

class AboutAudioKit: NSObject {
    // MARK: - 属性
    /// midi
    private let midi = AKMIDI()
    
    /// Sequencer
    private var finalSequencer: AKSequencer = AKSequencer.init()
    
    /// 主混合器
    private var mainMixer: AKMixer = AKMixer.init()
    
    
    init(wavFileName: String) {
        super.init()
        
        midi.createVirtualPorts()
        midi.openInput("Session 1")
        midi.openOutput()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.enableLogging = false
        AKSettings.bufferLength = .medium
        AKSettings.playbackWhileMuted = true
        
        do {
            try AKSettings.setSession(category: .playback, with: [.defaultToSpeaker, .allowBluetooth, .mixWithOthers])
        } catch {
            AKLog("Could not set session category.")
        }
        
        
        self.loadSampler(wavFileName: wavFileName)
        
        let sampler = MusicProperties.SamplersDict["a_C4"]
        
        AudioKit.output = sampler
        
        
        try! AudioKit.start()
        
    }
}

// MARK: - 方法
extension AboutAudioKit {
    /// 通过配置加载音色并存储
    private func loadSampler(wavFileName: String) -> Void {
        let totalFile = try! AKAudioFile(readFileName: wavFileName)
        
        for index in 0 ..< MusicProperties.wordArray.count {
            // 当前文件名
            let unitFileName = MusicProperties.wordArray[index]
            
            // 对应音高字符串
            let pitchName: String = {
                
                if let range = unitFileName.range(of: "_", options: .backwards, range: nil, locale: nil) {
                    // 获取音符字符串
                    let tmpString = unitFileName.cutWithPlaces(startPlace: range.upperBound.encodedOffset, endPlace: unitFileName.count)
                    
                    return tmpString
                    
                }else {
                    return ""
                    
                }
            }()
            
            // 对应音高数字
            let pitchCount = Int32(Int(MusicConverter.getMidiNoteFromString(pitchName) - 12))
            // 对应音高频率
            let pitchFre = MusicConverter.getFrequencyFrom(pitchName: pitchName)
            
            
            let unitFile = try! totalFile.extracted(
                fromSample: Int64(index * (MusicProperties.UnitWAVFileDuration + 4) * 44_100),
                toSample: Int64((index * (MusicProperties.UnitWAVFileDuration + 4) + MusicProperties.UnitWAVFileDuration) * 44_100),
                name: unitFileName
            )
            
            /*
             let sampler = AKSampler.init(attackDuration: <#T##Double#>, decayDuration: <#T##Double#>, sustainLevel: <#T##Double#>, releaseDuration: <#T##Double#>, filterEnable: <#T##Bool#>, filterAttackDuration: <#T##Double#>, filterDecayDuration: <#T##Double#>, filterSustainLevel: <#T##Double#>, filterReleaseDuration: <#T##Double#>, glideRate: <#T##Double#>, loopThruRelease: <#T##Bool#>, isMonophonic: <#T##Bool#>, isLegato: <#T##Bool#>)
             
             */
            
            let sampler = AKSampler.init(glideRate: 0, loopThruRelease: false, isMonophonic: true, isLegato: true)
            
            let sampleDescriptor = AKSampleDescriptor.init(
                noteNumber: pitchCount,
                noteFrequency: Float(pitchFre),
                minimumNoteNumber: 0,
                maximumNoteNumber: 127,
                minimumVelocity: 0,
                maximumVelocity: 127,
                isLooping: true,
                loopStartPoint: 0.5,
                loopEndPoint: 0.625,
                startPoint: 0,
                endPoint: 0
            )
            
            sampler.loadAKAudioFile(from: sampleDescriptor, file: unitFile)
            
            sampler.buildKeyMap()
            
            // 存储
            MusicProperties.SamplersDict[unitFileName] = sampler
            
            // 绑定
            let _ = self.finalSequencer.newTrack()
            
            
//            self.finalSequencer.tracks[index].add(noteNumber: <#T##MIDINoteNumber#>, velocity: <#T##MIDIVelocity#>, position: <#T##AKDuration#>, duration: <#T##AKDuration#>)
            
        }
        
        
    }// funcEnd
    
}

extension AboutAudioKit {
    func play() -> Void {
        let sampler = MusicProperties.SamplersDict["a_C4"]
        
        sampler?.play(noteNumber: MusicConverter.getMidiNoteFromString("C4"), velocity: MIDIVelocity.init(128), frequency: MusicConverter.getFrequencyFrom(pitchName: "C4"))
        
    }
    
    
    func stop() -> Void {
        let sampler = MusicProperties.SamplersDict["a_C4"]
        
        sampler?.stop(noteNumber: MusicConverter.getMidiNoteFromString("C4"))
        
    }
    
    
}
