//
//  FeedbackSheet.swift
//  Daydream
//
//  Created by Ray Kim on 11/9/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct FeedbackSheet: View {
    
    @State private var showAlert = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                if let url = URL(string: "mailto:daydreamiosapp@gmail.com") {
                    openURL(url)
                }
            } label: {
                Text("Got feedback? Email me!")
                    .padding(4)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 16)
            Button("Clear cached data") {
                Task {
                    ImageCache.shared.clear()
                    PlacesCache.shared.clear()
                }
                showAlert = true
            }
            .font(.subheadline).bold()
            .foregroundStyle(.red)
            .padding(.bottom, 48)
            Text("Shoutout to YH for app feedback!")
                .font(.caption)
                .foregroundStyle(.gray)
            Text(alertMessage)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .alert("Cached data cleared!", isPresented: $showAlert) {}
    }
}
