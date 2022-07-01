import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        List {
            Section(footer: Text("Signed in in as \(authStore.auth.user!.email)")) {
                Button {
                    authStore.logout()
                } label: {
                    Text("Sign out")
                }
            }
            
        }
    }
}
