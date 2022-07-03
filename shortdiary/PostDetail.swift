import SwiftUI
import MapKit

struct PostDetail: View {
    //@Binding var post: Post

    @EnvironmentObject var postStore: PostStore
    @Environment(\.dismiss) private var dismiss

    var post: Post = Post()

    init(post: Post) {
        self.post = post
        UIScrollView.appearance().bounces = false
    }

    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 9.2)
    )
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    if let location = post.location {
                        Map(coordinateRegion: $mapRegion, interactionModes: [])
                            .frame(height: 200)
                            .onAppear {
                                mapRegion = MKCoordinateRegion(
                                    center: location,
                                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                                )
                                //MKMapView.appearance().mapType = .mutedStandard
                            }
                    } else {
                        Color("ShortdiaryGreen")
                            .padding(0)
                            .frame(height: 200)
                    }

                   Spacer()
                }

                VStack {
                    Text(post.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)

                    HStack {
                        Label("\(post.mood)", systemImage: "face.smiling")
                            .foregroundColor(.white)
                            .fontWeight(.light)

                        if let name = post.location_verbose {
                            Label(name, systemImage: "map")
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                    }
                    .padding([.top], 5)

                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag)
                            .padding([.top, .bottom], 3)
                            .padding([.leading, .trailing], 8)
                            .font(.subheadline)
                            .background(Color("ShortdiaryGold"))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding([.top], 90)

                VStack {
                    Text(post.text)
                        //.textSelection(.enabled)
                        .padding()
                        .padding([.top], 30)

                }
                .padding([.top], 190)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        //.navigationBarTitle(post.date.formatted(date: .abbreviated, time: .omitted), displayMode: .inline)
        .toolbar {
            ToolbarItem {
                Button {
                    print("editing")
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }
}
