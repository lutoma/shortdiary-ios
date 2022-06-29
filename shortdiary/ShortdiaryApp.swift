import SwiftUI
import Moya

let authStore = AuthStore()

@main
struct ShortdiaryApp: App {
    @StateObject private var postData = PostData()
    
    func loadAuth() {
        AuthStore.load { result in
            switch result {
            case .failure(let error):
                fatalError(error.localizedDescription)
            case .success(let auth):
                authStore.auth = auth
                
                if auth.jwt != nil && auth.masterKey != nil {
                    isLoggedIn = true
                }
            }
        }
    }
    
    func loadData() {
        api.request(.showPosts) { result in
            switch result {
                case let .success(moyaResponse):
                do {
                    let response = try moyaResponse.filterSuccessfulStatusCodes()
                    let data = try response.map([EncryptedPost].self)
                    postData.loadPosts(encryptedPosts: data)
                } catch let err {
                    print("riperoni", err)
                }
                case let .failure(error):
                print("api request failure", error)
            }
        }
    }
    
    @State var isLoggedIn: Bool = false
    var body: some Scene {
        WindowGroup {
            if !isLoggedIn {
                LoginView(isLoggedIn: $isLoggedIn)
                    .onAppear(perform: loadAuth)
            } else {
                NavigationView {
                    PostsList()
                    Text("Select a Post")
                        .foregroundStyle(.secondary)
                }
                .environmentObject(postData)
                .onAppear(perform: loadData)
            }
        }
    }
}
