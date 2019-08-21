//
//  CustomCameraDelegate.swift
//  CustomCamera
//
//  Created by Ivo Peric on 11/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol CustomCameraDelegate: AnyObject {
    func customCameraOnCancel(viewController: CustomCameraViewController)
    func customCameraOnPermissionDenied(camera: Bool, microphone: Bool)
    func customCameraOnImage(image: UIImage, viewController: CustomCameraViewController)
    func customCameraOnVideo(path: String, viewController: CustomCameraViewController)
}
