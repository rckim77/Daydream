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
import Combine
import SwiftUI

final class SearchViewController: UIViewController {

    private var autocompletePlace: GooglePlacesSwift.Place?
    private var placeBackgroundImage: UIImage?

    private let curatedCitiesDataSource: CuratedCityCollectionViewDataSource
    private var deviceYOffset: CGFloat {
        isSmallDevice ? 0 : 48
    }
    private var titleLabelCenterYOffset: CGFloat {
        -212 - deviceYOffset
    }

    private lazy var backgroundImageView: UIImageView = {
        let image = UIImage(named: "sunriseJungle")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var backgroundBlurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()

    /// Note: When the user does not have Dark Mode on, this does nothing.
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.4) : .clear
        return view
    }()

    private lazy var titleLabel: CardLabel = {
        let label = CardLabel(textStyle: .largeTitle, text: "Where do you want to go?")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var curatedCitiesCollectionView: CarouselCollectionView = {
        let collectionView = CarouselCollectionView(deviceSize: deviceSize, isIpad: UIDevice.current.userInterfaceIdiom == .pad)
        collectionView.delegate = self
        collectionView.dataSource = curatedCitiesDataSource
        return collectionView
    }()

    // MARK: - Cancellables

    private var curatedCitiesCancellable: AnyCancellable?
    
    // MARK: Init
    
    init() {
        let cityCount = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
        curatedCitiesDataSource = CuratedCityCollectionViewDataSource(cityCount: cityCount)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                } else {
                    self.overlayView.backgroundColor = .clear
                }
            }
        })
    }

    private func addViews() {
        view.addSubview(backgroundImageView)
        backgroundImageView.addSubview(backgroundBlurEffectView)
        view.addSubview(overlayView)
        view.addSubview(titleLabel)
        view.addSubview(curatedCitiesCollectionView)
        
        let searchActionsView = SearchActionsView(randomCityReceived: { [weak self] place, image in
            if let image = image {
                self?.resetAndPresentDetailViewController(place: place, image: image)
            }
        }, feedbackButtonTapped: { [weak self] in
            self?.feedbackButtonTapped()
        }, autocompleteTapped: { [weak self] place, image in
            if let image = image {
                self?.resetAndPresentDetailViewController(place: place, image: image)
            }
        })

        let searchActionsHostVC = UIHostingController(rootView: searchActionsView)
        addChild(searchActionsHostVC)
        view.addSubview(searchActionsHostVC.view)
        searchActionsHostVC.view.backgroundColor = .clear
        searchActionsHostVC.didMove(toParent: self)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundBlurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview().offset(titleLabelCenterYOffset)
        }

        searchActionsHostVC.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
        
        curatedCitiesCollectionView.snp.makeConstraints { make in
            make.height.equalTo(curatedCitiesCollectionView.height)
            make.bottom.equalTo(searchActionsHostVC.view.snp.top).offset(-24)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func resetAndPresentDetailViewController(place: GooglePlacesSwift.Place, image: UIImage) {
        placeBackgroundImage = nil
        autocompletePlace = nil
        let searchDetailVC = SearchDetailViewController(backgroundImage: image, place: place)
        searchDetailVC.modalPresentationStyle = .fullScreen
        searchDetailVC.modalTransitionStyle = .crossDissolve
        present(searchDetailVC, animated: true, completion: nil)
    }

    private func feedbackButtonTapped() {
        var message: String?

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            message = "The current app version is \(appVersion) (\(bundleVersion))."
        }

        let alert = UIAlertController(title: "Got feedback? Email me!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { _ in
            self.openUrl("mailto:daydreamiosapp@gmail.com")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CuratedCityCollectionViewCell,
            let place = cell.place,
            let image = cell.placeImage else {
            return
        }
        let searchDetailVC = SearchDetailViewController(backgroundImage: image, place: place)
        searchDetailVC.modalPresentationStyle = .fullScreen
        searchDetailVC.modalTransitionStyle = .crossDissolve
        present(searchDetailVC, animated: true, completion: nil)
    }
}

extension SearchViewController: RandomCitySelectable {}
