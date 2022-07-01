import SwiftUI

private let calendar = Calendar.current
private let dateFormatter = DateFormatter()
private let decoder = JSONDecoder()

struct TimelinePostGroup: Hashable, Identifiable {
    var id: Date { date }
    let date: Date
    let posts: [Post]
}

private func loadPost(rawPost: EncryptedPost) -> Post {
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

    var bodyData : EncryptedPostBody
    do {
        bodyData = try decoder.decode(EncryptedPostBody.self, from: rawData)
    } catch let error {
        print(error)
        return Post(text: "Decoding JSON body failed: \(error.localizedDescription)")
    }

    let location_lat = Double(bodyData.location_lat ?? "")
    let location_lon = Double(bodyData.location_lon ?? "")

    var location_verbose: String? = nil
    if bodyData.location_verbose != nil && bodyData.location_verbose != "" {
        location_verbose = bodyData.location_verbose
    }

    let date = dateFormatter.date(from: rawPost.date)!
    return Post(date: date, text: bodyData.text, location_verbose: location_verbose,
        location_lat: location_lat, location_lon: location_lon, mood: bodyData.mood, tags: bodyData.tags)
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
                    let data = try response.map([EncryptedPost].self)

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


