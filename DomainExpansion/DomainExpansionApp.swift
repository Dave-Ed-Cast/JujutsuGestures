//
//  DomainExpansionApp.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 09/05/25.
//

import SwiftUI

@main
struct DomainExpansionApp: App {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var appModel = AppModel()
    @State private var mudraRecognizer = MudraRecognizer.shared
    
    var body: some Scene {
        
        Group {
            WindowGroup(id: "WelcomeView") {
                WelcomeView()
                    .environment(mudraRecognizer)
                    .environment(appModel)
            }
            .defaultSize(width: 0.45, height: 0.35, depth: 0, in: .meters)
            .defaultWindowPlacement { content, context in
                let size = content.sizeThatFits(.unspecified)
                if let mudraView = context.windows.first(where: { $0.id == "MudraSelector"}) {
                    return WindowPlacement(.leading(mudraView), size: size)
                }
                return WindowPlacement(.none)
            }
            
            WindowGroup(id: "MudraSelector") {
                MudraSelector()
                    .environment(mudraRecognizer)
                    .environment(appModel)
                    .padding()
                    .onAppear { openWindow (id: "Progress") }
            }
            .defaultSize(width: 0.3, height: 0.275, depth: 0, in: .meters)
            .defaultWindowPlacement { content, context in
                let size = content.sizeThatFits(.unspecified)
                if let welcomeView = context.windows.first(where: { $0.id == "WelcomeView"}) {
                    return WindowPlacement(.trailing(welcomeView), size: size)
                }
                return WindowPlacement(.none)
            }
            
            WindowGroup(id: "Progress") {
                ProgressRingView(recognizer: mudraRecognizer)
                    .environment(mudraRecognizer)
                    .environment(appModel)
            }
            .windowStyle(.plain)
            .windowResizability(.contentSize)
            .persistentSystemOverlays(.hidden)
            .defaultWindowPlacement { content, context in
                let size = content.sizeThatFits(.unspecified)
                if let selectorView = context.windows.first(where: { $0.id == "MudraSelector"}) {
                    return WindowPlacement(.leading(selectorView), size: size)
                }
                return WindowPlacement(.none)
            }
            
            ImmersiveSpace(id: appModel.immersiveSpaceID) {
                ImmersiveView()
                    .onAppear {
                        appModel.immersiveSpaceState = .open
                        openWindow(id: "MudraSelector")
                        dismissWindow(id: "WelcomeView")
                    }
                    .onDisappear {
                        appModel.immersiveSpaceState = .closed
                        Task {
                            openWindow(id: "WelcomeView")
                            try? await Task.sleep(for: .seconds(0.1))
                            dismissWindow(id: "MudraSelector")
                        }
                    }
            }
            .immersionStyle(selection: .constant(.progressive(0.0...1.0, initialAmount: 1.0)), in: .progressive)
        }
        .environment(mudraRecognizer)
        .environment(appModel)
    }
}
