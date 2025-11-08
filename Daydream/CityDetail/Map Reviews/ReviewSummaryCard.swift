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
    
    var body: some View {
        VStack {
            Text(summary.text ?? "No review text!")
                .font(.subheadline)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let disclosureText = summary.disclosureText {
                Text(disclosureText)
                    .font(.caption).italic()
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
        .containerRelativeFrame(.horizontal)
    }
}
