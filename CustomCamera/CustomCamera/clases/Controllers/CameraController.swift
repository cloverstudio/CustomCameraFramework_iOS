//
//  CameraController.swift
//  CustomCamera
//
//  Created by Ivo Peric on 06/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraControllerDelegate: AnyObject {
    func onSelectedCamera(camera: AVCaptureDevice)
    func onNumbersOfCamera(numbers: Int)
    func onVideoRecorded(filePath: URL)
}

class CameraController: NSObject, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var captureAudio: AVCaptureDevice?
    var captureAudioInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.auto
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var currentZoom = 1.0 as CGFloat
    
    weak var delegate: CameraControllerDelegate?
    var maxVideo = 60
    var videoFilePath: String?
    
    var isCanceled = false as Bool
    var isLocked = false as Bool
}

extension CameraController {
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
            
            if((self.delegate) != nil){
                self.delegate?.onNumbersOfCamera(numbers: cameras.count)
            }
            
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
            
            let sessionAudio = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone], mediaType: AVMediaType.audio, position: .unspecified)
            for audio in sessionAudio.devices {
                if audio.hasMediaType(.audio){
                    self.captureAudio = audio
                    break
                }
            }
            
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
            
            self.captureAudioInput = try AVCaptureDeviceInput(device: self.captureAudio!)
            
            if self.captureAudioInput != nil && captureSession.canAddInput(self.captureAudioInput!){
                captureSession.addInput(self.captureAudioInput!)
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            if #available(iOS 11.0, *) {
                self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
                
            }
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
        
        func configureVideoOutput() throws {
            
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.videoOutput = AVCaptureMovieFileOutput()
            let maxDuration = CMTime.init(seconds: Double(self.maxVideo), preferredTimescale: 30)
            self.videoOutput!.maxRecordedDuration = maxDuration
            
            if captureSession.canAddOutput(self.videoOutput!) { captureSession.addOutput(self.videoOutput!) }
            
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
                try configureVideoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
                if((self.delegate) != nil){
                    self.delegate?.onSelectedCamera(camera: (self.currentCameraPosition == CameraPosition.rear ? self.rearCamera : self.frontCamera)!)
                }
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        self.previewLayer?.frame = view.bounds
        view.layer.addSublayer(self.previewLayer!)
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else {
                throw CameraControllerError.invalidOperation
            }
            
        }
        
        func switchToRearCamera() throws {
            
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
        
        if((self.delegate) != nil){
            self.delegate?.onSelectedCamera(camera: (self.currentCameraPosition == CameraPosition.rear ? self.rearCamera : self.frontCamera)!)
        }
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func startRecording(completion: @escaping (Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(CameraControllerError.captureSessionIsMissing); return }
        
        var fileURL: URL
        if(videoFilePath != nil && videoFilePath!.count > 0){
            fileURL = URL(string: self.videoFilePath!)!
        }else{
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            fileURL = URL(string:"\(documentsURL.appendingPathComponent("temp"))" + ".mov")!
        }
        
        self.videoOutput?.startRecording(to: fileURL, recordingDelegate: self)
    }
    
    func stopRecording(){
        self.videoOutput?.stopRecording()
    }
    
    func cancelRecording(){
        self.isCanceled = true
        self.videoOutput?.stopRecording()
    }
    
    func lockRecording(){
        self.isLocked = true
    }
    
    func isLockOrCanceled() ->Bool{
        return self.isLocked || self.isCanceled
    }
    
    func isLockedAndRecording() ->Bool{
        return self.videoOutput!.isRecording && self.isLocked
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if(!self.isCanceled){
            if((self.delegate) != nil){
                self.delegate?.onVideoRecorded(filePath: outputFileURL)
            }
        }
    }
    
    func focusOnTouch(point: CGPoint) throws{
        var currentDevice = self.frontCamera
        if(self.currentCameraPosition == CameraPosition.rear){
            currentDevice = self.rearCamera
        }
        
        if let device = currentDevice {
            do {
                try device.lockForConfiguration()
                
                device.focusPointOfInterest = point
                //device.focusMode = .continuousAutoFocus
                device.focusMode = .autoFocus
                //device.focusMode = .locked
                device.exposurePointOfInterest = point
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {
                throw CameraControllerError.invalidOperation
            }
        }else{
            throw CameraControllerError.invalidOperation
        }
    }
    
    func zoomOnPinch(zoom: CGFloat) throws{
        do{
            
            var currentDevice = self.frontCamera
            if(self.currentCameraPosition == CameraPosition.rear){
                currentDevice = self.rearCamera
            }
            
            var zoomToApply = zoom
            
            try currentDevice!.lockForConfiguration()
            defer {currentDevice!.unlockForConfiguration()}
            
            if (zoomToApply > currentDevice!.activeFormat.videoMaxZoomFactor){
                zoomToApply = currentDevice!.activeFormat.videoMaxZoomFactor
            }else if(zoomToApply < 1){
                zoomToApply = 1
            }
            
            self.currentZoom = zoomToApply
            
            currentDevice!.videoZoomFactor = zoomToApply
            
        }catch _{
            throw CameraControllerError.invalidOperation
        }
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                            resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
        
    }
    
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data) {
            
            self.photoCaptureCompletionBlock?(image, nil)
        }
            
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
