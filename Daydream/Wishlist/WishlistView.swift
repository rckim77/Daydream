import GooglePlacesSwift
import SwiftUI

struct WishlistView: View {
    let wishlist: WishlistStore

    @State private var selectedContinent: WishlistContinentFilter = .all
    @State private var openingCity: RandomCity?
    @State private var selectedCity: CityRoute?
    @State private var showOpenError = false

    init(wishlist: WishlistStore, initialContinent: WishlistContinentFilter = .all) {
        self.wishlist = wishlist
        _selectedContinent = State(initialValue: initialContinent)
    }

    var body: some View {
        let sections = selectedContinent.sections(from: wishlist.countrySections)

        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.cities) { city in
                        Button {
                            openingCity = city
                        } label: {
                            HStack(spacing: 16) {
                                Text(city.city)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 8)
                                if openingCity?.id == city.id {
                                    ProgressView()
                                        .accessibilityLabel("Opening city")
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                        .accessibilityHidden(true)
                                }
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Explore \(city.city), \(section.country)")
                        .accessibilityIdentifier("wishlist-city-\(city.city)")
                    }
                    .onDelete { offsets in
                        wishlist.remove(offsets.map { section.cities[$0] })
                    }
                } header: {
                    HStack(spacing: 8) {
                        if let flag = section.flag {
                            Text(flag)
                                .accessibilityHidden(true)
                        }
                        Text(section.country)
                            .foregroundStyle(Color(uiColor: .label))
                    }
                    .textCase(nil)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(section.country)
                    .accessibilityIdentifier("wishlist-country-\(section.country)")
                } footer: {
                    if section.id == sections.last?.id {
                        Text("Tap a city to explore. Swipe to remove. Saved on this device.")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollEdgeEffectStyle(.soft, for: .top)
        .disabled(openingCity != nil)
        .overlay {
            if wishlist.cities.isEmpty {
                ContentUnavailableView {
                    Label("Your next adventure starts here", systemImage: "heart")
                } description: {
                    Text("Tap the heart on a city to keep it in your wishlist.")
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
        }
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
