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
import SnapKit

// swiftlint:disable type_body_length
final class MapViewController: UIViewController {

    var place: Placeable?
    var dynamicMapView: GMSMapView?
    var dynamicMarker: GMSMarker?
    var currentReviews: [Reviewable]?
    var currentReviewIndex = 0
    var isViewingDarkMode = false

    private let networkService = NetworkService()
    
    @IBOutlet weak var reviewView: DesignableView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!

    // contains close and dark mode buttons (and creates frame for gradient)
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        return layer
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "mapCloseIconSoftShadow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var darkModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "nightIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(darkModeButtonTapped), for: .touchUpInside)
        return button
    }()

    @IBAction func reviewViewTapped(_ sender: UITapGestureRecognizer) {
        guard let reviews = currentReviews, let authorUrl = reviews[currentReviewIndex].authorUrl else {
            return
        }
        openUrl(authorUrl)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopDisplayingReviews),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartDisplayingCurrentReviews),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        reviewView.isHidden = true

        addOrUpdateMapView(for: place?.placeableId, name: place?.placeableName, location: place?.placeableCoordinate)
        addMapHeader()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplayingReviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame = containerView.bounds
    }

    /// Map header includes a gradient so that buttons are easier to see and creates a pannable section above the map view
    /// so users can dismiss.
    private func addMapHeader() {
        view.addSubview(containerView)
        containerView.layer.addSublayer(gradientLayer)
        containerView.addSubview(closeButton)
        containerView.addSubview(darkModeButton)

        containerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(60)
        }

        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(18)
            make.height.equalTo(48)
        }

        darkModeButton.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(18)
            make.height.equalTo(48)
        }
    }

    private func addOrUpdateMapView(for placeId: String?, name: String?, location: CLLocationCoordinate2D?) {
        guard let placeId = placeId, let name = name, let location = location else {
            return
        }

        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: 16.0)

        if let dynamicMapView = dynamicMapView {
            dynamicMapView.animate(to: camera)
            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
        } else {
            let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let mapViewNew = GMSMapView.map(withFrame: frame, camera: camera)

            dynamicMapView = mapViewNew

            guard let dynamicMapView = dynamicMapView else {
                return
            }
            dynamicMapView.delegate = self
            view.addSubview(dynamicMapView)
            view.sendSubviewToBack(dynamicMapView)
            addOrUpdateMarkerAndReviews(for: placeId, name: name, location: location, in: dynamicMapView)
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

        guard let dynamicMarker = dynamicMarker else {
            return
        }

        mapView.selectedMarker = dynamicMarker

        dynamicMarker.tracksInfoWindowChanges = true

        networkService.getPlace(with: placeId, success: { [weak self] place in
            guard let strongSelf = self else {
                return
            }
            dynamicMarker.snippet = strongSelf.createSnippet(for: place)
            dynamicMarker.tracksInfoWindowChanges = false
            strongSelf.place = place
            DispatchQueue.main.async {
                strongSelf.displayReviews(place.placeableReviews, index: 0)
            }
        }, failure: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.logErrorEvent(error)
        })
    }

    // MARK: - Marker-specific methods

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

    // MARK: - Review-specific methods

    private func displayReviews(_ reviews: [Reviewable]?, index: Int) {
        guard let reviews = reviews, !reviews.isEmpty else {
            return
        }
        currentReviews = reviews
        currentReviewIndex = index
        loadReviewContent(reviews[index])
        reviewView.isHidden = false
        reviewView.alpha = 1

        if ProcessInfo.processInfo.environment["isUITest"] == "true" {
            displayReviewForUITest(reviews)
        } else {
            startDisplayingReviews(reviews, index: index + 1)   
        }
    }

    private func startDisplayingReviews(_ reviews: [Reviewable], index: Int) {
        if index < reviews.count - 1 {
            UIView.animate(withDuration: 0.7, animations: {
                self.reviewView.subviews.forEach { $0.alpha = 1 }
            }, completion: { finished in
                if finished {
                    UIView.animate(withDuration: 0.7, delay: 6, animations: {
                        self.reviewView.subviews.forEach { $0.alpha = 0 }
                    }, completion: { finished in
                        if finished {
                            self.currentReviewIndex = index
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

    private func displayReviewForUITest(_ reviews: [Reviewable]) {
        guard let firstReview = reviews.first else {
            return
        }
        reviewView.isHidden = false
        currentReviewIndex = 1
        loadReviewContent(firstReview)
    }

    @objc
    private func restartDisplayingCurrentReviews() {
        guard let reviews = currentReviews else {
            return
        }
        displayReviews(reviews, index: currentReviewIndex)
    }

    @objc
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
        loadImage(from: review.authorProfileUrl)
    }

    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let strongSelf = self, let data = data else {
                return
            }
            DispatchQueue.main.async {
                guard let image = UIImage(data: data) else {
                    return
                }
                strongSelf.fadeInImage(image, forImageView: strongSelf.authorImageView)
            }
        }.resume()
    }

    // MARK: - Button selector methods

    @objc
    private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func darkModeButtonTapped() {
        if isViewingDarkMode {
            dynamicMapView?.mapStyle = nil
            isViewingDarkMode = false
            darkModeButton.setImage(UIImage(named: "nightIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json"), let mapView = dynamicMapView {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                    isViewingDarkMode = true
                    darkModeButton.setImage(UIImage(named: "sunIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            } catch {
                logErrorEvent(error)
            }
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        logEvent(contentType: "POI on map tapped", title)
        stopDisplayingReviews()
        addOrUpdateMapView(for: placeID, name: name, location: location)
    }

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        logEvent(contentType: "info window on marker tapped", title)
        if let mapUrl = place?.placeableMapUrl, let url = URL(string: mapUrl) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension MapViewController: Loggable, ImageViewFadeable {}
