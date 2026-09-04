import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ShelfPanelView: View {
    @EnvironmentObject var service: FileShelfService
    @State private var isTargeted = false

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 12)]

    var body: some View {
        VStack(spacing: 8) {
            if service.items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(service.items) { item in
                            shelfTile(item)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isTargeted ? Color.accentColor : .clear, lineWidth: 2)
        )
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
            return true
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray.and.arrow.down")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text("Drop files here")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shelfTile(_ item: ShelfItem) -> some View {
        VStack(spacing: 4) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: item.url.path))
                .resizable()
                .frame(width: 40, height: 40)
                .onDrag { NSItemProvider(object: item.url as NSURL) }
            Text(item.fileName)
                .font(.system(size: 10))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(width: 72)
        .contextMenu {
            Button("Remove") { service.remove(item) }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                guard let data = data as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                Task { @MainActor in
                    service.add(urls: [url])
                }
            }
        }
    }
}
