//
//  EateryCollection.swift
//  Daydream
//
//  Created by Raymond Kim on 6/4/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

struct EateryCollection: Decodable {
    let businesses: [Eatery]

    var hasSufficientEateries: Bool {
        return businesses.count > 2
    }
}
