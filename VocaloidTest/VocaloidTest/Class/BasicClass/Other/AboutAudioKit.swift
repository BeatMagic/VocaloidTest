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
    
    /// Sequencer
    private var finalSequencer: AKSequencer!
    
    /// 主混合器
    private var mainMixer: AKMixer = AKMixer.init()
    
    
    init(wavFileName: String, midiFileName: String) {
        super.init()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.enableLogging = false
        AKSettings.bufferLength = .medium
        AKSettings.playbackWhileMuted = true
        
        self.loadSampler(wavFileName: wavFileName)
        
        self.loadMidi(midiFileName)
        
        AudioKit.output = self.mainMixer
        
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
            
            
            // 绑定
            sampler.connect(to: self.mainMixer)
            
            // 存储
            MusicProperties.SamplersDict[unitFileName] = sampler
        
        }
        
        
    }// funcEnd
    
    private func loadMidi(_ midiFileName: String) {
        self.finalSequencer = AKSequencer()
        self.finalSequencer.loadMIDIFile(midiFileName)
        self.finalSequencer.enableLooping()

        
    }
    
    private func playNote(word: String, note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        MusicProperties.SamplersDict[word]!.play(noteNumber: note, velocity: velocity)
    }
    
}

// MARK: - 接口
extension AboutAudioKit {
    func play() -> Void {
        self.mainMixer.play()
        
        let noteArray = self.finalSequencer.tracks[1].getMIDINoteData()
        
        var currentTime = 0.0
        
        var index = 0
        
        for note in noteArray {
            
            if note.noteNumber != 0 {
                let word = MusicProperties.wordArray[index]
                let sampler = MusicProperties.SamplersDict[word]
                let noteString: String = {
                    
                    if let range = word.range(of: "_", options: .backwards, range: nil, locale: nil) {
                        // 获取音符字符串
                        let tmpString = word.cutWithPlaces(startPlace: range.upperBound.encodedOffset, endPlace: word.count)
                        
                        return tmpString
                        
                    }else {
                        return ""
                        
                    }
                }()
                
                let ownNoteNumber = MusicConverter.getMidiNoteFromString(noteString) - 12
                
                
                DelayTask.createTaskWith(workItem: {
                    sampler!.play(noteNumber: ownNoteNumber, velocity: note.velocity)
                    
                }, finishedCallBack: nil, delayTime: currentTime)
                
                
                DelayTask.createTaskWith(workItem: {
                    sampler!.stop(noteNumber: ownNoteNumber)
                    
                }, finishedCallBack: nil, delayTime: currentTime + note.duration.seconds)
                
                index += 1
            }
            
            
            currentTime += note.duration.seconds
            
        }
    }
    
    
    func stop() -> Void {
        self.mainMixer.stop()
        DelayTask.cancelAllWorkItems()
    }
    
}
