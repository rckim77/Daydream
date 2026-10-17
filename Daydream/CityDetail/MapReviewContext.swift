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
    @Published var selectedName: String
    @Published var isLoading = false
    @Published var loadFailed = false

    var displayedReviewSummary: ReviewSummary? {
        #if DEBUG
        if ProcessInfo.processInfo.environment["DAYDREAM_UI_CAPTURE_REVIEW_FALLBACK"] == "1" { return nil }
        #endif
        return place?.reviewSummary
    }

    init(place: Place?) {
        self.place = place
        selectedName = place?.displayName ?? "Place details"
    }
}
