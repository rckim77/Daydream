//
//  GettingStartedTip.swift
//  Daydream
//
//  Created by Ray Kim on 11/6/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import TipKit

struct GettingStartedTip: Tip {
    var title: Text {
        Text("Getting Started")
    }
    
    var message: Text? {
        Text("Explore a city, search for your own, or tap a heart to save it for later.")
    }
}
