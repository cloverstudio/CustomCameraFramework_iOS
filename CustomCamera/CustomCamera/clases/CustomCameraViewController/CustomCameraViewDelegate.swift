//
//  CustomCameraDelegate.swift
//  CustomCamera
//
//  Created by Ivo Peric on 11/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol CustomCameraViewDelegate: AnyObject {
    func customCameraViewOnCancel(view: CustomCameraView)
    func customCameraViewOnPermissionDenied(camera: Bool, microphone: Bool)
    func customCameraViewOnImage(image: UIImage, view: CustomCameraView)
    func customCameraViewOnVideo(urlPath: URL, view: CustomCameraView)
}
