//
//  Math.swift
//  Drummit
//
//  Created by Max Brayman on 10/24/26.
//

import Foundation

enum MathUtils {
    static func clamp(_ value: CGFloat, min left: CGFloat, max right: CGFloat) -> CGFloat {
        max(left, min(value, right))
    }
    
    static func interpolate(value: CGFloat, from: (CGFloat, CGFloat), to: (CGFloat, CGFloat)) -> CGFloat {
        to.0 + ((value - from.0) / (from.1 - from.0)) * (to.1 - to.0)
    }
}
