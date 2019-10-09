//
//  CameraClass.swift
//  CustomCamera
//
//  Created by Moek Thona on 10/9/19.
//  Copyright © 2019 Moek Thona. All rights reserved.
//

import UIKit
import UIKit
import AVFoundation


class CameraClass {
    
    public enum CameraPosition {
        case front
        case rear
    }
    
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var currentCameraPosition: CameraPosition?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    func setup(on view: UIView){
//        DispatchQueue.main.async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
                try self.displayPreview(on: view)
            }catch {
                print("Error on prepare")
            }
//        }
        
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else {return}
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCamera(){
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { return}
        
        captureSession.beginConfiguration()
        
        switch currentCameraPosition {
        case .front:
            try! switchToRearCamera()
            
        case .rear:
            try! switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    func switchCamera(_ position : CameraPosition){
        guard var currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { return}
        currentCameraPosition = position
        captureSession.beginConfiguration()
        
        switch currentCameraPosition {
        case .front:
            try! switchToRearCamera()
            
        case .rear:
            try! switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
     func captureImage(completion: @escaping (UIImage?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        if let videoConnection = stillImageOutput!.connection(with: AVMediaType.video) {
            stillImageOutput!.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                // UIImageWriteToSavedPhotosAlbum(, nil, nil, nil)
                let image = UIImage(data: imageData!)!
                  completion(image)
            }
        }else{
            completion(nil)
        }
        
      
    }
    
    private func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    private func configureCaptureDevices() throws {
        
        let cameras = AVCaptureDevice.devices(for: AVMediaType.video)
        guard !cameras.isEmpty else { return }
        
        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
            }
            
            if camera.position == .back {
                self.rearCamera = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    private func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { return}
        
        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
            
            self.currentCameraPosition = .rear
        }
            
        else if let frontCamera = self.frontCamera {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
            else { return }
            
            self.currentCameraPosition = .front
        }
        
    }
    private func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { return }
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(self.stillImageOutput!) { captureSession.addOutput(self.stillImageOutput!) }
        captureSession.startRunning()
    }
    
    private func switchToFrontCamera() throws {
        
        guard let rearCameraInput = self.rearCameraInput, captureSession!.inputs.contains(rearCameraInput),
            let frontCamera = self.frontCamera else { return }
        
        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        captureSession!.removeInput(rearCameraInput)
        
        if captureSession!.canAddInput(self.frontCameraInput!) {
            captureSession!.addInput(self.frontCameraInput!)
            
            self.currentCameraPosition = .front
        }
        
    }
    
    private func switchToRearCamera() throws {
        
        guard let frontCameraInput = self.frontCameraInput, captureSession!.inputs.contains(frontCameraInput),
            let rearCamera = self.rearCamera else { return }
        
        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
        captureSession!.removeInput(frontCameraInput)
        
        if captureSession!.canAddInput(self.rearCameraInput!) {
            captureSession!.addInput(self.rearCameraInput!)
            
            self.currentCameraPosition = .rear
        }
        
    }
    
}
