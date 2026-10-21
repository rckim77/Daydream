import SwiftUI

struct WishlistButton: View {
    let cityName: String
    let isSaved: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(isSaved ? Color.pink : Color.white)
                .frame(width: 48, height: 48)
                .background(.black.opacity(0.5), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove \(cityName) from wishlist" : "Save \(cityName) to wishlist")
        .accessibilityValue(isSaved ? "Saved" : "Not saved")
        .accessibilityIdentifier("wishlist-toggle-\(cityName)")
        .sensoryFeedback(.selection, trigger: isSaved)
    }
}
