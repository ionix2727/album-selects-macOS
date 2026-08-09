import SwiftUI
import AppKit

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        VStack(spacing: 18) {
            if let icon = NSApp.applicationIconImage {
                Image(nsImage: icon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
            }

            Text("Album Selects")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            VStack(spacing: 8) {
                HStack {
                    Text("Dezvoltator:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("Rinculescu Ion")
                }

                HStack {
                    Text("Site:")
                        .fontWeight(.semibold)
                    Spacer()
                    Link("www.fxstudio.ro", destination: URL(string: "https://www.fxstudio.ro")!)
                }

                HStack {
                    Text("Telefon:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("+40750400949")
                }

                HStack {
                    Text("Versiune:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(appVersion) (\(buildNumber))")
                }
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .frame(maxWidth: 320)

            Divider()

            Text("Aplicație pentru selectarea fotografiilor pentru album.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .padding(28)
        .frame(width: 420, height: 320)
    }
}

#Preview {
    AboutView()
}
