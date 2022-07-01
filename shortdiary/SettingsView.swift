import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        List {
            Button {
                authStore.logout()
            } label: {
                Text("Sign out")
            }
            
        }
    }
}
