//
//  MapReviewContext.swift
//  Daydream
//
//  Created by Ray Kim on 11/9/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import Combine
import GooglePlacesSwift
import UIKit

final class MapReviewContext: ObservableObject {
    @Published var place: Place?

    init(place: Place?) {
        self.place = place
    }
}
