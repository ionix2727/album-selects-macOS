import SwiftUI

@main
struct Album_SelectsApp: App {
    @StateObject private var logStore = AppLogStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(logStore)
        }

        Window("Despre Album Selects", id: "about-window") {
            AboutView()
        }
        .windowResizability(.contentSize)

        Window("Ajutor", id: "help-window") {
            HelpView()
        }
        .windowResizability(.contentSize)

        Window("Detalii procesare", id: "log-window") {
            LogView()
                .environmentObject(logStore)
        }
        .windowResizability(.contentSize)

        Settings {
            VStack(alignment: .leading, spacing: 12) {
                Text("Setări")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Text("Aici poți adăuga în viitor opțiuni precum preferințe de potrivire, formate acceptate sau reguli de selecție.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 460, height: 220, alignment: .topLeading)
            .padding(24)
        }
    }
}
