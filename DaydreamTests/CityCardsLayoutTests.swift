import SwiftUI
import Testing
import UIKit
@testable import Daydream

@MainActor
struct CityCardsLayoutTests {
    @Test("an incomplete final row and mixed card heights fit inside the grid")
    func gridMeasuresEveryRow() {
        let host = UIHostingController(rootView:
            CityCardsLayout(columns: 2, spacing: 20, layoutDirection: .leftToRight) {
                Color.clear.frame(height: 180)
                Color.clear.frame(height: 220)
                Color.clear.frame(height: 200)
                Color.clear.frame(height: 260)
                Color.clear.frame(height: 240)
            }
        )
        let size = host.sizeThatFits(in: CGSize(width: 700, height: 2000))
        #expect(size.width == 700)
        #expect(size.height == 760)
    }

    @Test("compact overlapping cards reserve space for the entire final card")
    func compactMeasuresOverlap() {
        let host = UIHostingController(rootView:
            CityCardsLayout(columns: 1, spacing: -60, layoutDirection: .leftToRight) {
                ForEach(0..<5) { _ in
                    Color.clear.frame(height: 220)
                }
            }
        )
        let size = host.sizeThatFits(in: CGSize(width: 320, height: 2000))
        #expect(size.width == 320)
        #expect(size.height == 860)
    }
}
