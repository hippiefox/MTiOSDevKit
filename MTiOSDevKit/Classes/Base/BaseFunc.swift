//
//  BaseFunc.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/26.
//

import Foundation
import UIKit

func mt_baseline(_ a: CGFloat)-> CGFloat{
    return a * UIScreen.main.bounds.width / 375
}
