import GooglePlacesSwift
import SwiftUI

struct CityDiscoveriesView: View {
    let sights: [Place]
    let eateries: [Place]
    @Binding var tappedPlace: IdentifiablePlace?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Top Sights")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: sights, tappedPlace: $tappedPlace)
            Text("Top Eateries")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: eateries, tappedPlace: $tappedPlace)
        }
    }
}
