import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        NavigationView {
            Form {
                // ── Appearance ───────────────────────────────────────────────
                Section {
                    ForEach(AppTheme.allCases) { t in
                        HStack {
                            ThemeSwatchView(theme: t)
                            Text(t.rawValue)
                                .font(.system(size: 14))
                            Spacer()
                            if theme.selectedTheme == t {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { theme.selectedTheme = t }
                    }
                } header: {
                    Text("Color Theme")
                }

                Section {
                    ForEach(AppColorScheme.allCases) { scheme in
                        HStack {
                            Image(systemName: schemeIcon(scheme))
                                .frame(width: 28)
                                .foregroundColor(theme.primary)
                            Text(scheme.rawValue)
                            Spacer()
                            if theme.selectedColorScheme == scheme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { theme.selectedColorScheme = scheme }
                    }
                } header: {
                    Text("Display Mode")
                }

                // ── About ────────────────────────────────────────────────────
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Calculations")
                        Spacer()
                        Text("116 formulas")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Drug Cards")
                        Spacer()
                        Text("\(DrugCardLibrary.all.count) agents")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Offline Capable")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                } header: {
                    Text("About")
                }

                // ── Disclaimer ───────────────────────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Clinical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                        Text("This app is a reference tool intended for use by licensed healthcare professionals. All calculated doses must be independently verified against current clinical guidelines, institutional protocols, and individual patient factors. This app does not replace clinical judgment.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Legal")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(theme.headerBg)
        }
        .navigationViewStyle(.stack)
    }

    func schemeIcon(_ scheme: AppColorScheme) -> String {
        switch scheme {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }
}

// MARK: - Theme Swatch

struct ThemeSwatchView: View {
    let theme: AppTheme
    var palette: ThemePalette { theme.palette }

    var body: some View {
        HStack(spacing: 2) {
            ForEach([palette.primary, palette.secondary, palette.accent, palette.s3, palette.s5], id: \.self) { color in
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 24)
                    .cornerRadius(2)
            }
        }
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.separator), lineWidth: 0.5))
    }
}
