import SwiftUI

struct User: Codable {
    var id: UUID
    var email: String
    var email_verified: Bool
    var ephemeral_key_salt: String
    var master_key: String
    var master_key_nonce: String
}

struct LoginResponse: Codable {
    var access_token: String
    var user: User
}

struct EncryptedPost: Codable {
    var id: UUID
    var format_version: Int
    var date: String
    var data: String
    var nonce: String?
}

struct EncryptedPostBody: Codable {
    var text: String
    var location_verbose: String?
    var location_lat: String?
    var location_lon: String?
    var mood: Int
    var tags: [String]
}

struct Post: Identifiable, Hashable {
    var id = UUID()
    var date = Date.now
    var text = ""
    var location_verbose: String?
    var location_lat: Double?
    var location_lon: Double?
    var mood = 6
    var tags: [String] = []
}

