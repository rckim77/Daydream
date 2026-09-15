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
        Button {
            buttonTapped()
        } label: {
            Image(systemName: "house.fill")
                .frame(width: 24, height: 24)
        }
        .modifier(SearchActionStyle(shape: .circle))
        .frame(width: 54)
    }
}
