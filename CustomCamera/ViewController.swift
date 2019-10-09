//
//  ViewController.swift
//  CustomCamera
//
//  Created by Moek Thona on 10/9/19.
//  Copyright © 2019 Moek Thona. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

    @IBOutlet weak var imgDisplay: UIImageView!
    @IBOutlet weak var previewView: UIImageView!
    
    let camera = CameraClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.setup(on: previewView)
        camera.switchCamera(.front)
    }
    
    @IBAction func btnTake(_ sender: Any) {
        camera.captureImage { (image) in
            self.imgDisplay.image = image
            print(image!)
        }
    }
    @IBAction func btnSwitch(_ sender: Any) {
        camera.switchCamera()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}


    



