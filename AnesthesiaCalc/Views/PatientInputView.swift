// AnesthesiaCalc v2.0.0
// Modified: PatientInputView.swift
// Change: PlaceholderNumberField replaces numberField/numberField2/numberFieldOB;
//         placeholder-style UX — untouched fields clear on first tap, revert on invalid unfocus

import SwiftUI

// MARK: - Shared placeholder number field

struct PlaceholderNumberField: View {
    var label: String
    var unit: String
    @Binding var value: Double
    @Binding var touchedFields: Set<String>
    var field: AppField?
    var accentColor: Color
    @FocusState.Binding var focused: AppField?

    @State private var displayText: String = ""
    @State private var lastValidValue: Double = 0
    @State private var fieldIsFocused: Bool = false

    private var fieldKey: String { field.map { "\($0.rawValue)" } ?? "" }

    private func formatted(_ v: Double) -> String { String(format: "%g", v) }

    private func commitText() {
        if let parsed = Double(displayText), parsed.isFinite {
            value = parsed
            if !fieldKey.isEmpty { touchedFields.insert(fieldKey) }
            displayText = formatted(parsed)
        } else {
            displayText = formatted(lastValidValue)
        }
    }

    var body: some View {
        let isTouched = touchedFields.contains(fieldKey)
        let textColor: Color = fieldIsFocused ? accentColor :
                               (isTouched ? accentColor : accentColor.opacity(0.4))

        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                TextField("", text: $displayText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .focused($focused, equals: field)
                    .onAppear {
                        lastValidValue = value
                        displayText = formatted(value)
                    }
                    .onChange(of: focused) { _, newFocused in
                        let nowFocused = (newFocused == field)
                        if nowFocused && !fieldIsFocused {
                            lastValidValue = value
                            if !touchedFields.contains(fieldKey) {
                                displayText = ""
                            }
                        } else if !nowFocused && fieldIsFocused {
                            commitText()
                        }
                        fieldIsFocused = nowFocused
                    }
                    .onChange(of: value) { _, newValue in
                        guard focused != field else { return }
                        displayText = formatted(newValue)
                        lastValidValue = newValue
                    }
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(accentColor.opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
    }
}

// MARK: - Patient Input Panel

struct PatientInputView: View {
    @ObservedObject var patient: PatientModel
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var focusManager: FieldFocusManager
    @FocusState private var focused: AppField?
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // ── Header toggle ────────────────────────────────────────────────
            Button(action: { withAnimation(.spring(duration: 0.3, bounce: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "person.text.rectangle.fill")
                        .foregroundStyle(.white)
                    Text("PATIENT INPUTS")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
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
                .clipped()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        // Sync manager → local focus
        .onChange(of: focusManager.current) { _, field in
            if let f = field, AppField.allCases.firstIndex(of: f).map({ $0 < 20 }) ?? false {
                focused = f
            } else if field == nil {
                focused = nil
            }
        }
        // Sync local → manager
        .onChange(of: focused) { _, field in
            if let f = field { focusManager.current = f }
        }
    }

    @ViewBuilder
    var inputGrid: some View {
        // Row 1 — core demographics
        Group {
            sectionLabel("Demographics")
            HStack(spacing: 8) {
                PlaceholderNumberField(label: "Age", unit: "yrs",
                    value: $patient.age, touchedFields: $patient.touchedFields,
                    field: .age, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "Weight", unit: "kg",
                    value: $patient.weight, touchedFields: $patient.touchedFields,
                    field: .weight, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "Height", unit: "cm",
                    value: $patient.height, touchedFields: $patient.touchedFields,
                    field: .height, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                sexPicker
                PlaceholderNumberField(label: "Hgb", unit: "g/dL",
                    value: $patient.hemoglobin, touchedFields: $patient.touchedFields,
                    field: .hgb, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "Min Hgb", unit: "g/dL",
                    value: $patient.minTargetHgb, touchedFields: $patient.touchedFields,
                    field: .minHgb, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)
        }

        // Row 2 — periop
        Group {
            sectionLabel("Perioperative")
            HStack(spacing: 8) {
                PlaceholderNumberField(label: "NPO", unit: "hrs",
                    value: $patient.npoHours, touchedFields: $patient.touchedFields,
                    field: .npo, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "FiO₂", unit: "0–1",
                    value: $patient.fio2, touchedFields: $patient.touchedFields,
                    field: .fio2, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "HR", unit: "bpm",
                    value: $patient.heartRate, touchedFields: $patient.touchedFields,
                    field: .hr, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                PlaceholderNumberField(label: "MAP", unit: "mmHg",
                    value: $patient.map, touchedFields: $patient.touchedFields,
                    field: .map, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "CVP", unit: "mmHg",
                    value: $patient.cvp, touchedFields: $patient.touchedFields,
                    field: .cvp, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "CO", unit: "L/min",
                    value: $patient.cardiacOutput, touchedFields: $patient.touchedFields,
                    field: .co, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)
        }

        // Row 3 — ABG / Pulm
        Group {
            sectionLabel("ABG & Pulmonary")
            HStack(spacing: 8) {
                PlaceholderNumberField(label: "PaO₂", unit: "mmHg",
                    value: $patient.pao2, touchedFields: $patient.touchedFields,
                    field: .pao2, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "PaCO₂", unit: "mmHg",
                    value: $patient.paco2, touchedFields: $patient.touchedFields,
                    field: .paco2, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "SaO₂", unit: "%",
                    value: $patient.sao2, touchedFields: $patient.touchedFields,
                    field: .sao2, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)

            HStack(spacing: 8) {
                PlaceholderNumberField(label: "SvO₂", unit: "%",
                    value: $patient.svo2, touchedFields: $patient.touchedFields,
                    field: .svo2, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "MPAP", unit: "mmHg",
                    value: $patient.mpap, touchedFields: $patient.touchedFields,
                    field: .mpap, accentColor: theme.secondary, focused: $focused)
                PlaceholderNumberField(label: "PCWP", unit: "mmHg",
                    value: $patient.pcwp, touchedFields: $patient.touchedFields,
                    field: .pcwp, accentColor: theme.secondary, focused: $focused)
            }
            .padding(.horizontal, 12)
        }

        // Row 4 — ECG / PONV toggles
        Group {
            sectionLabel("ECG & PONV Risk")
            HStack(spacing: 8) {
                PlaceholderNumberField(label: "QT", unit: "ms",
                    value: $patient.qtInterval, touchedFields: $patient.touchedFields,
                    field: .qt, accentColor: theme.secondary, focused: $focused)

                HStack(spacing: 0) {
                    PlaceholderNumberField(label: "Altitude", unit: "m",
                        value: $patient.altitude, touchedFields: $patient.touchedFields,
                        field: .altitude, accentColor: theme.secondary, focused: $focused)

                    AltitudeLocationButton(
                        altitude: $patient.altitude,
                        touchedFields: $patient.touchedFields,
                        accentColor: theme.secondary
                    )
                }
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
                .foregroundStyle(.secondary)
                .tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }

    var sexPicker: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Sex")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
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
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Toggle("", isOn: value)
                .labelsHidden()
                .tint(theme.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
            Button(action: { withAnimation(.spring(duration: 0.3, bounce: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "iv.bag.fill")
                        .foregroundStyle(.white)
                    Text("TIVA PARAMETERS")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
                        .font(.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(theme.sectionColor("sectionTIVA"))
            }

            if isExpanded {
                VStack(spacing: 0) {
                    sectionLabel2("Anesthetic Target")

                    // Row 1: Target — full width
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                        Picker("Target", selection: $patient.tivaTarget) {
                            ForEach(TIVATarget.allCases) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(theme.sectionColor("sectionTIVA"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(theme.sectionColor("sectionTIVA").opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)

                    // Row 2: Duration + ASA Class
                    HStack(spacing: 8) {
                        PlaceholderNumberField(label: "Duration", unit: "min",
                            value: $patient.tivaInfusionDuration,
                            touchedFields: $patient.touchedFields,
                            field: .tivaDuration,
                            accentColor: theme.sectionColor("sectionTIVA"),
                            focused: $focused)
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
                .clipped()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .onChange(of: focusManager.current) { _, field in
            if field == .tivaDuration { focused = .tivaDuration }
            else if field == nil { focused = nil }
        }
        .onChange(of: focused) { _, field in
            if let f = field { focusManager.current = f }
        }
    }

    func sectionLabel2(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 2)
    }

    func intField2(_ label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
            Picker("", selection: value) {
                ForEach(1...4, id: \.self) { i in Text("\(i)").tag(i) }
            }
            .pickerStyle(.segmented)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func toggleField2(_ label: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Toggle("", isOn: value).labelsHidden().tint(theme.sectionColor("sectionTIVA"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6).padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
            Button(action: { withAnimation(.spring(duration: 0.3, bounce: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "staroflife.fill")
                        .foregroundStyle(.white)
                    Text("OB / EPIDURAL PARAMETERS")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white.opacity(0.7))
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
                            Text("Indication").font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
                            Picker("", selection: $patient.epiduralIndication) {
                                ForEach(EpiduralIndication.allCases) { i in
                                    Text(i.rawValue).tag(i)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4).padding(.horizontal, 6)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
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
                        PlaceholderNumberField(label: "Weight", unit: "kg",
                            value: $patient.maternalWeightKg,
                            touchedFields: $patient.touchedFields,
                            field: .maternalWeight, accentColor: obColor, focused: $focused)
                        PlaceholderNumberField(label: "Height", unit: "cm",
                            value: $patient.maternalHeightCm,
                            touchedFields: $patient.touchedFields,
                            field: .maternalHeight, accentColor: obColor, focused: $focused)
                        PlaceholderNumberField(label: "GA", unit: "wks",
                            value: $patient.gestationalAge,
                            touchedFields: $patient.touchedFields,
                            field: .ga, accentColor: obColor, focused: $focused)
                    }
                    .padding(.horizontal, 12)

                    HStack(spacing: 8) {
                        PlaceholderNumberField(label: "Cervix", unit: "cm",
                            value: $patient.cervicalDilation,
                            touchedFields: $patient.touchedFields,
                            field: .cervix, accentColor: obColor, focused: $focused)
                        toggleFieldOB("CSE Technique", value: $patient.combinedSpinalEpidural)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipped()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal, 12)
        .onChange(of: focusManager.current) { _, field in
            let obFields: [AppField] = [.maternalWeight, .maternalHeight, .ga, .cervix]
            if let f = field, obFields.contains(f) { focused = f }
            else if field == nil { focused = nil }
        }
        .onChange(of: focused) { _, field in
            if let f = field { focusManager.current = f }
        }
    }

    func sectionLabelOB(_ text: String) -> some View {
        HStack {
            Text(text.uppercased()).font(.system(size: 9, weight: .semibold)).foregroundStyle(.secondary).tracking(1.0)
            Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 0.5)
        }
        .padding(.horizontal, 12).padding(.top, 10).padding(.bottom, 2)
    }

    func pickerFieldOB<T: Identifiable & Hashable>(_ label: String, selection: Binding<T>,
                                         options: [T], display: @escaping (T) -> String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
            Picker("", selection: selection) {
                ForEach(options) { opt in Text(display(opt)).tag(opt) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4).padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.3), lineWidth: 1))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 2)
    }

    func toggleFieldOB(_ label: String, value: Binding<Bool>) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label).font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Toggle("", isOn: value).labelsHidden().tint(obColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6).padding(.horizontal, 4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(obColor.opacity(0.2), lineWidth: 1))
    }
}
