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
}
