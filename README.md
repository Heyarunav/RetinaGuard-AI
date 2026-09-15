# Retina Guard AI 👁️🩺
> **Explainable AI Tele-Ophthalmology & ABDM-Integrated Diabetic Retinopathy Triage for Rural Primary Healthcare**
> *Developed for Smart India Hackathon 2026 | Theme: MedTech / BioTech / HealthTech*

[![ABDM Compliant](https://img.shields.io/badge/ABDM-FHIR%20v4.0.1-blue.svg)](https://abdm.gov.in/)
[![Platform](https://img.shields.io/badge/Platform-MATLAB%20%7C%20ONNX-orange.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Release](https://img.shields.io/badge/Release-v1.0--stable--ui-brightgreen.svg)](https://github.com/Heyarunav/RetinaGuard-AI/releases)

---

## 📌 Executive Summary
Over 77 million individuals in India suffer from diabetes, yet rural Community Health Centers (CHCs) face an **80% shortfall of specialist ophthalmologists** (MoHFW Rural Health Statistics). 

**Retina Guard AI** is an edge-native tele-triage gateway designed for rural Ayushman Arogya Mandirs (Sub-Centers). It enables grassroots ASHA workers to conduct 2-minute non-mydriatic diabetic retinopathy screenings using low-cost smartphone optical adapters (<₹3,000), completely offline.

---

## ⚡ Key Architectural Innovations
* **Biological Anti-Spoofing & Quality Gate:** Automatically rejects blurry captures, room photos, and web screenshots using aspect ratio filtering ($0.72 \le \text{AR} \le 1.38$), corner aperture checks, and HSV hemoglobin reflectance profiling before running inference.
* **Dual-Interface Mode (ASHA vs. Doctor):** 
  * *👨‍⚕️ Doctor Mode:* Displays granular ETDRS microaneurysm/hemorrhage densities and Layer-4 Grad-CAM activation heatmaps.
  * *👩‍⚕️ ASHA Worker Mode:* Replaces medical jargon with an actionable 3-step checklist (✅ Clear / ⚠️ Alert / ❌ Danger) and universal traffic light protocols (🟢 Safe / 🟡 Review / 🔴 Urgent Referral).
* **Multimodal Oculomics Engine:** Binds retinal vascular lesion densities with patient clinical history (HbA1c & Blood Pressure) to triage secondary risks of diabetic nephropathy and microvascular stroke.
* **Offline-First Store-and-Forward Architecture:** Functions 100% offline at remote sub-centers. Scans and diagnostics queue in local encrypted storage and auto-sync when network connectivity is restored.
* **ABDM & e-Sanjeevani Tele-Bridge:** Automatically constructs HL7 FHIR v4.0.1 `DiagnosticReport` JSON bundles linked to the patient's 14-digit ABHA ID and pushes trilingual alerts (English + Hindi + Regional State Script).

---

## 🚀 Quick Start (Running Locally)

### Prerequisites
* MATLAB R2021a or newer (Tested on macOS / Windows / Linux)
* Image Processing Toolbox
* Deep Learning Toolbox

### Installation
1. Clone the stable release repository:
   ```bash
   git clone [https://github.com/Heyarunav/RetinaGuard-AI.git](https://github.com/Heyarunav/RetinaGuard-AI.git)
   cd RetinaGuard-AI
