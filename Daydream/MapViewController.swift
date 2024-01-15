//
//  MapViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SnapKit
import Combine

// swiftlint:disable type_body_length
final class MapViewController: UIViewController {

    private var place: Place
    private var dynamicMapView: GMSMapView?
    private var dynamicMarker: GMSMarker?
    private var currentReviews: [Review]?
    private var currentReviewIndex = 0

    // Will automatically sync with system user interface style settings but can be overridden
    // when the user taps the dark mode button. Note this must be called once dynamicMapView is set.
    private var isViewingDarkMode = false {
        didSet {
            dynamicMapView?.configureMapStyle(isDark: isViewingDarkMode)
            let imageName = isViewingDarkMode ? "sun.max.fill" : "moon.fill"
            darkModeButton.configureWithSystemIcon(imageName)
        }
    }

    private var loadPlaceCancellable: AnyCancellable?

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
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("xmark.circle.fill")
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "map-close-button"
        button.pointerStyleProvider = buttonProvider
        return button
    }()

    private lazy var darkModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("moon.fill")
        button.addTarget(self, action: #selector(darkModeButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "map-dark-mode-button"
        button.pointerStyleProvider = buttonProvider
        return button
    }()

    private lazy var aboutButton: UIButton = {
        let button = UIButton(type: .system)
        button.configureWithSystemIcon("info.circle.fill")
        button.addTarget(self, action: #selector(aboutButtonTapped), for: .touchUpInside)
        button.pointerStyleProvider = buttonProvider
        return button
    }()

    private lazy var reviewCard: MapReviewCard = {
        let card = MapReviewCard()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(reviewCardTapped))
        card.addGestureRecognizer(tapGesture)
        return card
    }()
    
    init?(place: Place?) {
        guard let place = place else {
            return nil
        }
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

        addOrUpdateMapView(for: place.placeId, name: place.name, location: place.coordinate)
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
        
        darkModeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12 + iPadOffset)
            make.leading.equalToSuperview().inset(12)
            make.size.equalTo(40)
        }

        aboutButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12 + iPadOffset)
            make.size.equalTo(40)
        }

        closeButton.snp.makeConstraints { make in
            make.leading.equalTo(aboutButton.snp.trailing)
            make.top.equalToSuperview().inset(12 + iPadOffset)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(40)
        }

        reviewCard.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12 + iPadOffset)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12 + iPadOffset)
            make.height.equalTo(MapReviewCard.height)
        }

        reviewCard.isHidden = true
    }

    private func addOrUpdateMapView(for placeId: String, name: String, location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16.0)

        if let dynamicMapView = dynamicMapView {
            dynamicMapView.animate(to: camera)
            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
        } else {
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let options = GMSMapViewOptions()
            options.camera = camera
            options.frame = frame
            let mapViewNew = GMSMapView(options: options)
            dynamicMapView = mapViewNew

            guard let dynamicMapView = dynamicMapView else {
                return
            }
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubviewToBack(dynamicMapView)
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

        loadPlaceCancellable = API.PlaceSearch.loadPlaceWithReviews(placeId: placeId)?
            .sink(receiveCompletion: { completion in
            }, receiveValue: { [weak self] place in
                guard let strongSelf = self else {
                    return
                }
                dynamicMarker.snippet = place.formattedAddress
                dynamicMarker.tracksInfoWindowChanges = false
                strongSelf.place = place
                strongSelf.displayReviews(place.reviews, index: 0)
            })
    }

    // MARK: - Review-specific methods

    private func displayReviews(_ reviews: [Review]?, index: Int) {
        guard let reviews = reviews, !reviews.isEmpty else {
            return
        }
        currentReviews = reviews
        currentReviewIndex = index
        loadReviewContent(reviews[index])
        reviewCard.isHidden = false
        reviewCard.alpha = 1

        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            displayReviewForUITest(reviews)
        } else {
            startDisplayingReviews(reviews, index: index + 1)
        }
    }

    private func startDisplayingReviews(_ reviews: [Review], index: Int) {
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

    private func displayReviewForUITest(_ reviews: [Review]) {
        guard let firstReview = reviews.first else {
            return
        }
        reviewCard.isHidden = false
        currentReviewIndex = 1
        loadReviewContent(firstReview)
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

    private func loadReviewContent(_ review: Review) {
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
        guard let reviews = currentReviews, let authorUrl = reviews[currentReviewIndex].authorUrl else {
            return
        }
        openUrl(authorUrl)
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        stopDisplayingReviews()
        addOrUpdateMapView(for: placeID, name: name, location: location)
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let mapUrl = place.mapUrl, let url = URL(string: mapUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension MapViewController: ImageViewFadeable {}
