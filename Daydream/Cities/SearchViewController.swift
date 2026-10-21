//
//  SearchViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlacesSwift
import SnapKit
import SwiftUI

final class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let locationManager = CurrentLocationManager()
        #if DEBUG
        let capture = WishlistCaptureView.fromEnvironment()
        #endif
        let citiesVC = UIHostingController(rootView: Group {
            #if DEBUG
            if let capture {
                capture
            } else {
                CitiesView()
            }
            #else
            CitiesView()
            #endif
        }.environment(locationManager))
        #if DEBUG
        if let appearance = capture?.appearance {
            citiesVC.overrideUserInterfaceStyle = appearance == .dark ? .dark : .light
        }
        #endif
        addChild(citiesVC)
        view.addSubview(citiesVC.view)
        citiesVC.didMove(toParent: self)
        
        citiesVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
