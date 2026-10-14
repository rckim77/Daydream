//
//  HomeButton.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct HomeButton: View {
    
    let buttonTapped: () -> Void
    
    var body: some View {
        Button("Home", systemImage: "house.fill") {
            buttonTapped()
        }
        .accessibilityIdentifier("home-button")
    }
}
