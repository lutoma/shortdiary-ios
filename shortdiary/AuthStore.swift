import Foundation
import Foundation

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

struct AuthData: Codable {
    var jwt: String?
    var masterKey: [UInt8]?
    var user: User?
}

class AuthStore: ObservableObject {
    @Published var auth: AuthData = AuthData()
    
    var isLoggedIn: Bool {
        return self.auth.jwt != nil
    }
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("auth.data")
    }
    
    static func load(completion: @escaping (Result<AuthData, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success(AuthData()))
                    }
                    return
                }
                let authData = try JSONDecoder().decode(AuthData.self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(authData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(authData: AuthData, completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(authData)
                let outfile = try fileURL()
                try data.write(to: outfile)
            } catch {
            }
        }
    }
    
    func logout() {
        self.auth = AuthData()
        AuthStore.save(authData: self.auth) { result in
            if case .failure(let error) = result {
                fatalError(error.localizedDescription)
            }
        }
    }
}
