import Foundation
import Combine

final class AppLogStore: ObservableObject {
    @Published var lines: [String] = []

    func clear() {
        DispatchQueue.main.async {
            self.lines.removeAll()
        }
    }

    func add(_ text: String) {
        DispatchQueue.main.async {
            self.lines.append(text)
        }
    }

    func set(_ items: [String]) {
        DispatchQueue.main.async {
            self.lines = items
        }
    }
}
