import SwiftUI

struct PostRow: View {
    let post: Post
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(post.date.formatted(date: .abbreviated, time: .omitted))
                    .fontWeight(.bold)

                HStack {
                    if post.location_verbose != nil && post.location_verbose != "" {
                        Text(post.location_verbose!)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(post.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(4)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .background(Color.orange)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .badge(post.mood)
    }
}
