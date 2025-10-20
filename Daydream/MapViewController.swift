//
//  MapViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlacesSwift
import SnapKit

// swiftlint:disable type_body_length
final class MapViewController: UIViewController {

    private var place: Place
    private var dynamicMapView: GMSMapView?
    private var dynamicMarker: GMSMarker?
    private var currentReviews: [GooglePlacesSwift.Review]?
    private var currentReviewIndex = 0

    /// Will automatically sync with system user interface style settings but can be overridden
    /// when the user taps the dark mode button. Note this must be called once `dynamicMapView` is set.
    private var isViewingDarkMode = false {
        didSet {
            dynamicMapView?.configureMapStyle(isDark: isViewingDarkMode)

            if #available(iOS 26, *) {
                let imageName = isViewingDarkMode ? "sun.max" : "moon"
                darkModeButton.setImage(UIImage(systemName: imageName), for: .normal)
            } else {
                let imageName = isViewingDarkMode ? "sun.max.fill" : "moon.fill"
                var newConfig = UIButton.Configuration.plain()
                newConfig.configureForIcon(imageName)
                darkModeButton.configuration = newConfig
            }
        }
    }

    // contains close and dark mode buttons (and creates frame for gradient)
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        return layer
    }()

    private lazy var closeButton: UIButton = {
        let button: UIButton

        if #available(iOS 26, *) {
            var config = UIButton.Configuration.glass()
            config.configureForIcon("xmark")
            button = UIButton(configuration: config)
        } else {
            var config = UIButton.Configuration.plain()
            config.configureForIcon("xmark.circle.fill")
            button = UIButton(configuration: config)
            button.addDropShadow()
        }
        
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "map-close-button"
        button.pointerStyleProvider = buttonProvider
        button.isSymbolAnimationEnabled = true
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        return button
    }()

    private lazy var darkModeButton: UIButton = {
        let button: UIButton

        if #available(iOS 26, *) {
            var config = UIButton.Configuration.glass()
            config.configureForIcon("moon")
            button = UIButton(configuration: config)
        } else {
            var config = UIButton.Configuration.plain()
            config.configureForIcon("moon.fill")
            button = UIButton(configuration: config)
            button.addDropShadow()
        }
        
        button.addTarget(self, action: #selector(darkModeButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "dark mode toggle"
        button.pointerStyleProvider = buttonProvider
        button.isSymbolAnimationEnabled = true
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return button
    }()

    private lazy var aboutButton: UIButton = {
        let button: UIButton

        if #available(iOS 26, *) {
            var config = UIButton.Configuration.glass()
            config.configureForIcon("info")
            button = UIButton(configuration: config)
        } else {
            var config = UIButton.Configuration.plain()
            config.configureForIcon("info.circle.fill")
            button = UIButton(configuration: config)
            button.addDropShadow()
        }
        
        button.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "info button"
        button.pointerStyleProvider = buttonProvider
        button.isSymbolAnimationEnabled = true
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        return button
    }()

    private lazy var reviewCard: MapReviewCard = {
        let card = MapReviewCard()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reviewCardTapped))
        card.addGestureRecognizer(tapGesture)
        return card
    }()
    
    init(place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopDisplayingReviews),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartDisplayingCurrentReviews),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addOrUpdateMapView(for: place.placeID, name: place.displayName, location: place.location)
        addProgrammaticViews()
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            if self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
                self.isViewingDarkMode = self.traitCollection.userInterfaceStyle == .dark
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplayingReviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = containerView.bounds
    }

    private func addProgrammaticViews() {
        view.addSubview(containerView)

        // Map header includes a gradient so that buttons are easier to see and creates a pannable section above
        // the map view so users can dismiss.
        containerView.layer.addSublayer(gradientLayer)
        containerView.addSubview(closeButton)
        containerView.addSubview(darkModeButton)
        containerView.addSubview(aboutButton)

        view.addSubview(reviewCard)

        containerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(68)
        }

        let iPadOffset = UIDevice.current.userInterfaceIdiom == .pad ? 12 : 0
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16 + iPadOffset)
            if #available(iOS 26, *) {
                make.leading.equalToSuperview().inset(16)
            } else {
                make.leading.equalToSuperview().inset(8)
            }
        }

        darkModeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16 + iPadOffset)
        }

        aboutButton.snp.makeConstraints { make in
            if #available(iOS 26, *) {
                make.leading.equalTo(darkModeButton.snp.trailing).offset(12)
            } else {
                make.leading.equalTo(darkModeButton.snp.trailing)
            }
            make.top.equalToSuperview().inset(16 + iPadOffset)

            if #available(iOS 26, *) {
                make.trailing.equalToSuperview().inset(16)
            } else {
                make.trailing.equalToSuperview().inset(8)
            }
        }


        reviewCard.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12 + iPadOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12 + iPadOffset)
            make.height.equalTo(MapReviewCard.height)
        }
        
        if let summary = place.reviewSummary {
            reviewCard.configureWithSummary(summary)
        } else {
            reviewCard.isHidden = true
        }
    }

    private func addOrUpdateMapView(for placeId: String?, name: String?, location: CLLocationCoordinate2D?) {
        guard let placeId = placeId, let name = name, let location = location else {
            return
        }
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16.0)

        if let dynamicMapView = dynamicMapView {
            dynamicMapView.animate(to: camera)
            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
        } else {
            let options = GMSMapViewOptions()
            options.camera = camera
            options.frame = .zero
            let mapViewNew = GMSMapView(options: options)
            dynamicMapView = mapViewNew

            guard let dynamicMapView = dynamicMapView else {
                return
            }
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubviewToBack(dynamicMapView)
            
            // fixes issue where map wasn't centered on iPad (but doesn't work on iPhone due to safe area)
            if UIDevice().userInterfaceIdiom == .pad {
                dynamicMapView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            } else {
                dynamicMapView.frame = view.frame
            }

            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
        }
        isViewingDarkMode = traitCollection.userInterfaceStyle == .dark
    }

    private func addOrUpdateMarkerAndReviews(for placeId: String, name: String, location: CLLocationCoordinate2D, in mapView: GMSMapView) {
        if let marker = dynamicMarker {
            marker.map = nil // clears prev marker
            marker.title = name
            marker.map = mapView
            marker.position = location
        } else {
            let marker = GMSMarker()
            marker.appearAnimation = .pop
            marker.title = name
            marker.map = mapView
            marker.position = location

            dynamicMarker = marker
        }

        guard let dynamicMarker = dynamicMarker else {
            return
        }

        mapView.selectedMarker = dynamicMarker

        dynamicMarker.tracksInfoWindowChanges = true

        Task {
            guard let result = await API.PlaceSearch.fetchPlaceWithReviewsBy(placeId: placeId) else {
                return
            }

            dynamicMarker.snippet = result.formattedAddress
            dynamicMarker.tracksInfoWindowChanges = false
            place = result
            await MainActor.run {
                if let summary = result.reviewSummary {
                    reviewCard.configureWithSummary(summary)
                } else {
                    displayReviews(result.reviews, index: 0)
                }
            }
        }
    }

    // MARK: - Review-specific methods

    private func displayReviews(_ reviews: [GooglePlacesSwift.Review]?, index: Int) {
        guard let reviews = reviews, !reviews.isEmpty else {
            return
        }
        currentReviews = reviews
        currentReviewIndex = index
        loadReviewContent(reviews[index])
        reviewCard.isHidden = false
        reviewCard.alpha = 1

        startDisplayingReviews(reviews, index: index + 1)
    }

    private func startDisplayingReviews(_ reviews: [GooglePlacesSwift.Review], index: Int) {
        if index < reviews.count - 1 {
            UIView.animate(withDuration: 0.7, animations: {
                self.reviewCard.alpha = 1
            }, completion: { finished in
                if finished {
                    // Bug fix: In order for the map review card to be tappable and
                    // animatable, we need to wrap the animate function in a timeout
                    // function. Adding a delay to the animate function will not work
                    // because the view's frame changes as soon as the animation begins
                    // and ignores the delay. The tap gesture recognizer needs the frame
                    // to actually execute.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        UIView.animate(withDuration: 0.7, animations: {
                            self.reviewCard.alpha = 0
                        }, completion: { [weak self] finished in
                            if let strongSelf = self, finished {
                                strongSelf.currentReviewIndex = index
                                strongSelf.loadReviewContent(reviews[index])
                                strongSelf.startDisplayingReviews(reviews, index: index + 1)
                            }
                        })
                    }
                }
            })
        } else {
            UIView.animate(withDuration: 0.8, animations: {
                self.reviewCard.alpha = 0
            }, completion: { [weak self] _ in
                self?.reviewCard.isHidden = true
            })
        }
    }

    @objc
    private func restartDisplayingCurrentReviews() {
        guard let reviews = currentReviews else {
            return
        }
        displayReviews(reviews, index: currentReviewIndex)
    }

    @objc
    private func stopDisplayingReviews() {
        reviewCard.subviews.forEach { $0.layer.removeAllAnimations() }
        reviewCard.layer.removeAllAnimations()
        reviewCard.alpha = 0
        reviewCard.isHidden = true
    }

    private func loadReviewContent(_ review: GooglePlacesSwift.Review) {
        reviewCard.configure(review)
    }

    // MARK: - Button selector methods

    @objc
    private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func darkModeButtonTapped() {
        isViewingDarkMode.toggle()
    }

    @objc
    private func aboutButtonTapped() {
        let openSourceMessage = GMSServices.openSourceLicenseInfo()
        presentInfoAlertModal(title: "About Google Maps", message: openSourceMessage)
    }

    @objc
    private func reviewCardTapped() {
        guard let reviews = currentReviews, let authorUrl = reviews[currentReviewIndex].authorAttribution?.url else {
            return
        }
        UIApplication.shared.open(authorUrl, options: [:])
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        stopDisplayingReviews()
        addOrUpdateMapView(for: placeID, name: name, location: location)
    }
}

extension MapViewController: ImageViewFadeable {}
