import SwiftUI

struct SectionCardView: View {
    let section: CalcSection
    let isExpanded: Bool
    let onToggle: () -> Void

    @EnvironmentObject var theme: ThemeManager

    private var sectionColor: Color { theme.sectionColor(section.colorKey) }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────────────
            Button(action: { withAnimation(.spring(response: 0.3)) { onToggle() } }) {
                HStack(spacing: 10) {
                    Image(systemName: section.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Text(section.title.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .tracking(0.5)

                    Spacer()

                    // Alert badge if any critical items
                    let criticalCount = section.results.filter { $0.alert == .critical || $0.alert == .warning }.count
                    if criticalCount > 0 {
                        Text("\(criticalCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(sectionColor)
                            .frame(width: 18, height: 18)
                            .background(Color.white)
                            .clipShape(Circle())
                            .accessibilityLabel("\(criticalCount) critical or warning value\(criticalCount == 1 ? "" : "s")")
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(sectionColor)
            }

            // ── Results ──────────────────────────────────────────────────────
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(section.results.enumerated()), id: \.offset) { idx, result in
                        ResultRowView(result: result, isEven: idx % 2 == 0, accentColor: sectionColor)
                        if idx < section.results.count - 1 {
                            Divider().padding(.leading, 44)
                        }
                    }

                    // Source
                    if !section.source.isEmpty {
                        Divider()
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                            Text(verbatim: "Sources: " + section.source)
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                    }
                }
                .background(Color(.systemBackground))
                .clipped()
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.07), radius: 3, y: 2)
    }
}

// MARK: - Result Row

struct ResultRowView: View {
    let result: CalcResult
    let isEven: Bool
    let accentColor: Color

    @Environment(\.colorScheme) var colorScheme

    var alertColor: Color? {
        let dark = colorScheme == .dark
        switch result.alert {
        case .critical: return dark ? Color(red: 1.00, green: 0.35, blue: 0.27) : Color(red: 0.75, green: 0.12, blue: 0.07)
        case .warning:  return dark ? Color(red: 1.00, green: 0.70, blue: 0.00) : Color(red: 0.85, green: 0.45, blue: 0.00)
        case .caution:  return dark ? Color(red: 1.00, green: 0.88, blue: 0.00) : Color(red: 0.75, green: 0.65, blue: 0.00)
        case .normal:   return nil
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Alert stripe
            Rectangle()
                .fill(alertColor ?? Color.clear)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(result.label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if !result.note.isEmpty {
                    Text(result.note)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.secondary.opacity(0.7))
                        .italic()
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Value
            VStack(alignment: .trailing, spacing: 1) {
                Text(result.value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(alertColor ?? accentColor)
                    .minimumScaleFactor(0.7)
                if !result.unit.isEmpty {
                    Text(result.unit)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 70, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(isEven ? Color(.systemBackground) : Color(.secondarySystemBackground))
    }
}
