import SwiftUI

struct PostsList: View {
    @EnvironmentObject var postStore: PostStore
    @State private var isAddingNewPost = false
    @State private var newPost = Post()
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(postStore.groupedPosts) { group in
                Section(content: {
                    ForEach(group.posts) { post in
                        NavigationLink {
                            PostDetail(post: post)
                        } label: {
                            PostRow(post: post)
                        }
                    }
                }, header: {
                    Text(group.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                })
                .headerProminence(.increased)
            }

        }
        .listStyle(.plain)
        //.navigationTitle("Entries")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("user")
                } label: {
                    Image(systemName: "person.circle")
                }
            }
                
            ToolbarItem(placement: .principal) {
                Text("Entries")
            }
                
            ToolbarItem {
                Button {
                    newPost = Post()
                    isAddingNewPost = true
                } label: {
                    Image(systemName: "square.and.pencil")
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
