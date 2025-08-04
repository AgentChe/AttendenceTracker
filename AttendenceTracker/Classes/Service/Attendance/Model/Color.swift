//
//  Color.swift
//  AttendenceTracker
//
//  Created by Андрей Чернышев on 30.07.2025.
//

import UIKit

struct Color: Codable {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    
    var uiColor: UIColor {
        UIColor(integralRed: r, green: g, blue: b)
    }
}
