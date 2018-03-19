//
//  MapViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 3/18/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    var mapCamera: GMSCameraPosition?

    @IBOutlet weak var mapView: UIView!

    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.hero.id = "mapCard"

        guard let camera = mapCamera else { return }

        let frame = CGRect(x: 0, y: 0, width: mapView.bounds.width, height: mapView.bounds.height)
        let mapViewNew = GMSMapView.map(withFrame: frame, camera: camera)
        mapView.addSubview(mapViewNew)
        mapView.sendSubview(toBack: mapViewNew)
    }

}
