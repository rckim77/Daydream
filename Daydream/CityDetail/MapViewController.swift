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
    private weak var reviewsView: UIView?
    /// Used to provide more accurate location when deeplinking to Google Maps
    private var dynamicMarkerPlaceId: String?
    /// Object that updates map review SwiftUI code
    private var mapReviewContext = MapReviewContext(place: nil)

    var isViewingDarkMode: Bool {
        didSet {
            guard isViewingDarkMode != oldValue else { return }
            dynamicMapView?.configureMapStyle(isDark: isViewingDarkMode)
        }
    }

    init(place: Place, isViewingDarkMode: Bool) {
        self.place = place
        self.isViewingDarkMode = isViewingDarkMode
        super.init(nibName: nil, bundle: nil)
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

        if let dynamicMapView, let reviewsView {
            // Move the camera's visible center above the reviews after every resize.
            let reviewsFrame = dynamicMapView.convert(reviewsView.bounds, from: reviewsView)
            dynamicMapView.padding = UIEdgeInsets(
                top: max(dynamicMapView.safeAreaInsets.top, Self.markerInfoWindowHeadroom),
                left: dynamicMapView.safeAreaInsets.left,
                bottom: max(dynamicMapView.safeAreaInsets.bottom, dynamicMapView.bounds.maxY - reviewsFrame.minY),
                right: dynamicMapView.safeAreaInsets.right
            )
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    private func addProgrammaticViews() {
        let reviewsCarouselVC = UIHostingController(rootView: MapReviewsCarousel(context: mapReviewContext))
        addChild(reviewsCarouselVC)
        view.addSubview(reviewsCarouselVC.view)
        reviewsView = reviewsCarouselVC.view
        reviewsCarouselVC.view.backgroundColor = .clear
        reviewsCarouselVC.didMove(toParent: self)
        
        reviewsCarouselVC.view.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            make.height.equalTo(200)
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
            mapReviewContext.place = result
        }
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
            components.queryItems?.append(URLQueryItem(name: "query", value: marker.title))
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
