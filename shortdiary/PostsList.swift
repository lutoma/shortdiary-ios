import SwiftUI

struct PostsList: View {
    @EnvironmentObject var postStore: PostStore
    @State private var isAddingNewPost = false
    @State private var newPost = Post()
    
    var body: some View {
        List {
            ForEach(postStore.postsByYear) { group in
                Section(content: {
                    ForEach(group.posts) { post in
                        NavigationLink {
                            PostDetail(post: post)
                        } label: {
                            Text(post.date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }, header: {
                    Text(String(group.year))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                })
            }

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
        .refreshable {
            await postStore.load()
        }
        .task {
            await postStore.load()
        }
    }
}
