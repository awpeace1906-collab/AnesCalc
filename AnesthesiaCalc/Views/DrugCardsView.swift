import SwiftUI

// MARK: - Chip label abbreviations (display only — rawValue unchanged)
extension DrugCategory {
    var chipLabel: String {
        switch self {
        case .anticoagulant:   return "Anticoag."
        case .anticholinergic: return "Anticholinergic"
        case .gi:              return "GI"
        case .methBlue:        return "Meth. Blue"
        case .local:           return "Local Anesthetic"
        default:               return rawValue
        }
    }
}

// MARK: - Wrapping flow layout (iOS 16+)
struct FlowLayout: Layout {
    var hSpacing: CGFloat = 8
    var vSpacing: CGFloat = 6

    private struct RowData {
        var subviews: [(LayoutSubviews.Element, CGSize)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func makeRows(subviews: LayoutSubviews, containerWidth: CGFloat) -> [RowData] {
        var rows: [RowData] = []
        var row = RowData()

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = row.subviews.isEmpty ? size.width : row.width + hSpacing + size.width
            if !row.subviews.isEmpty && needed > containerWidth {
                rows.append(row)
                row = RowData()
            }
            row.width = row.subviews.isEmpty ? size.width : row.width + hSpacing + size.width
            row.height = max(row.height, size.height)
            row.subviews.append((subview, size))
        }
        if !row.subviews.isEmpty { rows.append(row) }
        return rows
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let w = proposal.replacingUnspecifiedDimensions().width
        let rows = makeRows(subviews: subviews, containerWidth: w)
        let h = rows.reduce(0) { $0 + $1.height } + max(0, CGFloat(rows.count - 1)) * vSpacing
        return CGSize(width: w, height: h)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(subviews: subviews, containerWidth: bounds.width)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for (subview, size) in row.subviews {
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + hSpacing
            }
            y += row.height + vSpacing
        }
    }
}

struct DrugCardsView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedCategory: DrugCategory? = nil
    @State private var searchText = ""
    @State private var selectedCard: DrugCard? = nil
    @FocusState private var searchFocused: Bool

    var filtered: [DrugCard] {
        DrugCardLibrary.all.filter { card in
            let matchesCategory = selectedCategory == nil || card.category == selectedCategory
            let matchesSearch   = searchText.isEmpty
                || card.name.localizedCaseInsensitiveContains(searchText)
                || card.category.rawValue.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Search ───────────────────────────────────────────────────
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search drugs...", text: $searchText)
                        .font(.system(size: 14))
                        .focused($searchFocused)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 6)

                // ── Category Filter (wrapping chips — no horizontal scroll) ──
                FlowLayout(hSpacing: 7, vSpacing: 6) {
                    categoryChip("All", category: nil)
                    ForEach(DrugCategory.allCases) { cat in
                        categoryChip(cat.chipLabel, category: cat)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                Divider()

                // ── Card List ────────────────────────────────────────────────
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "pills")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No drugs found")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filtered) { card in
                                DrugCardRowView(card: card)
                                    .onTapGesture {
                                        searchFocused = false
                                        selectedCard = card
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    // Dismiss keyboard when scrolling the list
                    .onTapGesture { searchFocused = false }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Drug Reference")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackground(theme.headerBg)
            .toolbar {
                // ── Done button above the number pad / search keyboard ────────
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: { searchFocused = false }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Done")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(theme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.primary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                DrugCardDetailView(card: card)
                    .environmentObject(theme)
            }
        }
    }

    func categoryChip(_ label: String, category: DrugCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: {
            selectedCategory = category
            searchFocused = false
        }) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isSelected ? .white : theme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(isSelected ? theme.primary : Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.primary.opacity(0.3), lineWidth: 1))
        }
    }
}

// MARK: - Drug Card Row

struct DrugCardRowView: View {
    let card: DrugCard
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 0) {
            // ── Left accent bar — full-height, no clipping ──────────────────
            Rectangle()
                .fill(theme.sectionColor(card.colorKey))
                .frame(width: 4)

            // ── Content ──────────────────────────────────────────────────────
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(card.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(card.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(theme.sectionColor(card.colorKey).opacity(0.85))
                    Text(card.mechanism)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - Drug Card Detail

struct DrugCardDetailView: View {
    let card: DrugCard
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) var dismiss

    var cardColor: Color { theme.sectionColor(card.colorKey) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Hero header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))
                            .tracking(1.5)
                        Text(card.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(cardColor)

                    Group {
                        infoBlock(icon: "waveform.path.ecg", title: "Mechanism", body: card.mechanism)
                        HStack(spacing: 12) {
                            infoBlock(icon: "timer", title: "Onset", body: card.onset)
                                .frame(maxWidth: .infinity)
                            infoBlock(icon: "clock", title: "Duration", body: card.duration)
                                .frame(maxWidth: .infinity)
                        }
                        infoBlock(icon: "syringe.fill", title: "Dosing", body: card.dosing)

                        // Cautions
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Cautions & Contraindications", systemImage: "exclamationmark.triangle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.orange)
                            ForEach(card.cautions, id: \.self) { caution in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundStyle(.orange)
                                        .padding(.top, 5)
                                    Text(caution)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.orange.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Pearls
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Clinical Pearls", systemImage: "lightbulb.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(cardColor)
                            ForEach(card.pearls, id: \.self) { pearl in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(cardColor)
                                        .padding(.top, 3)
                                    Text(pearl)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .padding(14)
                        .background(cardColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(card.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    func infoBlock(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title.uppercased(), systemImage: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
            Text(body)
                .font(.system(size: 13))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
