import SwiftUI

struct PostsList: View {
    @EnvironmentObject var postData: PostData
    @State private var isAddingNewPost = false
    @State private var newPost = Post()
    
    var body: some View {
        List {
            Section(content: {
                ForEach(postData.sortedPosts()) { $post in
                    NavigationLink {
                        PostDetail(post: $post)
                    } label: {
                        Text(post.date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }, header: {
                Text("2022")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            })
            
            Section(content: {
            }, header: {
                Text("2021")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            })
        }
        .listStyle(.sidebar)
        .navigationTitle("Entries")
        .toolbar {
            ToolbarItem {
                Button {
                    newPost = Post()
                    isAddingNewPost = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingNewPost) {
            NavigationView {
                //PostEditor(post: $newPost, isNew: true)
            }
        }
    }
}
