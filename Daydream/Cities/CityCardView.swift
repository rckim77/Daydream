import GooglePlacesSwift
import SwiftUI

/// Google's photo component with Daydream's city title and unobstructed attribution.
struct CityCardView: View {
    let city: RandomCity
    let width: CGFloat
    let minimumHeight: CGFloat
    let isSaved: Bool
    let onWishlistToggle: () -> Void
    let onTap: (Place) -> Void

    @State private var placeID: String?
    @State private var loadFailed = false
    @State private var hasLoaded = false
    @State private var isOpening = false
    @State private var requestID = UUID()

    var body: some View {
        let currentRequest = requestID
        let usesCompactTitle = width < 300
        let horizontalInset: CGFloat = usesCompactTitle ? 12 : 16
        let theme: PlacesMaterialTheme = {
            var theme = PlacesMaterialTheme()
            theme.shape.cornerRadius = 20
            theme.shape.cornerRadiusCard = 20
            theme.shape.cornerRadiusThumbnail = 20
            theme.measurement.borderWidth = 0
            // Tighten the SDK's spacing while retaining its attribution text and disclosure control.
            theme.measurement.spacingExtraSmall = 2
            // Remove the extra gap above attribution while keeping the row's own vertical padding.
            theme.measurement.spacingSmall = 0
            theme.measurement.spacingMedium = 6
            theme.measurement.spacingLarge = 8
            theme.measurement.spacingExtraLarge = 12
            theme.measurement.spacingTwoExtraLarge = 16
            theme.color.surface = Color(.systemBackground)
            theme.color.outlineDecorative = .clear
            return theme
        }()

        Group {
            if loadFailed {
                VStack(spacing: 12) {
                    Text(city.city)
                        .font(usesCompactTitle ? .title3.bold() : .largeTitle.bold())
                    Button("Try Again", systemImage: "arrow.clockwise") {
                        placeID = nil
                        loadFailed = false
                        hasLoaded = false
                        requestID = UUID()
                    }
                }
                .padding(.top, 56)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: minimumHeight)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
            } else if let placeID {
                AdvancedPlaceDetailsCompactView(
                    orientation: .vertical,
                    query: .constant(PlaceDetailsQuery(identifier: .placeID(placeID))),
                    configuration: AdvancedPlaceDetailsCompactConfiguration(content: [.media()], theme: theme),
                    placeDetailsCallback: { result in
                        guard requestID == currentRequest else { return }
                        loadFailed = result.error != nil
                        hasLoaded = result.place != nil && result.error == nil
                    }
                )
                .cornerActions { _ in [] }
                .mainActions { _ in [] }
                .id(currentRequest)
                // Bound the SDK's cached intrinsic width after resizing; keep its full footer height.
                .frame(width: width, alignment: .leading)
                .frame(minHeight: minimumHeight, alignment: .top)
                // Balance the visible attribution glyphs, whose baseline sits below the SDK row's center.
                .padding(.bottom, 3)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.primary.opacity(0.2), lineWidth: 0.5)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .top) {
                    Button {
                        openCity(placeID: placeID)
                    } label: {
                        Text(city.city)
                            .font(usesCompactTitle ? .title3.bold() : .largeTitle.bold())
                            .lineLimit(3)
                            .minimumScaleFactor(0.75)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, horizontalInset)
                            .padding(.trailing, horizontalInset + 44 + 4)
                            .padding(.top, usesCompactTitle ? 10 : 12)
                            .padding(.bottom, usesCompactTitle ? 10 : 20)
                            .background(LinearGradient(colors: [.black.opacity(0.65), .clear], startPoint: .top, endPoint: .bottom))
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                    }
                    .buttonStyle(.plain)
                    .disabled(isOpening)
                    .accessibilityLabel("Explore \(city.city)")
                    .accessibilityIdentifier("city-\(hasLoaded ? "loaded" : "loading")-\(city.city)")
                }
                .overlay {
                    if isOpening {
                        ProgressView()
                            .padding(16)
                            .background(.regularMaterial, in: Circle())
                    }
                }
                .contentShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture { openCity(placeID: placeID) }
            } else {
                VStack(spacing: 12) {
                    Text(city.city)
                        .font(usesCompactTitle ? .title3.bold() : .largeTitle.bold())
                    ProgressView()
                }
                .padding(.top, 56)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity, minHeight: minimumHeight)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .frame(width: width)
        .overlay(alignment: .topTrailing) {
            WishlistButton(cityName: city.city, isSaved: isSaved,
                           iconSize: usesCompactTitle ? 20 : 30, action: onWishlistToggle)
                .padding(.trailing, horizontalInset)
                // Align the glyph with the title while preserving its tap target.
                .padding(.top, usesCompactTitle ? 1 : 11)
        }
        .task(id: currentRequest) {
            guard placeID == nil, !loadFailed else { return }
            let place = await API.PlaceSearch.fetchCityBy(city)
            guard !Task.isCancelled, requestID == currentRequest else { return }
            placeID = place?.placeID
            loadFailed = placeID == nil
        }
    }

    private func openCity(placeID: String) {
        guard !isOpening else { return }
        isOpening = true
        Task { @MainActor in
            defer { isOpening = false }
            do {
                let place = try await API.PlaceSearch.fetchPlaceBy(placeId: placeID)
                onTap(place)
            } catch {
                loadFailed = true
            }
        }
    }
}
