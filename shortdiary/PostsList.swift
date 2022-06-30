import SwiftUI

struct PostsList: View {
    @EnvironmentObject var postStore: PostStore
    @State private var isAddingNewPost = false
    @State private var newPost = Post()
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(postStore.postsByYear) { group in
                Section(content: {
                    ForEach(group.posts) { post in
                        NavigationLink {
                            PostDetail(post: post)
                        } label: {
                            PostRow(post: post)
                        }
                    }
                }, header: {
                    Text(String(group.year))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                })
                .headerProminence(.increased)
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
        .searchable(text: $searchText)
    }
}
