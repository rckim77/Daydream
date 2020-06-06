//
//  Eatable.swift
//  Daydream
//
//  Created by Raymond Kim on 6/6/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import Foundation

protocol Eatable {
    var type: EateryType? { get }
    var name: String { get }
    var eatableImageUrl: String? { get }
    /// Redirect url (e.g., Yelp url redirects to browser)
    var eatableUrl: String? { get }
    /// Returns string indicating priciness (e.g., Yelp returns $, $$, $$$, etc.)
    var priceIndicator: String? { get }
}
