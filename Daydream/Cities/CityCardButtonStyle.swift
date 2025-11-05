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
    let horizontalSizeClass: UserInterfaceSizeClass?
    
    private var pressedOffset: CGFloat {
        horizontalSizeClass == .compact ? 12 : 24
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .tint(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .offset(y: configuration.isPressed ? pressedOffset : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
