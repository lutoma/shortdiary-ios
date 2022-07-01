import SwiftUI
import MapKit

struct PostDetail: View {
    //@Binding var post: Post
    
    @EnvironmentObject var postStore: PostStore
    @Environment(\.dismiss) private var dismiss
    
    var post: Post = Post()
    
    var body: some View {
        /*if (post.location_lat != nil && post.location_lon != nil) {
            $mapRegion.center.latitude = post.location_lat
            $mapRegion.center.longitude = post.location_lon
        }*/
        ScrollView {
            HStack {
                Label("\(post.mood)", systemImage: "face.smiling")
                if post.location_verbose != nil && post.location_verbose != "" {
                    Label(post.location_verbose!, systemImage: "map")
                }
            }
            
            ForEach(post.tags, id: \.self) { tag in
                Text(tag)
                    .padding([.top, .bottom], 3)
                    .padding([.leading, .trailing], 8)
                    .font(.subheadline)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            
            Text(post.text)
                .textSelection(.enabled)
                .padding()
        }
        .navigationTitle(post.date.formatted(date: .abbreviated, time: .omitted))
        .padding([.top], 20)
        //.ignoresSafeArea()
    }
}
