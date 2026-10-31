import SwiftUI

struct WishlistCityRemovalConfirmation: ViewModifier {
    @Binding var city: RandomCity?
    let wishlist: WishlistStore

    func body(content: Content) -> some View {
        content.alert("Are you sure?", isPresented: Binding(
            get: { city != nil },
            set: { if !$0 { city = nil } }
        ), presenting: city) { city in
            Button("Remove city", role: .destructive) {
                wishlist.remove([city])
                self.city = nil
            }
            Button("Cancel", role: .cancel) { self.city = nil }
        } message: { city in
            Text("Unfavoriting \(city.city) will also clear all of its favorited sights and eateries.")
        }
    }
}
