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

        reviewView.isHidden = true

        guard let place = place else { return }

        addOrUpdateMapView(for: place.placeableId, name: place.placeableName, location: place.placeableCoordinate)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplayingReviews()
    }

    private func addOrUpdateMapView(for placeId: String, name: String, location: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16.0)

        if let dynamicMapView = dynamicMapView {
            dynamicMapView.animate(to: camera)
            addOrUpdateMarkerAndReviews(for: placeId,
                                        name: name,
                                        location: location,
                                        in: dynamicMapView)
        } else {
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let mapViewNew = GMSMapView.map(withFrame: frame, camera: camera)

            dynamicMapView = mapViewNew

            guard let dynamicMapView = dynamicMapView else { return }
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubview(toBack: dynamicMapView)
            addOrUpdateMarkerAndReviews(for: placeId,
                                        name: name,
                                        location: location,
                                        in: dynamicMapView)
        }
    }

    private func addOrUpdateMarkerAndReviews(for placeId: String, name: String, location: CLLocationCoordinate2D, in mapView: GMSMapView) {
        if let marker = dynamicMarker {
            marker.map = nil // clears prev marker
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

        guard let dynamicMarker = dynamicMarker else { return }

        mapView.selectedMarker = dynamicMarker

        dynamicMarker.tracksInfoWindowChanges = true

        networkService.getPlace(with: placeId, success: { [weak self] place in
            dynamicMarker.snippet = self?.createSnippet(for: place)
            dynamicMarker.tracksInfoWindowChanges = false
            self?.place = place
            self?.displayReviews(place.placeableReviews)
        }, failure: { [weak self] error in
            self?.logErrorEvent(error)
        })
    }

    private func createSnippet(for place: Placeable) -> String {
        var snippet = ""

        if let formattedAddress = place.placeableFormattedAddress {
            snippet += formattedAddress
        }

        if let phoneNumber = place.placeableFormattedPhoneNumber {
            snippet += "\n\(phoneNumber)"
        }

        return snippet
    }

    private func displayReviews(_ reviews: [Reviewable]?) {
        guard let reviews = reviews, !reviews.isEmpty else { return }
        loadReviewContent(reviews[0])
        reviewView.isHidden = false
        reviewView.alpha = 1
        startDisplayingReviews(reviews, index: 1)
    }

    private func startDisplayingReviews(_ reviews: [Reviewable], index: Int) {
        if index < reviews.count - 1 {
            UIView.animate(withDuration: 0.8, animations: {
                self.reviewView.subviews.forEach { $0.alpha = 1 }
            }, completion: { finished in
                if finished {
                    UIView.animate(withDuration: 0.8, delay: 4, animations: {
                        self.reviewView.subviews.forEach { $0.alpha = 0 }
                    }, completion: { finished in
                        if finished {
                            self.loadReviewContent(reviews[index])
                            self.startDisplayingReviews(reviews, index: index + 1)
                        }
                    })
                }
            })
        } else {
            UIView.animate(withDuration: 0.8, animations: {
                self.reviewView.alpha = 0
            }, completion: { _ in
                self.reviewView.isHidden = true
            })
        }
    }

    private func stopDisplayingReviews() {
        reviewView.subviews.forEach { $0.layer.removeAllAnimations() }
        reviewView.layer.removeAllAnimations()
        reviewView.alpha = 0
        reviewView.isHidden = true
    }

    private func loadReviewContent(_ review: Reviewable) {
        authorLabel.text = review.author

        let stars: [UIImageView] = [star5, star4, star3, star2, star1]
        for i in 0..<review.rating {
            stars[i].image = #imageLiteral(resourceName: "filledStarIcon")
        }

        reviewLabel.text = review.review ?? ""
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        logEvent(contentType: "tapped POI on map")
        stopDisplayingReviews()
        addOrUpdateMapView(for: placeID, name: name, location: location)
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        logEvent(contentType: "tapped info window on map")
        if let mapUrl = place?.placeableMapUrl, let url = URL(string: mapUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}
