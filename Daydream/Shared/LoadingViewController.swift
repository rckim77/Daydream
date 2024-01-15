//
//  LoadingViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 4/28/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import SnapKit

/// Refactors loading spinner into a child VC that any VC can add like a plugin. The benefits are:
///
/// 1. Avoids catch-all BaseViewController approach
/// 2. Can contain all logic and layout code inside the child VC
/// 3. Child VC has access to parent VC methods without having to subclass
/// 4. Contain logic for activity indicator all in one place rather than in other VCs
///
/// See: https://medium.com/@johnsundell/using-child-view-controllers-as-plugins-in-swift-458e6b277b54
class LoadingViewController: UIViewController {
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        
        return spinner
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = .black.withAlphaComponent(0.3)
        
        view.addSubview(spinner)
        
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        spinner.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
}
