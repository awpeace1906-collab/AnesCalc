import SwiftUI

@main
struct AnesthesiaCalcApp: App {
    @StateObject private var themeManager = ThemeManager()
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .fullScreenCover(isPresented: .constant(!disclaimerAccepted)) {
                    DisclaimerView {
                        disclaimerAccepted = true
                    }
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                }
        }
    }
}
