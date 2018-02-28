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

    @IBOutlet weak var mainView: UIView!
    
    var place: GMSPlace? {
        didSet {
            guard let place = place else { return }
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14.0)
            let mapView = GMSMapView.map(withFrame: mainView.frame, camera: camera)
            mapView.addRoundedCorners()
            
            mainView.addSubview(mapView)
            
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            marker.title = place.name
            marker.snippet = place.formattedAddress
            marker.map = mapView
        }
    }

}
