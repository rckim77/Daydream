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
            if shape == .circle {
                content
                    .buttonStyle(.glass)
                    .clipShape(Circle())
            } else {
                content
                    .buttonStyle(.glass)
            }
        } else {
            content
                .buttonStyle(.bordered)
                .tint(.white)
                .buttonBorderShape(shape)
                .controlSize(.extraLarge)
        }
    }
}
