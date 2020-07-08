//
//  MapCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 2/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class MapCardCell: UITableViewCell {

    private lazy var mapView: GMSMapView = {
        let defaultCamera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 0)
        let mapView = GMSMapView(frame: .zero, camera: defaultCamera)
        mapView.addRoundedCorners(radius: 10)
        mapView.configureMapStyle(isDark: traitCollection.userInterfaceStyle == .dark)
        return mapView
    }()

    var place: Place? {
        didSet {
            guard let place = place, place != oldValue else {
                return
            }
            updateMapView(place: place)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }

    private func updateMapView(place: Place) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                              longitude: place.coordinate.longitude,
                                              zoom: 14.0)
        mapView.animate(to: camera)
        createMarkerFor(mapView, with: place)
    }
    
    // Creates a marker in center of map
    private func createMarkerFor(_ mapView: GMSMapView, with place: Place) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude,
                                                 longitude: place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = mapView
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard let previousTraitCollection = previousTraitCollection else {
            return
        }
        if traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle {
            mapView.configureMapStyle(isDark: traitCollection.userInterfaceStyle == .dark)
        }
    }
}
