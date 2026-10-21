import SwiftUI

struct CountryFlagBackground: View {
    let countryCode: String?

    var body: some View {
        let colors = CountryFlagPalette.colors(for: countryCode).map { hex in
            Color(
                .sRGB,
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255,
                opacity: 1
            )
        }

        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay(.regularMaterial)
            .ignoresSafeArea()
    }
}
