//
//  ProgressRingView.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 15/05/25.
//

import SwiftUI

import SwiftUI

struct ProgressRingView: View {
    @Bindable var recognizer: MudraRecognizer
    
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var now = CFAbsoluteTimeGetCurrent()
    @State private var isCompleted = false
    
    var completionRatio: Double {
        guard let start = recognizer.mudraStartTime else { return 0.0 }
        let elapsed = now - start
        return min(elapsed / 2.0, 1.0)
    }
    
    var shouldShow: Bool {
        recognizer.mudraStartTime != nil && !recognizer.activateMudra.0 && !isCompleted
    }
    
    var body: some View {
        VStack(spacing: 25) {
            if isCompleted {
                Group {
                    Text("Activated!")
                    Text("Keep holding it!")
                }
                .font(.largeTitle.bold())
                .foregroundColor(.green)
                .transition(.scale.combined(with: .opacity))
                
            } else {
                Text("Hold the hand sign...!")
                    .font(.title)
                    .fontDesign(.rounded)
                ZStack {
                    if shouldShow {
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 10)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .trim(from: 0, to: completionRatio)
                            .stroke(.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 100, height: 100)
                            .animation(.easeOut(duration: 0.1), value: completionRatio)
                        
                        Text("\(Int(completionRatio * 100))%")
                            .foregroundStyle(.white)
                            .font(.title2.bold())
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            now = CFAbsoluteTimeGetCurrent()
            if completionRatio >= 1.0 && !isCompleted {
                isCompleted = true
                timer.upstream.connect().cancel()
            }
        }
        .onChange(of: MudraRecognizer.shared.hasActiveDomain) { oldValue, newValue in
            if oldValue && !newValue {
                reset()
            }
        }
    }
    
    private func reset() {
        now = CFAbsoluteTimeGetCurrent()
        isCompleted = false
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    }
}

#Preview(windowStyle: .plain) {
    struct MockRingContainer: View {
        @State private var mockRecognizer = MudraRecognizer.shared
        
        var body: some View {
            ZStack {
                ProgressRingView(recognizer: mockRecognizer)
                    .onAppear {
                        // Simulate mudra start time in the past to create a visual fill
                        let simulatedStart = CFAbsoluteTimeGetCurrent() - 1.0 // 50% progress
                        mockRecognizer.mudraStartTime = simulatedStart
                        mockRecognizer.activateMudra = (false, .gojo)
                        
                    }
            }
            .padding()
        }
    }
    
    return MockRingContainer()
}
