import SwiftUI

struct WishlistButton: View {
    let cityName: String
    let isSaved: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(isSaved ? Color.pink : Color.white)
                .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove \(cityName) from wishlist" : "Save \(cityName) to wishlist")
        .accessibilityValue(isSaved ? "Saved" : "Not saved")
        .accessibilityIdentifier("wishlist-toggle-\(cityName)")
        .sensoryFeedback(.selection, trigger: isSaved)
    }
}
