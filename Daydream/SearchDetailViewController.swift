//
//  SearchDetailViewController.swift
//  Daydream
//
//  Created by Raymond Kim on 2/19/18.
//  Copyright © 2018 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import GoogleMaps

class SearchDetailViewController: UIViewController {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var mapView: GMSMapView?
    var placeData: GMSPlace?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeCardsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAutocompleteVC()
        configureTableView()
        addSearchController()
        
        if let place = placeData {
            titleLabel.text = place.name
            loadPhotoForPlace(placeId: place.placeID, completion: { photo in
                self.placeImageView.image = photo
                self.placeImageView.contentMode = .scaleAspectFill
            })
        } else {
            // show default background screen
        }
    }
    
    // MARK: - IBActions
    @IBAction func homeBtnTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Search
    private func addSearchController() {
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.searchBarStyle = .minimal
        searchController?.setStyle()
        
        // filter autocomplete results by only showing cities and set styling
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .city
        resultsViewController?.autocompleteFilter = autocompleteFilter
        resultsViewController?.setStyle()
        
        let subView = UIView(frame: CGRect(x: 0, y: 128.0, width: view.bounds.width, height: 45.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }
    
    private func updateUI(withPlace place: GMSPlace) {
        titleLabel.text = place.name
        placeCardsTableView.reloadData()
        
        loadPhotoForPlace(placeId: place.placeID) { photo in
            self.placeImageView.image = photo
            self.placeImageView.contentMode = .scaleAspectFill
        }

    }
    
    private func loadPhotoForPlace(placeId: String, completion: @escaping(_ photo: UIImage?) -> Void) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId) { (photos, error) in
            if let error = error {
                // TODO: handle error
                print("Error: \(error.localizedDescription)")
                completion(nil)
            } else {
                if let firstPhoto = photos?.results.first {
                    GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: { (photo, error) in
                        if let error = error {
                            // TODO: handle error
                            print("Error: \(error.localizedDescription)")
                            completion(nil)
                        } else {
                            completion(photo)
                        }
                    })
                }
            }
        }
    }
    
    private func configureAutocompleteVC() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
    }
    
    private func configureTableView() {
        placeCardsTableView.dataSource = self
        placeCardsTableView.delegate = self
        placeCardsTableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView datasource and delegate methods
extension SearchDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "mapCardCell", for: indexPath) as? MapCardCell {
            
            cell.place = placeData
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // for viewport, enter GMSCoordinateBounds object
        guard let viewport = placeData?.viewport else { return }
        
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        
        present(placePicker, animated: true, completion: nil)
    }
}

// MARK: - GooglePlaces Autocomplete methods
extension SearchDetailViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    // Handle user's selection
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        
        searchController?.searchBar.text = nil // reset to search bar text
        
        dismiss(animated: true, completion: {
            self.placeData = place
            self.updateUI(withPlace: place)
        })
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

// MARK: - GooglePlacePicker methods
extension SearchDetailViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
//        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
