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
                    
                    let user = data.user
                    
                    print("Logged in, user data: ", user)
                    if let masterKey = cryptoUnlock(password: self.password, salt: user.ephemeral_key_salt, masterNonce: user.master_key_nonce, encryptedMaster: user.master_key) {
                        
                        authStore.auth.masterKey = masterKey
                        print("Have unlocked master key!")
                        self.isLoggedIn = true
                        print("authStore.isLoggedin is now", authStore.isLoggedIn)
                    } else {
                        print("Decryption of master key failed")
                    }
                    
                    AuthStore.save(authData: authStore.auth) { result in
                        if case .failure(let error) = result {
                            fatalError(error.localizedDescription)
                        }
                    }
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
        ZStack {
            Color("ShortdiaryGreen")
                .ignoresSafeArea()

            VStack {
                Text("Sign in to shortdiary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                    .foregroundColor(.white)
                
                TextField(
                    "Email address",
                    text: $username
                )
                .onSubmit {
                    signIn()
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                
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
}

