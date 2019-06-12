//
//  ViewController.swift
//  GPUImageDemo
//
//  Created by bigfish on 2019/6/12.
//  Copyright © 2019 zzb. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    
//    fileprivate lazy var camera : GPUImageStillCamera = GPUImageStillCamera(sessionPreset:AVCaptureSession.Preset.high.rawValue , cameraPosition: .front)
    fileprivate lazy var camera : GPUImageVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
    
    fileprivate lazy var filter = GPUImageBrightnessFilter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Thread.current)
        
        
        camera.outputImageOrientation = .portrait
//
        filter.brightness = 0.3
        camera.addTarget(filter)
        camera.delegate = self
//
//
        let showView = GPUImageView(frame: view.bounds)
        view.insertSubview(showView, at: 0)
        filter.addTarget(showView)
//
        camera.startCapture()
    }

    
    
    
    @IBAction func screenshots(_ sender: Any) {
        
//        camera.capturePhotoAsImageProcessedUp(toFilter: filter) { (image, error) in
//
//            DispatchQueue.main.async {
//                print(Thread.current)
//                UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
//                self.imageView.image = image
//                self.camera.stopCapture()
//            }
//
//        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        guard let sourceImage  = UIImage(named: "test") else {
//            return
//        }
//
//        let picProcess = GPUImagePicture(image: sourceImage)
//
//        let blurFilter = GPUImageGaussianBlurFilter()
//
//        blurFilter.texelSpacingMultiplier = 2
//        blurFilter.blurRadiusInPixels = 2
//
//        picProcess?.addTarget(blurFilter)
//
//        blurFilter.useNextFrameForImageCapture()
//        picProcess?.processImage()
//
//        let newImage = blurFilter.imageFromCurrentFramebuffer()
//
//        imageView.image = newImage
//    }

}


extension ViewController : GPUImageVideoCameraDelegate{
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("willOutputSampleBuffer")
    }
}
