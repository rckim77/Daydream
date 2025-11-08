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
                .font(.headline)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let disclosureText = summary.disclosureText {
                Text(disclosureText)
                    .font(.subheadline).italic()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(12)
    }
}
