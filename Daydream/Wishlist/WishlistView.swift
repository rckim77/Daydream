import GooglePlacesSwift
import SwiftUI

struct WishlistView: View {
    let wishlist: WishlistStore

    @Environment(\.dismiss) private var dismiss
    @State private var openingCity: RandomCity?
    @State private var selectedCity: CityRoute?
    @State private var showOpenError = false

    var body: some View {
        List {
            if !wishlist.cities.isEmpty {
                Section {
                    ForEach(wishlist.cities) { city in
                        Button {
                            openingCity = city
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                    .frame(width: 32, height: 44)
                                    .accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(city.city)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(city.country)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
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
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Explore \(city.city), \(city.country)")
                        .accessibilityIdentifier("wishlist-city-\(city.city)")
                    }
                    .onDelete(perform: wishlist.remove)
                    .onMove(perform: wishlist.move)
                } header: {
                    Text("Places you want to go")
                } footer: {
                    Text("Tap a city to explore. Swipe to remove, or use Edit to change the order. Saved on this device.")
                }
            }
        }
        .disabled(openingCity != nil)
        .overlay {
            if wishlist.cities.isEmpty {
                ContentUnavailableView {
                    Label("Your next adventure starts here", systemImage: "heart")
                } description: {
                    Text("Tap the heart beside a city to keep it in your wishlist.")
                } actions: {
                    Button("Explore Cities") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Wishlist")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !wishlist.cities.isEmpty {
                    EditButton()
                        .disabled(openingCity != nil)
                }
            }
        }
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
