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

class MapViewController: UIViewController {

    var place: Any?
    var heroId: String?
    var dynamicMapView: GMSMapView?

    @IBOutlet weak var mapView: UIView!

    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.hero.id = heroId
        createMapView(with: place)
    }

    private func createMapView(with place: Any?) {
        var camera: GMSCameraPosition?

        if let place = place as? PointOfInterest {
            camera = GMSCameraPosition.camera(withLatitude: place.centerLat, longitude: place.centerLng, zoom: 15.0)

        } else if let place = place as? GMSPlace {
            camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                                  longitude: place.coordinate.longitude,
                                                  zoom: 16.0)
        }

        guard let cameraPosition = camera else { return }

        let frame = CGRect(x: 0, y: 0, width: mapView.bounds.width, height: mapView.bounds.height)
        let mapViewNew = GMSMapView.map(withFrame: frame, camera: cameraPosition)

        dynamicMapView = mapViewNew
        mapView.addSubview(mapViewNew)
        mapView.sendSubview(toBack: mapViewNew)

        createMarker(with: place)
    }

    private func createMarker(with place: Any?) {
        let marker = GMSMarker()
        marker.appearAnimation = .pop

        if let place = place as? PointOfInterest {
            marker.position = CLLocationCoordinate2D(latitude: place.centerLat, longitude: place.centerLng)
            marker.title = place.name
            marker.map = dynamicMapView
        } else if let place = place as? GMSPlace {
            marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            marker.title = place.name
            marker.map = dynamicMapView
        }
    }
}
