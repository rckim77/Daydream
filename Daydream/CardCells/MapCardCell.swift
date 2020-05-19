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
    weak var mapView: GMSMapView?

    weak var place: Placeable? {
        didSet {
            guard let place = place, place !== oldValue else {
                return
            }

            if let mapView = mapView {
                update(mapView, with: place)
            } else {
                addMapView(with: place)
            }
        }
    }

    private func addMapView(with place: Placeable) {
        let camera = GMSCameraPosition.camera(withLatitude: place.placeableCoordinate.latitude,
                                              longitude: place.placeableCoordinate.longitude,
                                              zoom: 14.0)
        let frame = calculateFrame()
        let mapViewNew = GMSMapView.map(withFrame: frame, camera: camera)

        mapViewNew.addRoundedCorners(radius: 10)

        createMarkerFor(mapViewNew, with: place)

        mainView.addSubview(mapViewNew)

        mapView = mapViewNew
    }
    
    private func update(_ mapView: GMSMapView, with place: Placeable) {
        let camera = GMSCameraPosition.camera(withLatitude: place.placeableCoordinate.latitude,
                                              longitude: place.placeableCoordinate.longitude,
                                              zoom: 14.0)

        createMarkerFor(mapView, with: place)

        mapView.animate(to: camera)
    }

    private func calculateFrame() -> CGRect {
        let leftMargin: CGFloat = 16
        let rightMargin: CGFloat = 16
        let width = UIScreen.main.bounds.width - leftMargin - rightMargin
        let frame = CGRect(x: mainView.frame.minX, y: mainView.frame.minY, width: width, height: mainView.frame.height)

        return frame
    }
    
    // Creates a marker in center of map
    private func createMarkerFor(_ mapView: GMSMapView, with place: Placeable) {
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: place.placeableCoordinate.latitude,
                                                 longitude: place.placeableCoordinate.longitude)
        marker.title = place.placeableName
        marker.snippet = place.placeableFormattedAddress
        marker.map = mapView
    }
}
