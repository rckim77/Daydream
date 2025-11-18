//
//  View+Extensions.swift
//  Daydream
//
//  Created by Ray Kim on 11/2/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

extension View {

    var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    var alertMessage: String {
        var message: String?

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            message = "Version: \(appVersion) (\(bundleVersion))"
        }
        return message ?? ""
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
    
    func deniedLocationAlert(isPresented: Binding<Bool>) -> some View {
        self
            .alert("Looks like you've denied location permissions. Please go to Settings to allow location authorization to use this feature.", isPresented: isPresented) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString),
                          UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
    }
    
    func errorAlert(isPresented: Binding<Bool>) -> some View {
        self
            .alert("Sorry, something went wrong! Try again later.", isPresented: isPresented, actions: {})
    }
}
