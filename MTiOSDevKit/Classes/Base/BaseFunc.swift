//
//  BaseFunc.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/26.
//

import Foundation
import UIKit

public func mt_baseline(_ a: CGFloat)-> CGFloat{
    return a * UIScreen.main.bounds.width / 375
}


public func mt_print(_ items: Any..., separator: String = " ", terminator: String = "\n"){
    guard MTDevConfig.isLogEnable else{ return}
    
    print(items,separator: separator,terminator: terminator)
}


public let MT_SCREEN_WIDTH = UIScreen.main.bounds.width
public let MT_SCREEN_HEIGHT = UIScreen.main.bounds.height
