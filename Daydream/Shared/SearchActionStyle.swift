//
//  SearchActionStyle.swift
//  Daydream
//
//  Created by Ray Kim on 10/18/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct SearchActionStyle: ViewModifier {
    
    let shape: ButtonBorderShape
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .buttonStyle(.glass)
                .controlSize(.extraLarge)
                .buttonBorderShape(shape)
        } else {
            let base = content
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
                .controlSize(.extraLarge)
                .buttonBorderShape(shape)
            if shape == .circle {
                base
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            } else {
                base
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
    }
}
