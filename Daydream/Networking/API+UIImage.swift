//
//  API+UIImage.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit

extension API {
    enum Image {
        static func loadImage(url: URL) async throws -> UIImage? {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                throw APIError.imageDataError
            }
            
            return image
        }
    }
}
