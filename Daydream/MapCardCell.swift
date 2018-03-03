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

    @IBOutlet weak var mainView: DesignableView!
    var mapView: GMSMapView?

    var place: GMSPlace? {
        didSet {
            guard let place = place else { return }

            if let mapView = mapView {
                update(mapView, with: place)
            } else {
                addMapView(with: place)
            }
        }
    }

    private func addMapView(with place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14.0)
        let mapViewNew = GMSMapView.map(withFrame: mainView.frame, camera: camera)

        mapViewNew.addRoundedCorners()

        createMarkerFor(mapViewNew, with: place)

        mainView.addSubview(mapViewNew)

        mapView = mapViewNew
    }
    
    private func update(_ mapView: GMSMapView, with place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14.0)

        createMarkerFor(mapView, with: place)

        mapView.animate(to: camera)
    }
    
    // Creates a marker in center of map
    private func createMarkerFor(_ mapView: GMSMapView, with place: GMSPlace) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = mapView
    }
}
