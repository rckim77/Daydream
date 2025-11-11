//
//  TopScrollTransition.swift
//  Daydream
//
//  Created by Ray Kim on 11/6/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct TopScrollTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollTransition { content, phase in
                content
                    .opacity(phase == .identity || phase == .bottomTrailing ? 1 : 0)
                    .scaleEffect(phase == .identity || phase == .bottomTrailing ? 1 : 0.75)
            }
    }
}
