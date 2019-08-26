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

open class CustomCameraViewController: CustomCameraBaseViewController, UINavigationControllerDelegate, UIVideoEditorControllerDelegate, CustomCameraViewDelegate {
    
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
    
    @IBOutlet weak var viewForCameraView: UIView!
    
    var configFile: CustomCameraConfigFile?
    var customCameraDelegate: CustomCameraDelegate?
    
    func setCustomConfigFile(configFile: CustomCameraConfigFile){
        self.configFile = configFile
    }
    
    func setCustomCameraDelegate(delegate: CustomCameraDelegate){
        self.customCameraDelegate = delegate
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        CustomCameraView.startCustomCameraInView(view: self.viewForCameraView, config: configFile, delegate: self, animate: false)
        
    }
    
    deinit {
        print("Deinit custom camera view controller")
    }
    
    public func customCameraViewOnImage(image: UIImage, view: CustomCameraView) {
        onImageTaken(image: image)
    }
    
    public func customCameraViewOnVideo(urlPath: URL, view: CustomCameraView) {
        onVideoRecorded(filePath: urlPath)
    }
    
    public func customCameraViewOnPermissionDenied(camera: Bool, microphone: Bool) {
        
    }
    
    public func customCameraViewOnCancel(view: CustomCameraView) {
        if(self.navigationController != nil){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if(self.viewForCameraView.subviews.count > 0){
            self.viewForCameraView.subviews[0].removeFromSuperview()
            self.viewForCameraView.tag = -99
        }
        super.viewWillDisappear(animated)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(self.viewForCameraView.tag == -99){
            self.viewForCameraView.tag = 0
            CustomCameraView.startCustomCameraInView(view: self.viewForCameraView, config: configFile, delegate: self, animate: false)
        }
    }
    
    func onImageTaken(image: UIImage){
        if(self.customCameraDelegate != nil){
            self.customCameraDelegate?.customCameraOnImage(image: image, viewController: self)
        }
    }
    
    func onVideoRecorded(filePath: URL) {
        if(configFile!.editVideoEnabled!){
            let editor = UIVideoEditorController()
            editor.videoPath = filePath.path
            editor.videoQuality = configFile!.editVideoQuality!
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }else{
            if(self.customCameraDelegate != nil){
                self.customCameraDelegate?.customCameraOnVideo(urlPath: filePath, viewController: self)
            }
        }
        
    }
    
    public func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    public func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    public func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        editor.dismiss(animated: true) {
            self.customCameraDelegate?.customCameraOnVideo(urlPath: URL(fileURLWithPath: editedVideoPath), viewController: self)
        }
    }
    
}
