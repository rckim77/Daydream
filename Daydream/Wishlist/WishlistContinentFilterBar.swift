import SwiftUI

struct WishlistContinentFilterBar: View {
    @Binding var selection: WishlistContinentFilter
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView(.horizontal) {
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(WishlistContinentFilter.allCases) { filter in
                        let isSelected = selection == filter
                        Button {
                            withAnimation(reduceMotion ? nil : .smooth(duration: 0.28)) {
                                selection = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .fixedSize(horizontal: true, vertical: false)
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
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .padding(.vertical, 8)
        .accessibilityIdentifier("wishlist-continent-filters")
    }
}
