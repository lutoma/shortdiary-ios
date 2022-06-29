import Foundation
import SwiftUI

struct AuthData: Codable {
    var jwt: String?
}

class AuthStore: ObservableObject {
    @Published var auth: AuthData = AuthData()
    
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
}
