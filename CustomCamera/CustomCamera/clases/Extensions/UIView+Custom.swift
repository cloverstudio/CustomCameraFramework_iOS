//
//  UIView+Custom.swift
//  CustomCamera
//
//  Created by Ivo Peric on 20/08/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import UIKit

extension UIView{
    var rightPoint: CGFloat{
        return self.frame.maxX
    }
    var leftPoint: CGFloat{
        return self.frame.minX
    }
    var topPoint: CGFloat{
        return self.frame.minY
    }
    var bottomPoint: CGFloat{
        return self.frame.maxY
    }
    var heightOfView: CGFloat{
        return self.frame.size.height
    }
    var widthOfView: CGFloat{
        return self.frame.size.width
    }
    
    func hideView(){
        self.isHidden = true
    }
    
    func showView(){
        self.isHidden = false
    }
    
    func roundView(){
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
    
    func cornerView(corner: CGFloat){
        self.layer.cornerRadius = corner
        self.clipsToBounds = true
    }
    
    func addBorderToView(width: CGFloat, color: UIColor){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func animateHideWithFade(toHide: Bool){
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.isHidden = toHide
        }
    }
    
    func animateShowWithFade(){
        if(self.isHidden){
            self.isHidden = false
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        })
    }
    
    func addGradientBorderToView(){
        let gradientLayer = CAGradientLayer()
        let rect = CGRect(x: 1, y: 1, width: self.frame.size.width - 2, height: self.frame.size.height - 2)
        gradientLayer.frame =  CGRect(origin: CGPoint(x:0.0, y:0.0), size: self.layer.bounds.size)
        gradientLayer.startPoint = CGPoint(x:0.0, y:0.5)
        gradientLayer.endPoint = CGPoint(x:0.3, y:0.5)
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.clear.cgColor]
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.height / 2).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer
        
        self.layer.addSublayer(gradientLayer)
    }
    
    func infiniteRoatation(){
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = 1
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        
        self.layer.add(rotateAnimation, forKey: "rotate")
    }
    
    func removeRotateAnimation(){
        self.layer.removeAnimation(forKey: "rotate")
    }
    
}
