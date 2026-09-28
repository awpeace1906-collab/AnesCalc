// AnesthesiaCalc v2.0.0
// Modified: CalculationEngine.swift
// Change: Merged 8 Drug Ref sections into clinical counterparts; added Fick CO + Driving Pressure

import Foundation

// MARK: - Result Types

struct CalcResult {
    let label: String
    let value: String
    let unit: String
    let note: String
    var alert: AlertLevel = .normal
}

enum AlertLevel {
    case normal, caution, warning, critical
}

struct CalcSection {
    let title: String
    let icon: String
    let colorKey: String
    var results: [CalcResult]
}

// MARK: - Engine

struct CalculationEngine {

    let p: PatientModel

    // ── Derived base values ───────────────────────────────────────────────────

    var bmi: Double { p.weight / pow(p.height / 100, 2) }

    var ibw: Double {
        let inchesOver5ft = (p.height / 2.54) - 60
        return p.sex == .male ? 50 + 2.3 * inchesOver5ft
                              : 45.5 + 2.3 * inchesOver5ft
    }

    var adjbw: Double {
        let excess = p.weight - ibw
        return excess > 0 ? ibw + 0.4 * excess : p.weight
    }

    var lbw: Double {
        p.sex == .male
            ? 9270 * p.weight / (6680 + 216 * bmi)
            : 9270 * p.weight / (8780 + 244 * bmi)
    }

    var bsa: Double { sqrt(p.height * p.weight / 3600) }

    // Age-corrected MAC helper — Mapleson/Nickalls equation (BJA 1996; Nickalls & Mapleson 2003)
    // MACage = MAC40 × 10^[-0.00269 × (age - 40)]
    func mac(base: Double, floor: Double) -> Double {
        max(floor, base * pow(10, -0.00269 * (p.age - 40)))
    }

    var macSevo: Double  { mac(base: 1.8, floor: 0.5) }   // v2.0: was 2.0 — Mapleson 1996 MAC40
    var macDes: Double   { mac(base: 6.6, floor: 2.0) }
    var macIso: Double   { mac(base: 1.17, floor: 0.4) }  // v2.0: was 1.2 — Mapleson 1996 MAC40
    var macN2O: Double   { mac(base: 104, floor: 60)  }

    var ebv: Double {
        if p.age < 0.083 { return p.weight * 90 }
        if p.age < 1     { return p.weight * 80 }
        if p.age < 10    { return p.weight * 75 }
        return p.sex == .male ? p.weight * 75 : p.weight * 65
    }

    var maintenanceRate: Double {
        if p.weight <= 10 { return p.weight * 4 }
        if p.weight <= 20 { return 40 + (p.weight - 10) * 2 }
        return 60 + (p.weight - 20) * 1
    }

    var apfelScore: Int {
        var score = 0
        if p.sex == .female   { score += 1 }
        if !p.smokingHx        { score += 1 }
        if p.priorPONV         { score += 1 }
        if p.opioidPlanned     { score += 1 }
        return score
    }

    var apfelRisk: String {
        switch apfelScore {
        case 0, 1: return "Low (~10%)"
        case 2:    return "Moderate (~40%)"
        case 3:    return "High (~60%)"
        default:   return "Very High (~80%)"
        }
    }

    var pBarometric: Double { 760 * exp(-p.altitude / 8430) }
    var pao2Alveolar: Double { p.fio2 * (pBarometric - 47) - p.paco2 / 0.8 }

    var qtc: Double {
        guard p.heartRate > 0 else { return 0 }
        return p.qtInterval / sqrt(60 / p.heartRate)
    }

    // ── Format helpers ────────────────────────────────────────────────────────

    func fmt(_ v: Double, decimals: Int = 1) -> String {
        String(format: "%.\(decimals)f", v)
    }

    func fmtRange(_ lo: Double, _ hi: Double, decimals: Int = 1) -> String {
        "\(fmt(lo, decimals: decimals)) – \(fmt(hi, decimals: decimals))"
    }

    // ── Build all sections ────────────────────────────────────────────────────

    func buildAll() -> [CalcSection] {
        [
            anthropometrics(),
            airway(),
            macSection(),
            inductionAgents(),
            tiva(),
            nmb(),
            fluids(),
            ventilator(),
            analgesics(),
            vasopressors(),
            localAnesthetics(),
            laborEpidural(),
            ponv(),
            emergency(),
            cardiac(),
            pediatric(),
        ]
    }

    // ── 1. Anthropometrics ────────────────────────────────────────────────────
    func anthropometrics() -> CalcSection {
        let bmiCat: String
        switch bmi {
        case ..<18.5: bmiCat = "Underweight"
        case ..<25:   bmiCat = "Normal"
        case ..<30:   bmiCat = "Overweight"
        case ..<35:   bmiCat = "Obese Class I"
        case ..<40:   bmiCat = "Obese Class II"
        default:      bmiCat = "Morbid Obesity"
        }
        let bmiAlert: AlertLevel = bmi >= 40 ? .warning : bmi >= 30 ? .caution : .normal
        return CalcSection(title: "Anthropometrics", icon: "person.fill", colorKey: "section1", results: [
            CalcResult(label: "IBW (Devine)", value: fmt(ibw), unit: "kg", note: "Ideal body weight"),
            CalcResult(label: "Adjusted BW", value: fmt(adjbw), unit: "kg", note: "IBW + 0.4 × excess"),
            CalcResult(label: "LBW (Janmahasatian)", value: fmt(lbw), unit: "kg", note: "Lean body weight"),
            CalcResult(label: "BMI", value: fmt(bmi), unit: "kg/m²", note: bmiCat, alert: bmiAlert),
            CalcResult(label: "BSA (Mosteller)", value: fmt(bsa, decimals: 2), unit: "m²", note: "Body surface area"),
        ])
    }

    // ── 2. Airway ────────────────────────────────────────────────────────────
    func airway() -> CalcSection {
        let ettSize: String
        if p.age >= 18 {
            ettSize = p.sex == .male ? "7.5 – 8.0" : "7.0 – 7.5"
        } else if p.age < 1 {
            ettSize = "3.0"
        } else {
            ettSize = fmt(p.age / 4 + 3.5, decimals: 1)
        }

        let ettDepthOral: String
        if p.age >= 18 { ettDepthOral = p.sex == .male ? "23" : "21" }
        else { ettDepthOral = fmt(p.age / 2 + 12, decimals: 0) }

        let ettDepthNasal: String
        if p.age >= 18 { ettDepthNasal = p.sex == .male ? "26" : "24" }
        else { ettDepthNasal = fmt(p.age / 2 + 15, decimals: 0) }

        let blade: String
        if p.age < 1      { blade = "Miller 0" }
        else if p.age < 3  { blade = "Miller 1" }
        else if p.age < 8  { blade = "Mac 2 / Miller 2" }
        else               { blade = "Macintosh 3" }

        let lmaSize: String
        switch p.weight {
        case ..<5:  lmaSize = "1"
        case ..<11: lmaSize = "1.5"
        case ..<21: lmaSize = "2"
        case ..<31: lmaSize = "2.5"
        case ..<51: lmaSize = "3"
        case ..<71: lmaSize = "4"
        default:    lmaSize = "5"
        }

        let cuff = p.age < 8 ? "Consider uncuffed" : "Cuffed preferred"

        return CalcSection(title: "Airway Management", icon: "lungs.fill", colorKey: "section2", results: [
            CalcResult(label: "ETT Size", value: ettSize, unit: "mm ID", note: "Adult M:7.5-8 / F:7-7.5; Pedi: age/4+3.5"),
            CalcResult(label: "ETT Depth — Oral", value: ettDepthOral, unit: "cm at lip", note: "Adult M:23 F:21; Pedi: age/2+12"),
            CalcResult(label: "ETT Depth — Nasal", value: ettDepthNasal, unit: "cm at nare", note: "Adult M:26 F:24"),
            CalcResult(label: "Laryngoscope Blade", value: blade, unit: "", note: "Age-based recommendation"),
            CalcResult(label: "LMA Size", value: lmaSize, unit: "", note: "Weight-based sizing"),
            CalcResult(label: "Cuff Recommendation", value: cuff, unit: "", note: ""),
        ])
    }

    // ── 3. MAC ───────────────────────────────────────────────────────────────
    func macSection() -> CalcSection {
        return CalcSection(title: "MAC — Volatile Anesthetics", icon: "waveform.path.ecg", colorKey: "section3", results: [
            CalcResult(label: "Sevoflurane MAC 1.0", value: fmt(macSevo, decimals: 2), unit: "%", note: "Age-corrected (base 1.8% @ age 40)"),
            CalcResult(label: "Sevo MAC-awake (0.33×)", value: fmt(macSevo * 0.33, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Sevo MAC-BAR (1.6×)", value: fmt(macSevo * 1.6, decimals: 2), unit: "%", note: "Blunts adrenergic response"),
            CalcResult(label: "Desflurane MAC 1.0", value: fmt(macDes, decimals: 2), unit: "%", note: "Age-corrected (base 6.6% @ age 40)"),
            CalcResult(label: "Des MAC-awake (0.33×)", value: fmt(macDes * 0.33, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Des MAC-BAR (1.6×)", value: fmt(macDes * 1.6, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Isoflurane MAC 1.0", value: fmt(macIso, decimals: 2), unit: "%", note: "Age-corrected (base 1.17% @ age 40)"),
            CalcResult(label: "Iso MAC-awake (0.33×)", value: fmt(macIso * 0.33, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Iso MAC-BAR (1.6×)", value: fmt(macIso * 1.6, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Nitrous Oxide MAC 1.0", value: fmt(macN2O, decimals: 1), unit: "%", note: "Age-corrected (base 104% @ age 40)"),
            CalcResult(label: "Sevo with 50% N₂O", value: fmt(macSevo * 0.5, decimals: 2), unit: "% Sevo", note: "50% N₂O reduces Sevo need ~50%"),
            CalcResult(label: "── SEVOFLURANE — CLINICAL DOSING ─", value: "", unit: "", note: ""),
            CalcResult(label: "Pediatric mask induction", value: "6 – 8", unit: "%", note: "100% O₂; non-pungent; most common pedi induction agent"),
            CalcResult(label: "Induction overpressure (~1.3 MAC)", value: fmt(macSevo * 1.3, decimals: 2), unit: "% Et", note: "Reduce as BIS/depth achieved"),
            CalcResult(label: "Maintenance typical (0.7 MAC with adjuncts)", value: fmt(macSevo * 0.7, decimals: 2), unit: "% Et", note: "With opioid / N₂O / other adjuncts"),
            CalcResult(label: "Compound A — minimum fresh gas flow", value: ">2 L/min", unit: "", note: "Avoid prolonged low-flow with soda lime", alert: .caution),
            CalcResult(label: "── DESFLURANE — CLINICAL DOSING ──", value: "", unit: "", note: ""),
            CalcResult(label: "Des MAC-awake (0.33×)", value: fmt(macDes * 0.33, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Des MAC-BAR (1.6×)", value: fmt(macDes * 1.6, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Des with 50% N₂O", value: fmt(macDes * 0.5, decimals: 2), unit: "% Des", note: "Reduces sympathetic stimulation from des alone"),
            CalcResult(label: "⚠ NOT for inhalation induction", value: "—", unit: "", note: "Severe airway irritant — laryngospasm risk", alert: .warning),
            CalcResult(label: "⚠ Do not increase >1 MAC/min", value: "—", unit: "", note: "Sympathetic surge: ↑HR, ↑BP at rapid increases", alert: .caution),
            CalcResult(label: "── ISOFLURANE ────────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Iso MAC-awake (0.33×)", value: fmt(macIso * 0.33, decimals: 2), unit: "%", note: ""),
            CalcResult(label: "Iso MAC-BAR (1.6×)", value: fmt(macIso * 1.6, decimals: 2), unit: "%", note: ""),
        ])
    }

    // ── 4. Induction ────────────────────────────────────────────────────────
    func inductionAgents() -> CalcSection {
        let ageFactor: Double = p.age > 55 ? max(0.5, 1.0 - 0.01 * (p.age - 55)) : 1.0
        let propInd = p.weight * 2.0 * ageFactor
        return CalcSection(title: "Induction Agents", icon: "syringe.fill", colorKey: "section4", results: [
            CalcResult(label: "── PROPOFOL ──────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Induction — healthy adult (2 mg/kg, age-adj)", value: fmt(propInd, decimals: 0), unit: "mg", note: "Titrate slowly; reduce rate in elderly"),
            CalcResult(label: "Induction — elderly / ASA III–IV (1 mg/kg)", value: fmt(p.weight * 1.0, decimals: 0), unit: "mg", note: "Hemodynamically fragile; smaller increments"),
            CalcResult(label: "MAC / sedation bolus (0.75 mg/kg)", value: fmt(p.weight * 0.75, decimals: 0), unit: "mg", note: "Starting bolus; titrate to effect"),
            CalcResult(label: "TIVA maintenance — GA (4–12 mg/kg/hr)", value: fmtRange(p.weight * 4, p.weight * 12, decimals: 0), unit: "mg/hr", note: "= \(fmtRange(p.weight * 4 / 10, p.weight * 12 / 10, decimals: 1)) mL/hr (10 mg/mL)"),
            CalcResult(label: "Sedation infusion (25–75 mcg/kg/min)", value: fmtRange(p.weight * 25 / 1000 * 60, p.weight * 75 / 1000 * 60, decimals: 0), unit: "mg/hr", note: "Sub-anesthetic; titrate to effect"),
            CalcResult(label: "Anti-emetic sub-hypnotic (10–20 mcg/kg/min)", value: fmtRange(p.weight * 10 / 1000 * 60, p.weight * 20 / 1000 * 60, decimals: 1), unit: "mg/hr", note: "Reduces PONV at sub-sedative doses"),
            CalcResult(label: "── KETAMINE ──────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Induction IV (1–2 mg/kg)", value: fmtRange(p.weight * 1.0, p.weight * 2.0, decimals: 0), unit: "mg", note: "Dissociative; onset 1–2 min"),
            CalcResult(label: "Induction IM (4–6 mg/kg)", value: fmtRange(p.weight * 4.0, p.weight * 6.0, decimals: 0), unit: "mg", note: "Uncooperative patient; onset 3–5 min"),
            CalcResult(label: "Sub-dissociative analgesia (0.3 mg/kg)", value: fmt(p.weight * 0.3, decimals: 1), unit: "mg", note: "NMDA antagonism; opioid-sparing"),
            CalcResult(label: "Intranasal — pediatric (3–5 mg/kg)", value: fmtRange(p.weight * 3.0, p.weight * 5.0, decimals: 0), unit: "mg", note: "Procedural sedation; no IV access"),
            CalcResult(label: "TIVA adjunct infusion (0.1–0.5 mg/kg/hr)", value: fmtRange(p.weight * 0.1, p.weight * 0.5, decimals: 1), unit: "mg/hr", note: "Reduces opioid and propofol requirements"),
            CalcResult(label: "Emergence delirium prevention (midazolam 0.03 mg/kg)", value: fmt(min(5, p.weight * 0.03), decimals: 1), unit: "mg", note: "Give IV before ketamine"),
            CalcResult(label: "── ETOMIDATE ─────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Induction standard (0.3 mg/kg)", value: fmt(p.weight * 0.3, decimals: 1), unit: "mg", note: "Hemodynamically neutral; onset 30–60s"),
            CalcResult(label: "Induction elderly / compromised (0.2 mg/kg)", value: fmt(p.weight * 0.2, decimals: 1), unit: "mg", note: "Reduced dose; adrenal caution"),
            CalcResult(label: "⚠ Adrenal suppression window", value: "4–8 hrs", unit: "", note: "Single dose suppresses 11β-hydroxylase", alert: .caution),
            CalcResult(label: "── MIDAZOLAM ─────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Premedication (0.05 mg/kg IV, max 10 mg)", value: fmt(min(10, p.weight * 0.05), decimals: 1), unit: "mg", note: "IV; reduce in elderly / hepatic impairment"),
            CalcResult(label: "Sedation (0.02 mg/kg IV, max 5 mg)", value: fmt(min(5, p.weight * 0.02), decimals: 1), unit: "mg", note: "Titrate; slower onset in obese"),
            CalcResult(label: "── DEXMEDETOMIDINE ───────────", value: "", unit: "", note: ""),
            CalcResult(label: "Loading dose (1 mcg/kg over 10 min)", value: fmt(p.weight * 1.0, decimals: 0), unit: "mcg", note: "Omit or reduce if hemodynamically unstable"),
            CalcResult(label: "Maintenance infusion (0.2–0.7 mcg/kg/hr)", value: fmtRange(p.weight * 0.2, p.weight * 0.7, decimals: 1), unit: "mcg/hr", note: "No respiratory depression; useful for awake intubation"),
        ])
    }

    // ── 5. NMB ───────────────────────────────────────────────────────────────
    func nmb() -> CalcSection {
        let rocInfLo = p.weight * 5.0 / 1000 * 60
        let rocInfHi = p.weight * 12.0 / 1000 * 60
        let cisInfLo = p.weight * 1.0 / 1000 * 60
        let cisInfHi = p.weight * 3.0 / 1000 * 60
        return CalcSection(title: "Neuromuscular Blockade & Reversal", icon: "bolt.heart.fill", colorKey: "section5", results: [
            CalcResult(label: "── SUCCINYLCHOLINE ───────────", value: "", unit: "", note: ""),
            CalcResult(label: "Adult RSI (1.5 mg/kg)", value: fmt(p.weight * 1.5, decimals: 0), unit: "mg IV", note: "Onset ~45s; gold standard for RSI"),
            CalcResult(label: "Pediatric (2 mg/kg)", value: fmt(p.weight * 2.0, decimals: 0), unit: "mg IV", note: "Higher volume of distribution in children"),
            CalcResult(label: "IM dose (4 mg/kg)", value: fmt(p.weight * 4.0, decimals: 0), unit: "mg IM", note: "No IV access; onset ~3 min"),
            CalcResult(label: "⚠ Avoid in: burns >48h, crush, denervation", value: "—", unit: "", note: "Life-threatening hyperkalemia risk", alert: .critical),
            CalcResult(label: "── ROCURONIUM ────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Intubation (0.6 mg/kg)", value: fmt(p.weight * 0.6, decimals: 0), unit: "mg IV", note: "Onset 2–3 min; 30–60 min duration"),
            CalcResult(label: "RSI dose (1.2 mg/kg)", value: fmt(p.weight * 1.2, decimals: 0), unit: "mg IV", note: "Onset ~60s; reversal with sugammadex 16 mg/kg"),
            CalcResult(label: "Maintenance bolus (0.15 mg/kg)", value: fmt(p.weight * 0.15, decimals: 0), unit: "mg IV", note: "At ~25% T1 recovery"),
            CalcResult(label: "Infusion (5–12 mcg/kg/min)", value: fmtRange(rocInfLo, rocInfHi, decimals: 1), unit: "mg/hr", note: "Titrate to TOF; reduce in hepatic dysfunction"),
            CalcResult(label: "── VECURONIUM ────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Intubation (0.1 mg/kg)", value: fmt(p.weight * 0.1, decimals: 2), unit: "mg IV", note: "Onset 3–4 min; ~25–40 min duration"),
            CalcResult(label: "Maintenance bolus (0.02 mg/kg)", value: fmt(p.weight * 0.02, decimals: 2), unit: "mg IV", note: "At 25% T1 recovery"),
            CalcResult(label: "── CISATRACURIUM ─────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Intubation (0.15 mg/kg)", value: fmt(p.weight * 0.15, decimals: 1), unit: "mg IV", note: "Hoffman elimination — renal/hepatic safe"),
            CalcResult(label: "Infusion (1–3 mcg/kg/min)", value: fmtRange(cisInfLo, cisInfHi, decimals: 1), unit: "mg/hr", note: "ICU-preferred NMB; no organ-dependent clearance"),
            CalcResult(label: "── SUGAMMADEX ────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Routine reversal TOF ≥T2 (2 mg/kg)", value: fmt(p.weight * 2.0, decimals: 0), unit: "mg IV", note: "Any depth with ≥2 twitches"),
            CalcResult(label: "Deep block TOF T1/PTC 1–2 (4 mg/kg)", value: fmt(p.weight * 4.0, decimals: 0), unit: "mg IV", note: "No need to wait for spontaneous recovery"),
            CalcResult(label: "Immediate CICO reversal (16 mg/kg)", value: fmt(p.weight * 16.0, decimals: 0), unit: "mg IV", note: "Complete reversal of 1.2 mg/kg roc in <3 min", alert: .caution),
            CalcResult(label: "⚠ Does NOT reverse benzylisoquinoliniums", value: "—", unit: "", note: "No effect on cisatracurium/atracurium — use neostigmine", alert: .warning),
            CalcResult(label: "── NEOSTIGMINE ───────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Neostigmine (0.07 mg/kg, max 5 mg)", value: fmt(min(5, p.weight * 0.07), decimals: 2), unit: "mg IV", note: "Only at TOF ≥T4 with fade; ceiling effect"),
            CalcResult(label: "Glycopyrrolate partner (0.01 mg/kg)", value: fmt(min(1, p.weight * 0.01), decimals: 2), unit: "mg IV", note: "Always co-administer; prevents muscarinic bradycardia"),
        ])
    }

    // ── 6. Fluids ────────────────────────────────────────────────────────────
    func fluids() -> CalcSection {
        let mabl = ebv * (p.hemoglobin - p.minTargetHgb) / p.hemoglobin
        let npoDeficit = maintenanceRate * p.npoHours
        return CalcSection(title: "Fluid Management & Blood Loss", icon: "drop.fill", colorKey: "section6", results: [
            CalcResult(label: "EBV — Estimated Blood Volume", value: fmt(ebv, decimals: 0), unit: "mL", note: "Adult M:75 F:65; Infant:80; Neonate:90 mL/kg"),
            CalcResult(label: "MABL — Max Allowable Blood Loss", value: fmt(max(0, mabl), decimals: 0), unit: "mL", note: "EBV × (Hgb_start − Hgb_min) / Hgb_start"),
            CalcResult(label: "Maintenance Rate (4-2-1 rule)", value: fmt(maintenanceRate, decimals: 1), unit: "mL/hr", note: ""),
            CalcResult(label: "NPO Fluid Deficit", value: fmt(npoDeficit, decimals: 0), unit: "mL", note: "Maintenance × NPO hours"),
            CalcResult(label: "Third-Space Loss — general surg (~5 mL/kg/hr)", value: fmt(p.weight * 5, decimals: 0), unit: "mL/hr", note: "Estimate; 2–8 mL/kg/hr per case complexity"),
        ])
    }

    // ── 7. Ventilator ────────────────────────────────────────────────────────
    func ventilator() -> CalcSection {
        let tv6 = ibw * 6
        let tv8 = ibw * 8
        let tv7 = ibw * 7
        let rr  = round(7000 / tv7)
        let mv  = tv7 * rr / 1000
        let peep = bmi > 30 ? "8–10 cmH₂O (obese)" : "5 cmH₂O (standard)"
        let pip  = round(tv7 / 10 + 10)
        // Driving pressure estimates: DP = TV / Crs; target < 15 cmH₂O
        let dpNormal = tv6 / 50.0   // Crs ≈ 50 mL/cmH₂O (healthy lungs)
        let dpMild   = tv6 / 35.0   // Crs ≈ 35 mL/cmH₂O (mild disease)
        let dpSevere = tv6 / 20.0   // Crs ≈ 20 mL/cmH₂O (moderate ARDS)
        return CalcSection(title: "Ventilator Settings", icon: "lungs", colorKey: "section7", results: [
            CalcResult(label: "Tidal Volume — lung protective (6 mL/kg IBW)", value: fmt(tv6, decimals: 0), unit: "mL", note: "ARDSnet / ICU"),
            CalcResult(label: "Tidal Volume — standard (8 mL/kg IBW)", value: fmt(tv8, decimals: 0), unit: "mL", note: "OR routine; no significant lung disease"),
            CalcResult(label: "Respiratory Rate (target MV ~6–8 L/min)", value: fmt(rr, decimals: 0), unit: "breaths/min", note: "Adjust to ETCO₂ 35–45"),
            CalcResult(label: "Minute Ventilation", value: fmt(mv, decimals: 1), unit: "L/min", note: "TV × RR"),
            CalcResult(label: "PEEP", value: peep, unit: "", note: "Increase if hypoxic or obese"),
            CalcResult(label: "I:E Ratio", value: "1:2 standard / 1:3 if obstructive", unit: "", note: "Lengthen expiration in COPD/asthma"),
            CalcResult(label: "Peak Pressure Limit", value: fmt(pip, decimals: 0), unit: "cmH₂O", note: "Alert >30; plateau target <28", alert: pip > 30 ? .caution : .normal),
            CalcResult(label: "── DRIVING PRESSURE (TV/Crs) ─", value: "", unit: "", note: "Target DP < 15 cmH₂O to limit lung stress"),
            CalcResult(label: "DP @ normal compliance (Crs 50 mL/cmH₂O)", value: fmt(dpNormal, decimals: 1), unit: "cmH₂O", note: "6 mL/kg IBW; healthy lungs", alert: dpNormal > 15 ? .caution : .normal),
            CalcResult(label: "DP @ mild disease (Crs 35 mL/cmH₂O)", value: fmt(dpMild, decimals: 1), unit: "cmH₂O", note: "Reduce TV if DP approaches 15", alert: dpMild > 15 ? .caution : .normal),
            CalcResult(label: "DP @ mod ARDS (Crs 20 mL/cmH₂O)", value: fmt(dpSevere, decimals: 1), unit: "cmH₂O", note: "Titrate TV down; permissive hypercapnia may be needed", alert: dpSevere > 15 ? .warning : .normal),
        ])
    }

    // ── 8. Analgesics ────────────────────────────────────────────────────────
    func analgesics() -> CalcSection {
        let apap = p.weight < 50 ? p.weight * 15 : 1000
        return CalcSection(title: "Opioids & Analgesics", icon: "pills.fill", colorKey: "section8", results: [
            CalcResult(label: "Fentanyl — induction bolus (2 mcg/kg)", value: fmt(p.weight * 2, decimals: 0), unit: "mcg", note: "Slow IV over 30–60s"),
            CalcResult(label: "Fentanyl — infusion (1 mcg/kg/hr)", value: fmt(p.weight * 1, decimals: 0), unit: "mcg/hr", note: "Titrate; context-sensitive half-life"),
            CalcResult(label: "Remifentanil infusion (0.1 mcg/kg/min)", value: fmt(p.weight * 0.1, decimals: 2), unit: "mcg/kg/min", note: "Use LBW; ultra-short"),
            CalcResult(label: "Morphine IV (0.1 mg/kg)", value: fmt(p.weight * 0.1, decimals: 1), unit: "mg", note: "Titrate; longer onset vs fentanyl"),
            CalcResult(label: "Hydromorphone IV (0.015 mg/kg)", value: fmt(p.weight * 0.015, decimals: 2), unit: "mg", note: "~5× potency of morphine"),
            CalcResult(label: "Ketorolac (0.5 mg/kg IV, max 30 mg)", value: fmt(min(30, p.weight * 0.5), decimals: 0), unit: "mg", note: "Avoid renal dz / elderly / coagulopathy"),
            CalcResult(label: "Acetaminophen IV (15 mg/kg; max 1000 mg)", value: fmt(min(1000, apap), decimals: 0), unit: "mg", note: "Q6h; weight-based if <50 kg"),
            CalcResult(label: "Dexamethasone analgesic/PONV (fixed 4–10 mg)", value: "4 – 10", unit: "mg", note: "Fixed dose, not weight-based — SAMBA guidelines favor 4–5 mg; give early in case"),
            CalcResult(label: "Lidocaine infusion adjunct (1.5 mg/kg/hr)", value: fmt(p.weight * 1.5, decimals: 0), unit: "mg/hr", note: "Opioid-sparing; stop at skin closure"),
            CalcResult(label: "Ketamine sub-dissociative bolus (0.3 mg/kg)", value: fmt(p.weight * 0.3, decimals: 1), unit: "mg", note: "NMDA antagonist; opioid-sparing"),
            CalcResult(label: "── FENTANYL — EXTENDED ───────", value: "", unit: "", note: ""),
            CalcResult(label: "Fentanyl intranasal procedural (1.5 mcg/kg)", value: fmt(p.weight * 1.5, decimals: 0), unit: "mcg IN", note: "Prehospital / pediatric procedural sedation"),
            CalcResult(label: "Fentanyl intrathecal (fixed)", value: "15 – 25", unit: "mcg", note: "Rapid spinal analgesia adjunct"),
            CalcResult(label: "Fentanyl epidural bolus (fixed)", value: "50 – 100", unit: "mcg", note: "Adjunct to LA for rapid onset and block quality"),
            CalcResult(label: "── REMIFENTANIL (LBW-based) ──", value: "", unit: "LBW \(fmt(lbw, decimals: 0)) kg", note: ""),
            CalcResult(label: "TIVA infusion low (0.05 mcg/kg/min LBW)", value: fmt(lbw * 0.05, decimals: 2), unit: "mcg/min", note: "= \(fmt(lbw * 0.05 * 60, decimals: 0)) mcg/hr; context-insensitive"),
            CalcResult(label: "TIVA infusion high (0.3 mcg/kg/min LBW)", value: fmt(lbw * 0.3, decimals: 2), unit: "mcg/min", note: "= \(fmt(lbw * 0.3 * 60, decimals: 0)) mcg/hr"),
            CalcResult(label: "Laryngoscopy bolus (0.5–1 mcg/kg LBW)", value: fmt(lbw * 0.75, decimals: 1), unit: "mcg", note: "Blunts intubation response"),
            CalcResult(label: "⚠ Transition analgesia MANDATORY before stopping", value: "—", unit: "", note: "Zero residual effect — bridge to LA/opioid/NSAID", alert: .critical),
            CalcResult(label: "⚠ OIH with prolonged high-dose use", value: "—", unit: "", note: "Consider ketamine adjunct to prevent hyperalgesia", alert: .caution),
        ])
    }

    // ── 9. Vasopressors ───────────────────────────────────────────────────────
    func vasopressors() -> CalcSection {
        // Pump rates at standard concentrations
        let phenylPumpLo = p.weight * 0.5 / 100 * 60   // @ 100 mcg/mL
        let phenylPumpHi = p.weight * 3.0 / 100 * 60
        let norepiPumpLo = p.weight * 0.05 / 16 * 60   // @ 16 mcg/mL (4 mg/250 mL)
        let norepiPumpHi = p.weight * 0.5  / 16 * 60
        let epiPumpLo    = p.weight * 0.01 / 16 * 60
        let epiPumpHi    = p.weight * 0.3  / 16 * 60
        let dopPumpLo    = p.weight * 3.0  / 1600 * 60  // @ 1600 mcg/mL (400 mg/250 mL)
        let dopPumpHi    = p.weight * 20.0 / 1600 * 60
        let dobuPumpLo   = p.weight * 2.5  / 1000 * 60  // @ 1000 mcg/mL (250 mg/250 mL)
        let dobuPumpHi   = p.weight * 20.0 / 1000 * 60
        return CalcSection(title: "Vasopressors & Inotropes", icon: "heart.fill", colorKey: "section9", results: [
            CalcResult(label: "── PHENYLEPHRINE ─────────────", value: "", unit: "", note: "Pure α1; no β effects"),
            CalcResult(label: "Infusion (0.5–3 mcg/kg/min)", value: fmtRange(p.weight * 0.5, p.weight * 3.0), unit: "mcg/min", note: "Standard for spinal/epidural hypotension"),
            CalcResult(label: "Pump rate @ 100 mcg/mL", value: fmtRange(phenylPumpLo, phenylPumpHi, decimals: 1), unit: "mL/hr", note: "100 mg in 1000 mL NS"),
            CalcResult(label: "Bolus (1 mcg/kg)", value: fmt(p.weight * 1.0, decimals: 0), unit: "mcg IV", note: "Acute hypotension rescue"),
            CalcResult(label: "OB prophylaxis — start at spinal", value: fmtRange(p.weight * 0.5, p.weight * 1.5), unit: "mcg/min", note: "Titrate to MAP ≥80% baseline; preferred in OB"),
            CalcResult(label: "── NOREPINEPHRINE ────────────", value: "", unit: "", note: "α1 dominant; moderate β1"),
            CalcResult(label: "Infusion (0.05–0.5 mcg/kg/min)", value: fmtRange(p.weight * 0.05, p.weight * 0.5, decimals: 2), unit: "mcg/min", note: "Septic shock first-line vasopressor"),
            CalcResult(label: "Pump rate @ 16 mcg/mL (4 mg/250 mL)", value: fmtRange(norepiPumpLo, norepiPumpHi, decimals: 1), unit: "mL/hr", note: "Standard ICU concentration"),
            CalcResult(label: "── EPINEPHRINE ───────────────", value: "", unit: "", note: "α1, α2, β1, β2 — dose-dependent"),
            CalcResult(label: "Infusion (0.01–0.3 mcg/kg/min)", value: fmtRange(p.weight * 0.01, p.weight * 0.3, decimals: 2), unit: "mcg/min", note: "Low dose: β dominant; high dose: α dominant"),
            CalcResult(label: "Pump rate @ 16 mcg/mL (4 mg/250 mL)", value: fmtRange(epiPumpLo, epiPumpHi, decimals: 1), unit: "mL/hr", note: ""),
            CalcResult(label: "Anaphylaxis IM (0.01 mg/kg, max 0.5 mg)", value: fmt(min(0.5, p.weight * 0.01), decimals: 3), unit: "mg IM", note: "1:1000; lateral thigh; repeat q5–15 min", alert: .warning),
            CalcResult(label: "ACLS pulseless (fixed 1 mg)", value: "1", unit: "mg IV/IO", note: "q3–5 min; 1:10,000 = 10 mL", alert: .critical),
            CalcResult(label: "── DOPAMINE ──────────────────", value: "", unit: "", note: "3–10: β+dopa; >10: α dominant"),
            CalcResult(label: "Infusion (3–20 mcg/kg/min)", value: fmtRange(p.weight * 3.0, p.weight * 20.0, decimals: 0), unit: "mcg/min", note: ""),
            CalcResult(label: "Pump rate @ 1600 mcg/mL (400 mg/250 mL)", value: fmtRange(dopPumpLo, dopPumpHi, decimals: 1), unit: "mL/hr", note: "Standard cardiac drip"),
            CalcResult(label: "── DOBUTAMINE ────────────────", value: "", unit: "", note: "β1 inotrope; mild vasodilation"),
            CalcResult(label: "Infusion (2.5–20 mcg/kg/min)", value: fmtRange(p.weight * 2.5, p.weight * 20.0, decimals: 0), unit: "mcg/min", note: "Cardiogenic shock / low CO states"),
            CalcResult(label: "Pump rate @ 1000 mcg/mL (250 mg/250 mL)", value: fmtRange(dobuPumpLo, dobuPumpHi, decimals: 1), unit: "mL/hr", note: ""),
            CalcResult(label: "── VASOPRESSIN ───────────────", value: "", unit: "", note: "Weight-independent fixed dosing"),
            CalcResult(label: "Septic shock (fixed 0.03–0.04 units/min)", value: "0.03 – 0.04", unit: "units/min", note: "Add-on to norepinephrine; do not titrate beyond 0.04"),
            CalcResult(label: "── EPHEDRINE ─────────────────", value: "", unit: "", note: "Indirect α+β agonist; releases NE"),
            CalcResult(label: "IV bolus (0.1 mg/kg, max 50 mg)", value: fmt(min(50, p.weight * 0.1), decimals: 0), unit: "mg IV", note: "Spinal/epidural hypotension with bradycardia"),
            CalcResult(label: "Clinical increment — titrate to effect", value: "5–10", unit: "mg IV", note: "Typical q1–2 min PRN; onset ~60s; tachyphylaxis occurs"),
            CalcResult(label: "── GLYCOPYRROLATE ────────────", value: "", unit: "", note: "Anticholinergic; does not cross BBB"),
            CalcResult(label: "Bradycardia (0.004 mg/kg, max 0.4 mg)", value: fmt(min(0.4, max(0.1, p.weight * 0.004)), decimals: 3), unit: "mg IV", note: "Min 0.1 mg; preferred over atropine for vagal bradycardia"),
            CalcResult(label: "Antisialagogue (0.004 mg/kg, max 0.2 mg)", value: fmt(min(0.2, p.weight * 0.004), decimals: 3), unit: "mg IV/IM", note: "Pre-induction; give 30–60 min before if IM"),
            CalcResult(label: "With neostigmine (0.2 mg per 1 mg neostigmine, max 1 mg)", value: fmt(min(1.0, p.weight * 0.014), decimals: 2), unit: "mg IV", note: "FDA-labeled 0.2:1 ratio; prevents muscarinic bradycardia"),
            CalcResult(label: "── ATROPINE ──────────────────", value: "", unit: "", note: "Anticholinergic; crosses BBB"),
            CalcResult(label: "Bradycardia (fixed 1 mg, max 3 mg)", value: "1", unit: "mg", note: "AHA 2020: fixed dose, repeat q3–5 min to 3 mg total — not weight-based"),
            CalcResult(label: "── AMIODARONE ────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "VF/pulseless VT (5 mg/kg, max 300 mg)", value: fmt(min(300, p.weight * 5), decimals: 0), unit: "mg", note: "150 mg for stable VT", alert: .warning),
            CalcResult(label: "── METHYLENE BLUE (VASOPLEGIC) ─", value: "", unit: "", note: "NO/cGMP pathway inhibitor"),
            CalcResult(label: "Vasoplegic bolus (1–2 mg/kg over 15–20 min)", value: fmtRange(p.weight * 1.0, p.weight * 2.0, decimals: 0), unit: "mg IV", note: "Post-CPB / catecholamine-refractory distributive shock"),
            CalcResult(label: "Continuous infusion (0.25–2 mg/kg/hr)", value: fmtRange(p.weight * 0.25, p.weight * 2.0, decimals: 1), unit: "mg/hr", note: "Titrate to MAP target"),
            CalcResult(label: "Max daily dose (7 mg/kg/day)", value: fmt(p.weight * 7.0, decimals: 0), unit: "mg/day", note: "Higher doses → paradoxical methemoglobinemia", alert: .warning),
            CalcResult(label: "⚠ ABSOLUTE CI: serotonergic drugs", value: "—", unit: "", note: "SSRIs, SNRIs, MAOIs, linezolid — serotonin syndrome risk", alert: .critical),
            CalcResult(label: "⚠ G6PD deficiency — CI for MetHgb use", value: "—", unit: "", note: "Worsens methemoglobinemia; use ascorbic acid 1 g IV", alert: .critical),
        ])
    }

    // ── 10. Local anesthetics ────────────────────────────────────────────────
    func localAnesthetics() -> CalcSection {
        return CalcSection(title: "Local Anesthetics & Regional", icon: "cross.vial.fill", colorKey: "section10", results: [
            CalcResult(label: "Lidocaine plain max (4.5 mg/kg)", value: fmt(p.weight * 4.5, decimals: 0), unit: "mg", note: "Titrate conservatively"),
            CalcResult(label: "Lidocaine with epinephrine max (7 mg/kg)", value: fmt(p.weight * 7, decimals: 0), unit: "mg", note: ""),
            CalcResult(label: "Bupivacaine plain max (2.5 mg/kg)", value: fmt(p.weight * 2.5, decimals: 0), unit: "mg", note: "Cardiotoxic; never IV bolus", alert: .caution),
            CalcResult(label: "Bupivacaine with epi max (3 mg/kg)", value: fmt(p.weight * 3, decimals: 0), unit: "mg", note: ""),
            CalcResult(label: "Ropivacaine max (3 mg/kg)", value: fmt(p.weight * 3, decimals: 0), unit: "mg", note: "Less cardiotoxic than bupivacaine"),
            CalcResult(label: "Mepivacaine plain max (5 mg/kg)", value: fmt(p.weight * 5, decimals: 0), unit: "mg", note: ""),
            CalcResult(label: "Mepivacaine with epi max (7 mg/kg)", value: fmt(p.weight * 7, decimals: 0), unit: "mg", note: ""),
            CalcResult(label: "Intralipid 20% — LAST bolus (1.5 mL/kg)", value: fmt(p.weight * 1.5, decimals: 0), unit: "mL", note: "IV over 1 min; repeat ×3 q3–5 min", alert: .critical),
            CalcResult(label: "Intralipid 20% — LAST infusion (0.25 mL/kg/min)", value: fmt(p.weight * 0.25, decimals: 1), unit: "mL/min", note: "Continue 30–60 min after ROSC", alert: .critical),
            CalcResult(label: "── BUPIVACAINE HYPERBARIC 0.75% ─", value: "", unit: "", note: ""),
            CalcResult(label: "Spinal — C-section standard", value: "1.5", unit: "mL", note: "11.25 mg + fentanyl 15–25 mcg + morphine 100–200 mcg"),
            CalcResult(label: "Spinal — lower extremity surgery", value: "1.2 – 2.0", unit: "mL", note: "9–15 mg; level dependent"),
            CalcResult(label: "Saddle block (perineal procedures)", value: "0.5", unit: "mL", note: "3.75 mg; seated position maintained 5 min"),
            CalcResult(label: "── LIPOSOMAL BUPIVACAINE (EXPAREL®) ─", value: "", unit: "", note: ""),
            CalcResult(label: "Wound infiltration (fixed 266 mg)", value: "266", unit: "mg", note: "20 mL; dilute with up to 280 mL NS; ~72h duration"),
            CalcResult(label: "Interscalene block (133 mg)", value: "133", unit: "mg", note: "10 mL; 24–48h shoulder analgesia"),
            CalcResult(label: "TAP block (266 mg)", value: "266", unit: "mg", note: "20 mL; abdominal surgery opioid-sparing"),
            CalcResult(label: "⚠ NOT for neuraxial (IT/epidural) use", value: "—", unit: "", note: "Not approved; potentially neurotoxic", alert: .critical),
            CalcResult(label: "⚠ Do NOT mix with plain bupivacaine HCl", value: "—", unit: "", note: "Accelerates drug release; reduces duration", alert: .warning),
            CalcResult(label: "── CHLOROPROCAINE 3% ─────────", value: "", unit: "", note: ""),
            CalcResult(label: "Epidural extension for C-section", value: "15 – 20", unit: "mL", note: "Fastest epidural onset 5–10 min; \(fmt(p.weight * 4.5, decimals: 0)) mg max"),
            CalcResult(label: "⚠ Wait ≥30 min before epidural opioid", value: "—", unit: "", note: "Chloroprocaine antagonizes opioid receptors neuraxially", alert: .caution),
            CalcResult(label: "── COCAINE 4–10% (TOPICAL ONLY) ─", value: "", unit: "", note: ""),
            CalcResult(label: "Topical max (3 mg/kg; max 200 mg)", value: fmt(min(200, p.weight * 3.0), decimals: 0), unit: "mg", note: "ENT/nasal procedures — pledgets or spray ONLY"),
            CalcResult(label: "⚠ NOT for injection", value: "—", unit: "", note: "Topical application ONLY; CI: MAOIs; caution CAD/HTN", alert: .critical),
        ])
    }

    // ── 11. PONV ─────────────────────────────────────────────────────────────
    func ponv() -> CalcSection {
        let scopolamine = apfelScore >= 3 ? "Recommended (Apfel ≥3)" : "Not routinely indicated"
        let apfelAlert: AlertLevel = apfelScore >= 3 ? .warning : apfelScore >= 2 ? .caution : .normal
        return CalcSection(title: "PONV — Apfel Score & Prophylaxis", icon: "figure.stand", colorKey: "section11", results: [
            CalcResult(label: "Apfel Score", value: "\(apfelScore) / 4", unit: "", note: "Female + Nonsmoker + PONV Hx + Opioid", alert: apfelAlert),
            CalcResult(label: "PONV Risk", value: apfelRisk, unit: "", note: "", alert: apfelAlert),
            CalcResult(label: "Ondansetron — adult (fixed 4 mg)", value: "4", unit: "mg IV", note: "Give at end of case"),
            CalcResult(label: "Ondansetron — pedi (0.1 mg/kg, max 4)", value: fmt(min(4, p.weight * 0.1), decimals: 1), unit: "mg IV", note: "Weight-based"),
            CalcResult(label: "Dexamethasone PONV (fixed 4–10 mg)", value: "4 – 10", unit: "mg", note: "Fixed dose, not weight-based — SAMBA guidelines favor 4–5 mg; give early in case"),
            CalcResult(label: "Droperidol (0.015 mg/kg, max 1.25 mg)", value: fmt(min(1.25, p.weight * 0.015), decimals: 2), unit: "mg", note: "QTc monitoring required"),
            CalcResult(label: "Scopolamine Patch", value: scopolamine, unit: "", note: "Apply ≥4h pre-op or night before"),
        ])
    }

    // ── 12. Emergency ────────────────────────────────────────────────────────
    func emergency() -> CalcSection {
        let dantVialsInit = ceil(p.weight * 2.5 / 20)
        let dantVialsMax  = ceil(p.weight * 10  / 20)
        return CalcSection(title: "Emergency & Reversal Drugs", icon: "cross.circle.fill", colorKey: "section12", results: [
            CalcResult(label: "── NALOXONE ──────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Partial reversal (1 mcg/kg)", value: fmt(p.weight * 0.001, decimals: 3), unit: "mg IV", note: "Titrate; avoid acute opioid withdrawal"),
            CalcResult(label: "Full reversal (10 mcg/kg)", value: fmt(p.weight * 0.01, decimals: 3), unit: "mg IV", note: "Painful arousal; may need redosing in 20–90 min"),
            CalcResult(label: "Infusion — opioid toxicity (3–5 mcg/kg/hr)", value: fmtRange(p.weight * 0.003 * 1000, p.weight * 0.005 * 1000, decimals: 1), unit: "mcg/hr", note: "Duration > fentanyl/methadone half-life"),
            CalcResult(label: "⚠ Short half-life 30–90 min — re-sedation risk", value: "—", unit: "", note: "Monitor ≥2h after dosing", alert: .caution),
            CalcResult(label: "── FLUMAZENIL ────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Initial dose (0.01 mg/kg, max 0.2 mg)", value: fmt(min(0.2, p.weight * 0.01), decimals: 2), unit: "mg IV", note: "Over 15s; titrate q1 min"),
            CalcResult(label: "Maximum total (0.05 mg/kg, max 1 mg)", value: fmt(min(1.0, p.weight * 0.05), decimals: 2), unit: "mg IV", note: "Stop if no response by 1 mg total"),
            CalcResult(label: "⚠ Seizure risk — avoid in benzo-dependent patients", value: "—", unit: "", note: "Acute withdrawal may precipitate seizures", alert: .warning),
            CalcResult(label: "⚠ Half-life < benzodiazepines — re-sedation likely", value: "—", unit: "", note: "Effect lasts ~30–60 min; monitor ≥2h", alert: .caution),
            CalcResult(label: "── DANTROLENE (MH PROTOCOL) ──", value: "", unit: "", note: ""),
            CalcResult(label: "Initial bolus (2.5 mg/kg IV RAPID)", value: fmt(p.weight * 2.5, decimals: 0), unit: "mg IV", note: "Give IMMEDIATELY on suspicion — do NOT wait", alert: .critical),
            CalcResult(label: "# 20 mg vials for initial dose", value: fmt(dantVialsInit, decimals: 0), unit: "vials", note: "Each needs 60 mL sterile water — assign dedicated team"),
            CalcResult(label: "Repeat q5 min until crisis resolves", value: fmt(p.weight * 2.5, decimals: 0), unit: "mg IV", note: "Same dose each time; max documented ~30 mg/kg"),
            CalcResult(label: "Cumulative max (10 mg/kg)", value: fmt(p.weight * 10, decimals: 0), unit: "mg", note: "# vials total: \(Int(dantVialsMax))", alert: .warning),
            CalcResult(label: "Maintenance (1 mg/kg q6h × 24–48h)", value: fmt(p.weight * 1.0, decimals: 0), unit: "mg q6h", note: "Prevent recurrence; monitor respiratory function"),
            CalcResult(label: "MH Hotline (US 24/7)", value: "1-800-644-9737", unit: "", note: "MHAUS — call immediately on suspicion"),
            CalcResult(label: "Stop ALL volatiles + succinylcholine", value: "Immediate", unit: "", note: "Hyperventilate 100% O₂ at 10 L/min FGF", alert: .critical),
            CalcResult(label: "Active cooling target", value: "<38.5°C", unit: "", note: "Ice packs, cold IV fluid; stop at 38°C"),
            CalcResult(label: "── METHYLENE BLUE — MetHgb ──", value: "", unit: "", note: "REQUIRES NADPH — G6PD screen first"),
            CalcResult(label: "Methemoglobinemia (1–2 mg/kg over 5–15 min)", value: fmtRange(p.weight * 1.0, p.weight * 2.0, decimals: 0), unit: "mg IV", note: "For symptomatic MetHgb >20–30%"),
            CalcResult(label: "⚠ G6PD deficiency — DO NOT USE for MetHgb", value: "—", unit: "", note: "Use ascorbic acid 1 g IV instead", alert: .critical),
            CalcResult(label: "⚠ SpO₂ unreliable after MB dose (reads ~65–85%)", value: "—", unit: "", note: "Absorbs at 668 nm; confirm with co-oximetry ABG", alert: .caution),
            CalcResult(label: "⚠ Absolute CI: serotonergic drugs", value: "—", unit: "", note: "SSRIs/SNRIs/MAOIs/linezolid — fatal serotonin syndrome", alert: .critical),
            CalcResult(label: "── CALCIUM CHLORIDE 10% ──────", value: "", unit: "", note: ""),
            CalcResult(label: "Hyperkalemia / Ca-channel toxicity (10 mg/kg)", value: fmt(p.weight * 10, decimals: 0), unit: "mg IV", note: "100 mg/mL; central line preferred"),
            CalcResult(label: "── SODIUM BICARBONATE ────────", value: "", unit: "", note: ""),
            CalcResult(label: "Standard dose (1 mEq/kg)", value: fmt(p.weight * 1.0, decimals: 0), unit: "mEq IV", note: "Severe acidemia / Na-channel block (TCA / flecainide)"),
            CalcResult(label: "TCA overdose — repeat to Na⁺ 150–155 mEq/L", value: fmt(p.weight * 1.0, decimals: 0), unit: "mEq IV", note: "Sodium loading drives Na-channel competition", alert: .warning),
            CalcResult(label: "── LIDOCAINE VT ──────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Antiarrhythmic bolus (1–3 mg/kg, max 300 mg)", value: fmtRange(p.weight * 1.0, min(300, p.weight * 3.0), decimals: 0), unit: "mg IV", note: "Stable VT; infusion 1–4 mg/min after bolus"),
            CalcResult(label: "── SUGAMMADEX (QUICK REF) ────", value: "", unit: "", note: ""),
            CalcResult(label: "Routine TOF ≥T2 (2 mg/kg)", value: fmt(p.weight * 2.0, decimals: 0), unit: "mg IV", note: "Works at any recovery depth with 2+ twitches"),
            CalcResult(label: "Deep block (4 mg/kg)", value: fmt(p.weight * 4.0, decimals: 0), unit: "mg IV", note: ""),
            CalcResult(label: "Immediate CICO reversal (16 mg/kg)", value: fmt(p.weight * 16.0, decimals: 0), unit: "mg IV", note: "Complete reversal of 1.2 mg/kg roc in <3 min", alert: .caution),
        ])
    }

    // ── 13. Cardiac ──────────────────────────────────────────────────────────
    func cardiac() -> CalcSection {
        let svr  = p.cardiacOutput > 0 ? (p.map - p.cvp) / p.cardiacOutput * 80 : 0
        let pvr  = p.cardiacOutput > 0 ? (p.mpap - p.pcwp) / p.cardiacOutput * 80 : 0
        let o2Content = 1.34 * p.hemoglobin * p.sao2 + 0.0031 * p.pao2
        let do2: Double = p.cardiacOutput > 0 ? p.cardiacOutput * o2Content * 10 : 0
        let avDiff = p.hemoglobin * 1.34 * (p.sao2 - p.svo2)
        let vo2: Double = p.cardiacOutput > 0 ? p.cardiacOutput * avDiff * 10 : 0
        let aaGrad = p.pao2 > 0 ? pao2Alveolar - p.pao2 : 0
        let pf    = p.pao2 > 0 && p.fio2 > 0 ? p.pao2 / p.fio2 : 0

        let qtcVal = qtc
        let qtcInterp: String
        let qtcAlert: AlertLevel
        if qtcVal > 500     { qtcInterp = "PROLONGED — Caution"; qtcAlert = .critical }
        else if qtcVal > 450 { qtcInterp = "Borderline"; qtcAlert = .caution }
        else                 { qtcInterp = "Normal"; qtcAlert = .normal }

        let do2Alert: AlertLevel = do2 > 0 && do2 < 400 ? .critical : do2 < 600 ? .warning : .normal
        let pfAlert: AlertLevel  = pf > 0 && pf < 200 ? .critical : pf < 300 ? .warning : .normal

        // Fick CO: VO₂ (assumed 3.5 mL/kg/min) / (1.34 × Hgb × (SaO₂ − SvO₂) × 10)
        let avDiffFick = 1.34 * p.hemoglobin * (p.sao2 - p.svo2)
        let fickCO: Double = (p.sao2 > p.svo2 && p.hemoglobin > 0)
            ? (3.5 * p.weight) / (avDiffFick * 10) : 0
        let fickAlert: AlertLevel = fickCO > 0 && fickCO < 4 ? .warning : .normal

        return CalcSection(title: "Cardiac, Pulmonary & Oxygenation", icon: "heart.text.square.fill", colorKey: "section13", results: [
            CalcResult(label: "SVR [(MAP−CVP)/CO × 80]", value: p.cardiacOutput > 0 ? fmt(svr, decimals: 0) : "Enter CO", unit: "dyn·s/cm⁵", note: "Normal 900–1400"),
            CalcResult(label: "PVR [(MPAP−PCWP)/CO × 80]", value: p.cardiacOutput > 0 ? fmt(pvr, decimals: 0) : "Enter CO", unit: "dyn·s/cm⁵", note: "Normal <250"),
            CalcResult(label: "DO₂ — Oxygen Delivery", value: p.cardiacOutput > 0 ? fmt(do2, decimals: 0) : "Enter CO", unit: "mL/min", note: "Normal ~1000; critical <400", alert: do2Alert),
            CalcResult(label: "VO₂ — Oxygen Consumption", value: p.cardiacOutput > 0 ? fmt(vo2, decimals: 0) : "Enter CO", unit: "mL/min", note: "Normal ~250"),
            CalcResult(label: "Alveolar PAO₂ (altitude-corrected)", value: fmt(pao2Alveolar, decimals: 1), unit: "mmHg", note: "FiO₂×(PB−47)−PaCO₂/0.8"),
            CalcResult(label: "A-a Gradient", value: p.pao2 > 0 ? fmt(aaGrad, decimals: 1) : "Enter PaO₂", unit: "mmHg", note: "Normal <10 on RA; <50 on 100% O₂"),
            CalcResult(label: "P/F Ratio", value: pf > 0 ? fmt(pf, decimals: 0) : "Enter ABG", unit: "", note: "ALI <300; ARDS <200", alert: pfAlert),
            CalcResult(label: "QTc (Bazett)", value: p.heartRate > 0 ? fmt(qtcVal, decimals: 0) : "Enter HR", unit: "ms", note: qtcInterp, alert: qtcAlert),
            CalcResult(label: "Fick CO (assumed VO₂ 3.5 mL/kg/min)", value: (p.sao2 > p.svo2 && p.hemoglobin > 0) ? fmt(fickCO, decimals: 1) : "Enter Hgb, SaO₂, SvO₂", unit: "L/min", note: "VO₂ / (1.34×Hgb×(SaO₂−SvO₂)×10); normal 4–8", alert: fickAlert),
        ])
    }

    // ── 14. Pediatric ────────────────────────────────────────────────────────
    func pediatric() -> CalcSection {
        let broselow = p.age < 1
            ? (p.age * 12 + 9) / 2
            : 2 * p.age + 10
        let pediEBV: Double
        if p.age < 0.083     { pediEBV = p.weight * 90 }
        else if p.age < 1    { pediEBV = p.weight * 80 }
        else                 { pediEBV = p.weight * 75 }
        let pediMABL = pediEBV * (p.hemoglobin - p.minTargetHgb) / p.hemoglobin

        return CalcSection(title: "Pediatric Quick Reference", icon: "figure.child", colorKey: "section14", results: [
            CalcResult(label: "Age-Based Weight Estimate (Broselow)", value: fmt(broselow, decimals: 1), unit: "kg", note: "Always confirm actual weight"),
            CalcResult(label: "Pedi EBV", value: fmt(pediEBV, decimals: 0), unit: "mL", note: "Neonate:90 Infant:80 Child:75 mL/kg"),
            CalcResult(label: "Pedi MABL", value: fmt(max(0, pediMABL), decimals: 0), unit: "mL", note: ""),
            CalcResult(label: "Atropine pedi (0.02 mg/kg; min 0.1, max 0.5)", value: fmt(min(0.5, max(0.1, p.weight * 0.02)), decimals: 2), unit: "mg", note: "Min 0.1 mg — avoid paradox bradycardia"),
            CalcResult(label: "Glycopyrrolate pedi (0.005 mg/kg, max 0.2)", value: fmt(min(0.2, p.weight * 0.005), decimals: 3), unit: "mg", note: "Pre-induction antisialagogue"),
            CalcResult(label: "Succinylcholine pedi (2 mg/kg)", value: fmt(p.weight * 2, decimals: 0), unit: "mg", note: "Higher dose than adults"),
            CalcResult(label: "Pedi Maintenance Fluid (4-2-1)", value: fmt(maintenanceRate, decimals: 1), unit: "mL/hr", note: ""),
        ])
    }

    // ── 15. TIVA ─────────────────────────────────────────────────────────────
    func tiva() -> CalcSection {
        let ageFactor: Double  = p.age > 55 ? max(0.5, 1.0 - 0.01 * (p.age - 55)) : 1.0
        let premFactor: Double = p.tivaPremedicated ? 0.8 : 1.0
        let asaFactor: Double  = p.tivaASAClass >= 3 ? 0.75 : 1.0

        let targetCe: Double
        let targetCeNote: String
        switch p.tivaTarget {
        case .generalAnesthesia:
            targetCe = 3.5; targetCeNote = "Ce 3–5 mcg/mL (stimulus dependent)"
        case .sedationMild:
            targetCe = 1.0; targetCeNote = "Ce 1–2 mcg/mL (conscious sedation)"
        case .sedationModerate:
            targetCe = 2.0; targetCeNote = "Ce 2–3 mcg/mL (moderate, ± airway support)"
        case .ICUSedation:
            targetCe = 1.5; targetCeNote = "Ce 1–2 mcg/mL (RASS -2 to -3)"
        }

        let propMainLo: Double
        let propMainHi: Double
        switch p.tivaTarget {
        case .generalAnesthesia:
            propMainLo = 6.0 * ageFactor * asaFactor
            propMainHi = 12.0 * ageFactor * asaFactor
        case .sedationMild:
            propMainLo = 1.0
            propMainHi = 3.0
        case .sedationModerate:
            propMainLo = 2.0
            propMainHi = 5.0
        case .ICUSedation:
            propMainLo = 0.5
            propMainHi = 4.0
        }

        let propIndBolus = p.weight * 1.5 * ageFactor * premFactor * asaFactor
        _ = p.weight * propMainHi
        let propMainLoKg = propMainLo
        let propMainHiKg = propMainHi
        let propMainMgHrLo = p.weight * propMainLoKg
        let propMainMgHrHi = p.weight * propMainHiKg
        let propMainMgMinLo = propMainMgHrLo / 60
        let propMainMgMinHi = propMainMgHrHi / 60
        let propMlHrLo = propMainMgHrLo / 10
        let propMlHrHi = propMainMgHrHi / 10

        let csht: Double
        if p.tivaInfusionDuration < 60       { csht = 10 }
        else if p.tivaInfusionDuration < 120  { csht = 20 }
        else if p.tivaInfusionDuration < 240  { csht = 30 }
        else                                  { csht = 40 }

        let lbwDose = lbw
        let remiLo: Double
        let remiHi: Double
        switch p.tivaTarget {
        case .generalAnesthesia:
            remiLo = 0.1; remiHi = 0.3
        case .sedationMild, .sedationModerate:
            remiLo = 0.02; remiHi = 0.1
        case .ICUSedation:
            remiLo = 0.05; remiHi = 0.2
        }

        let fentLoMcgHr = lbwDose * 1.0
        let fentHiMcgHr = lbwDose * 3.0
        let ketInfusion = p.weight * 0.15
        let dexLo = p.weight * 0.2
        let dexHi = p.weight * 0.7
        let lidoInfLo = p.weight * 1.0
        let lidoInfHi = p.weight * 2.0
        let estTotalProp = propMainMgHrLo * (p.tivaInfusionDuration / 60)

        let bisTarget: String
        switch p.tivaTarget {
        case .generalAnesthesia: bisTarget = "40–60 (GA)"
        case .sedationMild:      bisTarget = "70–80 (minimal)"
        case .sedationModerate:  bisTarget = "60–75 (moderate)"
        case .ICUSedation:       bisTarget = "40–60 (ICU)"
        }

        return CalcSection(title: "TIVA — Total IV Anesthesia", icon: "iv.bag.fill", colorKey: "sectionTIVA", results: [
            CalcResult(label: "Target: \(p.tivaTarget.rawValue)", value: "\(fmt(targetCe, decimals: 1))", unit: "mcg/mL Ce", note: targetCeNote),
            CalcResult(label: "BIS Target", value: bisTarget, unit: "", note: "Adjust per clinical context"),
            CalcResult(label: "── PROPOFOL ──────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Induction bolus (1.5 mg/kg, age/ASA-corrected)", value: fmt(propIndBolus, decimals: 0), unit: "mg", note: "Titrate slowly; adjust for age & stability"),
            CalcResult(label: "Maintenance rate LOW (mg/kg/hr)", value: fmt(propMainLoKg, decimals: 1), unit: "mg/kg/hr", note: fmtRange(propMainMgHrLo, propMainMgHrHi, decimals: 0) + " mg/hr total"),
            CalcResult(label: "Maintenance rate HIGH (mg/kg/hr)", value: fmt(propMainHiKg, decimals: 1), unit: "mg/kg/hr", note: "Increase for stimulating phases"),
            CalcResult(label: "Pump rate range (10 mg/mL vial)", value: fmtRange(propMlHrLo, propMlHrHi, decimals: 1), unit: "mL/hr", note: "Standard 1% propofol (10 mg/mL)"),
            CalcResult(label: "Maintenance mcg/kg/min", value: fmtRange(propMainMgMinLo / p.weight * 1000, propMainMgMinHi / p.weight * 1000, decimals: 0), unit: "mcg/kg/min", note: "Equivalent in mcg/kg/min"),
            CalcResult(label: "Context-sensitive half-time (~\(Int(p.tivaInfusionDuration)) min infusion)", value: "~\(Int(csht))", unit: "min", note: "Estimated emergence delay; increases with duration"),
            CalcResult(label: "Est. total propofol (\(Int(p.tivaInfusionDuration)) min at low rate)", value: fmt(estTotalProp, decimals: 0), unit: "mg", note: "\(fmt(estTotalProp / 10, decimals: 0)) mL of 10 mg/mL"),
            CalcResult(label: "── REMIFENTANIL ──────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Remifentanil infusion (LBW-based)", value: fmtRange(remiLo, remiHi, decimals: 3), unit: "mcg/kg/min", note: "LBW \(fmt(lbwDose, decimals: 0)) kg — context-insensitive"),
            CalcResult(label: "Remifentanil absolute rate LOW", value: fmt(lbwDose * remiLo, decimals: 2), unit: "mcg/min", note: "= \(fmt(lbwDose * remiLo * 60, decimals: 0)) mcg/hr"),
            CalcResult(label: "Remifentanil absolute rate HIGH", value: fmt(lbwDose * remiHi, decimals: 2), unit: "mcg/min", note: "= \(fmt(lbwDose * remiHi * 60, decimals: 0)) mcg/hr"),
            CalcResult(label: "⚠ Transition analgesia BEFORE stopping", value: "Plan ahead", unit: "", note: "No residual analgesia — bridge to LA/opioid/NSAID", alert: .caution),
            CalcResult(label: "── FENTANYL (alternative) ────", value: "", unit: "", note: ""),
            CalcResult(label: "Fentanyl infusion range (LBW-based)", value: fmtRange(fentLoMcgHr, fentHiMcgHr, decimals: 0), unit: "mcg/hr", note: "Context-sensitive half-life ↑ with duration"),
            CalcResult(label: "── ADJUNCTS ──────────────────", value: "", unit: "", note: ""),
            CalcResult(label: "Ketamine sub-dissociative infusion (0.15 mg/kg/hr)", value: fmt(ketInfusion, decimals: 1), unit: "mg/hr", note: "Opioid-sparing; reduces propofol requirements"),
            CalcResult(label: "Dexmedetomidine infusion (0.2–0.7 mcg/kg/hr)", value: fmtRange(dexLo, dexHi, decimals: 1), unit: "mcg/hr", note: "Reduces propofol ~30%; no resp depression"),
            CalcResult(label: "Lidocaine infusion (1–2 mg/kg/hr)", value: fmtRange(lidoInfLo, lidoInfHi, decimals: 0), unit: "mg/hr", note: "Stop at skin closure; systemic LA adjunct"),
        ])
    }

    // ── 16. Labor Epidural / OB ───────────────────────────────────────────────
    func laborEpidural() -> CalcSection {
        let wt  = p.maternalWeightKg
        let ht  = p.maternalHeightCm
        let bmiMat = wt / pow(ht / 100, 2)

        let epidLoadVol: Double = bmiMat > 35 ? 10.0 : 15.0
        let epidLoadBupi = epidLoadVol * 1.0
        let epidLoadFent = epidLoadVol * 2.0
        let pceaBolusMl: Double = 8.0
        let pceaLockout: Int   = 20
        let pceaBaseMlHr: Double = bmiMat > 35 ? 6.0 : 8.0
        let pceaMaxHr: Double   = 20.0
        let testDoseLido: Double = 45.0
        let testDoseEpi: Double  = 15.0
        let topUpVol: Double = 8.0
        let topUpBupi = topUpVol * 2.5
        let csEpiVolLido: Double   = 18.0
        let csEpiLidoMg   = csEpiVolLido * 20.0
        let csEpiEpiMcg   = csEpiVolLido * 5.0
        let csEpiBicarbMl: Double  = 2.0
        let csEpiBupiVol: Double   = 17.0
        let csEpiBupiMg   = csEpiBupiVol * 5.0
        let csEpiFentMcg: Double   = 100.0
        let spinalBupiHeavy: Double = 1.5
        let spinalBupiMl = spinalBupiHeavy
        let spinalBupiMg    = spinalBupiHeavy * 7.5
        let spinalFent: Double      = 15.0
        let spinalMorphine: Double  = 150.0
        let spinalEpi: Double       = 200.0
        let cseBupiMl: Double  = 1.2
        let cseBupiMg   = cseBupiMl * 7.5
        let cseFent: Double    = 15.0
        let thoracLoadVol: Double  = 6.0
        let thoracLoadRopi = thoracLoadVol * 2.0
        let thoracInfLoMlHr: Double = 5.0
        let thoracInfHiMlHr: Double = 10.0
        let thoracInfLoMg   = thoracInfLoMlHr * 2.0
        let thoracInfHiMg   = thoracInfHiMlHr * 2.0
        let lastBupiMax = wt * 2.5
        let lastRopiMax = wt * 3.0
        let lastLidoMax = wt * 4.5
        let intralipidBolus = wt * 1.5
        let intralipidInf   = wt * 0.25
        let phenylInfLo = wt * 0.5
        let phenylInfHi = wt * 1.5
        let phenylBolus = wt * 1.0
        let ephedrineBolus = min(30.0, wt * 0.1)
        let oxytocinBolus: Double = 3.0
        let oxytocinInfMlHr: Double = 125.0
        let txaMg: Double = 1000.0
        let carboprost: Double = 250.0
        let miso: Double = 800.0
        let metherg: Double = 0.2

        // suppress unused warnings
        _ = testDoseLido; _ = testDoseEpi; _ = cseBupiMl
        _ = cseBupiMg; _ = cseFent

        let results: [CalcResult]
        switch p.epiduralIndication {

        case .laborAnalgesia:
            results = [
                CalcResult(label: "── EPIDURAL INITIATION ───────", value: "", unit: "", note: ""),
                CalcResult(label: "Loading dose volume", value: fmt(epidLoadVol, decimals: 0), unit: "mL", note: bmiMat > 35 ? "Reduced: BMI > 35" : "0.1% bupivacaine + fentanyl 2 mcg/mL"),
                CalcResult(label: "Bupivacaine in loading dose", value: fmt(epidLoadBupi, decimals: 0), unit: "mg", note: "0.1% = 1 mg/mL"),
                CalcResult(label: "Fentanyl in loading dose", value: fmt(epidLoadFent, decimals: 0), unit: "mcg", note: "2 mcg/mL"),
                CalcResult(label: "Test dose: Lidocaine 1.5% + Epi 1:200k", value: "3", unit: "mL", note: "45 mg lido + 15 mcg epi — IV injection marker", alert: .caution),
                CalcResult(label: "── PCEA MAINTENANCE ──────────", value: "", unit: "", note: ""),
                CalcResult(label: "PCEA basal rate", value: fmt(pceaBaseMlHr, decimals: 0), unit: "mL/hr", note: "0.0625–0.1% bupi + fentanyl 2 mcg/mL"),
                CalcResult(label: "PCEA demand bolus", value: fmt(pceaBolusMl, decimals: 0), unit: "mL", note: "Patient-controlled bolus"),
                CalcResult(label: "PCEA lockout interval", value: "\(pceaLockout)", unit: "min", note: ""),
                CalcResult(label: "PCEA max hourly dose", value: fmt(pceaMaxHr, decimals: 0), unit: "mL/hr", note: "Basal + demand combined"),
                CalcResult(label: "── BREAKTHROUGH PAIN TOP-UP ──", value: "", unit: "", note: ""),
                CalcResult(label: "Top-up volume (0.25% bupivacaine)", value: fmt(topUpVol, decimals: 0), unit: "mL", note: "\(fmt(topUpBupi, decimals: 0)) mg bupivacaine"),
                CalcResult(label: "Alternative: 0.5% ropivacaine", value: "5–8", unit: "mL", note: "10–16 mg ropivacaine"),
                CalcResult(label: "Fentanyl epidural bolus (for analgesia)", value: "50–100", unit: "mcg", note: "Adjunct to LA for rapid onset"),
                CalcResult(label: "── SPINAL HYPOTENSION MGMT ───", value: "", unit: "", note: ""),
                CalcResult(label: "Phenylephrine infusion (0.5–1.5 mcg/kg/min)", value: fmtRange(phenylInfLo, phenylInfHi, decimals: 0), unit: "mcg/min", note: "Preferred in OB — preserves uteroplacental flow"),
                CalcResult(label: "Phenylephrine bolus (1 mcg/kg)", value: fmt(phenylBolus, decimals: 0), unit: "mcg", note: "For acute hypotension"),
                CalcResult(label: "Ephedrine bolus (max 30 mg in OB)", value: fmt(ephedrineBolus, decimals: 0), unit: "mg", note: "If bradycardia with hypotension"),
                CalcResult(label: "── LAST MAX DOSES ────────────", value: "", unit: "", note: ""),
                CalcResult(label: "Max bupivacaine (2.5 mg/kg)", value: fmt(lastBupiMax, decimals: 0), unit: "mg", note: "⚠ Cardiotoxic", alert: .warning),
                CalcResult(label: "Max ropivacaine (3 mg/kg)", value: fmt(lastRopiMax, decimals: 0), unit: "mg", note: ""),
                CalcResult(label: "Intralipid 20% — LAST bolus (1.5 mL/kg)", value: fmt(intralipidBolus, decimals: 0), unit: "mL", note: "IV bolus; repeat ×3 q3–5 min", alert: .critical),
                CalcResult(label: "Intralipid 20% — LAST infusion (0.25 mL/kg/min)", value: fmt(intralipidInf, decimals: 1), unit: "mL/min", note: "Continue 30–60 min after ROSC", alert: .critical),
            ]

        case .csectionSpinal:
            results = [
                CalcResult(label: "── SPINAL (SAB) FOR C-SECTION ─", value: "", unit: "", note: ""),
                CalcResult(label: "Bupivacaine 0.75% hyperbaric", value: fmt(spinalBupiMl, decimals: 1), unit: "mL", note: "\(fmt(spinalBupiMg, decimals: 1)) mg — standard bilateral T4 block"),
                CalcResult(label: "Intrathecal fentanyl", value: fmt(spinalFent, decimals: 0), unit: "mcg", note: "Rapid onset analgesic adjunct"),
                CalcResult(label: "Intrathecal morphine", value: fmt(spinalMorphine, decimals: 0), unit: "mcg", note: "Postoperative analgesia 12–24h; monitor respiratory status", alert: .caution),
                CalcResult(label: "Intrathecal epinephrine (optional)", value: fmt(spinalEpi, decimals: 0), unit: "mcg", note: "Prolongs block; 100–200 mcg"),
                CalcResult(label: "Needle recommendation", value: p.spinalNeedle.rawValue, unit: "", note: "Pencil-point preferred (↓ PDPH risk)"),
                CalcResult(label: "Target dermatome level", value: "T4", unit: "", note: "Bilateral — confirm before incision"),
                CalcResult(label: "── HYPOTENSION PROPHYLAXIS ───", value: "", unit: "", note: ""),
                CalcResult(label: "Crystalloid co-load", value: "500–1000", unit: "mL", note: "LR or NS rapidly at time of spinal"),
                CalcResult(label: "Phenylephrine infusion prophylaxis", value: fmtRange(phenylInfLo, phenylInfHi, decimals: 0), unit: "mcg/min", note: "Start with spinal; titrate to MAP ≥80% baseline"),
                CalcResult(label: "Phenylephrine bolus (rescue)", value: fmt(phenylBolus, decimals: 0), unit: "mcg", note: "For acute drop"),
                CalcResult(label: "Ephedrine (if bradycardic + hypotensive)", value: fmt(ephedrineBolus, decimals: 0), unit: "mg", note: "Max 30 mg in OB; mixed β/α"),
                CalcResult(label: "── PPH UTEROTONIC DRUGS ──────", value: "", unit: "", note: ""),
                CalcResult(label: "Oxytocin IV bolus (slow, diluted)", value: fmt(oxytocinBolus, decimals: 0), unit: "IU", note: "⚠ Give slowly — causes hypotension if rapid", alert: .caution),
                CalcResult(label: "Oxytocin infusion (30 IU / 500 mL)", value: fmt(oxytocinInfMlHr, decimals: 0), unit: "mL/hr", note: "= ~7.5 IU/hr maintenance"),
                CalcResult(label: "Tranexamic acid (if hemorrhage)", value: fmt(txaMg, decimals: 0), unit: "mg IV", note: "1 g over 10 min; repeat at 30 min if needed"),
                CalcResult(label: "Carboprost (Hemabate) IM", value: fmt(carboprost, decimals: 0), unit: "mcg", note: "Q15–90 min; avoid in asthma", alert: .caution),
                CalcResult(label: "Misoprostol (rectal/sublingual)", value: fmt(miso, decimals: 0), unit: "mcg", note: "600–1000 mcg PR/SL"),
                CalcResult(label: "Methylergonovine IM (avoid if HTN)", value: fmt(metherg, decimals: 1), unit: "mg", note: "CI: hypertension, preeclampsia", alert: .caution),
            ]

        case .csectionEpidural:
            results = [
                CalcResult(label: "── EPIDURAL EXTENSION FOR C/S ─", value: "", unit: "", note: ""),
                CalcResult(label: "Lidocaine 2% + epi 1:200k volume", value: fmt(csEpiVolLido, decimals: 0), unit: "mL", note: "First-line for urgent extension"),
                CalcResult(label: "Lidocaine 2% total dose", value: fmt(csEpiLidoMg, decimals: 0), unit: "mg", note: "2% = 20 mg/mL"),
                CalcResult(label: "Epinephrine in solution", value: fmt(csEpiEpiMcg, decimals: 0), unit: "mcg", note: "1:200,000 = 5 mcg/mL"),
                CalcResult(label: "Sodium bicarbonate 8.4% (alkalinize)", value: fmt(csEpiBicarbMl, decimals: 0), unit: "mL", note: "Add to lido/epi; speeds onset by 2–3 min"),
                CalcResult(label: "Fentanyl epidural adjunct", value: fmt(csEpiFentMcg, decimals: 0), unit: "mcg", note: "100 mcg improves quality of block"),
                CalcResult(label: "── BUPIVACAINE 0.5% ALTERNATIVE ─", value: "", unit: "", note: ""),
                CalcResult(label: "Bupivacaine 0.5% volume", value: fmt(csEpiBupiVol, decimals: 0), unit: "mL", note: "Slower onset; use if time allows"),
                CalcResult(label: "Bupivacaine 0.5% total dose", value: fmt(csEpiBupiMg, decimals: 0), unit: "mg", note: "0.5% = 5 mg/mL"),
                CalcResult(label: "Target level", value: "T4 bilateral", unit: "", note: "Assess cold/light touch before incision"),
                CalcResult(label: "── PPH & HYPOTENSION ────────────", value: "", unit: "", note: ""),
                CalcResult(label: "Phenylephrine infusion", value: fmtRange(phenylInfLo, phenylInfHi, decimals: 0), unit: "mcg/min", note: "Titrate to MAP ≥80% baseline"),
                CalcResult(label: "Oxytocin bolus (slow/diluted)", value: fmt(oxytocinBolus, decimals: 0), unit: "IU", note: "Dilute; give slowly", alert: .caution),
                CalcResult(label: "Tranexamic acid", value: fmt(txaMg, decimals: 0), unit: "mg IV", note: "1 g over 10 min for PPH"),
                CalcResult(label: "Max bupivacaine (2.5 mg/kg mat. wt)", value: fmt(lastBupiMax, decimals: 0), unit: "mg", note: "LAST risk — know location of intralipid", alert: .warning),
                CalcResult(label: "Intralipid 20% — LAST bolus", value: fmt(intralipidBolus, decimals: 0), unit: "mL", note: "1.5 mL/kg IV — have immediately available", alert: .critical),
            ]

        case .thoracicEpidural:
            results = [
                CalcResult(label: "── THORACIC EPIDURAL ────────", value: "", unit: "", note: ""),
                CalcResult(label: "Typical level", value: "T4–T8", unit: "", note: "Match to surgical dermatome"),
                CalcResult(label: "Loading dose volume (0.2% ropivacaine)", value: fmt(thoracLoadVol, decimals: 0), unit: "mL", note: "\(fmt(thoracLoadRopi, decimals: 0)) mg ropivacaine"),
                CalcResult(label: "Infusion rate (0.2% ropivacaine)", value: fmtRange(thoracInfLoMlHr, thoracInfHiMlHr, decimals: 0), unit: "mL/hr", note: "\(fmt(thoracInfLoMg, decimals: 0))–\(fmt(thoracInfHiMg, decimals: 0)) mg/hr"),
                CalcResult(label: "Fentanyl in infusion (optional)", value: "2–4", unit: "mcg/mL", note: "Synergistic with LA; reduces concentration needed"),
                CalcResult(label: "Alternative: 0.1% bupivacaine", value: fmtRange(thoracInfLoMlHr, thoracInfHiMlHr, decimals: 0), unit: "mL/hr", note: "1–2 mg/hr bupivacaine"),
                CalcResult(label: "Needle: Tuohy at level", value: p.epiduralNeedle.rawValue, unit: "", note: "Midline or paramedian approach"),
                CalcResult(label: "Depth to epidural space (estimate)", value: "4–6", unit: "cm", note: "Variable; loss of resistance to saline preferred"),
                CalcResult(label: "── BREAKTHROUGH / BOLUS ─────", value: "", unit: "", note: ""),
                CalcResult(label: "PRN bolus (0.2% ropivacaine)", value: "3–5", unit: "mL", note: "Test dose first; assess for intrathecal"),
                CalcResult(label: "── HYPOTENSION MGMT ─────────", value: "", unit: "", note: ""),
                CalcResult(label: "Phenylephrine infusion", value: fmtRange(phenylInfLo, phenylInfHi, decimals: 0), unit: "mcg/min", note: "Sympathetic blockade → systemic vasodilation"),
                CalcResult(label: "Norepinephrine infusion (alternative)", value: fmt(p.maternalWeightKg * 0.05, decimals: 2), unit: "mcg/min", note: "Start low; titrate to MAP target"),
                CalcResult(label: "Max ropivacaine (3 mg/kg)", value: fmt(lastRopiMax, decimals: 0), unit: "mg", note: "LAST surveillance throughout"),
                CalcResult(label: "Intralipid 20% — LAST bolus", value: fmt(intralipidBolus, decimals: 0), unit: "mL", note: "1.5 mL/kg; have immediately available", alert: .critical),
            ]

        case .lumbarEpidural:
            results = [
                CalcResult(label: "── LUMBAR SURGICAL EPIDURAL ─", value: "", unit: "", note: ""),
                CalcResult(label: "Loading: 2% lidocaine + epi 1:200k", value: "15–20", unit: "mL", note: "After negative test dose; inject in 5 mL aliquots"),
                CalcResult(label: "Lidocaine 2% total dose", value: fmt(min(lastLidoMax, 20 * 20), decimals: 0), unit: "mg", note: "20 mg/mL"),
                CalcResult(label: "Loading: 0.5% bupivacaine (alt)", value: "15–20", unit: "mL", note: "Slower onset ~20 min; longer duration"),
                CalcResult(label: "Loading: 0.75% ropivacaine (alt)", value: "15–18", unit: "mL", note: "Dense motor + sensory; ~20 min onset"),
                CalcResult(label: "Epidural fentanyl adjunct", value: "50–100", unit: "mcg", note: "Improves block quality; reduces LA dose"),
                CalcResult(label: "Epidural morphine (postop)", value: "2–4", unit: "mg", note: "24h analgesia; monitor for delayed resp depression", alert: .caution),
                CalcResult(label: "── MAINTENANCE INFUSION ─────", value: "", unit: "", note: ""),
                CalcResult(label: "Infusion: 0.1% bupivacaine + fentanyl 2 mcg/mL", value: "8–12", unit: "mL/hr", note: "Titrate to sensory level and pain score"),
                CalcResult(label: "── HYPOTENSION ──────────────", value: "", unit: "", note: ""),
                CalcResult(label: "Phenylephrine bolus (1 mcg/kg)", value: fmt(wt * 1.0, decimals: 0), unit: "mcg", note: "Lumbar sympathectomy → hypotension"),
                CalcResult(label: "Ephedrine bolus (0.1 mg/kg)", value: fmt(min(50, wt * 0.1), decimals: 0), unit: "mg", note: "If bradycardia accompanies hypotension"),
                CalcResult(label: "── LAST DOSES ───────────────", value: "", unit: "", note: ""),
                CalcResult(label: "Max lidocaine + epi (7 mg/kg)", value: fmt(wt * 7, decimals: 0), unit: "mg", note: ""),
                CalcResult(label: "Max bupivacaine (2.5 mg/kg)", value: fmt(lastBupiMax, decimals: 0), unit: "mg", note: "⚠ Cardiotoxic", alert: .warning),
                CalcResult(label: "Intralipid 20% — LAST bolus", value: fmt(intralipidBolus, decimals: 0), unit: "mL", note: "1.5 mL/kg IV", alert: .critical),
            ]
        }

        let indTitle: String
        switch p.epiduralIndication {
        case .laborAnalgesia:   indTitle = "Labor Analgesia"
        case .csectionSpinal:   indTitle = "C-Section — Spinal"
        case .csectionEpidural: indTitle = "C-Section — Epidural Ext."
        case .thoracicEpidural: indTitle = "Thoracic Epidural"
        case .lumbarEpidural:   indTitle = "Lumbar Surgical Epidural"
        }

        return CalcSection(
            title: "Labor & Regional OB — \(indTitle)",
            icon: "staroflife.fill",
            colorKey: "sectionOB",
            results: results
        )
    }

}

// MARK: - Section Sources

// Primary reference(s) behind each calculator section, keyed by CalcSection.colorKey.
enum CalcSources {
    static let bySection: [String: String] = [
        "section1": "Pai MP & Paloucek FP, Ann Pharmacother 2000 (PMID 10981254); Traynor AM et al, Antimicrob Agents Chemother 1995 (PMID 7726530); Janmahasatian S et al, Clin Pharmacokinet 2005 (PMID 16176118); Mosteller RD, N Engl J Med 1987 (PMID 3657876); WHO Technical Report Series 894 (BMI classes)",   // Anthropometrics
        "section2": "Khine HH et al, Anesthesiology 1997 (PMID 9066329); Weiss M et al, Br J Anaesth 2009 (PMID 19887533); Topjian AA et al, Pediatrics 2020, AHA PALS (PMID 33087552); Miller's Anesthesia, 9th ed.",   // Airway Management
        "section3": "Mapleson WW, Br J Anaesth 1996 (PMID 8777094); Nickalls RWD & Mapleson WW, Br J Anaesth 2003 (PMID 12878613); Eger EI, Anesth Analg 2001 (PMID 11574362); Roizen MF et al, Anesthesiology 1981, MAC-BAR (PMID 7224208)",   // MAC — Volatile Anesthetics
        "section4": "Miller's Anesthesia, 9th ed.; Schnider TW et al, Anesthesiology 1998 (PMID 9605675); Green SM et al, Ann Emerg Med 2011 (PMID 21256625); Motov S et al, Ann Emerg Med 2015 (PMID 25817884); Forman SA, Anesthesiology 2011 (PMID 21263301); Riker RR et al, JAMA 2009, SEDCOM (PMID 19188334)",   // Induction Agents
        "sectionTIVA": "Schnider TW et al, Anesthesiology 1998 (PMID 9605675); Minto CF et al, Anesthesiology 1997, I (PMID 9009935); Hughes MA et al, Anesthesiology 1992 (PMID 1539843); Jouguelet-Lacoste J et al, Pain Med 2015 (PMID 25530168); Weibel S et al, Cochrane 2018 (PMID 29864216)",   // TIVA — Total IV Anesthesia
        "section5": "Thilen SR et al, Anesthesiology 2023, ASA NMB guideline (PMID 36520073); Sørensen MK et al, Br J Anaesth 2012 (PMID 22315329); Papazian L et al, N Engl J Med 2010, ACURASYS (PMID 20843245); Miller's Anesthesia, 9th ed.",   // Neuromuscular Blockade & Reversal
        "section6": "Holliday MA & Segar WE, Pediatrics 1957 (PMID 13431307); Gross JB, Anesthesiology 1983 (PMID 6829965); labtestsguide.com EBV calculator",   // Fluid Management & Blood Loss
        "section7": "ARDS Network, N Engl J Med 2000 (PMID 10793162); Amato MB et al, N Engl J Med 2015 (PMID 25693014); Self M et al, J Emerg Med 2023 (PMID 37355422)",   // Ventilator Settings
        "section8": "Miller's Anesthesia, 9th ed.; Minto CF et al, Anesthesiology 1997, I (PMID 9009935); Borland M et al, Ann Emerg Med 2007 (PMID 17067720); Motov S et al, Ann Emerg Med 2015 (PMID 25817884); Weibel S et al, Cochrane 2018 (PMID 29864216); Gan TJ et al, Anesth Analg 2020, 4th PONV consensus (PMID 32467512)",   // Opioids & Analgesics
        "section9": "Evans L et al, Crit Care Med 2021, Surviving Sepsis (PMID 34605781); De Backer D et al, N Engl J Med 2010 (PMID 20200382); Russell JA et al, N Engl J Med 2008, VASST (PMID 18305265); Panchal AR et al, Circulation 2020, AHA ACLS (PMID 33081529); Kinsella SM et al, Anaesthesia 2018, vasopressor consensus (PMID 29090733); Mehaffey JH et al, Ann Thorac Surg 2017 (PMID 28551045)",   // Vasopressors & Inotropes
        "section10": "Neal JM et al, Reg Anesth Pain Med 2010, ASRA LAST advisory (PMID 20216033); Neal JM et al, Reg Anesth Pain Med 2021, ASRA LAST checklist 2020 (PMID 33148630); Manufacturer PI (Exparel)",   // Local Anesthetics & Regional
        "sectionOB": "Kinsella SM et al, Anaesthesia 2018, vasopressor consensus (PMID 29090733); ACOG Practice Bulletin No. 183, Obstet Gynecol 2017 (PMID 28937571); Heesen M et al, Anaesthesia 2019, uterotonic consensus (PMID 31347151); WOMAN Trial Collaborators, Lancet 2017 (PMID 28456509); Palmer CM et al, Anesthesiology 1999 (PMID 9952150); Dahl JB et al, Anesthesiology 1999 (PMID 10598635); COMET Study Group UK, Lancet 2001 (PMID 11454372); Neal JM et al, Reg Anesth Pain Med 2021, ASRA LAST checklist 2020 (PMID 33148630); Chestnut's Obstetric Anesthesia, 6th ed.",   // Labor & Regional OB
        "section11": "Apfel CC et al, Anesthesiology 1999 (PMID 10485781); Gan TJ et al, Anesth Analg 2020, 4th PONV consensus (PMID 32467512); Gan TJ et al, Anesth Analg 2014, PONV consensus (PMID 24356162)",   // PONV — Apfel Score & Prophylaxis
        "section12": "Goldfrank L et al, Ann Emerg Med 1986 (PMID 3963538); Glahn KPE et al, Br J Anaesth 2020, EMHG dantrolene (PMID 32591088); Larach MG et al, Anesth Analg 2010 (PMID 20081135); Wright RO et al, Ann Emerg Med 1999 (PMID 10533013); Panchal AR et al, Circulation 2020, AHA ACLS (PMID 33081529); Neal JM et al, Reg Anesth Pain Med 2021, ASRA LAST checklist 2020 (PMID 33148630)",   // Emergency & Reversal Drugs
        "section13": "West JB, J Appl Physiol 1996 (PMID 8904608); ARDS Definition Task Force, JAMA 2012, Berlin (PMID 22797452); Bazett HC, Heart 1920; Miller's Anesthesia, 9th ed.",   // Cardiac, Pulmonary & Oxygenation
        "section14": "Tinning K & Acworth J, Emerg Med Australas 2007, Best Guess (PMID 18021105); Lubitz DS et al, Ann Emerg Med 1988, Broselow (PMID 3377285); Topjian AA et al, Pediatrics 2020, AHA PALS (PMID 33087552); Holliday MA & Segar WE, Pediatrics 1957 (PMID 13431307)",   // Pediatric Quick Reference
    ]
}

extension CalcSection {
    var source: String { CalcSources.bySection[colorKey] ?? "" }
}
