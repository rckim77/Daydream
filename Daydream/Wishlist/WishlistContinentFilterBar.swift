import SwiftUI

struct WishlistContinentFilterBar: View {
    @Binding var selection: WishlistContinentFilter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            WishlistFilterLayout(spacing: 12, layoutDirection: layoutDirection) {
                ForEach(WishlistContinentFilter.allCases) { filter in
                    let isSelected = selection == filter
                    Button {
                        withAnimation(reduceMotion ? nil : .smooth(duration: 0.28)) {
                            selection = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .tint(isSelected ? Color.accentColor : nil)
                    .accessibilityLabel(filter.name)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityIdentifier("wishlist-filter-\(filter.id)")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .accessibilityIdentifier("wishlist-continent-filters")
    }
}
