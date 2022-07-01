import SwiftUI

private func monthLabel(date: Date) -> String {
    let monthFormatter = DateFormatter()
    monthFormatter.setLocalizedDateFormatFromTemplate("yyyyMMMM")
    return monthFormatter.string(from: date)
}

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
                    Text(monthLabel(date: group.date))
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                })
                .headerProminence(.increased)
            }

        }
        .listStyle(.sidebar)
        .navigationTitle("Entries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "person.circle")
                }
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
