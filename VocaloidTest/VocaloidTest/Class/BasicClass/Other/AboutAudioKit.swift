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
    /// 自我Midi
    private var ownMidi: AKMIDI = AKMIDI()
    
    /// Sequencer
    private var finalSequencer: AKSequencer?
    
    /// 主混合器
    private var mainMixer: AKMixer = AKMixer.init()
    
    /// 速度
    private var musicBPM: Double = 80 {
        didSet {
            self.finalSequencer!.setTempo(self.musicBPM)
            let samplerReleaseDuration = 0.3 * 80 / self.musicBPM
            
            for sampler in MusicProperties.SamplersDict.values {
                sampler.releaseDuration = samplerReleaseDuration
            }
        }
    }
    
    /// 当前音Index计数器
    private var currentMidiNoteIndex = 0
    
    /// 记录
    private var midiFileName = ""
    
    
    init(wavFileName: String, midiFileName: String) {
        super.init()
        
        // AudioKit的设置
        AKAudioFile.cleanTempDirectory()
        AKSettings.enableLogging = true
        AKSettings.bufferLength = .medium
        
        // 生成Sampler
        self.loadSampler(wavFileName: wavFileName)
        
        // 设置ownMidi
        self.setOwnMidi()
        
        // 生成Sequencer
        self.midiFileName = midiFileName
        self.loadMidi(midiFileName)
        
        AudioKit.output = self.mainMixer
        
        do {
            try AudioKit.start()
            
        } catch {
            print("AudioKit.start() failed")
            
        }
        
        
    }
}

// MARK: - 方法
extension AboutAudioKit {
    /// 通过配置加载音色并存储
    private func loadSampler(wavFileName: String) -> Void {
        let totalFile = try! AKAudioFile(readFileName: wavFileName)
        let leftArray = totalFile.floatChannelData![0]

        let cutLineArray = self.filterContinuousZeroVolumeRangeArray(leftArray: leftArray, rangeLength: 2 * 44100)

        var currentTime = 0
        
        for index in 0 ..< MusicProperties.Word_PitchArray.count {
            // 当前文件名(带音高)
            let unitFileName = MusicProperties.Word_PitchArray[index]
            
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
            
            let cutLine = cutLineArray[index]



            let startTime = Int64(currentTime)
            let endTime = Int64(currentTime + cutLine.1)

            let unitFile = try! totalFile.extracted(
                fromSample: startTime,
                toSample: endTime,
                name: unitFileName
            )

            currentTime = cutLine.0 + cutLine.1
            
            // 起始时间 & 结束时间
            
            /*
             filterCutoff: <#T##Double#>,
             filterStrength: <#T##Double#>,
             filterResonance: <#T##Double#>,
             attackDuration: <#T##Double#>,
             decayDuration: <#T##Double#>,
             sustainLevel: <#T##Double#>,
             releaseDuration: <#T##Double#>,
             filterEnable: <#T##Bool#>,
             filterAttackDuration: <#T##Double#>,
             filterDecayDuration: <#T##Double#>,
             filterSustainLevel: <#T##Double#>,
             filterReleaseDuration: <#T##Double#>,
             */
            
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
            
            
            
            let sampler = AKSampler.init(
                releaseDuration: 0.3,
                glideRate: 0,
                loopThruRelease: false,
                isMonophonic: true,
                isLegato: true)
            
            sampler.loadAKAudioFile(from: sampleDescriptor, file: unitFile)
            
            sampler.buildKeyMap()
            
            // 存储
            MusicProperties.SamplersDict[unitFileName] = sampler
            
            // 绑定
            self.mainMixer.connect(input: sampler)
            
        }
        
        
    }// funcEnd
    
    private func setOwnMidi() -> Void {
        self.ownMidi.createVirtualPorts()
        self.ownMidi.openInput("Session 1")
        self.ownMidi.openOutput()
        
        self.ownMidi.addListener(self)
        
    }
    
    private func loadMidi(_ midiFileName: String) -> Void {
        self.finalSequencer = nil
        self.finalSequencer = AKSequencer()
        self.finalSequencer!.loadMIDIFile(midiFileName)
        self.finalSequencer!.setGlobalMIDIOutput(self.ownMidi.virtualInput)
        
        // 调整速度
        self.musicBPM = 80
        
        self.finalSequencer!.disableLooping()
        
        
    }
    
    /// 将音量数组中连续为零的区域提取出来
    private func filterContinuousZeroVolumeRangeArray(leftArray: [Float], rangeLength: Int) -> [(Int, Int)] {
        var zeroIndexCountArray: [(Int, Int)] = []
        
        for index in 0 ..< leftArray.count {
            let currentVolume = leftArray[index]
            
            if currentVolume == Float(0) {
                
                if let lastZeroIndexCount = zeroIndexCountArray.last {
                    
                    if lastZeroIndexCount.0 + lastZeroIndexCount.1 == index {
                        zeroIndexCountArray.replaceSubrange(
                            (zeroIndexCountArray.count - 1) ..< (zeroIndexCountArray.count),
                            with: repeatElement((lastZeroIndexCount.0, lastZeroIndexCount.1 + 1 ), count: 1)
                        )
                        
                    }else {
                        zeroIndexCountArray.append((index, 1))
                        
                    }
                    
                    
                    
                }else {
                    zeroIndexCountArray.append((index, 1))
                    
                }
                
            }
            
            
        }
        
        
        var finalCutOffLineArray: [(Int, Int)] = []
        
        for zeroIndexCount in zeroIndexCountArray {
            if zeroIndexCount.1 >= rangeLength {
                finalCutOffLineArray.append(zeroIndexCount)
            }
        }
        
        
        return finalCutOffLineArray
    }// funcEnd
    
}

// MARK: - 接口
extension AboutAudioKit {
    func play() -> Void {
        self.currentMidiNoteIndex = 0
        
        self.finalSequencer!.setTime(0)
        
        self.finalSequencer!.play()
        
    }
    
    
    func stop() -> Void {
        self.finalSequencer!.stop()
        
    }
    
}

// MARK: - MIDI监听
extension AboutAudioKit: AKMIDIListener {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if channel != 0  {
            if self.currentMidiNoteIndex < MusicProperties.LyricWordArray.count {
//                let wordWithPitch = MusicProperties.LyricWordArray[self.currentMidiNoteIndex]
//                
//                // 对应音高字符串
//                let pitchName: String = {
//                    
//                    if let range = wordWithPitch.range(of: "_", options: .backwards, range: nil, locale: nil) {
//                        // 获取音符字符串
//                        let tmpString = wordWithPitch.cutWithPlaces(startPlace: range.upperBound.encodedOffset, endPlace: wordWithPitch.count)
//                        
//                        return tmpString
//                        
//                    }else {
//                        return ""
//                        
//                    }
//                }()
//                
//                // 对应汉字
//                let wordName: String = {
//                    
//                    if let range = wordWithPitch.range(of: "_", options: .backwards, range: nil, locale: nil) {
//                        // 获取音符字符串
//                        let tmpString = wordWithPitch.cutWithPlaces(startPlace: 0, endPlace: range.upperBound.encodedOffset)
//                        
//                        return tmpString
//                        
//                    }else {
//                        return ""
//                        
//                    }
//                }()
//                
//                // 汉字对应SamplerArray
//                
//                // 音高除4对应Sampler
                
                
                
                
                let word = MusicProperties.LyricWordArray[self.currentMidiNoteIndex]
            
                let sampler = MusicProperties.SamplersDict[word]!
                
                sampler.play(noteNumber: noteNumber - 12, velocity: velocity)
                
            }
        }
        
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if channel != 0 {
            if self.currentMidiNoteIndex < MusicProperties.LyricWordArray.count {
                let word = MusicProperties.LyricWordArray[self.currentMidiNoteIndex]
                let sampler = MusicProperties.SamplersDict[word]!
                
                sampler.stop(noteNumber: noteNumber - 12)
                self.currentMidiNoteIndex += 1
                
            }
        }
        
    }
    
    func receivedMIDISetupChange() {
        print("midi setup change, midi.inputNames: \(self.ownMidi.inputNames)")
        let inputNames = self.ownMidi.inputNames
        inputNames.forEach { inputName in
            self.ownMidi.openInput(inputName)
        }
    }
    
}
