import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case navyGold     = "Navy & Gold"
    case deepTeal     = "Deep Teal"
    case midnightRed  = "Midnight Red"
    case slateGreen   = "Slate Green"
    case charcoalBlue = "Charcoal Blue"
    case purpleGray   = "Purple Gray"
    case astmColors   = "ASTM Drug Classes"
    var id: String { rawValue }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"
    var id: String { rawValue }
}

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .astmColors
    @AppStorage("selectedColorScheme") var selectedColorSchemeRaw: String = AppColorScheme.system.rawValue

    var selectedColorScheme: AppColorScheme {
        get { AppColorScheme(rawValue: selectedColorSchemeRaw) ?? .system }
        set { selectedColorSchemeRaw = newValue.rawValue }
    }

    var colorScheme: ColorScheme? {
        switch selectedColorScheme {
        case .light:  return .light
        case .dark:   return .dark
        case .system: return nil
        }
    }

    var primary: Color       { palette.primary }
    var secondary: Color     { palette.secondary }
    var accent: Color        { palette.accent }
    var headerBg: Color      { palette.headerBg }
    var cardBg: Color        { palette.cardBg }
    var tabBarBg: Color      { palette.tabBarBg }

    private var palette: ThemePalette { selectedTheme.palette }

    func sectionColor(_ key: String) -> Color {
        switch key {
        case "section1":  return palette.s1
        case "section2":  return palette.s2
        case "section3":  return palette.s3
        case "section4":  return palette.s4
        case "section5":  return palette.s5
        case "section6":  return palette.s6
        case "section7":  return palette.s7
        case "section8":  return palette.s8
        case "section9":  return palette.s9
        case "section10": return palette.s10
        case "section11": return palette.s11
        case "section12": return palette.s12
        case "section13": return palette.s13
        case "section14": return palette.s14
        case "induction": return palette.s4
        case "volatile":  return palette.s3
        case "nmb":       return palette.s5
        case "opioid":    return palette.s8
        case "local":     return palette.s10
        case "vasopressor": return palette.s9
        case "reversal":  return palette.s5
        case "emergency": return palette.s12
        case "sectionTIVA": return palette.tiva
        case "sectionOB":   return palette.ob
        default:          return palette.primary
        }
    }
}

struct ThemePalette {
    let primary, secondary, accent, headerBg, cardBg, tabBarBg: Color
    let s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14: Color
    let tiva: Color
    let ob: Color
}

extension AppTheme {
    var palette: ThemePalette {
        switch self {

        case .navyGold:
            return ThemePalette(
                primary:   Color(hex: "1B3A6B"), secondary: Color(hex: "2E6DA4"),
                accent:    Color(hex: "C9A24A"), headerBg:  Color(hex: "1B3A6B"),
                cardBg:    Color(hex: "EBF5FB"), tabBarBg:  Color(hex: "1B3A6B"),
                s1:  Color(hex: "1B3A6B"), s2:  Color(hex: "1A5276"),
                s3:  Color(hex: "4A235A"), s4:  Color(hex: "1B4F72"),
                s5:  Color(hex: "922B21"), s6:  Color(hex: "117A65"),
                s7:  Color(hex: "1A5276"), s8:  Color(hex: "6E2F8C"),
                s9:  Color(hex: "7D6608"), s10: Color(hex: "1A5230"),
                s11: Color(hex: "6E2C00"), s12: Color(hex: "C0392B"),
                s13: Color(hex: "154360"), s14: Color(hex: "145A32"), tiva: Color(hex: "0B4F6C"), ob: Color(hex: "8E3A59"))

        case .deepTeal:
            return ThemePalette(
                primary:   Color(hex: "0D5C5C"), secondary: Color(hex: "1A8F8F"),
                accent:    Color(hex: "F0A500"), headerBg:  Color(hex: "0D5C5C"),
                cardBg:    Color(hex: "E0F5F5"), tabBarBg:  Color(hex: "0D5C5C"),
                s1:  Color(hex: "0D5C5C"), s2:  Color(hex: "0A7070"),
                s3:  Color(hex: "5C3870"), s4:  Color(hex: "0A4F7A"),
                s5:  Color(hex: "8A2020"), s6:  Color(hex: "0A6B50"),
                s7:  Color(hex: "0A607A"), s8:  Color(hex: "6A1F80"),
                s9:  Color(hex: "7A6000"), s10: Color(hex: "0A5020"),
                s11: Color(hex: "6A2A00"), s12: Color(hex: "C03030"),
                s13: Color(hex: "103050"), s14: Color(hex: "105030"), tiva: Color(hex: "0A4060"), ob: Color(hex: "7A3050"))

        case .midnightRed:
            return ThemePalette(
                primary:   Color(hex: "7B0000"), secondary: Color(hex: "B22222"),
                accent:    Color(hex: "E8C048"), headerBg:  Color(hex: "7B0000"),
                cardBg:    Color(hex: "FDF0F0"), tabBarBg:  Color(hex: "7B0000"),
                s1:  Color(hex: "5C0000"), s2:  Color(hex: "7B1200"),
                s3:  Color(hex: "4A1A6B"), s4:  Color(hex: "3A1A6B"),
                s5:  Color(hex: "7B0000"), s6:  Color(hex: "005C30"),
                s7:  Color(hex: "003A6B"), s8:  Color(hex: "5C0040"),
                s9:  Color(hex: "5C4000"), s10: Color(hex: "004A20"),
                s11: Color(hex: "5C2000"), s12: Color(hex: "9B0000"),
                s13: Color(hex: "001A5C"), s14: Color(hex: "003A20"), tiva: Color(hex: "0A2A50"), ob: Color(hex: "6B1F40"))

        case .slateGreen:
            return ThemePalette(
                primary:   Color(hex: "2D5016"), secondary: Color(hex: "4A7A28"),
                accent:    Color(hex: "E0A030"), headerBg:  Color(hex: "2D5016"),
                cardBg:    Color(hex: "EDF5E6"), tabBarBg:  Color(hex: "2D5016"),
                s1:  Color(hex: "2D5016"), s2:  Color(hex: "1A5A3A"),
                s3:  Color(hex: "3A1A60"), s4:  Color(hex: "1A3A70"),
                s5:  Color(hex: "8A2020"), s6:  Color(hex: "1A6A1A"),
                s7:  Color(hex: "1A4A6A"), s8:  Color(hex: "5A1A80"),
                s9:  Color(hex: "6A5A00"), s10: Color(hex: "1A5A10"),
                s11: Color(hex: "5A2A00"), s12: Color(hex: "AA2020"),
                s13: Color(hex: "102050"), s14: Color(hex: "105A20"),
                tiva: Color(hex: "0A3A60"), ob: Color(hex: "7A2A50"))

        case .charcoalBlue:
            return ThemePalette(
                primary:   Color(hex: "2C3E50"), secondary: Color(hex: "34495E"),
                accent:    Color(hex: "3498DB"), headerBg:  Color(hex: "2C3E50"),
                cardBg:    Color(hex: "ECF0F1"), tabBarBg:  Color(hex: "2C3E50"),
                s1:  Color(hex: "2C3E50"), s2:  Color(hex: "1F618D"),
                s3:  Color(hex: "6C3483"), s4:  Color(hex: "1A5276"),
                s5:  Color(hex: "922B21"), s6:  Color(hex: "117A65"),
                s7:  Color(hex: "1F618D"), s8:  Color(hex: "6E2F8C"),
                s9:  Color(hex: "7E5109"), s10: Color(hex: "1E8449"),
                s11: Color(hex: "7B241C"), s12: Color(hex: "C0392B"),
                s13: Color(hex: "154360"), s14: Color(hex: "145A32"), tiva: Color(hex: "0B4F6C"), ob: Color(hex: "8E3A59"))

        case .purpleGray:
            return ThemePalette(
                primary:   Color(hex: "4A3060"), secondary: Color(hex: "7B5EA7"),
                accent:    Color(hex: "F39C12"), headerBg:  Color(hex: "4A3060"),
                cardBg:    Color(hex: "F0EAF8"), tabBarBg:  Color(hex: "4A3060"),
                s1:  Color(hex: "4A3060"), s2:  Color(hex: "2A4A80"),
                s3:  Color(hex: "6A2080"), s4:  Color(hex: "2A4A70"),
                s5:  Color(hex: "802020"), s6:  Color(hex: "205A40"),
                s7:  Color(hex: "204A70"), s8:  Color(hex: "5A1A70"),
                s9:  Color(hex: "705A00"), s10: Color(hex: "1A5A30"),
                s11: Color(hex: "5A2A10"), s12: Color(hex: "A02020"),
                s13: Color(hex: "1A3060"), s14: Color(hex: "1A4A20"), tiva: Color(hex: "0A3A60"), ob: Color(hex: "7A2A50"))

        case .astmColors:
            return ThemePalette(
                primary:   Color(hex: "1C2B3A"), secondary: Color(hex: "2E4560"),
                accent:    Color(hex: "C4A800"), headerBg:  Color(hex: "1C2B3A"),
                cardBg:    Color(hex: "F4F4F0"), tabBarBg:  Color(hex: "1C2B3A"),
                s1:  Color(hex: "3A4A5A"),   // Anthropometrics — slate
                s2:  Color(hex: "3A5068"),   // Airway — steel blue-grey
                s3:  Color(hex: "9A7800"),   // Volatile/MAC — amber (induction family)
                s4:  Color(hex: "B89800"),   // Induction — ASTM YELLOW
                s5:  Color(hex: "C02000"),   // NMB — ASTM FLUORESCENT RED
                s6:  Color(hex: "0E6858"),   // Fluids — deep teal
                s7:  Color(hex: "2A5080"),   // Ventilator — slate blue
                s8:  Color(hex: "1068B8"),   // Opioids — ASTM SKY BLUE
                s9:  Color(hex: "5E2A90"),   // Vasopressors — ASTM VIOLET
                s10: Color(hex: "4E5C6A"),   // Local Anesthetics — ASTM GREY
                s11: Color(hex: "0A7272"),   // PONV/Antiemetics — ASTM CYAN
                s12: Color(hex: "146E30"),   // Emergency — ASTM GREEN
                s13: Color(hex: "0C2A50"),   // Cardiac — dark navy
                s14: Color(hex: "1A5C28"),   // Pediatric — forest green
                tiva: Color(hex: "B84800"),  // TIVA/Benzos — ASTM ORANGE
                ob:  Color(hex: "8A2858"))   // OB/Regional — warm rose
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default:(a,r,g,b) = (1,1,1,0)
        }
        self.init(.sRGB,red:Double(r)/255,green:Double(g)/255,blue:Double(b)/255,opacity:Double(a)/255)
    }
}
