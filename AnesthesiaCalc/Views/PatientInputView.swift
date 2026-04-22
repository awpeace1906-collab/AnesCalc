import SwiftUI

struct PatientInputView: View {
    @ObservedObject var patient: PatientModel
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FieldFocusManager
    @FocusState private var focused: AppField?
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // ── Header toggle ────────────────────────────────────────────────
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .foregroundColor(.white)
                    Text("PATIENT INPUTS")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(theme.headerBg)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    inputGrid
                }
                .background(Color(.secondarySystemGroupedBackground))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        // Sync manager → local focus
        .onChange(of: focusManager.current) { field in
            if let f = field, AppField.allCases.firstIndex(of: f).map({ $0 < 20 }) ?? false {
                focused = f
            } else if field == nil {
                focused = nil
            }
        }
        // Sync local → manager
        .onChange(of: focused) { field in
            if let f = field { focusManager.current = f }
        }
    }

    @ViewBuilder
    var inputGrid: some View {
        // Row 1 — core demographics
        Group {
            sectionLabel("Demographics")
            HStack(spacing: 8) {
                numberField("Age", value: $patient.age, unit: "yrs", format: "%.0f", field: .age)
                numberField("Weight", value: $patient.weight, unit: "kg", format: "%.1f", field: .weight)
                numberField("Height", value: $patient.height, unit: "cm", format: "%.0f", field: .height)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                sexPicker
                numberField("Hgb", value: $patient.hemoglobin, unit: "g/dL", format: "%.1f", field: .hgb)
                numberField("Min Hgb", value: $patient.minTargetHgb, unit: "g/dL", format: "%.1f", field: .minHgb)
            }
            .padding(.horizontal, 12)
        }

        // Row 2 — periop
        Group {
            sectionLabel("Perioperative")
            HStack(spacing: 8) {
                numberField("NPO", value: $patient.npoHours, unit: "hrs", format: "%.0f", field: .npo)
                numberField("FiO₂", value: $patient.fio2, unit: "", format: "%.2f", field: .fio2)
                numberField("HR", value: $patient.heartRate, unit: "bpm", format: "%.0f", field: .hr)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                numberField("MAP", value: $patient.map, unit: "mmHg", format: "%.0f", field: .map)
                numberField("CVP", value: $patient.cvp, unit: "mmHg", format: "%.0f", field: .cvp)
                numberField("CO", value: $patient.cardiacOutput, unit: "L/min", format: "%.1f", field: .co)
            }
            .padding(.horizontal, 12)
        }

        // Row 3 — ABG / Pulm
        Group {
            sectionLabel("ABG & Pulmonary")
            HStack(spacing: 8) {
                numberField("PaO₂", value: $patient.pao2, unit: "mmHg", format: "%.0f", field: .pao2)
                numberField("PaCO₂", value: $patient.paco2, unit: "mmHg", format: "%.0f", field: .paco2)
                numberField("SaO₂", value: $patient.sao2, unit: "", format: "%.2f", field: .sao2)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                numberField("SvO₂", value: $patient.svo2, unit: "", format: "%.2f", field: .svo2)
                numberField("MPAP", value: $patient.mpap, unit: "mmHg", format: "%.0f", field: .mpap)
                numberField("PCWP", value: $patient.pcwp, unit: "mmHg", format: "%.0f", field: .pcwp)
            }
            .padding(.horizontal, 12)
        }

        // Row 4 — ECG / PONV toggles
        Group {
            sectionLabel("ECG & PONV Risk")
            HStack(spacing: 8) {
                numberField("QT", value: $patient.qtInterval, unit: "ms", format: "%.0f", field: .qt)
                numberField("Altitude", value: $patient.altitude, unit: "m", format: "%.0f", field: .altitude)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 0) {
                toggleField("Smoking Hx", value: $patient.smokingHx)
                toggleField("Prior PONV", value: $patient.priorPONV)
                toggleField("Opioid Plan", value: $patient.opioidPlanned)
            }
            .padding(.horizontal, 12)
        }

        Spacer().frame(height: 10)
    }

    // ── Sub-components ────────────────────────────────────────────────────────

    func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }

    func numberField(_ label: String, value: Binding<Double>, unit: String, format: String, field: AppField? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                TextField("", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.secondary)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .focused($focused, equals: field)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(theme.secondary.opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }

    var sexPicker: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Sex")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
            Picker("", selection: $patient.sex) {
                ForEach(BiologicalSex.allCases) { s in
                    Text(s.label).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }

    func toggleField(_ label: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Toggle("", isOn: value)
                .labelsHidden()
                .tint(theme.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6)
            .stroke(theme.secondary.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - TIVA Input Panel

struct TIVAInputView: View {
    @ObservedObject var patient: PatientModel
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FieldFocusManager
    @FocusState private var focused: AppField?
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "iv.bag.fill")
                        .foregroundColor(.white)
                    Text("TIVA PARAMETERS")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(theme.sectionColor("sectionTIVA"))
            }

            if isExpanded {
                VStack(spacing: 0) {
                    sectionLabel2("Anesthetic Target")

                    // Row 1: Target (compact menu) — full width
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                        Menu {
                            ForEach(TIVATarget.allCases) { t in
                                Button(t.rawValue) { patient.tivaTarget = t }
                            }
                        } label: {
                            HStack {
                                Text(patient.tivaTarget.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.sectionColor("sectionTIVA"))
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                                    .foregroundColor(theme.sectionColor("sectionTIVA").opacity(0.7))
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6)
                                .stroke(theme.sectionColor("sectionTIVA").opacity(0.3), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)

                    // Row 2: Duration + ASA Class
                    HStack(alignment: .top, spacing: 8) {
                        numberField2("Duration", value: $patient.tivaInfusionDuration, unit: "min", field: .tivaDuration)
                        intField2("ASA Class", value: $patient.tivaASAClass)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)

                    // Row 3: Toggles
                    HStack(spacing: 8) {
                        toggleField2("Premedicated", value: $patient.tivaPremedicated)
                        toggleField2("Ketamine Adjunct", value: $patient.tivaAdjunct)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .onChange(of: focusManager.current) { field in
            if field == .tivaDuration { focused = .tivaDuration }
            else if field == nil { focused = nil }
        }
        .onChange(of: focused) { field in
            if let f = field { focusManager.current = f }
        }
    }

    func sectionLabel2(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }

    func numberField2(_ label: String, value: Binding<Double>, unit: String, field: AppField? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary)
            HStack(spacing: 2) {
                TextField("", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.sectionColor("sectionTIVA"))
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .focused($focused, equals: field)
                Text(unit).font(.system(size: 8)).foregroundColor(.secondary)
            }
            .padding(.vertical, 5).padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(theme.sectionColor("sectionTIVA").opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func intField2(_ label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary)
            Picker("", selection: value) {
                ForEach(1...4, id: \.self) { i in Text("\(i)").tag(i) }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func toggleField2(_ label: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary).multilineTextAlignment(.center)
            Toggle("", isOn: value).labelsHidden().tint(theme.sectionColor("sectionTIVA"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6).padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6)
            .stroke(theme.sectionColor("sectionTIVA").opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Epidural / OB Input Panel

struct EpiduralInputView: View {
    @ObservedObject var patient: PatientModel
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FieldFocusManager
    @FocusState private var focused: AppField?
    @State private var isExpanded = true

    var obColor: Color { theme.sectionColor("sectionOB") }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "staroflife.fill")
                        .foregroundColor(.white)
                    Text("OB / EPIDURAL PARAMETERS")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(obColor)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    sectionLabelOB("Indication & Equipment")
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Indication").font(.system(size: 9, weight: .medium)).foregroundColor(.secondary)
                            Picker("", selection: $patient.epiduralIndication) {
                                ForEach(EpiduralIndication.allCases) { i in
                                    Text(i.rawValue).tag(i)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4).padding(.horizontal, 6)
                            .background(Color(.systemBackground))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.3), lineWidth: 1))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 12)

                    HStack(spacing: 8) {
                        pickerFieldOB("Epidural Needle", selection: $patient.epiduralNeedle,
                            options: EpiduralNeedle.allCases) { $0.rawValue }
                        pickerFieldOB("Spinal Needle", selection: $patient.spinalNeedle,
                            options: SpinalNeedle.allCases) { $0.rawValue }
                    }
                    .padding(.horizontal, 12)

                    sectionLabelOB("Maternal Data")
                    HStack(spacing: 8) {
                        numberFieldOB("Weight", value: $patient.maternalWeightKg, unit: "kg", field: .maternalWeight)
                        numberFieldOB("Height", value: $patient.maternalHeightCm, unit: "cm", field: .maternalHeight)
                        numberFieldOB("GA", value: $patient.gestationalAge, unit: "wks", field: .ga)
                    }
                    .padding(.horizontal, 12)

                    HStack(spacing: 8) {
                        numberFieldOB("Cervix", value: $patient.cervicalDilation, unit: "cm", field: .cervix)
                        toggleFieldOB("CSE Technique", value: $patient.combinedSpinalEpidural)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .onChange(of: focusManager.current) { field in
            let obFields: [AppField] = [.maternalWeight, .maternalHeight, .ga, .cervix]
            if let f = field, obFields.contains(f) { focused = f }
            else if field == nil { focused = nil }
        }
        .onChange(of: focused) { field in
            if let f = field { focusManager.current = f }
        }
    }

    func sectionLabelOB(_ text: String) -> some View {
        HStack {
            Text(text.uppercased()).font(.system(size: 9, weight: .semibold)).foregroundColor(.secondary).tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 2)
    }

    func numberFieldOB(_ label: String, value: Binding<Double>, unit: String, field: AppField? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary)
            HStack(spacing: 2) {
                TextField("", value: value, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(obColor)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .focused($focused, equals: field)
                Text(unit).font(.system(size: 8)).foregroundColor(.secondary)
            }
            .padding(.vertical, 5).padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func pickerFieldOB<T: Identifiable & Hashable>(_ label: String, selection: Binding<T>,
                                         options: [T], display: @escaping (T) -> String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary)
            Picker("", selection: selection) {
                ForEach(options) { opt in Text(display(opt)).tag(opt) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4).padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func toggleFieldOB(_ label: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundColor(.secondary).multilineTextAlignment(.center)
            Toggle("", isOn: value).labelsHidden().tint(obColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6).padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.2), lineWidth: 1))
    }
}
