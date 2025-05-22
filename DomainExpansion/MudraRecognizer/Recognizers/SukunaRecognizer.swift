//
//  SukunaRecognizer.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 14/05/25.
//

import ARKit

/// Sukuna's handsign is quite complex anatomically speaking.
/// Therefore this a simplified and original versions are provided
/// The user will be asked which one to perform in the UI.
struct SukunaRecognizer: MudraPoseRecognizer {
    
    func isPoseValid(left: HandAnchor?, right: HandAnchor?) -> Bool {
        return isPoseValid(left: left, right: right, version: .original)
    }
    
    func isPoseValid(left: HandAnchor?, right: HandAnchor?, version: SukunaHandSignsVersions) -> Bool {
        guard
            let L = left,   L.chirality == .left,
            let R = right,  R.chirality == .right,
            let LS = L.handSkeleton,
            let RS = R.handSkeleton
        else { return false }
        
        /// This recognition is the same for the other hand. So let's consider the left.
        let R2L = matrix_multiply(simd_inverse(L.originFromAnchorTransform), R.originFromAnchorTransform)
        
        let leftThumbPosition = LS.thumbTipTransform.position
        let leftMiddlePosition = LS.middleTipTransform.position
        
        let threshold: Float = 0.033
        
        let thumbTipsDistance = R2L.distance(from: leftThumbPosition, toJoint: RS.thumbTipTransform)
        let middleTipsDistance = R2L.distance(from: leftMiddlePosition, toJoint: RS.middleTipTransform)
        
        switch version {
        case .simplified:
            // Thumb and middle need to match
            return thumbTipsDistance < threshold && middleTipsDistance < threshold
            
            // Thumb, middle and ring must match
        case .original:
            let leftRingPosition = LS.ringTipTransform.position
            let ringTipsDistance = R2L.distance(from: leftRingPosition, toJoint: RS.ringTipTransform)
            
            return thumbTipsDistance < threshold && middleTipsDistance < threshold && ringTipsDistance < threshold
        }
        
    }
    
}
