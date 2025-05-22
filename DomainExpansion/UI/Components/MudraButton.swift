//
//  MudraButton.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import SwiftUI

struct MudraButton: View {
    
    @Environment(MudraRecognizer.self) private var mudraRecognizer
    
    @Binding var selectedMudra: MudraNames?
    
    @State private var showPopUp: Bool = false
    @State var version: SukunaHandSignsVersions = .original
    
    let mudra: MudraNames
    let imageName: String
    let label: String
    
    let size = 110.0
    
    private var isSelected: Bool { selectedMudra == mudra }
    
    var body: some View {
        
        VStack(spacing: 10) {
            Button {
                selectedMudra = mudra
                mudra == .sukuna ? showPopUp = true : ()
                mudraRecognizer.selectedMudra = mudra
            } label: {
                VStack(alignment: .center) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .background(
                            ZStack {
                                if isSelected {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [.white, .clear]),
                                                center: .center,
                                                startRadius: 70,
                                                endRadius: 57
                                            )
                                        )
                                        .frame(width: size + 20, height: size + 20)
                                }
                            }
                        )
                }
                .frame(width: size + 10, height: size + 10)
            }
            .background(.clear)
            .buttonStyle(.plain)
            
            Text(label)
        }
        .popover(isPresented: $showPopUp) {
            VStack {
                Text(version == .original ? "The hand sign is exactly like the anime" : "The hand sign can be rough")
                    .font(.caption)

                Picker(selection: $version) {
                    Text("Original").tag(SukunaHandSignsVersions.original)
                    Text("Simplified").tag(SukunaHandSignsVersions.simplified)
                } label: {
                    Text("Select your preferred version")
                }
                .pickerStyle(.palette)
            }
            .frame(width: 300)
            .padding()
        }
        .onChange(of: version) { _, newValue in
            print("changed version: \(newValue)")
            mudraRecognizer.setSukunaVersion(newValue)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedMudra)
        .padding(5)
    }
}
