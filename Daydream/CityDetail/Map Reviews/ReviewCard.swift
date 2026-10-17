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
    var showsFullText = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            if let authorUrl = review.authorAttribution?.url {
                openURL(authorUrl)
            }
        } label: {
            VStack {
                let headerLayout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout())
                headerLayout {
                    HStack(alignment: .top) {
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
                                .fixedSize(horizontal: false, vertical: true)
                            if let dateText = review.relativePublishDateDescription {
                                Text(dateText)
                                    .font(.caption).italic()
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    if !dynamicTypeSize.isAccessibilitySize { Spacer() }
                    ReviewStars(rating: review.rating)
                }
                .padding(.top, 12)
                Text(review.text ?? "Sorry, couldn't load review!")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .lineLimit(showsFullText ? nil : 5)
                    .fixedSize(horizontal: false, vertical: showsFullText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                    .padding(.bottom, 14)
            }
            .padding(.horizontal, 12)
        }
        .accessibilityIdentifier("map-review-card")
        .buttonStyle(.plain)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(radius: 2)
        }
        .padding(.horizontal, 4)
    }
}

