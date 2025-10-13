//
//  SearchActionsView.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct SearchActionsView: View {
    
    var randomCityButtonTapped: () -> Void
    var feedbackButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            if #available(iOS 26.0, *) {
                Button {
                    // todo
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.glass)
                Button {
                    randomCityButtonTapped()
                } label: {
                    Image(systemName: "shuffle")
                        .padding(12)
                }
                .buttonStyle(.glass)
                Button {
                    feedbackButtonTapped()
                } label: {
                    Image(systemName: "questionmark")
                        .padding(12)
                }
                .clipShape(Circle())
                .buttonStyle(.glass)
            } else {
                Button {
                    // todo
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .tint(.white)
                Button {
                    randomCityButtonTapped()
                } label: {
                    Image(systemName: "shuffle")
                        .padding(8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .tint(.white)
                Button {
                    feedbackButtonTapped()
                } label: {
                    Image(systemName: "questionmark")
                        .padding(8)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.bordered)
                .tint(.white)
            }
        }
    }
}
