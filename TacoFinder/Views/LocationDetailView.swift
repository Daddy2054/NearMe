import SwiftUI
import CoreLocation
import MapKit

struct LocationDetailView: View {
    let place: Place
    let userLocation: CLLocation?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Place Name
                Text(place.name)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 10)
                
                // Address Section
                VStack(alignment: .leading, spacing: 8) {
                 
                    Text("📍 Address: \(place.fullAddress)")
                            .font(.subheadline)
                   
                    
                    if let distance = calculateDistance() {
                        Text("📏 Distance: \(distance) away")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 4)
                
                // Location Information Section
                VStack(alignment: .leading, spacing: 8) {
                    if let postalCode = place.postalCode {
                        Text("📮 Postal Code: \(postalCode)")
                            .font(.subheadline)
                    }
                    
                    if let locality = place.locality {
                        Text("🏙 City: \(locality)")
                            .font(.subheadline)
                    }
                    
                    if let administrativeArea = place.administrativeArea {
                        Text("🏛 State/Province: \(administrativeArea)")
                            .font(.subheadline)
                    }
                    
                    if let country = place.country {
                        Text("🌍 Country: \(country)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 4)
                
                Divider()
                    .padding(.vertical, 10)
                
                // Driving Directions Buttons
                Text("Get Directions")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                VStack(spacing: 16) {
                    Button(action: openInAppleMaps) {
                        HStack {
                            Image(systemName: "map")
                            Text("Apple Maps")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                    
                    Button(action: openInGoogleMaps) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Google Maps")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                    
                    Button(action: openInWaze) {
                        HStack {
                            Image(systemName: "car.fill")
                            Text("Waze")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                }
            }
            .padding()
        }
    }

    // Helper to calculate and format distance between user and place based on the user's locale
    func calculateDistance() -> String? {
        guard let userLocation = userLocation else { return nil }
        let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        let distanceInMeters = userLocation.distance(from: placeLocation)
        
        // Convert to appropriate distance unit based on user's locale
        let measurement = Measurement(value: distanceInMeters, unit: UnitLength.meters)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale  // Automatically selects kilometers or miles based on locale
        formatter.numberFormatter.maximumFractionDigits = 2  // Format to 2 decimal places

        // Return formatted distance string (e.g., "5.23 km" or "3.24 mi")
        return formatter.string(from: measurement)
    }

    // Function to open the location in Apple Maps
    func openInAppleMaps() {
        let placemark = MKPlacemark(coordinate: place.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // Function to open the location in Google Maps
    func openInGoogleMaps() {
        let url = URL(string: "comgooglemaps://?daddr=\(place.coordinate.latitude),\(place.coordinate.longitude)&directionsmode=driving")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // If Google Maps is not installed, open the URL in the browser
            let fallbackURL = URL(string: "https://maps.google.com/?daddr=\(place.coordinate.latitude),\(place.coordinate.longitude)&directionsmode=driving")!
            UIApplication.shared.open(fallbackURL)
        }
    }
    
    // Function to open the location in Waze
    func openInWaze() {
        let url = URL(string: "waze://?ll=\(place.coordinate.latitude),\(place.coordinate.longitude)&navigate=yes")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // If Waze is not installed, open the URL in the browser
            let fallbackURL = URL(string: "https://www.waze.com/ul?ll=\(place.coordinate.latitude),\(place.coordinate.longitude)&navigate=yes")!
            UIApplication.shared.open(fallbackURL)
        }
    }
}
