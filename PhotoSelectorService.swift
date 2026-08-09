import Foundation

struct SelectionResult {
    let copiedCount: Int
    let totalItems: Int
    let shortStatus: String
    let missing: [String]
    let ambiguous: [String]
    let logs: [String]
}

final class PhotoSelectorService {

    private let destinationFolderName = "Selecții pentru albumul foto"
    private let allowedExtensions = ["jpg", "jpeg", "png", "tif", "tiff", "bmp", "webp", "heic"]

    func process(photoFolderURL: URL, listFileURL: URL) throws -> SelectionResult {
        let photoFiles = try loadPhotoFiles(from: photoFolderURL)
        let listItems = try loadListItems(from: listFileURL)

        let destinationURL = photoFolderURL.appendingPathComponent(destinationFolderName, isDirectory: true)
        try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)

        var copiedCount = 0
        var missing: [String] = []
        var ambiguous: [String] = []
        var logs: [String] = []
        var copiedNames = Set<String>()

        for item in listItems {
            let matches = findMatches(for: item, in: photoFiles)

            if matches.count == 1, let sourceURL = matches.first {
                let destinationFileURL = destinationURL.appendingPathComponent(sourceURL.lastPathComponent)

                if !copiedNames.contains(sourceURL.lastPathComponent.lowercased()) {
                    if FileManager.default.fileExists(atPath: destinationFileURL.path) {
                        try? FileManager.default.removeItem(at: destinationFileURL)
                    }

                    try FileManager.default.copyItem(at: sourceURL, to: destinationFileURL)
                    copiedNames.insert(sourceURL.lastPathComponent.lowercased())
                    copiedCount += 1
                    logs.append("✓ \(item) -> \(sourceURL.lastPathComponent)")
                } else {
                    logs.append("= \(item) -> deja copiat")
                }
            } else if matches.count > 1 {
                ambiguous.append(item)
                logs.append("! \(item) -> ambiguu (\(matches.count) variante)")
            } else {
                missing.append(item)
                logs.append("✗ \(item) -> negăsit")
            }
        }

        let reportURL = destinationURL.appendingPathComponent("raport_selectie_album.txt")
        let report = buildReport(copiedCount: copiedCount, missing: missing, ambiguous: ambiguous, logs: logs)
        try report.write(to: reportURL, atomically: true, encoding: .utf8)

        return SelectionResult(
            copiedCount: copiedCount,
            totalItems: listItems.count,
            shortStatus: "S-au selectat \(copiedCount) repere din \(listItems.count) repere din listă.",
            missing: missing,
            ambiguous: ambiguous,
            logs: logs
        )
    }

    private func loadPhotoFiles(from folderURL: URL) throws -> [URL] {
        let items = try FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        return items.filter { url in
            allowedExtensions.contains(url.pathExtension.lowercased())
        }
    }

    private func loadListItems(from fileURL: URL) throws -> [String] {
        let ext = fileURL.pathExtension.lowercased()

        switch ext {
        case "csv", "txt":
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return parsePlainText(content)

        case "xlsx", "xls", "doc", "docx":
            throw NSError(
                domain: "PhotoSelectorService",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Momentan sunt implementate CSV și TXT. Excel și Word le adăugăm în pasul următor."]
            )

        default:
            throw NSError(
                domain: "PhotoSelectorService",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Format de fișier neacceptat. Folosește CSV sau TXT."]
            )
        }
    }

    private func parsePlainText(_ content: String) -> [String] {
        content
            .components(separatedBy: .newlines)
            .flatMap { line in
                line.split(whereSeparator: { $0 == "," || $0 == ";" || $0 == "\t" })
                    .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            }
            .map { normalizeFileName($0) }
            .filter { !$0.isEmpty }
    }

    private func normalizeFileName(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileName = URL(fileURLWithPath: trimmed).lastPathComponent
        return fileName
    }

    private func findMatches(for item: String, in photoFiles: [URL]) -> [URL] {
        let itemNumbers = extractNumbers(from: normalizeFileName(item).lowercased())

        guard !itemNumbers.isEmpty else {
            return []
        }

        return photoFiles.filter { photoURL in
            let photoName = photoURL.deletingPathExtension().lastPathComponent.lowercased()
            let photoNumbers = extractNumbers(from: photoName)
            return !photoNumbers.isEmpty && !itemNumbers.isDisjoint(with: photoNumbers)
        }
    }

    private func extractNumbers(from value: String) -> Set<String> {
        let pattern = "\\d+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let range = NSRange(value.startIndex..<value.endIndex, in: value)
        let matches = regex.matches(in: value, range: range)

        return Set(matches.compactMap { match in
            guard let r = Range(match.range, in: value) else { return nil }
            return String(value[r])
        })
    }

    private func buildReport(copiedCount: Int, missing: [String], ambiguous: [String], logs: [String]) -> String {
        var lines: [String] = []
        lines.append("Copiate: \(copiedCount)")
        lines.append("Negăsite: \(missing.count)")
        lines.append("Ambigue: \(ambiguous.count)")
        lines.append("")

        if !missing.isEmpty {
            lines.append("Negăsite:")
            lines.append(contentsOf: missing.map { "- \($0)" })
            lines.append("")
        }

        if !ambiguous.isEmpty {
            lines.append("Ambigue:")
            lines.append(contentsOf: ambiguous.map { "- \($0)" })
            lines.append("")
        }

        lines.append("Jurnal:")
        lines.append(contentsOf: logs)

        return lines.joined(separator: "\n")
    }
}
