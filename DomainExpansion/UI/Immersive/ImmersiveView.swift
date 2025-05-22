//
//  ImmersiveView.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 09/05/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @Environment(MudraRecognizer.self) private var mudraRecognizer
    
    let domainSpawner: Entity = .init()
    
    var body: some View {
        
        RealityView { content in
            content.add(domainSpawner)
            mudraRecognizer.spawnerHolder = domainSpawner
#if !targetEnvironment(simulator)
            addHands(in: content)
#endif
        }
#if targetEnvironment(simulator)
        .onAppear { mudraRecognizer.activateMudra.0 = true }
#endif
        .onChange(of: mudraRecognizer.activateMudra.0) {
            guard !mudraRecognizer.hasActiveDomain else { return }
            print("cast domain")
            Task { @MainActor in
                await mudraRecognizer.addDomain()
            }
        }
    }
    
    @MainActor
    func addHands(in content: any RealityViewContentProtocol) {
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        
        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
}
