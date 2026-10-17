//
//  ReviewSummaryCard.swift
//  Daydream
//
//  Created by Ray Kim on 11/8/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import GooglePlacesSwift
import SwiftUI

struct ReviewSummaryCard: View {

    let summary: ReviewSummary
    var scrollsText = false
    
    var body: some View {
        VStack {
            Group {
                if scrollsText {
                    ScrollView(.vertical) {
                        Text(summary.text ?? "No review text!")
                            .accessibilityIdentifier("map-review-summary")
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityIdentifier("map-review-text-scroll")
                } else {
                    Text(summary.text ?? "No review text!")
                        .accessibilityIdentifier("map-review-summary")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            if let disclosureText = summary.disclosureText {
                Text(disclosureText)
                    .accessibilityIdentifier("map-review-disclosure")
                    .font(.caption).italic()
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(radius: 2)
        }
        .padding(12)
    }
}
