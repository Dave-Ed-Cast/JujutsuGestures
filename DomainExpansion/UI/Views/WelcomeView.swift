//
//  WelcomeView.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(MudraRecognizer.self) private var mudraRecognizer
    @Environment(AppModel.self) private var appModel
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        VStack {
            Spacer()
            MudraCycle()
            Spacer()
            VStack{
                Text("Welcome to App Name!")
                    .font(.title)
                Text("Expand your domain by simply using your hands. Mimic your selected sign and you prepare to open your domain!")
            }
            Spacer()
            ToggleImmersiveSpaceButton()
            Spacer()
        }
        .environment(mudraRecognizer)
        .environment(appModel)
        .frame(width: 350)
    }
}

#Preview {
    WelcomeView()
}
