import SwiftUI

/// Keeps the same card instances (and their loaded photos) when the window changes width.
struct CityCardsLayout: Layout {
    var columns: Int
    var spacing: CGFloat
    var layoutDirection: LayoutDirection

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        let heights = rowHeights(width: width, subviews: subviews)
        return CGSize(width: width, height: heights.reduce(0, +) + CGFloat(max(0, heights.count - 1)) * spacing)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = cardWidth(in: bounds.width)
        let heights = rowHeights(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in heights.indices {
            for column in 0..<columns {
                let index = row * columns + column
                guard index < subviews.count else { break }
                let visualColumn = layoutDirection == .rightToLeft ? columns - 1 - column : column
                subviews[index].place(
                    at: CGPoint(x: bounds.minX + CGFloat(visualColumn) * (width + spacing), y: y),
                    anchor: .topLeading,
                    // Row heights position the next row; each SDK card keeps its intrinsic footer height.
                    proposal: ProposedViewSize(width: width, height: nil)
                )
            }
            y += heights[row] + spacing
        }
    }

    private func cardWidth(in width: CGFloat) -> CGFloat {
        max(0, (width - CGFloat(columns - 1) * spacing) / CGFloat(columns))
    }

    private func rowHeights(width: CGFloat, subviews: Subviews) -> [CGFloat] {
        let proposal = ProposedViewSize(width: cardWidth(in: width), height: nil)
        return stride(from: 0, to: subviews.count, by: columns).map { start in
            subviews[start..<min(start + columns, subviews.count)]
                .map { $0.sizeThatFits(proposal).height }.max() ?? 0
        }
    }
}
