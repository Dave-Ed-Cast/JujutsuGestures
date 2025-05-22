//
//  MudraSelector.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import SwiftUI

struct MudraSelector: View {
    
    @Environment(MudraRecognizer.self) private var mudraRecognizer
    @Environment(AppModel.self) private var appModel
    
    @State private var selectedMudra: MudraNames? = .gojo
    
    var body: some View {
        VStack {
            Spacer()
            Text("Select one and look in front of you").font(.title3)
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    MudraButton(
                        selectedMudra: $selectedMudra,
                        mudra: .gojo,
                        imageName: "GojoMudra",
                        label: "Gojo"
                    )
                    MudraButton(
                        selectedMudra: $selectedMudra,
                        mudra: .sukuna,
                        imageName: "SukunaMudra",
                        label: "Sukuna"
                    )
                    
                    MudraButton(
                        selectedMudra: $selectedMudra,
                        mudra: .hakari,
                        imageName: "HakariMudra",
                        label: "Hakari"
                    )
                    MudraButton(
                        selectedMudra: $selectedMudra,
                        mudra: .jogo,
                        imageName: "JogoMudra",
                        label: "Jogo"
                    )
                }
            }
            
            Spacer()
            
            HStack {
                ToggleImmersiveSpaceButton()
                
                Button("Close domain", action: mudraRecognizer.removeDomain)
                
                .disabled(!mudraRecognizer.hasActiveDomain)
                .opacity(mudraRecognizer.hasActiveDomain ? 1.0 : 0.5)
            }
            
            Spacer()
        }
        .environment(mudraRecognizer)
    }
}

#Preview(windowStyle: .automatic) {
    MudraSelector()
}
