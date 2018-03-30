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

    var place: Placeable?
    var heroId: String?
    var dynamicMapView: GMSMapView?

    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hero.id = heroId
        addOrUpdateMapView(with: place)
    }

    private func addOrUpdateMapView(with place: Placeable?) {
        guard let place = place else { return }
        let camera = GMSCameraPosition.camera(withLatitude: place.placeableCoordinate.latitude,
                                              longitude: place.placeableCoordinate.longitude,
                                              zoom: 16.0)

        if let dynamicMapView = dynamicMapView {
            dynamicMapView.animate(to: camera)
        } else {
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let mapViewNew = GMSMapView.map(withFrame: frame, camera: camera)

            dynamicMapView = mapViewNew

            guard let dynamicMapView = dynamicMapView else { return }
            view.addSubview(dynamicMapView)
            view.sendSubview(toBack: dynamicMapView)
        }

        createMarker(with: place)
    }

    private func createMarker(with place: Placeable) {
        let marker = GMSMarker()
        marker.appearAnimation = .pop

        marker.position = CLLocationCoordinate2D(latitude: place.placeableCoordinate.latitude,
                                                 longitude: place.placeableCoordinate.longitude)
        marker.title = place.placeableName
        marker.map = dynamicMapView
    }
}
