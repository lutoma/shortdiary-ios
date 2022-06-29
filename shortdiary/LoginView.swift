import SwiftUI

struct LoginView: View {
    func signIn() {
        api.request(.login(email: self.username, password: self.password)) { result in
            switch result {
            case let .success(moyaResponse):
                do {
                    let response = try moyaResponse.filterSuccessfulStatusCodes()
                    let data = try response.map(LoginResponse.self)
                    APIToken = data.access_token
                    authStore.auth.jwt = data.access_token
                    
                    AuthStore.save(authData: authStore.auth) { result in
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        }
                    }
                    
                    self.isLoggedIn = true
                } catch let err {
                    print("riperoni", err)
                }
            case let .failure(error):
                print("api request failure", error)
            }
        }
    }
    
    @State private var username: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    var body: some View {
        VStack {
            Text("Sign in to shortdiary")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            TextField(
                "Email address",
                text: $username
            )
            .onSubmit {
                signIn()
            }
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            
            SecureField(
                "Password",
                text: $password
            )
            .onSubmit {
                signIn()
            }
            
            Button(action: signIn) {
                Text("Sign In")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
        .frame(maxWidth: 400)
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}
