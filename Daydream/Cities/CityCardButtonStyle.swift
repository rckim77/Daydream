//
//  CityCardButtonStyle.swift
//  Daydream
//
//  Created by Ray Kim on 11/1/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct CityCardButtonStyle: ButtonStyle {
    
    let height: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .tint(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 3)
            .offset(y: configuration.isPressed ? 12 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
