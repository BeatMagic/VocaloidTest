//
//  ViewController.swift
//  VocaloidTest
//
//  Created by X Young. on 2018/10/30.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    var audioKitObj = AboutAudioKit.init(wavFileName: "totalFile.wav", midiFileName: "洛天依长音测试09")

    // MARK: - 记录属性
    /// 当前播放属性
    private var playStatus: StaticProperties.PlayStatus = .Initial
    

    // MARK: - UI元素
    /// 播放按钮
    @IBOutlet var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setData()
        self.setUI()
        
    }

    

}

extension ViewController {
    func setData() -> Void {
        
    }
    
    func setUI() -> Void {
        let startPlayingImg = StaticProperties.loadImageFrom(.startPlaying)
        self.playButton.setImage(startPlayingImg, for: .normal)
        self.playButton.addTarget(self, action: #selector(self.playButtonClickEvent), for: .touchUpInside)
        
    }
    
}

// MARK: - 点击事件
extension ViewController {
    /// 点击播放或者停止音乐
    @objc func playButtonClickEvent() -> Void {
        if self.playStatus == .Initial {
            self.stratPlaying()
            
        }else if self.playStatus == .Playing {
            self.stopPlaying()
            
        }
        
    }
    
    
}

extension ViewController {
    /// 开始播放
    func stratPlaying() -> Void {
        let stopPlayingImg = StaticProperties.loadImageFrom(.stopPlaying)
        self.playButton.setImage(stopPlayingImg, for: .normal)
        self.playStatus = .Playing
        
        audioKitObj.play()
    }
    
    /// 停止播放
    func stopPlaying() -> Void {
        let startPlayingImg = StaticProperties.loadImageFrom(.startPlaying)
        self.playButton.setImage(startPlayingImg, for: .normal)
        self.playStatus = .Initial
        
        
        audioKitObj.stop()
    }
}

extension ViewController: AKMIDIListener {
    
}

