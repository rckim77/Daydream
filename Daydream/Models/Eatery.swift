//
//  Eatery.swift
//  Daydream
//
//  Created by Raymond Kim on 3/17/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

enum EateryType {
    case yelp, google
}

struct Eatery: Codable, Equatable {
    let name: String
    let imageUrl: String
    let url: String
    let price: String // e.g., $, $$, $$$
}

extension Eatery: Eatable {
    var type: EateryType {
        .yelp
    }

    var eatableId: String? {
        nil
    }

    var eatableImageUrl: String? {
        imageUrl
    }

    var eatableUrl: String? {
        url
    }

    var priceIndicator: String? {
        price
    }
}
