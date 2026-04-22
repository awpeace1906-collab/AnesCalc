import SwiftUI
import Combine

// Ordered list of all numeric fields across all input panels.
// The index order determines prev/next navigation sequence.
enum AppField: Int, CaseIterable {
    // Patient inputs
    case age, weight, height
    case hgb, minHgb
    case npo, fio2, hr
    case map, cvp, co
    case pao2, paco2, sao2
    case svo2, mpap, pcwp
    case qt, altitude
    // TIVA
    case tivaDuration
    // OB / Epidural
    case maternalWeight, maternalHeight, ga, cervix
}

class FieldFocusManager: ObservableObject {
    @Published var current: AppField? = nil

    func moveNext() {
        guard let c = current,
              let nextRaw = AppField(rawValue: c.rawValue + 1) else {
            current = nil
            return
        }
        current = nextRaw
    }

    func movePrev() {
        guard let c = current,
              let prevRaw = AppField(rawValue: c.rawValue - 1) else { return }
        current = prevRaw
    }

    var isFirst: Bool { current?.rawValue == 0 }
    var isLast:  Bool { current == AppField.allCases.last }
}
