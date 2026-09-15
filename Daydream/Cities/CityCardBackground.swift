import SwiftUI

struct CityCardBackground: View {
    let image: UIImage?
    let height: CGFloat

    var body: some View {
        Color(.lightGray)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                // The card owns its size; a wide photo must not enlarge the scroll content.
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .contentShape(RoundedRectangle(cornerRadius: 32))
    }
}
