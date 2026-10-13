import GooglePlacesSwift
import SwiftUI

struct CityDetailContentView: View {
    let place: Place
    let cityText: String
    @Bindable var viewState: CityDetailViewState
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, 1200)
            let expanded = width >= 760 && !dynamicTypeSize.isAccessibilitySize
            // Change only the layout, preserving map camera, summary, and carousel identity across a fold.
            let layout = expanded
                ? AnyLayout(HStackLayout(alignment: .top, spacing: 0))
                : AnyLayout(VStackLayout(alignment: .leading, spacing: 4))

            ScrollView(showsIndicators: false) {
                layout {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cityText)
                            .font(.largeTitle)
                            .padding(.horizontal, 24)
                        SummaryView(cityText: cityText)
                        MapCardView(mapPosition: $viewState.mapPosition, place: place, height: expanded ? 340 : 190)
                    }
                    .frame(width: expanded ? width * 0.44 : width)

                    CityDiscoveriesView(sights: viewState.sights, eateries: viewState.eateries, tappedPlace: $viewState.tappedCardPlace)
                        .frame(width: expanded ? width * 0.56 : width)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .frame(width: width)
            .frame(maxWidth: .infinity)
        }
    }
}
