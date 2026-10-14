import GooglePlacesSwift
import SwiftUI

struct CityDiscoveriesView: View {
    let sights: [Place]
    let eateries: [Place]
    @Binding var tappedPlace: IdentifiablePlace?
    let fadesLeadingEdge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Top Sights")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: sights, tappedPlace: $tappedPlace, fadesLeadingEdge: fadesLeadingEdge)
            Text("Top Eateries")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: eateries, tappedPlace: $tappedPlace, fadesLeadingEdge: fadesLeadingEdge)
        }
    }
}
