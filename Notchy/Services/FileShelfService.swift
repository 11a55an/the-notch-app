import Foundation
import Combine

@MainActor
final class FileShelfService: ObservableObject {
    @Published private(set) var items: [ShelfItem] = []

    func add(urls: [URL]) {
        for url in urls where !items.contains(where: { $0.url == url }) {
            items.append(ShelfItem(url: url))
        }
    }

    func remove(_ item: ShelfItem) {
        items.removeAll { $0.id == item.id }
    }

    func clear() {
        items.removeAll()
    }
}
