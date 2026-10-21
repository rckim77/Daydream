import SwiftUI

struct WishlistButton: View {
    let cityName: String
    let isSaved: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isSaved ? Color.pink : Color.primary)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove \(cityName) from wishlist" : "Save \(cityName) to wishlist")
        .accessibilityValue(isSaved ? "Saved" : "Not saved")
        .accessibilityIdentifier("wishlist-toggle-\(cityName)")
        .sensoryFeedback(.selection, trigger: isSaved)
    }
}
