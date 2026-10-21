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
                            HStack(spacing: 6) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .accessibilityHidden(true)
                                        .transition(.opacity)
                                }
                                Text(filter.rawValue)
                            }
                            .font(.subheadline.weight(.semibold))
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .tint(isSelected ? Color.accentColor : nil)
                        .accessibilityLabel(filter.name)
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                        .accessibilityIdentifier("wishlist-filter-\(filter.id)")
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .padding(.vertical, 8)
        .accessibilityIdentifier("wishlist-continent-filters")
    }
}
