import GooglePlacesSwift
import SwiftUI

struct WishlistView: View {
    let wishlist: WishlistStore
    @Namespace private var zoomNS

    @State private var selectedContinent: WishlistContinentFilter = .all
    @State private var openingCity: RandomCity?
    @State private var selectedCity: CityRoute?
    @State private var showOpenError = false
    @State private var selectedPlace: MapPlace?
    @State private var removingCity: RandomCity?
    @State private var collapsedCountries: Set<WishlistCountrySection.ID> = []

    var body: some View {
        let sections = selectedContinent.sections(from: wishlist.countrySections)

        List {
            ForEach(sections) { section in
                Section {
                    if !collapsedCountries.contains(section.id) {
                        ForEach(section.cities) { city in
                            WishlistCityRow(city: city, wishlist: wishlist, zoomNamespace: zoomNS,
                                            isOpening: openingCity?.id == city.id) {
                                openingCity = city
                            } onOpenPlace: { place in
                                selectedPlace = place
                            } onRemoveCity: {
                                if wishlist.places(in: city).isEmpty {
                                    wishlist.remove([city])
                                } else {
                                    removingCity = city
                                }
                            }
                        }
                    }
                } header: {
                    let isCollapsed = collapsedCountries.contains(section.id)
                    Button {
                        withAnimation {
                            if isCollapsed {
                                collapsedCountries.remove(section.id)
                            } else {
                                collapsedCountries.insert(section.id)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isCollapsed ? "arrowtriangle.right.fill" : "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .frame(width: 12)
                                .accessibilityHidden(true)
                            if let flag = section.flag {
                                Text(flag)
                                    .accessibilityHidden(true)
                            }
                            Text(section.country)
                                .foregroundStyle(Color(uiColor: .label))
                            Spacer(minLength: 8)
                        }
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .textCase(nil)
                    .accessibilityLabel(section.country)
                    .accessibilityValue(isCollapsed ? "Collapsed" : "Expanded")
                    .accessibilityIdentifier("wishlist-country-\(section.country)")
                } footer: {
                    if section.id == sections.last?.id {
                        Text("Tap a country to expand or collapse its cities and saved places. Swipe to remove a place or city. Saved on this device.")
                    }
                }
                .listSectionMargins(.vertical, collapsedCountries.contains(section.id) ? 0 : nil)
            }
        }
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollEdgeEffectStyle(.soft, for: .top)
        .disabled(openingCity != nil)
        .overlay {
            if wishlist.cities.isEmpty {
                ContentUnavailableView {
                    Label("Your next adventure starts here", systemImage: "heart")
                } description: {
                    Text("Tap the heart on a city, sight, or eatery to keep it in your wishlist.")
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .transition(.opacity)
            } else if sections.isEmpty {
                ContentUnavailableView {
                    Label("No saved cities in \(selectedContinent.name)", systemImage: "heart")
                } description: {
                    Text("Save a city in this continent or choose another filter.")
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .id(selectedContinent)
                .transition(.opacity)
            }
        }
        .safeAreaBar(edge: .top, spacing: 0) {
            WishlistContinentFilterBar(selection: $selectedContinent)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Wishlist")
        .fullScreenCover(item: $selectedCity) { route in
            CityDetailView(place: route.place, wishlist: wishlist, sourceCity: route.wishlistCity)
                .navigationTransition(.zoom(sourceID: route.wishlistCity?.id ?? route.name, in: zoomNS))
        }
        .fullScreenCover(item: $selectedPlace) { place in
            MapDetailView(mapPlace: place)
        }
        .modifier(WishlistCityRemovalConfirmation(city: $removingCity, wishlist: wishlist))
        .alert("Couldn’t open city", isPresented: $showOpenError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check your connection and try again. Your city is still in your wishlist.")
        }
        .task(id: openingCity?.id) {
            guard let city = openingCity else { return }
            defer { openingCity = nil }
            // Leaving this screen cancels pending navigation.
            let place: Place?
            if let placeID = city.placeID {
                place = try? await API.PlaceSearch.fetchPlaceBy(placeId: placeID)
            } else {
                place = await API.PlaceSearch.fetchCityBy(city)
            }
            guard let place else {
                if !Task.isCancelled { showOpenError = true }
                return
            }
            guard !Task.isCancelled else { return }
            selectedCity = CityRoute(name: city.city, place: place, wishlistCity: city)
        }
    }
}
