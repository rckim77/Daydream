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
        content
            .buttonStyle(.glass)
            .controlSize(.extraLarge)
            .buttonBorderShape(shape)
    }
}
