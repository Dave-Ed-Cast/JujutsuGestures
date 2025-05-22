//
//  HakariRecognizer.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 14/05/25.
//

import ARKit

struct HakariRecognizer: MudraPoseRecognizer {
    
    func isPoseValid(left: HandAnchor?, right: HandAnchor?) -> Bool {
        
        guard
            let left = left, left.chirality == .left,
            let right = right, right.chirality == .right,
            let leftSkeleton = left.handSkeleton,
            let rightSkeleton = right.handSkeleton
        else { return false }
        
        let leftOrigin  = left.originFromAnchorTransform
        let rightOrigin = right.originFromAnchorTransform
        
        let contactThreshold: Float = 0.03
        let proximityThreshold: Float = 0.06
        
        let rightIndexTip = rightOrigin.worldPosition(from: rightSkeleton.indexTipTransform)
        let rightThumbTip = rightOrigin.worldPosition(from: rightSkeleton.thumbTipTransform)
        let leftLittleKnuckle = leftOrigin.worldPosition(from: leftSkeleton.littleFingerKnuckleTransform)
        
        let indexThumbDistance = simd_distance(rightIndexTip, rightThumbTip)
        let knuckleThumbDistance = simd_distance(leftLittleKnuckle, rightThumbTip)
        
        return indexThumbDistance < contactThreshold && knuckleThumbDistance < proximityThreshold
    }
}
