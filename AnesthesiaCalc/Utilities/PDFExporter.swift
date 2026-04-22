// AnesthesiaCalc v1.6.0
// Modified: PDFExporter.swift
// Change: MRN and date in patient header block
import UIKit
import PDFKit

struct PDFExporter {

    static func generatePDF(patient: PatientModel, sections: [CalcSection]) -> Data {
        let pageWidth: CGFloat  = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat     = 40
        let contentWidth        = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { ctx in
            var y: CGFloat = margin

            func newPage() {
                ctx.beginPage()
                y = margin
                drawPageHeader(at: &y)
            }

            func checkPageBreak(neededHeight: CGFloat) {
                if y + neededHeight > pageHeight - margin { newPage() }
            }

            // ── Helpers ──────────────────────────────────────────────────────
            func drawText(_ text: String, font: UIFont, color: UIColor = .black,
                          x: CGFloat = margin, width: CGFloat = contentWidth,
                          alignment: NSTextAlignment = .left) -> CGFloat {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font, .foregroundColor: color
                ]
                let rect = CGRect(x: x, y: y, width: width, height: .greatestFiniteMagnitude)
                let bounded = NSAttributedString(string: text, attributes: attrs)
                    .boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                  options: .usesLineFragmentOrigin, context: nil)
                let style = NSMutableParagraphStyle()
                style.alignment = alignment
                let finalAttrs: [NSAttributedString.Key: Any] = [
                    .font: font, .foregroundColor: color, .paragraphStyle: style
                ]
                text.draw(in: CGRect(x: x, y: y, width: width, height: bounded.height + 4),
                          withAttributes: finalAttrs)
                return bounded.height + 4
            }

            func drawPageHeader(at yRef: inout CGFloat) {
                let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 50)
                UIColor(red: 0.107, green: 0.227, blue: 0.42, alpha: 1).setFill()
                UIRectFill(headerRect)
                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ]
                "⚕  ANESTHESIA CLINICAL CALCULATOR".draw(
                    at: CGPoint(x: margin, y: 16), withAttributes: titleAttrs)
                let now = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                let dateAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.8)
                ]
                now.draw(at: CGPoint(x: pageWidth - 180, y: 19), withAttributes: dateAttrs)
                yRef = 60
            }

            // ── Patient Summary ───────────────────────────────────────────────
            newPage()

            // Patient header block
            let boxHeight: CGFloat = patient.patientMRN.isEmpty ? 86 : 100
            UIColor(red: 0.84, green: 0.92, blue: 0.97, alpha: 1).setFill()
            UIRectFill(CGRect(x: margin, y: y, width: contentWidth, height: boxHeight))
            y += 10

            let boldFont  = UIFont.boldSystemFont(ofSize: 11)
            let regFont   = UIFont.systemFont(ofSize: 10)
            let smallFont = UIFont.systemFont(ofSize: 9)

            let sexLabel = patient.sex == .male ? "Male" : "Female"

            // MRN and date row (if provided)
            let df = DateFormatter()
            df.dateStyle = .medium; df.timeStyle = .short
            let dateStr = df.string(from: patient.exportDate)
            var headerLine = "Date: \(dateStr)"
            if !patient.patientMRN.isEmpty { headerLine = "MRN: \(patient.patientMRN)   |   " + headerLine }
            _ = drawText(headerLine, font: boldFont,
                         color: UIColor(red: 0.107, green: 0.227, blue: 0.42, alpha: 1))
            y += 14

            _ = drawText("PATIENT DEMOGRAPHICS", font: UIFont.systemFont(ofSize: 9),
                         color: UIColor(red: 0.107, green: 0.227, blue: 0.42, alpha: 1).withAlphaComponent(0.7))
            y += 12
            _ = drawText(
                "Age: \(Int(patient.age)) yrs  |  Weight: \(String(format: "%.1f", patient.weight)) kg  |  Height: \(Int(patient.height)) cm  |  Sex: \(sexLabel)  |  BMI: \(String(format: "%.1f", patient.weight / pow(patient.height/100, 2))) kg/m²",
                font: regFont)
            y += 14
            _ = drawText(
                "Hgb: \(String(format: "%.1f", patient.hemoglobin)) g/dL  |  Min Hgb: \(String(format: "%.1f", patient.minTargetHgb)) g/dL  |  NPO: \(Int(patient.npoHours))h  |  FiO₂: \(String(format: "%.2f", patient.fio2))  |  HR: \(Int(patient.heartRate)) bpm  |  MAP: \(Int(patient.map)) mmHg",
                font: regFont)
            y += 18

            // ── Sections ──────────────────────────────────────────────────────
            for section in sections {
                checkPageBreak(neededHeight: 40)

                // Section header
                UIColor(red: 0.107, green: 0.227, blue: 0.42, alpha: 1).setFill()
                UIRectFill(CGRect(x: margin, y: y, width: contentWidth, height: 20))
                let sectionAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.white
                ]
                "\(section.icon)  \(section.title)".draw(
                    at: CGPoint(x: margin + 8, y: y + 5), withAttributes: sectionAttrs)
                y += 22

                // Result rows
                for (idx, result) in section.results.enumerated() {
                    checkPageBreak(neededHeight: 18)
                    let rowBg = idx % 2 == 0
                        ? UIColor(white: 0.97, alpha: 1)
                        : UIColor.white
                    rowBg.setFill()
                    UIRectFill(CGRect(x: margin, y: y, width: contentWidth, height: 17))

                    // Alert indicator
                    let alertColor: UIColor
                    switch result.alert {
                    case .critical: alertColor = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1)
                    case .warning:  alertColor = UIColor(red: 0.85, green: 0.55, blue: 0.0,  alpha: 1)
                    case .caution:  alertColor = UIColor(red: 0.95, green: 0.77, blue: 0.06, alpha: 1)
                    case .normal:   alertColor = UIColor.clear
                    }
                    alertColor.setFill()
                    UIRectFill(CGRect(x: margin, y: y, width: 4, height: 17))

                    let labelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.darkGray
                    ]
                    let valueAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 9.5), .foregroundColor: UIColor.black
                    ]
                    let noteAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.italicSystemFont(ofSize: 8), .foregroundColor: UIColor.gray
                    ]

                    result.label.draw(at: CGPoint(x: margin + 8, y: y + 4), withAttributes: labelAttrs)
                    "\(result.value) \(result.unit)".draw(
                        at: CGPoint(x: margin + contentWidth * 0.55, y: y + 4), withAttributes: valueAttrs)
                    if !result.note.isEmpty {
                        result.note.draw(at: CGPoint(x: margin + contentWidth * 0.75, y: y + 5), withAttributes: noteAttrs)
                    }
                    y += 17
                }
                y += 6
            }

            // ── Footer on last page ───────────────────────────────────────────
            let footerY = pageHeight - 30
            UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: footerY, width: pageWidth, height: 30))
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 7.5),
                .foregroundColor: UIColor.white
            ]
            "⚠ CLINICAL DISCLAIMER: Reference tool only. All doses must be verified against current guidelines and clinical judgment."
                .draw(at: CGPoint(x: margin, y: footerY + 10), withAttributes: footerAttrs)
        }
    }
}
