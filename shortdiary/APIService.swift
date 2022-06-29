import Foundation
import Moya

var APIToken = ""
private let authPlugin = AccessTokenPlugin { _ in authStore.auth.jwt ?? "" }
let api = MoyaProvider<APIService>(plugins: [authPlugin])

enum APIService {
    case login(email: String, password: String)
    case showUser
    case showPosts
}

extension APIService: TargetType, AccessTokenAuthorizable {
    var baseURL: URL { URL(string: "https://api.beta.shortdiary.com")! }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .showUser:
            return "/auth/user"
        case .showPosts:
            return "/posts"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        case .showUser, .showPosts:
            return .get
        }
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .login:
            return nil
        case .showUser, .showPosts:
            return .bearer
        }
    }
    
    var task: Task {
        switch self {
        case let .login(email, password):
            let usernameData = MultipartFormData(provider: .data(email.data(using: .utf8)!), name: "username")
            let passwordData = MultipartFormData(provider: .data(password.data(using: .utf8)!), name: "password")
            let multipartData = [usernameData, passwordData]
            return .uploadMultipart(multipartData)
        case .showUser, .showPosts:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data { Data(self.utf8) }
}
