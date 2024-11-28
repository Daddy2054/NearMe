import SwiftUI
import MapKit
import Observation

struct ContentView: View {
    @State private var locationManager = LocationManager()
    @State private var selectedPlace: Place?
    @State private var searchText: String = ""
    
    let commonPlaces = ["Restaurant", "Cafe", "Tacos", "Park", "Museum", "Hotel", "Airport"]

    var body: some View {
        VStack {
            // Search Bar
            TextField("Search for a place", text: $searchText, onCommit: {
                locationManager.searchPlaces(query: searchText)
            })
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Horizontal ScrollView for common places
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(commonPlaces, id: \.self) { place in
                        Button(action: {
                            searchText = place
                            locationManager.searchPlaces(query: place)
                        }) {
                            Text(place)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            
            // Map View
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationManager.places) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                        .onTapGesture {
                            selectedPlace = place
                        }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestLocationPermission()
            }
            .alert(isPresented: $locationManager.showingAlert) {
                Alert(title: Text("Error"), message: Text(locationManager.errorMessage), dismissButton: .default(Text("OK")))
            }

        }
        .sheet(item: $selectedPlace) { place in
            LocationDetailView(place: place, userLocation: locationManager.location)
        }
    }
}

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    var places: [Place] = []
    var showingAlert = false
    var errorMessage = ""
    var location: CLLocation?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func findTacoPlaces() {
        guard let userLocation = locationManager.location else {
            errorMessage = "Unable to get your location."
            showingAlert = true
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Taco"
        request.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showingAlert = true
            } else if let mapItems = response?.mapItems {
                self?.places = mapItems.map { Place(placemark: $0.placemark) }
            }
        }
    }

    func searchPlaces(query: String) {
        guard let userLocation = locationManager.location else {
            errorMessage = "Unable to get your location."
            showingAlert = true
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showingAlert = true
            } else if let mapItems = response?.mapItems {
                self?.places = mapItems.map { Place(placemark: $0.placemark) }
            }
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation() // Stop after getting the location to save battery.
            self.location = location
            region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to get your location: \(error.localizedDescription)"
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
