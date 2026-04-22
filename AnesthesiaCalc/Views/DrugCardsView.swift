import SwiftUI

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
        NavigationView {
            VStack(spacing: 0) {
                // ── Search ───────────────────────────────────────────────────
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search drugs...", text: $searchText)
                        .font(.system(size: 14))
                        .focused($searchFocused)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 6)

                // ── Category Filter ──────────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        categoryChip("All", category: nil)
                        ForEach(DrugCategory.allCases) { cat in
                            categoryChip(cat.rawValue, category: cat)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }

                Divider()

                // ── Card List ────────────────────────────────────────────────
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "pills")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No drugs found")
                            .foregroundColor(.secondary)
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
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.primary.opacity(0.12))
                        .cornerRadius(8)
                    }
                }
            }
            .sheet(item: $selectedCard) { card in
                DrugCardDetailView(card: card)
                    .environmentObject(theme)
            }
        }
        .navigationViewStyle(.stack)
    }

    func categoryChip(_ label: String, category: DrugCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: {
            selectedCategory = category
            searchFocused = false
        }) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : theme.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(isSelected ? theme.primary : Color(.systemBackground))
                .cornerRadius(20)
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
                        .foregroundColor(.primary)
                    Text(card.category.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.sectionColor(card.colorKey).opacity(0.85))
                    Text(card.mechanism)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Hero header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(card.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1.5)
                        Text(card.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
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
                                .foregroundColor(.orange)
                            ForEach(card.cautions, id: \.self) { caution in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundColor(.orange)
                                        .padding(.top, 5)
                                    Text(caution)
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(10)

                        // Pearls
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Clinical Pearls", systemImage: "lightbulb.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(cardColor)
                            ForEach(card.pearls, id: \.self) { pearl in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(cardColor)
                                        .padding(.top, 3)
                                    Text(pearl)
                                        .font(.system(size: 13))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(14)
                        .background(cardColor.opacity(0.08))
                        .cornerRadius(10)
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
                .foregroundColor(.secondary)
                .tracking(0.8)
            Text(body)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}
