//
//  Review.swift
//  Daydream
//
//  Created by Raymond Kim on 4/6/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

struct Review: Codable {
    let authorName: String
    let rating: Int
    let text: String?
    let authorUrl: String?
    let profilePhotoUrl: String?
}
