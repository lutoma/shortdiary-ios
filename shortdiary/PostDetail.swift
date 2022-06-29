import SwiftUI
import MapKit

struct PostDetail: View {
    //@Binding var post: Post
    
    @EnvironmentObject var postData: PostData
    @Environment(\.dismiss) private var dismiss
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 9.2)
    )
    
    var post: Post = Post()
    
    var body: some View {
        /*if (post.location_lat != nil && post.location_lon != nil) {
            $mapRegion.center.latitude = post.location_lat
            $mapRegion.center.longitude = post.location_lon
        }*/
        ScrollView {
            Map(coordinateRegion: $mapRegion)
                .frame(width: 300, height: 300)
            
            VStack(alignment: .leading) {
                Text(post.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.title)
                
                if post.location_verbose != nil && post.location_verbose != "" {
                    Text(post.location_verbose ?? "")
                }
                
                HStack {
                    Text("Mood: \(post.mood)")
                        .font(.subheadline)
                    
                    if post.tags.count > 0 {
                        let tagsList = post.tags.joined(separator: ",")
                        Text("Tags: \(tagsList)")
                    }
                }
            }
            //.offset(y: -80)
            
            Text(post.text)
                .padding()
        }
        //.offset(y: -130)
    }
}
