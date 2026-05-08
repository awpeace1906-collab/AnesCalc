// AnesthesiaCalc v1.7.0
// New: ToolsView.swift
// Change: Patient-independent clinical tools — RSBI, RASS, Driving Pressure, Fick CO,
//         BP Targets, NPO Fasting, Machine Checkout, Dermatomal Levels, Vasopressor Drips

import SwiftUI

// MARK: - Tool Catalog

enum ToolItem: String, CaseIterable, Identifiable {
    case rsbi            = "RSBI"
    case rass            = "RASS Scale"
    case drivingPressure = "Driving Pressure"
    case fickCO          = "Fick Cardiac Output"
    case bpTargets       = "BP Targets"
    case npoFasting      = "NPO Fasting"
    case machineCheckout = "Machine Checkout"
    case dermatomal      = "Dermatomal Levels"
    case vasopressor     = "Vasopressor Drips"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rsbi:            return "lungs.fill"
        case .rass:            return "brain.head.profile"
        case .drivingPressure: return "waveform.path"
        case .fickCO:          return "heart.fill"
        case .bpTargets:       return "gauge.medium"
        case .npoFasting:      return "fork.knife"
        case .machineCheckout: return "checklist"
        case .dermatomal:      return "figure.stand"
        case .vasopressor:     return "iv.bag.fill"
        }
    }
    var subtitle: String {
        switch self {
        case .rsbi:            return "RR ÷ Vt — extubation readiness"
        case .rass:            return "Richmond Agitation-Sedation Scale"
        case .drivingPressure: return "Pplat − PEEP"
        case .fickCO:          return "Estimated CO from assumed VO₂"
        case .bpTargets:       return "MAP goals by clinical indication"
        case .npoFasting:      return "ASA fasting cutoffs by food type"
        case .machineCheckout: return "Pre-anesthesia machine verification"
        case .dermatomal:      return "Spinal level landmarks & surgical targets"
        case .vasopressor:     return "Dose → infusion rate calculator"
        }
    }
    var color: Color {
        switch self {
        case .rsbi, .drivingPressure: return Color(red: 0.20, green: 0.48, blue: 0.78)
        case .rass:            return Color(red: 0.55, green: 0.20, blue: 0.70)
        case .fickCO:          return Color(red: 0.82, green: 0.18, blue: 0.22)
        case .bpTargets:       return Color(red: 0.80, green: 0.35, blue: 0.10)
        case .npoFasting:      return Color(red: 0.18, green: 0.62, blue: 0.38)
        case .machineCheckout: return Color(red: 0.28, green: 0.28, blue: 0.68)
        case .dermatomal:      return Color(red: 0.50, green: 0.33, blue: 0.18)
        case .vasopressor:     return Color(red: 0.70, green: 0.14, blue: 0.38)
        }
    }
}

// MARK: - Main ToolsView

struct ToolsView: View {
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        NavigationView {
            List {
                ForEach(ToolItem.allCases) { tool in
                    NavigationLink(destination: toolDestination(tool)) {
                        ToolRow(tool: tool)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Clinical Tools")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(theme.headerBg)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func toolDestination(_ tool: ToolItem) -> some View {
        switch tool {
        case .rsbi:            RSBIToolView()
        case .rass:            RASSToolView()
        case .drivingPressure: DrivingPressureToolView()
        case .fickCO:          FickCOToolView()
        case .bpTargets:       BPTargetsToolView()
        case .npoFasting:      NPOFastingToolView()
        case .machineCheckout: MachineCheckoutToolView()
        case .dermatomal:      DermatomalToolView()
        case .vasopressor:     VasopressorDripToolView()
        }
    }
}

private struct ToolRow: View {
    let tool: ToolItem
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(tool.color)
                    .frame(width: 38, height: 38)
                Image(systemName: tool.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                Text(tool.subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.vertical, 3)
        }
    }
}

// MARK: - Shared form helpers

private struct ToolNumRow: View {
    let label: String
    let unit: String
    @Binding var text: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 14))
            Spacer()
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
            Text(unit)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(width: 56, alignment: .leading)
        }
    }
}

private struct ToolRefRow: View {
    let label: String
    let value: String
    var labelColor: Color = .secondary
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(labelColor)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 1. RSBI

struct RSBIToolView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var rrText = ""
    @State private var vtText = ""

    private var rsbi: Double? {
        guard let rr = Double(rrText), rr > 0,
              let vt = Double(vtText), vt > 0 else { return nil }
        return rr / vt
    }
    private var rsbiColor: Color {
        guard let v = rsbi else { return .primary }
        return v < 80 ? .green : v <= 105 ? .orange : .red
    }
    private var rsbiLabel: String {
        guard let v = rsbi else { return "" }
        if v < 80  { return "Favorable — high likelihood of extubation success" }
        if v <= 105 { return "Borderline — integrate clinical factors" }
        return "Unfavorable — elevated extubation failure risk"
    }

    var body: some View {
        Form {
            Section("Inputs") {
                ToolNumRow(label: "Respiratory Rate", unit: "br/min", text: $rrText)
                ToolNumRow(label: "Tidal Volume",     unit: "L",      text: $vtText)
            }
            Section("Result") {
                HStack {
                    Text("RSBI").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    if let v = rsbi {
                        Text(String(format: "%.1f", v))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(rsbiColor)
                        Text("br/min/L").font(.caption).foregroundColor(.secondary)
                    } else {
                        Text("—").foregroundColor(.secondary)
                    }
                }
                if !rsbiLabel.isEmpty {
                    Text(rsbiLabel).font(.system(size: 13)).foregroundColor(rsbiColor)
                }
            }
            Section("Reference") {
                ToolRefRow(label: "< 80",    value: "Excellent — high success likelihood",    labelColor: .green)
                ToolRefRow(label: "80–105",  value: "Borderline — clinical correlation needed", labelColor: .orange)
                ToolRefRow(label: "> 105",   value: "Poor — high extubation failure risk",     labelColor: .red)
                ToolRefRow(label: "Formula", value: "RSBI = RR (br/min) ÷ Vt (L)")
                ToolRefRow(label: "Source",  value: "Yang & Tobin 1991 — threshold 105")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("RSBI")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 2. RASS Scale

struct RASSToolView: View {
    @EnvironmentObject var theme: ThemeManager

    private let scores: [(Int, String, String)] = [
        (+4, "Combative",      "Violent, immediate danger to staff"),
        (+3, "Very Agitated",  "Pulls/removes tubes, aggressive"),
        (+2, "Agitated",       "Frequent non-purposeful movement, fights ventilator"),
        (+1, "Restless",       "Anxious, non-aggressive movements"),
        ( 0, "Alert & Calm",   "Spontaneously attentive and calm"),
        (-1, "Drowsy",         "Sustained awakening >10s to voice; eye contact"),
        (-2, "Light Sedation", "Brief awakening <10s to voice; eye opening to voice"),
        (-3, "Mod Sedation",   "Movement or eye opening to voice — no eye contact"),
        (-4, "Deep Sedation",  "No response to voice; movement to physical stimulus only"),
        (-5, "Unarousable",    "No response to voice or physical stimulation"),
    ]
    private let targets: [(String, String)] = [
        ("Most ICU patients",          "–1 to 0  (light sedation; SAT/SBT protocol)"),
        ("Moderate–severe ARDS",       "–2 to –3  (consider NMBA if dyssynchrony)"),
        ("Prone positioning",          "–3 to –4"),
        ("Status epilepticus / ↑ICP",  "–4 to –5  (burst suppression target)"),
        ("Post-op early wean",         "0 to –1"),
        ("Alcohol withdrawal",         "CIWA-Ar scale preferred; RASS for sedation depth"),
    ]

    var body: some View {
        Form {
            Section("RASS Score Reference") {
                ForEach(scores, id: \.0) { score, name, desc in
                    HStack(alignment: .top, spacing: 12) {
                        Text(score > 0 ? "+\(score)" : "\(score)")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(rassColor(score))
                            .frame(width: 28, alignment: .center)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name).font(.system(size: 14, weight: .semibold))
                            Text(desc).font(.system(size: 12)).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            Section("ICU Sedation Targets") {
                ForEach(targets, id: \.0) { indication, target in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(indication).font(.system(size: 13, weight: .semibold))
                        Text(target).font(.system(size: 13)).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            Section("Assessment Steps") {
                Text("1. Observe 30 sec — score if spontaneously alert or agitated\n2. Call patient's name — score –1 if sustained eye contact >10s, –2 if <10s\n3. Louder voice — score –3 if movement or eye opening (no eye contact)\n4. Shoulder shake or sternal rub — score –4 if movement, –5 if no response")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("RASS Scale")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }

    private func rassColor(_ s: Int) -> Color {
        switch s {
        case 3...4:  return .red
        case 1...2:  return .orange
        case 0:      return .green
        case -1:     return Color(red: 0.2, green: 0.6, blue: 0.2)
        case -2:     return .orange
        default:     return .red
        }
    }
}

// MARK: - 3. Driving Pressure

struct DrivingPressureToolView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var pplatText = ""
    @State private var peepText  = ""

    private var dp: Double? {
        guard let pp = Double(pplatText), let peep = Double(peepText),
              pp >= peep else { return nil }
        return pp - peep
    }
    private var dpColor: Color {
        guard let v = dp else { return .primary }
        return v <= 15 ? .green : v <= 20 ? .orange : .red
    }
    private var dpLabel: String {
        guard let v = dp else { return "" }
        if v <= 15 { return "Acceptable — lung-protective target met" }
        if v <= 20 { return "Elevated — optimize Vt or PEEP to reduce DP" }
        return "High — associated with increased ARDS mortality"
    }

    var body: some View {
        Form {
            Section("Inputs") {
                ToolNumRow(label: "Plateau Pressure (Pplat)", unit: "cmH₂O", text: $pplatText)
                ToolNumRow(label: "PEEP",                     unit: "cmH₂O", text: $peepText)
            }
            Section("Result") {
                HStack {
                    Text("Driving Pressure").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    if let v = dp {
                        Text(String(format: "%.1f", v))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(dpColor)
                        Text("cmH₂O").font(.caption).foregroundColor(.secondary)
                    } else {
                        Text("—").foregroundColor(.secondary)
                    }
                }
                if !dpLabel.isEmpty {
                    Text(dpLabel).font(.system(size: 13)).foregroundColor(dpColor)
                }
            }
            Section("Reference") {
                ToolRefRow(label: "Formula", value: "DP = Pplat − PEEP  (= Vt / Crs)")
                ToolRefRow(label: "≤ 15",    value: "Target for lung-protective ventilation", labelColor: .green)
                ToolRefRow(label: "15–20",   value: "Optimize — adjust Vt (6 mL/kg IBW) or PEEP", labelColor: .orange)
                ToolRefRow(label: "> 20",    value: "High risk — consider prone, paralytic, or ECMO evaluation", labelColor: .red)
                ToolRefRow(label: "Crs",     value: "Normal static compliance ≈ 50 mL/cmH₂O; ARDS ≈ 20–35")
                ToolRefRow(label: "Source",  value: "Amato et al., NEJM 2015")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Driving Pressure")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 4. Fick Cardiac Output

struct FickCOToolView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var weightText = ""
    @State private var hgbText    = ""
    @State private var sao2Text   = ""
    @State private var svo2Text   = ""

    private var co: Double? {
        guard let wt  = Double(weightText), wt > 0,
              let hgb = Double(hgbText),    hgb > 0,
              let sa  = Double(sao2Text),
              let sv  = Double(svo2Text),
              sa > sv else { return nil }
        let avDiff = 1.34 * hgb * ((sa - sv) / 100) * 10
        return (3.5 * wt) / avDiff
    }
    private var coColor: Color {
        guard let v = co else { return .primary }
        return v >= 4 && v <= 8 ? .green : v < 4 ? .red : .orange
    }
    private var coLabel: String {
        guard let v = co else { return "" }
        if v < 4 { return "Low — evaluate for cardiogenic or obstructive etiology" }
        if v > 8 { return "Elevated — consider septic/distributive physiology" }
        return "Normal (4–8 L/min)"
    }

    var body: some View {
        Form {
            Section("Inputs") {
                ToolNumRow(label: "Weight",               unit: "kg",   text: $weightText)
                ToolNumRow(label: "Hemoglobin",           unit: "g/dL", text: $hgbText)
                ToolNumRow(label: "SaO₂ (arterial)",      unit: "%",    text: $sao2Text)
                ToolNumRow(label: "SvO₂ (mixed venous)",  unit: "%",    text: $svo2Text)
            }
            Section("Result") {
                HStack {
                    Text("Fick CO").font(.system(size: 15, weight: .semibold))
                    Spacer()
                    if let v = co {
                        Text(String(format: "%.2f", v))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(coColor)
                        Text("L/min").font(.caption).foregroundColor(.secondary)
                    } else {
                        Text("—").foregroundColor(.secondary)
                    }
                }
                if !coLabel.isEmpty {
                    Text(coLabel).font(.system(size: 13)).foregroundColor(coColor)
                }
            }
            Section("Reference") {
                ToolRefRow(label: "Formula",  value: "CO = VO₂ / (1.34 × Hgb × (SaO₂−SvO₂) × 10)")
                ToolRefRow(label: "VO₂",      value: "Assumed 3.5 mL/kg/min (average resting adult)")
                ToolRefRow(label: "Normal CO", value: "4–8 L/min")
                ToolRefRow(label: "Normal CI", value: "2.2–4.0 L/min/m²")
                ToolRefRow(label: "SvO₂",      value: "Normal mixed venous: 60–75%; low <60% → low CO or ↑ extraction")
                ToolRefRow(label: "Sample",    value: "True SvO₂ from PA catheter or right atrial port for best accuracy")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Fick Cardiac Output")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 5. BP Targets

struct BPTargetsToolView: View {
    @EnvironmentObject var theme: ThemeManager

    private let targets: [(String, String, String)] = [
        ("Septic Shock",              "MAP ≥ 65",              "Increase to 75–85 if chronic HTN or ongoing oliguria"),
        ("Cardiogenic Shock",         "MAP ≥ 65, SBP ≥ 90",   "Avoid excessive vasopressors — may worsen afterload"),
        ("Hemorrhagic Shock",         "MAP 50–65",             "Permissive hypotension until surgical control (no TBI)"),
        ("TBI (no ICP monitor)",      "MAP > 80",              "Assume elevated ICP; maintain CPP"),
        ("TBI (ICP monitored)",       "CPP 60–70",             "CPP = MAP − ICP; titrate MAP accordingly"),
        ("Ischemic Stroke (no tPA)",  "SBP < 220 / DBP < 120","Do not aggressively lower unless end-organ damage"),
        ("Ischemic Stroke + tPA",     "SBP < 180 / DBP < 105","Maintain for ≥24h post-thrombolysis"),
        ("SAH (pre-coiling)",         "SBP < 160",             "Minimize re-bleed risk before aneurysm is secured"),
        ("Hypertensive Emergency",    "↓MAP ≤ 25% in 1st hr", "Then target 160/100 over 2–6h; organ involvement guides pace"),
        ("Aortic Dissection",         "SBP 100–120",           "Add beta-blocker for HR < 60 simultaneously"),
        ("Post-CABG",                 "MAP 60–80",             "Balance graft perfusion vs. anastomotic bleeding risk"),
        ("Eclampsia",                 "SBP < 160, DBP < 110",  "Labetalol / hydralazine / nifedipine; MgSO₄ for seizures"),
        ("Intraop (general)",         "MAP ≥ 65; within 20% baseline", "Avoid MAP < 55 — associated with AKI and myocardial injury"),
    ]

    var body: some View {
        Form {
            Section {
                ForEach(targets, id: \.0) { indication, target, note in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text(indication)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text(target)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.trailing)
                        }
                        Text(note)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("MAP / BP Targets by Indication")
            } footer: {
                Text("⚠️ Guidelines only. Individualize to patient history, comorbidities, and clinical response. All pressures in mmHg.")
                    .font(.caption)
            }
        }
        .navigationTitle("BP Targets")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 6. NPO Fasting

struct NPOFastingToolView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var caseTime: Date = {
        Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    }()

    private let rules: [(String, Int, String, String)] = [
        ("Clear liquids",              2, "drop.fill",          "Water, black coffee, clear juice, gelatin, sports drinks"),
        ("Breast milk",                4, "heart.fill",         "Infants only"),
        ("Non-human milk / formula",   6, "cup.and.saucer.fill","Treat as light meal regardless of volume"),
        ("Light meal",                 6, "fork.knife",         "Toast, crackers + clear liquids; no fat or meat"),
        ("Fatty / fried foods",        8, "flame.fill",         "Full meal or high-fat content; may exceed 8h in gastroparesis"),
    ]

    var body: some View {
        Form {
            Section("Case Start Time") {
                DatePicker("Surgery Time", selection: $caseTime,
                           displayedComponents: [.date, .hourAndMinute])
            }
            Section("NPO Cutoff Times") {
                ForEach(rules, id: \.0) { category, hours, icon, note in
                    let cutoff = Calendar.current.date(byAdding: .hour, value: -hours, to: caseTime) ?? caseTime
                    let met = cutoff < Date()
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Image(systemName: icon)
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                                .frame(width: 18)
                            Text(category)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(timeString(cutoff))
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(met ? .green : .orange)
                                Text("(–\(hours)h)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(note)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.leading, 26)
                    }
                    .padding(.vertical, 3)
                }
            }
            Section {
                HStack(spacing: 8) {
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                    Text("Cutoff passed — fasting criteria met for this category")
                        .font(.system(size: 12)).foregroundColor(.secondary)
                }
                HStack(spacing: 8) {
                    Circle().fill(Color.orange).frame(width: 10, height: 10)
                    Text("Cutoff not yet reached — patient should not have consumed this")
                        .font(.system(size: 12)).foregroundColor(.secondary)
                }
            } header: { Text("Legend") }
              footer: {
                Text("ASA 2017 Practice Guidelines for Preoperative Fasting. Always confirm with the supervising anesthesiologist.")
                    .font(.caption)
              }
        }
        .navigationTitle("NPO Fasting")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - 7. Machine Checkout

struct MachineCheckoutToolView: View {
    @EnvironmentObject var theme: ThemeManager

    private let items: [(Int, String, String)] = [
        (0,  "Patient verification",       "Confirm identity, procedure, site, consent, and allergies"),
        (1,  "Machine power / self-test",  "Power on; complete automated self-test; resolve all errors"),
        (2,  "O₂ pipeline supply",         "Pipeline gauge 50–55 psi; O₂ cylinder ≥ 1000 psi as backup"),
        (3,  "Alternative gas supplies",   "Check N₂O and air pipeline/cylinder pressures"),
        (4,  "Flow meters",                "Verify bobbin free movement; confirm O₂ flows at all settings"),
        (5,  "Vaporizers",                 "Adequate agent level; filler port closed; mounted securely"),
        (6,  "Breathing circuit",          "Assemble circuit; perform manual leak test (APL at 30 cmH₂O, pop-off closed)"),
        (7,  "CO₂ absorber",               "Check color — replace if >50% exhausted (purple/white indicates exhaustion)"),
        (8,  "APL valve",                  "Opens freely; set appropriately for ventilation mode"),
        (9,  "Manual bag ventilation",     "Squeeze bag, observe test lung chest rise; confirm no obstruction"),
        (10, "Mechanical ventilation",     "Attach test lung; verify Vt, RR, FiO₂ match ordered settings"),
        (11, "Waste gas scavenging",       "Scavenger connected; open-reservoir bag deflates appropriately"),
        (12, "O₂ analyzer calibrated",     "Calibrate to room air (21%); set low O₂ alarm ≥ 18%"),
        (13, "SpO₂ monitor",              "Probe attached; waveform present; alarms active"),
        (14, "Capnography (ETCO₂)",       "Connected; baseline 0 mmHg in room air before patient"),
        (15, "NIBP / arterial line",       "NIBP cycling; arterial waveform zeroed and calibrated if used"),
        (16, "ECG / temperature",          "Leads applied; mode selected; alarms set"),
        (17, "Suction",                    "Functional; suction catheter available at head of bed"),
        (18, "Airway equipment",           "Laryngoscope + backup blade; ETT/LMA sized; video laryngoscope; stylet"),
        (19, "IV access",                  "Patent; flushes freely; adequate gauge for expected blood loss"),
        (20, "Emergency drugs",            "Sux or roc available; vasopressors drawn; atropine; lipid emulsion nearby"),
        (21, "Documentation",             "Machine checkout recorded in anesthesia record or EMR"),
    ]

    @State private var checked: Set<Int> = []

    private var progress: Double { Double(checked.count) / Double(items.count) }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress").font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text("\(checked.count) / \(items.count)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(checked.count == items.count ? .green : .primary)
                    }
                    ProgressView(value: progress)
                        .tint(checked.count == items.count ? .green : theme.primary)
                }
                .padding(.vertical, 4)
                if checked.count == items.count {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                        Text("Checkout complete").font(.system(size: 14, weight: .semibold)).foregroundColor(.green)
                    }
                }
                Button("Reset All") { checked.removeAll() }
                    .foregroundColor(.red)
            }
            Section("Checklist") {
                ForEach(items, id: \.0) { id, name, detail in
                    Button(action: {
                        if checked.contains(id) { checked.remove(id) }
                        else { checked.insert(id) }
                    }) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: checked.contains(id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(checked.contains(id) ? .green : .secondary)
                                .font(.system(size: 20))
                                .padding(.top, 1)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(detail)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Machine Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 8. Dermatomal Levels

struct DermatomalToolView: View {
    @EnvironmentObject var theme: ThemeManager

    private let landmarks: [(String, String)] = [
        ("C4",    "Clavicle / shoulder cap"),
        ("T1",    "Inner arm / medial elbow"),
        ("T4",    "Nipple line / sternal angle"),
        ("T6",    "Xiphoid process"),
        ("T7–T9", "Upper abdomen"),
        ("T10",   "Umbilicus"),
        ("T12",   "Inguinal ligament / groin"),
        ("L1",    "Upper inner thigh"),
        ("L2–L3", "Medial thigh / knee"),
        ("L4",    "Medial lower leg / great toe"),
        ("L5",    "Lateral lower leg / dorsal foot"),
        ("S1",    "Lateral foot / heel / small toe"),
        ("S2–S3", "Posterior thigh / popliteal fossa"),
        ("S3–S5", "Perineum / saddle area / perianal"),
    ]
    private let surgical: [(String, String, String)] = [
        ("Perineum / hemorrhoidectomy",  "S2–S4",              "Saddle block; lithotomy position"),
        ("TURP",                          "T10",                "Patient perceives bladder perforation at T10"),
        ("Lower extremity",               "L2–L3",              "Add T12 for tourniquet pain coverage"),
        ("Hip surgery",                   "T10",                "Femoral head coverage requires T10"),
        ("Appendectomy / inguinal hernia","T6–T8",              "Peritoneum sensitive above T6"),
        ("C-section / Pfannenstiel",      "T4",                 "Visceral T10, sensory/parietal T4"),
        ("Upper abdominal / hysterectomy","T4–T6",              "Full peritoneal coverage"),
        ("Open prostatectomy",            "T6–T8",              "Bladder dome T10; retropubic exposure T8"),
        ("Carotid endarterectomy",        "Cervical plexus",    "C2–C4 block; not a spinal technique"),
    ]

    var body: some View {
        Form {
            Section("Dermatomal Landmarks") {
                ForEach(landmarks, id: \.0) { level, landmark in
                    HStack(spacing: 12) {
                        Text(level)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                            .frame(width: 50, alignment: .leading)
                        Text(landmark).font(.system(size: 14))
                    }
                    .padding(.vertical, 2)
                }
            }
            Section {
                ForEach(surgical, id: \.0) { procedure, level, note in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(procedure).font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Text(level)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                        Text(note).font(.system(size: 12)).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 3)
                }
            } header: {
                Text("Surgical Target Levels")
            } footer: {
                Text("Required level = highest dermatomal level of surgical field. Consider adding one level for reliable block margin. Confirm with attending anesthesiologist.")
                    .font(.caption)
            }
        }
        .navigationTitle("Dermatomal Levels")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }
}

// MARK: - 9. Vasopressor Drip Builder

enum VasopressorDrug: String, CaseIterable, Identifiable {
    case norepinephrine = "Norepinephrine"
    case epinephrine    = "Epinephrine"
    case dopamine       = "Dopamine"
    case vasopressin    = "Vasopressin"
    case phenylephrine  = "Phenylephrine"
    case dobutamine     = "Dobutamine"
    case milrinone      = "Milrinone"
    var id: String { rawValue }

    var isWeightBased: Bool { self != .vasopressin }
    var doseUnit: String { self == .vasopressin ? "units/min" : "mcg/kg/min" }

    var standardConcentrations: [(label: String, concValue: Double)] {
        switch self {
        case .norepinephrine: return [("4 mg / 250 mL → 16 mcg/mL",  16),  ("8 mg / 250 mL → 32 mcg/mL",  32)]
        case .epinephrine:    return [("2 mg / 250 mL → 8 mcg/mL",    8),   ("4 mg / 250 mL → 16 mcg/mL",  16)]
        case .dopamine:       return [("400 mg / 250 mL → 1600 mcg/mL", 1600), ("800 mg / 250 mL → 3200 mcg/mL", 3200)]
        case .vasopressin:    return [("20 units / 100 mL → 0.2 u/mL", 0.2), ("40 units / 250 mL → 0.16 u/mL", 0.16)]
        case .phenylephrine:  return [("20 mg / 250 mL → 80 mcg/mL",  80),  ("100 mg / 250 mL → 400 mcg/mL", 400)]
        case .dobutamine:     return [("250 mg / 250 mL → 1000 mcg/mL", 1000), ("500 mg / 250 mL → 2000 mcg/mL", 2000)]
        case .milrinone:      return [("20 mg / 100 mL → 200 mcg/mL", 200), ("40 mg / 200 mL → 200 mcg/mL", 200)]
        }
    }

    // (tier name, low dose, high dose) — doses in doseUnit
    var doseRanges: [(String, Double, Double)] {
        switch self {
        case .norepinephrine: return [("Low",      0.01, 0.1),  ("Moderate", 0.1, 0.5),   ("High",     0.5, 1.0)]
        case .epinephrine:    return [("Low",       0.01, 0.05), ("Moderate", 0.05, 0.3),  ("High",     0.3, 1.0)]
        case .dopamine:       return [("Cardiac",   3,    10),   ("Vasopressor", 10, 20)]
        case .vasopressin:    return [("Adjunct",   0.01, 0.03), ("Max",      0.03, 0.04)]
        case .phenylephrine:  return [("Low",       0.5,  1.5),  ("Moderate", 1.5, 3.0),   ("High",     3.0, 6.0)]
        case .dobutamine:     return [("Low",       2,    5),    ("Moderate", 5,   10),     ("High",     10,  20)]
        case .milrinone:      return [("Low",       0.125, 0.25),("Standard", 0.25, 0.5),  ("High",     0.5, 0.75)]
        }
    }
}

struct VasopressorDripToolView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var drug       = VasopressorDrug.norepinephrine
    @State private var concIndex  = 0
    @State private var weightText = ""
    @State private var doseText   = ""

    private var conc: Double {
        let c = drug.standardConcentrations
        return concIndex < c.count ? c[concIndex].concValue : c[0].concValue
    }
    private var rate: Double? {
        guard let dose = Double(doseText), dose > 0 else { return nil }
        if drug == .vasopressin {
            return dose * 60 / conc
        }
        guard let wt = Double(weightText), wt > 0 else { return nil }
        return dose * wt * 60 / conc
    }
    private var tableWeight: Double { Double(weightText) ?? 70 }

    var body: some View {
        Form {
            Section("Drug & Concentration") {
                Picker("Drug", selection: $drug) {
                    ForEach(VasopressorDrug.allCases) { d in
                        Text(d.rawValue).tag(d)
                    }
                }
                .onChange(of: drug) { _, _ in concIndex = 0; doseText = "" }
                Picker("Concentration", selection: $concIndex) {
                    ForEach(0..<drug.standardConcentrations.count, id: \.self) { i in
                        Text(drug.standardConcentrations[i].label).tag(i)
                    }
                }
                .pickerStyle(.menu)
            }
            if drug.isWeightBased {
                Section("Patient Weight") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("70", text: $weightText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 90)
                        Text("kg").foregroundColor(.secondary).frame(width: 30)
                    }
                }
            }
            Section("Dose → Rate") {
                HStack {
                    Text("Dose")
                    Spacer()
                    TextField("0", text: $doseText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                    Text(drug.doseUnit)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 80, alignment: .leading)
                }
                if let r = rate {
                    HStack {
                        Text("Infusion Rate").font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text(String(format: "%.1f", r))
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        Text("mL/hr").font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            Section {
                ForEach(drug.doseRanges, id: \.0) { name, lo, hi in
                    let loRate = drug == .vasopressin
                        ? lo * 60 / conc
                        : lo * tableWeight * 60 / conc
                    let hiRate = drug == .vasopressin
                        ? hi * 60 / conc
                        : hi * tableWeight * 60 / conc
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name).font(.system(size: 13, weight: .semibold))
                            Text("\(fmtDose(lo))–\(fmtDose(hi)) \(drug.doseUnit)")
                                .font(.system(size: 11)).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(fmtRate(loRate))–\(fmtRate(hiRate)) mL/hr")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Dose Range Reference")
            } footer: {
                let wt = drug.isWeightBased ? " at \(Int(tableWeight)) kg" : ""
                Text("Rates shown\(wt) with selected concentration. Verify all drips with institutional pharmacy protocols.")
                    .font(.caption)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Vasopressor Drips")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackground(theme.headerBg)
    }

    private func fmtDose(_ d: Double) -> String { String(format: "%g", d) }
    private func fmtRate(_ r: Double) -> String { String(format: "%.1f", r) }
}
