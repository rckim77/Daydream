import SwiftUI

struct WishlistFilterLayout: Layout {
    var spacing: CGFloat
    var layoutDirection: LayoutDirection

    private struct Row {
        var items: [(index: Int, size: CGSize)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width: CGFloat
        if let proposedWidth = proposal.width, proposedWidth.isFinite {
            width = max(0, proposedWidth)
        } else {
            width = subviews.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
                + CGFloat(max(0, subviews.count - 1)) * spacing
        }
        let rows = rows(width: width, subviews: subviews)
        let height = rows.reduce(0) { $0 + $1.height } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in rows(width: bounds.width, subviews: subviews) {
            var offset: CGFloat = 0
            for item in row.items {
                let x = layoutDirection == .rightToLeft
                    ? bounds.maxX - offset - item.size.width
                    : bounds.minX + offset
                subviews[item.index].place(
                    at: CGPoint(x: x, y: y + (row.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
                offset += item.size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private func rows(width: CGFloat, subviews: Subviews) -> [Row] {
        var result: [Row] = []
        var row = Row()
        for index in subviews.indices {
            let idealWidth = subviews[index].sizeThatFits(.unspecified).width
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: min(idealWidth, width), height: nil))
            if !row.items.isEmpty, row.width + spacing + size.width > width {
                result.append(row)
                row = Row()
            }
            row.width += (row.items.isEmpty ? 0 : spacing) + size.width
            row.height = max(row.height, size.height)
            row.items.append((index, size))
        }
        if !row.items.isEmpty { result.append(row) }
        return result
    }
}
