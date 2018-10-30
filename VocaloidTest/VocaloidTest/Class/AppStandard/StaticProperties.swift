//
//  StaticProperties.swift
//  SoundsFilter
//
//  Created by X Young. on 2018/10/10.
//  Copyright © 2018 X Young. All rights reserved.
//

import UIKit

class StaticProperties: NSObject {
    /// 图片文件名集合
    enum ImageName: String {
        /// 播放
        case startPlaying = "start_playing"
        
        /// 停止播放
        case stopPlaying = "stop_playing"
        
    }
    
    static func loadImageFrom(_ imageNameEnum: ImageName) -> UIImage {
        let imageName = imageNameEnum.rawValue
        let image = UIImage.init(named: imageName)
        
        return image!
    }
    
    /// 播放页面状态
    enum PlayStatus {
        /// 初始
        case Initial
        
        /// 播放中
        case Playing
    }
    
}

