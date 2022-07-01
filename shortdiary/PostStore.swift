import SwiftUI
import MapKit

private let calendar = Calendar.current
private let dateFormatter = DateFormatter()
private let decoder = JSONDecoder()

struct PostEnvelope: Codable, Identifiable {
    var id: UUID
    var format_version: Int
    var date: String
    var data: String
    var nonce: String?
}

struct RawPost: Codable {
    var text: String
    var location_verbose: String?
    var location_lat: String?
    var location_lon: String?
    var mood: Int
    var tags: [String]
}

struct Post: Identifiable {
    var id = UUID()
    var date = Date.now
    var text = ""
    var location_verbose: String?
    var location: CLLocationCoordinate2D?
    var mood = 6
    var tags: [String] = []
}

struct TimelinePostGroup: Identifiable {
    var id: Date { date }
    let date: Date
    let posts: [Post]
}

private func loadPost(rawPost: PostEnvelope) -> Post {
    var rawData: Data

    switch rawPost.format_version {
        case 0:
           rawData = rawPost.data.data(using: .utf8)!

        case 1:
            print("decrypting post with v1")
            if let bytes = decrypt(key: authStore.auth.masterKey!, b64Nonce: rawPost.nonce!, b64CryptData: rawPost.data) {
                rawData =  Data(bytes)
            } else {
                return Post(text: "Decryption failed")
            }

        default:
           return Post(text: "Unsupported format version")
    }

    var bodyData : RawPost
    do {
        bodyData = try decoder.decode(RawPost.self, from: rawData)
    } catch let error {
        print(error)
        return Post(text: "Decoding JSON body failed: \(error.localizedDescription)")
    }

    var location_verbose: String? = nil
    if bodyData.location_verbose != nil && bodyData.location_verbose != "" {
        location_verbose = bodyData.location_verbose
    }

    var location: CLLocationCoordinate2D? = nil
    if bodyData.location_lat != nil && bodyData.location_lat != "" && bodyData.location_lon != nil && bodyData.location_lon != "" {
        if let lat = Double(bodyData.location_lat!), let lon = Double(bodyData.location_lon!) {
            location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }

    let date = dateFormatter.date(from: rawPost.date)!
    return Post(date: date, text: bodyData.text, location_verbose: location_verbose,
                location: location, mood: bodyData.mood, tags: bodyData.tags)
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []

    var groupedPosts: [TimelinePostGroup] {
        let utc = TimeZone(abbreviation: "UTC")!
        return Dictionary(grouping: self.posts, by: { post in
            // This is stupid, but .dateComponents does not seem to allow immediately specifying the components
            // while also specifying a time zone, only one or the other...
            let dc = calendar.dateComponents(in: utc, from: post.date)
            return DateComponents(timeZone: utc, year: dc.year!, month: dc.month!)
        })
        .map({ TimelinePostGroup(date: calendar.date(from: $0.0)!, posts: $0.1) })
        .sorted(by: { $0.date > $1.date })
    }

    func load() async {
        api.request(.showPosts) { result in
            switch result {
                case let .success(moyaResponse):
                do {
                    let response = try moyaResponse.filterSuccessfulStatusCodes()
                    let data = try response.map([PostEnvelope].self)

                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"

                    self.posts = data.map { loadPost(rawPost: $0) }
                } catch let err {
                    print("riperoni", err)
                }
                case let .failure(error):
                print("api request failure", error)
            }
        }
    }
}


