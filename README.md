# Retina Guard AI 👁️🩺

> **Explainable AI Tele-Ophthalmology & ABDM-Integrated Diabetic Retinopathy Triage for Rural Primary Healthcare**  
> *Developed for Smart India Hackathon 2026 | Theme: MedTech / BioTech / HealthTech | Problem Statement ID: SIH26038*

[![ABDM Compliant](https://img.shields.io/badge/ABDM-FHIR%20v4.0.1-blue.svg)](https://abdm.gov.in/)
[![Platform](https://img.shields.io/badge/Platform-MATLAB%20%7C%20ONNX-orange.svg)](https://www.mathworks.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.0--stable--ui-brightgreen.svg)](https://github.com/Heyarunav/RetinaGuard-AI/releases)
[![Clinical Report](https://img.shields.io/badge/Whitepaper-Clinical%20Report%20(PDF)-red.svg)](docs/RetinaGuard_Clinical_Architecture_Report.pdf)
[![Video Demo](https://img.shields.io/badge/Demo-Video%20Walkthrough-critical.svg)](https://youtu.be/YOUR_VIDEO_ID)

> 📄 **[Click Here to Read the Full Clinical & SaMD Architecture Report (PDF)](docs/RetinaGuard_Clinical_Architecture_Report.pdf)**  
> 🎬 **[Click Here to Watch the Working Video Demonstration](https://youtu.be/p73fuM1iXHE)**[cite: 3]

---

## 📌 Executive Summary

Over **77 million individuals** in India live with diabetes, yet rural Community Health Centers (CHCs) face an **80% shortfall of specialist ophthalmologists** (MoHFW Rural Health Statistics). While teleconsultation platforms connect health centers, they encounter documented barriers when patients with low digital literacy cannot navigate interfaces independently (NCBI PMC11414145). Furthermore, commercial desktop fundus cameras costing ₹5,00,000 to ₹18,00,000 remain economically unviable for village-level deployment.

**Retina Guard AI** is an edge-native tele-triage gateway designed for rural Ayushman Arogya Mandirs (Sub-Centers). It enables grassroots ASHA workers to conduct 2-minute non-mydriatic diabetic retinopathy screenings using low-cost smartphone optical adapters (<₹3,000), running completely offline with zero cloud dependency.

---

## ⚡ Key Architectural Innovations

* **Biological Anti-Spoofing & Quality Gate:**  
  Hard-coded optical pre-screening gate evaluates aspect ratio ($0.72 \le \text{AR} \le 1.38$), corner aperture illumination thresholds (<45/255), and HSV hemoglobin reflectance ($H \in [0, 0.14] \cup [0.93, 1.0]$). It intercepts and rejects blurry captures, room photos, and web screenshots in <100ms before computational inference occurs, actively preventing AI hallucinations.

* **Dual-Interface Mode (ASHA vs. Doctor):**  
  * **👨‍⚕️ Doctor Mode:** Displays granular ETDRS microvascular lesion counts (microaneurysms, hemorrhages, exudates) and interactive Grad-CAM Layer-4 activation heatmaps.
  * **👩‍⚕️ ASHA Worker Mode:** Replaces clinical jargon with an actionable 3-step checklist (✅ Clear / ⚠️ Alert / ❌ Danger) and universal traffic-light protocols (🟢 Safe / 🟡 Review in 6 Months / 🔴 Urgent Referral).

* **Multimodal Oculomics Engine:**  
  Binds retinal vascular lesion densities with patient clinical history (HbA1c & Blood Pressure) to evaluate systemic capillary beds, providing early triage alerts for diabetic nephropathy and microvascular stroke.

* **Offline-First Store-and-Forward Architecture:**  
  Functions 100% offline at remote sub-centers on commodity laptops. Features an interactive network toggle (`ABDM ONLINE` vs. `OFFLINE LOCAL QUEUE`) that safely encrypts records in local AES-256 storage during rural connectivity drops and syncs automatically when reconnected[cite: 1, 2].

* **ABDM & e-Sanjeevani Tele-Bridge:**  
  Automatically constructs standardized **HL7 FHIR v4.0.1** `DiagnosticReport` JSON bundles linked to the patient's 14-digit ABHA ID and pushes trilingual alerts (English + Hindi + Regional State Script)[cite: 1, 2].

---

## 🚀 Quick Start (Running Locally)

### Prerequisites
* **MATLAB R2021a or newer** (Tested on macOS, Windows, and Linux)
* **Image Processing Toolbox** (Required for aperture detection & HSV color checks)
* **Deep Learning Toolbox** (Required for ONNX model inference & Grad-CAM)

### Installation & Launch

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/Heyarunav/RetinaGuard-AI.git](https://github.com/Heyarunav/RetinaGuard-AI.git)
   cd RetinaGuard-AI
