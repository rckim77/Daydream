//
//  View+Extensions.swift
//  Daydream
//
//  Created by Ray Kim on 11/2/25.
//  Copyright © 2025 Raymond Kim. All rights reserved.
//

import SwiftUI

extension View {
    private var alertMessage: String {
        var message: String?

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            message = "The current app version is \(appVersion) (\(bundleVersion))."
        }
        return message ?? ""
    }
    
    func feedbackAlert(showAlert: Binding<Bool>, onEmailButtonPress: @escaping ((URL) -> Void)) -> some View {
        self
            .alert("Got feedback? Email me!", isPresented: showAlert, actions: {
                Button("Email") {
                    if let url = URL(string: "mailto:daydreamiosapp@gmail.com") {
                        onEmailButtonPress(url)
                    }
                }
                Button("Cancel") {}
            }, message: {
                Text(alertMessage)
            })
    }
}
