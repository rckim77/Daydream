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

    var authorAbbreviated: String? {
        let nameParts = author.components(separatedBy: " ")
        guard let first = nameParts.first, let lastInitial = nameParts.last?.first else { return nil }
        return first + " " + String(lastInitial) + "."
    }

    init(_ author: String, _ rating: Int, _ review: String? = nil, _ authorUrl: String? = nil, _ authorProfileUrl: String? = nil) {
        self.author = author
        self.rating = rating
        self.review = review
        self.authorUrl = authorUrl
        self.authorProfileUrl = authorProfileUrl
    }
}
