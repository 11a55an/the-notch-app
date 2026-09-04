import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ShelfPanelView: View {
    @EnvironmentObject var service: FileShelfService
    @State private var isTargeted = false

    private let columns = [GridItem(.adaptive(minimum: 68), spacing: 10)]

    var body: some View {
        Group {
            if service.items.isEmpty {
                dropZone
            } else {
                itemsGrid
            }
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            handleDrop(providers)
            return true
        }
    }

    private var dropZone: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 1) {
                Text("Drop Files Here")
                    .font(.system(size: 13, weight: .semibold))
                Text("Upload, move, or share files")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(isTargeted ? 0.08 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    isTargeted ? Color.accentColor : Color.primary.opacity(0.15),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])
                )
        )
    }

    private var itemsGrid: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Shelf", systemImage: "tray.and.arrow.down")
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Clear", action: service.clear)
                    .font(.system(size: 11))
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(service.items) { item in
                        shelfTile(item)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func shelfTile(_ item: ShelfItem) -> some View {
        VStack(spacing: 4) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: item.url.path))
                .resizable()
                .frame(width: 34, height: 34)
                .onDrag { NSItemProvider(object: item.url as NSURL) }
            Text(item.fileName)
                .font(.system(size: 9.5))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(width: 64)
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
