//
//  RandomCityButton.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct RandomCityButton: View {
    
    let onFetch: ((Place) -> Void)
    
    @State private var showLoadingSpinner = false
    @State private var showErrorAlert = false
    
    var body: some View {
        Button {
            showLoadingSpinner = true
            Task {
                do {
                    let place = try await API.PlaceSearch.fetchRandomCity()
                    showLoadingSpinner = false
                    onFetch(place)
                } catch {
                    showLoadingSpinner = false
                    showErrorAlert = true
                }
            }
        } label: {
            ZStack {
                Image(systemName: "shuffle")
                    .opacity(showLoadingSpinner ? 0 : 1)
                if showLoadingSpinner {
                    ProgressView()
                        .controlSize(.regular)
                        .tint(.primary)
                }
            }
        }
        .accessibilityLabel("Random City")
        .accessibilityIdentifier("random-city-button")
        .alert("Drats, something went wrong. Try again later!", isPresented: $showErrorAlert, presenting: nil) {}
    }
}
