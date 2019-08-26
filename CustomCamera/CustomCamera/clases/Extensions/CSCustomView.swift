//
//  CustomView.swift
//  eaZymoney
//
//  Created by Ivo Peric on 06/09/2018.
//  Copyright © 2018 Zenith. All rights reserved.
//

import UIKit

open class CSCustomView: UIView {
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    private func loadNib() {
        
        var nibName = String(describing: type(of: self))
        
        let bundle = Bundle(for: self.classForCoder)
        
        if(bundle.path(forResource: nibName, ofType: "nib") == nil){
            let parentClassName = NSStringFromClass(self.superclass!).components(separatedBy: ".").last
            nibName = parentClassName!
        }
        
        let view = bundle.loadNibNamed(nibName, owner: self, options: nil)!.first as! UIView
        
        view.frame = self.bounds;
        view.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(view)
        
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        customInit()
        
    }
    
    open func customInit() {
        
    }
    
}
