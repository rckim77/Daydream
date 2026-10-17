import SwiftUI

struct CurrentCityButton: View {
    let currentLocationTapped: () -> Void
    @Environment(CurrentLocationManager.self) private var locationManager
    @State private var showDeniedLocationAlert = false

    var body: some View {
        Button("Current Location", systemImage: "location.fill") {
            switch locationManager.requestCurrentLocation() {
            case .denied, .restricted:
                showDeniedLocationAlert = true
            case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
                currentLocationTapped()
            @unknown default:
                break
            }
        }
        .accessibilityIdentifier("current-city-button")
        .deniedLocationAlert(isPresented: $showDeniedLocationAlert)
    }
}
