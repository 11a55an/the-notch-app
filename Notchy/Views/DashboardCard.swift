import SwiftUI

struct DashboardCard<Content: View, Accessory: View>: View {
    let title: String
    let symbolName: String
    let content: Content
    let accessory: Accessory

    init(
        title: String,
        symbolName: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.title = title
        self.symbolName = symbolName
        self.content = content()
        self.accessory = accessory()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(title, systemImage: symbolName)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                accessory
            }
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

extension DashboardCard where Accessory == EmptyView {
    init(title: String, symbolName: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, symbolName: symbolName, content: content, accessory: { EmptyView() })
    }
}
