//
//  MapViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import GoogleMaps
import GooglePlacesSwift
import SnapKit
import SwiftUI
import UIKit

final class MapViewController: UIViewController {

    // Reserve room for Google's selected-marker callout on short landscape maps.
    private static let markerInfoWindowHeadroom: CGFloat = 80
    private var place: Place
    private var dynamicMapView: GMSMapView?
    private var dynamicMarker: GMSMarker?
    private weak var placeDetailCardView: UIView?
    private var usesAccessibleDetails = false
    private var selectedAddress: String?
    /// Used to provide more accurate location when deeplinking to Google Maps
    private var dynamicMarkerPlaceId: String?
    /// Object that updates map review SwiftUI code
    private let reviewsState = MapReviewsViewState()

    var isViewingDarkMode: Bool {
        didSet {
            guard isViewingDarkMode != oldValue else { return }
            overrideUserInterfaceStyle = isViewingDarkMode ? .dark : .light
            dynamicMapView?.configureMapStyle(isDark: isViewingDarkMode)
        }
    }

    init(place: Place, isViewingDarkMode: Bool) {
        self.place = place
        self.isViewingDarkMode = isViewingDarkMode
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = isViewingDarkMode ? .dark : .light
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addOrUpdateMapView(for: place.placeID, name: place.displayName, location: place.location)
        addProgrammaticViews()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let accessibleDetails = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if usesAccessibleDetails != accessibleDetails {
            usesAccessibleDetails = accessibleDetails
            updateMarkerPresentation()
        }

        if let dynamicMapView, let placeDetailCardView {
            // Keep map attribution and the selected place above the content-sized card.
            let cardFrame = dynamicMapView.convert(placeDetailCardView.bounds, from: placeDetailCardView)
            let padding = UIEdgeInsets(
                top: max(dynamicMapView.safeAreaInsets.top, usesAccessibleDetails ? 0 : Self.markerInfoWindowHeadroom),
                left: dynamicMapView.safeAreaInsets.left,
                bottom: max(dynamicMapView.safeAreaInsets.bottom, dynamicMapView.bounds.maxY - cardFrame.minY),
                right: dynamicMapView.safeAreaInsets.right
            )
            if dynamicMapView.padding != padding { dynamicMapView.padding = padding }
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    private func addProgrammaticViews() {
        let placeDetailCardController = UIHostingController(rootView: MapPlaceDetailCardView(
            state: reviewsState,
            onPlaceLoaded: { [weak self] result in
                // The overlay validates request identity before delivering this callback.
                guard let self else { return }
                self.selectedAddress = result.formattedAddress
                self.updateMarkerPresentation()
            }
        ))
        // UIKit positions the card inside its safe area; SwiftUI only measures the content.
        placeDetailCardController.safeAreaRegions = []
        placeDetailCardController.sizingOptions = .intrinsicContentSize
        addChild(placeDetailCardController)
        view.addSubview(placeDetailCardController.view)
        placeDetailCardView = placeDetailCardController.view
        placeDetailCardController.view.backgroundColor = .clear
        placeDetailCardController.didMove(toParent: self)

        placeDetailCardController.view.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(view.safeAreaLayoutGuide).offset(-24).priority(.high)
            make.width.lessThanOrEqualTo(450)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(12)
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
            dynamicMapView.paddingAdjustmentBehavior = .never
            dynamicMapView.clipsToBounds = true
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubviewToBack(dynamicMapView)

            dynamicMapView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
        }
        dynamicMapView?.configureMapStyle(isDark: isViewingDarkMode)
    }

    private func addOrUpdateMarkerAndReviews(for placeId: String, name: String, location: CLLocationCoordinate2D, in mapView: GMSMapView) {
        if let marker = dynamicMarker {
            marker.map = nil // removes previous marker from map
            marker.appearAnimation = .pop
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

        dynamicMarkerPlaceId = placeId

        guard dynamicMarker != nil else { return }

        selectedAddress = nil
        reviewsState.select(placeID: placeId, name: name)
        updateMarkerPresentation()
    }

    /// The provided overlay carries place context at large accessibility sizes, where map callouts clip.
    private func updateMarkerPresentation() {
        guard let marker = dynamicMarker, let mapView = dynamicMapView else { return }
        marker.title = usesAccessibleDetails ? nil : reviewsState.placeName
        marker.snippet = usesAccessibleDetails ? nil : selectedAddress
        marker.accessibilityLabel = reviewsState.placeName
        let selectedMarker = usesAccessibleDetails ? nil : marker
        if mapView.selectedMarker !== selectedMarker { mapView.selectedMarker = selectedMarker }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        addOrUpdateMapView(for: placeID, name: name, location: location)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.path = "/maps/search/"
        components.queryItems = [URLQueryItem(name: "api", value: "1")]
        
        // placeId is most accurate but can fallback with coordinate
        // Google Map URLs must always contain a query, which can consist of a name, address, or comma-separated
        // lat/lon coordinates. Strings must be URL-encoded so make sure to convert chars like commas.
        if let placeId = dynamicMarkerPlaceId {
            components.queryItems?.append(URLQueryItem(name: "query_place_id", value: placeId))
            components.queryItems?.append(URLQueryItem(name: "query", value: reviewsState.placeName))
        } else {
            var query = "\(marker.position.latitude), \(marker.position.longitude)"
            if let name = marker.title {
                query = name + " " + query
            }
            components.queryItems?.append(URLQueryItem(name: "query", value: query))
        }
        
        if let url = components.url {
            UIApplication.shared.open(url)
        }
    }
}
