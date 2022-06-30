import SwiftUI

private let calendar = Calendar.current
private let dateFormatter = DateFormatter()
private let decoder = JSONDecoder()

struct PostYearGroup: Hashable, Identifiable {
    var id: Int { year }
    let year: Int
    let posts: [Post]
}

private func loadPost(rawPost: EncryptedPost) -> Post {
    var rawData: Data
    if rawPost.format_version == 0 {
        rawData = rawPost.data.data(using: .utf8)!
    } else if rawPost.format_version == 1 {
        print("decrypting post with v1")
        if let bytes = decrypt(key: authStore.auth.masterKey!, b64Nonce: rawPost.nonce!, b64CryptData: rawPost.data) {
            rawData =  Data(bytes)
        } else {
            return Post(text: "Decryption failed")
        }
    } else {
        return Post(text: "Unsupported format version")
    }
    
    var bodyData : EncryptedPostBody
    do {
        bodyData = try decoder.decode(EncryptedPostBody.self, from: rawData)
    } catch let error {
        print(error)
        return Post(text: "Decryption failed: \(error.localizedDescription)")
    }
    
    let location_lat = Double(bodyData.location_lat ?? "")
    let location_lon = Double(bodyData.location_lon ?? "")
    let date = dateFormatter.date(from: rawPost.date)!

    return Post(date: date, text: bodyData.text, location_verbose: bodyData.location_verbose, location_lat: location_lat, location_lon: location_lon, mood: bodyData.mood, tags: bodyData.tags)
}

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var postsByYear: [PostYearGroup] = []

    func load() async {
        api.request(.showPosts) { result in
            switch result {
                case let .success(moyaResponse):
                do {
                    let response = try moyaResponse.filterSuccessfulStatusCodes()
                    let data = try response.map([EncryptedPost].self)
                    
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    self.posts = data.map {
                        loadPost(rawPost: $0)
                    }
                    
                    let grouped = Dictionary(grouping: self.posts, by: { post in
                        return calendar.dateComponents([.year], from: post.date).year!
                    })
                    
                    self.postsByYear = grouped.map({ di -> PostYearGroup in
                        return PostYearGroup(year: di.0, posts: di.1)
                    }).sorted(by: { $0.year > $1.year })
                } catch let err {
                    print("riperoni", err)
                }
                case let .failure(error):
                print("api request failure", error)
            }
        }
    }
}


