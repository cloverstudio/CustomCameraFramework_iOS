//
//  BaseViewController.swift
//  CustomCamera
//
//  Created by Ivo Peric on 06/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import UIKit

open class CustomCameraBaseViewController: UIViewController {
    
    static func initWithStoryBoard(className: String) -> Any{
        let storyboardBundle = Bundle(for: self)
        let storyboard = UIStoryboard.init(name: className, bundle: storyboardBundle)
        return storyboard.instantiateInitialViewController()!
    }
    
    static func getClassName() -> String{
        let className = NSStringFromClass(self).components(separatedBy: ".").last
        return className!
    }

}
