import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Ajutor")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Cum folosești aplicația")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))

                Group {
                    helpStep(
                        number: "1",
                        title: "Selectează folderul cu fotografii",
                        text: "Apasă pe butonul „Selectează folderul” și alege folderul în care se află toate fotografiile din eveniment."
                    )

                    helpStep(
                        number: "2",
                        title: "Selectează fișierul cu lista",
                        text: "Apasă pe butonul „Selectează fișierul” și alege fișierul CSV sau TXT care conține numele sau numerele fotografiilor pentru album."
                    )

                    helpStep(
                        number: "3",
                        title: "Apasă pe „Creează selecția”",
                        text: "Aplicația va crea automat un folder nou numit „Selecții pentru albumul foto” în interiorul folderului cu fotografii."
                    )

                    helpStep(
                        number: "4",
                        title: "Copierea fotografiilor",
                        text: "Aplicația caută fiecare reper din listă și copiază fotografiile găsite în noul folder creat."
                    )

                    helpStep(
                        number: "5",
                        title: "Cum se face potrivirea",
                        text: "Potrivirea se face după numerele găsite în numele din listă și în numele fișierelor foto. Nu contează dacă numărul este la începutul, la mijlocul sau la sfârșitul numelui."
                    )

                    helpStep(
                        number: "6",
                        title: "Rezultatul",
                        text: "La final, bara de status îți arată câte repere au fost selectate din totalul reperelor din listă."
                    )
                }

                Divider()

                Text("Exemple utile")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Exemplu listă:")
                        .font(.headline)

                    Text("""
1201
IMG_1202
album_final_334
""")
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text("Dacă în numele fotografiei există același număr, aplicația o poate corela automat.")
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text("Observații")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))

                VStack(alignment: .leading, spacing: 8) {
                    Text("• Folderul de destinație este creat automat.")
                    Text("• Dacă o fotografie nu este găsită, ea nu va fi copiată.")
                    Text("• Dacă există mai multe potriviri pentru același reper, cazul poate fi tratat ca ambiguu.")
                    Text("• Pentru scriere în folder, aplicația trebuie să aibă permisiune Read/Write la User Selected File.")
                }
                .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 620, minHeight: 560)
    }

    private func helpStep(number: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.16))
                    .frame(width: 30, height: 30)

                Text(number)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                Text(text)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HelpView()
}
