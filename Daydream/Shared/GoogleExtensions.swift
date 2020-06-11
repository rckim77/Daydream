//
//  GoogleExtensions.swift
//  Daydream
//
//  Created by Raymond Kim on 6/3/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import GooglePlaces
import GoogleMaps

//extension GMSPlace: Placeable {
//    var placeableId: String {
//        return self.placeID ?? ""
//    }
//
//    var placeableName: String {
//        return self.name ?? ""
//    }
//
//    var placeableFormattedAddress: String? {
//        return self.formattedAddress
//    }
//
//    var placeableFormattedPhoneNumber: String? {
//        return self.phoneNumber
//    }
//
//    var placeableRating: Float? {
//        return self.rating
//    }
//
//    var placeableCoordinate: CLLocationCoordinate2D {
//        return self.coordinate
//    }
//
//    var placeableMapUrl: String? {
//        return nil
//    }
//
//    var placeableReviews: [Review]? {
//        return nil
//    }
//
//    /*
//
//     typedef NS_ENUM(NSInteger, GMSPlacesBusinessStatus) {
//       /** The business status is not known. */
//       GMSPlacesBusinessStatusUnknown,
//       /** The business is operational. */
//       GMSPlacesBusinessStatusOperational,
//       /** The business is closed temporarily. */
//       GMSPlacesBusinessStatusClosedTemporarily,
//       /** The business is closed permanently. */
//       GMSPlacesBusinessStatusClosedPermanently,
//     };
//
//     */
//    var placeableBusinessStatus: PlaceBusinessStatus? {
//        switch self.businessStatus {
//        case .operational:
//            return .operational
//        case .closedTemporarily:
//            return .closedTemporarily
//        case .closedPermanently:
//            return .closedPermanently
//        default:
//            return nil
//        }
//    }
//}

extension GMSAutocompleteResultsViewController {
    func setStyle() {
        tableCellBackgroundColor = UIColor.black.withAlphaComponent(0.3)
        primaryTextHighlightColor = .white
        primaryTextColor = .lightGray
        secondaryTextColor = .lightGray
    }

    func setAutocompleteFilter(_ type: GMSPlacesAutocompleteTypeFilter) {
        let filter = GMSAutocompleteFilter()
        filter.type = type
        autocompleteFilter = filter
    }
}

extension GMSMapView {
    func configureMapStyle(isDark: Bool) {
        if isDark {
            guard let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") else {
                return
            }
            mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            mapStyle = nil
        }
    }
}
