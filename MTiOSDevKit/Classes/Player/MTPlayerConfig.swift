//
//  MTPlayerConfig.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation

public struct MTPlayerConfig {
    public static var allowedOrientation: UIInterfaceOrientationMask = .portrait

    // MARK: (UI Config)

    public static var playControlItemSize: CGSize = .init(width: 22, height: 22)

    public static var trackColor: UIColor = .gray
    public static var progressColor: UIColor = .white.withAlphaComponent(0.8)

    public static var close: UIImage?
    public static var back: UIImage?
    public static var pause: UIImage?
    public static var play: UIImage?
    public static var slide: UIImage?
    public static var rotate: UIImage?
    public static var lock: UIImage?
    public static var unlock: UIImage?
    public static var download: UIImage?
    public static var scale: UIImage?
    public static var softHardDecode: UIImage?
    public static var volume: UIImage?
    public static var brightness: UIImage?
    public static var accelerate: UIImage?
}

public extension MTPlayerConfig {
    /// 解码方式
    enum SoftHardDecode: CaseIterable, MTPlayerOptionProtocol {
        case soft
        case hard

        public var title: String {
            switch self {
            case .soft: return "软解"
            case .hard: return "硬解"
            }
        }
    }

    /// 播放速率
    enum Rate: Float, CaseIterable, MTPlayerOptionProtocol {
        case r_0_75 = 0.75
        case r_1_0 = 1.0
        case r_1_25 = 1.25
        case r_1_5 = 1.5
        case r_1_75 = 1.75
        case r_2_0 = 2.0
        case r_3_0 = 3.0

        public var title: String {
            return "\(rawValue)×"
        }
    }

    enum Scale: CaseIterable, MTPlayerOptionProtocol {
        case `default`
        case fill
        case stretch

        public var title: String {
            switch self {
            case .default: return "默认"
            case .stretch: return "拉伸至全屏"
            case .fill: return "原比例放大"
            }
        }
    }
}
