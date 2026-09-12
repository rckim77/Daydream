import SwiftUI
import Testing
import UIKit

@testable import Daydream

@Suite("City card layout")
@MainActor
struct CityCardLayoutTests {
    @Test("Loading photos preserves the available card width and height",
          arguments: [CGFloat(320), 402, 550, 1_018])
    func photoDimensionsDoNotExpandCard(availableWidth: CGFloat) {
        let height: CGFloat = availableWidth < 500 ? 188 : 280
        let host = UIHostingController(rootView: CityCardBackground(image: nil, height: height))
        let proposal = CGSize(width: availableWidth, height: UIView.layoutFittingExpandedSize.height)
        let placeholder = host.sizeThatFits(in: proposal)
        #expect(abs(placeholder.width - availableWidth) < 0.5)
        #expect(abs(placeholder.height - height) < 0.5)

        // Replace the placeholder with different photo shapes, as an async load would.
        for size in [CGSize(width: 4_096, height: 256),
                     CGSize(width: 256, height: 4_096),
                     CGSize(width: 64, height: 64),
                     CGSize(width: 2_048, height: 2_048),
                     CGSize(width: 1_600, height: 900)] {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
                UIColor.systemBlue.setFill()
                context.fill(CGRect(origin: .zero, size: size))
            }
            host.rootView = CityCardBackground(image: image, height: height)
            let loaded = host.sizeThatFits(in: proposal)
            #expect(abs(loaded.width - placeholder.width) < 0.5,
                    "Photo \(size) expanded a \(availableWidth)-point card to \(loaded.width)")
            #expect(abs(loaded.height - placeholder.height) < 0.5)
        }
    }
}
