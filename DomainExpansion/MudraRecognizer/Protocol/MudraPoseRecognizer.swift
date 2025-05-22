//
//  MudraPoseRecognizer.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 14/05/25.
//

import ARKit

/// A protocol that defines a common interface for validating hand poses (mudras).
///
/// Conforming types implement logic to determine whether a pair of detected hands
/// match a specific gesture or configuration.
protocol MudraPoseRecognizer {
    
    /// Determines whether the provided left and right hand anchors represent a valid pose.
    ///
    /// - Parameters:
    ///   - left: The left hand anchor.
    ///   - right: The right hand anchor.
    /// - Returns: `true` if the pose is valid according to the recognizer's criteria.
    func isPoseValid(left: HandAnchor?, right: HandAnchor?) -> Bool
}

private extension MudraPoseRecognizer {
    
    /// Convenience overload that delegates to the simpler `isPoseValid` method, ignoring versioning.
    ///
    /// This method is used internally by `SukunaRecognizer` that support pose variants,
    /// such as simplified and original version.
    ///
    /// - Parameters:
    ///   - left: The left hand anchor.
    ///   - right: The right hand anchor.
    ///   - version: A version of the pose either simplified or original
    /// - Returns: The result of the non-versioned `isPoseValid` method.
    func isPoseValid(left: HandAnchor?, right: HandAnchor?, version: SukunaHandSignsVersions) -> Bool {
        return isPoseValid(left: left, right: right)
    }
}
