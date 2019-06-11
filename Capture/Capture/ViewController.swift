//
//  ViewController.swift
//  Capture
//
//  Created by bigfish on 2019/6/11.
//  Copyright © 2019 zzb. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    fileprivate lazy var session : AVCaptureSession = AVCaptureSession();
    fileprivate var videoOutput : AVCaptureVideoDataOutput?
    fileprivate var videoInput : AVCaptureDeviceInput?
    fileprivate var movieOutput : AVCaptureMovieFileOutput?
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
        //1 初始化视频的输入输出
        setupVideoInputOutput()
        //2 初始化音频的输入输出
        setupAudioInputOutput()

    }

    @IBAction func startCapturing(_ sender: Any) {
        session.startRunning()
        
        setupPreviewLayer()
        
        // 录制视频, 并且写入文件
        setupMovieFileOutput()
        
    }
    
    @IBAction func stopCapturing(_ sender: Any) {
        movieOutput?.stopRecording()
        
        session.stopRunning()
        previewLayer?.removeFromSuperlayer()
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        // 1.取出之前镜头的方向
        guard let videoInput = videoInput else {
            return
        }
        let postion : AVCaptureDevice.Position = videoInput.device.position == .front ? .back : .front
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else { return }
        guard let device = devices.filter({ $0.position == postion }).first else { return }
        guard let newInput = try? AVCaptureDeviceInput(device: device) else { return }
        
        
        // 2.移除之前的input, 添加新的input
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(newInput) {
            session.addInput(newInput)
        }
        session.commitConfiguration()
        
        // 3.保存最新的input
        self.videoInput = newInput
    }
    
}



extension ViewController {
    
    /// 创建预览图层
    fileprivate func setupPreviewLayer(){
        
        //1 创建预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        //2 设置属性
        previewLayer.frame = view.bounds
        //3 添加图层到view
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
    
    
    
    /// 初始化视频的输入输出
    fileprivate func setupVideoInputOutput(){
        //1 视频的输入
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {
            print("get video AVCaptureDevices failed!")
            return
        }
        //1.1默认获取前置摄像头
        guard let device = devices.filter({$0.position == .front}).first else {
             print("get front video AVCaptureDevice  failed!")
            return
        }
        //1.2视频输入
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("get front video AVCaptureDeviceInput  failed!")
            return
        }
        self.videoInput = input
        //2 视频的输出
        let output = AVCaptureVideoDataOutput();
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        self.videoOutput = output
        
        //3 会话添加视频输入输出
        addInputOutputToSession(input, output)
    }
    
    /// 初始化音频的输入输出
    fileprivate func setupAudioInputOutput(){
        //1 音频的输入
        guard let device = AVCaptureDevice.default(for: .audio) else {
            print("get audio AVCaptureDevice  failed!")
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("get audio AVCaptureDeviceInput  failed!")
            return
        }
        //2 音频的输出
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        //3 会话添加音频输入输出
        addInputOutputToSession(input, output)
    }
    
    
    /// 添加一组输入输出
    ///
    /// - Parameters:
    ///   - input: 输入
    ///   - output: 输入
    private func addInputOutputToSession(_ input :AVCaptureInput,_ output : AVCaptureOutput){
        session.beginConfiguration()
        
        if session.canAddInput(input){
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
    }
    
    
    fileprivate func setupMovieFileOutput(){
        
        if (self.movieOutput != nil){
             session.removeOutput(self.movieOutput!)
        }
        
        let fileOutput = AVCaptureMovieFileOutput()
        self.movieOutput = fileOutput
        
        let connection = fileOutput.connection(with: .video)
        connection?.automaticallyAdjustsVideoMirroring  = true
        
        if session.canAddOutput(fileOutput){
            session.addOutput(fileOutput)
        }
        
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/test.mp4"
        let fileURL = URL(fileURLWithPath: filePath)
        
        fileOutput.startRecording(to: fileURL, recordingDelegate: self)
        
        
        
        
    }
    
    
    
    
}


extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if videoOutput?.connection(with: .video)  == connection{
            print("采集视频数据")
        }else{
            print("采集音频数据")
        }
    }
   
    
    

}





extension ViewController : AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始写入文件")
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("文件写入完成")
    }
    
    
}
