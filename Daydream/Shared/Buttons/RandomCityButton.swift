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
    
    let onFetch: ((Place, UIImage) -> Void)
    
    @State private var showLoadingSpinner = false
    
    var body: some View {
        Button {
            showLoadingSpinner = true
            Task {
                do {
                    let (place, image) = try await API.PlaceSearch.fetchRandomCity()
                    showLoadingSpinner = false
                    onFetch(place, image)
                } catch {
                    showLoadingSpinner = false
                }
            }
        } label: {
            if showLoadingSpinner {
                ProgressView()
                    .controlSize(.regular)
                    .tint(.primary)
            } else {
                Image(systemName: "shuffle")
            }
        }
        .modifier(SearchActionStyle(shape: .capsule))
    }
}
