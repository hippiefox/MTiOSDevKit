//
//  MTPlayerControls_Ext.swift
//  MTiOSDevKit
//
//  Created by PanGu on 2022/8/30.
//

import Foundation
import UIKit


public extension MTPlayerControls {
    enum PlayerOption {
        case play
        case pause
        case close
        case slide(Float)
        case longPress(Bool)
        case rotate
        case rate
        case scale
        case softHard
    }

    enum PanOption {
        case none
        case volume
        case lightness
        case progress
    }
}

public class MTPlayerContentView: UIView{
    
}
public class MTPlayerGestureView: UIView{
    
}
public class MTPlayerBottomView: UIView{
    
}
public class MTPlayerTopView: UIView{
    
}
public class MTPlayerMiddleView: UIView{
    
}
public class MTPlayerAppdendixView: UIView{
    
}
