import SwiftUI

struct CurrentCityButton: View {
    let currentLocationTapped: () -> Void
    @Environment(CurrentLocationManager.self) private var locationManager
    @State private var showDeniedLocationAlert = false

    var body: some View {
        Button("Current Location", systemImage: "location.fill") {
            if locationManager.requestCurrentLocation() == .denied {
                showDeniedLocationAlert = true
            }
            currentLocationTapped()
        }
        .accessibilityIdentifier("current-city-button")
        .deniedLocationAlert(isPresented: $showDeniedLocationAlert)
    }
}
