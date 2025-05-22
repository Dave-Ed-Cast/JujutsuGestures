//
//  MudraCycle.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import SwiftUI

struct MudraCycle: View {
    @State private var currentIndex = 0
    @State private var nextIndex = 1
    @State private var animateOffset = false
    
    private let images = ["GojoMudra", "SukunaMudra", "HakariMudra", "JogoMudra"]
    private let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image(images[currentIndex])
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: animateOffset ? -250 : 0)
                .animation(.easeInOut(duration: 0.5), value: animateOffset)
            
            Image(images[nextIndex])
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: animateOffset ? 0 : 250)
            
                .frame(width: 250, height: 250)
                .clipped()
                .onReceive(timer) { _ in
                    animateOffset = true
                    currentIndex = nextIndex
                    nextIndex = (nextIndex + 1) % images.count
                    animateOffset = false
                }
                .animation(.easeInOut(duration: 0.5), value: animateOffset)
        }
        .frame(width: 150, height: 150)
    }
}
