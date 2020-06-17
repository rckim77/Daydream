//
//  API+UIImage.swift
//  Daydream
//
//  Created by Raymond Kim on 6/17/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import Combine

extension API {
    enum Image {
        /// Note: Returns on the main queue and with errors erased for easier binding.
        static func loadImage(url: URL) -> AnyPublisher<UIImage?, Never> {
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: UIImage())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}
