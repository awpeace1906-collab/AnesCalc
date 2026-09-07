// AnesthesiaCalc v2.0.0
// Modified: DrugCard.swift
// Change: Expanded struct (brandName, tallManLetters, reversal); updated all 44 Excel drugs;
//         added Famotidine; added Benzodiazepine, Anticholinergic, Antiemetic, GI categories

import Foundation

// MARK: - DrugCard Model

struct DrugCard: Identifiable {
    let id = UUID()
    let name: String
    var brandName: String = ""
    let category: DrugCategory
    let mechanism: String
    let onset: String
    let duration: String
    let dosing: String
    let cautions: [String]
    let pearls: [String]
    let colorKey: String
    var tallManLetters: String = ""
    var reversal: String = ""
}

// MARK: - DrugCategory

enum DrugCategory: String, CaseIterable, Identifiable {
    case induction      = "Induction"
    case benzodiazepine = "Benzodiazepine"
    case volatile       = "Volatile"
    case nmb            = "NMB"
    case opioid         = "Opioid"
    case local          = "Local Anesthetic"
    case vasopressor    = "Vasopressor"
    case reversal       = "Reversal"
    case anticholinergic = "Anticholinergic"
    case antiemetic     = "Antiemetic"
    case gi             = "GI / Aspiration"
    case emergency      = "Emergency"
    case methBlue       = "Methylene Blue"
    case anticoagulant  = "Anticoagulant / Hemostatic"
    var id: String { rawValue }
}

// MARK: - Drug Library

struct DrugCardLibrary {
    static let all: [DrugCard] = [

        // ── IV ANESTHETICS ────────────────────────────────────────────────────
        DrugCard(
            name: "Propofol", brandName: "Diprivan",
            category: .induction,
            mechanism: "Positive allosteric GABA-A modulator; slows receptor dissociation. Rapid redistribution from CNS. Antiemetic properties at sub-hypnotic doses.",
            onset: "~40 sec (IV)",
            duration: "5–10 min (single dose); context-sensitive with infusion",
            dosing: "Induction (ASA I–II): 1–2.5 mg/kg IV\nInduction (elderly/ASA III–IV): 1 mg/kg IV\nTIVA maintenance: 6–12 mg/kg/hr\nMAC sedation: 25–75 mcg/kg/min\nSub-anesthetic antiemetic: 10–20 mcg/kg/min",
            cautions: [
                "AEs: Hypotension, apnea, bradycardia, pain on injection, PRIS (prolonged high-dose infusion >48h), hypertriglyceridemia, green urine (benign)",
                "CI: Hypersensitivity to egg or soy products (contains 10% soybean oil, 1.2% egg phosphatide)",
                "Precautions: Microbial contamination risk — strict aseptic technique; cardiac depression in elderly/hemodynamically compromised; pediatric neurotoxicity (long exposures); PRIS in ICU settings"
            ],
            pearls: [
                "Gold standard for TIVA — predictable kinetics. Antiemetic dose is sub-anesthetic and does not reliably provide sedation.",
                "Oil/water emulsion — do NOT mix with other drugs in same syringe. Context-sensitive half-time increases markedly with prolonged infusion."
            ],
            colorKey: "induction",
            tallManLetters: "PROPofol",
            reversal: "None (supportive)"),

        DrugCard(
            name: "Etomidate", brandName: "Amidate",
            category: .induction,
            mechanism: "Carboxylated imidazole; positive allosteric GABA-A modulator (β2/β3 subunit selective). Minimal cardiovascular effects — no histamine or catecholamine release.",
            onset: "~60 sec",
            duration: "3–5 min",
            dosing: "Induction (ASA I–II): 0.2–0.3 mg/kg IV\nInduction (elderly/ASA III–IV / hemodynamically compromised): 0.15–0.2 mg/kg IV",
            cautions: [
                "AEs: Myoclonus (~30%), venous pain on injection, adrenocortical suppression (6–12h), N/V, laryngospasm",
                "CI: Hypersensitivity; avoid in <10 yo or obstetrics per labeling",
                "Precautions: Single-dose only — adrenocortical suppression is a class effect; caution in sepsis (blunted stress response); hepatic impairment prolongs effect; does NOT provide analgesia"
            ],
            pearls: [
                "Hemodynamic stability hallmark — drug of choice for cardiac-compromised induction (severe LV dysfunction, AS, cardiac tamponade).",
                "NOT preferred for RSI in septic patients — cortisol suppression worsens hemodynamics in septic shock."
            ],
            colorKey: "induction",
            tallManLetters: "etomiDATE",
            reversal: "None (supportive)"),

        DrugCard(
            name: "Ketamine", brandName: "Ketalar",
            category: .induction,
            mechanism: "Non-competitive NMDA receptor antagonist → dissociative anesthesia. Also activates σ, opioid, and muscarinic receptors. Sympathomimetic via indirect catecholamine release. Bronchodilator via β-adrenergic pathway.",
            onset: "IV ~30 sec; IM 3–4 min; IN 5–10 min",
            duration: "IV 10–15 min; IM 15–25 min",
            dosing: "Induction (IV): 1–2 mg/kg\nInduction (IM): 4–6 mg/kg\nTIVA adjunct infusion: 0.1–0.5 mg/kg/hr\nSub-dissociative analgesia bolus: 0.1–0.5 mg/kg IV\nSub-dissociative infusion (OIH-sparing): 0.15 mg/kg/hr\nPediatric intranasal: 3–5 mg/kg",
            cautions: [
                "AEs: Hypertension, tachycardia, emergence reactions/hallucinations (~12%), ↑ICP, ↑IOP, ↑secretions, nystagmus; laryngeal reflexes preserved but NOT protective",
                "CI: Conditions where ↑BP is hazardous — uncontrolled severe HTN, acute CAD (relative); hypersensitivity",
                "Precautions: Pair with glycopyrrolate to reduce secretions; midazolam or dark quiet room reduces emergence reactions; OIH with prolonged high-dose infusion; pediatric neurotoxicity; GU complications with chronic use"
            ],
            pearls: [
                "Drug of choice for hemodynamically unstable induction (trauma, sepsis, hypovolemia). Bronchodilator — preferred in reactive airway disease.",
                "NMDA antagonism reduces opioid consumption and may prevent OIH. Laryngeal reflexes maintained but NOT protective — aspiration risk persists."
            ],
            colorKey: "induction",
            tallManLetters: "KETamine",
            reversal: "None (supportive)"),

        DrugCard(
            name: "Dexmedetomidine", brandName: "Precedex",
            category: .induction,
            mechanism: "Selective α₂-adrenergic agonist → inhibits NE release from locus coeruleus (sedation/anxiolysis) and dorsal horn (analgesia/sympatholysis). Produces cooperative, rousable sedation without respiratory depression.",
            onset: "~15–20 min (load); steady state ~60 min",
            duration: "Infusion-dependent; offset ~30–60 min after stopping",
            dosing: "Loading: 1 mcg/kg over 10 min (omit if hemodynamically unstable)\nMaintenance: 0.2–0.7 mcg/kg/hr (titrate to RASS/BIS)\nProcedural/awake intubation: 0.5–1 mcg/kg over 10 min load; 0.2–0.5 mcg/kg/hr maintenance",
            cautions: [
                "AEs: Bradycardia (including sinus arrest), hypotension, transient hypertension (rapid bolus), dry mouth, nausea",
                "CI: No absolute contraindications per FDA",
                "Precautions: Avoid in 2nd/3rd degree AV block, uncompensated heart failure; continuous monitoring required; tolerance/tachyphylaxis with prolonged infusion; NOT interchangeable with clonidine"
            ],
            pearls: [
                "Produces cooperative sedation — patient rousable and NOT apneic. Ideal for awake fiber-optic intubation or procedures requiring patient cooperation.",
                "Synergistic with opioids for analgesia. Load dose ARDS/resp failure with infusions >24h — associated with outcomes concerns in some ICU data."
            ],
            colorKey: "induction",
            tallManLetters: "dexMEDETomidine",
            reversal: "None (supportive — atropine for bradycardia)"),

        // ── BENZODIAZEPINES ───────────────────────────────────────────────────
        DrugCard(
            name: "Midazolam", brandName: "Versed",
            category: .benzodiazepine,
            mechanism: "Positive allosteric GABA-A modulator (benzodiazepine binding site) — augments endogenous GABA activity; does not directly activate the receptor. Anxiolysis, sedation, amnesia, anticonvulsant.",
            onset: "IV 2–3 min; IM 5–15 min; IN 5–10 min; PO 15–30 min",
            duration: "IV 45–60 min",
            dosing: "Premedication adult: 0.5 mg/kg IV (MAX 10 mg)\nPremedication peds: 0.5 mg/kg PO (MAX 15 mg)\nSedation: 0.02 mg/kg IV (MAX 5 mg); titrate 1–2 mg q2–3 min\nInduction adjunct: 0.05–0.1 mg/kg IV\nAnticonvulsant: 0.1 mg/kg IV (MAX 10 mg)\nICU infusion: 0.02–0.1 mg/kg/hr",
            cautions: [
                "AEs: Respiratory depression, apnea, hypotension, paradoxical agitation (peds), retrograde amnesia, nystagmus",
                "CI: Acute narrow-angle glaucoma; hypersensitivity; premature infants; intrathecal/epidural administration",
                "Precautions: Synergistic respiratory depression with opioids — dose reduce both; paradoxical reactions (peds); withdrawal with chronic use; ↑ICP; pediatric neurotoxicity"
            ],
            pearls: [
                "Reliable amnesia — dose BEFORE painful or distressing procedures. Duration of flumazenil < duration of midazolam — resedation possible.",
                "Does NOT reverse non-BZD hypnotics (propofol, ketamine, barbiturates). Hepatic CYP3A4 metabolism — impaired in hepatic/renal failure."
            ],
            colorKey: "benzodiazepine",
            tallManLetters: "midaZOLAM",
            reversal: "Flumazenil 0.2 mg IV q1 min (MAX 1 mg)"),

        // ── VOLATILE ANESTHETICS ──────────────────────────────────────────────
        DrugCard(
            name: "Sevoflurane", brandName: "Ultane / Sojourn",
            category: .volatile,
            mechanism: "Halogenated methyl isopropyl ether. Enhances GABA-A inhibition; inhibits nACh and NMDA receptors. Low blood/gas partition coefficient (0.65) → rapid on/off.",
            onset: "Rapid — blood/gas λ = 0.63–0.69",
            duration: "Rapid offset; proportional to duration of exposure",
            dosing: "Pediatric mask induction: 6–8% in 100% O₂\nMAC (~40 yr): ~2.0%\nMAC-awake (sedation): ~0.65% (0.33× MAC)\nMAC-BAR (blunt adrenergic): ~3.2% (1.6× MAC)\nTypical maintenance: 1.5–2.5% in air/O₂",
            cautions: [
                "AEs: Laryngospasm (induction), hypotension, bradycardia, peds emergence agitation, MH susceptibility, QT prolongation, Compound A nephrotoxicity (>2 MAC·h with low-flow <1 L/min)",
                "CI: Known/suspected MH susceptibility; hypersensitivity",
                "Precautions: Pompe disease — fatal ventricular arrhythmias reported; low-flow use >1 L/min to limit Compound A; dose-dependent hypotension; pediatric neurotoxicity"
            ],
            pearls: [
                "Preferred volatile for pediatric mask induction — non-pungent, smooth. Blood/gas λ ~0.65 = fastest ether for titration. Age-corrected MAC decreases ~6%/decade after 40.",
                "Ischemic preconditioning properties reported — potentially cardioprotective."
            ],
            colorKey: "volatile",
            tallManLetters: "SEVOflurane",
            reversal: "Dantrolene 2.5 mg/kg IV if MH triggered"),

        DrugCard(
            name: "Isoflurane", brandName: "Forane",
            category: .volatile,
            mechanism: "Halogenated methyl ethyl ether. Enhances GABA-A inhibition; inhibits NMDA receptors. Intermediate blood/gas partition coefficient (1.43) → slower onset/offset than sevoflurane.",
            onset: "Slower than sevoflurane — blood/gas λ = 1.43",
            duration: "Slower offset vs. sevoflurane/desflurane",
            dosing: "MAC (~40 yr): ~1.2%\nMAC-awake: ~0.4%\nTypical maintenance: 1.0–2.0% in air/O₂",
            cautions: [
                "AEs: Pungent odor (airway irritant — not for mask induction), hypotension, arrhythmias, MH, QT prolongation, coronary steal (theoretical)",
                "CI: Known/suspected MH; hypersensitivity; prior halogenated anesthetic-induced hepatitis",
                "Precautions: Perioperative hyperkalemia; hepatic reactions (rare); ↑blood loss in uterine procedures; pediatric neurotoxicity"
            ],
            pearls: [
                "Lower cost than sevoflurane/desflurane — economical for long cases where emergence speed is less critical.",
                "Coronary steal phenomenon — largely theoretical at clinical doses but controversial in severe fixed-stenosis CAD. Not used for induction (pungent)."
            ],
            colorKey: "volatile",
            tallManLetters: "ISOFlurane",
            reversal: "Dantrolene 2.5 mg/kg IV if MH triggered"),

        DrugCard(
            name: "Desflurane", brandName: "Suprane",
            category: .volatile,
            mechanism: "Halogenated methyl ethyl ether. Ultra-low blood/gas partition coefficient (0.42) → fastest onset/offset of all clinical volatiles. Requires heated, pressurized vaporizer (BP = 22.8°C).",
            onset: "Very rapid — blood/gas λ = 0.42",
            duration: "Fastest offset of clinical volatiles; true context-insensitive half-time",
            dosing: "MAC (~40 yr): ~6.0–7.3%\nTypical maintenance: 4–8% in air/O₂\nNOT for inhalation induction — severe airway irritant",
            cautions: [
                "AEs: Airway irritation (cough, laryngospasm — NOT for mask induction), sympathetic stimulation at >1.5 MAC (↑HR, ↑BP), pungent odor, MH susceptibility",
                "CI: Known/suspected MH; hypersensitivity; mask induction",
                "Precautions: Requires HEATED, PRESSURIZED vaporizer (BP 22.8°C — would vaporize at room temperature in standard vaporizer); high global warming potential — many programs phasing out"
            ],
            pearls: [
                "Fastest emergence after long cases (>4h) — context-insensitive half-time stays predictable regardless of infusion duration.",
                "Minimal hepatic metabolism (<0.02%) — lowest of all volatiles; ideal in hepatic disease. Environmental impact significant — GWP ~2500× CO₂."
            ],
            colorKey: "volatile",
            tallManLetters: "DESFlurane",
            reversal: "Dantrolene 2.5 mg/kg IV if MH triggered"),

        DrugCard(
            name: "Nitrous Oxide", brandName: "N₂O",
            category: .volatile,
            mechanism: "Inorganic gaseous anesthetic. Non-competitive NMDA antagonist; minimal GABA-A effect; endogenous opioid release (midbrain). Oil/gas λ ~1.4 — inherently weak anesthetic (MAC 104% at 40 yr).",
            onset: "Very rapid — blood/gas λ = 0.47",
            duration: "Rapid offset; diffusion hypoxia risk on emergence (give 100% O₂ for 5 min)",
            dosing: "Co-induction adjunct: 50–70% with O₂ + volatile\nGA adjunct (MAC-sparing): 50–70% with O₂\nLabor analgesia: 50% N₂O / 50% O₂\nProcedural sedation: 25–50% with O₂",
            cautions: [
                "AEs: PONV (↑ vs. air), diffusion hypoxia on emergence, expansion of gas-containing spaces, inactivates vitamin B12/methionine synthase (prolonged use)",
                "CI: Pneumothorax, bowel obstruction, pneumocephalus, middle ear surgery, vitamin B12 deficiency, prolonged use (homocystinuria risk)",
                "Precautions: MAC = 104% at age 40 — cannot produce surgical anesthesia at 1 atm alone; second gas effect accelerates uptake of co-administered volatile; PONV risk — avoid in high-risk patients"
            ],
            pearls: [
                "Halves MAC of volatile agent when combined 50:50. Classic teaching: NOT safe in any closed gas space (pneumothorax, ileus, pneumocephalus).",
                "Diffusion hypoxia on emergence — always administer 100% O₂ for ≥5 min when discontinuing N₂O."
            ],
            colorKey: "volatile",
            tallManLetters: "nitrous OXIDE",
            reversal: "100% O₂ for diffusion hypoxia"),

        // ── OPIOIDS ───────────────────────────────────────────────────────────
        DrugCard(
            name: "Fentanyl", brandName: "Sublimaze",
            category: .opioid,
            mechanism: "Synthetic μ-opioid receptor agonist. ~100× more potent than morphine. Highly lipophilic — rapid CNS penetration. Context-sensitive half-time increases significantly with prolonged infusion.",
            onset: "IV 1–2 min; IT 5–10 min; IN 5–15 min",
            duration: "IV 30–60 min (single dose); CSHT increases markedly with infusions >2h",
            dosing: "Induction adjunct: 1–3 mcg/kg IV (slow push)\nIntraoperative infusion: 1–3 mcg/kg/hr\nIntrathecal: 10–25 mcg\nEpidural: 50–100 mcg\nIN procedural sedation: 1.5–2 mcg/kg",
            cautions: [
                "AEs: Respiratory depression, chest wall rigidity (high/rapid dose), bradycardia, N/V, pruritus (neuraxial), CSHT increases with prolonged infusion",
                "CI: Significant respiratory depression in unmonitored setting; acute/severe asthma without resuscitation equipment; GI obstruction; hypersensitivity",
                "Precautions: Serotonin syndrome with MAOIs/serotonergic agents; ↑ICP via CO₂ retention; CYP3A4 inhibitors ↑ effect; hepatic impairment; dose ↓ in elderly/cachectic"
            ],
            pearls: [
                "Workhorse of intraoperative analgesia — no histamine release unlike morphine. 100× more potent than morphine IV.",
                "Chest wall rigidity with rapid high-dose push — treat with NMB. Fentanyl patch NOT for acute pain (not an OR drug)."
            ],
            colorKey: "opioid",
            tallManLetters: "FENTanyl",
            reversal: "Naloxone 1 mcg/kg IV q2–3 min (partial); 10 mcg/kg (full reversal)"),

        DrugCard(
            name: "Morphine", brandName: "Duramorph (neuraxial)",
            category: .opioid,
            mechanism: "Full μ-opioid receptor agonist (naturally occurring phenanthrene alkaloid). ↓adenylyl cyclase → ↓cAMP, ↓Ca²⁺ channels, ↑K⁺ channels. No ceiling for analgesia.",
            onset: "IV 5–10 min; IT 15–60 min (delayed peak); PO 30–60 min",
            duration: "IV 3–4h; IT 12–24h (slow CSF rostral spread — delayed respiratory depression risk)",
            dosing: "IV analgesia: 0.05–0.1 mg/kg IV q3–4h; titrate to effect\nIntrathecal: 100–300 mcg (C/S postop: 100–200 mcg)\nEpidural: 2–4 mg lumbar\nPCA: 1 mg bolus, 6–10 min lockout\nOral: 0.2–0.5 mg/kg q4h (PO:IV ratio ~3:1)",
            cautions: [
                "AEs: Histamine release (urticaria, bronchospasm, hypotension — not true allergy), pruritus (neuraxial), N/V, respiratory depression, constipation",
                "CI: Significant respiratory depression; acute/severe asthma; MAOIs within 14 days; GI obstruction; hypersensitivity",
                "Precautions: M6G (active metabolite) accumulates in renal failure → prolonged respiratory depression; delayed respiratory depression with neuraxial use (up to 12–24h); adrenal insufficiency"
            ],
            pearls: [
                "Gold standard reference opioid. Histamine release is NOT a true allergy — most 'morphine allergy' is intolerance. PO:IV ratio ~3:1.",
                "IT morphine for C/S — landmark neuraxial technique: 100–200 mcg = 12–24h analgesia. Monitor for delayed respiratory depression."
            ],
            colorKey: "opioid",
            tallManLetters: "MORPhine",
            reversal: "Naloxone 1–10 mcg/kg IV"),

        DrugCard(
            name: "Hydromorphone", brandName: "Dilaudid",
            category: .opioid,
            mechanism: "Semisynthetic full μ-opioid agonist (morphine derivative). ~5–8.5× more potent than morphine. Mechanism analogous to morphine. No histamine release — advantage over morphine.",
            onset: "IV 5–10 min",
            duration: "IV 3–4h",
            dosing: "IV: 0.015 mg/kg; titrate 0.2–0.4 mg increments\nPCA: 0.2 mg bolus, 6–10 min lockout\nEpidural: 0.5–1.5 mg lumbar\nOral: 2–4 mg q4h (PO:IV ratio ~5:1)",
            cautions: [
                "AEs: Respiratory depression, H3G-mediated neuroexcitatory effects (myoclonus, agitation, cognitive impairment) in renal failure",
                "CI: Significant respiratory depression; acute asthma without resuscitative equipment; GI obstruction; hypersensitivity",
                "Precautions: H3G (hydromorphone-3-glucuronide) accumulates in renal impairment — switch to alternative in ESRD; high potency — dose carefully; H3G neuroexcitatory toxicity does NOT respond to naloxone"
            ],
            pearls: [
                "~5× more potent PO, ~8.5× IV vs. morphine. No histamine release — preferred in morphine-intolerant patients. PO:IV ratio ~5:1.",
                "H3G does NOT respond to naloxone — neuroexcitatory toxicity requires supportive care (not reversible with opioid antagonist)."
            ],
            colorKey: "opioid",
            tallManLetters: "HYDROmorphone",
            reversal: "Naloxone 1–10 mcg/kg IV (does NOT reverse H3G toxicity)"),

        DrugCard(
            name: "Remifentanil", brandName: "Ultiva",
            category: .opioid,
            mechanism: "Ultra-short-acting synthetic μ-opioid agonist. Ester linkage cleaved by nonspecific blood/tissue esterases — context-insensitive half-time ~3–4 min regardless of infusion duration.",
            onset: "~1 min",
            duration: "3–5 min (context-insensitive — constant regardless of infusion length)",
            dosing: "TIVA infusion: 0.05–0.3 mcg/kg/min (use LBW in obese)\nBolus for laryngoscopy: 0.5–1 mcg/kg\nNeurosurgery/neuromonitoring: 0.1–0.4 mcg/kg/min\nICU analgesia: 0.05–0.2 mcg/kg/min",
            cautions: [
                "AEs: Profound respiratory depression/apnea, bradycardia, hypotension, skeletal muscle rigidity (dose-related), OIH with prolonged high-dose infusion",
                "CI: Epidural/intrathecal use (glycine diluent is neurotoxic); hypersensitivity",
                "Precautions: NO residual analgesia after stopping — MUST bridge with alternative analgesic before emergence; OIH risk with prolonged high-dose; do NOT administer through same IV line as blood products"
            ],
            pearls: [
                "Only opioid with truly context-insensitive half-time — ideal for neuroanesthesia and cases requiring rapid, precise titration.",
                "Analgesic cliff at end of case — plan bridge analgesia (LA infiltration, ketorolac, acetaminophen, longer-acting opioid) BEFORE stopping infusion."
            ],
            colorKey: "opioid",
            tallManLetters: "remifeNTAnil",
            reversal: "Naloxone (abrupt reversal causes acute pain crisis — avoid unless emergency); supportive care"),

        DrugCard(
            name: "Methadone", brandName: "Dolophine / Methadose",
            category: .opioid,
            mechanism: "Full μ-opioid agonist + NMDA receptor antagonist (↓opioid tolerance) + SNRI activity (neuropathic analgesia). Uniquely active at multiple receptor classes — favored for complex pain states.",
            onset: "PO 30–60 min",
            duration: "24–36h (long t½; peak respiratory depression occurs LATER and LONGER than analgesia)",
            dosing: "OUD maintenance: Initial 20–30 mg PO daily (MAX 40 mg day 1); titrate 5–10 mg q3–5 days; maintenance ≥80 mg (≥100 mg for fentanyl users)\nChronic pain (opioid-naive): 2.5 mg q8h; titrate ≤5 mg/day q5–7 days\nOpioid rotation: Use 75–90% less than calculated equianalgesic dose",
            cautions: [
                "AEs: QTc prolongation (23% incidence), respiratory depression (delayed peak), serotonin syndrome, severe hypotension, OIH, adrenal insufficiency",
                "CI: Significant respiratory depression; acute asthma; GI obstruction; hypersensitivity",
                "Precautions: Incomplete cross-tolerance — start LOW when converting from other opioids; QTc monitoring (baseline ECG + serial); extensive CYP450 interactions; NOWS risk; benzodiazepine combination high-risk; titrate no more frequently than q5–7 days"
            ],
            pearls: [
                "NMDA antagonism makes it uniquely valuable for neuropathic pain and OIH prevention. QTc risk is real — baseline and serial ECGs with high doses or combination therapy.",
                "Long t½ makes titration challenging — respiratory depression peak occurs AFTER analgesic peak. Titration interval ≥5–7 days."
            ],
            colorKey: "opioid",
            tallManLetters: "METHadone",
            reversal: "Naloxone (titrate carefully — short duration vs. methadone; repeat dosing or infusion required)"),

        DrugCard(
            name: "Meperidine", brandName: "Demerol",
            category: .opioid,
            mechanism: "Synthetic μ-opioid agonist + κ-agonist (antishivering) + serotonin reuptake inhibition + Na⁺ channel block (local anesthetic activity). Structurally related to local anesthetics.",
            onset: "IV 1–5 min; IM 10–15 min",
            duration: "2–4h",
            dosing: "Acute pain (adult): PO/IM 50–150 mg q3–4h\nAcute pain (peds): 1.1–1.76 mg/kg IM/SC q3–4h (MAX 100 mg per dose)\nPreop: IM 50–100 mg adult; 1.1–2.2 mg/kg peds (30–90 min prior)\nPostop shivering: 25 mg IV; repeat PRN\nIntrathecal adjuvant: 0.05–0.5 mg/kg single dose",
            cautions: [
                "AEs: Normeperidine neurotoxicity (tremor → myoclonus → seizures — NOT reversed by naloxone), serotonin syndrome (with MAOIs/serotonergics), respiratory depression, histamine release",
                "CI: MAOI use or within 14 days; significant respiratory depression; GI obstruction; hypersensitivity",
                "Precautions: Normeperidine accumulates with repeat dosing or renal impairment — limit to single-dose or short course; seizure risk NOT reversed by naloxone (may worsen); ISMP high-alert medication"
            ],
            pearls: [
                "The ONLY opioid with reliable antishivering properties (κ-receptor, 25 mg IV). Structurally related to LAs — Na⁺ channel block useful for IT adjuvant.",
                "Largely fallen out of favor for pain management due to normeperidine toxicity; still used for postop shivering and IT adjuvant. Normeperidine t½ = 15–30h — accumulates with repeat dosing."
            ],
            colorKey: "opioid",
            tallManLetters: "mePERIdine",
            reversal: "Naloxone for respiratory depression ONLY — does NOT reverse normeperidine neurotoxicity"),

        // ── NMB ───────────────────────────────────────────────────────────────
        DrugCard(
            name: "Succinylcholine", brandName: "Anectine / Quelicin",
            category: .nmb,
            mechanism: "Depolarizing NMB — structural ACh analog binds nicotinic NMJ receptor causing sustained depolarization (Phase I block). Fasciculations reflect initial unsynchronized depolarization. Metabolized by plasma (pseudo)cholinesterase.",
            onset: "IV ~45–60 sec; IM 3–4 min",
            duration: "IV ~10–12 min (plasma cholinesterase-dependent); prolonged in pseudocholinesterase deficiency",
            dosing: "RSI adult: 1.5 mg/kg IV\nRSI peds: 2 mg/kg IV (↑ volume of distribution)\nIM emergency (peds): 4 mg/kg (MAX 150 mg total, regardless of weight)\nDefasciculation (pretreatment): non-depolarizing NMB at 10% of intubating dose, 3 min before",
            cautions: [
                "AEs: Hyperkalemia (CRITICAL: burns >48h, crush injury, denervation, prolonged immobility, UMN lesion), bradycardia (peds repeat dosing), ↑ICP, ↑IOP, ↑intragastric pressure, fasciculations, myalgia, MH susceptibility, cardiac arrest",
                "CI: Life-threatening hyperkalemia risk (burns >48h after injury, crush, denervation, prolonged immobility, UMN lesion); skeletal muscle myopathies; known/suspected MH; pseudocholinesterase deficiency (relative); hypersensitivity",
                "Precautions: Normal K⁺ rises ~0.5 mEq/L (safe in healthy patients); dibucaine number identifies pseudocholinesterase deficiency; defasciculation does not eliminate ↑K⁺; peds — consider rocuronium + sugammadex if unknown myopathy"
            ],
            pearls: [
                "Fastest onset NMB — gold standard for RSI when can't-intubate/can't-ventilate scenario is feared and succinylcholine not contraindicated.",
                "HIGH-ALERT medication — ASTM fluorescent red label. Dibucaine number: normal >70; heterozygous ~60; homozygous ~20 (prolonged block). Rocuronium 1.2 mg/kg + sugammadex 16 mg/kg is a validated alternative when contraindicated."
            ],
            colorKey: "nmb",
            tallManLetters: "SUCCINYLcholine",
            reversal: "No pharmacologic reversal. Supportive. Dantrolene for MH. FFP for pseudocholinesterase deficiency."),

        DrugCard(
            name: "Rocuronium", brandName: "Zemuron",
            category: .nmb,
            mechanism: "Aminosteroid non-depolarizing NMB. Competitive ACh antagonist at nicotinic NMJ receptors. Modified structure provides faster onset than vecuronium without cardiovascular side effects.",
            onset: "0.6 mg/kg: ~90 sec; 1.2 mg/kg: ~60 sec",
            duration: "0.6 mg/kg: 30–60 min; 1.2 mg/kg: 60–90 min (dose-dependent, hepatically prolonged)",
            dosing: "Standard intubation: 0.6 mg/kg IV\nRSI equivalent: 1.2–1.3 mg/kg IV (~60 sec onset)\nMaintenance bolus: 0.1–0.2 mg/kg\nMaintenance infusion: 5–12 mcg/kg/min",
            cautions: [
                "AEs: Most common NMB implicated in anaphylaxis (IgE-mediated); transient hypotension/hypertension; tachycardia; residual paralysis → postop pulmonary complications",
                "CI: Hypersensitivity (including rocuronium-sugammadex complex hypersensitivity)",
                "Precautions: Duration extended by volatile anesthetics, aminoglycosides, magnesium, hypothermia; hepatic dysfunction prolongs duration; always confirm TOF ratio >0.9 before extubation"
            ],
            pearls: [
                "Most commonly used NMB in modern anesthesia. At 1.2 mg/kg: onset comparable to succinylcholine — preferred when succinylcholine contraindicated + sugammadex available.",
                "Sugammadex completely reverses even profound rocuronium block. NOT reversed by neostigmine at deep block levels."
            ],
            colorKey: "nmb",
            tallManLetters: "ROCUronium",
            reversal: "Sugammadex 2 mg/kg (TOF ≥T2), 4 mg/kg (deep/PTC 1–2), 16 mg/kg (immediate post-RSI reversal)"),

        DrugCard(
            name: "Vecuronium", brandName: "Norcuron",
            category: .nmb,
            mechanism: "Aminosteroid non-depolarizing NMB. Competitive ACh antagonist at nicotinic NMJ receptors. Intermediate duration; no cardiovascular side effects or histamine release at clinical doses.",
            onset: "3–5 min",
            duration: "25–40 min (prolonged in renal/hepatic failure)",
            dosing: "Intubation: 0.1 mg/kg IV\nMaintenance: 0.01–0.015 mg/kg q20–30 min\nInfusion: 1–2 mcg/kg/min",
            cautions: [
                "AEs: Prolonged block in renal/hepatic failure; ICU myopathy (neuromyopathy of critical illness) with prolonged infusion; residual block",
                "CI: Hypersensitivity",
                "Precautions: Active metabolite 3-OH vecuronium (80% potency) accumulates in renal failure → prolonged weakness; duration extended by volatiles, aminoglycosides, magnesium, hypothermia; TOF monitoring mandatory"
            ],
            pearls: [
                "No cardiovascular effects — no histamine release, no vagolysis at clinical doses. Largely displaced by rocuronium in modern practice.",
                "ICU use associated with ICU myopathy — avoid prolonged infusions. Sugammadex preferred reversal over neostigmine."
            ],
            colorKey: "nmb",
            tallManLetters: "VECUronium",
            reversal: "Sugammadex (preferred); Neostigmine 0.07 mg/kg (MAX 5 mg) — only at TOF ≥T4"),

        DrugCard(
            name: "Cisatracurium", brandName: "Nimbex",
            category: .nmb,
            mechanism: "Benzylisoquinolinium non-depolarizing NMB. Competitive cholinergic antagonist at NMJ. Hofmann elimination — spontaneous, organ-independent degradation (temperature and pH dependent).",
            onset: "~3–5 min",
            duration: "~45–60 min",
            dosing: "Intubation: 0.15–0.2 mg/kg IV\nMaintenance bolus: 0.03 mg/kg q20 min\nMaintenance infusion: 1–3 mcg/kg/min",
            cautions: [
                "AEs: Minimal histamine release at clinical doses; laudanosine CNS stimulation with high doses/prolonged infusion; residual block",
                "CI: Hypersensitivity; 10 mL multidose vials contraindicated in <1 month or low birth-weight infants (benzyl alcohol preservative)",
                "Precautions: Laudanosine accumulates with prolonged high-dose infusion; Hofmann elimination slows in hypothermia or acidosis; does NOT respond to sugammadex"
            ],
            pearls: [
                "Drug of choice in severe hepatic/renal failure — organ-independent metabolism. Preferred ICU NMB for ARDS (ACURASYS trial).",
                "Does NOT respond to sugammadex — plan reversal with neostigmine accordingly. Benzylisoquinolinium class — not an aminosteroid."
            ],
            colorKey: "nmb",
            tallManLetters: "cisATRacurium",
            reversal: "Neostigmine 0.07 mg/kg (MAX 5 mg) at TOF ≥T4 — NO sugammadex efficacy"),

        // ── REVERSAL ──────────────────────────────────────────────────────────
        DrugCard(
            name: "Sugammadex", brandName: "Bridion",
            category: .reversal,
            mechanism: "Modified γ-cyclodextrin. Forms tight 1:1 encapsulation complex with rocuronium or vecuronium, removing them from the NMJ. No anticholinergic or cholinergic effects — works independently of AChE.",
            onset: "3–5 min (routine); ~3 min (high dose 16 mg/kg)",
            duration: "Sustained — complex is renally excreted intact",
            dosing: "Routine reversal (TOF ≥T2): 2 mg/kg IV\nDeep block (T1 or PTC 1–2): 4 mg/kg IV\nImmediate reversal after RSI-dose rocuronium 1.2 mg/kg: 16 mg/kg IV\nAll doses based on actual body weight",
            cautions: [
                "AEs: Hypersensitivity/anaphylaxis (rare but serious); progesterone-based contraceptive interference (advise alternative for 7 days post-dose); bradycardia (rare)",
                "CI: Hypersensitivity (severe cases including anaphylaxis reported)",
                "Precautions: Severe renal impairment — complex accumulates; only reverses aminosteroid NMBs (rocuronium, vecuronium) — NO efficacy vs. cisatracurium or succinylcholine; re-intubation within 24h — rocuronium still works (may need higher dose)"
            ],
            pearls: [
                "Game-changer for NMB reversal — reverses even profound block in 3–5 min. Confirm TOF ratio >0.9 after reversal.",
                "ASTM white-stripe reversal label. Female patients — advise barrier contraception for 7 days (progesterone binding). 16 mg/kg reverses 1.2 mg/kg rocuronium within 3 min of administration."
            ],
            colorKey: "reversal",
            tallManLetters: "sugaMMAdex",
            reversal: "N/A — is itself the reversal agent"),

        DrugCard(
            name: "Neostigmine", brandName: "Prostigmin / Bloxiverz",
            category: .reversal,
            mechanism: "Reversible acetylcholinesterase (AChE) inhibitor → ↑ACh at NMJ → competes with residual non-depolarizing NMB. Also ↑muscarinic activity — requires anticholinergic co-administration.",
            onset: "7–10 min (full reversal may take 15–20 min)",
            duration: "~60–90 min (shorter than most NMBs — watch for recurarization if used too early)",
            dosing: "Standard reversal: 0.07 mg/kg IV (MAX 5 mg)\nMust pair with glycopyrrolate 0.01 mg/kg (preferred) or atropine 0.02 mg/kg",
            cautions: [
                "AEs: Bradycardia, ↑GI motility (N/V, cramping), bronchospasm, cholinergic crisis if overdosed (excess secretions, bradycardia, bronchospasm)",
                "CI: Hypersensitivity; peritonitis or mechanical GI/GU obstruction; cholinergic crisis risk",
                "Precautions: CONFIRM adequate spontaneous recovery (TOF ≥T4) before administration — will NOT effectively reverse deep block and can paradoxically worsen reversal quality at high ACh; confirm TOF ratio >0.9 before extubation; does NOT reverse succinylcholine"
            ],
            pearls: [
                "Always pair with anticholinergic — glycopyrrolate preferred (slower onset matches neostigmine; less tachycardia; no BBB crossing → no CNS effects).",
                "ASTM white-stripe reversal label. TOF ≥T4 minimum — neostigmine at deeper block can worsen reversal quality via depolarization block at high ACh levels."
            ],
            colorKey: "reversal",
            tallManLetters: "NEOstigmine",
            reversal: "N/A — is itself the reversal agent"),

        DrugCard(
            name: "Naloxone", brandName: "Narcan",
            category: .reversal,
            mechanism: "Competitive opioid receptor antagonist (μ, κ, δ). Competitive displacement of opioids from receptors → reverses analgesia, sedation, and respiratory depression.",
            onset: "IV 1–2 min; IM/IN 5–10 min",
            duration: "30–90 min (SHORTER than most opioids — renarcotization risk)",
            dosing: "Partial reversal (periop — preserve analgesia): 1 mcg/kg IV q2–3 min; titrate to respirations\nFull reversal (emergency): 10 mcg/kg IV (0.4 mg adult); titrate to respirations\nRenarcotization prevention infusion: ⅔ of effective reversal dose per hour\nIM/SC community OD: 0.4 mg; repeat in 2–3 min PRN",
            cautions: [
                "AEs: Acute pain (reverses analgesia — distressing), sympathetic storm (hypertension, tachycardia, pulmonary edema, cardiac arrest) with rapid full reversal; precipitated withdrawal in opioid-dependent patients; neonatal seizures with rapid reversal",
                "CI: Hypersensitivity",
                "Precautions: Duration SHORTER than most opioids — renarcotization risk; infusion often required for long-acting opioids; titrate carefully in opioid-dependent patients (precipitated withdrawal)"
            ],
            pearls: [
                "Titrate in periop setting — avoid full reversal (abrupt pain crisis + sympathetic storm). Use infusion for long-acting opioids (methadone, IT morphine).",
                "ASTM blue + white stripe reversal/antagonist label. In-hospital: titrate to respiratory rate, NOT full consciousness. 0.4 mg IM standard for community opioid OD."
            ],
            colorKey: "reversal",
            tallManLetters: "nalOXone",
            reversal: "N/A — is itself the reversal agent"),

        DrugCard(
            name: "Flumazenil", brandName: "Romazicon",
            category: .reversal,
            mechanism: "Competitive benzodiazepine receptor antagonist at GABA-A BZD binding site → reverses BZD sedation, anxiolysis, and amnesia. Does NOT reverse non-BZD hypnotics.",
            onset: "1–2 min",
            duration: "30–60 min (SHORTER than most BZDs — resedation very likely)",
            dosing: "Standard adult: 0.2 mg IV q1 min (MAX 1 mg total)\nPediatric: 0.01 mg/kg IV q1 min (MAX 0.05 mg/kg or 1 mg)\nResedation prevention infusion: 0.1–0.5 mg/hr",
            cautions: [
                "AEs: Acute BZD withdrawal in chronic users (tachycardia, hypertension, SEIZURES); resedation (common — duration shorter than most BZDs); anxiety, agitation",
                "CI: Seizure disorders controlled by BZDs; patients on BZDs for seizure prophylaxis; hypersensitivity",
                "Precautions: Lowers seizure threshold; resedation common — monitor 60–120 min after administration; does NOT reverse propofol, ketamine, barbiturates, or alcohol"
            ],
            pearls: [
                "Does NOT reverse propofol, ketamine, or barbiturate sedation — a common and dangerous misunderstanding.",
                "ASTM orange + white stripe antagonist label. BZD-dependent patients: reversal precipitates acute withdrawal seizures — use extreme caution. Infusion often needed for long-acting BZDs."
            ],
            colorKey: "reversal",
            tallManLetters: "fluMAZenil",
            reversal: "N/A — is itself the reversal agent"),

        // ── ANTICHOLINERGICS ──────────────────────────────────────────────────
        DrugCard(
            name: "Glycopyrrolate", brandName: "Robinul",
            category: .anticholinergic,
            mechanism: "Quaternary ammonium competitive muscarinic antagonist. Does NOT cross the blood-brain barrier — no CNS effects. Preferred for neostigmine pairing (slower onset matches neostigmine kinetics).",
            onset: "IV 1 min; IM 15–30 min",
            duration: "2–4h (longer than atropine)",
            dosing: "With neostigmine: 0.01 mg/kg IV (MAX 1 mg) simultaneously\nAnti-sialagogue (pre-ketamine): 0.005–0.01 mg/kg IV\nBradycardia treatment: 0.1–0.2 mg IV PRN adult\nPeds anti-sialagogue: 0.005 mg/kg IV (MAX 0.2 mg)",
            cautions: [
                "AEs: Tachycardia (avoid in AF or tachyarrhythmia), urinary retention, constipation, secretion drying, blurred vision",
                "CI: Hypersensitivity; glaucoma; obstructive uropathy; GI obstruction; GI motility disorders; bleeding GI ulcer; myasthenia gravis; unstable cardiovascular status in acute hemorrhage",
                "Precautions: Renal impairment — reduced excretion; prostatic hypertrophy; hepatic disease; autonomic neuropathy; geriatric patients (preferred over atropine — no CNS effects)"
            ],
            pearls: [
                "PREFERRED anticholinergic for neostigmine pairing — slower onset matches neostigmine; less tachycardia than atropine; no BBB crossing → no CNS effects.",
                "Anti-sialagogue for ketamine — give IV 5 min before or IM 15–20 min before ketamine administration."
            ],
            colorKey: "anticholinergic",
            tallManLetters: "glycoPYRRolate",
            reversal: "Physostigmine for severe anticholinergic toxicity"),

        DrugCard(
            name: "Atropine", brandName: "AtroPen (auto-injector)",
            category: .anticholinergic,
            mechanism: "Non-selective competitive muscarinic antagonist (M1, M2, M3). Tertiary amine — crosses the blood-brain barrier (CNS effects possible at high doses). Preferred for sinus bradycardia (fastest IV onset).",
            onset: "IV 1–2 min; IM 5–15 min",
            duration: "2–3h",
            dosing: "Adult bradycardia: 0.5–1 mg IV (MAX 3 mg total)\nPeds bradycardia: 0.02 mg/kg IV (MIN 0.1 mg, MAX 0.5 mg)\nPre-induction anti-sialagogue: 0.01 mg/kg IV or 0.02 mg/kg IM\nWith neostigmine: 0.02 mg/kg IV\nACLS: 1 mg IV q3–5 min (MAX 3 mg)",
            cautions: [
                "AEs: Tachycardia (avoid in AMI, HOCM, tachyarrhythmia), urinary retention, constipation, CNS toxicity at high doses (confusion, hallucinations, hyperthermia — crosses BBB), blurred vision, dry mouth",
                "CI: Hypersensitivity; narrow-angle glaucoma; obstructive uropathy; pyloric stenosis; BPH (relative)",
                "Precautions: Paradoxical bradycardia with sub-threshold doses — DO NOT give <0.1 mg (peds) or <0.5 mg (adults); may precipitate acute glaucoma; use glycopyrrolate preferentially for neostigmine pairing"
            ],
            pearls: [
                "Crosses BBB → CNS toxicity ('atropine psychosis') at high doses. Preferred over glycopyrrolate for sinus node bradycardia (faster onset IV) and ACLS.",
                "Paradoxical bradycardia occurs with sub-minimum doses (central vagal stimulation) — dose thresholds are absolute minimums, not suggestions."
            ],
            colorKey: "anticholinergic",
            tallManLetters: "ATROPine",
            reversal: "Physostigmine for severe atropine toxicity"),

        // ── ANTIEMETICS ───────────────────────────────────────────────────────
        DrugCard(
            name: "Ondansetron", brandName: "Zofran",
            category: .antiemetic,
            mechanism: "5-HT₃ serotonin receptor antagonist. Blocks 5-HT₃ receptors on vagal afferents in GI tract and at the chemoreceptor trigger zone (CTZ). Does not affect dopamine receptors.",
            onset: "IV 5–15 min",
            duration: "4–6h",
            dosing: "Adult PONV prophylaxis: 4 mg IV at end of case\nPeds PONV prophylaxis: 0.1 mg/kg IV at end of case (MAX 4 mg)\nPONV rescue: 1 mg IV\nOral preop: 8 mg PO",
            cautions: [
                "AEs: Headache, QTc prolongation (dose-dependent), constipation, serotonin syndrome (with serotonergic agents), mild LFT elevations",
                "CI: Hypersensitivity; concomitant apomorphine; congenital long QT syndrome",
                "Precautions: QTc monitoring in high-risk patients; serotonin syndrome risk with MAOIs/serotonergics; hepatic impairment ↓ clearance; phenylketonuria (ODT tablet contains phenylalanine)"
            ],
            pearls: [
                "First-line PONV prophylaxis per SAMBA/ASPIRE guidelines. 4 mg IV at END of case = optimal timing. PONV rescue dose is 1 mg, not a full 4 mg repeat.",
                "Class effect with other 5-HT₃ antagonists. Palonosetron has longer duration — may be preferred in high-risk PONV patients."
            ],
            colorKey: "antiemetic",
            tallManLetters: "ondanSETRON",
            reversal: "None"),

        DrugCard(
            name: "Droperidol", brandName: "Inapsine",
            category: .antiemetic,
            mechanism: "Butyrophenone D₂ dopamine receptor antagonist at the chemoreceptor trigger zone (CTZ) → antiemetic. Also α₁ blockade → vasodilation/hypotension.",
            onset: "3–10 min",
            duration: "3–6h",
            dosing: "Adult PONV prophylaxis: 0.625–1.25 mg IV at end of case\nPeds PONV prophylaxis: 0.01–0.015 mg/kg IV (MAX 1.25 mg)\nPONV rescue: 0.625 mg IV",
            cautions: [
                "AEs: QTc prolongation (FDA BLACK BOX WARNING — 12-lead ECG monitoring required), extrapyramidal symptoms (dystonia, akathisia), neuroleptic malignant syndrome (rare), hypotension",
                "CI: Hypersensitivity; known/suspected QT prolongation; Parkinson's disease; pheochromocytoma",
                "Precautions: Black Box for QTc — controversial at low antiemetic doses (risk comparable to ondansetron 4 mg); Class I/III antiarrhythmics; hypokalemia/hypomagnesemia; age >65; NMS monitoring"
            ],
            pearls: [
                "Highly effective at low antiemetic doses (0.625 mg) despite the 2001 FDA Black Box (which is widely considered excessive for antiemetic dosing by experts).",
                "Combined with ondansetron for multimodal PONV prophylaxis in high-risk patients. Still considered a standard component of PONV prevention protocols at many institutions."
            ],
            colorKey: "antiemetic",
            tallManLetters: "DROPeridol",
            reversal: "Diphenhydramine or benztropine for EPS; supportive for NMS"),

        // ── VASOPRESSORS ──────────────────────────────────────────────────────
        DrugCard(
            name: "Epinephrine", brandName: "Adrenalin / EpiPen",
            category: .vasopressor,
            mechanism: "Endogenous catecholamine — non-selective α and β agonist. Dose-dependent: low doses (≤0.05 mcg/kg/min) → β dominance (inotropy, ↑HR, bronchodilation); high doses → α dominance (vasoconstriction).",
            onset: "IV immediate; IM 3–5 min",
            duration: "Infusion-dependent; bolus 5–10 min; t½ ~2 min",
            dosing: "Cardiac arrest (ACLS): 1 mg IV/IO q3–5 min\nAnaphylaxis: 0.3–0.5 mg IM (1:1000); 0.1–0.2 mg IV (1:10,000) titrated\nVasopressor infusion: 0.01–0.5 mcg/kg/min\nBronchospasm: 0.3–0.5 mg SQ/IM; nebulized\nEpidural test dose: 15 mcg (with lidocaine) — monitors for IV injection (↑HR >20 bpm)",
            cautions: [
                "AEs: Hypertension, tachycardia, arrhythmias, myocardial ischemia, headache, anxiety, hyperglycemia, lactic acidosis (β₂ effect), tissue ischemia (extravasation)",
                "CI: No absolute contraindications in cardiac arrest/anaphylaxis; relative: organic heart disease (non-emergent), hypersensitivity",
                "Precautions: Extravasation → tissue necrosis (central line preferred for infusion); arrhythmias with halogenated anesthetics; β-blockers blunt β effects (α dominates → severe hypertension)"
            ],
            pearls: [
                "First-line for anaphylaxis — delay increases mortality; administer IM into lateral thigh. Only drug with proven ROSC benefit in cardiac arrest.",
                "Low-dose → β-dominant (inotropy, bronchodilation); high-dose → α-dominant (vasoconstriction). Tall man letters REQUIRED per ASTM: EPINEPHrine."
            ],
            colorKey: "vasopressor",
            tallManLetters: "EPINEPHrine",
            reversal: "Phentolamine 5–10 mg for extravasation or severe hypertension"),

        DrugCard(
            name: "Norepinephrine", brandName: "Levophed",
            category: .vasopressor,
            mechanism: "Endogenous catecholamine — potent α₁/α₂ vasoconstriction (↑SVR, ↑MAP) + β₁ inotropy. Minimal β₂ activity (unlike epinephrine). No ↑HR at normal doses (reflex bradycardia common).",
            onset: "~1–2 min",
            duration: "Infusion-dependent; offset ~1–2 min after stopping",
            dosing: "Vasopressor infusion: 0.01–3 mcg/kg/min (titrate to MAP ≥65 mmHg; higher doses in refractory septic shock)",
            cautions: [
                "AEs: Hypertension (overdose), reflex bradycardia, tissue ischemia (extravasation/peripheral), arrhythmias, reduced renal/mesenteric perfusion at very high doses",
                "CI: Hypovolemia as sole therapy (correct volume first); hypersensitivity; peripheral vasoconstriction in non-occlusive mesenteric ischemia",
                "Precautions: Central access preferred (extravasation → tissue necrosis); peripheral IV acceptable for up to 4h per updated evidence (Loubani et al.); monitor UO/renal perfusion"
            ],
            pearls: [
                "Gold standard vasopressor for septic shock (Surviving Sepsis Campaign 2021). Superior to dopamine in reducing arrhythmias and mortality in septic shock (De Backer NEJM 2010).",
                "Peripheral administration acceptable short-term per contemporary evidence. Correct hypovolemia first — vasopressors do not substitute for volume."
            ],
            colorKey: "vasopressor",
            tallManLetters: "norEPINEPHrine",
            reversal: "Phentolamine for extravasation; dose reduction for overdose"),

        DrugCard(
            name: "Phenylephrine", brandName: "Neosynephrine",
            category: .vasopressor,
            mechanism: "Selective synthetic α₁ agonist → vasoconstriction (↑SVR, ↑MAP). No β activity → reflex bradycardia common via baroreceptors. No direct inotropy or chronotropy.",
            onset: "~1 min",
            duration: "10–15 min (bolus)",
            dosing: "Bolus (intraop/spinal hypotension): 50–200 mcg IV\nInfusion: 0.25–1 mcg/kg/min (or 25–100 mcg/min)\nObstetric spinal prophylaxis: 0.5–1 mcg/kg/min prophylactic infusion",
            cautions: [
                "AEs: Reflex bradycardia (↑SVR with ↔/↑MAP → reflex ↓HR), reflex ↓CO with high doses, hypertension (overdose)",
                "CI: Bradycardia; severe hypovolemia; hypothyroidism (extreme sensitivity)",
                "Precautions: Pure vasoconstriction — may ↓CO if cardiac output is HR-dependent; preferred over ephedrine for C/S spinal hypotension (less fetal acidosis); treat reflex bradycardia with atropine or epinephrine"
            ],
            pearls: [
                "First-line for spinal hypotension in obstetrics per 2017 ASA/SOAP consensus — less fetal umbilical artery acidosis than ephedrine. No β-activity — does NOT treat bradycardia.",
                "Pure α₁ — avoid as sole vasopressor if low cardiac output is the etiology of hypotension. Combination phenylephrine/vasopressin infusion increasingly used in OR."
            ],
            colorKey: "vasopressor",
            tallManLetters: "PHENYLEPHrine",
            reversal: "Dose reduction; atropine for reflex bradycardia"),

        DrugCard(
            name: "Vasopressin", brandName: "Pitressin / Vasostrict",
            category: .vasopressor,
            mechanism: "Antidiuretic hormone (AVP) analog. V₁ receptor agonism → vascular smooth muscle contraction (↑SVR) via catecholamine-independent mechanism. V₂: renal collecting duct water reabsorption.",
            onset: "~1 min (IV)",
            duration: "Infusion-dependent; t½ ~10–35 min",
            dosing: "Septic shock adjunct: 0.03–0.04 units/min fixed (do NOT titrate as primary vasopressor)\nVariceal hemorrhage: 0.2–0.4 units/min infusion\nCardiac arrest (historical): 40 units IV × 1 (removed from 2020 ACLS guidelines)",
            cautions: [
                "AEs: Digital ischemia, mesenteric ischemia, coronary vasospasm (high doses), hyponatremia (V₂/ADH effect), skin/mucosal blanching, headache",
                "CI: Hypersensitivity; no firm contraindication in shock",
                "Precautions: Fixed dose for septic shock — not titrated like catecholamines; mesenteric ischemia risk — monitor GI signs; catecholamine-sparing (VASST trial 2008)"
            ],
            pearls: [
                "SSC 2021: vasopressin as second-line add-on at 0.03 units/min when norepinephrine ≥25–50 mcg/min. Fixed dose — acts as a catecholamine-sparing agent.",
                "VASST 2008: vasopressin + NE vs. NE alone — no overall mortality difference but ↓mortality in less severe sepsis. Catecholamine-independent mechanism valuable in vasoplegic states."
            ],
            colorKey: "vasopressor",
            tallManLetters: "VASOpressin",
            reversal: "None specific; dose reduction"),

        DrugCard(
            name: "Ephedrine", brandName: "(Generic)",
            category: .vasopressor,
            mechanism: "Non-catecholamine sympathomimetic — indirect (stimulates NE release from sympathetic terminals) + direct mild α/β agonism. ↑HR, ↑BP, ↑CO. Does NOT deplete catecholamines with acute use.",
            onset: "IV 1–2 min; IM 5–10 min",
            duration: "30–60 min",
            dosing: "IV bolus: 5–25 mg (titrate; start 5–10 mg)\nIM preemptive (before spinal): 25–50 mg",
            cautions: [
                "AEs: Tachycardia (direct β₁ + indirect NE release), hypertension (overdose), fetal tachycardia + umbilical artery acidosis (vs. phenylephrine in OB), tachyphylaxis with repeat dosing (NE store depletion)",
                "CI: Hyperthyroidism; severe hypertension; MAOI use; hypersensitivity",
                "Precautions: Tachyphylaxis with repeat dosing — NE stores deplete; MAOIs → hypertensive crisis; OB setting — associated with more fetal acidosis than phenylephrine"
            ],
            pearls: [
                "Preferred over phenylephrine when bradycardia accompanies hypotension (β₁ effect maintains HR and CO). Mixed α/β — useful in anesthetic-induced vasoplegia WITH myocardial depression.",
                "Tachyphylaxis more prominent than direct agonists — switch to epinephrine or norepinephrine if repeated boluses are losing effect."
            ],
            colorKey: "vasopressor",
            tallManLetters: "ePHEDrine",
            reversal: "Phentolamine for severe hypertension"),

        // ── LOCAL ANESTHETICS (EXCEL DRUGS) ───────────────────────────────────
        DrugCard(
            name: "Bupivacaine", brandName: "Marcaine / Sensorcaine",
            category: .local,
            mechanism: "Long-acting amide LA. Na⁺ channel blockade (voltage-gated, open-state preferential; slow dissociation = 'fast in, slow out'). High lipid solubility and protein binding (96%) — prolonged block. Most cardiotoxic amide.",
            onset: "Slow (high pKa 8.1 → less free base at physiologic pH). Spinal: 5 min; Epidural: 15–25 min",
            duration: "Long — IT 2–4h; epidural variable; peripheral block 8–12h (plain), 12–18h (with epi)",
            dosing: "Spinal (isobaric/hyperbaric 0.5%): 5–20 mg (dose varies by level and baricity)\nEpidural analgesia: 0.0625–0.25%; bolus 5–20 mL\nPeripheral nerve block: 0.25–0.5%; MAX 2.5 mg/kg (plain), 3 mg/kg (with epi)\nLAST prevention: stay within max dose limits; have Intralipid immediately available",
            cautions: [
                "AEs: LAST (bupivacaine most cardiotoxic amide — refractory VF, wide complex dysrhythmia), CNS toxicity (seizures), high spinal, hypotension, urinary retention, motor block",
                "CI: Hypersensitivity; IV administration (except Exparel per specific protocol); obstetric paracervical block (0.75%); 0.75% NOT for OB epidural",
                "Precautions: Narrowest therapeutic window of amide LAs — slow channel dissociation causes refractory arrhythmia; LAST risk ↑ with highly vascular sites; ultrasound guidance reduces LAST risk; HAVE INTRALIPID IMMEDIATELY AVAILABLE for all high-dose regional"
            ],
            pearls: [
                "Gold standard long-acting amide. Refractory VF in LAST is notoriously difficult to treat — immediate Intralipid 20% 1.5 mL/kg bolus + CPR. Ropivacaine has better cardiac safety profile.",
                "Differential sensory > motor block at low concentrations (0.0625–0.125%) ideal for labor epidurals. Hyperbaric 0.5% (with 8% dextrose) most common for spinal anesthesia in the US."
            ],
            colorKey: "local",
            tallManLetters: "BUPivacaine",
            reversal: "Intralipid 20% 1.5 mL/kg IV bolus (LAST); repeat PRN; ACLS"),

        DrugCard(
            name: "Ropivacaine", brandName: "Naropin",
            category: .local,
            mechanism: "Pure S-enantiomer amide LA — same mechanism as bupivacaine but stereoselective cardiac Na⁺ channel binding produces less cardiotoxicity. Intrinsic vasoconstriction (less systemic absorption than lidocaine without epi).",
            onset: "Intermediate — epidural 15–20 min; peripheral block 15–30 min",
            duration: "Epidural 4–6h; peripheral block 8–12h (concentration-dependent)",
            dosing: "Epidural analgesia: 0.1–0.2%; labor: 0.1% with opioid\nPeripheral nerve block: 0.2–0.5%; MAX 3 mg/kg (MAX ~250 mg)\nLocal infiltration: 0.2–0.5%",
            cautions: [
                "AEs: LAST (less cardiotoxic than bupivacaine but not risk-free), CNS toxicity, hypotension, motor block",
                "CI: Hypersensitivity; IV administration",
                "Precautions: Still can cause LAST — Intralipid must be available; less motor block than bupivacaine at equivalent doses (S-enantiomer selectivity); preferred over bupivacaine for high-volume nerve blocks"
            ],
            pearls: [
                "Superior cardiac safety vs. bupivacaine — preferred for high-volume nerve blocks (truncal, TAP, pecs). Provides differential sensory > motor block — preferred for labor epidurals.",
                "Intrinsic vasoconstriction: longer duration than lidocaine without needing epinephrine. Still requires LAST preparedness."
            ],
            colorKey: "local",
            tallManLetters: "ROPivacaine",
            reversal: "Intralipid 20% 1.5 mL/kg IV for LAST"),

        DrugCard(
            name: "Lidocaine", brandName: "Xylocaine",
            category: .local,
            mechanism: "Amide LA with intermediate duration. Na⁺ channel blockade — FAST dissociation (lower cardiotoxicity than bupivacaine). Also Class IB antiarrhythmic. Versatile: topical, infiltration, neuraxial, IV adjunct.",
            onset: "Fast (low pKa 7.9 — more free base at physiologic pH). Infiltration 2–5 min; epidural 10–15 min",
            duration: "Infiltration: 45–90 min (plain), 2–4h (with epi). Epidural: 60–90 min. IV systemic: short",
            dosing: "Infiltration MAX: 4.5 mg/kg plain (300 mg); 7 mg/kg with epi (500 mg)\nIV regional (Bier block): 3 mg/kg (0.5% solution)\nEpidural: 1.5–2%; 15–20 mL\nTopical airway: 4% nebulized or atomized; 4 mg/kg max\nIV adjunct infusion (opioid-sparing): 1–2 mg/kg/hr\nLaryngoscopy blunting: 1.5 mg/kg IV 90 sec before",
            cautions: [
                "AEs: LAST (CNS: perioral numbness → tinnitus → visual disturbance → seizures → cardiovascular collapse), TNS with IT use (esp. lithotomy position), cauda equina (repeated intrathecal), methemoglobinemia (high-dose topical)",
                "CI: Hypersensitivity; Wolff-Parkinson-White with AF (antiarrhythmic use); Stokes-Adams syndrome",
                "Precautions: TNS risk with IT (largely replaced by bupivacaine for spinal requiring mobility); reduce dose in hepatic failure/low CO; significant systemic absorption from topical airway application"
            ],
            pearls: [
                "The workhorse LA — used topically, infiltration, epidural, spinal, IV adjunct, and antiarrhythmic. Fast Na⁺ channel dissociation = lower cardiotoxicity than bupivacaine.",
                "IV lidocaine infusion (1–2 mg/kg/hr) shows opioid-sparing, anti-inflammatory, and prokinetic effects — popular in enhanced recovery protocols. Alkalinization (NaHCO₃ 1 mEq per 10 mL) speeds epidural onset 2–3 min."
            ],
            colorKey: "local",
            tallManLetters: "LIDOcaine",
            reversal: "Intralipid 20% 1.5 mL/kg IV for LAST"),

        // ── LOCAL ANESTHETICS (EXISTING — NOT IN EXCEL) ───────────────────────
        DrugCard(
            name: "Lidocaine with Epinephrine", brandName: "Xylocaine with Epi",
            category: .local,
            mechanism: "Lidocaine + epinephrine (typically 1:100,000 = 10 mcg/mL or 1:200,000 = 5 mcg/mL). Epinephrine causes local vasoconstriction: reduces systemic LA absorption, prolongs block duration, and serves as intravascular injection marker.",
            onset: "Similar to plain but slightly faster due to reduced washout",
            duration: "Infiltration: 2–4 hours (2× plain). Epidural: 90–120 min.",
            dosing: "Max dose: 7 mg/kg lidocaine with epi (500 mg absolute max). Standard: 1% or 2% lido + 1:100,000 epi. Test dose: 3 mL of 1.5% lido + 1:200,000 epi (45 mg lido + 15 mcg epi).",
            cautions: ["Do NOT use in end-artery territories: digits, penis, nose, ear tip — ischemic necrosis risk", "Avoid in patients on non-selective beta-blockers — unopposed alpha → hypertension", "Cardiac arrhythmias from systemic epi absorption — most problematic under volatile anesthesia", "Intravascular injection of epi component → tachycardia/hypertension — monitor as test dose response"],
            pearls: ["Epinephrine test dose: IV injection marker — HR increase >20 bpm within 60s suggests intravascular placement", "Extends infiltration duration 2–4× vs. plain lidocaine", "Alkalinization: add 1 mL of 8.4% NaHCO₃ per 10 mL of lido/epi to shorten onset by 2–3 min"],
            colorKey: "local"),

        DrugCard(
            name: "Bupivacaine Hyperbaric 0.5%", brandName: "Marcaine Heavy",
            category: .local,
            mechanism: "Bupivacaine 0.5% + 8% dextrose — specific gravity ~1.023, heavier than CSF (~1.003). Block spread influenced by patient position and table tilt (baricity-driven migration in CSF).",
            onset: "3–5 min spinal",
            duration: "Spinal 1.5–2.5h (shorter than isobaric due to CSF dilution)",
            dosing: "Spinal C-section: 1.4–1.6 mL (10.5–12 mg) + fentanyl 15–25 mcg + morphine 100–200 mcg. Spinal lower extremity: 0.5–1.5 mL (3.75–11.25 mg). Saddle block: 0.5 mL seated.",
            cautions: ["High spinal risk if head-down (Trendelenburg) used immediately after injection — can cause apnea and cardiac arrest", "Hypotension predictable with T4 spinal for OB — prepare vasopressors before injection", "Delayed respiratory depression risk if IT morphine added — monitor 12–24h"],
            pearls: ["Workhorse for spinal anesthesia in the US — most common drug used for C-section spinal", "Baricity matters: early repositioning after injection affects block spread and symmetry", "IT morphine 100–200 mcg provides 12–24h post-C-section analgesia"],
            colorKey: "local"),

        DrugCard(
            name: "Liposomal Bupivacaine (Exparel)", brandName: "Exparel",
            category: .local,
            mechanism: "Bupivacaine encapsulated in multivesicular DepoFoam lipid particles. Slow, sustained release over 72h as lipid layers erode. Provides prolonged local tissue analgesia.",
            onset: "Initial release within 30 min; sustained release 24–72h",
            duration: "Up to 72h (local infiltration); 24–48h (some nerve block indications)",
            dosing: "Infiltration: 266 mg (20 mL) diluted with up to 280 mL NS. Interscalene: 133 mg (10 mL) diluted. TAP block: 266 mg (20 mL). NOT for spinal or epidural. Do NOT mix with bupivacaine HCl — accelerates release.",
            cautions: ["High cost — justify with anticipated analgesic benefit vs. multimodal alternatives", "NOT for neuraxial (intrathecal/epidural) — not approved, potentially neurotoxic", "Same LAST toxicity profile as bupivacaine — monitor accordingly", "Do NOT add epinephrine (increases release rate, reduces duration)"],
            pearls: ["Best evidence for infiltration analgesia in hip arthroplasty, bunionectomy, hemorrhoidectomy, C-section wound infiltration", "TAP block application popular for abdominal surgery opioid-sparing — no catheter required", "Insurance/cost often limit use — ensure prior authorization in elective settings"],
            colorKey: "local"),

        DrugCard(
            name: "Ropivacaine (Epidural/Nerve Block)", brandName: "Naropin",
            category: .local,
            mechanism: "Pure S-enantiomer amide LA. Preferential sensory > motor block — ideal for epidural analgesia and continuous nerve block catheters. Better cardiac safety profile than bupivacaine.",
            onset: "Epidural: 15–20 min. Peripheral nerve block: 15–30 min.",
            duration: "Epidural: 3–5h. Peripheral nerve block: 6–12h.",
            dosing: "Max dose: 3 mg/kg (225 mg). Epidural: 0.1–0.2% for analgesia; 0.5–1% for surgical block. Peripheral nerve block: 0.375–0.75%. Thoracic epidural infusion: 0.2% at 5–10 mL/hr.",
            cautions: ["Still cardiotoxic in overdose — less so than bupivacaine but LAST remains a risk", "Intrinsic vasoconstriction means epinephrine provides less additional benefit vs. lidocaine", "Slower onset than lidocaine — plan block timing accordingly"],
            pearls: ["Preferred for continuous nerve block catheters — less motor block than bupivacaine at equivalent sensory dose", "Thoracic epidurals: preserves respiratory muscle function better than equipotent bupivacaine", "0.2% provides differential sensory > motor block ideal for postop epidural infusions"],
            colorKey: "local"),

        DrugCard(
            name: "Mepivacaine", brandName: "Carbocaine / Polocaine",
            category: .local,
            mechanism: "Amide LA. Intermediate potency and duration. Less vasodilation than lidocaine — intrinsic vasoconstriction gives slightly longer duration without epinephrine.",
            onset: "Faster than bupivacaine; similar to lidocaine. Infiltration: 3–5 min. Peripheral block: 10–20 min.",
            duration: "Infiltration plain: 90–150 min. With epi: 3–4h. Peripheral nerve block: 2–5h.",
            dosing: "Max plain: 5 mg/kg (300 mg). Max with epi: 7 mg/kg (500 mg). Peripheral nerve block: 1–1.5%. Dental: 3% plain or 2% with 1:20,000 levonordefrin.",
            cautions: ["Neonatal toxicity — crosses placenta and slowly metabolized by neonates; avoid in obstetric use", "Standard LAST risk profile — monitor CNS/cardiac symptoms", "NOT for OB paracervical or epidural (prolonged neonatal half-life)"],
            pearls: ["Good choice for outpatient peripheral nerve blocks — intermediate duration without prolonged motor block", "Faster onset than bupivacaine with longer duration than plain lidocaine", "Dental anesthesia standard in the US — 3% cartridges widely used"],
            colorKey: "local"),

        DrugCard(
            name: "Chloroprocaine (NESACAINE)", brandName: "Nesacaine",
            category: .local,
            mechanism: "Ester LA hydrolyzed rapidly by plasma cholinesterase (t½ ~25 sec) — lowest systemic toxicity of all clinical LAs. Minimal placental transfer — ideal for OB epidural extension.",
            onset: "Rapid — epidural onset 5–10 min. Infiltration: 2–5 min.",
            duration: "Very short — 30–60 min epidural. 30–45 min infiltration.",
            dosing: "Epidural extension for C-section: 3% chloroprocaine 15–20 mL (fastest epidural LA onset). Epidural test dose: 3 mL 3%. NOT recommended for spinal without preservative-free formulation.",
            cautions: ["Preservative (bisulfite/EDTA) formulations: historical neurotoxicity — use preservative-free for neuraxial", "Antagonizes epidural opioids — receptor competition; wait 30+ min before neuraxial opioid after chloroprocaine epidural", "Tachyphylaxis develops faster than with other LAs", "EDTA-containing formulations may cause hypocalcemia (chelation)"],
            pearls: ["Drug of choice for urgent epidural extension in OB — fastest onset of any epidural LA (5–10 min to T4)", "Minimal placental transfer — ideal when rapid fetal delivery required", "After chloroprocaine epidural, wait ≥30 min before epidural opioid due to receptor antagonism"],
            colorKey: "local"),

        DrugCard(
            name: "Tetracaine", brandName: "Pontocaine",
            category: .local,
            mechanism: "Long-acting ester LA. High lipid solubility and potency — most potent ester LA. Metabolized by plasma cholinesterase (slower than chloroprocaine). Primary use: spinal anesthesia.",
            onset: "Spinal: 3–5 min",
            duration: "Spinal isobaric/hyperbaric: 2–4h (significantly longer than lidocaine spinal)",
            dosing: "Spinal (primary use): 0.5% isobaric or 0.5–1% hyperbaric (with dextrose). Dose: 6–20 mg. Ophthalmology: 0.5% topical drops.",
            cautions: ["High systemic toxicity if absorbed — NOT for infiltration or nerve blocks", "Ester LA — contraindicated with PABA or aminobenzoic acid allergy", "Largely replaced by bupivacaine in the US for most spinal applications"],
            pearls: ["Classic teaching drug for spinal anesthesia history — traditional gold standard before bupivacaine", "Still used at some institutions for prolonged urological procedures", "Ophthalmologic 0.5% drops for corneal analgesia in procedural ophthalmology", "Epinephrine 0.2 mg added prolongs spinal duration ~30–45 min"],
            colorKey: "local"),

        DrugCard(
            name: "Cocaine 4–10%", brandName: "(Topical solution)",
            category: .local,
            mechanism: "Naturally occurring ester LA. Dual mechanism: Na⁺ channel blockade (LA analgesia) + catecholamine reuptake inhibition (sympathomimetic vasoconstriction). Only LA with intrinsic vasoconstrictive properties.",
            onset: "Topical nasal/airway: 2–5 min",
            duration: "30–60 min topical",
            dosing: "Topical ONLY: 4% solution for ENT/nasal (MAX 3 mg/kg, absolute max 200 mg). Soaked pledgets or spray. NOT for infiltration, epidural, or spinal.",
            cautions: ["Potent CNS stimulant — tachycardia, hypertension, dysrhythmias", "ABSOLUTE CI: MAOIs — hypertensive crisis", "CI: CAD, severe HTN, hyperthyroidism", "Schedule II — strict institutional controls; urine drug screen positive after clinical use"],
            pearls: ["Irreplaceable in ENT: only LA with intrinsic vasoconstriction — simultaneous analgesia and bloodless surgical field", "Alternative: oxymetazoline (vasoconstriction) + lidocaine (analgesia) as two separate agents", "Document clinical use in chart — urine screen will be positive for benzoylecgonine"],
            colorKey: "local"),

        // ── EMERGENCY ─────────────────────────────────────────────────────────
        DrugCard(
            name: "Dantrolene", brandName: "Ryanodex / Dantrium",
            category: .emergency,
            mechanism: "Ryanodine receptor (RyR1) antagonist. Inhibits Ca²⁺ release from sarcoplasmic reticulum — directly halts the uncontrolled hypermetabolic cascade of malignant hyperthermia (MH).",
            onset: "Within minutes of IV administration",
            duration: "Sustained — repeat dosing required in most MH crises; 24–48h maintenance",
            dosing: "Initial: 2.5 mg/kg IV rapid bolus. Repeat q5 min as needed. Typical total: 5–10 mg/kg; MAX documented: 30 mg/kg. Each 20 mg vial reconstitutes in 60 mL sterile water. Maintenance: 1 mg/kg q6h for 24–48h to prevent recurrence.",
            cautions: ["Each 20 mg vial requires 60 mL sterile water — assign dedicated reconstitution team IMMEDIATELY", "Muscle weakness during/after — monitor respiratory function", "Hepatotoxicity with prolonged oral use (not acute IV)", "Calcium channel blockers + dantrolene = risk of hyperkalemia and cardiovascular collapse"],
            pearls: ["ONLY definitive MH treatment — give IMMEDIATELY on clinical suspicion; do NOT wait for confirmation", "MH Hotline (US): 1-800-644-9737 (24/7 expert consultation)", "Trigger removal: stop ALL volatile anesthetics, stop succinylcholine, hyperventilate with 100% O₂ at 10 L/min", "Concurrent: active cooling, treat hyperkalemia, treat dysrhythmias, correct acidosis, maintain UO >1 mL/kg/hr", "Also used for neuroleptic malignant syndrome (NMS) and serotonin syndrome with rigidity"],
            colorKey: "emergency"),

        // ── METHYLENE BLUE ────────────────────────────────────────────────────
        DrugCard(
            name: "Methylene Blue",
            category: .methBlue,
            mechanism: """
                Phenothiazine dye. Principal anesthesia/critical care \
                mechanisms: (1) Guanylate cyclase inhibitor — blocks \
                NO-mediated vasodilation → reverses distributive shock \
                unresponsive to catecholamines. (2) Electron carrier in \
                methemoglobin reduction — donates electrons via NADPH-\
                methemoglobin reductase, converting met-Hgb Fe³⁺ → \
                Fe²⁺. (3) MAO-A inhibitor at high doses — serotonin \
                syndrome risk. (4) Mitochondrial electron chain support \
                in cyanide/CO poisoning.
                """,
            onset: "Vasopressor: 1–2 min IV. MetHgb reversal: 15–30 min IV.",
            duration: """
                Vasopressor: 30–60 min (may repeat). \
                MetHgb reversal: 60–120 min; repeat if met-Hgb rebounds.
                """,
            dosing: """
                VASOPLEGIC SHOCK (cardiac surgery / catecholamine-refractory): \
                1–2 mg/kg IV over 15–20 min; may repeat q30–60 min (max \
                7 mg/kg/day). Continuous infusion (off-label): \
                0.25–2 mg/kg/hr.

                METHEMOGLOBINEMIA (symptomatic >30% or >20% with sx): \
                1–2 mg/kg IV over 5–15 min. Repeat 1 mg/kg in 30–60 min \
                if met-Hgb persists. Max single course 7 mg/kg. Available \
                as 10 mg/mL (1%) solution.

                ANAPHYLAXIS (refractory, adjunct to epinephrine): \
                1–2 mg/kg IV over 20 min.

                INTRAOPERATIVE MAPPING / SENTINEL NODE: 1% solution, \
                5 mL local intradermal injection (subcutaneous, not IV \
                for this indication).

                PARATHYROID LOCALIZATION (intraoperative): 5 mg/kg IV \
                over 20 min before incision — tissues stain blue-green; \
                parathyroid remains unstained (differential uptake).

                CYANIDE POISONING (adjunct to hydroxocobalamin): \
                1–2 mg/kg IV; electron donor role in cyanide-impaired \
                mitochondrial chain.

                IFOSFAMIDE ENCEPHALOPATHY: 50 mg IV q6h until resolution \
                (weight-independent fixed dosing per published protocols).
                """,
            cautions: [
                "Serotonin syndrome — ABSOLUTE CONTRAINDICATION with SSRIs, SNRIs, MAOIs, linezolid, tramadol, fentanyl (at high doses), meperidine. Potentially fatal. Screen ALL patients.",
                "G6PD deficiency — methylene blue REQUIRES NADPH; in G6PD deficiency it WORSENS methemoglobinemia and causes hemolysis. Contraindicated for MetHgb treatment in G6PD deficiency.",
                "Pulse oximetry interference — absorbs at 668 nm; SpO₂ reads falsely LOW (~65–85%) for 1–2 min after IV dose; confirm with co-oximetry ABG.",
                "Blue-green discoloration — urine, skin, mucous membranes; warn patient/team; interferes with colorimetric assays and BIS monitor values.",
                "High doses (>7 mg/kg total) → paradoxical methemoglobinemia from direct oxidation of Hgb; stay within dosing limits.",
                "Pulmonary vasoconstriction reported — use with caution in pulmonary HTN; can worsen RV afterload."
            ],
            pearls: [
                "Vasoplegic syndrome post-CPB: MB is first-line adjunct after norepinephrine ≥0.25 mcg/kg/min fails — targets the NO/cGMP pathway upstream of catecholamines.",
                "PROPHYLACTIC MB before CPB (1 mg/kg): RCT evidence shows reduced vasoplegic syndrome incidence and vasopressor requirements post-bypass.",
                "MetHgb reversal: response within 30 min — if no improvement, check G6PD status; repeat dose or consider exchange transfusion.",
                "SEROTONIN TOXICITY RISK is the most dangerous perioperative concern — review ALL serotonergic medications preoperatively.",
                "Co-oximetry ABG is mandatory for MetHgb monitoring — standard pulse oximetry is unreliable during and after MB infusion.",
                "Ifosfamide encephalopathy: MB reverses encephalopathy within hours (reversal of chloroacetaldehyde-induced mitochondrial dysfunction)."
            ],
            colorKey: "emergency",
            reversal: "None specific"),

        // ── GI / ASPIRATION PROPHYLAXIS ───────────────────────────────────────
        DrugCard(
            name: "Famotidine", brandName: "Pepcid",
            category: .gi,
            mechanism: "Competitive H₂ receptor antagonist at gastric parietal cells → ↓gastric acid secretion (↓volume + ↑pH). Does NOT reduce residual gastric volume already present at time of administration.",
            onset: "IV 30 min; PO 60 min",
            duration: "10–12h (significantly longer than ranitidine — preferred H₂ antagonist after ranitidine market withdrawal)",
            dosing: "Aspiration prophylaxis IV: 20 mg IV 30–60 min before induction\nAspiration prophylaxis PO: 20–40 mg PO night before + morning of surgery\nPediatric: 0.5 mg/kg IV (MAX 20 mg)\nGERD/PUD: 20–40 mg PO BID",
            cautions: [
                "AEs: Headache, dizziness, constipation/diarrhea; QTc prolongation (rare, dose-dependent); thrombocytopenia (rare); CNS effects in renal failure (delirium, hallucinations — accumulation of active metabolite)",
                "CI: Hypersensitivity to H₂ antagonists",
                "Precautions: Renal impairment — accumulates; does NOT reliably reduce residual gastric volume (only raises pH); less potent acid suppression than PPIs but faster IV onset; does not substitute for RSI technique in high-aspiration-risk patients"
            ],
            pearls: [
                "Preferred H₂ antagonist for aspiration prophylaxis after ranitidine market withdrawal (NDMA contamination). Raises gastric pH above 2.5 — reduces aspiration pneumonitis severity (Mendelson threshold).",
                "For full-stomach cases: combine with non-particulate antacid (sodium citrate 30 mL PO) for immediate pH neutralization; famotidine provides sustained effect. PPIs (pantoprazole IV) are more potent but slower onset."
            ],
            colorKey: "gi",
            tallManLetters: "FAMOTIdine",
            reversal: "None"),

        // ── ANTICOAGULANT / HEMOSTATIC ────────────────────────────────────────
        DrugCard(
            name: "Heparin (Unfractionated)", brandName: "Heparin Sodium",
            category: .anticoagulant,
            mechanism: "Indirect thrombin inhibitor. Binds antithrombin III (AT-III) → conformational change → accelerates AT-III inactivation of thrombin (IIa), Xa, IXa, XIa, XIIa (1000×). Does NOT directly dissolve existing clots. Chain-length dependent: long chains inhibit both IIa and Xa; short chains (LMWH) preferentially inhibit Xa.",
            onset: "IV: Immediate. SQ: 1–2h",
            duration: "IV: t½ ~60–90 min (dose-dependent, nonlinear). SQ prophylaxis: 8–12h effective duration",
            dosing: """
                CARDIAC SURGERY (CPB): 300–400 units/kg IV bolus; target ACT ≥480 sec (some centers >400 sec). Supplemental heparin 5,000–10,000 units for ACT <400 sec. Dose from cardiology/perfusionist protocol.

                VASCULAR SURGERY (non-CPB): 100–150 units/kg IV bolus; target ACT 250–300 sec.

                VTE TREATMENT (DVT/PE): 80 units/kg IV bolus, then 18 units/kg/hr infusion. Titrate to aPTT 60–100 sec (institutional nomogram). Weight-based dosing per Raschke nomogram reduces time to therapeutic anticoagulation.

                VTE PROPHYLAXIS (SQ): 5,000 units SQ q8–12h. High-risk: 7,500 units SQ q8h or LMWH preferred.

                ARTERIAL LINE FLUSH: 1–2 units/mL flush solution (heparin lock).

                HEPARIN DRIP TITRATION (Raschke nomogram):
                aPTT <35 sec → 80 units/kg bolus + ↑rate 4 units/kg/hr
                aPTT 35–45 sec → 40 units/kg bolus + ↑rate 2 units/kg/hr
                aPTT 46–70 sec → No change
                aPTT 71–90 sec → ↓rate 2 units/kg/hr
                aPTT >90 sec → Hold 1h, ↓rate 3 units/kg/hr
                """,
            cautions: [
                "HIT Type II (Heparin-Induced Thrombocytopenia): Immune-mediated (anti-PF4/heparin antibody → platelet activation → PARADOXICAL THROMBOSIS). Onset day 5–14 after first exposure. Suspect if platelet count ↓>50% from baseline or <100K. STOP ALL HEPARIN immediately — switch to argatroban or bivalirudin. Risk: ~1–3% with UFH, <0.2% with LMWH.",
                "Bleeding: Most common dose-related adverse effect. Risk factors: aPTT >100 sec, age >70, concurrent antiplatelet agents, renal failure, prior GI bleed.",
                "Heparin resistance: AT-III deficiency (inherited or acquired — sepsis, cirrhosis, DIC, extended heparin use), elevated Factor VIII, high acute-phase proteins. Treatment: FFP (contains AT-III) or AT-III concentrate.",
                "CI: Active major bleeding, HIT (any type), hypersensitivity. Use caution: thrombocytopenia, recent surgery, uncontrolled HTN.",
                "Hyperkalemia: Heparin inhibits aldosterone secretion (zona glomerulosa suppression) — monitor K⁺ with prolonged use. Clinically significant primarily in renal failure.",
                "Osteoporosis: Risk with >3 months continuous use (activates osteoclasts). Prefer LMWH for extended anticoagulation."
            ],
            pearls: [
                "MONITOR — ACT for high-dose (CPB, vascular); aPTT for therapeutic anticoagulation. ACT >480 sec required for CPB (lower ACT risks clotting in circuit). Goal-directed dosing reduces both thrombotic and bleeding complications.",
                "HIT TYPE II is the most dangerous complication — thrombosis (not just thrombocytopenia) is the threat. Never restart heparin in confirmed HIT; alternative anticoagulants (argatroban, bivalirudin) required.",
                "REVERSAL: Protamine sulfate 1 mg per 100 units UFH administered (see Protamine card). Full reversal requires knowledge of dose administered and time elapsed (t½ ~90 min).",
                "Heparin resistance: First evaluate for AT-III deficiency. FFP 2 units or AT-III concentrate corrects most cases. Document resistance — cardiac surgery perfusionist must know.",
                "LMWH (enoxaparin, dalteparin) has more predictable pharmacokinetics, does not require aPTT monitoring, and lower HIT risk — preferred for most outpatient therapeutic anticoagulation and VTE prophylaxis."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "HEParin",
            reversal: "Protamine sulfate 1 mg per 100 units UFH; fresh frozen plasma for AT-III supplementation"),

        DrugCard(
            name: "Protamine Sulfate", brandName: "Protamine Sulfate",
            category: .anticoagulant,
            mechanism: "Highly basic (cationic) polypeptide derived from salmon sperm. Forms stable electrostatic complex with strongly acidic (anionic) heparin → biologically inactive salt complex, rapidly cleared. Completely reverses UFH anticoagulation. Partially reverses LMWH (reverses ~60% of anti-IIa activity; anti-Xa activity incompletely neutralized). At excess doses, paradoxical anticoagulant effect via platelet inhibition and fibrinogenolysis.",
            onset: "5 min (IV)",
            duration: "2h. Heparin rebound may occur at 2–4h post-CPB as tissue-bound heparin is released — re-check ACT and redose if necessary",
            dosing: """
                POST-CPB REVERSAL (standard): 1–1.3 mg protamine per 100 units UFH administered during bypass. Administer SLOWLY over 10 min (max 50 mg/min infusion rate).

                EXAMPLE: Patient received 30,000 units UFH for CPB → administer 300–390 mg protamine (total dose).

                TITRATION BY ACT: Give calculated dose; recheck ACT at 5 min. Residual ACT elevation → supplemental protamine 25–50 mg IV. Target: ACT within 10% of pre-heparin baseline.

                EXCESS UFH REVERSAL (non-CPB): 1 mg per 100 units UFH estimated REMAINING (account for heparin already metabolized based on t½ ~90 min). Maximum recommended single dose: 50 mg.

                LMWH REVERSAL: 1 mg protamine per 1 mg enoxaparin (or per 100 anti-Xa units) administered within 8h. Repeat 0.5 mg per 1 mg enoxaparin if needed. Expect incomplete anti-Xa reversal (~60%).

                INFUSION RATE: Give over 10 min — administer NO FASTER than 5 mg/min (50 mg/10 min). Rapid administration → severe hypotension.
                """,
            cautions: [
                "ANAPHYLAXIS / ANAPHYLACTOID REACTIONS (1–2% incidence): Complement activation → pulmonary vasoconstriction, systemic hypotension, bronchoconstriction, cardiovascular collapse. Risk factors: (1) Previous protamine exposure (prior cardiac surgery, catheterization), (2) NPH insulin use (contains protamine — cross-reactive antibodies), (3) Fish/salmon allergy, (4) Vasectomy (anti-protamine antibodies from sperm exposure). Pre-treat high-risk patients: diphenhydramine 25–50 mg + hydrocortisone 100 mg IV before protamine.",
                "PULMONARY VASOCONSTRICTION (complement-mediated): Seen especially with rapid administration. Manifests as acute ↑PA pressures, ↑RV afterload, RV failure post-CPB. Give SLOWLY and via LEFT atrium (if available) to reduce pulmonary concentration.",
                "RAPID ADMINISTRATION HYPOTENSION: Histamine release + direct vasodilation → severe hypotension. Administer at ≤5 mg/min (10-min infusion). Have vasopressors ready.",
                "PARADOXICAL ANTICOAGULATION (excess protamine): At >5–10 mg/kg or excessive free protamine → inhibits platelet function (GPIIb/IIIa interference) and causes anticoagulant effect. More is NOT better — dose precisely.",
                "HEPARIN REBOUND: Heparin sequestered in tissues during CPB released over 2–4 hours → delayed re-anticoagulation despite adequate initial reversal. Monitor ACT at 1–2h post-reversal; redose 25–50 mg protamine as needed.",
                "CI: Hypersensitivity to protamine or fish. Use with extreme caution in known NPH insulin users or previous protamine reactions."
            ],
            pearls: [
                "CPB reversal dosing: Calculate total heparin administered (initial + supplemental doses) and give 1–1.3 mg/100 units. Verify by ACT within 5 min — supplement as needed. ACT NOT returning to baseline despite repeated protamine → consider heparin resistance, insufficient reversal, or excessive protamine paradox.",
                "HIGH-RISK PATIENTS: Consider left atrial administration if available to reduce pulmonary exposure. Pre-medicate with diphenhydramine + steroids. Have epinephrine drawn and ready at bedside.",
                "HEPARIN REBOUND is clinically important post-CPB — a patient with good hemostasis in the OR who bleeds in the ICU may simply need additional protamine (check ACT first before empirically giving blood products).",
                "LMWH reversal is INCOMPLETE — protamine reverses anti-IIa but only ~60% of anti-Xa activity of LMWH. Residual anti-Xa effect persists. For life-threatening bleeding on LMWH, consider andexanet alfa (if available) or rFVIIa.",
                "POINT-OF-CARE TESTING: TEG/ROTEM can help distinguish heparin rebound (elevated R-time or CT corrected by heparinase channel) from surgical bleeding, thrombocytopenia, or factor deficiency — guides targeted therapy."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "PROTamine",
            reversal: "No antidote for protamine excess; supportive care, heparin can partially re-anticoagulate if paradoxical anticoagulation occurs"),

        DrugCard(
            name: "Tranexamic Acid (TXA)", brandName: "Cyklokapron / Lysteda",
            category: .anticoagulant,
            mechanism: "Synthetic lysine analogue — competitive inhibitor of plasminogen activation. Blocks lysine-binding sites on plasminogen and plasmin, preventing attachment to fibrin → inhibits fibrinolysis. Does NOT promote clotting; preserves clot integrity by preventing premature fibrin degradation. 6–10× more potent than aminocaproic acid.",
            onset: "IV: within minutes. Oral: ~3h peak",
            duration: "t½ ~3h. Active drug excreted renally; duration of antifibrinolytic effect outlasts serum concentration",
            dosing: """
                CARDIAC SURGERY (on-pump CPB): 10–30 mg/kg IV load before incision (or before sternotomy), then 1–2 mg/kg/hr infusion throughout CPB. Some protocols add 1–2 mg/kg into pump prime. (High-dose: 30/16/2 mg/kg load/infusion/prime has strongest evidence for blood conservation.)

                MAJOR ORTHOPEDIC (hip/knee arthroplasty): 1–2 g IV before tourniquet inflation (or incision). Topical: 1.5–3 g in 100 mL NS applied to wound cavity before closure; may combine IV + topical.

                TRAUMA / MASSIVE HEMORRHAGE: CRASH-2 protocol — 1 g IV over 10 min within 3h of injury, then 1 g IV over 8h. Benefit attenuated after 3h; harmful if given >3h post-injury.

                OBSTETRICS (PPH prevention/treatment): 1 g IV over 10 min after delivery (WHO 2017 recommendation). Repeat 1 g if bleeding continues after 30 min or restarts within 24h.

                NEUROSURGERY / SPINE: 1 g IV load, 100–200 mg/hr infusion intraoperatively.

                PEDIATRIC: 10–50 mg/kg IV over 15 min (dose varies widely by center/protocol; cardiac surgery typically 50–100 mg/kg load).

                RENAL DOSING:
                CrCl 10–50 mL/min → reduce to 50% of dose
                CrCl <10 mL/min → reduce to 25% of dose or avoid
                """,
            cautions: [
                "SEIZURES: Dose-dependent neurotoxicity — TXA crosses blood-brain barrier and acts as GABA-A and glycine receptor antagonist. Risk highest with high doses (cardiac surgery), direct intrathecal/intracerebroventricular exposure, renal failure (accumulation), and in neonates. Seizures typically occur within hours of cardiac surgery. Use seizure precautions with high-dose protocols.",
                "THROMBOEMBOLIC EVENTS: TXA is PRO-thrombotic in the right context. Contraindicated in: active intravascular clotting (DIC with clotting phase), subarachnoid hemorrhage from ruptured aneurysm (unless awaiting surgery), and in patients with history of VTE without adequate anticoagulation. Not independently associated with MI/PE at clinical doses based on large RCTs (ATACAS, CRASH-2).",
                "RENAL ACCUMULATION: Renally excreted; dose-reduce in renal impairment. Accumulation → elevated drug levels → seizure risk.",
                "CI: Active thromboembolic disease; DIC with clotting predominance; hypersensitivity; ureteral bleeding from upper tract lesions (may cause ureteral obstruction from clot).",
                "INTRATHECAL EXPOSURE (inadvertent): Extremely seizurogenic — TXA must NEVER be placed in syringes alongside neuraxial drugs. Label clearly; use in separate syringes/IV lines only. Multiple reported catastrophic errors."
            ],
            pearls: [
                "STRONGEST perioperative antifibrinolytic — robust RCT evidence for blood conservation in cardiac, orthopedic, trauma, and obstetric settings. Meta-analyses consistently show 30–40% reduction in transfusion requirement.",
                "CARDIAC SURGERY — ATACAS trial (2017, N=4,631): TXA reduced transfusion by ~35% with no increase in thromboembolic events vs. placebo. Seizure rate ~0.7% (vs. 0.1% placebo) — mainly with high-dose protocols.",
                "TRAUMA — CRASH-2 trial (N=20,211): 1g bolus + 1g over 8h within 3h of injury reduced all-cause mortality (14.5% vs 16.0%). TIME IS CRITICAL — benefit lost after 3h; harmful effect if given late.",
                "TOPICAL APPLICATION (orthopedics): 1.5–3 g in NS poured/soaked into wound → equivalent blood loss reduction to IV, with minimal systemic absorption and no systemic thrombotic risk. Ideal for patients with thromboembolic history.",
                "SEIZURE PREVENTION: Avoid pump prime concentrations >~0.5 mmol/L. In high-risk patients (renal failure, elderly, high-dose protocols), consider EEG monitoring; treat TXA-induced seizures with benzodiazepines (not phenytoin — less effective for GABA-mechanism seizures).",
                "LABEL ALL SYRINGES CLEARLY — the most catastrophic TXA errors have been inadvertent intrathecal injection (mistaken for bupivacaine or saline). Strict preparation protocols mandatory."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "TRANEXamic acid",
            reversal: "No specific antidote; hemodialysis can remove TXA; seizures treated with benzodiazepines"),

        DrugCard(
            name: "Aminocaproic Acid (Amicar)", brandName: "Amicar",
            category: .anticoagulant,
            mechanism: "Synthetic lysine analogue antifibrinolytic — same mechanism as TXA (plasminogen lysine-binding site inhibitor → inhibits fibrinolysis). 6–10× less potent than TXA on a mg-per-mg basis, requiring higher doses. May also inhibit plasmin directly at very high concentrations.",
            onset: "IV: 15–30 min",
            duration: "t½ ~2h (shorter than TXA); continuous infusion maintains effect",
            dosing: """
                CARDIAC SURGERY: 5–10 g IV load over 30 min before incision, then 1–2.5 g/hr infusion during CPB. Some protocols add 5 g to pump prime.

                GENERAL SURGICAL HEMOSTASIS: 4–5 g IV over 1h, then 1 g/hr for 8h (or until bleeding controlled). Total dose typically ≤24 g/24h.

                HEMATOLOGIC BLEEDING (ITP, hemophilia adjunct): 4 g IV/PO, then 1 g/hr. Oral: 5 g loading dose PO, then 1 g/hr.

                DENTAL PROCEDURES (hemophilia): 75 mg/kg PO q6h starting the day before and continuing 5–7 days post-procedure.

                RENAL DOSING: Reduce dose proportionally in renal impairment (renally excreted; accumulates).
                """,
            cautions: [
                "UPPER URINARY TRACT BLEEDING: Contraindicated — antifibrinolytic action can cause ureteral clot obstruction → obstructive uropathy/hydronephrosis.",
                "THROMBOEMBOLIC RISK: Same theoretical risk as TXA; contraindicated in active DIC with clotting predominance and active intravascular coagulation.",
                "MYOPATHY / RHABDOMYOLYSIS: Rare but serious complication with prolonged high-dose use (>4 weeks). Monitor CK with extended courses.",
                "CI: Hematuria of upper urinary origin; active intravascular coagulation; hypersensitivity.",
                "GENERALLY PREFERRED OVER TXA for: situations where lower potency is desirable; some institutions' cost-driven protocols (less expensive than TXA per gram, though higher dose needed)."
            ],
            pearls: [
                "Functionally equivalent to TXA but less potent — requires 6–10× higher dose for equivalent antifibrinolytic effect. TXA is preferred in most current cardiac and trauma protocols due to more favorable dose size and stronger evidence base.",
                "Useful in hemophilia management as adjunct (prevents fibrinolysis of formed clots while Factor replacement promotes clot formation). Oral formulation available for outpatient dental management.",
                "LOWER SEIZURE RISK than TXA — fewer reports of neurotoxicity, likely due to less CNS penetration at equivalent antifibrinolytic concentrations. May be preferred in patients with seizure history or neurological vulnerability.",
                "Available as oral formulation — an advantage for outpatient management of hemostatic disorders and post-procedure hemostasis in hemophilia patients."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "aminoCAPROic acid",
            reversal: "No specific antidote; discontinue infusion for bleeding complications"),

        DrugCard(
            name: "Enoxaparin (LMWH)", brandName: "Lovenox",
            category: .anticoagulant,
            mechanism: "Low molecular weight heparin (LMWH). Selectively binds AT-III → preferential Factor Xa inhibition (~3:1 anti-Xa:anti-IIa ratio, vs. 1:1 for UFH). Shorter polysaccharide chains cannot bridge thrombin and AT-III simultaneously → minimal direct thrombin (IIa) inhibition. More predictable pharmacokinetics than UFH: dose-independent clearance, less protein binding, longer half-life (~4.5h). No reliable monitoring required for most patients (fixed weight-based dosing).",
            onset: "SQ: 3–5h (anti-Xa peak). IV: immediate (off-label use)",
            duration: "t½ ~4.5h (therapeutic SQ); renal clearance — significantly prolonged in CrCl <30 mL/min",
            dosing: """
                VTE PROPHYLAXIS (surgical patients):
                Standard risk: 40 mg SQ daily (start 12h before or 12–24h post-op)
                High risk / bariatric: 40 mg SQ q12h or weight-based 0.5 mg/kg SQ q12h
                Hip/knee arthroplasty: 30 mg SQ q12h or 40 mg SQ daily

                VTE TREATMENT (DVT/PE):
                1 mg/kg SQ q12h (anti-Xa target 0.6–1.0 IU/mL at 4h post-dose)
                OR 1.5 mg/kg SQ daily (less studied for PE; anti-Xa target 1.0–2.0 IU/mL)
                BMI >40 or weight >150 kg: Consider anti-Xa monitoring; cap at 144 mg dose

                ACS (NSTEMI/UA — with or without PCI):
                1 mg/kg SQ q12h; IV bolus 0.3 mg/kg may be given before PCI if last SQ dose >8h prior

                BRIDGING (perioperative):
                Therapeutic: 1 mg/kg SQ q12h; hold last dose 24h before surgery
                Prophylactic bridge: 40 mg SQ daily; hold last dose 12h before surgery

                RENAL DOSING (CrCl <30 mL/min):
                Prophylactic: 30 mg SQ daily
                Therapeutic: 1 mg/kg SQ daily (NOT q12h)
                Avoid if CrCl <15 mL/min or on dialysis — UFH preferred
                """,
            cautions: [
                "RENAL ACCUMULATION: Enoxaparin is renally cleared — dose-reduce significantly in CrCl <30 mL/min. Anti-Xa monitoring mandatory for renal impairment. Risk of severe bleeding with accumulation.",
                "HIT: Lower risk than UFH (~0.1–0.2%) but CROSS-REACTS with HIT antibodies — do NOT use enoxaparin in confirmed or suspected HIT. Switch to argatroban or fondaparinux.",
                "EPIDURAL/SPINAL HEMATOMA (neuraxial anesthesia): ASRA guidelines — wait 12h after prophylactic dose, 24h after therapeutic dose before neuraxial procedure. After neuraxial, wait 12h before resuming prophylactic dose, 24h before therapeutic. High risk — follow ASRA guidelines strictly.",
                "REVERSAL INCOMPLETE: Protamine neutralizes ~60% of anti-IIa activity; anti-Xa activity only ~60% reversed. For life-threatening bleeding, consider andexanet alfa (FDA-approved for LMWH reversal).",
                "PREGNANCY: Enoxaparin does NOT cross placenta — preferred anticoagulant in pregnancy for VTE treatment and prevention. Monitor anti-Xa levels throughout pregnancy (volume of distribution changes).",
                "WEIGHT EXTREMES: <45 kg → accumulation; >100 kg → subtherapeutic with standard dosing. Monitor anti-Xa in these patients."
            ],
            pearls: [
                "PERIOPERATIVE BRIDGING — key timing: Therapeutic enoxaparin → last dose 24h before surgery; resume 24–48h post-op (after hemostasis confirmed). Prophylactic → last dose 12h before; resume 12–24h post-op. Always individualize for bleeding vs. thrombotic risk.",
                "ANTI-XA MONITORING: Not routinely needed for standard weight patients. Indicated for: renal impairment (CrCl <30), extremes of weight (<45 kg or >100 kg), pregnancy. Peak anti-Xa drawn 4h after SQ dose. Therapeutic target: q12h dosing → 0.6–1.0 IU/mL; daily dosing → 1.0–2.0 IU/mL.",
                "NEURAXIAL TIMING (ASRA 2018): Prophylactic enoxaparin: 12h hold before / 12h after catheter removal. Therapeutic: 24h hold before / 24h after removal. These are MINIMUM intervals — increase for renal impairment or epidural catheter in situ.",
                "PREGNANCY VTE TREATMENT: Preferred over UFH (no teratogenicity, more predictable dosing). Dose requirements typically increase during pregnancy due to ↑renal clearance and ↑volume of distribution — anti-Xa monitoring recommended each trimester.",
                "FONDAPARINUX (Arixtra) is a pure anti-Xa agent with NO protamine reversal — for HIT patients requiring anticoagulation who cannot use argatroban. Shorter t½ than enoxaparin; renally cleared."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "enoXAParin",
            reversal: "Protamine 1 mg per 1 mg enoxaparin (60% reversal); andexanet alfa for life-threatening bleeding"),

        DrugCard(
            name: "4-Factor PCC (Kcentra)", brandName: "Kcentra / Beriplex / Octaplex",
            category: .anticoagulant,
            mechanism: "Prothrombin Complex Concentrate (4-Factor): pooled human plasma-derived concentrate of clotting factors II, VII, IX, and X (vitamin K-dependent factors), plus Proteins C and S. Directly replaces vitamin K-dependent factors depleted by warfarin or factor Xa inhibitors. Provides immediate coagulation factor restoration without large volume load. Activated 4F-PCC (FEIBA) contains activated Factor VII and is used specifically for inhibitor bypassing in hemophilia.",
            onset: "5–15 min (INR reversal begins within minutes)",
            duration: "Factor half-lives vary: FIX ~24h, FX ~40h, FII ~60h, FVII ~4–6h (FVII is shortest — may need repeat dosing for warfarin)",
            dosing: """
                WARFARIN REVERSAL (urgent/emergent — e.g., life-threatening bleeding, urgent surgery):
                INR 2–3.9 → 25 units/kg (max 2,500 units)
                INR 4–6 → 35 units/kg (max 3,500 units)
                INR >6 → 50 units/kg (max 5,000 units)
                ALWAYS give with Vitamin K 10 mg IV concurrently (PCC effect lasts only hours; VitK replenishes endogenous production). Target: INR <1.5 within 30 min.

                FACTOR Xa INHIBITOR REVERSAL (apixaban, rivaroxaban — off-label use):
                25–50 units/kg IV (literature supports; andexanet alfa is FDA-approved alternative)
                Most institutions use 25–50 units/kg for urgent reversal when andexanet alfa unavailable

                PEDIATRIC: Same weight-based dosing; unit doses vary by product

                ADMINISTRATION: Max infusion rate 8–12 mL/min. Typically administered over 15–30 min. Do NOT mix with other IV medications.

                3-FACTOR PCC (factors II, IX, X only — no FVII; e.g., Profilnine):
                Less preferred for warfarin reversal due to FVII omission — FVII deficiency is primary driver of warfarin-related INR elevation.
                """,
            cautions: [
                "THROMBOEMBOLISM: Contains concentrated procoagulant factors — risk of DVT, PE, MI, stroke (particularly in patients with pre-existing thrombotic risk or DIC). Use lowest effective dose. Avoid in active thrombosis unless life-threatening bleeding.",
                "HEPARIN-INDUCED THROMBOCYTOPENIA: Some 4F-PCC formulations contain heparin as stabilizer — contraindicated in HIT. Check product insert (Kcentra does contain heparin).",
                "ALWAYS CO-ADMINISTER VITAMIN K for warfarin reversal: PCC factors are consumed within hours; without concurrent VitK (10 mg IV), INR will re-elevate as PCC factors are metabolized. VitK takes 6–24h to restore endogenous synthesis.",
                "DIC CONTRAINDICATION: Do not use in disseminated intravascular coagulation — adding concentrated factors to an already dysregulated coagulation cascade can worsen DIC and thrombotic complications.",
                "Volume advantage vs. FFP: 4F-PCC delivers equivalent factor replacement in ~25 mL vs. 4–6 units FFP (~1,000 mL). Critical advantage in volume-sensitive patients (CHF, severe renal failure, pediatric)."
            ],
            pearls: [
                "WARFARIN REVERSAL — FOUR-Rs: Kcentra (4F-PCC) is now preferred over FFP for urgent warfarin reversal based on ANNEXA-4 and earlier PCC vs FFP RCTs. Faster INR correction (15–30 min vs. 12–24h for VitK alone; 2–6h for FFP), less volume, no blood type required, no viral transmission risk.",
                "FACTOR Xa INHIBITOR (rivaroxaban/apixaban) — OFF-LABEL but widely used: PCC 25–50 units/kg is the de facto standard when andexanet alfa is unavailable (cost, formulary) or for immediate reversal. Evidence comes from healthy volunteer studies and observational data — not as robust as andexanet alfa trial (ANNEXA-4).",
                "FEIBA (Factor Eight Inhibitor Bypassing Activity — activated PCC): Contains activated FVII; used specifically for bleeding in hemophilia A/B WITH inhibitors (antibodies neutralizing FVIII or FIX). NOT interchangeable with Kcentra. Different dosing and indications.",
                "MONITORING POST-ADMINISTRATION: Repeat INR 30 min and 6h post-infusion. If INR re-rises >1.5 after initial correction, consider repeat dosing or evaluation for continued VitK deficiency (especially if VitK not given).",
                "COST AND ACCESS: Kcentra is expensive (~$1,000–4,000 per dose) but readily available and rapidly administered. Andexanet alfa (Xa reversal) is substantially more expensive (~$25,000–50,000/course). Institutional protocols should define when each agent is appropriate."
            ],
            colorKey: "anticoagulant",
            reversal: "No reversal — if thrombosis from PCC occurs, anticoagulate appropriately"),

        DrugCard(
            name: "Andexanet Alfa (Ondexxya)", brandName: "Ondexxya",
            category: .anticoagulant,
            mechanism: "Recombinant modified human Factor Xa decoy molecule — lacks catalytic activity. Binds Factor Xa inhibitors (apixaban, rivaroxaban, enoxaparin) with high affinity, sequestering them and preventing binding to native FXa. Does NOT directly promote clotting; restores endogenous FXa activity by removing inhibitor. Rapidly reduces anti-Xa activity by 80–90% within minutes of administration.",
            onset: "Anti-Xa activity reduction within 2 min of IV administration",
            duration: "Reversal maintained during infusion; anti-Xa activity may re-elevate within 2h after completion (drug redistribution from tissue). Bleeding control typically maintained beyond plasma anti-Xa re-elevation.",
            dosing: """
                APIXABAN or RIVAROXABAN REVERSAL (life-threatening or uncontrolled bleeding):

                LOW-DOSE REGIMEN (apixaban ≤5 mg within 8h; rivaroxaban ≤10 mg within 8h):
                400 mg IV bolus (30 mg/min) THEN 480 mg IV infusion over 2h (4 mg/min)

                HIGH-DOSE REGIMEN (apixaban >5 mg or timing unknown; rivaroxaban >10 mg or timing unknown):
                800 mg IV bolus (30 mg/min) THEN 960 mg IV infusion over 2h (8 mg/min)

                ENOXAPARIN (off-label — FDA-approved for FXa inhibitors only; used off-label for LMWH):
                Same dosing regimens used off-label; evidence extrapolated from anti-Xa activity reduction studies

                BETRIXABAN/EDOXABAN: FDA-approved indication — use high-dose regimen.

                ADMINISTRATION NOTES: Must be reconstituted; administer with dedicated IV line. Do NOT administer other drugs in same line.
                """,
            cautions: [
                "THROMBOEMBOLIC EVENTS: 10–15% rate of thrombosis (DVT, PE, MI, stroke) in ANNEXA-4 trial — driven largely by underlying patient comorbidities and reversal of anticoagulation in high-risk population. Resume anticoagulation as soon as safely feasible after hemostasis.",
                "ANTI-Xa REBOUND: Anti-FXa activity may re-elevate 2–18h post-infusion as andexanet alfa is cleared faster than apixaban/rivaroxaban. Monitor anti-Xa levels; resuming anticoagulation is typically more effective than re-dosing andexanet alfa.",
                "COST: One of the most expensive drugs in hospital formulary (~$25,000–50,000 per course). Most institutions have restricted use criteria requiring clinical pharmacy/hematology approval.",
                "DOES NOT REVERSE: Dabigatran (DTI — use idarucizumab), warfarin (use 4F-PCC + VitK), or UFH/LMWH heparin (use protamine; LMWH partially reversed by protamine — andexanet off-label for LMWH).",
                "LABORATORY: Standard anti-Xa assays may be unreliable during andexanet alfa infusion (andexanet alfa cross-reacts with some assays). Use HEMO ScreenTM or thrombin generation assay if available; clinical monitoring of bleeding is primary endpoint.",
                "PREGNANCY / PEDIATRIC: Not studied; no data available."
            ],
            pearls: [
                "ONLY FDA-APPROVED SPECIFIC REVERSAL AGENT for apixaban and rivaroxaban (Factor Xa inhibitors). ANNEXA-4 trial: 82% excellent/good hemostatic efficacy at 12h in patients with acute major bleeding on apixaban or rivaroxaban.",
                "DOSE SELECTION TIP: 'High dose' is for patients who took a recent high dose of rivaroxaban (>10 mg) or apixaban (>5 mg) OR timing of last dose is unknown. When in doubt → use high-dose regimen.",
                "RESUME ANTICOAGULATION EARLY: Andexanet alfa reversal is a bridge, not permanent. Once hemostasis is confirmed (typically 12–24h), restart anticoagulation. The thrombotic risk from the underlying condition (AF, VTE) persists. Document plan at time of reversal.",
                "4F-PCC vs. ANDEXANET ALFA for FXa inhibitor reversal: PCC (off-label, $1,000–4,000) vs. andexanet alfa (on-label, ~$25,000–50,000). Many institutions use PCC as first-line due to cost and formulary access, reserving andexanet alfa for patients where PCC fails or is contraindicated.",
                "DOES NOT REQUIRE BLOOD TYPING — no plasma components; no transfusion reaction risk. Reconstitution takes ~15 min — plan ahead; do not delay other supportive care while preparing."
            ],
            colorKey: "anticoagulant",
            reversal: "No reversal agent; thrombosis risk managed by resuming anticoagulation"),

        DrugCard(
            name: "Idarucizumab (Praxbind)", brandName: "Praxbind",
            category: .anticoagulant,
            mechanism: "Humanized monoclonal antibody fragment (Fab) against dabigatran. Binds dabigatran and its active metabolites with 350× higher affinity than thrombin → immediate neutralization of anticoagulant effect. Does NOT affect other anticoagulants, coagulation factors, or platelets. Not a reversal agent for any drug except dabigatran.",
            onset: "Immediate (within minutes of IV administration)",
            duration: "Sustained for ~24h with standard 5 g dose. If dabigatran re-distributes from tissues (dialysis patients, high plasma dabigatran concentration), repeat dosing may be required",
            dosing: """
                STANDARD DOSE: 5 g IV (2 × 2.5 g vials given consecutively).

                ADMINISTRATION: Each 2.5 g/50 mL vial given IV push or infusion over 5–10 min. Two vials administered one after the other (total infusion ~10–15 min). No dilution required. Dedicated IV line only.

                RE-DOSING: Additional 5 g may be given if:
                - Clinically relevant bleeding recurs AND
                - Dabigatran levels remain elevated OR coagulation parameters (aPTT, TT, ECT) remain elevated

                PEDIATRIC: Not established; limited case reports.

                DIALYSIS CONSIDERATION: Dabigatran is dialyzable (low protein binding) — hemodialysis removes ~60–70% in 4h and is an alternative if idarucizumab unavailable.
                """,
            cautions: [
                "THROMBOEMBOLIC RISK: Reversal of anticoagulation restores thrombotic risk. In RE-VERSE AD trial: 6.8% thrombotic event rate at 30 days (largely in patients not restarted on anticoagulation). Resume dabigatran or alternative anticoagulation as soon as hemostasis permits (typically 24h).",
                "HEREDITARY FRUCTOSE INTOLERANCE: Contains sorbitol excipient — contraindicated in hereditary fructose intolerance (rare genetic condition). Check product insert.",
                "MONITORING: Standard aPTT will normalize; diluted thrombin time (dTT) or ecarin clotting time (ECT) are most specific for dabigatran concentration if available. Thrombin time (TT) qualitatively sensitive — if TT is normal, dabigatran levels are negligible.",
                "DOES NOT REVERSE: Apixaban, rivaroxaban, edoxaban, betrixaban (use andexanet alfa), warfarin (use 4F-PCC + VitK), or UFH/LMWH (use protamine). Dabigatran-specific ONLY.",
                "COST: ~$3,500–4,000 per dose (5 g); significantly less expensive than andexanet alfa."
            ],
            pearls: [
                "ONLY FDA-APPROVED REVERSAL AGENT for dabigatran. RE-VERSE AD trial (N=503): 98% normalized diluted TT/ECT within minutes; 82% intraoperative hemostasis rated excellent/good; 81% clinical hemostasis in bleeding group.",
                "FASTEST REVERSAL AVAILABLE — within minutes, no preparation beyond drawing up vials. Ideal for: emergency surgery, life-threatening bleeding (ICH, GI, trauma), urgent procedures requiring hemostasis in patients on dabigatran.",
                "DABIGATRAN UNIQUE PROPERTY: Unlike Xa inhibitors, dabigatran is ~35% protein-bound and renally cleared → dialyzable. Hemodialysis removes ~60–70% in 4h. Consider if idarucizumab unavailable, patient already on dialysis, or if re-elevation of dabigatran levels is anticipated (e.g., overdose).",
                "WHEN TO SUSPECT DABIGATRAN ON BOARD: Elevated aPTT + elevated thrombin time (TT) with normal reptilase time → highly suggestive. TT is an extremely sensitive (qualitative) test for dabigatran — a completely normal TT essentially excludes clinically relevant dabigatran levels.",
                "RESTART ANTICOAGULATION DECISION: After emergent reversal, restart anticoagulation 24–72h post-reversal when hemostasis is secure. Failure to restart is a significant safety issue — these patients (often AF with high CHA₂DS₂-VASc scores) have high thrombotic risk."
            ],
            colorKey: "anticoagulant",
            reversal: "No reversal needed — idarucizumab effect wanes naturally; dabigatran can be restarted when hemostasis secure"),

        DrugCard(
            name: "Desmopressin (DDAVP)", brandName: "DDAVP / Stimate",
            category: .anticoagulant,
            mechanism: "Synthetic analogue of arginine vasopressin (AVP). V2 receptor agonism on vascular endothelium → releases stored von Willebrand factor (vWF) and Factor VIII from Weibel-Palade bodies → enhances platelet adhesion (GPIb–vWF interaction) and secondary hemostasis. Also increases platelet surface expression of GPIb and αIIbβ3. Antidiuretic effect via V2 in renal collecting duct → water reabsorption (used for central DI, enuresis). No direct vasopressor activity at hemostatic doses.",
            onset: "Hemostatic: peak effect 30–90 min after IV infusion. Antidiuretic: 1–2h (IN); 15–30 min (IV)",
            duration: "Hemostatic: 6–12h (single dose). TACHYPHYLAXIS develops with repeat dosing — second dose within 24h yields ~30–50% reduced response; third dose minimal effect (vWF stores depleted; 24h required for resynthesis)",
            dosing: """
                HEMOSTASIS (VWD Type 1, platelet dysfunction, uremic bleeding, aspirin/NSAID effect, cardiac surgery):
                IV: 0.3 mcg/kg diluted in 50 mL NS, infuse over 15–30 min. Standard adult dose: 15–20 mcg IV (approximately 0.3 mcg/kg for 50–70 kg patient).
                Intranasal (Stimate 1.5 mg/mL): <50 kg → 150 mcg (1 spray); ≥50 kg → 300 mcg (1 spray each nostril).
                SQ: 0.3 mcg/kg (same dose as IV; slower onset).

                HEMOPHILIA A (mild-moderate, Factor VIII >5%):
                0.3 mcg/kg IV over 15–30 min. Repeat dosing q12–24h (tachyphylaxis limits). For procedures: administer 30–60 min before.

                CENTRAL DIABETES INSIPIDUS (perioperative polyuria):
                IV/SQ: 1–2 mcg per dose, q12h (total 2–4 mcg/day). Titrate to urine output. MUCH lower dose than hemostatic — do NOT confuse.
                Intranasal: 10–40 mcg q8–12h.
                Oral (chronic management): 0.1–1.2 mg/day divided.

                NOCTURNAL ENURESIS: 0.2–0.4 mg PO at bedtime.

                REPEAT DOSING NOTE: 24h minimum between hemostatic doses to allow vWF replenishment. Tachyphylaxis is predictable — plan for alternative hemostatic agents (TXA, FFP, cryo) if second dose needed acutely.
                """,
            cautions: [
                "HYPONATREMIA (dilutional): Most significant perioperative risk. DDAVP V2 → water retention → ↓serum Na⁺. Risk highest with: free water loading, pediatric patients, elderly, postoperative period (↑ADH state), multiple doses. Monitor serum Na⁺ with repeat dosing. Restrict free water intake after administration. Severe hyponatremia → seizures.",
                "TACHYPHYLAXIS: Rapid depletion of vWF/FVIII stores with repeat dosing. Second dose <24h → significantly blunted response. Third dose → minimal effect. Plan hemostatic strategy accordingly — transition to factor concentrates or antifibrinolytics for ongoing needs.",
                "TYPE IIB VWD — ABSOLUTE CONTRAINDICATION: DDAVP releases abnormal vWF in type IIB → binds platelets with abnormally high affinity → platelet clumping → worsening thrombocytopenia. Can precipitate severe thrombocytopenia.",
                "CARDIOVASCULAR: Mild hypotension, facial flushing, reflex tachycardia during infusion (especially if given rapidly). Rare: thrombotic events (arterial/venous) — use caution in patients with known thrombophilia or active thrombotic disease.",
                "RENAL IMPAIRMENT (severe, CrCl <10): V2 antidiuretic effect unpredictable; risk of profound hyponatremia.",
                "CI: Type IIB or platelet-type VWD; hemodynamically unstable patients (hypotension risk); hypersensitivity to desmopressin."
            ],
            pearls: [
                "HEMOSTATIC INDICATIONS — perioperative: VWD type 1 (most responsive), acquired platelet dysfunction (uremia, aspirin/NSAID use, cardiac surgery CPB-related platelet dysfunction), mild Hemophilia A. Less effective for type 2A/2B VWD and type 3 (severe deficiency).",
                "CARDIAC SURGERY: DDAVP 0.3 mcg/kg reduces postoperative bleeding in patients with aspirin use or CPB-induced platelet dysfunction. Often combined with TXA (antifibrinolytic) for synergistic hemostasis. Evidence for routine use is mixed — target to platelet dysfunction identified on TEG/ROTEM.",
                "TACHYPHYLAXIS STRATEGY: First dose is most effective. For planned procedures with anticipated ongoing hemostatic need, give first dose then PLAN for alternative agents (cryo for vWF replenishment, FVIII concentrate for Hemophilia A). Stagger doses ≥24h if repeat DDAVP is used.",
                "HYPONATREMIA PREVENTION: Fluid restrict to maintenance or less for 24h after DDAVP administration. Check baseline Na⁺ before dosing in elderly or at-risk patients. Pediatric patients are especially vulnerable.",
                "INTRANASAL vs. IV: Stimate (1.5 mg/mL) is the hemostatic intranasal formulation — do NOT substitute with DDAVP nasal spray (0.1 mg/mL, used for enuresis) — 15× concentration difference. Confirm correct concentration before use."
            ],
            colorKey: "anticoagulant",
            tallManLetters: "desMOPRESSin",
            reversal: "No specific antidote; hyponatremia treated with fluid restriction ± 3% NaCl if severe"),
    ]
}
