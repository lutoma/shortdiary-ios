import SwiftUI
import MapKit

struct LocationsView: View {
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 9.2)
    )
    
    var body: some View {
        Map(coordinateRegion: $mapRegion)
            .ignoresSafeArea()
            
    }
}
