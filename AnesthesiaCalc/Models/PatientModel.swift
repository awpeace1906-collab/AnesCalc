// AnesthesiaCalc v1.6.0
// Modified: PatientModel.swift
// Change: Added patientMRN and exportDate fields for PDF export header
import Foundation
import Combine

enum BiologicalSex: String, CaseIterable, Identifiable {
    case male = "M"
    case female = "F"
    var id: String { rawValue }
    var label: String { self == .male ? "Male" : "Female" }
}

enum TIVATarget: String, CaseIterable, Identifiable {
    case generalAnesthesia = "General Anesthesia"
    case sedationMild      = "Mild Sedation"
    case sedationModerate  = "Moderate Sedation"
    case ICUSedation       = "ICU Sedation"
    var id: String { rawValue }
}

enum TIVAOpioid: String, CaseIterable, Identifiable {
    case remifentanil = "Remifentanil"
    case fentanyl     = "Fentanyl"
    case alfentanil   = "Alfentanil"
    case sufentanil   = "Sufentanil"
    var id: String { rawValue }
}

enum EpiduralIndication: String, CaseIterable, Identifiable {
    case laborAnalgesia    = "Labor Analgesia"
    case csectionSpinal    = "C-Section (Spinal)"
    case csectionEpidural  = "C-Section (Epidural)"
    case thoracicEpidural  = "Thoracic Epidural"
    case lumbarEpidural    = "Lumbar Epidural Surgical"
    var id: String { rawValue }
}

enum EpiduralNeedle: String, CaseIterable, Identifiable {
    case tuohy17 = "Tuohy 17G"
    case tuohy18 = "Tuohy 18G"
    case tuohy16 = "Tuohy 16G"
    var id: String { rawValue }
}

enum SpinalNeedle: String, CaseIterable, Identifiable {
    case whitacre25 = "Whitacre 25G"
    case whitacre27 = "Whitacre 27G"
    case quincke25  = "Quincke 25G"
    case quincke27  = "Quincke 27G"
    case sprotte24  = "Sprotte 24G"
    var id: String { rawValue }
}

class PatientModel: ObservableObject {
    // Demographics
    @Published var age: Double = 35
    @Published var weight: Double = 80
    @Published var height: Double = 175
    @Published var sex: BiologicalSex = .male

    // Labs
    @Published var hemoglobin: Double = 14
    @Published var minTargetHgb: Double = 7
    @Published var sao2: Double = 0.99
    @Published var svo2: Double = 0.75

    // ABG
    @Published var pao2: Double = 95
    @Published var paco2: Double = 40
    @Published var fio2: Double = 0.5

    // Preop
    @Published var npoHours: Double = 8
    @Published var smokingHx: Bool = false
    @Published var priorPONV: Bool = false
    @Published var opioidPlanned: Bool = true

    // Hemodynamics
    @Published var heartRate: Double = 75
    @Published var map: Double = 75
    @Published var cvp: Double = 5
    @Published var cardiacOutput: Double = 5

    // Pulmonary
    @Published var mpap: Double = 25
    @Published var pcwp: Double = 10

    // ECG
    @Published var qtInterval: Double = 400
    @Published var altitude: Double = 0

    // TIVA
    @Published var tivaTarget: TIVATarget = .generalAnesthesia
    @Published var tivaOpioid: TIVAOpioid = .remifentanil
    @Published var tivaAdjunct: Bool = true
    @Published var tivaPremedicated: Bool = false
    @Published var tivaASAClass: Int = 2
    @Published var tivaInfusionDuration: Double = 120

    // OB / Epidural
    @Published var epiduralIndication: EpiduralIndication = .laborAnalgesia
    @Published var gestationalAge: Double = 39
    @Published var cervicalDilation: Double = 4
    @Published var maternalWeightKg: Double = 75
    @Published var maternalHeightCm: Double = 163
    @Published var epiduralNeedle: EpiduralNeedle = .tuohy17
    @Published var spinalNeedle: SpinalNeedle = .whitacre25
    @Published var combinedSpinalEpidural: Bool = false
    @Published var priorEpiduralDose: Double = 0

    // PDF Export metadata
    @Published var patientMRN: String = ""
    @Published var exportDate: Date = Date()

    // Reset all inputs except altitude
    func resetInputs() {
        age = 35; weight = 80; height = 175; sex = .male
        hemoglobin = 14; minTargetHgb = 7; sao2 = 0.99; svo2 = 0.75
        pao2 = 95; paco2 = 40; fio2 = 0.5
        npoHours = 8; smokingHx = false; priorPONV = false; opioidPlanned = true
        heartRate = 75; map = 75; cvp = 5; cardiacOutput = 5
        mpap = 25; pcwp = 10; qtInterval = 400
        // altitude intentionally excluded
        tivaTarget = .generalAnesthesia; tivaOpioid = .remifentanil
        tivaAdjunct = true; tivaPremedicated = false
        tivaASAClass = 2; tivaInfusionDuration = 120
        epiduralIndication = .laborAnalgesia; gestationalAge = 39
        cervicalDilation = 4; maternalWeightKg = 75; maternalHeightCm = 163
        epiduralNeedle = .tuohy17; spinalNeedle = .whitacre25
        combinedSpinalEpidural = false; priorEpiduralDose = 0
        patientMRN = ""; exportDate = Date()
    }
}
