//
//  SIMD3.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import Foundation
import simd

/// An extension of `SIMD3<Float>` providing geometric utilities for 3D vector operations.
///
/// These methods are particularly useful for spatial reasoning in hand tracking applications,
/// such as measuring angles between joints or determining gesture directionality in a 3D space.
///
/// The functions assume right-handed coordinate system conventions, as typically used in ARKit and visionOS.
extension SIMD3 where Scalar == Float {
    
    /// Calculates the angle between two 3D vectors in **degrees**.
    ///
    /// Useful for determining angular relationships between joints or bones, such as the flexion
    /// of a finger or the divergence between finger directions.
    ///
    /// - Parameter other: The vector to compute the angle to.
    /// - Returns: The angle between `self` and `other` in degrees, ranging from 0° to 180°.
    func angle(to other: SIMD3<Float>) -> Float {
        let dot = simd_dot(self, other)
        let magnitude = simd_length(self) * simd_length(other)
        let angleRad = acos(simd_clamp(dot / magnitude, -1, 1))
        return angleRad * 180 / .pi
    }
    
    /// Computes the absolute horizontal angle between two points projected onto the **XY plane**.
    ///
    /// Ideal for estimating lateral hand movement or finger pointing direction relative to the X-axis,
    /// when vertical (Z-axis) variation is not relevant or should be ignored.
    ///
    /// - Parameter other: The target point in 3D space to measure the direction to.
    /// - Returns: The **absolute** angle in degrees, ranging from 0° to 180°, between the projected direction and the X-axis.
    func horizontalAngle(to other: SIMD3<Float>) -> Float {
        let vec = self - other
        return abs(atan2(vec.y, vec.x) * 180 / .pi)
    }
}
