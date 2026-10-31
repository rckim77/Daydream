import GooglePlacesSwift
import SwiftUI

struct CityDetailContentView: View {
    let place: Place
    let cityText: String
    let wishlistCity: RandomCity?
    let wishlist: WishlistStore
    @Bindable var viewState: CityDetailViewState
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, 1200)
            let isLandscape = geometry.size.width > geometry.size.height
            let expanded = isLandscape && width >= 760 && !dynamicTypeSize.isAccessibilitySize
            // Keep the overview inset while letting landscape carousels reach the trailing edge.
            let leadingInset = (geometry.size.width - width) / 2
            let contentWidth = expanded ? geometry.size.width - leadingInset : width
            let fillsLandscapeHeight = expanded && verticalSizeClass == .regular
            let topPadding: CGFloat = verticalSizeClass == .compact ? 8 : 24
            let bottomPadding: CGFloat = 16
            // Change only the layout, preserving map camera, summary, and carousel identity across a fold.
            let layout = expanded
                ? AnyLayout(HStackLayout(alignment: .top, spacing: 0))
                : AnyLayout(VStackLayout(alignment: .leading, spacing: 4))

            ScrollView(showsIndicators: false) {
                layout {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 8) {
                            Text(cityText)
                                .font(.largeTitle)
                            if let city = wishlistCity {
                                Spacer(minLength: 8)
                                let isSaved = wishlist.contains(city)
                                Button {
                                    if isSaved, !wishlist.places(in: city).isEmpty {
                                        viewState.removingWishlistCity = city
                                    } else {
                                        wishlist.toggle(city)
                                    }
                                } label: {
                                    Image(systemName: isSaved ? "heart.fill" : "heart")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(isSaved ? Color.pink : Color.primary)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .glassEffect(.regular.interactive(), in: .circle)
                                .fixedSize()
                                .accessibilityLabel(isSaved ? "Remove \(city.city) from wishlist" : "Save \(city.city) to wishlist")
                                .accessibilityValue(isSaved ? "Saved" : "Not saved")
                                .accessibilityIdentifier("city-detail-wishlist-button")
                                .sensoryFeedback(.selection, trigger: isSaved)
                            }
                        }
                        .padding(.horizontal, 24)
                        SummaryView(cityText: cityText)
                        MapCardView(mapPosition: $viewState.mapPosition, place: place, height: expanded ? nil : 190)
                    }
                    .frame(width: expanded ? width * 0.44 : width)
                    .frame(maxHeight: expanded ? .infinity : nil, alignment: .top)

                    CityDiscoveriesView(
                        sights: viewState.sights,
                        eateries: viewState.eateries,
                        wishlistCity: wishlistCity,
                        wishlist: wishlist,
                        tappedPlace: Binding(
                            get: { viewState.tappedSheetPlace ?? viewState.tappedCardPlace },
                            set: { viewState.presentMap($0, asSheet: isLandscape) }
                        ),
                        fadesLeadingEdge: isLandscape,
                        expandsCards: fillsLandscapeHeight
                    )
                        .frame(width: expanded ? contentWidth - width * 0.44 : width)
                        // Fill spare height, but allow taller content to scroll without shrinking the cards.
                        .frame(minHeight: fillsLandscapeHeight ? max(0, geometry.size.height - topPadding - bottomPadding) : nil)
                        .frame(maxHeight: expanded ? .infinity : nil, alignment: .bottom)
                }
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            }
            .scrollClipDisabled()
            .frame(width: contentWidth)
            .frame(maxWidth: .infinity, alignment: expanded ? .trailing : .center)
        }
        .toolbarVisibility(verticalSizeClass == .compact ? .hidden : .automatic, for: .navigationBar)
        .modifier(WishlistCityRemovalConfirmation(city: $viewState.removingWishlistCity, wishlist: wishlist))
    }
}
