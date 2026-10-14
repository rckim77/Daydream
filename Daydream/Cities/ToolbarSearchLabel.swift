import SwiftUI

@available(iOS 27.1, *)
struct ToolbarSearchLabel: View {
    @Environment(\.toolbarVerticalEdge) private var verticalEdge

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            if verticalEdge == nil {
                Text("Search")
            }
        }
    }
}
