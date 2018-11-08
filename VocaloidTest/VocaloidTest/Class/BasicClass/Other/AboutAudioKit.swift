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
    
    private var timePitch: AKTimePitch?
    
    private var midiNoteArray: [AKMIDINoteData] = []

    private var pinyin_CDuration = 0.051
    
    private var wavTimeArray: [Double] = []
    
    private var samplerKeyArray: [String] = []
    
    
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
//        self.loadSampler(wavFileName: wavFileName)
        #warning("测试")
//        self.loadTestSampler(word: "cang", startPitch: "C1", endPitch: "B4", groupOfPitchNum: 5, samplingPoint: 3)
        self.loadSingleSampler()
        
        #warning("测试结束")
        
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
    /// 加载单一Sampler
    private func loadSingleSampler() -> Void {
        
        let pitchString = "C3"
        
        for pinyin in MusicProperties.testPinyinArray {
            // 音乐文件
            let wavFile = try! AKAudioFile(readFileName: pinyin + "_test.wav")
            
            let sampler = AKSampler.init(glideRate: 0, loopThruRelease: false, isMonophonic: true, isLegato: true)
            
            // 配置文件
            var sampleDescriptor = AKSampleDescriptor.init(
                noteNumber: Int32(MusicConverter.getMidiNoteFromString(pitchString) - 12),
                noteFrequency: Float(MusicConverter.getFrequencyFrom(pitchName: pitchString)),
                minimumNoteNumber: 0,
                maximumNoteNumber: 127,
                minimumVelocity: 0,
                maximumVelocity: 127,
                isLooping: true,
                loopStartPoint: 0,
                loopEndPoint: 1,
                startPoint: 0,
                endPoint: 0
            )
            
            
            switch pinyin {
            case "c":
                sampleDescriptor.isLooping = false
                self.pinyin_CDuration = wavFile.duration
                
            default:
                print(".")
            }
            
            
            self.wavTimeArray.append(wavFile.duration)
            
            sampler.loadAKAudioFile(from: sampleDescriptor, file: wavFile)
            
            sampler.buildKeyMap()
            
            // 绑定
            self.mainMixer.connect(input: sampler)
            
            MusicProperties.SamplersDict[pinyin] = sampler
        }

    }// funcEnd
    
    private func setOwnMidi() -> Void {
        self.ownMidi.createVirtualPorts()
        self.ownMidi.openInput("Session 1")
        self.ownMidi.openOutput()
        
        self.ownMidi.addListener(self)
        
    }
    
    private func loadMidi(_ midiFileName: String) -> Void {
        
        // 原始Sequencer
        let preliminarySequencer = AKSequencer()
        preliminarySequencer.loadMIDIFile(midiFileName)
        preliminarySequencer.setTempo(80)
        self.midiNoteArray = preliminarySequencer.tracks[1].getMIDINoteData()
        
        // 拼音Sequencer
        self.finalSequencer = nil
        self.finalSequencer = AKSequencer()
        
        self.finalSequencer!.disableLooping()
        
        #warning("生成拼音Track")
        let akPinyinTrack = self.finalSequencer!.newTrack()

        self.createMidiNote(musicTrack: akPinyinTrack!, bpm: 60)
        
        self.finalSequencer!.setGlobalMIDIOutput(self.ownMidi.virtualInput)
        self.finalSequencer!.setTempo(60)
        
        
    }
    
    
    private func createMidiNote(musicTrack: AKMusicTrack, bpm: Double) -> Void {
        let speedModulus = 60 / bpm
        
        var currentTime = 0.0
        
        for midiNote in self.midiNoteArray {
            
            let c_Duration = self.pinyin_CDuration
            
            let playDuration = (midiNote.duration.seconds * speedModulus - c_Duration) / 5
            
            musicTrack.add(noteNumber: midiNote.noteNumber,
                           velocity: midiNote.velocity,
                           
                           position: AKDuration.init(
                            seconds: currentTime,
                            sampleRate: midiNote.position.sampleRate,
                            tempo: bpm),
                           
                           duration: AKDuration.init(
                            seconds: c_Duration,
                            sampleRate: midiNote.duration.sampleRate,
                            tempo: bpm),
                           
                           channel: midiNote.channel)
            
            
            currentTime += c_Duration
            
            musicTrack.add(noteNumber: midiNote.noteNumber,
                           velocity: midiNote.velocity,
                           
                           position: AKDuration.init(
                            seconds: currentTime,
                            sampleRate: midiNote.position.sampleRate,
                            tempo: bpm),
                           
                           duration: AKDuration.init(
                            seconds: playDuration * 3,
                            sampleRate: midiNote.duration.sampleRate,
                            tempo: bpm),
                           
                           channel: midiNote.channel)
            
            
            currentTime += playDuration * 3
            
            musicTrack.add(noteNumber: midiNote.noteNumber,
                           velocity: midiNote.velocity,
                           
                           position: AKDuration.init(
                            seconds: currentTime,
                            sampleRate: midiNote.position.sampleRate,
                            tempo: bpm),
                           
                           duration: AKDuration.init(
                            seconds: playDuration * 2,
                            sampleRate: midiNote.duration.sampleRate,
                            tempo: bpm),
                           
                           channel: midiNote.channel)
            
            
            currentTime += playDuration * 2

        }
        
        
        
    }// funcEnd
    

    
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
    
    
    /// 获取所需的Sampler
    private func getCorrespondSampler() -> AKSampler {
        let word = MusicProperties.testWordArray[self.currentMidiNoteIndex]
        
        let underlineRange = word.range(of: "_", options: .backwards, range: nil, locale: nil)!
        
        let samplerKey = word.cutWithPlaces(startPlace: 0, endPlace: underlineRange.upperBound.encodedOffset - 1)
        
        return MusicProperties.SamplersDict[samplerKey]!
        

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
            if self.currentMidiNoteIndex < MusicProperties.LyricWordArray.count * MusicProperties.testPinyinArray.count {
                
                let playNoteNumber = noteNumber - 12
                
                let piyin = MusicProperties.testPinyinArray[self.currentMidiNoteIndex % MusicProperties.testPinyinArray.count]
                print("播放\(piyin)")
                

                
                let sampler = MusicProperties.SamplersDict[piyin]!
                sampler.play(noteNumber: playNoteNumber, velocity: velocity)
                
                self.samplerKeyArray.append(piyin)
                
                self.currentMidiNoteIndex += 1

            }
        }
        
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        if channel != 0 {
            
            if self.currentMidiNoteIndex <= MusicProperties.LyricWordArray.count * MusicProperties.testPinyinArray.count {
                
                let playNoteNumber = noteNumber - 12
                
                let pinyin = self.samplerKeyArray.first!
                print("停止\(pinyin)")
                
                let sampler = MusicProperties.SamplersDict[pinyin]!
                sampler.stop(noteNumber: playNoteNumber)
                
                
                self.samplerKeyArray.remove(at: 0)
                
                
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

// MARK: - 暂时不用
extension AboutAudioKit {
    private func loadTestSampler(word: String,
                                 startPitch: String,
                                 endPitch: String,
                                 groupOfPitchNum: Int,
                                 samplingPoint: Int) -> Void {
        
        let finalSampler = AKSampler.init(
            //            filterCutoff: <#T##Double#>,
            //            filterStrength: <#T##Double#>,
            //            filterResonance: <#T##Double#>,
            attackDuration: 0.1,
            decayDuration: 1.2,
            sustainLevel: 2.4,
            releaseDuration: 0.3,
            //            filterEnable: <#T##Bool#>,
            //            filterAttackDuration: <#T##Double#>,
            //            filterDecayDuration: <#T##Double#>,
            //            filterSustainLevel: <#T##Double#>,
            //            filterReleaseDuration: <#T##Double#>,
            glideRate: 0,
            loopThruRelease: false,
            isMonophonic: true,
            isLegato: true
        )
        
        
        //        let finalSampler = AKSampler.init(
        //            releaseDuration: 0.3,
        //            glideRate: 0,
        //            loopThruRelease: false,
        //            isMonophonic: true,
        //            isLegato: true
        //        )
        
        let startPitchNum = Int(MusicConverter.getMidiNoteFromString(startPitch))
        let endPitchNum = Int(MusicConverter.getMidiNoteFromString(endPitch))
        
        var groupTotalCount = 0
        if (endPitchNum - startPitchNum) % groupOfPitchNum == 0 {
            groupTotalCount = (endPitchNum - startPitchNum) / groupOfPitchNum
            
        }else {
            groupTotalCount = (endPitchNum - startPitchNum) / groupOfPitchNum + 1
            
        }
        
        
        var currentMinNumber = startPitchNum
        
        for index in 0 ..< groupTotalCount {
            let samplingPitchNum = groupOfPitchNum * index + samplingPoint - 1 + startPitchNum
            
            let samplingPitchString = MusicConverter.getMidiNoteStringFromNum(UInt8(samplingPitchNum))
            
            let samplingPitchFre = MusicConverter.getFrequencyFrom(pitchName: samplingPitchString)
            
            let currentMaxNumber: Int = {
                if (currentMinNumber + groupOfPitchNum) > endPitchNum {
                    return endPitchNum
                    
                }else {
                    return currentMinNumber + groupOfPitchNum
                    
                }
                
                
            }()
            
            // 音乐文件
            let firstFile = try! AKAudioFile(readFileName: word + "_" + samplingPitchString + ".wav")
            
            let leftArray = firstFile.floatChannelData![0]
            
            let cutLineArray = self.filterContinuousZeroVolumeRangeArray(leftArray: leftArray, rangeLength: 2 * 44100)
            
            let startTime = cutLineArray.first!.0 + cutLineArray.first!.1
            let endTime = cutLineArray.last!.0
            
            
            let wavFile = try! firstFile.extracted(
                fromSample: Int64(startTime),
                toSample: Int64(endTime),
                name: word + "_" + samplingPitchString
            )
            
            
            
            // 配置文件
            let sampleDescriptor = AKSampleDescriptor.init(
                noteNumber: Int32(samplingPitchNum - 12),
                noteFrequency: Float(samplingPitchFre),
                minimumNoteNumber: Int32(currentMinNumber - 12),
                maximumNoteNumber: Int32(currentMaxNumber - 12),
                minimumVelocity: 0,
                maximumVelocity: 127,
                isLooping: false,
                loopStartPoint: 0.5,
                loopEndPoint: 0.625,
                startPoint: 0,
                endPoint: 0
            )
            
            // 存入Sampler
            finalSampler.loadAKAudioFile(from: sampleDescriptor, file: wavFile)
            
            
            currentMinNumber += groupOfPitchNum
            
        }
        
        finalSampler.buildKeyMap()
        
        self.timePitch = AKTimePitch.init(finalSampler, rate: 8)
        
        // 绑定
        self.mainMixer.connect(input: self.timePitch)
        
        MusicProperties.SamplersDict[word] = finalSampler
        
    }
    
    
    
    
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
            
            self.timePitch = AKTimePitch.init(sampler, rate: 8)
            
            
        }
        
        
    }// funcEnd
    
}
