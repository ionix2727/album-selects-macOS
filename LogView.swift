import SwiftUI

struct LogView: View {
    @EnvironmentObject var logStore: AppLogStore

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if logStore.lines.isEmpty {
                        Text("Nu există încă detalii de afișat.")
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    } else {
                        ForEach(Array(logStore.lines.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 2)
                                .id(index)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: logStore.lines.count) { _ in
                if let lastIndex = logStore.lines.indices.last {
                    proxy.scrollTo(lastIndex, anchor: .bottom)
                }
            }
        }
        .frame(minWidth: 760, minHeight: 420)
    }
}

#Preview {
    LogView()
        .environmentObject(AppLogStore())
}
