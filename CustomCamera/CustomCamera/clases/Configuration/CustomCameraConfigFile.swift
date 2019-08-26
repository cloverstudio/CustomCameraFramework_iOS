//
//  CustomCameraConfigFile.swift
//  CustomCamera
//
//  Created by Ivo Peric on 11/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import Foundation
import UIKit

open class CustomCameraConfigFile: NSObject{
    
    public var holdForVideoTapForImageString: String?
    public var slideYourFingerUpToZoomInString: String?
    public var tapStopButtonToStopRecordingString: String?
    public var cameraFrontIcon: UIImage?
    public var cameraRearIcon: UIImage?
    public var flashOnIcon: UIImage?
    public var flashOffIcon: UIImage?
    public var flashAutoIcon: UIImage?
    public var maxVideoDuration: Int?
    public var videoPath: String?
    public var lockOpenIcon: UIImage?
    public var lockCloseIcon: UIImage?
    public var editVideoEnabled: Bool?
    public var editVideoQuality: UIImagePickerController.QualityType?
    
    public override init() {
        let storyboardBundle = Bundle(for: type(of: self))
        
        self.holdForVideoTapForImageString = "Hold for video, tap for photo"
        self.slideYourFingerUpToZoomInString = "Slide your finger up to zoom in, slide left to cancel recording or slide right to lock recording"
        self.tapStopButtonToStopRecordingString = "Tap stop button to stop recording"
        self.cameraFrontIcon = UIImage.init(named: "ic_camera_front", in: storyboardBundle, compatibleWith: nil)
        self.cameraRearIcon = UIImage.init(named: "ic_camera_rear", in: storyboardBundle, compatibleWith: nil)
        self.flashOffIcon = UIImage.init(named: "ic_flash_off", in: storyboardBundle, compatibleWith: nil)
        self.flashOnIcon = UIImage.init(named: "ic_flash_on", in: storyboardBundle, compatibleWith: nil)
        self.flashAutoIcon = UIImage.init(named: "ic_flash_auto", in: storyboardBundle, compatibleWith: nil)
        self.lockOpenIcon = UIImage.init(named: "ic_lock_open", in: storyboardBundle, compatibleWith: nil)
        self.lockCloseIcon = UIImage.init(named: "ic_lock_close", in: storyboardBundle, compatibleWith: nil)
        self.maxVideoDuration = 60
        self.editVideoEnabled = false
        self.editVideoQuality = .typeHigh
    }
    
    @objc public func setHoldForVideoTapForImageString(text: String){
        self.holdForVideoTapForImageString = text
    }
    
    @objc public func setSlideYourFingerUpToZoomInString(text: String){
        self.holdForVideoTapForImageString = text
    }
    
    @objc public func setCameraFrontIcon(image: UIImage){
        self.cameraFrontIcon = image
    }
    
    @objc public func setCameraRearIcon(image: UIImage){
        self.cameraRearIcon = image
    }
    
    @objc public func setFlashOffIcon(image: UIImage){
        self.flashOffIcon = image
    }
    
    @objc public func setFlashOnIcon(image: UIImage){
        self.flashOnIcon = image
    }
    
    @objc public func setLockOpenIcon(image: UIImage){
        self.lockOpenIcon = image
    }
    
    @objc public func setLockCloseIcon(image: UIImage){
        self.lockCloseIcon = image
    }
    
    @objc public func setTapStopButtonToStopRecordingString(text: String){
        self.tapStopButtonToStopRecordingString = text
    }
    
    @objc public func setEditVideoEnabled(enabled: Bool){
        self.editVideoEnabled = enabled
    }
    
    @objc public func setEditVideoQuality(quality: UIImagePickerController.QualityType){
        self.editVideoQuality = quality
    }
    
}
