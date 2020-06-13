//
//  PlaceBusinessStatus.swift
//  Daydream
//
//  Created by Raymond Kim on 6/11/20.
//  Copyright © 2020 Raymond Kim. All rights reserved.
//

import UIKit
import GooglePlaces

/* Google Places SDK

 typedef NS_ENUM(NSInteger, GMSPlacesBusinessStatus) {
   /** The business status is not known. */
   GMSPlacesBusinessStatusUnknown,
   /** The business is operational. */
   GMSPlacesBusinessStatusOperational,
   /** The business is closed temporarily. */
   GMSPlacesBusinessStatusClosedTemporarily,
   /** The business is closed permanently. */
   GMSPlacesBusinessStatusClosedPermanently,
 };

 */

enum PlaceBusinessStatus: String, Decodable, Equatable {
    case operational = "OPERATIONAL"
    case closedTemporarily = "CLOSED_TEMPORARILY"
    case closedPermanently = "CLOSED_PERMANENTLY"

    var displayValue: String {
        switch self {
        case .operational:
            return "operational"
        case .closedTemporarily:
            return "closed temporarily"
        case .closedPermanently:
            return "closed permanently"
        }
    }

    var displayColor: UIColor {
        switch self {
        case .operational:
            return .systemGreen
        case .closedTemporarily:
            return .systemOrange
        case .closedPermanently:
            return .systemRed
        }
    }

    var imageName: String? {
        switch self {
        case .closedTemporarily:
            return "exclamationmark.triangle.fill"
        case .closedPermanently:
            return "nosign"
        case .operational:
            return nil
        }
    }
}

extension PlaceBusinessStatus {
    init?(gmsBusinessStatus: GMSPlacesBusinessStatus) {
        switch gmsBusinessStatus {
        case .closedPermanently:
            self = .closedPermanently
        case .closedTemporarily:
            self = .closedTemporarily
        case .operational:
            self = .operational
        case .unknown:
            return nil
        default:
            return nil
        }
    }
}
