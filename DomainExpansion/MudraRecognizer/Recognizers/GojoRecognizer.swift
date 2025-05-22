//
//  GojoRecognizer.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 14/05/25.
//

import ARKit

struct GojoRecognizer: MudraPoseRecognizer {
    
    func isPoseValid(left: HandAnchor?, right: HandAnchor?) -> Bool {
        guard
            let anchor = right,
            anchor.chirality == .right,
            let joints = anchor.handSkeleton
        else {
            return false
        }
        
        let idxTipLocal = joints.indexTipTransform.position
        let idxPIPLocal = joints.indexIntermediateTipTransform.position
        let midTipLocal = joints.middleTipTransform.position
        let midPIPLocal = joints.middleIntermediateTipTransform.position
        
        let idxDir = simd_normalize(idxTipLocal - idxPIPLocal)
        let midDir = simd_normalize(midTipLocal - midPIPLocal)
        
        let cosTheta = simd_dot(idxDir, midDir)
        let angleDeg = acos(simd_clamp(cosTheta, -1, 1)) * (180 / .pi)
        
        let wrapDistance = simd_distance(midTipLocal, idxPIPLocal)
        
        let maxAngleThreshold: Float = 50
        let maxWrapDistance: Float = 0.031
        
        return angleDeg < maxAngleThreshold &&
        wrapDistance < maxWrapDistance
    }
}
