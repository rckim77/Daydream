//
//  Review.swift
//  Daydream
//
//  Created by Raymond Kim on 4/6/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

class Review: Reviewable {
    var author: String
    var rating: Int
    var review: String?
    var authorUrl: String?

    init(author: String, rating: Int, review: String? = nil, authorUrl: String? = nil) {
        self.author = author
        self.rating = rating
        self.review = review
        self.authorUrl = authorUrl
    }
}
