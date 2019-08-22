//
//  CustomCameraViewController.swift
//  CustomCamera
//
//  Created by Ivo Peric on 06/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

open class CustomCameraViewController: CustomCameraBaseViewController, CameraFocusableViewDelegate, CameraControllerDelegate {
    
    @objc public static func startCustomCameraForObjC(viewOrNavigationController: Any, config: CustomCameraConfigFile, delegate: CustomCameraDelegate){
        startCustomCamera(viewOrNavigationController: viewOrNavigationController, config: config, delegate: delegate)
    }
    
    public static func startCustomCamera(viewOrNavigationController: Any, config: CustomCameraConfigFile, delegate: CustomCameraDelegate){
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                    if granted {
                        DispatchQueue.main.async {
                            let className = CustomCameraViewController.getClassName()
                            let vc = CustomCameraViewController.initWithStoryBoard(className: className) as! CustomCameraViewController
                            vc.setCustomConfigFile(configFile: config)
                            vc.setCustomCameraDelegate(delegate: delegate)
                            
                            if(viewOrNavigationController is UIViewController){
                                let parent: UIViewController = viewOrNavigationController as! UIViewController
                                parent.present(vc as UIViewController, animated: true, completion: nil)
                            }else{
                                let navigation: UINavigationController = viewOrNavigationController as! UINavigationController
                                navigation.pushViewController(vc, animated: true)
                            }
                        }
                    }else{
                        delegate.customCameraOnPermissionDenied(camera: true, microphone: false)
                    }
                }
            } else {
                delegate.customCameraOnPermissionDenied(camera: false, microphone: false)
            }
        }
        
        
    }
    
    var dispatchItemForZoom = DispatchWorkItem.init {}
    var timerForVideoRecording: Timer?
    var recordingTime = 0 as UInt64
    
    @IBOutlet weak var previewView: CameraFocusableView!
    let cameraController = CameraController()
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var viewForZoom: UIView!
    @IBOutlet weak var viewForZoomMin: UIView!
    @IBOutlet weak var viewForZoomCurrent: UIView!
    @IBOutlet weak var labelForZoom: UILabel!
    @IBOutlet weak var takePictureButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var redViewForRecording: UIView!
    @IBOutlet weak var viewForVideoDuration: UIView!
    @IBOutlet weak var labelVideoDuration: UILabel!
    @IBOutlet weak var videoProgressDuration: UIProgressView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var labelForVideoZoom: UILabel!
    @IBOutlet weak var cancelVideoRecording: UIImageView!
    @IBOutlet weak var lockVideoRecording: UIImageView!
    @IBOutlet weak var animateView: UIView!
    @IBOutlet weak var blockUIButton: UIButton!
    
    var configFile: CustomCameraConfigFile?
    var customCameraDelegate: CustomCameraDelegate?
    var lastMoveForLockZoom : CGFloat?
    
    func setCustomConfigFile(configFile: CustomCameraConfigFile){
        self.configFile = configFile
    }
    
    func setCustomCameraDelegate(delegate: CustomCameraDelegate){
        self.customCameraDelegate = delegate
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastMoveForLockZoom = 0.0
        
        if(configFile == nil){
            configFile = CustomCameraConfigFile.init()
        }
        
        func configureCameraController() {
            cameraController.delegate = self
            cameraController.maxVideo = (configFile?.maxVideoDuration)!
            if(configFile?.videoPath != nil){
                cameraController.videoFilePath = configFile?.videoPath
            }
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                self.blockUIButton.hideView()
                
                try? self.cameraController.displayPreview(on: self.previewView)
            }
        }
        
        self.switchCameraButton.setImage(configFile?.cameraFrontIcon, for: .normal)
        self.flashButton.setImage(configFile?.flashAutoIcon, for: .normal)
        
        self.closeButton.cornerView(corner: 8)
        
        self.viewForZoom.addBorderToView(width: 1, color: UIColor.white)
        self.viewForZoom.cornerView(corner: (UIScreen.main.bounds.size.width - (48 * 2)) / 2)
        
        self.viewForZoomMin.addBorderToView(width: 1, color: UIColor.white)
        self.viewForZoomMin.cornerView(corner: ((UIScreen.main.bounds.size.width - (48 * 2)) * 0.3) / 2)
        
        self.viewForZoomCurrent.addBorderToView(width: 1, color: UIColor.blue)
        self.viewForZoomCurrent.frame = self.viewForZoomMin.frame
        self.viewForZoomCurrent.cornerView(corner: ((UIScreen.main.bounds.size.width - (48 * 2)) * 0.3) / 2)
        
        self.labelForZoom.textColor = UIColor.white
        
        self.infoLabel.text = configFile?.holdForVideoTapForImageString
        
        self.takePictureButton.addBorderToView(width: 2, color: UIColor.white)
        self.takePictureButton.roundView()
        
        self.animateView.addGradientBorderToView()
        
        self.redViewForRecording.roundView()
        
        self.viewForVideoDuration.cornerView(corner: 8)
        
        self.videoProgressDuration.setProgress(0, animated: false)
        self.labelVideoDuration.text = "00:00"
        
        self.labelForVideoZoom.superview!.cornerView(corner: 8)
        
        self.cancelVideoRecording.roundView()
        self.cancelVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.lockVideoRecording.roundView()
        self.lockVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.lockVideoRecording.image = configFile?.lockOpenIcon
        
        configureCameraController()
        
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongGesture))
        self.takePictureButton.addGestureRecognizer(longGesture)
        
    }
    
    @objc func onLongGesture(sender:UIPinchGestureRecognizer){
        if(sender.state == .began){
            if(self.cameraController.videoOutput!.isRecording){
                return
            }
            self.cameraController.isCanceled = false
            self.cameraController.isLocked = false
            self.cameraController.startRecording { (error) in
                if(error != nil){
                    print(error ?? "Image capture error")
                    return
                }
            }
            self.previewView.disableZoom = true
            self.redViewForRecording.showView()
            self.viewForVideoDuration.showView()
            
            self.animateStartRecordingView()
            
            recordingTime = Date.init().nowLong
            self.timerForVideoRecording = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
                let currentTime = Date.init().nowLong
                let current = currentTime - self.recordingTime
                self.labelVideoDuration.text = String(format: "%02d:%02d", current / 60, current % 60)
                let progress = Float(current) / Float(self.cameraController.maxVideo) as Float
                self.videoProgressDuration.setProgress(progress, animated: true)
            }
            self.infoLabel.text = configFile?.slideYourFingerUpToZoomInString
        }else if(sender.state == .changed){
            
            if(self.cameraController.isLockOrCanceled()){
                return
            }
            
            let touchPoint = sender.location(in: self.view)
            
            let cancelRight = self.cancelVideoRecording.rightPoint
            let cancelTop = self.cancelVideoRecording.topPoint
            
            if(touchPoint.x < cancelRight && touchPoint.y > cancelTop){
                if(self.cancelVideoRecording.tag != 99){
                    self.cancelVideoRecording.tag = 99
                    self.cancelVideoRecording.backgroundColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1)
                    UIView.animate(withDuration: 0.15) {
                        self.cancelVideoRecording.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }
                }
            }else if(self.cancelVideoRecording.tag == 99){
                self.cancelVideoRecording.tag = 0
                self.cancelVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                UIView.animate(withDuration: 0.15) {
                    self.cancelVideoRecording.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
            
            let lockLeft = self.lockVideoRecording.leftPoint
            let lockTop = self.lockVideoRecording.topPoint
            
            if(touchPoint.x > lockLeft && touchPoint.y > lockTop){
                if(self.lockVideoRecording.tag != 99){
                    self.lockVideoRecording.tag = 99
                    self.lockVideoRecording.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
                    UIView.animate(withDuration: 0.15) {
                        self.lockVideoRecording.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    }
                }
            }else if(self.lockVideoRecording.tag == 99){
                self.lockVideoRecording.tag = 0
                self.lockVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
                UIView.animate(withDuration: 0.15) {
                    self.lockVideoRecording.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
            
            let buttonPointY = takePictureButton.frame.origin.y
            if(touchPoint.y < buttonPointY){
                
                let heightToWorkWith = buttonPointY
                let heightMin = heightToWorkWith * 0.3
                let heightMax = buttonPointY
                
                let diffMy = heightMax - touchPoint.y + heightMin
                
                let step = (heightMax - heightMin) / ((self.previewView.maxZoom - 1) * 10)
                let newLevel = (diffMy - heightMin) / step + 10
                let roundedNewLevel = round(newLevel * 10) / 10
                var newScale = roundedNewLevel / 10
                
                newScale = newScale < 1.0 ? 1.0 : newScale > self.previewView.maxZoom ? self.previewView.maxZoom : newScale
                
                if(self.cameraController.currentZoom != newScale){
                    cameraController.currentZoom = newScale
                    self.onVideoZoom(zoom: newScale, withoutShowingLabel: false)
                }
            }else{
                if(self.cameraController.currentZoom != 1.0){
                    self.onVideoZoom(zoom: 1.0, withoutShowingLabel: false)
                }
            }
        }else{
            if(self.cameraController.isLockOrCanceled()){
                return
            }
            if(self.cancelVideoRecording.tag == 99){
                let touchPoint = sender.location(in: self.view)
                let cancelRight = self.cancelVideoRecording.rightPoint
                let cancelTop = self.cancelVideoRecording.topPoint
                if(touchPoint.x < cancelRight && touchPoint.y > cancelTop){
                    self.cameraController.cancelRecording()
                    self.timerForVideoRecording?.invalidate()
                    self.timerForVideoRecording = nil
                    self.resetRecordingView()
                    return
                }
            }else if(self.lockVideoRecording.tag == 99){
                let touchPoint = sender.location(in: self.view)
                let lockLeft = self.lockVideoRecording.leftPoint
                let lockTop = self.lockVideoRecording.topPoint
                
                if(touchPoint.x > lockLeft && touchPoint.y > lockTop){
                    self.cameraController.lockRecording()
                    self.lockRecording()
                    return
                }
            }
            
            self.stopRecording()
        }
    }
    
    func stopRecording(){
        self.cameraController.stopRecording()
        self.timerForVideoRecording?.invalidate()
        self.timerForVideoRecording = nil
        self.animateView.hideView()
        self.animateView.removeRotateAnimation()
    }
    
    func onVideoRecorded(filePath: URL) {
        if(self.customCameraDelegate != nil){
            self.customCameraDelegate?.customCameraOnVideo(path: filePath.absoluteString, viewController: self)
            self.resetRecordingView()
        }
    }
    
    @IBAction func takePictureTouchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.takePictureButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.animateView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
    }
    
    @IBAction func takePictureTouchUpOutside(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.takePictureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.animateView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    @IBAction func takePictureTouchUpInside(_ sender: Any) {
        if(self.cameraController.isLockedAndRecording()){
            self.stopRecording()
            return
        }
        self.takePictureButton.isUserInteractionEnabled = false
        self.takePictureButton.backgroundColor = UIColor.red
        self.takePicture()
    }
    
    func takePicture(){
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            if(self.customCameraDelegate != nil){
                self.customCameraDelegate?.customCameraOnImage(image: image, viewController: self)
                self.resetImageViews()
            }
            
        }
    }
    
    @IBAction func flashClick(_ sender: Any) {
        
        if(cameraController.flashMode == .on){
            animateFlashButton(image: (self.configFile?.flashOffIcon)!)
            cameraController.flashMode = .off
        }else if(cameraController.flashMode == .off){
            animateFlashButton(image: (self.configFile?.flashAutoIcon)!)
            cameraController.flashMode = .auto
        }else{
            animateFlashButton(image: (self.configFile?.flashOnIcon)!)
            cameraController.flashMode = .on
        }
        
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        
        do {
            try cameraController.switchCameras()
        }
            
        catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            animateSwitchButton(image: (self.configFile?.cameraRearIcon)!)
            
        case .some(.rear):
            animateSwitchButton(image: (self.configFile?.cameraFrontIcon)!)
            
        case .none:
            return
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if(self.customCameraDelegate != nil){
            self.customCameraDelegate?.customCameraOnCancel(viewController: self)
        }
    }
    
    func animateSwitchButton(image: UIImage){
        UIView.animate(withDuration: 0.3, animations: {
            self.switchCameraButton.transform = CGAffineTransform(scaleX: 0.01, y: 1.5)
        }) { (_) in
            self.switchCameraButton.setImage(image, for: .normal)
            UIView.animate(withDuration: 0.3) {
                self.switchCameraButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    func animateFlashButton(image: UIImage){
        UIView.animate(withDuration: 0.3, animations: {
            self.flashButton.transform = CGAffineTransform(translationX: 0.0, y: self.flashButton.frame.size.height)
            self.flashButton.alpha = 0.0;
        }) { (_) in
            self.flashButton.setImage(image, for: .normal)
            self.flashButton.transform = CGAffineTransform(translationX: 0.0, y: -self.flashButton.frame.size.height)
            UIView.animate(withDuration: 0.3) {
                self.flashButton.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
                self.flashButton.alpha = 1.0;
            }
        }
    }
    
    func animateStartRecordingView(){
        self.flashButton.animateHideWithFade(toHide: true)
        self.switchCameraButton.animateHideWithFade(toHide: true)
        
        self.cancelVideoRecording.animateShowWithFade()
        self.lockVideoRecording.animateShowWithFade()
        
        self.animateView.showView()
        self.animateView.infiniteRoatation()
    }
    
    func resetRecordingView(){
        self.animateView.hideView()
        self.animateView.removeRotateAnimation()
        self.cancelVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.lockVideoRecording.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.lockVideoRecording.image =  configFile?.lockOpenIcon
        self.redViewForRecording.roundView()
        self.cancelVideoRecording.animateHideWithFade(toHide: true)
        self.lockVideoRecording.animateHideWithFade(toHide: true)
        
        self.flashButton.animateShowWithFade()
        self.switchCameraButton.animateShowWithFade()
        
        self.previewView.disableZoom = false
        self.previewView.disableFocus = false
        self.redViewForRecording.hideView()
        self.viewForVideoDuration.hideView()
        self.infoLabel.text = configFile?.holdForVideoTapForImageString
        
        self.cameraController.currentZoom = 1.0
        self.onVideoZoom(zoom: 1.0, withoutShowingLabel: true)
        
        UIView.animate(withDuration: 0.3) {
            self.takePictureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.animateView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        UIView.animate(withDuration: 0.15) {
            self.cancelVideoRecording.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func resetImageViews(){
        UIView.animate(withDuration: 0.3) {
            self.takePictureButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.animateView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        self.takePictureButton.isUserInteractionEnabled = true
        self.takePictureButton.backgroundColor = UIColor.clear
        
        self.cameraController.currentZoom = 1.0
        self.onVideoZoom(zoom: 1.0, withoutShowingLabel: true)
    }
    
    func lockRecording(){
        self.previewView.disableFocus = true
        self.redViewForRecording.cornerView(corner: 10)
        self.lockVideoRecording.image =  configFile?.lockCloseIcon
        self.infoLabel.text = configFile?.tapStopButtonToStopRecordingString
        self.previewView.disableZoom = false
        self.cancelVideoRecording.animateHideWithFade(toHide: true)
        UIView.animate(withDuration: 0.15) {
            self.lockVideoRecording.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func onTouch(point: CGPoint) {
        if(self.previewView.disableFocus){
            return;
        }
        do {
            try cameraController.focusOnTouch(point: point)
        }
        catch {
            print(error)
        }
    }
    
    func onZoom(zoom: CGFloat) {
        do {
            try cameraController.zoomOnPinch(zoom: zoom)
        }
        catch {
            print(error)
        }
        
        let maxHeight = self.viewForZoom.frame.size.height
        let minHeight = self.viewForZoomMin.frame.size.height
        let minZoom = 1.0 as CGFloat
        let maxZoom = self.previewView.maxZoom
        let step = (maxHeight - minHeight) / (maxZoom - minZoom)
        var size = (zoom - 1) * step + minHeight
        size = size > maxHeight ? maxHeight : size < minHeight ? minHeight : size
        
        let scaleFactor = size / minHeight
        
        self.labelForZoom.text = String.init(format: "x%.1f", zoom)
        self.viewForZoomCurrent.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
    }
    
    func onVideoZoom(zoom: CGFloat, withoutShowingLabel:Bool) {
        do {
            try cameraController.zoomOnPinch(zoom: zoom)
        }
        catch {
            print(error)
        }
        self.dispatchItemForZoom.cancel()
        
        if(withoutShowingLabel){
            self.labelForVideoZoom.text = String.init(format: "x%.1f", zoom)
            return
        }
        
        self.labelForVideoZoom.superview!.showView()
        
        self.labelForVideoZoom.text = String.init(format: "x%.1f", zoom)
        
        self.dispatchItemForZoom = DispatchWorkItem.init(block: {
            self.labelForVideoZoom.superview!.hideView()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: self.dispatchItemForZoom)
        
    }
    
    func onStartZoom(){
        self.dispatchItemForZoom.cancel()
        self.viewForZoom.showView()
    }
    
    func onFinishedZoom(){
        self.dispatchItemForZoom.cancel()
        self.dispatchItemForZoom = DispatchWorkItem.init(block: {
            self.viewForZoom.hideView()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: self.dispatchItemForZoom)
    }
    
    func onMove(point: CGPoint) {
        if(self.cameraController.isLockedAndRecording()){
            
            let treshold = self.lastMoveForLockZoom! - point.y
            
            if(treshold < 3 && treshold > -3){
                return
            }
            
            self.lastMoveForLockZoom = point.y
            
            var step = 0.1 as CGFloat
            if(treshold < 0){
                step = -0.1
            }
            var newScale = self.cameraController.currentZoom + step
            
            newScale = newScale < 1.0 ? 1.0 : newScale > self.previewView.maxZoom ? self.previewView.maxZoom : newScale
            
            if(self.cameraController.currentZoom != newScale){
                cameraController.currentZoom = newScale
                self.onVideoZoom(zoom: newScale, withoutShowingLabel: false)
            }
        }
    }
    
    func onStartMove(point: CGPoint) {
        if(self.cameraController.isLockedAndRecording()){
            self.lastMoveForLockZoom = point.y
        }
    }
    
    func onSelectedCamera(camera: AVCaptureDevice) {
        self.previewView.isFocusSupported = camera.isFocusPointOfInterestSupported
        self.previewView.maxZoom = camera.activeFormat.videoMaxZoomFactor
        self.previewView.currentZoom = 1.0
        if(!camera.hasFlash){
            animateFlashButton(image: (self.configFile?.flashOffIcon)!)
            cameraController.flashMode = AVCaptureDevice.FlashMode.off
            flashButton.isUserInteractionEnabled = false
        }else{
            animateFlashButton(image: (self.configFile?.flashAutoIcon)!)
            cameraController.flashMode = AVCaptureDevice.FlashMode.auto
            flashButton.isUserInteractionEnabled = true
        }
    }
    
    func onNumbersOfCamera(numbers: Int){
        if(numbers > 1){
            DispatchQueue.main.async {
                self.switchCameraButton.showView()
                self.switchCameraButton.alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.switchCameraButton.alpha = 1.0
                }
            }
        }
    }
    
    @IBAction func clickOnBlockUIButton(_ sender: Any) {
        print("Preparing")
    }
    
    deinit {
        if(self.timerForVideoRecording != nil){
            self.timerForVideoRecording?.invalidate()
            self.timerForVideoRecording = nil
        }
    }
    
}
