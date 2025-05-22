//
//  SIMD4.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 09/05/25.
//

import Foundation
import simd

extension SIMD4 {
    
    /// Used to return a coordinates in SIMD3 format.
    /// Specifically used for world coordinates.
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}
