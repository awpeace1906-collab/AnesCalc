import SwiftUI

// MARK: - Conversion Categories

enum ConversionCategory: String, CaseIterable, Identifiable {
    case weight        = "Weight"
    case volume        = "Volume"
    case pressure      = "Pressure"
    case temperature   = "Temperature"
    case length        = "Length"
    case dose          = "Drug Dose"
    case infusion      = "Infusion Rate"
    case concentration = "Concentration"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weight:        return "scalemass.fill"
        case .volume:        return "drop.fill"
        case .pressure:      return "gauge.medium"
        case .temperature:   return "thermometer.medium"
        case .length:        return "ruler.fill"
        case .dose:          return "pills.fill"
        case .infusion:      return "iv.bag.fill"
        case .concentration: return "cross.vial.fill"
        }
    }
}

// MARK: - Main View

struct ConversionsView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedCategory: ConversionCategory = .weight
    // Int? avoids all cross-struct enum-inference issues that plagued ConField
    @FocusState private var focusedTag: Int?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ── Category picker ───────────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ConversionCategory.allCases) { cat in
                            categoryChip(cat)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                Divider()

                // ── Conversion panels ─────────────────────────────────────────
                ScrollView {
                    VStack(spacing: 14) {
                        switch selectedCategory {
                        case .weight:        WeightConversionView(focusedTag: $focusedTag)
                        case .volume:        VolumeConversionView(focusedTag: $focusedTag)
                        case .pressure:      PressureConversionView(focusedTag: $focusedTag)
                        case .temperature:   TemperatureConversionView(focusedTag: $focusedTag)
                        case .length:        LengthConversionView(focusedTag: $focusedTag)
                        case .dose:          DoseConversionView(focusedTag: $focusedTag)
                        case .infusion:      InfusionConversionView(focusedTag: $focusedTag)
                        case .concentration: ConcentrationConversionView(focusedTag: $focusedTag)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .padding(.bottom, focusedTag != nil ? 340 : 20)
                }
                .animation(.easeInOut(duration: 0.2), value: focusedTag != nil)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Conversions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(theme.headerBg)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: { focusedTag = nil }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Done")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.primary.opacity(0.12))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    func categoryChip(_ cat: ConversionCategory) -> some View {
        let isSelected = selectedCategory == cat
        return Button(action: {
            selectedCategory = cat
            focusedTag = nil
        }) {
            HStack(spacing: 5) {
                Image(systemName: cat.icon)
                    .font(.system(size: 11))
                Text(cat.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : theme.primary)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(isSelected ? theme.primary : Color(.systemBackground))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(theme.primary.opacity(0.3), lineWidth: 1))
        }
    }
}

// MARK: - Shared row component
// Uses Int tag instead of a custom enum — avoids all FocusState.Binding
// member-inference and "cannot find type in scope" errors.

struct ConvRow: View {
    let label: String
    let unit: String
    @Binding var text: String
    let tag: Int
    @FocusState.Binding var focusedTag: Int?
    var note: String? = nil

    var isFocused: Bool { focusedTag == tag }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 90, alignment: .leading)
                Spacer()
                TextField("0", text: $text)
                    .keyboardType(.decimalPad)
                    .focused($focusedTag, equals: tag)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .frame(width: 120)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(isFocused
                        ? Color.blue.opacity(0.08)
                        : Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(isFocused ? Color.blue.opacity(0.5) : Color.clear,
                                    lineWidth: 1.5)
                    )
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(width: 56, alignment: .leading)
            }
            if let note = note {
                Text(note)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

// MARK: - Card container with colored header bar

struct ConvCard<Content: View>: View {
    let title: String
    let icon: String
    var accentColor: Color = Color(.systemBlue)
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accentColor)
            .cornerRadius(10, corners: [.topLeft, .topRight])

            content()
        }
        .background(Color(.systemBackground))
        .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.07), radius: 3, y: 1)
    }
}

// MARK: - Reference card

struct RefCard: View {
    let title: String
    let rows: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundColor(.secondary)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 6)

            ForEach(Array(rows.enumerated()), id: \.offset) { idx, pair in
                if idx > 0 { Divider().padding(.leading, 14) }
                HStack {
                    Text(pair.0)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(minWidth: 130, alignment: .leading)
                    Spacer()
                    Text(pair.1)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.04), radius: 2, y: 1)
    }
}

// MARK: - Corner radius helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect,
                          byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}

// MARK: - Math helpers

func safeDouble(_ s: String) -> Double? {
    Double(s.replacingOccurrences(of: ",", with: "."))
}

func convFmt(_ v: Double, decimals: Int = 4) -> String {
    var s = String(format: "%.\(decimals)f", v)
    if s.contains(".") {
        while s.hasSuffix("0") { s.removeLast() }
        if s.hasSuffix(".") { s.removeLast() }
    }
    return s
}

// MARK: - Tag ranges (unique per sub-view, no collisions)
// Weight 100–109 | Volume 200–209 | Pressure 300–309
// Temp 400–409   | Length 500–509 | Dose 600–619
// Infusion 700–709 | Concentration 800–809

// MARK: - Weight

struct WeightConversionView: View {
    @FocusState.Binding var focusedTag: Int?
    @State private var kg = ""
    @State private var lb = ""
    @State private var g  = ""
    @State private var oz = ""

    var body: some View {
        ConvCard(title: "Weight", icon: "scalemass.fill",
                 accentColor: Color(red: 0.25, green: 0.47, blue: 0.85)) {
            VStack(spacing: 1) {
                ConvRow(label: "Kilograms", unit: "kg",
                        text: Binding(get: { kg }, set: { v in kg = v; fromKg(v) }),
                        tag: 100, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Pounds", unit: "lb",
                        text: Binding(get: { lb }, set: { v in lb = v; fromLb(v) }),
                        tag: 101, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Grams", unit: "g",
                        text: Binding(get: { g }, set: { v in g = v; fromG(v) }),
                        tag: 102, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Ounces", unit: "oz",
                        text: Binding(get: { oz }, set: { v in oz = v; fromOz(v) }),
                        tag: 103, focusedTag: $focusedTag)
            }
        }
        RefCard(title: "Quick Reference", rows: [
            ("1 kg",            "= 2.205 lb"),
            ("1 lb",            "= 0.4536 kg"),
            ("70 kg adult",     "≈ 154 lb"),
            ("IBW ♂ (Devine)",  "50 + 2.3 × in over 5 ft"),
            ("IBW ♀ (Devine)",  "45.5 + 2.3 × in over 5 ft"),
        ])
    }

    func fromKg(_ s: String) {
        guard let v = safeDouble(s) else { lb = ""; g = ""; oz = ""; return }
        lb = convFmt(v * 2.20462)
        g  = convFmt(v * 1000, decimals: 1)
        oz = convFmt(v * 35.274)
    }
    func fromLb(_ s: String) {
        guard let v = safeDouble(s) else { kg = ""; g = ""; oz = ""; return }
        let k = v / 2.20462
        kg = convFmt(k)
        g  = convFmt(k * 1000, decimals: 1)
        oz = convFmt(v * 16)
    }
    func fromG(_ s: String) {
        guard let v = safeDouble(s) else { kg = ""; lb = ""; oz = ""; return }
        let k = v / 1000
        kg = convFmt(k)
        lb = convFmt(k * 2.20462)
        oz = convFmt(k * 35.274)
    }
    func fromOz(_ s: String) {
        guard let v = safeDouble(s) else { kg = ""; lb = ""; g = ""; return }
        let k = v / 35.274
        kg = convFmt(k)
        lb = convFmt(k * 2.20462)
        g  = convFmt(k * 1000, decimals: 1)
    }
}

// MARK: - Volume

struct VolumeConversionView: View {
    @FocusState.Binding var focusedTag: Int?
    @State private var mL   = ""
    @State private var L    = ""
    @State private var oz   = ""
    @State private var tsp  = ""
    @State private var tbsp = ""

    var body: some View {
        ConvCard(title: "Volume", icon: "drop.fill",
                 accentColor: Color(red: 0.18, green: 0.60, blue: 0.78)) {
            VStack(spacing: 1) {
                ConvRow(label: "Milliliters",  unit: "mL",    text: Binding(get: { mL   }, set: { v in mL   = v; fromML(v)   }), tag: 200, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Liters",       unit: "L",     text: Binding(get: { L    }, set: { v in L    = v; fromL(v)    }), tag: 201, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Fluid Ounces", unit: "fl oz", text: Binding(get: { oz   }, set: { v in oz   = v; fromOz(v)   }), tag: 202, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Teaspoons",    unit: "tsp",   text: Binding(get: { tsp  }, set: { v in tsp  = v; fromTsp(v)  }), tag: 203, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Tablespoons",  unit: "tbsp",  text: Binding(get: { tbsp }, set: { v in tbsp = v; fromTbsp(v) }), tag: 204, focusedTag: $focusedTag)
            }
        }
    }

    func fromML(_ s: String) {
        guard let v = safeDouble(s) else { L = ""; oz = ""; tsp = ""; tbsp = ""; return }
        L    = convFmt(v / 1000)
        oz   = convFmt(v / 29.5735)
        tsp  = convFmt(v / 4.92892)
        tbsp = convFmt(v / 14.7868)
    }
    func fromL(_ s: String) {
        guard let v = safeDouble(s) else { mL = ""; oz = ""; tsp = ""; tbsp = ""; return }
        let ml = v * 1000
        mL   = convFmt(ml, decimals: 2)
        oz   = convFmt(ml / 29.5735)
        tsp  = convFmt(ml / 4.92892)
        tbsp = convFmt(ml / 14.7868)
    }
    func fromOz(_ s: String) {
        guard let v = safeDouble(s) else { mL = ""; L = ""; tsp = ""; tbsp = ""; return }
        let ml = v * 29.5735
        mL   = convFmt(ml, decimals: 2)
        L    = convFmt(ml / 1000)
        tsp  = convFmt(ml / 4.92892)
        tbsp = convFmt(ml / 14.7868)
    }
    func fromTsp(_ s: String) {
        guard let v = safeDouble(s) else { mL = ""; L = ""; oz = ""; tbsp = ""; return }
        let ml = v * 4.92892
        mL   = convFmt(ml, decimals: 2)
        L    = convFmt(ml / 1000)
        oz   = convFmt(ml / 29.5735)
        tbsp = convFmt(ml / 14.7868)
    }
    func fromTbsp(_ s: String) {
        guard let v = safeDouble(s) else { mL = ""; L = ""; oz = ""; tsp = ""; return }
        let ml = v * 14.7868
        mL   = convFmt(ml, decimals: 2)
        L    = convFmt(ml / 1000)
        oz   = convFmt(ml / 29.5735)
        tsp  = convFmt(ml / 4.92892)
    }
}

// MARK: - Pressure

struct PressureConversionView: View {
    @FocusState.Binding var focusedTag: Int?
    @State private var mmhg  = ""
    @State private var cmH2O = ""
    @State private var kpa   = ""
    @State private var atm   = ""
    @State private var inhg  = ""

    var body: some View {
        ConvCard(title: "Pressure", icon: "gauge.medium",
                 accentColor: Color(red: 0.55, green: 0.35, blue: 0.80)) {
            VStack(spacing: 1) {
                ConvRow(label: "mmHg",        unit: "mmHg",   text: Binding(get: { mmhg  }, set: { v in mmhg  = v; fromMmhg(v)  }), tag: 300, focusedTag: $focusedTag, note: "MAP, CVP, blood pressure")
                Divider().padding(.leading, 14)
                ConvRow(label: "cmH₂O",       unit: "cmH₂O",  text: Binding(get: { cmH2O }, set: { v in cmH2O = v; fromCmH2O(v) }), tag: 301, focusedTag: $focusedTag, note: "PEEP, airway pressures")
                Divider().padding(.leading, 14)
                ConvRow(label: "kPa",         unit: "kPa",    text: Binding(get: { kpa   }, set: { v in kpa   = v; fromKpa(v)   }), tag: 302, focusedTag: $focusedTag, note: "European / ABG reports")
                Divider().padding(.leading, 14)
                ConvRow(label: "Atmospheres", unit: "atm",    text: Binding(get: { atm   }, set: { v in atm   = v; fromAtm(v)   }), tag: 303, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "inHg",        unit: "inHg",   text: Binding(get: { inhg  }, set: { v in inhg  = v; fromInhg(v)  }), tag: 304, focusedTag: $focusedTag)
            }
        }
        RefCard(title: "Clinical Reference", rows: [
            ("Normal MAP",    "70–100 mmHg"),
            ("Normal CVP",    "2–8 mmHg  /  3–11 cmH₂O"),
            ("PEEP standard", "5 cmH₂O = 3.7 mmHg"),
            ("PEEP obese",    "8–10 cmH₂O"),
            ("1 mmHg",        "= 1.36 cmH₂O  =  0.133 kPa"),
        ])
    }

    func fromMmhg(_ s: String) {
        guard let v = safeDouble(s) else { cmH2O = ""; kpa = ""; atm = ""; inhg = ""; return }
        cmH2O = convFmt(v * 1.35951)
        kpa   = convFmt(v * 0.133322)
        atm   = convFmt(v / 760)
        inhg  = convFmt(v / 25.4)
    }
    func fromCmH2O(_ s: String) {
        guard let v = safeDouble(s) else { mmhg = ""; kpa = ""; atm = ""; inhg = ""; return }
        let m = v / 1.35951
        mmhg  = convFmt(m)
        kpa   = convFmt(m * 0.133322)
        atm   = convFmt(m / 760)
        inhg  = convFmt(m / 25.4)
    }
    func fromKpa(_ s: String) {
        guard let v = safeDouble(s) else { mmhg = ""; cmH2O = ""; atm = ""; inhg = ""; return }
        let m = v / 0.133322
        mmhg  = convFmt(m)
        cmH2O = convFmt(m * 1.35951)
        atm   = convFmt(m / 760)
        inhg  = convFmt(m / 25.4)
    }
    func fromAtm(_ s: String) {
        guard let v = safeDouble(s) else { mmhg = ""; cmH2O = ""; kpa = ""; inhg = ""; return }
        let m = v * 760
        mmhg  = convFmt(m)
        cmH2O = convFmt(m * 1.35951)
        kpa   = convFmt(m * 0.133322)
        inhg  = convFmt(m / 25.4)
    }
    func fromInhg(_ s: String) {
        guard let v = safeDouble(s) else { mmhg = ""; cmH2O = ""; kpa = ""; atm = ""; return }
        let m = v * 25.4
        mmhg  = convFmt(m)
        cmH2O = convFmt(m * 1.35951)
        kpa   = convFmt(m * 0.133322)
        atm   = convFmt(m / 760)
    }
}

// MARK: - Temperature

struct TemperatureConversionView: View {
    @FocusState.Binding var focusedTag: Int?
    @State private var celsius    = ""
    @State private var fahrenheit = ""
    @State private var kelvin     = ""

    var body: some View {
        ConvCard(title: "Temperature", icon: "thermometer.medium",
                 accentColor: Color(red: 0.85, green: 0.35, blue: 0.25)) {
            VStack(spacing: 1) {
                ConvRow(label: "Celsius",    unit: "°C", text: Binding(get: { celsius    }, set: { v in celsius    = v; fromC(v) }), tag: 400, focusedTag: $focusedTag, note: "Clinical standard")
                Divider().padding(.leading, 14)
                ConvRow(label: "Fahrenheit", unit: "°F", text: Binding(get: { fahrenheit }, set: { v in fahrenheit = v; fromF(v) }), tag: 401, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Kelvin",     unit: "K",  text: Binding(get: { kelvin     }, set: { v in kelvin     = v; fromK(v) }), tag: 402, focusedTag: $focusedTag)
            }
        }
        RefCard(title: "Clinical Reference", rows: [
            ("Normal body temp",     "37.0°C  /  98.6°F"),
            ("Fever",                ">38.0°C  /  >100.4°F"),
            ("Hypothermia",          "<35.0°C  /  <95.0°F"),
            ("MH cooling target",    "<38.5°C"),
            ("TTM / targeted cooling","33–36°C"),
        ])
    }

    func fromC(_ s: String) {
        guard let v = safeDouble(s) else { fahrenheit = ""; kelvin = ""; return }
        fahrenheit = convFmt(v * 9/5 + 32, decimals: 2)
        kelvin     = convFmt(v + 273.15,   decimals: 2)
    }
    func fromF(_ s: String) {
        guard let v = safeDouble(s) else { celsius = ""; kelvin = ""; return }
        let c = (v - 32) * 5/9
        celsius = convFmt(c,           decimals: 2)
        kelvin  = convFmt(c + 273.15,  decimals: 2)
    }
    func fromK(_ s: String) {
        guard let v = safeDouble(s) else { celsius = ""; fahrenheit = ""; return }
        let c = v - 273.15
        celsius    = convFmt(c,            decimals: 2)
        fahrenheit = convFmt(c * 9/5 + 32, decimals: 2)
    }
}

// MARK: - Length

struct LengthConversionView: View {
    @FocusState.Binding var focusedTag: Int?
    @State private var cm  = ""
    @State private var ins = ""
    @State private var ft  = ""
    @State private var m   = ""

    var body: some View {
        ConvCard(title: "Length / Height", icon: "ruler.fill",
                 accentColor: Color(red: 0.22, green: 0.60, blue: 0.45)) {
            VStack(spacing: 1) {
                ConvRow(label: "Centimeters", unit: "cm", text: Binding(get: { cm  }, set: { v in cm  = v; fromCm(v) }), tag: 500, focusedTag: $focusedTag, note: "Used for IBW / drug dosing")
                Divider().padding(.leading, 14)
                ConvRow(label: "Inches",      unit: "in", text: Binding(get: { ins }, set: { v in ins = v; fromIn(v) }), tag: 501, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Feet",        unit: "ft", text: Binding(get: { ft  }, set: { v in ft  = v; fromFt(v) }), tag: 502, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Meters",      unit: "m",  text: Binding(get: { m   }, set: { v in m   = v; fromM(v)  }), tag: 503, focusedTag: $focusedTag)
            }
        }
        RefCard(title: "Quick Reference", rows: [
            ("5 ft 0 in",  "= 152.4 cm"),
            ("5 ft 6 in",  "= 167.6 cm"),
            ("6 ft 0 in",  "= 182.9 cm"),
            ("1 inch",     "= 2.54 cm"),
            ("1 foot",     "= 30.48 cm"),
        ])
    }

    func fromCm(_ s: String) {
        guard let v = safeDouble(s) else { ins = ""; ft = ""; m = ""; return }
        ins = convFmt(v / 2.54)
        ft  = convFmt(v / 30.48)
        m   = convFmt(v / 100)
    }
    func fromIn(_ s: String) {
        guard let v = safeDouble(s) else { cm = ""; ft = ""; m = ""; return }
        let c = v * 2.54
        cm = convFmt(c, decimals: 1)
        ft = convFmt(v / 12)
        m  = convFmt(c / 100)
    }
    func fromFt(_ s: String) {
        guard let v = safeDouble(s) else { cm = ""; ins = ""; m = ""; return }
        let c = v * 30.48
        cm  = convFmt(c, decimals: 1)
        ins = convFmt(v * 12)
        m   = convFmt(c / 100)
    }
    func fromM(_ s: String) {
        guard let v = safeDouble(s) else { cm = ""; ins = ""; ft = ""; return }
        let c = v * 100
        cm  = convFmt(c, decimals: 1)
        ins = convFmt(c / 2.54)
        ft  = convFmt(c / 30.48)
    }
}

// MARK: - Drug Dose

struct DoseConversionView: View {
    @FocusState.Binding var focusedTag: Int?

    @State private var doseMg  = ""
    @State private var doseMcg = ""
    @State private var doseG   = ""
    @State private var wt: Double = 70
    @State private var wtText  = "70"
    @State private var mcgKgMin = ""
    @State private var mgKgHr  = ""
    @State private var mgHr    = ""

    var body: some View {
        ConvCard(title: "Drug Dose — Mass Units", icon: "pills.fill",
                 accentColor: Color(red: 0.70, green: 0.35, blue: 0.20)) {
            VStack(spacing: 1) {
                ConvRow(label: "Milligrams", unit: "mg",  text: Binding(get: { doseMg  }, set: { v in doseMg  = v; fromMg(v)    }), tag: 600, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Micrograms", unit: "mcg", text: Binding(get: { doseMcg }, set: { v in doseMcg = v; fromMcg(v)   }), tag: 601, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Grams",      unit: "g",   text: Binding(get: { doseG   }, set: { v in doseG   = v; fromDoseG(v) }), tag: 602, focusedTag: $focusedTag)
            }
        }

        ConvCard(title: "Infusion Rate Equivalents", icon: "iv.bag.fill",
                 accentColor: Color(red: 0.30, green: 0.50, blue: 0.75)) {
            VStack(spacing: 1) {
                ConvRow(label: "Patient weight", unit: "kg",
                        text: Binding(get: { wtText  }, set: { v in wtText = v; wt = safeDouble(v) ?? 70; recalcInfusion() }),
                        tag: 603, focusedTag: $focusedTag,
                        note: "Used for weight-based rate conversions")
                Divider().padding(.leading, 14)
                ConvRow(label: "mcg/kg/min", unit: "mcg/kg/min", text: Binding(get: { mcgKgMin }, set: { v in mcgKgMin = v; fromMcgKgMin(v) }), tag: 604, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "mg/kg/hr",   unit: "mg/kg/hr",   text: Binding(get: { mgKgHr  }, set: { v in mgKgHr  = v; fromMgKgHr(v)  }), tag: 605, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "mg/hr total",unit: "mg/hr",      text: Binding(get: { mgHr    }, set: { v in mgHr    = v; fromMgHr(v)    }), tag: 606, focusedTag: $focusedTag)
            }
        }

        RefCard(title: "Opioid Equivalencies (IV)", rows: [
            ("Morphine 10 mg",     "≈ Fentanyl 100 mcg"),
            ("Fentanyl 100 mcg",   "≈ Hydromorphone 1.5 mg"),
            ("Hydromorphone 1 mg", "≈ Morphine ~7 mg IV"),
            ("1 mg",               "= 1,000 mcg  =  0.001 g"),
        ])
    }

    func fromMg(_ s: String) {
        guard let v = safeDouble(s) else { doseMcg = ""; doseG = ""; return }
        doseMcg = convFmt(v * 1000, decimals: 1)
        doseG   = convFmt(v / 1000)
    }
    func fromMcg(_ s: String) {
        guard let v = safeDouble(s) else { doseMg = ""; doseG = ""; return }
        doseMg = convFmt(v / 1000)
        doseG  = convFmt(v / 1_000_000)
    }
    func fromDoseG(_ s: String) {
        guard let v = safeDouble(s) else { doseMg = ""; doseMcg = ""; return }
        doseMg  = convFmt(v * 1000, decimals: 2)
        doseMcg = convFmt(v * 1_000_000, decimals: 1)
    }
    // Fixed: removed the stale `_ = v` that caused "cannot find 'v' in scope"
    func recalcInfusion() {
        if !mcgKgMin.isEmpty      { fromMcgKgMin(mcgKgMin) }
        else if !mgKgHr.isEmpty   { fromMgKgHr(mgKgHr)     }
        else if !mgHr.isEmpty     { fromMgHr(mgHr)          }
    }
    func fromMcgKgMin(_ s: String) {
        guard let v = safeDouble(s), wt > 0 else { mgKgHr = ""; mgHr = ""; return }
        let mKgHr = v * 0.06
        mgKgHr = convFmt(mKgHr)
        mgHr   = convFmt(mKgHr * wt)
    }
    func fromMgKgHr(_ s: String) {
        guard let v = safeDouble(s), wt > 0 else { mcgKgMin = ""; mgHr = ""; return }
        mcgKgMin = convFmt(v / 0.06)
        mgHr     = convFmt(v * wt)
    }
    func fromMgHr(_ s: String) {
        guard let v = safeDouble(s), wt > 0 else { mcgKgMin = ""; mgKgHr = ""; return }
        let mKgHr = v / wt
        mgKgHr   = convFmt(mKgHr)
        mcgKgMin = convFmt(mKgHr / 0.06)
    }
}

// MARK: - Infusion Rate

struct InfusionConversionView: View {
    @FocusState.Binding var focusedTag: Int?

    @State private var concText   = "1"
    @State private var rateMLHr   = ""
    @State private var rateMgHr   = ""
    @State private var rateMcgMin = ""
    @State private var wtText     = "70"
    @State private var wt: Double = 70

    var conc: Double { safeDouble(concText) ?? 1.0 }

    var body: some View {
        ConvCard(title: "Pump Rate ↔ Drug Delivery", icon: "iv.bag.fill",
                 accentColor: Color(red: 0.20, green: 0.52, blue: 0.68)) {
            VStack(spacing: 1) {
                ConvRow(label: "Concentration",  unit: "mg/mL",   text: Binding(get: { concText   }, set: { v in concText   = v; recalcFromRate() }), tag: 700, focusedTag: $focusedTag, note: "Drug concentration in syringe/bag")
                Divider().padding(.leading, 14)
                ConvRow(label: "Patient weight", unit: "kg",      text: Binding(get: { wtText     }, set: { v in wtText     = v; wt = safeDouble(v) ?? 70; recalcFromRate() }), tag: 701, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Pump rate",      unit: "mL/hr",   text: Binding(get: { rateMLHr   }, set: { v in rateMLHr   = v; fromMlHr(v)    }), tag: 702, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Delivery",       unit: "mg/hr",   text: Binding(get: { rateMgHr   }, set: { v in rateMgHr   = v; fromMgHr(v)    }), tag: 703, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "Delivery",       unit: "mcg/min", text: Binding(get: { rateMcgMin }, set: { v in rateMcgMin = v; fromMcgMin(v)  }), tag: 704, focusedTag: $focusedTag)
            }
        }
        RefCard(title: "Standard Drip Concentrations", rows: [
            ("Norepinephrine",  "4 mg / 250 mL = 16 mcg/mL"),
            ("Epinephrine",     "4 mg / 250 mL = 16 mcg/mL"),
            ("Phenylephrine",   "100 mg / 1000 mL = 100 mcg/mL"),
            ("Dopamine",        "400 mg / 250 mL = 1600 mcg/mL"),
            ("Dobutamine",      "250 mg / 250 mL = 1000 mcg/mL"),
            ("Vasopressin",     "20 u / 100 mL = 0.2 u/mL"),
            ("Propofol",        "10 mg/mL  (1% standard vial)"),
            ("Remifentanil",    "50 mcg/mL  (1 mg / 20 mL NS)"),
        ])
    }

    func fromMlHr(_ s: String) {
        guard let v = safeDouble(s), conc > 0 else { rateMgHr = ""; rateMcgMin = ""; return }
        let mgh = v * conc
        rateMgHr   = convFmt(mgh)
        rateMcgMin = convFmt(mgh * 1000 / 60)
    }
    func fromMgHr(_ s: String) {
        guard let v = safeDouble(s), conc > 0 else { rateMLHr = ""; rateMcgMin = ""; return }
        rateMLHr   = convFmt(v / conc)
        rateMcgMin = convFmt(v * 1000 / 60)
    }
    func fromMcgMin(_ s: String) {
        guard let v = safeDouble(s), conc > 0 else { rateMLHr = ""; rateMgHr = ""; return }
        let mgh = v * 60 / 1000
        rateMgHr = convFmt(mgh)
        rateMLHr = convFmt(mgh / conc)
    }
    func recalcFromRate() {
        if !rateMLHr.isEmpty        { fromMlHr(rateMLHr)       }
        else if !rateMgHr.isEmpty   { fromMgHr(rateMgHr)       }
        else if !rateMcgMin.isEmpty { fromMcgMin(rateMcgMin)   }
    }
}

// MARK: - Concentration

struct ConcentrationConversionView: View {
    @FocusState.Binding var focusedTag: Int?

    @State private var mgMl    = ""
    @State private var percent = ""
    @State private var mcgMl   = ""
    @State private var ratio   = ""

    var body: some View {
        ConvCard(title: "Concentration", icon: "cross.vial.fill",
                 accentColor: Color(red: 0.45, green: 0.60, blue: 0.25)) {
            VStack(spacing: 1) {
                ConvRow(label: "mg/mL",       unit: "mg/mL",  text: Binding(get: { mgMl    }, set: { v in mgMl    = v; fromMgMl(v)    }), tag: 800, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "% (w/v)",     unit: "%",      text: Binding(get: { percent }, set: { v in percent = v; fromPercent(v) }), tag: 801, focusedTag: $focusedTag, note: "1% = 10 mg/mL")
                Divider().padding(.leading, 14)
                ConvRow(label: "mcg/mL",      unit: "mcg/mL", text: Binding(get: { mcgMl   }, set: { v in mcgMl   = v; fromMcgMl(v)   }), tag: 802, focusedTag: $focusedTag)
                Divider().padding(.leading, 14)
                ConvRow(label: "1 : X ratio", unit: "X",      text: Binding(get: { ratio    }, set: { v in ratio    = v; fromRatio(v)   }), tag: 803, focusedTag: $focusedTag, note: "e.g. enter 1000 for 1:1000")
            }
        }
        RefCard(title: "Common Concentrations", rows: [
            ("Propofol 1%",           "10 mg/mL"),
            ("Lidocaine 1% / 2%",     "10 mg/mL  /  20 mg/mL"),
            ("Bupivacaine 0.5%",      "5 mg/mL"),
            ("Ropivacaine 0.2%",      "2 mg/mL"),
            ("Epi 1:1000",            "1 mg/mL  (0.1%)"),
            ("Epi 1:10,000",          "0.1 mg/mL  (0.01%)"),
            ("Epi 1:200,000 (LA adj)","5 mcg/mL"),
            ("Methylene Blue 1%",     "10 mg/mL"),
            ("NaHCO₃ 8.4%",           "1 mEq/mL  =  84 mg/mL"),
        ])
    }

    func fromMgMl(_ s: String) {
        guard let v = safeDouble(s) else { percent = ""; mcgMl = ""; ratio = ""; return }
        percent = convFmt(v / 10)
        mcgMl   = convFmt(v * 1000, decimals: 1)
        ratio   = v > 0 ? convFmt(1000 / v, decimals: 0) : ""
    }
    func fromPercent(_ s: String) {
        guard let v = safeDouble(s) else { mgMl = ""; mcgMl = ""; ratio = ""; return }
        let m = v * 10
        mgMl  = convFmt(m)
        mcgMl = convFmt(m * 1000, decimals: 1)
        ratio = m > 0 ? convFmt(1000 / m, decimals: 0) : ""
    }
    func fromMcgMl(_ s: String) {
        guard let v = safeDouble(s) else { mgMl = ""; percent = ""; ratio = ""; return }
        let m = v / 1000
        mgMl    = convFmt(m)
        percent = convFmt(m / 10)
        ratio   = m > 0 ? convFmt(1000 / m, decimals: 0) : ""
    }
    func fromRatio(_ s: String) {
        guard let v = safeDouble(s), v > 0 else { mgMl = ""; percent = ""; mcgMl = ""; return }
        let m = 1000 / v
        mgMl    = convFmt(m)
        percent = convFmt(m / 10)
        mcgMl   = convFmt(m * 1000, decimals: 1)
    }
}
