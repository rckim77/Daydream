import SwiftUI

struct WishlistContinentFilterBar: View {
    @Binding var selection: WishlistContinentFilter

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(WishlistContinentFilter.allCases) { filter in
                    let isSelected = selection == filter
                    Button {
                        selection = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 16)
                            .frame(minHeight: 44)
                            .foregroundStyle(isSelected ? Color(uiColor: .systemBackground) : Color.primary)
                            .background(isSelected ? Color.primary : Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                            .overlay {
                                Capsule().strokeBorder(Color.primary.opacity(isSelected ? 0 : 0.12), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(filter.name)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityIdentifier("wishlist-filter-\(filter.id)")
                }
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20, for: .scrollContent)
        .padding(.vertical, 8)
        .accessibilityIdentifier("wishlist-continent-filters")
    }
}
