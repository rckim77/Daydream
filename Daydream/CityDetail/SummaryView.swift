//
//  SummaryView.swift
//  Daydream
//
//  Created by Ray Kim on 11/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import FoundationModels
import SwiftUI

/// Displays streamed summary text from Apple Intelligence if available.
struct SummaryView: View {
    
    let cityText: String
    
    @State private var summary = ""
    @State private var isLoading = true
    
    var body: some View {
        if SystemLanguageModel.default.availability == .available {
            Group {
                if !summary.isEmpty {
                    Text(summary)
                        .transition(.opacity)
                } else if isLoading {
                    Text("This is placeholder text this is placeholder text placeholder text placeholder")
                        .redacted(reason: .placeholder)
                        .shimmer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.easeInOut, value: summary.count)
            .task(id: cityText) {
                summary = ""
                guard SystemLanguageModel.default.availability == .available else {
                    isLoading = false
                    return
                }
                isLoading = true
                // Empty responses and generation errors must not leave a permanent shimmer.
                defer {
                    if !Task.isCancelled {
                        isLoading = false
                    }
                }
                await streamSummary()
            }
        }
    }
    
    private func streamSummary() async {
        let instructions = """
            Answer concisely–the output must be no more than 2 short sentences. Do not output lists nor bullet points.
            Do not include any newlines. Your tone should be informative and impassioned. Always be factual. If you cannot
            fulfill the request, do not output anything in the response.
        """
        let session = LanguageModelSession(instructions: instructions)
        let prompt = """
            You are a tour guide for the city \(cityText). Tell me what makes this city unique and great for tourists in 2 
            sentences or fewer. Focus on its specific highlights. When referring to the city or its country, simply refer 
            to it as "it" to avoid repetition.
        """
        
        let stream = session.streamResponse(to: prompt)
        
        do {
            for try await chunk in stream {
                try Task.checkCancellation()
                // chunk.content is the entire partial snapshot so far,
                // so we just replace the text each time; animate so that
                // the height of this view grows smoothly
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        summary = chunk.content
                    }
                }
            }
        } catch is CancellationError {
            // SwiftUI cancels generation when this city is no longer visible.
        } catch {
            print("error handling streaming: \(error)")
        }
    }
}
