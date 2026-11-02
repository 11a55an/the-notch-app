import Foundation

struct ShelfItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL

    var fileName: String { url.lastPathComponent }
}
