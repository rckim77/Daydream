//
//  MapCardCell.swift
//  Daydream
//
//  Created by Raymond Kim on 2/27/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacesSwift
import GoogleMaps

final class MapCardCell: UITableViewCell {

    private lazy var mapView: GMSMapView = {
        let defaultCamera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 0)
        let mapView = GMSMapView()
        mapView.addRoundedCorners(radius: 16)
        mapView.configureMapStyle(isDark: traitCollection.userInterfaceStyle == .dark)
        mapView.isUserInteractionEnabled = false
        return mapView
    }()

    var place: GooglePlacesSwift.Place? {
        didSet {
            guard let place = place, place != oldValue else {
                return
            }
            updateMapView(place: place)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessibilityLabel = "Map"
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        
        registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
            if previousTraitCollection.userInterfaceStyle != self.traitCollection.userInterfaceStyle {
                self.mapView.configureMapStyle(isDark: self.traitCollection.userInterfaceStyle == .dark)
            }
        })
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateMapView(place: GooglePlacesSwift.Place) {
        let camera = GMSCameraPosition.camera(withLatitude: place.location.latitude,
                                              longitude: place.location.longitude,
                                              zoom: 14.0)
        mapView.animate(to: camera)
        createMarkerFor(mapView, with: place)
        accessibilityLabel = "Map of \(place.displayName ?? "")"
    }
    
    // Creates a marker in center of map
    private func createMarkerFor(_ mapView: GMSMapView, with place: GooglePlacesSwift.Place) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: place.location.latitude,
                                                 longitude: place.location.longitude)
        marker.title = place.displayName
        marker.snippet = place.formattedAddress
        marker.map = mapView
    }
    
    func clearForLoading() {
        mapView.clear()
    }
}
