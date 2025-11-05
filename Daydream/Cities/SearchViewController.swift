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

        let citiesVC = UIHostingController(rootView: CitiesView())
        addChild(citiesVC)
        view.addSubview(citiesVC.view)
        citiesVC.didMove(toParent: self)
        
        citiesVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
