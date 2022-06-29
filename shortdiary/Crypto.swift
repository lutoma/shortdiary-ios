import Foundation
//import Sodium

let decoder = JSONDecoder()
//let sodium = Sodium()

func decryptPost(rawPost: EncryptedPost) -> Post {
    if rawPost.format_version != 0 {
        return Post(text: "Unsupported format version")
    }
    
    var bodyData : EncryptedPostBody
    do {
        let rawData = rawPost.data.data(using: .utf8)!
        bodyData = try decoder.decode(EncryptedPostBody.self, from: rawData)
    } catch let error {
        print(error)
        return Post(text: "Decryption failed: \(error.localizedDescription)")
    }
    
    let location_lat = Double(bodyData.location_lat ?? "")
    let location_lon = Double(bodyData.location_lon ?? "")
    
    //return Post(date: rawPost.date, text: bodyData.text, location_verbose: bodyData.location_verbose, location_lat: location_lat, location_lon: location_lon, mood: bodyData.mood, tags: bodyData.tags)
    return Post(text: bodyData.text, location_verbose: bodyData.location_verbose, location_lat: location_lat, location_lon: location_lon, mood: bodyData.mood, tags: bodyData.tags)
}

func decryptPosts(encryptedPosts: [EncryptedPost]) -> [Post] {
    let posts : [Post] = encryptedPosts.map {
        decryptPost(rawPost: $0)
    }
    return posts
}
