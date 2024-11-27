//
//  Place.swift
//  TacoFinder
//

//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let fullAddress: String
    let postalCode: String?
    let locality: String?
    let administrativeArea: String?
    let country: String?

    init(placemark: MKPlacemark) {
        self.name = placemark.name ?? "Unknown"
        self.coordinate = placemark.coordinate
        self.address = placemark.thoroughfare ?? "No address available"
        
        // Combine different address components for a full address
        self.fullAddress = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode,
            placemark.country
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
        
        self.postalCode = placemark.postalCode
        self.locality = placemark.locality
        self.administrativeArea = placemark.administrativeArea
        self.country = placemark.country
    }
}
