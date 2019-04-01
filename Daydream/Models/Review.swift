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
    var authorProfileUrl: String?

    init(_ author: String, _ rating: Int, _ review: String? = nil, _ authorUrl: String? = nil, _ authorProfileUrl: String? = nil) {
        self.author = author.abbreviated
        self.rating = rating
        self.review = review
        self.authorUrl = authorUrl
        self.authorProfileUrl = authorProfileUrl
    }

}
