//
//  FeedbackButton.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct FeedbackButton: View {
    
    let buttonTapped: () -> Void
    
    var body: some View {
        Button("Help and Feedback", systemImage: "questionmark") {
            buttonTapped()
        }
        .accessibilityIdentifier("feedback-button")
    }
}
