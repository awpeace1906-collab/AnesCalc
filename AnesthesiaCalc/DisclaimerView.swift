import SwiftUI

// MARK: - Scrollable disclaimer content (shared by modal and settings nav link)

struct DisclaimerContent: View {
    @EnvironmentObject var theme: ThemeManager
    /// Nil = read-only (shown from Settings); non-nil = requires acknowledgment (first launch)
    let onAccept: (() -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                VStack(spacing: 8) {
                    Image(systemName: "stethoscope")
                        .font(.system(size: 40))
                        .foregroundStyle(theme.primary)
                    Text("AnesCalc")
                        .font(.title2.bold())
                    Text("Clinical Reference Tool")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                Divider()

                block(
                    icon: "person.badge.shield.checkmark.fill",
                    title: "For Healthcare Professionals Only",
                    color: theme.primary,
                    body: "This application is intended exclusively for use by licensed healthcare professionals — including physicians, CRNAs, pharmacists, and other qualified medical personnel — within their authorized scope of practice. It is not intended for use by patients or the general public."
                )

                block(
                    icon: "exclamationmark.triangle.fill",
                    title: "Clinical Limitations",
                    color: .orange,
                    body: "All outputs are suggested reference values derived from standard pharmacological formulas and published dosing guidelines. They do not constitute medical advice or a treatment directive.\n\nBefore any drug administration, independently verify all values against current clinical guidelines, institutional formularies, patient-specific factors (renal/hepatic function, weight, allergies, hemodynamic status, drug interactions, age extremes), and manufacturer prescribing information.\n\nThis app does not account for patient-specific contraindications or real-time clinical data."
                )

                block(
                    icon: "brain.fill",
                    title: "Clinical Judgment Required",
                    color: .purple,
                    body: "This tool supports — but does not replace — the independent clinical judgment of a qualified healthcare provider. The clinician retains full responsibility for all treatment decisions. Doses displayed are reference starting points; individualized adjustments are expected and required."
                )

                block(
                    icon: "function",
                    title: "Calculation Methodology",
                    color: .indigo,
                    body: "Dosing calculations apply standard weight-based pharmacological formulas sourced from manufacturer prescribing information and peer-reviewed anesthesia literature: Mapleson/Nickalls MAC age-correction (BJA 1996), Devine IBW, Janmahasatian LBW, and published induction, NMB, and analgesic dosing ranges. All formula logic is transparent — outputs are mathematically derivable from the displayed patient inputs using standard pharmacokinetic principles. Individual patient response may vary significantly."
                )

                block(
                    icon: "building.columns.fill",
                    title: "Regulatory Status",
                    color: .blue,
                    body: "AnesCalc is designed as a clinician-facing reference that displays the formula and basis for each output so that values can be independently reviewed. It has not been reviewed, cleared, or approved by the FDA. It does not acquire or analyze signals from medical devices, images, or in vitro diagnostic equipment. It is not intended as the sole basis for time-critical decisions; emergency values are provided for pre-planning and cross-checking."
                )

                block(
                    icon: "building.2.fill",
                    title: "No Institutional Endorsement",
                    color: .gray,
                    body: "This is an independent reference tool. It has not been approved, endorsed, or validated by any hospital, health system, specialty society, or regulatory body. Use consistent with your institution's drug administration policies and protocols."
                )

                Divider()

                if let accept = onAccept {
                    Text("By tapping \"I Understand,\" you confirm that you are a licensed healthcare professional and that you will independently verify all clinical values before use.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)

                    Button(action: accept) {
                        Text("I Understand")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primary)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private func block(icon: String, title: String, color: Color, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundStyle(color)
            Text(body)
                .font(.footnote)
                .foregroundStyle(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Modal wrapper (first-launch fullScreenCover)

struct DisclaimerView: View {
    @EnvironmentObject var theme: ThemeManager
    let onAccept: () -> Void

    var body: some View {
        NavigationStack {
            DisclaimerContent(onAccept: onAccept)
                .navigationTitle("Important Notice")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackground(theme.headerBg)
        }
        .interactiveDismissDisabled(true)
    }
}
