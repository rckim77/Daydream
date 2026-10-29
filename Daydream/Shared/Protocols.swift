//
//  Protocols.swift
//  Daydream
//
//  Created by Raymond Kim on 3/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import CoreLocation

protocol ImageViewFadeable {
    func fadeInImage(_ image: UIImage, forImageView imageView: UIImageView)
}

extension ImageViewFadeable {
    func fadeInImage(_ image: UIImage, forImageView imageView: UIImageView) {
        imageView.alpha = 0
        imageView.image = image
        UIView.animate(withDuration: 0.5) {
            imageView.alpha = 1
        }
    }
}
