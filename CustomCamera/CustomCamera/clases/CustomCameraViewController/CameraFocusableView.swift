//
//  CameraFocusableView.swift
//  CustomCamera
//
//  Created by Ivo Peric on 07/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import UIKit

@objc protocol CameraFocusableViewDelegate: AnyObject {
    func onTouch(point: CGPoint)
    func onZoom(zoom: CGFloat)
    func onStartZoom()
    func onFinishedZoom()
    func onMove(point: CGPoint)
    func onStartMove(point: CGPoint)
}

class CameraFocusableView: UIView {
    
    @IBOutlet weak var delegate: CameraFocusableViewDelegate?
    var currentZoom = 1.0 as CGFloat
    var maxZoom = 3.0 as CGFloat
    var minZoom = 1.0 as CGFloat
    var isFocusSupported = false
    var disableZoom = false
    var disableFocus = false
    
    var focusImage = UIImage.init(named: "ic_center_focus_weak")
    var imageViewForFocus = UIImageView.init() as UIImageView
    var item = DispatchWorkItem.init {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addPinchGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPinchGesture()
    }
    
    func addPinchGesture(){
        let gesture = UIPinchGestureRecognizer.init(target: self, action: #selector(onPinch))
        self.addGestureRecognizer(gesture)
    }
    
    @objc func onPinch(sender:UIPinchGestureRecognizer){
        if(disableZoom){
            return
        }
        checkForRemoveFocusImageView()
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minZoom), maxZoom), maxZoom)
        }
        
        func update(scale factor: CGFloat) {
            if((delegate) != nil){
                delegate!.onZoom(zoom: factor)
            }
        }
        
        func startZoom(){
            if((delegate) != nil){
                delegate!.onStartZoom()
            }
        }
        
        func finishZoom(){
            if((delegate) != nil){
                delegate!.onFinishedZoom()
            }
        }
        
        let newScaleFactor = minMaxZoom(sender.scale * currentZoom)
        
        switch sender.state {
        case .began: startZoom()
        case .changed: update(scale: newScaleFactor)
        case .ended:
            currentZoom = minMaxZoom(newScaleFactor)
            update(scale: currentZoom)
            finishZoom()
        default: break
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if((event?.allTouches?.count)! > 1){
            return
        }
        if(!isFocusSupported){
            return
        }
        let screenSize = self.bounds.size
        if let touchPoint = touches.first {
            let xPosition = touchPoint.location(in: self).x
            let yPosition = touchPoint.location(in: self).y
            let x = yPosition / screenSize.height
            let y = 1.0 - xPosition / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if((delegate) != nil){
                delegate!.onTouch(point: focusPoint)
                delegate!.onStartMove(point: CGPoint(x: xPosition, y: yPosition))
            }
            
            if(self.disableFocus){
                return
            }
            
            checkForRemoveFocusImageView()
            
            let height = self.focusImage?.size.height
            let widht = self.focusImage?.size.width
            imageViewForFocus = UIImageView.init(frame: CGRect(x: xPosition - (widht! / 2), y: yPosition - (height! / 2), width: 50, height: 50))
            imageViewForFocus.image = focusImage
            self.addSubview(imageViewForFocus)
            
            item.cancel()
            item = DispatchWorkItem.init(block: {
                self.checkForRemoveFocusImageView()
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if((event?.allTouches?.count)! > 1){
            return
        }
        if let touchPoint = touches.first {
            if((delegate) != nil){
                let xPosition = touchPoint.location(in: self).x
                let yPosition = touchPoint.location(in: self).y
                delegate!.onMove(point: CGPoint(x: xPosition, y: yPosition))
            }
            
        }
    }
    
    func checkForRemoveFocusImageView(){
        if(imageViewForFocus.image != nil){
            imageViewForFocus.removeFromSuperview()
            imageViewForFocus.image = nil
        }
    }

}
