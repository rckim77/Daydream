import GooglePlacesSwift
import SwiftUI

struct WishlistView: View {
    let wishlist: WishlistStore

    @State private var openingCity: RandomCity?
    @State private var selectedCity: CityRoute?
    @State private var showOpenError = false

    var body: some View {
        List {
            ForEach(wishlist.countrySections) { section in
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
                    }
                    .textCase(nil)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(section.country)
                    .accessibilityIdentifier("wishlist-country-\(section.country)")
                } footer: {
                    if section.id == wishlist.countrySections.last?.id {
                        Text("Tap a city to explore. Swipe to remove. Saved on this device.")
                    }
                }
            }
        }
        .disabled(openingCity != nil)
        .overlay {
            if wishlist.cities.isEmpty {
                ContentUnavailableView {
                    Label("Your next adventure starts here", systemImage: "heart")
                } description: {
                    Text("Tap the heart on a city to keep it in your wishlist.")
                }
            }
        }
        .navigationTitle("Wishlist")
        .fullScreenCover(item: $selectedCity) { route in
            CityDetailView(place: route.place)
        }
        .alert("Couldn’t open city", isPresented: $showOpenError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check your connection and try again. Your city is still in your wishlist.")
        }
        .task(id: openingCity?.id) {
            guard let city = openingCity else { return }
            defer { openingCity = nil }
            // Navigation belongs to this screen's task, so leaving cancels a pending presentation.
            guard let place = await API.PlaceSearch.fetchCityBy(city) else {
                if !Task.isCancelled { showOpenError = true }
                return
            }
            guard !Task.isCancelled else { return }
            selectedCity = CityRoute(name: city.city, place: place)
        }
    }
}
