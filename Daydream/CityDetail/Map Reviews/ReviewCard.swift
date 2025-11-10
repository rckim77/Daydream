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
                            .frame(width: 32, height: 32)
                    } placeholder: {
                        ProgressView()
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(review.authorAttribution?.displayName ?? "Author")
                            .font(.subheadline).bold()
                            .foregroundStyle(.black)
                            .minimumScaleFactor(0.9)
                        if let dateText = review.relativePublishDateDescription {
                            Text(dateText)
                                .font(.caption).italic()
                                .foregroundStyle(.black)
                        }
                    }
                    Spacer()
                    ReviewStars(rating: review.rating)
                }
                .padding(.top, 12)
                Text(review.text ?? "Sorry, couldn't load review!")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.9)
                    .lineLimit(5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                    .padding(.bottom, 14)
            }
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(radius: 2)
        }
        .padding(.horizontal, 4)
        .containerRelativeFrame(.horizontal)
    }
}

