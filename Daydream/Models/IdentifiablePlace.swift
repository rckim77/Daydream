//
//  for.swift
//  Daydream
//
//  Created by Ray Kim on 10/16/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import Foundation
import GooglePlacesSwift

/// Lightweight wrapper around `GooglePlaceSwift` `Place` struct for certain SwiftUI
/// use cases (e.g., .sheet() presentation).
struct IdentifiablePlace: Identifiable {
    let id = UUID()
    let place: Place
}
