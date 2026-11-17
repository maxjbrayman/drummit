//
//  ScannerLoadingView.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI
import Combine

struct ScannerLoadingView: View {
    private let phrases = ["Analyzing image", "Finding gear", "Reading logos", "Calculating sizes", "Checking finishes", "Counting drums", "Spotting cymbals", "Matching models", "Finding brands", "Tuning"]
    @State private var remainingPhrases: [String] = []
    @State private var currentPhrase: String = ""
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    init() {
        self.remainingPhrases = phrases
    }
    
    var body: some View {
        HStack {
            LoadingSpinner()
            ZStack {
                ForEach(phrases, id: \.self) { phrase in
                    Text(phrase).hidden()
                }
                Text(currentPhrase)
                    .id(currentPhrase)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .top)
                        ).combined(with: .opacity)
                    )
                    .frame(alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md).fill(.cardBackground).shadow(radius: 1.5)
        )
        .onReceive(timer) { _ in
            withAnimation {
                setNextPhrase()
            }
        }
        .onAppear {
            setNextPhrase()
        }
    }
    
    private func setNextPhrase() {
        if remainingPhrases.isEmpty {
            remainingPhrases = phrases
        }
        
        var nextIndex = Int.random(in: 0..<remainingPhrases.count)
        while remainingPhrases[nextIndex] == currentPhrase {
            nextIndex = Int.random(in: 0..<remainingPhrases.count)
        }
        
        currentPhrase = remainingPhrases.remove(at: nextIndex)
    }
}
