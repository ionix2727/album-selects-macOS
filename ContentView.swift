import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var logStore: AppLogStore

    @State private var photoFolderPath = ""
    @State private var listFilePath = ""
    @State private var statusMessage = "Alege folderul cu fotografii și fișierul listei."
    @State private var isProcessing = false
    @State private var selectedCount = 0
    @State private var totalCount = 0

    @State private var photoFolderURL: URL?
    @State private var listFileURL: URL?

    private let service = PhotoSelectorService()

    var body: some View {
        ZStack {
            NativeTahoeBackground()

            VStack(spacing: 16) {
                headerSection
                contentSection
                Spacer(minLength: 0)
                bottomStatusBar
            }
            .padding(18)
        }
        .frame(minWidth: 760, minHeight: 520)
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: "photo.stack.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Selector Album Foto")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Link("Dezvoltat de fxstudio.ro", destination: URL(string: "https://www.fxstudio.ro")!)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Spacer()

            HStack(spacing: 10) {
                Button("Detalii") {
                    openWindow(id: "log-window")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.regularMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .foregroundStyle(.white.opacity(0.92))

                Button("Ajutor") {
                    openWindow(id: "help-window")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.regularMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .foregroundStyle(.white.opacity(0.92))

                Button("Despre") {
                    openWindow(id: "about-window")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.regularMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .foregroundStyle(.white.opacity(0.92))

                HStack(spacing: 8) {
                    Circle()
                        .fill(isProcessing ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)

                    Text(isProcessing ? "Procesează" : "Pregătit")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.regularMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 2)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Selecție fișiere")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(spacing: 14) {
                adaptiveFieldRow(
                    title: "Folder fotografii",
                    value: photoFolderPath,
                    placeholder: "Nu a fost selectat niciun folder",
                    buttonTitle: "Selectează folderul",
                    icon: "folder",
                    action: choosePhotoFolder
                )

                adaptiveFieldRow(
                    title: "Fișier listă",
                    value: listFilePath,
                    placeholder: "Nu a fost selectat niciun fișier",
                    buttonTitle: "Selectează fișierul",
                    icon: "doc",
                    action: chooseListFile
                )
            }

            adaptiveButtons
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var adaptiveButtons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                primaryActionButton
                resetButton
            }

            VStack(spacing: 12) {
                primaryActionButton
                resetButton
            }
        }
    }

    private var primaryActionButton: some View {
        Button(action: runSelection) {
            HStack(spacing: 10) {
                Image(systemName: isProcessing ? "hourglass" : "sparkles")
                Text(isProcessing ? "Se procesează..." : "Creează selecția")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
        }
        .buttonStyle(NativeGlassPrimaryButtonStyle())
        .disabled(photoFolderURL == nil || listFileURL == nil || isProcessing)
    }

    private var resetButton: some View {
        Button(action: resetForm) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                Text("Resetează")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
        }
        .buttonStyle(NativeGlassSecondaryButtonStyle())
        .disabled(isProcessing)
    }

    private var bottomStatusBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.white.opacity(0.78))

            Text(statusSummary)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.88))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()

            if !photoFolderPath.isEmpty {
                Label("Folder selectat", systemImage: "folder.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.68))
            }

            if !listFilePath.isEmpty {
                Label("Listă selectată", systemImage: "doc.fill")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.68))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var statusSummary: String {
        if isProcessing {
            return "Se procesează lista..."
        }

        if totalCount > 0 {
            return "S-au selectat \(selectedCount) repere din \(totalCount) repere din listă."
        }

        return statusMessage
    }

    private func adaptiveFieldRow(
        title: String,
        value: String,
        placeholder: String,
        buttonTitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.88))

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    pathField(value: value, placeholder: placeholder)
                    fieldButton(title: buttonTitle, icon: icon, action: action)
                        .frame(width: 220)
                }

                VStack(spacing: 10) {
                    pathField(value: value, placeholder: placeholder)
                    fieldButton(title: buttonTitle, icon: icon, action: action)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func pathField(value: String, placeholder: String) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .frame(minHeight: 50)

            Text(value.isEmpty ? placeholder : value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(value.isEmpty ? Color.white.opacity(0.42) : Color.white.opacity(0.92))
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private func fieldButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
        }
        .buttonStyle(NativeGlassSecondaryButtonStyle())
    }

    private func choosePhotoFolder() {
        let panel = NSOpenPanel()
        panel.title = "Alege folderul cu fotografii"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            photoFolderURL = url
            photoFolderPath = url.path
            statusMessage = "Folder selectat."
            logStore.add("Folder selectat: \(url.path)")
        }
    }

    private func chooseListFile() {
        let panel = NSOpenPanel()
        panel.title = "Alege fișierul listei"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [
            .commaSeparatedText,
            .plainText,
            UTType(filenameExtension: "xlsx")!,
            UTType(filenameExtension: "xls")!,
            UTType(filenameExtension: "doc")!,
            UTType(filenameExtension: "docx")!
        ]

        if panel.runModal() == .OK, let url = panel.url {
            listFileURL = url
            listFilePath = url.path
            statusMessage = "Fișier selectat."
            logStore.add("Fișier listă selectat: \(url.path)")
        }
    }

    private func resetForm() {
        photoFolderPath = ""
        listFilePath = ""
        photoFolderURL = nil
        listFileURL = nil
        selectedCount = 0
        totalCount = 0
        statusMessage = "Alege folderul cu fotografii și fișierul listei."
        logStore.clear()
        logStore.add("Formular resetat.")
    }

    private func runSelection() {
        guard let photoFolderURL, let listFileURL else { return }

        isProcessing = true
        statusMessage = "Se procesează lista..."
        selectedCount = 0
        totalCount = 0

        logStore.clear()
        logStore.add("Pornire procesare...")
        logStore.add("Folder fotografii: \(photoFolderURL.path)")
        logStore.add("Fișier listă: \(listFileURL.path)")
        logStore.add("Se încearcă accesarea resurselor selectate de utilizator...")

        DispatchQueue.global(qos: .userInitiated).async {
            let folderAccess = photoFolderURL.startAccessingSecurityScopedResource()
            let fileAccess = listFileURL.startAccessingSecurityScopedResource()

            DispatchQueue.main.async {
                self.logStore.add("Acces folder: \(folderAccess ? "OK" : "NU")")
                self.logStore.add("Acces fișier listă: \(fileAccess ? "OK" : "NU")")
            }

            defer {
                if folderAccess { photoFolderURL.stopAccessingSecurityScopedResource() }
                if fileAccess { listFileURL.stopAccessingSecurityScopedResource() }

                DispatchQueue.main.async {
                    self.logStore.add("Accesul la resurse a fost închis.")
                }
            }

            do {
                DispatchQueue.main.async {
                    self.logStore.add("Procesare în curs...")
                }

                let result = try service.process(
                    photoFolderURL: photoFolderURL,
                    listFileURL: listFileURL
                )

                DispatchQueue.main.async {
                    self.logStore.add("Procesarea s-a încheiat.")
                    self.logStore.add("Repere totale: \(result.totalItems)")
                    self.logStore.add("Repere selectate: \(result.copiedCount)")
                    self.logStore.add("Repere negăsite: \(result.missing.count)")
                    self.logStore.add("Repere ambigue: \(result.ambiguous.count)")
                    self.logStore.add("----- Jurnal detaliat -----")

                    for line in result.logs {
                        self.logStore.add(line)
                    }

                    selectedCount = result.copiedCount
                    totalCount = result.totalItems
                    statusMessage = result.shortStatus
                    isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.logStore.add("Eroare la procesare: \(error.localizedDescription)")
                    selectedCount = 0
                    totalCount = 0
                    statusMessage = "Eroare: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
}

struct NativeTahoeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.13, blue: 0.18),
                Color(red: 0.10, green: 0.18, blue: 0.24),
                Color(red: 0.08, green: 0.12, blue: 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.06))
                .ignoresSafeArea()
        )
    }
}

struct NativeGlassPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.cyan.opacity(configuration.isPressed ? 0.35 : 0.44),
                                Color.blue.opacity(configuration.isPressed ? 0.28 : 0.36)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct NativeGlassSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.92))
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial.opacity(configuration.isPressed ? 0.72 : 0.88))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppLogStore())
}
