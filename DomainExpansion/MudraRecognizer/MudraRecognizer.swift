//
//  MudraRecognizer.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

@Observable
final class MudraRecognizer {
    
    private var currentRecognizer: MudraPoseRecognizer
    private var selectedSukunaVersion: SukunaHandSignsVersions
    
    private var mudraRecognizedAt: TimeInterval?
    private var mudraFired = false
    private var domainAdded = false
    
    static let shared = MudraRecognizer()
    
    var selectedMudra: MudraNames {
        didSet {
            currentRecognizer = MudraRecognizer.makeRecognizer(for: selectedMudra)
            reset()
        }
    }
    
    var mudraStartTime: TimeInterval?
    var spawnerHolder: Entity? = nil
    var hasActiveDomain: Bool = false
    var activateMudra: (Bool, MudraNames) = (false, .gojo)
    
    private init() {
        self.selectedMudra = .gojo
        self.selectedSukunaVersion = .original
        self.currentRecognizer = Self.makeRecognizer(for: .gojo)
    }
    
    private static func makeRecognizer(for mudra: MudraNames) -> MudraPoseRecognizer {
        switch mudra {
        case .gojo: return GojoRecognizer()
        case .sukuna: return SukunaRecognizer()
        case .hakari: return HakariRecognizer()
        case .jogo: return JogoRecognizer()
        }
    }
    
    
    func setSukunaVersion(_ version: SukunaHandSignsVersions) { selectedSukunaVersion = version }
    
    func addDomain() async {
        guard activateMudra.0, !hasActiveDomain, !domainAdded else { return }
        
        domainAdded = true
        
        print("add domain!")
        let domainName = activateMudra.1
#if targetEnvironment(simulator)
        await gojoAnimation()
#elseif !targetEnvironment(simulator)
        switch domainName {
        case .gojo:
            await gojoAnimation()
        default: break
        }
#endif
        //            if let domainEntity = try? await Entity(named: domainName, in: realityKitContentBundle) {
        //                await domainSpawnerEntity.addChild(domainEntity)
        //                print("domain expansion: mallanm e nonnt")
        //                hasActiveDomain = true
        //            } else {
        //                print("idk what happened")
        //            }
        
    }
    
    func removeDomain() {
        guard hasActiveDomain else { return }
        guard let domain = spawnerHolder else { return }
        
        switch selectedMudra {
        case .gojo:
            domainAdded = false
            hasActiveDomain = false
            Task {
                let root = await fetchEntity("DefinitiveSborrSphere_1")
                
                guard let sphere = await root.findEntity(named: "DefinitiveSborrSphere_1"),
                      let sphereSounds = await fetchAudio(from: sphere),
                      let sound = sphereSounds.first
                else { return }
                
                //if everything worked correctly, here there should only be voidDomScene as child
                print("found sborr")
                
                let transitionSphere = await fetchEntity("TransitionSphere")
                await MainActor.run {
                    transitionSphere.isEnabled = false
                    transitionSphere.setScale(SIMD3(repeating: 0.5), relativeTo: nil)
                    transitionSphere.components.set(OpacityComponent(opacity: 0.0))
                    domain.addChild(transitionSphere)
                    transitionSphere.isEnabled = true
                }
                
                await fadeIn(entity: transitionSphere, duration: 1.2)

                if let animation = await fetchAnimation(from: sphere) {
                    
                    print("nell'if")
                    await MainActor.run {
                        sphere.isEnabled = true
                        domain.addChild(sphere)
                        
                        for child in domain.children {
                            if child.name != "DefinitiveSborrSphere_1" || child.name != "TransitionSphere" {
                                
                                domain.removeChild(child)
                                print("removed: \(child.name)")
                            }
                        }
                    }
                    
                    await fadeOut(entity: transitionSphere, duration: 1.0)
                    
                    Task.detached { await domain.removeChild(transitionSphere) }
                    
                    
                    await MainActor.run {
                        sphere.playAnimation(animation.repeat(count: 0))
                        sphere.playAudio(sound)
                    }
                    
                    await fadeOut(entity: sphere, duration: 1.5)
                    
                    //after this, only the sphere
                    try? await Task.sleep(for: .seconds(3))
                    await sphere.removeFromParent()
                    //and then only the root holder
                    
                }
            }
            
        default: break
        }
        
        
        
    }
    /// Call this every frame; passes both anchors.
    func recognizeMudra(left: HandAnchor?, right: HandAnchor?) {
        
        guard !activateMudra.0 else { return }
        
        let now = CFAbsoluteTimeGetCurrent()
        let isValid: Bool
        
        if selectedMudra == .sukuna, let sukuna = currentRecognizer as? SukunaRecognizer {
            isValid = sukuna.isPoseValid(left: left, right: right, version: selectedSukunaVersion)
        } else {
            isValid = currentRecognizer.isPoseValid(left: left, right: right)
        }
        guard isValid else {
            reset()
            return
        }
        
        if mudraStartTime == nil {
            mudraStartTime = now
            mudraFired = false
        }
        
        let elapsed = now - (mudraStartTime ?? now)
        print("⏱️ Mudra held for \(String(format: "%.2f", elapsed))s")
        
        if elapsed >= 2.0, !mudraFired {
            mudraFired = true
            print("🌀 \(selectedMudra) mudra fully recognized.")
            activateMudra = (true, selectedMudra)
            
        }
    }
    
    func reset() {
        mudraStartTime = nil
        mudraFired = false
        mudraRecognizedAt = nil
        activateMudra = (false, selectedMudra)
        domainAdded = false
    }
    
    func gojoAnimation() async {
        
        guard self.activateMudra.0 else { return }
        print("playing gojo animation")
        
        guard let scene = spawnerHolder else { return }
        
        //Fetch the domain
        let gojoDomain = await fetchEntity("GojoDomain")
        let voidDomScene = await fetchEntity("VoidDomScene")
        
        //MARK: First scene elements
        guard let firstScene = await gojoDomain.findEntity(named: "FirstScene"),
              let pipopopi = await firstScene.findEntity(named: "PIPOPOPI_1"),
              let cloud = await firstScene.findEntity(named: "Cloud"),
              let particleEmitter = await firstScene.findEntity(named: "ParticleEmitter")
        else { return }
        
        print("first scene: ok!")
        //MARK: Second scene elements
        guard let _ = await voidDomScene.findEntity(named: "SkySphere"),
              let inkScene = await voidDomScene.findEntity(named: "inkDrop1"),
              let firstDrop = await inkScene.findEntity(named: "firstDrop"),
              let secondDrop = await inkScene.findEntity(named: "firstDrop_1"),
              let thirdDrop = await inkScene.findEntity(named: "Plane"),
              let fourthDrop = await inkScene.findEntity(named: "Plane_1")
        else { return }
        
        print("second scene: ok!")
        
        await MainActor.run {
            pipopopi.isEnabled = false
            cloud.isEnabled = false
            inkScene.isEnabled = false
            particleEmitter.isEnabled = false
            
            firstDrop.isEnabled = false
            secondDrop.isEnabled = false
            thirdDrop.isEnabled = false
            fourthDrop.isEnabled = false
            
            scene.addChild(gojoDomain)
        }
                
        Task {
            try? await Task.sleep(for: .seconds(3.5))
            await MainActor.run {
                pipopopi.components.set(OpacityComponent(opacity: 0.0))
                pipopopi.isEnabled = true
                cloud.components.set(OpacityComponent(opacity: 0.0))
                cloud.isEnabled = true
                particleEmitter.components.set(OpacityComponent(opacity: 0.0))
                particleEmitter.isEnabled = true
                
                setUpOpacity(for: pipopopi)
                moveEntity(pipopopi)
                setUpOpacity(for: cloud)
                moveEntity(cloud)
            }
            
            try? await Task.sleep(for: .seconds(1))
            
            await MainActor.run {
                scaleEntity(pipopopi)
                scaleEntity(cloud)
                setUpOpacity(for: particleEmitter)
            }
            
            guard let audios = await fetchAudio(from: cloud), let firstAudio = audios.first else { return }
            print("found audio")
            await cloud.playAudio(firstAudio)
            
            guard let inkSounds = await fetchAudio(from: inkScene),
                  let firstSound = inkSounds.first,
                  let secondSound = inkSounds.last
            else { return }
            
            let transitionSphere = await fetchEntity("TransitionSphere")
            await MainActor.run {
                transitionSphere.isEnabled = false
                transitionSphere.components.set(OpacityComponent(opacity: 0.0))
                scene.addChild(transitionSphere)
                transitionSphere.isEnabled = true
            }
            //in the scene now there are the domain and the transition sphere
            
            try? await Task.sleep(for: .seconds(6.75))
            
            await fadeIn(entity: transitionSphere, duration: 0.5)
            print("after pipopopi scene")
            
            await MainActor.run {
                scene.removeChild(gojoDomain)
                scene.addChild(voidDomScene)
                inkScene.isEnabled = true
                scene.removeChild(transitionSphere)
            }
            
            //Here there is only void dom scene as child
            
            try? await Task.sleep(for: .seconds(3.5))
            await inkScene.playAudio(firstSound)
            
            await MainActor.run { firstDrop.isEnabled = true }
            try? await Task.sleep(for: .seconds(0.65))
            await inkScene.playAudio(secondSound)
            
            await MainActor.run { secondDrop.isEnabled = true }
            try? await Task.sleep(for: .seconds(0.65))
            await inkScene.playAudio(secondSound)
            
            await MainActor.run { thirdDrop.isEnabled = true }
            try? await Task.sleep(for: .seconds(0.65))
            await inkScene.playAudio(firstSound)
            
            await MainActor.run { fourthDrop.isEnabled = true }
            try? await Task.sleep(for: .seconds(0.65))
            
            hasActiveDomain = true
            
        }
    }
    
    @MainActor
    private func fetchAnimation(from entity: Entity) -> AnimationResource? {
        guard let animationLibrary = entity.components[AnimationLibraryComponent.self] else {
            print("❌ No AnimationLibraryComponent found in entity \(entity.name)")
            return nil
        }
        
        if let animations = animationLibrary.animations.first?.value {
            
            return animations
        } else {
            print("No animations found in AnimationLibraryComponent")
            return nil
        }
    }
    
    private func fetchEntity(_ name: String) async -> Entity {
        return try! await Entity(named: name, in: realityKitContentBundle)
    }
    
    @MainActor
    private func fetchAudio(from entity: Entity) -> [AudioResource]? {
        guard let audioLibrary = entity.components[AudioLibraryComponent.self] else {
            print("❌ No AudioLibraryComponent found in entity \(entity.name)")
            return nil
        }
        
        let audioResources = Array(audioLibrary.resources.values)
        if audioResources.isEmpty {
            print("⚠️ AudioLibraryComponent is present, but contains no audio resources.")
            return nil
        }
        
        
        
        return audioResources
    }
    private func setUpOpacity(for entity: Entity, decrease: Bool = false, transition: Bool = false) {
        if !decrease {
            Task {
                var currentOpacity: Float = 0.0
                while currentOpacity < 1.0 {
                    try? await Task.sleep(nanoseconds: transition ? 10_000_000 : 50_000_000) // 50ms per frame
                    currentOpacity += transition ? 0.05 : 0.025
                    if currentOpacity > 1.0 { currentOpacity = 1.0 }
                    let newOpacity = OpacityComponent(opacity: currentOpacity)
                    await MainActor.run {
                        entity.components.set(newOpacity)
                    }
                }
            }
        } else if decrease {
            Task {
                var currentOpacity: Float = 1.0
                while currentOpacity > 0.0 { // ✅ Fix here
                    try? await Task.sleep(nanoseconds: transition ? 10_000_000 : 50_000_000) // 50ms per frame
                    currentOpacity -= 0.05
                    print("current opacity: \(currentOpacity)")
                    if currentOpacity < 0.0 { currentOpacity = 0.0 }
                    let newOpacity = OpacityComponent(opacity: currentOpacity)
                    await MainActor.run {
                        entity.components.set(newOpacity)
                    }
                }
            }
        }
    }
    
    private func scaleEntity(_ entity: Entity) {
        Task { @MainActor in
            while true {
                try? await Task.sleep(nanoseconds: 30_000_000) // 50ms per frame
                entity.scale.z += 0.05
            }
        }
    }
    private func moveEntity(_ entity: Entity) {
        Task { @MainActor in
            while true {
                try? await Task.sleep(nanoseconds: 50_000_000)
                entity.position.z -= 0.05
            }
        }
    }
    
    /// Replaces your setUpOpacity(for:decrease:transition:) for fade-out only.
    /// Call it like: `await fadeOut(entity: transitionSphere, duration: 1.0)`
    @MainActor
    private func fadeOut(entity: Entity, duration: TimeInterval) async {
        // how many steps? one every 50ms
        let stepDuration = 0.05
        let steps = Int(duration / stepDuration)
        var opacity: Float = 1.0
        for _ in 0..<steps {
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            opacity -= 1.0 / Float(steps)
            opacity = max(0, opacity)
            entity.components.set(OpacityComponent(opacity: opacity))
        }
        // make sure it’s exactly zero at the end
        entity.components.set(OpacityComponent(opacity: 0.0))
    }
    
    /// Fades an entity in from 0 → 1 over the given duration.
    /// Call it like: `await fadeIn(entity: someEntity, duration: 1.0)`
    @MainActor
    private func fadeIn(entity: Entity, duration: TimeInterval) async {
        // start fully transparent
        entity.components.set(OpacityComponent(opacity: 0.0))
        
        // how often to step (50 ms gives 20 steps/sec)
        let stepDuration = 0.05
        let steps = Int(duration / stepDuration)
        
        var opacity: Float = 0.0
        for _ in 0..<steps {
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            opacity += 1.0 / Float(steps)
            opacity = min(1.0, opacity)
            entity.components.set(OpacityComponent(opacity: opacity))
        }
        // ensure it ends exactly at 1.0
        entity.components.set(OpacityComponent(opacity: 1.0))
    }
}
