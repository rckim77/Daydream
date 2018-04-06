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
    var dynamicMarker: GMSMarker?
    var isInNightMode: Bool = false
    var addMarkerInfoView: Bool = false
    private let networkService = NetworkService()
    
    @IBOutlet weak var reviewView: DesignableView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nightModeBtnTapped(_ sender: UIButton) {
        if isInNightMode {
            dynamicMapView?.mapStyle = nil
            isInNightMode = false
            sender.setImage(#imageLiteral(resourceName: "nightIcon"), for: .normal)
        } else {
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json"), let mapView = dynamicMapView {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                    isInNightMode = true
                    sender.setImage(#imageLiteral(resourceName: "sunIcon"), for: .normal)
                }
            } catch {
                logErrorEvent(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.hero.id = heroId
        reviewView.alpha = 0

        guard let place = place else { return }

        addOrUpdateMapView(with: place, getSnippetData: true)
    }

    private func addOrUpdateMapView(with place: Placeable, getSnippetData: Bool) {
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
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubview(toBack: dynamicMapView)
        }

        addOrUpdateMarker(with: place, addMarkerInfoView: addMarkerInfoView, getSnippetData: getSnippetData)
    }

    private func addOrUpdateMarker(with place: Placeable, addMarkerInfoView: Bool = false, getSnippetData: Bool = false) {
        guard let mapView = dynamicMapView else { return }

        let position = CLLocationCoordinate2D(latitude: place.placeableCoordinate.latitude, longitude: place.placeableCoordinate.longitude)

        if let marker = dynamicMarker {
            marker.map = nil // clears prev marker
            marker.title = place.placeableName
            marker.map = mapView
            marker.position = position
        } else {
            let marker = GMSMarker()
            marker.appearAnimation = .pop
            marker.title = place.placeableName
            marker.map = mapView
            marker.position = position

            dynamicMarker = marker
        }

        guard let dynamicMarker = dynamicMarker else { return }

        if addMarkerInfoView {
            mapView.selectedMarker = dynamicMarker
            if getSnippetData {
                dynamicMarker.tracksInfoWindowChanges = true
                dynamicMarker.snippet = "Loading..."

                networkService.getPlace(with: place.placeableId, success: { [weak self] place in
                    dynamicMarker.snippet = self?.createSnippet(for: place)
                    dynamicMarker.tracksInfoWindowChanges = false
                    self?.place = place
                    if let reviews = place.placeableReviews, !reviews.isEmpty {
                        self?.authorLabel.text = reviews[0].author
                        self?.displayStars(reviews[0].rating)
                        self?.reviewLabel.text = reviews[0].review ?? ""

                        UIView.animate(withDuration: 0.8, animations: {
                            self?.reviewView.alpha = 1
                        })
                    }
                }, failure: { [weak self] error in
                    self?.logErrorEvent(error)
                })
            } else {
                dynamicMarker.snippet = createSnippet(for: place)
            }
        }

    }

    private func createSnippet(for place: Placeable) -> String {
        var snippet = ""

        if let formattedAddress = place.placeableFormattedAddress {
            snippet += formattedAddress
        }

        if let phoneNumber = place.placeableFormattedPhoneNumber {
            snippet += "\n\(phoneNumber)"
        }

        if let rating = place.placeableRating {
            snippet += "\nRating: \(rating)"
        }

        return snippet
    }

    private func displayStars(_ rating: Int) {
        let stars: [UIImageView] = [star5, star4, star3, star2, star1]

        for i in 0..<rating {
            stars[i].image = #imageLiteral(resourceName: "filledStarIcon")
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        networkService.getPlace(with: placeID, success: { [weak self] place in
            self?.addOrUpdateMapView(with: place, getSnippetData: false)
            self?.place = place
        }, failure: { [weak self] error in
            self?.logErrorEvent(error)
        })
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        logEvent(contentType: "tapped info window on map")
        if let mapUrl = place?.placeableMapUrl, let url = URL(string: mapUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
