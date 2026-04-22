import Foundation

struct DrugCard: Identifiable {
    let id = UUID()
    let name: String
    let category: DrugCategory
    let mechanism: String
    let onset: String
    let duration: String
    let dosing: String
    let cautions: [String]
    let pearls: [String]
    let colorKey: String
}

enum DrugCategory: String, CaseIterable, Identifiable {
    case induction    = "Induction"
    case volatile     = "Volatile"
    case nmb          = "NMB"
    case opioid       = "Opioid"
    case local        = "Local Anesthetic"
    case vasopressor  = "Vasopressor"
    case reversal     = "Reversal"
    case emergency    = "Emergency"
    case methBlue     = "Methylene Blue"
    var id: String { rawValue }
}

struct DrugCardLibrary {
    static let all: [DrugCard] = [
        
        // ── INDUCTION ─────────────────────────────────────────────────────────
        DrugCard(name: "Propofol", category: .induction,
                 mechanism: "GABA-A agonist. Enhances inhibitory neurotransmission. Antiemetic at sub-hypnotic doses. Rapid redistribution from CNS.",
                 onset: "30–60 seconds IV",
                 duration: "5–10 min (single bolus); context-sensitive with infusion",
                 dosing: "Induction: 1–2.5 mg/kg IV. Elderly/ASA III–IV: 1 mg/kg. TIVA maintenance: 4–12 mg/kg/hr (GA), 25–75 mcg/kg/min. Sedation: 25–50 mcg/kg/min. Vial: 10 mg/mL (1%).",
                 cautions: ["Significant hypotension (↓SVR, ↓CO) — reduce rate in elderly/hemodynamically unstable", "Apnea on induction — have airway equipment ready", "Propofol infusion syndrome with >4 mg/kg/hr for >48 hours (lactic acidosis, lipemia, cardiac failure)", "Pain on injection — use antecubital vein, pretreat with lidocaine 40 mg IV", "Egg/soy allergy — theoretical; not a true contraindication but worth noting"],
                 pearls: ["Gold standard for TIVA — predictable kinetics with Marsh/Schnider TCI models", "Antiemetic at 10–20 mcg/kg/min sub-anesthetic infusion", "Context-sensitive half-time increases with infusion duration — plan emergence accordingly", "BIS 40–60 for GA; 60–80 for sedation", "Can be combined with ketamine 1:1 ratio (Ketofol) to offset hemodynamic depression"],
                 colorKey: "induction"),
        
        DrugCard(name: "Ketamine", category: .induction,
                 mechanism: "Non-competitive NMDA receptor antagonist. Produces dissociative anesthesia. Sympathomimetic — indirect catecholamine release. Bronchodilator via β-adrenergic pathway.",
                 onset: "1–2 min IV; 3–5 min IM",
                 duration: "10–20 min (IV bolus); 20–45 min (IM)",
                 dosing: "Induction IV: 1–2 mg/kg. IM: 4–6 mg/kg. Sub-dissociative analgesia: 0.1–0.5 mg/kg IV. TIVA adjunct infusion: 0.1–0.5 mg/kg/hr. Intranasal pedi: 3–5 mg/kg.",
                 cautions: ["Emergence delirium/dysphoria (~12%) — pretreat with midazolam 0.03–0.05 mg/kg", "Hypersalivation — add glycopyrrolate or atropine", "Raises heart rate, BP, ICP — use with caution in uncontrolled HTN, severe CAD, elevated ICP", "Does NOT reliably protect airway — maintain patient positioning; have suction available", "Increases PVR — caution in right heart failure or pulmonary HTN"],
                 pearls: ["Drug of choice for hemodynamically unstable induction (trauma, sepsis, hypovolemia)", "Ideal in reactive airway disease — bronchodilation via β2 pathway", "Sub-dissociative dose (0.3 mg/kg) provides analgesia comparable to morphine 0.1 mg/kg", "NMDA antagonism reduces opioid consumption and may decrease opioid tolerance", "Ketofol (ketamine + propofol 1:1) balances hemodynamic stability with smooth emergence"],
                 colorKey: "induction"),
        
        DrugCard(name: "Etomidate", category: .induction,
                 mechanism: "Carboxylated imidazole. GABA-A agonist at β2 and β3 subunits. Minimal cardiovascular effects — no release of histamine or catecholamines.",
                 onset: "30–60 seconds IV",
                 duration: "3–5 min",
                 dosing: "Induction: 0.2–0.3 mg/kg IV. Elderly/sick: 0.15–0.2 mg/kg. No maintenance infusion recommended.",
                 cautions: ["Adrenal cortical suppression — single induction dose inhibits 11β-hydroxylase for 4–8 hours; controversial for critically ill", "Myoclonus on induction in ~30% — pretreat with fentanyl or midazolam", "PONV — higher incidence than propofol", "Pain on injection — avoid small veins", "Not for total IV maintenance — prolonged use causes severe adrenal suppression"],
                 pearls: ["Hemodynamically neutral — ideal for cardiac disease, aortic stenosis, severe LV dysfunction, trauma", "Maintains cerebral perfusion pressure — useful in TBI/elevated ICP", "Does not trigger malignant hyperthermia", "Preserved airway reflexes more than propofol at equivalent doses", "Consider single-dose adrenal consequences in critically ill patients requiring ongoing steroid support"],
                 colorKey: "induction"),
        
        // ── VOLATILE ──────────────────────────────────────────────────────────
        DrugCard(name: "Sevoflurane", category: .volatile,
                 mechanism: "Halogenated methyl isopropyl ether. Potentiates GABA-A and glycine receptors; inhibits NMDA and nAChR. Low blood:gas coefficient enables rapid titration.",
                 onset: "Rapid — blood:gas coefficient 0.65",
                 duration: "Offset proportional to duration; low CSHT for moderate cases",
                 dosing: "MAC: 2.0% (age-corrected). Pediatric inhalation induction: 6–8% in 100% O₂ via tight-fitting mask. MAC-awake: ~0.65%. Typical intraop: 1.5–2.5% with air/O₂.",
                 cautions: ["MH trigger — absolutely contraindicated in susceptible individuals; use dantrolene immediately if suspected", "Compound A formation in soda lime at low flow rates (>2 L/min fresh gas recommended)", "Dose-dependent cardiovascular depression (↓SVR, ↓MAP)", "Uterine relaxation — relevant in obstetric cases", "QTc prolongation at higher MAC values"],
                 pearls: ["Preferred volatile for pediatric mask induction — non-pungent, rapid and smooth", "Age-corrected MAC decreases ~6% per decade after 40", "Ischemic preconditioning properties — may be cardioprotective", "Fastest offset of ethers after short cases; desflurane slightly faster after long cases", "BIS-guided monitoring reduces awareness risk and speeds emergence"],
                 colorKey: "volatile"),
        
        DrugCard(name: "Desflurane", category: .volatile,
                 mechanism: "Fluorinated ether. Ultra-low blood:gas coefficient (0.42) gives the fastest onset and offset of all clinical volatiles. Requires heated vaporizer (boiling point 22.8°C).",
                 onset: "Very rapid — blood:gas 0.42",
                 duration: "Fastest offset of all volatiles; context-insensitive half-time",
                 dosing: "MAC: 6.0–7.3% (age-corrected). Typical: 4–8%. Not for inhalation induction — severe airway irritant. Requires Tec 6 or equivalent heated vaporizer.",
                 cautions: ["Severe airway irritant — laryngospasm, coughing, breath-holding if used for induction or in awake patients", "Sympathetic stimulation on rapid concentration increases (>1 MAC/min) — use desflurane at stable concentrations", "MH trigger", "High global warming potential — significant environmental concern (2500× CO₂ over 100 years)", "Requires special heated pressurized vaporizer — not interchangeable with other vaporizers"],
                 pearls: ["Best choice for rapid emergence after long cases (>4 hours) — context-insensitive half-time stays predictable", "Minimal hepatic metabolism (<0.02%) — ideal in hepatic disease", "Fastest return of cognitive function vs sevoflurane in studies of long-duration anesthesia", "Lower solubility = more precise titration via end-tidal monitoring", "Consider environmental impact — many institutions moving away from desflurane"],
                 colorKey: "volatile"),
        
        // ── NMB ───────────────────────────────────────────────────────────────
        DrugCard(name: "Succinylcholine", category: .nmb,
                 mechanism: "Depolarizing NMB. Structural analog of ACh — binds nicotinic receptor at NMJ causing sustained depolarization (Phase I block). Fasciculations reflect initial unsynchronized depolarization.",
                 onset: "45–60 seconds IV; ~3 min IM",
                 duration: "8–12 min (plasma cholinesterase metabolism); prolonged if pseudocholinesterase deficiency",
                 dosing: "Adult intubation: 1.5 mg/kg IV. Pediatric: 2 mg/kg IV (higher volume of distribution). IM: 4 mg/kg (pedi). Pretreatment: non-depolarizing NMB at 10% of intubating dose may reduce fasciculations.",
                 cautions: ["Hyperkalemia — benign +0.5 mEq/L normally; life-threatening in burns (>48h), massive crush injury, prolonged immobilization, upper/lower motor neuron lesions, severe sepsis", "MH trigger — avoid in susceptible patients", "Bradycardia (especially second dose in pedi) — pretreat with atropine", "Raises ICP, IOP, and intragastric pressure transiently", "Prolonged block (hours) with hereditary or acquired pseudocholinesterase deficiency"],
                 pearls: ["Still gold standard for RSI — fastest onset plus self-terminating short duration remains unmatched", "Dibucaine number determines pseudocholinesterase activity (normal >70; heterozygous ~60; homozygous ~20)", "Avoid >24–72h post-burn or after denervation injury — time window critical", "Last resort in can't-intubate-can't-oxygenate (CICO) — succinylcholine allows return of spontaneous ventilation", "Rocuronium 1.2 mg/kg + sugammadex 16 mg/kg is a valid alternative when succinylcholine is contraindicated"],
                 colorKey: "nmb"),
        
        DrugCard(name: "Rocuronium", category: .nmb,
                 mechanism: "Aminosteroid non-depolarizing NMB. Competitive ACh antagonist at nicotinic receptors. Modified structure gives faster onset than vecuronium without cardiovascular side effects.",
                 onset: "Intubation (0.6 mg/kg): 2–3 min. RSI (1.2 mg/kg): ~60 seconds",
                 duration: "0.6 mg/kg: 30–60 min. 1.2 mg/kg: 60–90 min. Prolonged in hepatic dysfunction.",
                 dosing: "Intubation: 0.6 mg/kg. RSI (succinylcholine equivalent onset): 1.2 mg/kg. Maintenance: 0.1–0.2 mg/kg. Infusion: 5–12 mcg/kg/min.",
                 cautions: ["Most common NMB implicated in anaphylaxis — IgE-mediated, can be severe", "Prolonged duration in hepatic dysfunction (primary hepatic elimination)", "Duration extended by volatile anesthetics, aminoglycosides, magnesium, hypothermia", "Residual block contributes to postop pulmonary complications — confirm TOF ratio >0.9 before extubation"],
                 pearls: ["Preferred non-depolarizing agent for RSI when succinylcholine contraindicated", "Fully reversible at ANY depth with sugammadex (16 mg/kg for immediate reversal)", "Rocuronium-sugammadex paradigm has effectively replaced succinylcholine at many institutions", "More reliable T1 depression than vecuronium at equivalent doses", "Sugammadex 16 mg/kg can reverse 1.2 mg/kg rocuronium within 3 minutes of administration"],
                 colorKey: "nmb"),
        
        DrugCard(name: "Sugammadex", category: .reversal,
                 mechanism: "Modified γ-cyclodextrin. Forms tight 1:1 inclusion complex with rocuronium or vecuronium, encapsulating the drug and removing it from the NMJ. No muscarinic effects.",
                 onset: "Within 2–3 minutes of administration",
                 duration: "Sustained — complex is renally excreted intact",
                 dosing: "Routine reversal (TOF ≥T2): 2 mg/kg. Deep block (T1 or PTC 1–2): 4 mg/kg. Immediate reversal after RSI dose of rocuronium: 16 mg/kg. All doses based on actual body weight.",
                 cautions: ["Renal impairment — sugammadex-rocuronium complex accumulates; use with caution in CrCl <30; avoid if anuric", "Affects progesterone-based contraceptives — advise patients to use barrier method for 7 days", "Hypersensitivity reactions reported (rare but severe)", "Does NOT work for benzylisoquinolinium NMBs (cisatracurium, atracurium) — use neostigmine"],
                 pearls: ["True pharmacologic antidote — the only NMB reversal agent that works at any block depth", "16 mg/kg reverses complete neuromuscular block from 1.2 mg/kg rocuronium within 3 minutes", "Eliminates concerns about residual NMB — NNT for preventing postop pulmonary complications favorable vs neostigmine", "No need to wait for spontaneous recovery — can reverse deep block immediately if needed for CICO", "Replace with rocuronium 24h after sugammadex if re-intubation needed; succinylcholine works immediately"],
                 colorKey: "reversal"),
        
        // ── OPIOIDS ───────────────────────────────────────────────────────────
        DrugCard(name: "Fentanyl", category: .opioid,
                 mechanism: "Synthetic μ-opioid receptor agonist. 100× more potent than morphine. Highly lipophilic — rapid CNS penetration. Redistributes to fat and muscle depots.",
                 onset: "1–2 min IV peak effect-site",
                 duration: "30–60 min (single bolus); context-sensitive half-life increases markedly with infusion",
                 dosing: "Induction: 1–3 mcg/kg IV. Infusion: 1–3 mcg/kg/hr. Intrathecal: 10–25 mcg. Epidural: 50–100 mcg. Intranasal: 1.5–2 mcg/kg (for procedural sedation).",
                 cautions: ["Respiratory depression — dose-dependent; titrate carefully", "Chest wall rigidity at high doses or rapid IV push — treat with NMB if severe", "Context-sensitive half-life increases significantly after prolonged infusion (e.g., 4h infusion = CSHT ~200 min)", "Serotonin syndrome risk with MAOIs or serotonergic agents"],
                 pearls: ["Workhorse of intraoperative analgesia — no histamine release unlike morphine", "Lipophilicity makes it ideal for epidural/intrathecal use with rapid onset", "Transdermal fentanyl patch not for acute/intraop use — only chronic pain management", "Intranasal route increasingly used prehospital and for pediatric procedural analgesia"],
                 colorKey: "opioid"),
        
        DrugCard(name: "Remifentanil", category: .opioid,
                 mechanism: "Ultra-short-acting μ-opioid agonist. Ester linkage cleaved by non-specific plasma and tissue esterases — completely context-insensitive metabolism.",
                 onset: "1–1.5 min",
                 duration: "5–10 min regardless of infusion duration (true context-insensitive)",
                 dosing: "TIVA infusion: 0.05–0.3 mcg/kg/min (use LBW in obesity). Bolus for laryngoscopy: 0.5–1 mcg/kg. Neuraxial surgery: 0.1–0.4 mcg/kg/min. ICU: 0.05–0.2 mcg/kg/min.",
                 cautions: ["Profound respiratory depression and apnea — anticipate at induction", "Bradycardia and hypotension — dose-dependent; have atropine/ephedrine ready", "Opioid-induced hyperalgesia with prolonged high-dose infusion — consider adjuncts", "No residual analgesia after stopping — MUST bridge to alternative before emergence", "Cannot be used as sole analgesic for postoperative pain"],
                 pearls: ["Ideal for neuromonitoring, remapping procedures, neurosurgery, ENT — off instantly on demand", "Context-insensitive half-time: 5–8 min regardless of whether it ran 20 min or 20 hours", "LBW dosing essential in obese patients — using total body weight causes profound respiratory depression", "Must plan transition analgesia (LA infiltration, ketorolac, acetaminophen, epidural) BEFORE stopping", "Remifentanil + propofol TIVA gives the most predictable emergence time of any anesthetic technique"],
                 colorKey: "opioid"),
        
        // ── LOCAL ANESTHETICS ────────────────────────────────────────────────
        
        DrugCard(name: "Lidocaine (Plain)", category: .local,
                 mechanism: "Amide local anesthetic. Blocks voltage-gated Na⁺ channels from the intracellular side in a use-dependent (frequency-dependent) fashion. Class Ib antiarrhythmic. Intermediate duration.",
                 onset: "Infiltration: 2–5 min. Epidural: 10–15 min. Spinal: 3–5 min. Topical: 2–5 min.",
                 duration: "Infiltration: 45–90 min. Epidural: 60–90 min. Spinal: 60–90 min (hyperbaric). IV systemic: short (context-sensitive).",
                 dosing: "Max dose plain: 4.5 mg/kg (300 mg absolute max). Infiltration: 0.5–1%. Peripheral nerve block: 1–1.5%. Epidural: 1.5–2%. Spinal: 1.5–5% hyperbaric. IV adjunct infusion: 1–2 mg/kg/hr. Topical 4%: airway analgesia 4 mg/kg max.",
                 cautions: ["CNS toxicity: circumoral numbness → tinnitus → visual disturbance → seizures → coma", "Cardiovascular toxicity: conduction delay, bradycardia, VT — less cardiotoxic than bupivacaine", "IV infusion: monitor for LAST — QRS widening, neurologic symptoms", "Caution in hepatic disease (amide metabolism)", "Methemoglobinemia risk with topical use — especially in pediatrics and combined with benzocaine"],
                 pearls: ["Most versatile LA — used topically, infiltration, epidural, spinal, IV adjunct, antiarrhythmic", "IV lidocaine 1.5 mg/kg blunts hemodynamic response to laryngoscopy (give 90s before)", "IV infusion (1–2 mg/kg/hr) provides opioid-sparing analgesia and reduces postop ileus", "Alkalinization (add NaHCO₃ 1 mEq per 10 mL) accelerates epidural onset by 2–3 min", "Topical 4% lidocaine excellent for awake FOB — spray-as-you-go technique", "Eutectic mixture with prilocaine (EMLA) for topical skin analgesia"],
                 colorKey: "local"),
        
        DrugCard(name: "Lidocaine with Epinephrine", category: .local,
                 mechanism: "Lidocaine + epinephrine (typically 1:100,000 = 10 mcg/mL or 1:200,000 = 5 mcg/mL). Epinephrine causes local vasoconstriction: reduces systemic LA absorption, prolongs block duration, and serves as intravascular injection marker.",
                 onset: "Similar to plain but slightly faster due to reduced washout",
                 duration: "Infiltration: 2–4 hours (significantly prolonged vs plain). Epidural: 90–120 min.",
                 dosing: "Max dose with epinephrine: 7 mg/kg lidocaine (500 mg absolute max). Standard premixed: 1% or 2% lidocaine + 1:100,000 epi. Test dose: 3 mL of 1.5% lido + 1:200,000 epi = 45 mg + 15 mcg epi.",
                 cautions: ["Do NOT use in end-artery territories: digits, penis, ear, nose, tip of tongue — risk of ischemic necrosis", "Avoid in patients on non-selective beta-blockers — unopposed alpha effect can cause hypertension", "Cardiac arrhythmias from systemic epinephrine absorption — most problematic in volatile-anesthetized patients", "Intravascular injection of epi component causes tachycardia/hypertension — monitor as test dose response"],
                 pearls: ["Epinephrine test dose: IV injection marker — HR increase >20 bpm in 60s suggests intravascular placement", "Extends infiltration duration 2–4× vs plain lidocaine", "Standard for epidural test dose — 3 mL of 1.5% lido + 1:200,000 epi", "Dilute concentrations (1:400,000 to 1:200,000) sufficient for most nerve blocks — higher concentrations add vasoconstriction without added benefit", "Alkalinization shortens onset: add 1 mL of 8.4% NaHCO₃ per 10 mL of lido/epi"],
                 colorKey: "local"),
        
        DrugCard(name: "Bupivacaine (Plain)", category: .local,
                 mechanism: "Long-acting amide LA. High lipid solubility and protein binding (96%) — slow dissociation from Na⁺ channels produces prolonged block. Differential sensory > motor block at low concentrations.",
                 onset: "Infiltration: 5–10 min. Epidural: 15–25 min. Spinal: 5 min.",
                 duration: "Infiltration: 3–8 hours. Epidural: 2–4 hours. Spinal (isobaric): 2–4 hours. Spinal (hyperbaric): 1.5–3 hours.",
                 dosing: "Max dose plain: 2.5 mg/kg (175 mg absolute max). Spinal: 0.5% hyperbaric or isobaric 1.5–3 mL (7.5–15 mg). Epidural labor: 0.0625–0.125%. Epidural surgical: 0.25–0.5%. Peripheral nerve block: 0.25–0.5%.",
                 cautions: ["Cardiotoxic — wide complex dysrhythmia, refractory VF difficult to treat. Far more cardiotoxic than lidocaine due to slow dissociation from cardiac Na⁺ channels ('fast-in, slow-out')", "Never give as IV bolus — even small doses can cause cardiac arrest", "Preferentially blocks cardiac over CNS in toxicity — patient may arrest without prior seizure", "Resuscitation from bupivacaine cardiac arrest is prolonged — have Intralipid 20% immediately available"],
                 pearls: ["Gold standard for spinal anesthesia in OB and surgical procedures", "Hyperbaric (0.5% + 8% dextrose) vs isobaric: baricity affects block spread — position-dependent", "Differential block at 0.0625–0.125% (sensory > motor) ideal for labor epidurals", "Liposomal bupivacaine (Exparel®) provides extended release up to 72 hours for infiltration and some nerve blocks", "Treat LAST immediately with Intralipid 20% 1.5 mL/kg bolus — do not wait for confirmation"],
                 colorKey: "local"),
        
        DrugCard(name: "Bupivacaine Hyperbaric (0.5%)", category: .local,
                 mechanism: "Bupivacaine 0.5% formulated with 8% dextrose — specific gravity ~1.023, heavier than CSF (~1.003). Block spread influenced by patient position and table tilt (baricity-driven).",
                 onset: "3–5 min spinal",
                 duration: "Spinal: 1.5–2.5 hours (shorter than isobaric due to dilution in CSF)",
                 dosing: "Spinal C-section: 1.4–1.6 mL (10.5–12 mg) + fentanyl 15–25 mcg + morphine 100–200 mcg. Spinal lower extremity surgery: 0.5–1.5 mL (3.75–11.25 mg). Saddle block: 0.5 mL seated.",
                 cautions: ["Over-sedation with intrathecal morphine — monitor for 12–24h for delayed respiratory depression", "High spinal risk if head-down (Trendelenburg) position used immediately after injection — can cause apnea and bradycardia", "Hypotension is predictable with higher spinal levels (T4 for OB) — prepare vasopressors before injection", "Total spinal if intrathecal dose inadvertently placed at high cervical level"],
                 pearls: ["Workhorse for spinal anesthesia in the US — most common drug used for C-section spinal", "Baricity matters: lateral to supine after injection allows unilateral block; early repositioning prevents fixed asymmetry", "Epinephrine 100–200 mcg intrathecal extends duration ~20–30 min", "Intrathecal morphine (100–200 mcg) provides 12–24h of post-C-section analgesia", "Pencil-point needles (Whitacre 25G, Sprotte 24G) significantly reduce PDPH vs cutting-bevel Quincke"],
                 colorKey: "local"),
        
        DrugCard(name: "Liposomal Bupivacaine (Exparel®)", category: .local,
                 mechanism: "Bupivacaine encapsulated in multivesicular DepoFoam lipid particles. Slow, sustained release over 72 hours as lipid layers erode. Provides prolonged local tissue analgesia without systemic LA toxicity profile of bolus dosing.",
                 onset: "Initial release within 30 min; sustained release over 24–72 hours",
                 duration: "Up to 72 hours for local infiltration. Some nerve block indications: 24–48 hours.",
                 dosing: "Infiltration: 266 mg (20 mL) diluted with up to 280 mL NS. Interscalene block: 133 mg (10 mL) diluted. TAP block: 266 mg (20 mL). NOT approved for spinal or epidural use. Do NOT mix with bupivacaine HCl — accelerates drug release. Can be mixed with normal saline or bupivacaine 0.5% within 30 minutes.",
                 cautions: ["High cost — justify with anticipated analgesic benefit vs multimodal alternatives", "Do NOT use for neuraxial (intrathecal/epidural) — not approved and potentially neurotoxic", "Do NOT mix with other local anesthetics except bupivacaine HCl (diluted, max 0.89 mg/mL)", "Same max dose toxicity concerns as bupivacaine — monitor for LAST", "Limited evidence for superiority over liposome-free bupivacaine + adjuncts in some block types"],
                 pearls: ["Best evidence for infiltration analgesia in hip arthroplasty, bunionectomy, hemorrhoidectomy, C-section wound infiltration", "TAP block application increasingly popular for abdominal surgery opioid-sparing", "Does not require catheter — single injection provides extended coverage", "Per the manufacturer: do not add epinephrine — increases release rate and reduces duration", "Insurance coverage and cost often limit use — ensure prior authorization in elective surgical settings"],
                 colorKey: "local"),
        
        DrugCard(name: "Ropivacaine", category: .local,
                 mechanism: "Pure S-enantiomer amide LA. Similar mechanism to bupivacaine but stereoselective cardiac Na⁺ channel binding produces less cardiotoxicity. Intrinsic vasoconstriction reduces systemic absorption.",
                 onset: "Epidural: 15–20 min. Peripheral nerve block: 15–30 min.",
                 duration: "Epidural: 3–5 hours. Peripheral nerve block: 6–12 hours (concentration-dependent).",
                 dosing: "Max dose: 3 mg/kg (225 mg). Epidural: 0.1–0.2% for analgesia; 0.5–1% for surgical block. Peripheral nerve block: 0.375–0.75%. Thoracic epidural: 0.2% at 5–10 mL/hr. Spinal: NOT commonly used intrathecally in US.",
                 cautions: ["Still cardiotoxic in overdose — less so than bupivacaine but not risk-free", "LAST remains a risk — monitor for CNS/cardiac symptoms with large doses", "Intrinsic vasoconstriction means adding epinephrine provides less additional benefit than with lidocaine", "Slower onset than lidocaine — plan block timing accordingly"],
                 pearls: ["Preferred for continuous nerve block catheters — less motor block than bupivacaine at equivalent sensory block", "Excellent choice for thoracic epidurals — preserves respiratory muscle function better than equipotent bupivacaine", "0.2% concentration gives differential sensory > motor block ideal for postoperative epidural infusions", "Vasoconstriction is an advantage: longer duration without epinephrine compared to lidocaine without epi", "More forgiving cardiovascular profile than bupivacaine in interscalene and other high-risk injection sites"],
                 colorKey: "local"),
        
        DrugCard(name: "Mepivacaine", category: .local,
                 mechanism: "Amide LA. Intermediate potency and duration. Less vasodilation than lidocaine — intrinsically more vasoconstricted than lidocaine, giving slightly longer duration without epinephrine.",
                 onset: "Faster than bupivacaine; similar to lidocaine. Infiltration: 3–5 min. Peripheral block: 10–20 min.",
                 duration: "Infiltration plain: 90–150 min. With epi: 3–4 hours. Peripheral nerve block: 2–5 hours.",
                 dosing: "Max plain: 5 mg/kg (300 mg). Max with epi: 7 mg/kg (500 mg). Peripheral nerve block: 1–1.5% (100–150 mg per injection site). Dental: 3% plain or 2% with 1:20,000 levonordefrin.",
                 cautions: ["Neonatal toxicity — crosses placenta and is slowly metabolized by neonates; avoid obstetric use", "Standard LAST risk profile for amide LAs — monitor CNS/cardiac symptoms", "Not for obstetric use (paracervical or epidural) due to prolonged neonatal half-life"],
                 pearls: ["Good choice for outpatient peripheral nerve blocks requiring intermediate duration without prolonged motor block", "Faster onset than bupivacaine with longer duration than lidocaine (no-epi scenarios)", "Dental anesthesia standard in the US — mepivacaine 3% cartridges widely used", "Useful when epinephrine is contraindicated but longer duration than plain lidocaine is needed", "Less vasodilation than lidocaine = better block quality in poorly perfused tissue"],
                 colorKey: "local"),
        
        DrugCard(name: "Chloroprocaine (NESACAINE®)", category: .local,
                 mechanism: "Ester LA. Hydrolyzed rapidly by plasma cholinesterase (half-life ~25 seconds) — lowest systemic toxicity of all clinical LAs. Minimal placental transfer.",
                 onset: "Rapid — epidural onset 5–10 min. Infiltration: 2–5 min.",
                 duration: "Very short — 30–60 min epidural. 30–45 min infiltration.",
                 dosing: "Epidural extension for C-section: 3% chloroprocaine 15–20 mL (rapid onset). Epidural test dose: 3 mL 3%. Infiltration/nerve block: 1–2% (not common). NOT recommended for spinal (neurotoxicity concerns with preservative-free formulations historically; currently preserved-free is acceptable).",
                 cautions: ["Preservative (sodium bisulfite/EDTA) formulations associated with historical neurotoxicity reports — use preservative-free for any neuraxial application", "Antagonizes epidural opioids — do not mix with morphine/fentanyl neuraxially; chloroprocaine occupies binding sites", "Tachyphylaxis develops faster than with other LAs — rotation may be needed for prolonged epidural use", "Hypocalcemia risk with EDTA-containing formulations (chelates calcium)"],
                 pearls: ["Drug of choice for urgent epidural extension in OB — fastest onset of any epidural LA (5–10 min to T4)", "Minimal placental transfer — ideal for any case requiring rapid fetal delivery", "Rapid plasma hydrolysis = lowest systemic toxicity profile — excellent safety for failed spinal rescue epidural", "3% concentration maximizes speed of onset for C-section conversion", "After chloroprocaine epidural, wait 30+ min before epidural opioid due to receptor antagonism"],
                 colorKey: "local"),
        
        DrugCard(name: "Tetracaine", category: .local,
                 mechanism: "Long-acting ester LA. High lipid solubility and potency — most potent ester LA. Metabolized by plasma cholinesterase (slower than chloroprocaine). Primary use: spinal anesthesia.",
                 onset: "Spinal: 3–5 min",
                 duration: "Spinal isobaric/hyperbaric: 2–4 hours (significantly longer than lidocaine spinal)",
                 dosing: "Spinal only (primary use in US): 0.5% isobaric or 0.5–1% hyperbaric (with dextrose). Dose: 6–20 mg depending on level needed. Ophthalmology: 0.5% topical drops.",
                 cautions: ["High systemic toxicity if absorbed — NOT for infiltration or nerve blocks", "Ester LA — contraindicated in allergy to PABA or aminobenzoic acid derivatives", "Largely replaced in the US by bupivacaine for spinal due to better availability and dosing familiarity", "Shorter duration than bupivacaine in some studies — verify duration expectations"],
                 pearls: ["Traditional gold standard for spinal anesthesia before bupivacaine became prevalent", "Still used in some institutions for prolonged urological procedures where long spinal duration is desired", "Ophthalmologic 0.5% drops widely used for corneal analgesia in procedural ophthalmology", "Epinephrine (0.2 mg) added to tetracaine spinal significantly prolongs duration by ~30–45 min", "Knowledge of tetracaine is important for boards (USMLE/COMLEX) — classic teaching drug for spinal anesthesia history"],
                 colorKey: "local"),
        
        DrugCard(name: "Cocaine (4–10%)", category: .local,
                 mechanism: "Naturally occurring ester LA. Unique dual mechanism: Na⁺ channel blockade (LA effect) + catecholamine reuptake inhibition (sympathomimetic vasoconstriction). Only LA with intrinsic vasoconstrictive properties.",
                 onset: "Topical nasal/airway: 2–5 min",
                 duration: "30–60 min topical",
                 dosing: "Topical only: 4% solution for ENT/nasal procedures (max 3 mg/kg, absolute max 200 mg). Applied via soaked pledgets or spray. NOT for infiltration, epidural, or spinal.",
                 cautions: ["Potent CNS stimulant and cardiovascular stimulant — tachycardia, hypertension, dysrhythmias", "Absolute contraindication: monoamine oxidase inhibitors (MAOIs) — hypertensive crisis", "Contraindicated in coronary artery disease, severe hypertension, hyperthyroidism", "Schedule II controlled substance — strict institutional controls", "Addictive potential — accounting and documentation requirements"],
                 pearls: ["Irreplaceable in certain ENT procedures — only LA with intrinsic vasoconstriction, providing simultaneous analgesia and a bloodless surgical field", "Preferred agent for awake nasal intubation and nasal endoscopy — vasoconstriction shrinks turbinates", "Alternative for nasal procedures: oxymetazoline (vasoconstriction) + lidocaine (analgesia) as two separate agents", "Urine drug screen positive for benzoylecgonine after clinical use — document clinical use in chart", "FDA-approved single-use 4% cocaine solution (Numbrino®) and cocaine HCl 4% are the standard clinical formulations"],
                 colorKey: "local"),
        
        // ── VASOPRESSORS ──────────────────────────────────────────────────────
        DrugCard(name: "Phenylephrine", category: .vasopressor,
                 mechanism: "Pure selective α1-adrenergic agonist. Vasoconstriction → ↑SVR → ↑MAP. No direct β effects — reflex bradycardia via baroreceptors as cardiac output may decrease.",
                 onset: "Immediate IV",
                 duration: "10–20 min (bolus)",
                 dosing: "Infusion: 0.5–3 mcg/kg/min. Bolus: 50–100 mcg (1 mcg/kg). OB spinal prophylaxis: start infusion at time of spinal, titrate to MAP ≥80% baseline.",
                 cautions: ["Reflex bradycardia — may require atropine/glycopyrrolate if symptomatic", "Reduced cardiac output in states requiring compensatory tachycardia (mitral stenosis, severe LV dysfunction)", "Coronary vasoconstriction at high doses"],
                 pearls: ["First-line vasopressor for spinal hypotension in obstetrics — preserves uteroplacental blood flow better than ephedrine", "Prophylactic infusion during OB spinal significantly reduces hypotension incidence vs reactive bolus dosing", "Pure α1 with no inotropy — avoid as sole vasopressor if low cardiac output is the etiology"],
                 colorKey: "vasopressor"),
        
        DrugCard(name: "Epinephrine", category: .vasopressor,
                 mechanism: "Endogenous catecholamine. α1, α2, β1, β2 agonist. Dose-dependent effects: low doses (≤0.05 mcg/kg/min) → β dominance (inotropy, ↑HR, bronchodilation); high doses → α dominance (vasoconstriction).",
                 onset: "Immediate IV",
                 duration: "Short — MAO and COMT metabolism",
                 dosing: "Anaphylaxis IM: 0.3–0.5 mg (1:1000). ACLS pulseless: 1 mg IV q3–5 min. Infusion: 0.01–0.5 mcg/kg/min. LA adjunct: 1:200,000–1:400,000 (2.5–5 mcg/mL).",
                 cautions: ["Tachyarrhythmias and dysrhythmias — especially combined with volatile anesthetics", "Hypertension at higher doses", "Tissue necrosis if extravasation from peripheral IV"],
                 pearls: ["Only drug with proven ROSC benefit in cardiac arrest — do not delay", "Drug of choice for anaphylaxis — give IM into lateral thigh", "Prolongs peripheral nerve block duration by local vasoconstriction reducing LA clearance"],
                 colorKey: "vasopressor"),
        
        // ── EMERGENCY ─────────────────────────────────────────────────────────
        DrugCard(name: "Dantrolene", category: .emergency,
                 mechanism: "Ryanodine receptor (RyR1) antagonist. Inhibits Ca²⁺ release from sarcoplasmic reticulum — directly halts the uncontrolled hypermetabolic cascade of malignant hyperthermia.",
                 onset: "Within minutes of IV administration",
                 duration: "Sustained — repeat dosing required in most MH crises",
                 dosing: "Initial: 2.5 mg/kg IV rapid bolus. Repeat q5 min as needed. Typical total: 5–10 mg/kg. Max documented total: 30 mg/kg. Each 20 mg vial needs 60 mL sterile water. Maintenance: 1 mg/kg q6h for 24–48h to prevent recurrence.",
                 cautions: ["Each 20 mg vial requires 60 mL sterile water — assign dedicated reconstitution team immediately", "Muscle weakness during/after treatment — monitor respiratory function", "Hepatotoxicity with prolonged oral use (not acute IV)", "Calcium channel blockers + dantrolene = risk of hyperkalemia and cardiovascular collapse"],
                 pearls: ["ONLY definitive treatment for MH — give IMMEDIATELY on clinical suspicion, do not wait for confirmation", "MH Hotline (US): 1-800-644-9737 (24/7 expert consultation)", "Trigger removal: stop all volatile anesthetics, stop succinylcholine, hyperventilate with 100% O₂ at 10 L/min", "Concurrent treatment: active cooling, treat hyperkalemia, treat dysrhythmias, correct acidosis, maintain UO >1 mL/kg/hr", "Also used for neuroleptic malignant syndrome (NMS) and serotonin syndrome with rigidity"],
                 colorKey: "emergency"),
        
        // -- METHYLENE BLUE -----------------------------------------------
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
                "Renal failure — elimination impaired; reduce dose and frequency in CKD; monitor for accumulation.",
                "High doses (>7 mg/kg total) → paradoxical methemoglobinemia from direct oxidation of Hgb; stay within dosing limits.",
                "Pulmonary vasoconstriction reported — use with caution in pulmonary HTN; can worsen RV afterload.",
                "NOT effective in G6PD deficiency MetHgb — use ascorbic acid 1 g IV or exchange transfusion.",
            ],
            pearls: [
                "Vasoplegic syndrome post-CPB: MB is first-line adjunct after norepinephrine ≥0.25 mcg/kg/min fails — targets the NO/cGMP pathway upstream of catecholamines.",
                "PROPHYLACTIC MB before CPB (1 mg/kg before bypass): RCT evidence shows reduced vasoplegic syndrome incidence and vasopressor requirements post-bypass.",
                "MetHgb reversal: response within 30 min — if no improvement, check G6PD status; repeat dose or consider exchange transfusion.",
                "Sentinel node / lymphatic mapping (breast, melanoma): intradermal injection guides surgical lymph node dissection; IV used for parathyroid identification.",
                "SEROTONIN TOXICITY RISK is the most dangerous perioperative concern — review ALL serotonergic medications preoperatively. Hold SSRIs/SNRIs if elective case permits.",
                "Co-oximetry ABG is mandatory for MetHgb monitoring — standard pulse oximetry is unreliable during and after MB infusion.",
                "Ifosfamide encephalopathy: MB reverses encephalopathy within hours (proposed mechanism: reversal of chloroacetaldehyde-induced mitochondrial dysfunction via electron carrier role).",
                "Intraoperative parathyroid ID: IV MB (5 mg/kg) selectively stains parathyroid tissue poorly vs surrounding tissue — allows visual identification during thyroid/parathyroid surgery.",
            ],
            colorKey: "emergency"
        )]
}

