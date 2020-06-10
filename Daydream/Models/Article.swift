//
//  Article.swift
//  Daydream
//
//  Created by Raymond Kim on 6/9/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

struct Article: Codable {
    let webUrl: String
    let snippet: String
    let leadParagraph: String
}

struct ArticleResponse: Decodable {
    let response: ArticleCollection
}

struct ArticleCollection: Decodable {
    let docs: [Article]
}
