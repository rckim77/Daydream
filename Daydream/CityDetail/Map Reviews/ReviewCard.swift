//
//  ReviewCard.swift
//  Daydream
//
//  Created by Ray Kim on 11/6/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import GooglePlacesSwift
import SwiftUI

struct ReviewCard: View {
    
    let review: Review
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            if let authorUrl = review.authorAttribution?.url {
                openURL(authorUrl)
            }
        } label: {
            VStack {
                HStack {
                    AsyncImage(url: review.authorAttribution?.photoUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                    } placeholder: {
                        ProgressView()
                    }
                    Text(review.authorAttribution?.displayName ?? "Author")
                        .font(.headline).bold()
                    Spacer()
                    ReviewStars(rating: review.rating)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                Text(review.text ?? "Sorry, couldn't load review!")
                    .font(.subheadline)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
            }
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(radius: 2)
        }
        .padding(.trailing, 16)
        .containerRelativeFrame(.horizontal)
    }
}

