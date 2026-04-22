# ⚕ Anesthesia Clinical Calculator — iOS App

A native SwiftUI app for iPhone and iPad with all 14 anesthesia calculation categories,
quick-reference drug cards, theming, and PDF export.

---

## Features

- **14 calculation sections** — all auto-update when inputs change:
  Anthropometrics · Airway · MAC (age-corrected) · Induction Agents · NMB & Reversal ·
  Fluid Management · Ventilator Settings · Opioids & Analgesics · Vasopressors ·
  Local Anesthetics & LAST rescue · PONV/Apfel · Emergency Drugs · Cardiac/Oxygenation · Pediatric

- **Drug Reference Cards** — searchable, filterable by category, with mechanism, dosing,
  cautions, and clinical pearls for propofol, ketamine, etomidate, sevoflurane, desflurane,
  succinylcholine, rocuronium, sugammadex, fentanyl, remifentanil, bupivacaine, ropivacaine,
  phenylephrine, epinephrine, dantrolene, and more

- **6 Color Themes** — Navy & Gold · Deep Teal · Midnight Red · Slate Green · Charcoal Blue · Purple Gray

- **Dark/Light/System Mode** — fully respects iOS appearance settings

- **PDF Export & Share** — generates a formatted patient report sharable via AirDrop, email, etc.

- **100% Offline** — no network connection required; no data transmitted

---

## How to Open in Xcode

### Requirements
- Mac with macOS 13 (Ventura) or later
- Xcode 15.0 or later (free from Mac App Store)
- Apple Developer account (free for personal device testing)

### Steps

1. **Unzip** this folder anywhere on your Mac

2. **Open Xcode** → File → Open → navigate to `AnesthesiaCalc/AnesthesiaCalc.xcodeproj`

3. **Set your Team** (required to run on a physical device):
   - Click the project name in the navigator (top left)
   - Select the `AnesthesiaCalc` target
   - Under **Signing & Capabilities** → set **Team** to your Apple ID

4. **Select your device** in the top toolbar (your iPhone/iPad, or a Simulator)

5. **Press ▶ Run** (⌘R)

That's it. The app will install and launch on your device.

---

## Project Structure

```
AnesthesiaCalc/
├── AnesthesiaCalc.xcodeproj/       ← Xcode project file
└── AnesthesiaCalc/
    ├── AnesthesiaCalcApp.swift      ← App entry point
    ├── ContentView.swift            ← Tab container + Calculator tab
    ├── Models/
    │   ├── PatientModel.swift       ← All patient input state (@Published)
    │   ├── CalculationEngine.swift  ← All 14 sections, 116+ calculations
    │   └── DrugCard.swift           ← Drug card data model + library
    ├── Views/
    │   ├── PatientInputView.swift   ← Collapsible input form
    │   ├── SectionCardView.swift    ← Collapsible result cards
    │   ├── DrugCardsView.swift      ← Drug browser + detail sheet
    │   └── SettingsView.swift       ← Theme + color scheme picker
    └── Utilities/
        ├── ThemeManager.swift       ← 6 themes, color scheme, @AppStorage
        ├── PDFExporter.swift        ← UIGraphicsPDFRenderer export
        └── AppColors.swift          ← Color utilities
```

---

## Extending the App

### Add a new calculation
1. Open `CalculationEngine.swift`
2. Add computed properties for your formula
3. Add `CalcResult` entries to the appropriate section function
4. Rebuild — the UI renders everything automatically

### Add a drug card
1. Open `DrugCard.swift`
2. Add a new `DrugCard(...)` entry to `DrugCardLibrary.all`

### Add a theme
1. Open `ThemeManager.swift`
2. Add a case to `AppTheme` enum
3. Add a matching `ThemePalette` in the `palette` switch

---

## Clinical Disclaimer

This app is a reference tool intended for use by licensed healthcare professionals only.
All calculated doses must be independently verified against current clinical guidelines,
institutional protocols, and individual patient factors. This app does not replace
licensed clinical decision-making.

---

## Notes

- Target: iOS 17.0+ / iPadOS 17.0+
- Supported orientations: Portrait + Landscape on both iPhone and iPad
- No third-party dependencies — pure SwiftUI + UIKit PDF rendering
- Bundle ID: `com.anesthesia.calc` — change this before App Store submission
