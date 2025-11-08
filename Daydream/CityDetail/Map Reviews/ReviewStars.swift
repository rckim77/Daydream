//
//  ReviewStars.swift
//  Daydream
//
//  Created by Ray Kim on 11/8/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

struct ReviewStars: View {
    /// 1.0 to 5.0
    let rating: Float
    
    private var starImages: [String] {
        var images = Array(repeating: "star", count: 5)
        var counter = rating
        
        while counter > 0 {
            let remainder = counter.truncatingRemainder(dividingBy: 1)
            if remainder != 0 {
                let starIndex = counter.rounded() - 1
                images[Int(starIndex)] = "star.leadinghalf.filled"
                counter -= remainder
            } else {
                let starIndex = counter.rounded() - 1
                images[Int(starIndex)] = "star.fill"
                counter -= 1
            }
        }
        
        return images
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<starImages.count, id: \.self) { index in
                Image(systemName: starImages[index])
                    .foregroundStyle(.yellow)
            }
        }
    }
}

#Preview {
    ReviewStars(rating: 1.0)
    ReviewStars(rating: 2.5)
    ReviewStars(rating: 5.0)
}

