//
//  SearchToolbar.swift
//  Daydream
//
//  Created by Ray Kim on 10/13/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI
import GooglePlacesSwift

struct SearchToolbar<Content: ToolbarContent>: ToolbarContent {
    
    var autocompleteTapped: (Place, UIImage?) -> Void
    var randomCityReceived: (Place, UIImage) -> Void
    var currentLocationTapped: () -> Void

    @ToolbarContentBuilder let additionalViews: Content
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            CitySearchButton(autocompleteTapped: autocompleteTapped)
        }
        .adaptsToVerticalToolbar()
        ToolbarSpacer(.fixed, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            RandomCityButton { place, image in
                randomCityReceived(place, image)
            }
        }
        .adaptsToVerticalToolbar()
        ToolbarItem(placement: .bottomBar) {
            CurrentCityButton(currentLocationTapped: currentLocationTapped)
        }
        additionalViews
    }
}

extension ToolbarContent {
    @ToolbarContentBuilder
    func adaptsToVerticalToolbar() -> some ToolbarContent {
        // Custom search labels and loading indicators fit either axis; opt them into the Duo bar.
        if #available(iOS 27.1, *) {
            self.axisBehavior(.verticalPreferred)
        } else {
            self
        }
    }
}
