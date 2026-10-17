import SwiftUI

/// A full scrolling surface replaces the map SDK's image-rendered callout at accessibility sizes.
struct MapAccessiblePlaceDetailsView: View {
    @ObservedObject var context: MapReviewContext
    let onRetry: () -> Void
    let onOpenMaps: () -> Void
    @State private var showDetails = false

    var body: some View {
        Button {
            showDetails = true
        } label: {
            Label("Place details", systemImage: "text.bubble")
                .labelStyle(.titleAndIcon)
                .font(.body).bold()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.black)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 2)
                .padding(12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(context.selectedName). Place details and reviews")
        .accessibilityIdentifier("map-place-details-button")
        .sheet(isPresented: $showDetails) {
            MapPlaceDetailsSheet(context: context, onRetry: onRetry, onOpenMaps: onOpenMaps)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
