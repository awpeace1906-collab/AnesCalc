// AnesthesiaCalc v2.0.0
// Modified: SettingsView.swift
// Change: Updated version number; added build info footer

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        NavigationStack {
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
                                    .foregroundStyle(theme.accent)
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
                                .foregroundStyle(theme.primary)
                            Text(scheme.rawValue)
                            Spacer()
                            if theme.selectedColorScheme == scheme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(theme.accent)
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
                        Text("2.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Drug Cards")
                        Spacer()
                        Text("\(DrugCardLibrary.all.count) agents")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Clinical Tools")
                        Spacer()
                        Text("\(ToolItem.allCases.count) tools")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Offline Capable")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text("About")
                }

                // ── Version footer ───────────────────────────────────────────
                Section {
                    VStack(spacing: 10) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(theme.primary.opacity(0.5))
                        Text("AnesthesiaCalc")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text("Version 2.0.0")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text("Built for anesthesia providers.\nFor educational and clinical reference use only.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .listRowBackground(Color.clear)

                // ── Legal ────────────────────────────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Clinical Disclaimer", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                        Text("This app is a reference tool intended exclusively for use by licensed healthcare professionals (physicians, CRNAs, pharmacists, and other qualified medical personnel) within their authorized scope of practice. All calculated doses must be independently verified against current clinical guidelines, institutional drug formularies, and individual patient factors — including renal and hepatic function, weight, allergies, hemodynamic status, and drug interactions — before administration. This app does not replace clinical judgment.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Regulatory Status", systemImage: "building.columns")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                        Text("This software is a non-device Clinical Decision Support (CDS) tool under 21 U.S.C. § 520(o)(1)(E), as amended by the 21st Century Cures Act (Pub. L. 114–255). It is not a FDA-cleared or FDA-approved medical device. It does not acquire or analyze signals from medical devices or diagnostic equipment. All outputs display their underlying pharmacological basis to enable independent professional review.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("About the Calculations", systemImage: "function")
                            .font(.caption.bold())
                            .foregroundStyle(.purple)
                        Text("Dosing calculations use standard weight-based pharmacological formulas sourced from manufacturer prescribing information and peer-reviewed anesthesia literature, including Mapleson/Nickalls MAC age-correction (BJA 1996), Devine IBW formula, Janmahasatian LBW formula, and published induction/NMB dosing ranges. Volatile agent MAC values reflect Mapleson 1996 MAC₄₀ references. All formula logic is applied transparently — outputs are mathematically derivable from the displayed patient inputs using standard pharmacokinetic principles. Individual patient response may vary significantly.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    NavigationLink {
                        DisclaimerContent(onAccept: nil)
                            .navigationTitle("Full Disclaimer")
                            .navigationBarTitleDisplayMode(.inline)
                            .navigationBarBackground(theme.headerBg)
                    } label: {
                        Label("View Full Disclaimer", systemImage: "doc.text")
                            .font(.caption)
                    }
                } header: {
                    Text("Legal")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(theme.headerBg)
        }
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
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.separator), lineWidth: 0.5))
    }
}
