// AnesthesiaCalc v1.8.0
// Modified: PatientModel.swift
// Change: UserDefaults persistence for all fields except altitude; touchedFields Set for Phase-2 placeholder behavior
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

    // MARK: - UserDefaults key namespace
    private enum K: String {
        case age, weight, height, sex
        case hemoglobin, minTargetHgb, sao2, svo2
        case pao2, paco2, fio2
        case npoHours, smokingHx, priorPONV, opioidPlanned
        case heartRate, map, cvp, cardiacOutput
        case mpap, pcwp, qtInterval
        case tivaTarget, tivaOpioid, tivaAdjunct, tivaPremedicated
        case tivaASAClass, tivaInfusionDuration
        case epiduralIndication, gestationalAge, cervicalDilation
        case maternalWeightKg, maternalHeightCm
        case epiduralNeedle, spinalNeedle
        case combinedSpinalEpidural, priorEpiduralDose
        case patientMRN, exportDate
    }
    private let ud = UserDefaults.standard

    // MARK: - Touched fields (used by placeholder behavior; @Published so $patient.touchedFields binding works)
    @Published var touchedFields: Set<String> = []

    // MARK: - Demographics
    @Published var age: Double = 35        { didSet { ud.set(age,    forKey: K.age.rawValue)    } }
    @Published var weight: Double = 80     { didSet { ud.set(weight, forKey: K.weight.rawValue) } }
    @Published var height: Double = 175    { didSet { ud.set(height, forKey: K.height.rawValue) } }
    @Published var sex: BiologicalSex = .male {
        didSet { ud.set(sex.rawValue, forKey: K.sex.rawValue) }
    }

    // MARK: - Labs
    @Published var hemoglobin: Double = 14   { didSet { ud.set(hemoglobin,   forKey: K.hemoglobin.rawValue)   } }
    @Published var minTargetHgb: Double = 7  { didSet { ud.set(minTargetHgb, forKey: K.minTargetHgb.rawValue) } }
    @Published var sao2: Double = 0.99       { didSet { ud.set(sao2,         forKey: K.sao2.rawValue)         } }
    @Published var svo2: Double = 0.75       { didSet { ud.set(svo2,         forKey: K.svo2.rawValue)         } }

    // MARK: - ABG
    @Published var pao2: Double = 95         { didSet { ud.set(pao2,  forKey: K.pao2.rawValue)  } }
    @Published var paco2: Double = 40        { didSet { ud.set(paco2, forKey: K.paco2.rawValue) } }
    @Published var fio2: Double = 0.5        { didSet { ud.set(fio2,  forKey: K.fio2.rawValue)  } }

    // MARK: - Preop
    @Published var npoHours: Double = 8        { didSet { ud.set(npoHours,      forKey: K.npoHours.rawValue)      } }
    @Published var smokingHx: Bool = false     { didSet { ud.set(smokingHx,     forKey: K.smokingHx.rawValue)     } }
    @Published var priorPONV: Bool = false     { didSet { ud.set(priorPONV,     forKey: K.priorPONV.rawValue)     } }
    @Published var opioidPlanned: Bool = true  { didSet { ud.set(opioidPlanned, forKey: K.opioidPlanned.rawValue) } }

    // MARK: - Hemodynamics
    @Published var heartRate: Double = 75      { didSet { ud.set(heartRate,     forKey: K.heartRate.rawValue)     } }
    @Published var map: Double = 75            { didSet { ud.set(map,           forKey: K.map.rawValue)           } }
    @Published var cvp: Double = 5             { didSet { ud.set(cvp,           forKey: K.cvp.rawValue)           } }
    @Published var cardiacOutput: Double = 5   { didSet { ud.set(cardiacOutput, forKey: K.cardiacOutput.rawValue) } }

    // MARK: - Pulmonary
    @Published var mpap: Double = 25           { didSet { ud.set(mpap, forKey: K.mpap.rawValue) } }
    @Published var pcwp: Double = 10           { didSet { ud.set(pcwp, forKey: K.pcwp.rawValue) } }

    // MARK: - ECG / Environment
    @Published var qtInterval: Double = 400    { didSet { ud.set(qtInterval, forKey: K.qtInterval.rawValue) } }
    @Published var altitude: Double = 0        // intentionally NOT persisted

    // MARK: - TIVA
    @Published var tivaTarget: TIVATarget = .generalAnesthesia {
        didSet { ud.set(tivaTarget.rawValue, forKey: K.tivaTarget.rawValue) }
    }
    @Published var tivaOpioid: TIVAOpioid = .remifentanil {
        didSet { ud.set(tivaOpioid.rawValue, forKey: K.tivaOpioid.rawValue) }
    }
    @Published var tivaAdjunct: Bool = true         { didSet { ud.set(tivaAdjunct,        forKey: K.tivaAdjunct.rawValue)        } }
    @Published var tivaPremedicated: Bool = false   { didSet { ud.set(tivaPremedicated,   forKey: K.tivaPremedicated.rawValue)   } }
    @Published var tivaASAClass: Int = 2            { didSet { ud.set(tivaASAClass,        forKey: K.tivaASAClass.rawValue)       } }
    @Published var tivaInfusionDuration: Double = 120 {
        didSet { ud.set(tivaInfusionDuration, forKey: K.tivaInfusionDuration.rawValue) }
    }

    // MARK: - OB / Epidural
    @Published var epiduralIndication: EpiduralIndication = .laborAnalgesia {
        didSet { ud.set(epiduralIndication.rawValue, forKey: K.epiduralIndication.rawValue) }
    }
    @Published var gestationalAge: Double = 39      { didSet { ud.set(gestationalAge,    forKey: K.gestationalAge.rawValue)    } }
    @Published var cervicalDilation: Double = 4     { didSet { ud.set(cervicalDilation,  forKey: K.cervicalDilation.rawValue)  } }
    @Published var maternalWeightKg: Double = 75    { didSet { ud.set(maternalWeightKg,  forKey: K.maternalWeightKg.rawValue)  } }
    @Published var maternalHeightCm: Double = 163   { didSet { ud.set(maternalHeightCm,  forKey: K.maternalHeightCm.rawValue)  } }
    @Published var epiduralNeedle: EpiduralNeedle = .tuohy17 {
        didSet { ud.set(epiduralNeedle.rawValue, forKey: K.epiduralNeedle.rawValue) }
    }
    @Published var spinalNeedle: SpinalNeedle = .whitacre25 {
        didSet { ud.set(spinalNeedle.rawValue, forKey: K.spinalNeedle.rawValue) }
    }
    @Published var combinedSpinalEpidural: Bool = false {
        didSet { ud.set(combinedSpinalEpidural, forKey: K.combinedSpinalEpidural.rawValue) }
    }
    @Published var priorEpiduralDose: Double = 0    { didSet { ud.set(priorEpiduralDose, forKey: K.priorEpiduralDose.rawValue) } }

    // MARK: - PDF Export metadata
    @Published var patientMRN: String = "" { didSet { ud.set(patientMRN, forKey: K.patientMRN.rawValue) } }
    @Published var exportDate: Date = Date() { didSet { ud.set(exportDate, forKey: K.exportDate.rawValue) } }

    // MARK: - Init — restore persisted state
    // didSet observers do NOT fire for assignments inside a class's own designated init.
    // Each assignment here restores the last saved value; if no key exists, the
    // inline default declared above is kept unchanged.
    init() {
        // Demographics
        if ud.object(forKey: K.age.rawValue)    != nil { age    = ud.double(forKey: K.age.rawValue)    }
        if ud.object(forKey: K.weight.rawValue) != nil { weight = ud.double(forKey: K.weight.rawValue) }
        if ud.object(forKey: K.height.rawValue) != nil { height = ud.double(forKey: K.height.rawValue) }
        if let raw = ud.string(forKey: K.sex.rawValue),
           let v   = BiologicalSex(rawValue: raw)  { sex = v }

        // Labs
        if ud.object(forKey: K.hemoglobin.rawValue)   != nil { hemoglobin   = ud.double(forKey: K.hemoglobin.rawValue)   }
        if ud.object(forKey: K.minTargetHgb.rawValue) != nil { minTargetHgb = ud.double(forKey: K.minTargetHgb.rawValue) }
        if ud.object(forKey: K.sao2.rawValue)         != nil { sao2         = ud.double(forKey: K.sao2.rawValue)         }
        if ud.object(forKey: K.svo2.rawValue)         != nil { svo2         = ud.double(forKey: K.svo2.rawValue)         }

        // ABG
        if ud.object(forKey: K.pao2.rawValue)  != nil { pao2  = ud.double(forKey: K.pao2.rawValue)  }
        if ud.object(forKey: K.paco2.rawValue) != nil { paco2 = ud.double(forKey: K.paco2.rawValue) }
        if ud.object(forKey: K.fio2.rawValue)  != nil { fio2  = ud.double(forKey: K.fio2.rawValue)  }

        // Preop
        if ud.object(forKey: K.npoHours.rawValue)      != nil { npoHours    = ud.double(forKey: K.npoHours.rawValue)     }
        if ud.object(forKey: K.smokingHx.rawValue)     != nil { smokingHx   = ud.bool(forKey: K.smokingHx.rawValue)     }
        if ud.object(forKey: K.priorPONV.rawValue)     != nil { priorPONV   = ud.bool(forKey: K.priorPONV.rawValue)     }
        if ud.object(forKey: K.opioidPlanned.rawValue) != nil { opioidPlanned = ud.bool(forKey: K.opioidPlanned.rawValue) }

        // Hemodynamics
        if ud.object(forKey: K.heartRate.rawValue)     != nil { heartRate     = ud.double(forKey: K.heartRate.rawValue)     }
        if ud.object(forKey: K.map.rawValue)           != nil { map           = ud.double(forKey: K.map.rawValue)           }
        if ud.object(forKey: K.cvp.rawValue)           != nil { cvp           = ud.double(forKey: K.cvp.rawValue)           }
        if ud.object(forKey: K.cardiacOutput.rawValue) != nil { cardiacOutput = ud.double(forKey: K.cardiacOutput.rawValue) }

        // Pulmonary
        if ud.object(forKey: K.mpap.rawValue) != nil { mpap = ud.double(forKey: K.mpap.rawValue) }
        if ud.object(forKey: K.pcwp.rawValue) != nil { pcwp = ud.double(forKey: K.pcwp.rawValue) }

        // ECG — altitude intentionally NOT loaded
        if ud.object(forKey: K.qtInterval.rawValue) != nil { qtInterval = ud.double(forKey: K.qtInterval.rawValue) }

        // TIVA
        if let raw = ud.string(forKey: K.tivaTarget.rawValue),
           let v   = TIVATarget(rawValue: raw) { tivaTarget = v }
        if let raw = ud.string(forKey: K.tivaOpioid.rawValue),
           let v   = TIVAOpioid(rawValue: raw) { tivaOpioid = v }
        if ud.object(forKey: K.tivaAdjunct.rawValue)         != nil { tivaAdjunct        = ud.bool(forKey: K.tivaAdjunct.rawValue)         }
        if ud.object(forKey: K.tivaPremedicated.rawValue)    != nil { tivaPremedicated   = ud.bool(forKey: K.tivaPremedicated.rawValue)    }
        if ud.object(forKey: K.tivaASAClass.rawValue)        != nil { tivaASAClass       = ud.integer(forKey: K.tivaASAClass.rawValue)     }
        if ud.object(forKey: K.tivaInfusionDuration.rawValue) != nil {
            tivaInfusionDuration = ud.double(forKey: K.tivaInfusionDuration.rawValue)
        }

        // OB / Epidural
        if let raw = ud.string(forKey: K.epiduralIndication.rawValue),
           let v   = EpiduralIndication(rawValue: raw) { epiduralIndication = v }
        if ud.object(forKey: K.gestationalAge.rawValue)    != nil { gestationalAge    = ud.double(forKey: K.gestationalAge.rawValue)    }
        if ud.object(forKey: K.cervicalDilation.rawValue)  != nil { cervicalDilation  = ud.double(forKey: K.cervicalDilation.rawValue)  }
        if ud.object(forKey: K.maternalWeightKg.rawValue)  != nil { maternalWeightKg  = ud.double(forKey: K.maternalWeightKg.rawValue)  }
        if ud.object(forKey: K.maternalHeightCm.rawValue)  != nil { maternalHeightCm  = ud.double(forKey: K.maternalHeightCm.rawValue)  }
        if let raw = ud.string(forKey: K.epiduralNeedle.rawValue),
           let v   = EpiduralNeedle(rawValue: raw) { epiduralNeedle = v }
        if let raw = ud.string(forKey: K.spinalNeedle.rawValue),
           let v   = SpinalNeedle(rawValue: raw) { spinalNeedle = v }
        if ud.object(forKey: K.combinedSpinalEpidural.rawValue) != nil {
            combinedSpinalEpidural = ud.bool(forKey: K.combinedSpinalEpidural.rawValue)
        }
        if ud.object(forKey: K.priorEpiduralDose.rawValue) != nil {
            priorEpiduralDose = ud.double(forKey: K.priorEpiduralDose.rawValue)
        }

        // PDF Export metadata
        if let s = ud.string(forKey: K.patientMRN.rawValue) { patientMRN = s }
        if let d = ud.object(forKey: K.exportDate.rawValue) as? Date { exportDate = d }
    }

    // MARK: - Reset all inputs except altitude
    // Clears touched flags and writes factory defaults back to UserDefaults via didSet.
    func resetInputs() {
        touchedFields = []
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
