//
//  HandTrackingSystem.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 09/05/25.
//

import RealityKit
import ARKit

/// A system that updates entities that have hand-tracking components, now visualizing each joint with a 3D axis.
struct HandTrackingSystem: System {
    
    static var arSession = ARKitSession()
    static let handTracking = HandTrackingProvider()
    static var latestLeftHand: HandAnchor?
    static var latestRightHand: HandAnchor?
    
    private static let recognizer = MudraRecognizer.shared
    
    /// When we first saw Gojo’s mudra in a continuous stream
    private static var mudraStartTime: TimeInterval?
    /// Whether we have already fired the “detection complete” event
    private static var mudraFired = false
    
    private static var mudraRecognizedAt: TimeInterval?
    
    
    init(scene: RealityKit.Scene) {
        Task { await Self.runSession() }
    }
    
    @MainActor
    static func runSession() async {
        do {
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            print("Error running providers: \(error.localizedDescription)")
        } catch let error {
            print("Unexpected error: \(error.localizedDescription)")
        }
        
        for await update in handTracking.anchorUpdates {
            switch update.anchor.chirality {
            case .left: latestLeftHand = update.anchor
            case .right: latestRightHand = update.anchor
            }
        }
    }
    
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    func update(context: SceneUpdateContext) {
        let hands = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        for entity in hands {
            guard let handComp = entity.components[HandTrackingComponent.self] else { continue }
            guard let anchor = (handComp.chirality == .left ? Self.latestLeftHand : Self.latestRightHand),
                  let skeleton = anchor.handSkeleton else { continue }
            
            for (jointName, jointEntity) in handComp.fingers {
                let jointTransform = skeleton.joint(jointName).anchorFromJointTransform
                jointEntity.setTransformMatrix(
                    anchor.originFromAnchorTransform * jointTransform,
                    relativeTo: nil
                )
            }
            
            let left = Self.latestLeftHand
            let right = Self.latestRightHand
            
            MudraRecognizer.shared.recognizeMudra(left: left, right: right)
        }
    }
}
