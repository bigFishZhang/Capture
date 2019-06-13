//
//  ViewController.swift
//  LiveDemo
//
//  Created by bigfish on 2019/6/13.
//  Copyright © 2019 zzb. All rights reserved.
//
import UIKit
import AVKit
import GPUImage



class ViewController: UIViewController {
    
    @IBOutlet weak var beautyViewBottomCons: NSLayoutConstraint!
    // 视频源
    fileprivate lazy var camera : GPUImageVideoCamera? = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
    // 创建预览图层
    fileprivate lazy var preview : GPUImageView = GPUImageView(frame: self.view.bounds)
    
    // 初始化滤镜
    let bilateralFilter = GPUImageBilateralFilter() //磨皮
    let exposureFilter = GPUImageExposureFilter() //曝光
    let brightnessFilter = GPUImageBrightnessFilter() //美白
    let saturationFilter = GPUImageSaturationFilter() //饱和度
    
    var fileURL : URL {
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())12345.mp4")
    }
    
    
    // 创建写入对象
    fileprivate lazy var movieWriter : GPUImageMovieWriter = { [unowned self] in
        
       let writer = GPUImageMovieWriter(movieURL: self.fileURL, size: self.view.bounds.size)
        
        
        return writer!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(fileURL)
        
        // 1 设置camera 方向
        camera?.outputImageOrientation = .portrait
        camera?.horizontallyMirrorFrontFacingCamera =  true
        
        // 2 创建预览view
        
        view.insertSubview(preview, at: 0)
        
        // 3 获取滤镜组
        
        let filterGroup = getGroupFilters()
        
        
        // 4 设置GPUImage 响应连
        camera?.addTarget(filterGroup)
        filterGroup.addTarget(preview)
        
        // 5 采集视频
        camera?.startCapture()
        
        // 6 设置writer属性
        movieWriter.encodingLiveVideo = true
        
        filterGroup.addTarget(movieWriter)
        
        camera?.delegate = self
        
        camera?.audioEncodingTarget  = movieWriter
        // 开始录制
        movieWriter.startRecording()
        
    }
    
    fileprivate func getGroupFilters() ->GPUImageFilterGroup{
        // 1.创建滤镜组
        let filterGroup = GPUImageFilterGroup()
        // 2.创建滤镜(设置滤镜的依赖关系)
        bilateralFilter.addTarget(brightnessFilter)
        brightnessFilter.addTarget(exposureFilter)
        exposureFilter.addTarget(saturationFilter)
        // 3.设置滤镜组链初始&终点的filter
        filterGroup.initialFilters = [bilateralFilter]
        filterGroup.terminalFilter = saturationFilter
        
        return filterGroup
    }
    
    @IBAction func rorateCamera(_ sender: Any) {
     camera?.rotateCamera()
    }
    
    
    @IBAction func adjustBeautyEffect(_ sender: Any) {
     adjustBeautyView(constant: 0)
    }
    @IBAction func finishedBeautyEffect() {
        adjustBeautyView(constant: -250)
    }
    @IBAction func playLocalVideo(_ sender: Any) {
        print(fileURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: fileURL)
        present(playerVC, animated: true, completion: nil)
    
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        print(fileURL)
        camera?.stopCapture()
        
        preview.removeFromSuperview()
        movieWriter.finishRecording()
    }
    
    @IBAction func changeSatureation(_ sender: UISlider) {
        saturationFilter.saturation = CGFloat(sender.value * 2)
    }
    
    @IBAction func changeBrightness(_ sender: UISlider) {
        // - 1 --> 1
        brightnessFilter.brightness = CGFloat(sender.value) * 2 - 1
    }
    
    @IBAction func changeExposure(_ sender: UISlider) {
        // - 10 ~ 10
        exposureFilter.exposure = CGFloat(sender.value) * 20 - 10
    }
    
    @IBAction func changeBilateral(_ sender: UISlider) {
        bilateralFilter.distanceNormalizationFactor = CGFloat(sender.value) * 8
    }
    @IBAction func switchBeautyEffect(switchBtn : UISwitch) {
        if switchBtn.isOn {
            camera?.removeAllTargets()
            let group = getGroupFilters()
            camera?.addTarget(group)
            group.addTarget(preview)
        } else {
            camera?.removeAllTargets()
            camera?.addTarget(preview)
        }
    }
    
    private func adjustBeautyView(constant : CGFloat) {
        beautyViewBottomCons.constant = constant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}




extension ViewController : GPUImageVideoCameraDelegate{
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}
