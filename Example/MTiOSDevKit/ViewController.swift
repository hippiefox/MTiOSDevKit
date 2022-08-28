//
//  ViewController.swift
//  MTiOSDevKit
//
//  Created by HippieFox on 08/26/2022.
//  Copyright (c) 2022 HippieFox. All rights reserved.
//

import UIKit
import MTiOSDevKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let path = Bundle.main.path(forResource: "IMG_0019", ofType: "JPG")!
        
//        let img = UIImage.init(contentsOfFile: path)!
//        let data = UIImageJPEGRepresentation(img, 1) as! NSData
        
        let data = NSData.init(contentsOfFile: path)!
        let etag = data.wcs_etag()
        print(etag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

