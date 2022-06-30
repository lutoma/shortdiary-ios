import SwiftUI
import Moya

let authStore = AuthStore()

@main
struct ShortdiaryApp: App {
    @StateObject private var postStore = PostStore()
    
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
                .environmentObject(postStore)
            }
        }
    }
}
