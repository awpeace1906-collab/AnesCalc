// AnesthesiaCalc v1.6.0
// Modified: ContentView.swift
// Change: Conversions tab, Reset button with confirmation, PDF export MRN/date sheet
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var patient = PatientModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            CalculatorTab(patient: patient)
                .tabItem {
                    Label("Calculator", systemImage: "stethoscope")
                }
                .tag(0)

            DrugCardsView()
                .tabItem {
                    Label("Drug Cards", systemImage: "pills.fill")
                }
                .tag(1)

            ConversionsView()
                .tabItem {
                    Label("Conversions", systemImage: "arrow.left.arrow.right")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(theme.accent)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(theme.tabBarBg)
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor      = UIColor.white.withAlphaComponent(0.55)
            itemAppearance.normal.titleTextAttributes   = [.foregroundColor: UIColor.white.withAlphaComponent(0.55)]
            itemAppearance.selected.iconColor    = UIColor(theme.accent)
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(theme.accent)]
            appearance.stackedLayoutAppearance  = itemAppearance
            appearance.inlineLayoutAppearance   = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Calculator Tab

struct CalculatorTab: View {
    @ObservedObject var patient: PatientModel
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var focusManager = FieldFocusManager()
    @State private var showShareSheet = false
    @State private var showExportSheet = false
    @State private var showResetConfirm = false
    @State private var pdfData: Data?
    @State private var expandedSections: Set<String> = []

    private var engine: CalculationEngine { CalculationEngine(p: patient) }
    private var sections: [CalcSection]   { engine.buildAll() }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    PatientInputView(patient: patient)
                        .environmentObject(focusManager)
                        .padding(.bottom, 6)
                    TIVAInputView(patient: patient)
                        .environmentObject(theme)
                        .environmentObject(focusManager)
                        .padding(.bottom, 6)
                    EpiduralInputView(patient: patient)
                        .environmentObject(theme)
                        .environmentObject(focusManager)
                        .padding(.bottom, 8)

                    ForEach(sections, id: \.title) { section in
                        SectionCardView(
                            section: section,
                            isExpanded: expandedSections.contains(section.title),
                            onToggle: {
                                if expandedSections.contains(section.title) {
                                    expandedSections.remove(section.title)
                                } else {
                                    expandedSections.insert(section.title)
                                }
                            }
                        )
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                    }

                    // Disclaimer
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Reference tool only. Verify all doses with current guidelines and clinical judgment.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(8)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Anesthesia Calc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 14) {
                        Button(action: {
                            expandedSections = Set(sections.map(\.title))
                        }) {
                            Image(systemName: "rectangle.expand.vertical")
                                .foregroundColor(.white)
                        }
                        Button(action: { showResetConfirm = true }) {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showExportSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .keyboard) {
                    HStack(spacing: 0) {
                        // Previous field
                        Button(action: { focusManager.movePrev() }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .disabled(focusManager.isFirst)
                        .foregroundColor(focusManager.isFirst ? .secondary : theme.accent)
                        .frame(width: 44, height: 36)

                        // Next field
                        Button(action: { focusManager.moveNext() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .disabled(focusManager.isLast)
                        .foregroundColor(focusManager.isLast ? .secondary : theme.accent)
                        .frame(width: 44, height: 36)

                        Spacer()

                        Button("Done") {
                            focusManager.current = nil
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(theme.accent)
                    }
                }
            }
            .navigationBarBackground(theme.headerBg)
            // Reset confirmation
            .alert("Reset All Inputs?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) { patient.resetInputs() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All fields will return to defaults. Altitude setting will be preserved.")
            }
            // Export options sheet
            .sheet(isPresented: $showExportSheet) {
                ExportOptionsSheet(patient: patient) { mrn, date in
                    patient.patientMRN = mrn
                    patient.exportDate = date
                    showExportSheet = false
                    exportPDF()
                }
                .presentationDetents([.medium])
            }
            // Share sheet
            .sheet(isPresented: $showShareSheet) {
                if let data = pdfData {
                    ShareSheet(items: [data])
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func exportPDF() {
        pdfData = PDFExporter.generatePDF(patient: patient, sections: sections)
        showShareSheet = true
    }
}

// MARK: - Navigation Bar Background

extension View {
    func navigationBarBackground(_ color: Color) -> some View {
        self.modifier(NavigationBarModifier(color: color))
    }
}

struct NavigationBarModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

// MARK: - Export Options Sheet

struct ExportOptionsSheet: View {
    @ObservedObject var patient: PatientModel
    let onExport: (String, Date) -> Void

    @State private var mrn: String = ""
    @State private var date: Date = Date()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Patient MRN")
                        Spacer()
                        TextField("Optional", text: $mrn)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("Export Header (Optional)")
                } footer: {
                    Text("MRN and date will appear at the top of the exported PDF.")
                        .font(.caption)
                }

                Section {
                    Button(action: { onExport(mrn, date) }) {
                        HStack {
                            Spacer()
                            Label("Generate PDF", systemImage: "doc.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear {
            mrn  = patient.patientMRN
            date = patient.exportDate
        }
    }
}
