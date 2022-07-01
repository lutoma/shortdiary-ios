import SwiftUI

struct PostRow: View {
    let post: Post
    
    var body: some View {
        HStack {
            Text("\(Calendar.current.dateComponents([.day], from: post.date).day!)")
                .font(.title)
                .fontWeight(.bold)
                .frame(minWidth: 35)
                .padding([.trailing], 10)

            VStack(alignment: .leading, spacing: 5) {
                Text(post.date.formatted(date: .abbreviated, time: .omitted))
                    .fontWeight(.bold)

                if let name = post.location_verbose {
                    Text(name)
                        .font(.caption2)
                }
                
                Text(post.text.truncate(to: 80))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

extension String {
    func truncate(to limit: Int, ellipsis: Bool = true) -> String {
        if count > limit {
            let truncated = String(prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines)
            return ellipsis ? truncated + "\u{2026}" : truncated
        } else {
            return self
        }
    }
}
