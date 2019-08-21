//
//  Date+Custom.swift
//  CustomCamera
//
//  Created by Ivo Peric on 11/03/2019.
//  Copyright © 2019 Clover. All rights reserved.
//

import Foundation

extension Date{
    var nowLong: UInt64{
        return UInt64(Date.init().timeIntervalSince1970)
    }
}
