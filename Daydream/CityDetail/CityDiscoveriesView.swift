import GooglePlacesSwift
import SwiftUI

struct CityDiscoveriesView: View {
    let sights: [Place]
    let eateries: [Place]
    let wishlistCity: RandomCity?
    let wishlist: WishlistStore
    @Binding var tappedPlace: IdentifiablePlace?
    let fadesLeadingEdge: Bool
    var expandsCards = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Top Sights")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: sights, wishlistCity: wishlistCity, wishlist: wishlist, kind: .sight,
                               tappedPlace: $tappedPlace, fadesLeadingEdge: fadesLeadingEdge, expandsCards: expandsCards)
            Text("Top Eateries")
                .font(.title)
                .padding(.horizontal, 24)
            PlacesCarouselView(places: eateries, wishlistCity: wishlistCity, wishlist: wishlist, kind: .eatery,
                               tappedPlace: $tappedPlace, fadesLeadingEdge: fadesLeadingEdge, expandsCards: expandsCards)
        }
    }
}
