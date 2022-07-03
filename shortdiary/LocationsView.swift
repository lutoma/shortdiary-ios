import SwiftUI
import MapKit

struct LocationsView: View {
    @EnvironmentObject var postStore: PostStore

    func regionThatFitsTo(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        for coordinate in coordinates {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude)
        }

        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        return region
    }

    @State private var mapRegion = MKCoordinateRegion()
    var body: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: postStore.postsWithLocation) { post in
            MapMarker(coordinate: post.location!)
        }
        .onChange(of: postStore.postsWithLocation) { _ in
             /*if !postStore.postsWithLocation.isEmpty {
                  mapRegion = regionThatFitsTo(coordinates: postStore.postsWithLocation.map { $0.location! })
             }*/
        }
        .ignoresSafeArea(edges: .top)
            
    }
}
