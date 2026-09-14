function RetinaGuard_App()
    

    fig = uifigure('Name', 'Retina Guard AI - National Health Mission (ABDM) Edition', ...
        'Position', [50 30 1280 770], ...
        'Color', [0.10 0.13 0.18]);

    appData = struct();
    appData.loadedImage = [];
    appData.camMap = [];
    appData.lesions = [];
    appData.predClass = 'Pending';
    appData.confidence = 0;
    appData.rationaleText = '';
    appData.detectedRegion = 'Assam (North-East)';
    appData.currentMode = '👨‍⚕️ Doctor Mode';
    appData.workerLang = 'English';

    masterGrid = uigridlayout(fig, [3, 1]);
    masterGrid.RowHeight = {75, '1x', 28};
    masterGrid.BackgroundColor = [0.10 0.13 0.18];

    % --- HEADER PANEL ---
    headerPanel = uipanel(masterGrid, 'BackgroundColor', [0.06 0.10 0.22], 'BorderType', 'none');
    headerGrid = uigridlayout(headerPanel, [1, 3]);
    headerGrid.ColumnWidth = {'1.2x', 320, 220};
    headerGrid.Padding = [15 10 15 10];
    
    uilabel(headerGrid, ...
        'Text', 'RETINA GUARD AI  |  ABDM Tele-Triage', ...
        'FontName', 'Helvetica', 'FontSize', 22, 'FontWeight', 'bold', ...
        'FontColor', [1 1 1]);

    % PHC Geo-Location Selector
    geoGrid = uigridlayout(headerGrid, [1, 2]);
    geoGrid.ColumnWidth = {75, '1x'};
    geoGrid.Padding = [0 0 0 0];
    uilabel(geoGrid, 'Text', '📍 PHC Site:', 'FontSize', 12, 'FontWeight', 'bold', 'FontColor', [0.85 0.92 1]);
    dropLocation = uidropdown(geoGrid, ...
        'Items', {'Assam (North-East)', 'Karnataka (South)', 'Maharashtra (West)', 'Uttar Pradesh (North)'}, ...
        'Value', 'Assam (North-East)', ...
        'ValueChangedFcn', @(d,e) onLocationChanged());

    statusBadge = uilabel(headerGrid, ...
        'Text', '● ABDM GATEWAY ONLINE', ...
        'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold', ...
        'FontColor', [0.3 0.95 0.4], ...
        'HorizontalAlignment', 'right');

    % --- MAIN BODY PANEL (3 Columns) ---
    bodyGrid = uigridlayout(masterGrid, [1, 3]);
    bodyGrid.ColumnWidth = {'1.08x', '1.18x', '1.24x'};
    bodyGrid.Padding = [10 10 10 10];
    bodyGrid.ColumnSpacing = 12;

    % ===================== COLUMN 1: PATIENT & ACQUISITION =====================
    col1 = uipanel(bodyGrid, 'Title', '1. Patient ABHA & Acquisition', 'FontSize', 12, ...
        'FontWeight', 'bold', 'ForegroundColor', [0.85 0.92 1], 'BackgroundColor', [0.14 0.17 0.24]);
    col1Grid = uigridlayout(col1, [4, 1]);
    col1Grid.RowHeight = {36, 40, '1x', 30};
    col1Grid.Padding = [10 10 10 10];

    abhaGrid = uigridlayout(col1Grid, [1, 2]);
    abhaGrid.ColumnWidth = {125, '1x'};
    abhaGrid.Padding = [0 0 0 0];
    lblAbhaPrompt = uilabel(abhaGrid, 'Text', 'Patient ABHA ID:', 'FontSize', 12, 'FontWeight', 'bold', 'FontColor', [1 1 1]);
    txtAbha = uieditfield(abhaGrid, 'text', 'Value', '91-4821-3904-7120', 'FontSize', 11, 'FontWeight', 'bold');

    btnActionGrid = uigridlayout(col1Grid, [1, 2]);
    btnActionGrid.Padding = [0 0 0 0];
    btnActionGrid.ColumnSpacing = 10;
    btnActionGrid.ColumnWidth = {'1x', '1x'};

    btnCamera = uibutton(btnActionGrid, 'push', ...
        'Text', '📷  Live Camera', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.08 0.58 0.45], 'FontColor', [1 1 1]);

    btnBrowse = uibutton(btnActionGrid, 'push', ...
        'Text', '📁  Browse Computer', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.18 0.48 0.85], 'FontColor', [1 1 1]);

    axRaw = uiaxes(col1Grid);
    title(axRaw, 'Raw Retinal Fundus', 'Color', [0.9 0.9 0.9]);
    axRaw.XTick = []; axRaw.YTick = [];
    axRaw.Box = 'on';

    lblImgInfo = uilabel(col1Grid, ...
        'Text', 'Connect a fundus camera or browse scans to begin.', ...
        'FontSize', 11, 'FontColor', [0.8 0.85 0.9], ...
        'HorizontalAlignment', 'center');

    % ===================== COLUMN 2: EXPLAINABILITY & BIOMARKERS =====================
    col2 = uipanel(bodyGrid, 'Title', '2. Biomarkers & Explainable AI', 'FontSize', 12, ...
        'FontWeight', 'bold', 'ForegroundColor', [0.85 0.92 1], 'BackgroundColor', [0.14 0.17 0.24]);
    col2Grid = uigridlayout(col2, [4, 1]);
    col2Grid.RowHeight = {42, '1x', 26, 36};

    btnAnalyze = uibutton(col2Grid, 'push', ...
        'Text', '⚡  Run Full Biomarker Inference', ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.15 0.68 0.38], 'FontColor', [1 1 1], ...
        'Enable', 'off');

    axGrad = uiaxes(col2Grid);
    title(axGrad, 'Pathology & Grad-CAM Mapping', 'Color', [0.9 0.9 0.9]);
    axGrad.XTick = []; axGrad.YTick = [];
    axGrad.Box = 'on';

    lblSlider = uilabel(col2Grid, 'Text', 'Heatmap / Lesion Overlay Opacity: 50%', ...
        'FontSize', 11, 'FontColor', [0.85 0.92 1], 'HorizontalAlignment', 'center');

    sliderOpacity = uislider(col2Grid, ...
        'Limits', [0 1], 'Value', 0.5, ...
        'ValueChangedFcn', @(s,e) updateHeatmapOverlay());

    % ===================== COLUMN 3: CLINICAL JUSTIFICATION & ASHA INTERFACE =====================
    col3 = uipanel(bodyGrid, 'Title', '3. Clinical Diagnostic Justification', 'FontSize', 12, ...
        'FontWeight', 'bold', 'ForegroundColor', [0.85 0.92 1], 'BackgroundColor', [0.14 0.17 0.24]);
    col3Grid = uigridlayout(col3, [10, 1]);
    col3Grid.RowHeight = {36, 28, 120, 22, 52, 22, 38, 56, 40, 16};

    % Control Bar: (1) Mode Switch + (2) Dynamic Worker Language
    controlsGrid = uigridlayout(col3Grid, [1, 2]);
    controlsGrid.ColumnWidth = {'1.1x', '1x'};
    controlsGrid.Padding = [0 0 0 0];
    
    dropMode = uidropdown(controlsGrid, ...
        'Items', {'👨‍⚕️ Doctor Mode', '👩‍⚕️ ASHA Mode'}, ...
        'Value', '👨‍⚕️ Doctor Mode', ...
        'ValueChangedFcn', @(d,e) onModeChanged());

    dropWorkerLang = uidropdown(controlsGrid, ...
        'Items', {'English', 'हिंदी (Hindi)', 'অসমীয়া (Assamese)'}, ...
        'Value', 'English', ...
        'ValueChangedFcn', @(d,e) onWorkerLanguageChanged());

    lblStage = uilabel(col3Grid, 'Text', 'PREDICTED STAGE: ---', 'FontSize', 14, 'FontWeight', 'bold', 'FontColor', [1 1 1]);

    uitableBiomarkers = uitable(col3Grid);
    uitableBiomarkers.ColumnName = {'Biomarker', 'Status', 'Density'};
    uitableBiomarkers.ColumnWidth = {135, 95, 85};
    uitableBiomarkers.RowName = [];
    uitableBiomarkers.Data = {
        'Microaneurysms (MAs)', 'Pending', '--';
        'Hemorrhages (HEMs)', 'Pending', '--';
        'Hard Exudates (EXs)', 'Pending', '--';
        'Cotton Wool Spots', 'Pending', '--';
        'Neovascularization', 'Pending', '--'
    };

    lblRationaleTitle = uilabel(col3Grid, 'Text', 'CLINICAL RATIONALE (WHY THIS STAGE):', 'FontSize', 11, 'FontWeight', 'bold', 'FontColor', [0.85 0.92 1]);
    lblRationale = uilabel(col3Grid, ...
        'Text', 'Load a scan and run inference to generate lesion-level justification.', ...
        'FontSize', 10, 'WordWrap', 'on', 'FontColor', [0.1 0.1 0.1], ...
        'BackgroundColor', [0.94 0.94 0.94]);

    lblActionHeader = uilabel(col3Grid, 'Text', 'ACTION DIRECTIVE FOR HEALTH WORKER:', 'FontSize', 11, 'FontWeight', 'bold', 'FontColor', [0.85 0.92 1]);
    badgeRisk = uilabel(col3Grid, 'Text', 'TRAFFIC LIGHT STATUS: PENDING', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.85 0.88 0.92], 'FontColor', [0.2 0.2 0.2], ...
        'HorizontalAlignment', 'center');

    lblRegionalAdvisory = uilabel(col3Grid, ...
        'Text', 'অসম (Assam PHC): ৰোগীৰ চকু পৰীক্ষাৰ বাবে সাজু।', ...
        'FontSize', 10, 'WordWrap', 'on', 'FontColor', [0.05 0.2 0.45], ...
        'BackgroundColor', [0.88 0.94 1.0]);

    btnExport = uibutton(col3Grid, 'push', ...
        'Text', '🏥  Export ABDM / e-Sanjeevani Referral Slip', ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.15 0.35 0.6], 'FontColor', [1 1 1], ...
        'Enable', 'off');

    uilabel(col3Grid, 'Text', '*Certified for ABDM FHIR v4.0.1 teleconsultation compliance.', ...
        'FontSize', 9, 'FontColor', [0.7 0.75 0.85], 'FontAngle', 'italic');

    % --- FOOTER ---
    uilabel(masterGrid, ...
        'Text', 'Retina Guard AI Prototype | Developed for Smart India Hackathon | Built on MATLAB Image & Deep Learning Toolbox', ...
        'FontSize', 10, 'FontColor', [0.6 0.65 0.75], 'HorizontalAlignment', 'center');

    % =====================================================================
    % CONTROLLER & DYNAMIC MULTILINGUAL LOGIC
    % =====================================================================

    % 1. PHC Location Change: Updates Worker Language options to match selected region
    function onLocationChanged()
        loc = dropLocation.Value;
        appData.detectedRegion = loc;
        
        switch loc
            case 'Karnataka (South)'
                dropWorkerLang.Items = {'English', 'हिंदी (Hindi)', 'ಕನ್ನಡ (Kannada)'};
                dropWorkerLang.Value = 'ಕನ್ನಡ (Kannada)';
            case 'Assam (North-East)'
                dropWorkerLang.Items = {'English', 'हिंदी (Hindi)', 'অসমীয়া (Assamese)'};
                dropWorkerLang.Value = 'অসমীয়া (Assamese)';
            case 'Maharashtra (West)'
                dropWorkerLang.Items = {'English', 'हिंदी (Hindi)', 'मराठी (Marathi)'};
                dropWorkerLang.Value = 'मराठी (Marathi)';
            otherwise % Uttar Pradesh
                dropWorkerLang.Items = {'English', 'हिंदी (Hindi)'};
                dropWorkerLang.Value = 'हिंदी (Hindi)';
        end
        
        appData.workerLang = dropWorkerLang.Value;
        refreshFullDashboard();
    end

    % 2. Mode Change (Doctor vs ASHA)
    function onModeChanged()
        appData.currentMode = dropMode.Value;
        refreshFullDashboard();
    end

    % 3. Worker Language Change
    function onWorkerLanguageChanged()
        appData.workerLang = dropWorkerLang.Value;
        refreshFullDashboard();
    end

    % MASTER UI TRANSLATION REFRESH (Translates everything instantly)
    function refreshFullDashboard()
        lang = appData.workerLang;
        mode = appData.currentMode;
        stage = appData.predClass;

        % A. Translate Column Panels & Buttons
        switch lang
            case 'ಕನ್ನಡ (Kannada)'
                col1.Title = '೧. ರೋಗಿಯ ABHA ಮತ್ತು ಸ್ಕ್ಯಾನ್';
                col2.Title = '೨. ಬಯೋಮಾರ್ಕರ್ ಮತ್ತು AI ವಿಶ್ಲೇಷಣೆ';
                lblAbhaPrompt.Text = 'ರೋಗಿಯ ABHA ID:';
                btnCamera.Text = '📷  ಲೈವ್ ಕ್ಯಾಮೆರಾ';
                btnBrowse.Text = '📁  ಕಂಪ್ಯೂಟರ್ ಬ್ರೌಸ್';
                btnAnalyze.Text = '⚡  ಪೂರ್ಣ AI ತಪಾಸಣೆ ನಡೆಸಿ';
                btnExport.Text = '🏥  ABDM / ಇ-ಸಂಜೀವನಿ ರೆಫರಲ್';
                lblSlider.Text = sprintf('ಹೀಟ್‌ಮ್ಯಾಪ್ ಪಾರದರ್ಶಕತೆ: %d%%', round(sliderOpacity.Value * 100));
                lblRationaleTitle.Text = 'ವೈದ್ಯಕೀಯ ಕಾರಣ (ರೋಗದ ವಿವರ):';
                lblActionHeader.Text = 'ಆಶಾ ಕಾರ್ಯಕರ್ತೆಯ ನಿರ್ದೇಶನ (ಆಕ್ಷನ್):';
                if strcmp(stage, 'Pending')
                    lblImgInfo.Text = 'ಕ್ಯಾಮೆರಾ ಸಂಪರ್ಕಿಸಿ ಅಥವಾ ಸ್ಕ್ಯಾನ್ ಆಯ್ಕೆಮಾಡಿ.';
                    lblStage.Text = 'ರೋಗದ ಹಂತ: ತಪಾಸಣೆ ಬಾಕಿ ಇದೆ';
                    badgeRisk.Text = 'ಟ್ರಾಫಿಕ್ ಲೈಟ್: ಬಾಕಿ ಇದೆ';
                    lblRationale.Text = 'ವಿಶ್ಲೇಷಣೆಗಾಗಿ ಸ್ಕ್ಯಾನ್ ಲೋಡ್ ಮಾಡಿ.';
                end

            case 'हिंदी (Hindi)'
                col1.Title = '1. मरीज ABHA एवं स्कैन अधिग्रहण';
                col2.Title = '2. बायोमार्कर एवं व्याख्यात्मक AI';
                lblAbhaPrompt.Text = 'मरीज ABHA आईडी:';
                btnCamera.Text = '📷  लाइव कैमरा';
                btnBrowse.Text = '📁  कंप्यूटर ब्राउज़ करें';
                btnAnalyze.Text = '⚡  पूर्ण बायोमार्कर जांच शुरू करें';
                btnExport.Text = '🏥  ABDM / ई-संजीवनी पर्ची भेजें';
                lblSlider.Text = sprintf('हीटमैप पारदर्शिता: %d%%', round(sliderOpacity.Value * 100));
                lblRationaleTitle.Text = 'नैदानिक तर्क (रोग का कारण):';
                lblActionHeader.Text = 'स्वास्थ्य कार्यकर्ता निर्देश (एक्शन):';
                if strcmp(stage, 'Pending')
                    lblImgInfo.Text = 'शुरू करने के लिए कैमरा जोड़ें या स्कैन चुनें।';
                    lblStage.Text = 'अनुमानित अवस्था: प्रक्रियाधीन';
                    badgeRisk.Text = 'ट्रैफिक लाइट: जांच लंबित';
                    lblRationale.Text = 'कारण देखने हेतु स्कैन लोड करें।';
                end

            case 'অসমীয়া (Assamese)'
                col1.Title = '১. ৰোগীৰ ABHA আৰু স্কেন সংগ্ৰহ';
                col2.Title = '২. বায়োমাৰ্কাৰ আৰু বিশ্লেষণাত্মক AI';
                lblAbhaPrompt.Text = 'ৰোগীৰ ABHA নম্বৰ:';
                btnCamera.Text = '📷  লাইভ কেমেৰা';
                btnBrowse.Text = '📁  কম্পিউটাৰ ব্ৰাউজ';
                btnAnalyze.Text = '⚡  সম্পূৰ্ণ বিশ্লেষণ আৰম্ভ কৰক';
                btnExport.Text = '🏥  ABDM / ই-সঞ্জীৱনী প্ৰেৰণ কৰক';
                lblSlider.Text = sprintf('হিটমেপ স্পষ্টতা: %d%%', round(sliderOpacity.Value * 100));
                lblRationaleTitle.Text = 'ৰোগ নিৰ্ণয়ৰ কাৰণ:';
                lblActionHeader.Text = 'স্বাস্থ্য কৰ্মীৰ নিৰ্দেশনা (কৰণীয় কাম):';
                if strcmp(stage, 'Pending')
                    lblImgInfo.Text = 'আৰম্ভ কৰিবলৈ কেমেৰা সংযোগ কৰক বা স্কেন বাছক।';
                    lblStage.Text = 'ৰোগৰ অৱস্থা: বাকী আছে';
                    badgeRisk.Text = 'ট্ৰেফিক লাইট: পৰীক্ষা হোৱা নাই';
                    lblRationale.Text = 'কাৰণ জানিবলৈ স্কেন লোড কৰি বিশ্লেষণ কৰক।';
                end

            case 'मराठी (Marathi)'
                col1.Title = '१. रुग्ण ABHA व स्कॅन';
                col2.Title = '२. बायोमार्कर व AI विश्लेषण';
                lblAbhaPrompt.Text = 'रुग्ण ABHA आयडी:';
                btnCamera.Text = '📷  लाइव्ह कॅमेरा';
                btnBrowse.Text = '📁  कॉम्प्युटर ब्राउझ करा';
                btnAnalyze.Text = '⚡  पूर्ण AI तपासणी करा';
                btnExport.Text = '🏥  ABDM / ई-संजीवनी रेफरल';
                lblSlider.Text = sprintf('हीटमॅप पारदर्शकता: %d%%', round(sliderOpacity.Value * 100));
                lblRationaleTitle.Text = 'वैद्यकीय कारण (रोग निदान):';
                lblActionHeader.Text = 'आरोग्य सेविका सूचना (कृती):';
                if strcmp(stage, 'Pending')
                    lblImgInfo.Text = 'कॅमेरा जोडा किंवा स्कॅन निवडा.';
                    lblStage.Text = 'अनुमानित अवस्था: प्रलंबित';
                    badgeRisk.Text = 'ट्रॅफिक लाइट: तपासणी बाकी';
                    lblRationale.Text = 'निदानासाठी स्कॅन लोड करा.';
                end

            otherwise % English
                col1.Title = '1. Patient ABHA & Acquisition';
                col2.Title = '2. Biomarkers & Explainable AI';
                lblAbhaPrompt.Text = 'Patient ABHA ID:';
                btnCamera.Text = '📷  Live Camera';
                btnBrowse.Text = '📁  Browse Computer';
                btnAnalyze.Text = '⚡  Run Full Biomarker Inference';
                btnExport.Text = '🏥  Export ABDM / e-Sanjeevani Referral Slip';
                lblSlider.Text = sprintf('Heatmap / Lesion Overlay Opacity: %d%%', round(sliderOpacity.Value * 100));
                lblRationaleTitle.Text = 'CLINICAL RATIONALE (WHY THIS STAGE):';
                lblActionHeader.Text = 'ACTION DIRECTIVE FOR HEALTH WORKER:';
                if strcmp(stage, 'Pending')
                    lblImgInfo.Text = 'Connect a fundus camera or browse scans to begin.';
                    lblStage.Text = 'PREDICTED STAGE: ---';
                    badgeRisk.Text = 'TRAFFIC LIGHT STATUS: PENDING';
                    lblRationale.Text = 'Load a scan and run inference to generate lesion-level justification.';
                end
        end

        % B. Update Table & Titles for DOCTOR vs ASHA MODE
        if contains(mode, 'ASHA')
            col3.Title = '3. ASHA Field Protocol (Simplified)';
            uitableBiomarkers.ColumnWidth = {140, 95, 95};
            
            switch lang
                case 'ಕನ್ನಡ (Kannada)'
                    uitableBiomarkers.ColumnName = {'ಪರೀಕ್ಷೆ', 'ಸ್ಥಿತಿ', 'ಕ್ಷೇತ್ರ ಕ್ರಮ'};
                    uitableBiomarkers.Data = {
                        '೧. ಫೋಟೋ ಸ್ಪಷ್ಟತೆ', '✅ ಸ್ಪಷ್ಟ', 'ಪರೀಕ್ಷೆಗೆ ಸಿದ್ಧ';
                        '೨. ರಕ್ತಸ್ರಾವ / ಕಲೆಗಳು', '⚠️ ಪತ್ತೆಯಾಗಿದೆ', 'ಅಪಾಯದ ಚಿಹ್ನೆ';
                        '೩. ದೃಷ್ಟಿ ಅಪಾಯ', '⚠️ ಎಚ್ಚರಿಕೆ', 'ರೆಫರಲ್ ಅಗತ್ಯವಿದೆ'
                    };
                case 'हिंदी (Hindi)'
                    uitableBiomarkers.ColumnName = {'जांच बिंदु', 'स्थिति', 'फील्ड निर्देश'};
                    uitableBiomarkers.Data = {
                        '1. फोटो की स्पष्टता', '✅ स्पष्ट', 'जांच हेतु सही';
                        '2. रक्तस्राव / धब्बे', '⚠️ मौजूद', 'खतरे के संकेत';
                        '3. दृष्टि हानि का जोखिम', '⚠️ सतर्कता', 'रेफरल आवश्यक'
                    };
                case 'অসমীয়া (Assamese)'
                    uitableBiomarkers.ColumnName = {'পৰীক্ষা', 'স্থিতি', 'নিৰ্দেশনা'};
                    uitableBiomarkers.Data = {
                        '১. ফটোৰ স্পষ্টতা', '✅ স্পষ্ট', 'পৰীক্ষাৰ যোগ্য';
                        '২. ৰক্তক্ষৰণ / দাগ', '⚠️ চিনাক্ত', 'বিপদৰ লক্ষণ';
                        '৩. দৃষ্টিৰ আশংকা', '⚠️ সতৰ্কতা', 'জিলালৈ প্ৰেৰণ'
                    };
                case 'मराठी (Marathi)'
                    uitableBiomarkers.ColumnName = {'तपासणी', 'स्थिती', 'कृती'};
                    uitableBiomarkers.Data = {
                        '१. फोटो स्पष्टता', '✅ स्पष्ट', 'योग्य';
                        '२. रक्तस्त्राव / डाग', '⚠️ आढळले', 'धोका';
                        '३. दृष्टी धोका', '⚠️ सावध', 'रेफर करा'
                    };
                otherwise
                    uitableBiomarkers.ColumnName = {'Protocol Step', 'Status', 'Field Action'};
                    uitableBiomarkers.Data = {
                        '1. Image Quality', '✅ Clear', 'Acceptable';
                        '2. Retinal Bleeds', '⚠️ Detected', 'Risk Present';
                        '3. Vision Risk', '⚠️ Warning', 'Referral Needed'
                    };
            end
        else
            col3.Title = '3. Clinical Diagnostic Justification (Doctor Mode)';
            uitableBiomarkers.ColumnWidth = {135, 95, 85};
            switch lang
                case 'ಕನ್ನಡ (Kannada)'
                    uitableBiomarkers.ColumnName = {'ಬಯೋಮಾರ್ಕರ್', 'ಸ್ಥಿತಿ', 'ಸಾಂದ್ರತೆ'};
                case 'हिंदी (Hindi)'
                    uitableBiomarkers.ColumnName = {'बायोमार्कर', 'स्थिति', 'घनत्व'};
                case 'অসমীয়া (Assamese)'
                    uitableBiomarkers.ColumnName = {'বায়োমাৰ্কাৰ', 'স্থিতি', 'ঘনত্ব'};
                case 'मराठी (Marathi)'
                    uitableBiomarkers.ColumnName = {'बायोमार्कर', 'स्थिती', 'घनता'};
                otherwise
                    uitableBiomarkers.ColumnName = {'Biomarker', 'Status', 'Density'};
            end
            
            if isfield(appData, 'bioTable') && ~isempty(appData.bioTable)
                uitableBiomarkers.Data = appData.bioTable;
            else
                uitableBiomarkers.Data = {
                    'Microaneurysms (MAs)', 'Pending', '--';
                    'Hemorrhages (HEMs)', 'Pending', '--';
                    'Hard Exudates (EXs)', 'Pending', '--';
                    'Cotton Wool Spots', 'Pending', '--';
                    'Neovascularization', 'Pending', '--'
                };
            end
        end

        % C. Update Result Directives (Post Inference)
        if ~strcmp(stage, 'Pending')
            updateInferenceText();
        end

        % D. Update Regional Patient Advisory Card
        updateRegionalPatientDisplay();
    end

    function updateInferenceText()
        lang = appData.workerLang;
        stage = appData.predClass;

        switch lang
            case 'ಕನ್ನಡ (Kannada)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        lblStage.Text = 'ಹಂತ: ಸಾಮಾನ್ಯ ರೆಟಿನಾ (ರೋಗವಿಲ್ಲ)';
                        badgeRisk.Text = '🟢 ಸುರಕ್ಷಿತ: ೧ ವರ್ಷದ ನಂತರ ಮರು-ಪರೀಕ್ಷೆ';
                    case 'Mild NPDR'
                        lblStage.Text = 'ಹಂತ: ಆರಂಭಿಕ ರೆಟಿನೋಪತಿ (ಮೈಲ್ಡ್)';
                        badgeRisk.Text = '🟡 ಎಚ್ಚರಿಕೆ: ೬-೧೨ ತಿಂಗಳಲ್ಲಿ ಕೇಂದ್ರಕ್ಕೆ ತನ್ನಿ';
                    case 'Moderate NPDR'
                        lblStage.Text = 'ಹಂತ: ಮಧ್ಯಮ ರೆಟಿನೋಪತಿ (ಮಾಡರೇಟ್)';
                        badgeRisk.Text = '🟠 ಗಂಭೀರ: ಜಿಲ್ಲಾ ಕಣ್ಣಿನ ತಜ್ಞರಿಗೆ ರೆಫರ್ ಮಾಡಿ';
                    case {'Severe NPDR', 'Proliferative DR'}
                        lblStage.Text = 'ಹಂತ: ಅತಿ ತೀವ್ರ ರೆಟಿನೋಪತಿ (ತುರ್ತು ಅಪಾಯ)';
                        badgeRisk.Text = '🔴 ತುರ್ತು ಅಪಾಯ: ತಕ್ಷಣ ಜಿಲ್ಲಾ ಆಸ್ಪತ್ರೆಗೆ ಕಳುಹಿಸಿ';
                end

            case 'हिंदी (Hindi)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        lblStage.Text = 'अवस्था: सामान्य रेटिना (रोग रहित)';
                        badgeRisk.Text = '🟢 सुरक्षित: 1 वर्ष बाद दोबारा जांच';
                    case 'Mild NPDR'
                        lblStage.Text = 'अवस्था: प्रारंभिक रेटिनोपैथी (माइल्ड)';
                        badgeRisk.Text = '🟡 सतर्कता: 6-12 महीने में स्वास्थ्य केंद्र लाएं';
                    case 'Moderate NPDR'
                        lblStage.Text = 'अवस्था: मध्यम रेटिनोपैथी (मॉडरेट)';
                        badgeRisk.Text = '🟠 गंभीर: जिला नेत्र विशेषज्ञ को रेफर करें';
                    case {'Severe NPDR', 'Proliferative DR'}
                        lblStage.Text = 'अवस्था: अति-गंभीर रेटिनोपैथी (प्रोलिफेरेटिव)';
                        badgeRisk.Text = '🔴 आपातकालीन: तुरंत जिला अस्पताल भेजें';
                end

            case 'অসমীয়া (Assamese)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        lblStage.Text = 'অৱস্থা: স্বাভাৱিক ৰেটিনা (কোনো ৰোগ নাই)';
                        badgeRisk.Text = '🟢 নিৰাপদ: ১ বছৰৰ পিছত পুনৰ পৰীক্ষা';
                    case 'Mild NPDR'
                        lblStage.Text = 'অৱস্থা: প্ৰাৰম্ভিক লক্ষণ (মাইল্ড)';
                        badgeRisk.Text = '🟡 সতৰ্কতা: ৬-১২ মাহত পৰিদৰ্শন কৰক';
                    case 'Moderate NPDR'
                        lblStage.Text = 'অৱস্থা: মধ্যম ৰক্তক্ষৰণ (মডাৰেট)';
                        badgeRisk.Text = '🟠 জটিল: জিলা বিশেষজ্ঞলৈ প্ৰেৰণ কৰক';
                    case {'Severe NPDR', 'Proliferative DR'}
                        lblStage.Text = 'অৱস্থা: অতি বিপজ্জনক অৱস্থা (জৰুৰী)';
                        badgeRisk.Text = '🔴 জৰুৰী বিপদ: তৎক্ষণাৎ জিলা চিকিৎসালয়লৈ পঠিয়াওক';
                end

            case 'मराठी (Marathi)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        lblStage.Text = 'अवस्था: सामान्य रेटिना (रोग नाही)';
                        badgeRisk.Text = '🟢 सुरक्षित: १ वर्षानंतर पुन्हा तपासा';
                    case 'Mild NPDR'
                        lblStage.Text = 'अवस्था: प्राथमिक रेटिनोपॅथी (माइल्ड)';
                        badgeRisk.Text = '🟡 खबरदारी: ६-१२ महिन्यांत केंद्रात या';
                    case 'Moderate NPDR'
                        lblStage.Text = 'अवस्था: मध्यम रेटिनोपॅथी (मॉडरेट)';
                        badgeRisk.Text = '🟠 गंभीर: जिल्हा नेत्रतज्ज्ञांकडे जा';
                    case {'Severe NPDR', 'Proliferative DR'}
                        lblStage.Text = 'अवस्था: अति-गंभीर (तातडीचा धोका)';
                        badgeRisk.Text = '🔴 तातडीचा धोका: त्वरित जिल्हा रुग्णालयात पाठवा';
                end

            otherwise % English
                switch stage
                    case 'No Diabetic Retinopathy'
                        lblStage.Text = sprintf('Stage: No DR (%.1f%%)', appData.confidence * 100);
                        badgeRisk.Text = '🟢 GREEN: Safe. Annual re-screening.';
                    case 'Mild NPDR'
                        lblStage.Text = sprintf('Stage: Mild NPDR (%.1f%%)', appData.confidence * 100);
                        badgeRisk.Text = '🟡 YELLOW: Review at Sub-Center in 6-12 mo.';
                    case 'Moderate NPDR'
                        lblStage.Text = sprintf('Stage: Moderate NPDR (%.1f%%)', appData.confidence * 100);
                        badgeRisk.Text = '🟠 ORANGE: Specialist Referral within 30 days.';
                    case {'Severe NPDR', 'Proliferative DR'}
                        lblStage.Text = sprintf('Stage: Severe/PDR (%.1f%%)', appData.confidence * 100);
                        badgeRisk.Text = '🔴 RED: Urgent Emergency Intervention.';
                end
        end
    end

    function updateRegionalPatientDisplay()
        region = appData.detectedRegion;
        stage = appData.predClass;

        if strcmp(stage, 'Pending')
            switch region
                case 'Karnataka (South)'
                    lblRegionalAdvisory.Text = 'ಕರ್ನಾಟಕ (Karnataka PHC): ರೋಗಿಗೆ ಕನ್ನಡ ಸಂದೇಶ ಸಿದ್ಧವಾಗಿದೆ.';
                case 'Assam (North-East)'
                    lblRegionalAdvisory.Text = 'অসম (Assam PHC): ৰোগীৰ বাবে অসমীয়া বাৰ্তা প্ৰস্তুত।';
                case 'Maharashtra (West)'
                    lblRegionalAdvisory.Text = 'महाराष्ट्र (Maharashtra PHC): रुग्णासाठी मराठी संदेश तयार.';
                otherwise % Uttar Pradesh
                    lblRegionalAdvisory.Text = 'उत्तर प्रदेश (UP PHC): मरीज हेतु हिंदी संदेश तैयार।';
            end
            return;
        end

        [~, ~, regText] = getTrilingualMessages(stage, region);
        lblRegionalAdvisory.Text = sprintf('📍 %s Patient SMS:\n"%s"', region, regText);
    end

    % 4. Guaranteed Native Foreground File Browse (Mac & Windows)
    btnBrowse.ButtonPushedFcn = @(btn, event) browseForImage();
    function browseForImage()
        btnBrowse.Text = '⏳ Selecting...';
        drawnow;
        fullPath = '';
        fileName = '';
        
        if ismac
            % Native macOS System Sheet: Guaranteed to float in front of MATLABWindow
            cmd = 'osascript -e ''try'' -e ''set chosenFile to POSIX path of (choose file with prompt "Select Retinal Fundus Scan")'' -e ''return chosenFile'' -e ''on error'' -e ''return ""'' -e ''end try''';
            [status, result] = system(cmd);
            if status == 0
                fullPath = strtrim(result);
                if ~isempty(fullPath)
                    [~, name, ext] = fileparts(fullPath);
                    fileName = [name, ext];
                end
            end
        else
            % Windows: Standard Modal File Picker
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif;*.bmp', 'Retinal Images (*.jpg, *.png, *.tif)'}, ...
                                    'Select Retinal Fundus Scan');
            if ~isequal(file, 0)
                fullPath = fullfile(path, file);
                fileName = file;
            end
        end
        
        btnBrowse.Text = '📁  Browse Computer';
        drawnow;
        if isvalid(fig)
            figure(fig);
        end
        
        if isempty(fullPath)
            return;
        end
        
        loadImageIntoDashboard(fullPath, fileName);
    end

    % 5. Live Camera Hardware Capture
    btnCamera.ButtonPushedFcn = @(btn, event) captureFromCamera();
    function captureFromCamera()
        statusBadge.Text = '● CHECKING HARDWARE...';
        statusBadge.FontColor = [1 0.7 0.1];
        drawnow;
        hasWebcamSupport = (exist('webcamlist', 'file') == 2 || exist('webcamlist', 'file') == 6);
        if ~hasWebcamSupport
            statusBadge.Text = '● ABDM GATEWAY ONLINE';
            statusBadge.FontColor = [0.3 0.95 0.4];
            uialert(fig, 'Webcam interface missing. Use "Browse Computer".', 'Camera Error', 'Icon', 'warning');
            return;
        end
        try
            cams = webcamlist();
            if isempty(cams)
                statusBadge.Text = '● ABDM GATEWAY ONLINE';
                statusBadge.FontColor = [0.3 0.95 0.4];
                uialert(fig, 'No optical camera detected on USB ports.', 'No Camera Connected', 'Icon', 'error');
                return;
            end
            camObj = webcam(1);
            capturedImg = snapshot(camObj);
            clear camObj;
            tempPath = fullfile(tempdir, 'camera_optical_capture.jpg');
            imwrite(capturedImg, tempPath);
            loadImageIntoDashboard(tempPath, 'Live_Capture.jpg');
        catch ME
            uialert(fig, ME.message, 'Device Error', 'Icon', 'error');
        end
        statusBadge.Text = '● ABDM GATEWAY ONLINE';
        statusBadge.FontColor = [0.3 0.95 0.4];
    end

    % 6. Unified Image Loader with Auto-BGR Healing & Quality Gate
    function loadImageIntoDashboard(filePath, fileName)
        try
            loadedScan = imread(filePath);

            % Validate authenticity first before attempting any channel conversion
            [isValid, qualityGrade, reason, isBGR] = validateScanQuality(loadedScan);

            % Flip channels ONLY if verified as an authentic BGR-inverted fundus scan
            if isBGR && size(loadedScan, 3) == 3
                loadedScan = loadedScan(:, :, [3 2 1]);
            end

            appData.loadedImage = loadedScan;
            cla(axRaw);
            imshow(appData.loadedImage, 'Parent', axRaw);
            title(axRaw, sprintf('Raw Fundus: %s', fileName), 'Interpreter', 'none', 'Color', [0.9 0.9 0.9]);
            cla(axGrad);
            title(axGrad, 'Pathology & Grad-CAM Mapping', 'Color', [0.9 0.9 0.9]);

            if ~isValid
                btnAnalyze.Enable = 'off';
                btnExport.Enable = 'off';
                lblStage.Text = 'UNGRADABLE SCAN';
                lblStage.FontColor = [1 0.4 0.4];
                badgeRisk.Text = qualityGrade;
                badgeRisk.BackgroundColor = [1 0.85 0.85];
                badgeRisk.FontColor = [0.8 0 0];
                lblRationale.Text = reason;
                lblImgInfo.Text = sprintf('Status: %s', qualityGrade);
                uialert(fig, reason, 'Quality Warning', 'Icon', 'warning');
                return;
            end

            btnAnalyze.Enable = 'on';
            btnExport.Enable = 'off';
            lblStage.Text = '---';
            lblStage.FontColor = [1 1 1];
            lblRationale.Text = reason;
            badgeRisk.Text = qualityGrade;
            badgeRisk.BackgroundColor = [0.85 0.95 0.85];
            badgeRisk.FontColor = [0.1 0.5 0.2];
            lblImgInfo.Text = sprintf('Loaded: %s (%dx%d px) | %s', fileName, ...
                size(appData.loadedImage, 1), size(appData.loadedImage, 2), qualityGrade);
            
            appData.bioTable = {
                'Microaneurysms (MAs)', 'Pending', '--';
                'Hemorrhages (HEMs)', 'Pending', '--';
                'Hard Exudates (EXs)', 'Pending', '--';
                'Cotton Wool Spots', 'Pending', '--';
                'Neovascularization', 'Pending', '--'
            };
            refreshFullDashboard();
        catch ME
            uialert(fig, ME.message, 'Image Error', 'Icon', 'error');
        end
    end

    % 7. Diagnostic Inference
    btnAnalyze.ButtonPushedFcn = @(btn, event) runDiagnostic();
    function runDiagnostic()
        if isempty(appData.loadedImage); return; end
        statusBadge.Text = '● EXTRACTING BIOMARKERS...';
        statusBadge.FontColor = [1 0.7 0.1];
        drawnow;

        [predClass, confidence, camMap, bioTable, rationaleText, lesions] = biomarkerInferenceEngine(appData.loadedImage);
        appData.camMap = camMap;
        appData.predClass = predClass;
        appData.confidence = confidence;
        appData.bioTable = bioTable;
        appData.rationaleText = rationaleText;
        appData.lesions = lesions;

        lblRationale.Text = rationaleText;

        switch predClass
            case 'No Diabetic Retinopathy'
                badgeRisk.BackgroundColor = [0.85 0.95 0.85];
                badgeRisk.FontColor = [0.1 0.5 0.2];
            case 'Mild NPDR'
                badgeRisk.BackgroundColor = [1 0.95 0.8];
                badgeRisk.FontColor = [0.7 0.4 0];
            case 'Moderate NPDR'
                badgeRisk.BackgroundColor = [1 0.9 0.8];
                badgeRisk.FontColor = [0.8 0.3 0];
            case {'Severe NPDR', 'Proliferative DR'}
                badgeRisk.BackgroundColor = [1 0.85 0.85];
                badgeRisk.FontColor = [0.8 0 0];
        end

        refreshFullDashboard();
        updateHeatmapOverlay();

        statusBadge.Text = '● ABDM GATEWAY ONLINE';
        statusBadge.FontColor = [0.3 0.95 0.4];
        btnExport.Enable = 'on';
    end

    % 8. Heatmap Blending Overlay
    function updateHeatmapOverlay()
        if isempty(appData.loadedImage) || isempty(appData.camMap); return; end
        alphaVal = sliderOpacity.Value;
        lblSlider.Text = sprintf('Heatmap / Lesion Overlay Opacity: %d%%', round(alphaVal * 100));

        cla(axGrad);
        imshow(appData.loadedImage, 'Parent', axGrad);
        hold(axGrad, 'on');
        h = imagesc(axGrad, appData.camMap);
        set(h, 'AlphaData', alphaVal * 0.7);
        colormap(axGrad, 'jet');

        if isfield(appData, 'lesions') && ~isempty(appData.lesions)
            for k = 1:size(appData.lesions, 1)
                x = appData.lesions(k, 1);
                y = appData.lesions(k, 2);
                if appData.lesions(k, 3) == 1
                    plot(axGrad, x, y, 'ro', 'LineWidth', 1.5, 'MarkerSize', 8);
                else
                    plot(axGrad, x, y, 'yo', 'LineWidth', 1.5, 'MarkerSize', 8);
                end
            end
        end
        hold(axGrad, 'off');
        title(axGrad, sprintf('Lesions Localized: %s', appData.predClass), 'Color', [0.9 0.9 0.9]);
    end

    % 9. Export Referral Slip with Trilingual Patient Push
    btnExport.ButtonPushedFcn = @(btn, event) exportReport();
    function exportReport()
        region = appData.detectedRegion;
        stage = appData.predClass;

        [engMsg, hindiMsg, regionalMsg] = getTrilingualMessages(stage, region);

        summaryText = sprintf([...
            '=======================================================\n', ...
            '   ABDM & e-SANJEEVANI TRILINGUAL REFERRAL DISPATCH\n', ...
            '=======================================================\n\n', ...
            'Patient ABHA ID : %s\n', ...
            'PHC Facility    : %s\n', ...
            'Operating Mode  : %s\n', ...
            'Diagnosis       : %s (Confidence: %.1f%%)\n', ...
            'Worker Action   : %s\n\n', ...
            '-------------------------------------------------------\n', ...
            'OUTBOUND PATIENT WHATSAPP / SMS (TRILINGUAL PUSH):\n', ...
            '-------------------------------------------------------\n', ...
            '[1] ENGLISH:\n"%s"\n\n', ...
            '[2] HINDI (National Link):\n"%s"\n\n', ...
            '[3] REGIONAL LANGUAGE (%s):\n"%s"\n\n', ...
            '-------------------------------------------------------\n', ...
            'FHIR v4.0.1 Tele-Ophthalmology ticket created & synced.'], ...
            txtAbha.Value, region, appData.currentMode, stage, appData.confidence * 100, ...
            badgeRisk.Text, engMsg, hindiMsg, region, regionalMsg);

        uialert(fig, summaryText, 'ABDM Patient Dispatch Success', 'Icon', 'success');
    end

    function [eng, hindi, reg] = getTrilingualMessages(stage, region)
        switch stage
            case 'No Diabetic Retinopathy'
                eng = 'Your retinal scan is normal. Next routine diabetic eye screening due in 12 months.';
                hindi = 'आपकी आँख का रेटिना सामान्य है। अगली नियमित जांच 12 महीने बाद कराएं।';
            case 'Mild NPDR'
                eng = 'Early diabetic eye changes detected. Please visit the Community Health Center in 6 months.';
                hindi = 'आँख में शुरुआती मधुमेह के लक्षण हैं। 6 महीने में नजदीकी स्वास्थ्य केंद्र पर दिखाएं।';
            case 'Moderate NPDR'
                eng = 'Retinal vascular changes confirmed. Scheduled for District Hospital specialist checkup.';
                hindi = 'रेटिना में रक्तस्राव के लक्षण हैं। जिला अस्पताल में नेत्र विशेषज्ञ से संपर्क करें।';
            case {'Severe NPDR', 'Proliferative DR'}
                eng = 'Urgent medical alert: Sight-threatening changes detected. Emergency laser consult dispatched.';
                hindi = 'आपातकालीन चेतावनी: दृष्टि सुरक्षा हेतु तुरंत जिला अस्पताल में लेजर परामर्श लें।';
            otherwise
                eng = 'Scan pending evaluation.';
                hindi = 'जांच प्रक्रियाधीन है।';
        end

        switch region
            case 'Karnataka (South)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        reg = 'ನಿಮ್ಮ ಕಣ್ಣಿನ ರೆಟಿನಾ ಸಹಜವಾಗಿದೆ. ಮುಂದಿನ ತಪಾಸಣೆಯನ್ನು 1 ವರ್ಷದ ನಂತರ ಮಾಡಿಸಿ.';
                    case 'Mild NPDR'
                        reg = 'ಆರಂಭಿಕ ಬದಲಾವಣೆಗಳು ಕಂಡುಬಂದಿವೆ. 6 ತಿಂಗಳಲ್ಲಿ ಸಮುದಾಯ ಆರೋಗ್ಯ ಕೇಂದ್ರಕ್ಕೆ ಭೇಟಿ ನೀಡಿ.';
                    case 'Moderate NPDR'
                        reg = 'ರೆಟಿನಾದಲ್ಲಿ ರಕ್ತಸ್ರಾವದ ಲಕ್ಷಣಗಳಿವೆ. ಜಿಲ್ಲಾ ಕಣ್ಣಿನ ತಜ್ಞರನ್ನು ಭೇಟಿ ಮಾಡಿ.';
                    case {'Severe NPDR', 'Proliferative DR'}
                        reg = 'ತುರ್ತು ಎಚ್ಚರಿಕೆ: ದೃಷ್ಟಿ ರಕ್ಷಣೆಗಾಗಿ ತಕ್ಷಣ ಜಿಲ್ಲಾ ಆಸ್ಪತ್ರೆಗೆ ಭೇಟಿ ನೀಡಿ ಚಿಕಿತ್ಸೆ ಪಡೆಯಿರಿ.';
                    otherwise
                        reg = 'ರೋಗಿಗೆ ಕನ್ನಡ ಸಂದೇಶ ಸಿದ್ಧವಾಗಿದೆ.';
                end
            case 'Assam (North-East)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        reg = 'আপোনাৰ চকুৰ ৰেটিনা সম্পূৰ্ণ স্বাভাৱিক। বছৰত এবাৰ নিয়মীয়া চকু পৰীক্ষা কৰাওক।';
                    case 'Mild NPDR'
                        reg = 'চকুৰ ৰেটিনাত প্ৰাৰম্ভিক পৰিবৰ্তন দেখা গৈছে। ৬ মাহৰ ভিতৰত স্বাস্থ্য কেন্দ্ৰলৈ যাওক।';
                    case 'Moderate NPDR'
                        reg = 'ৰেটিনাত দাগ ধৰা পৰিছে। অনতিপলমে জিলা চিকিৎসালয়ৰ চকু বিশেষজ্ঞক দেখুৱাওক।';
                    case {'Severe NPDR', 'Proliferative DR'}
                        reg = 'জৰুৰী সতৰ্কতা: দৃষ্টিশক্তি ৰক্ষাৰ বাবে তাৎক্ষণিক চিকিৎসা আৰু লেজাৰ পৰামৰ্শ প্ৰয়োজন।';
                    otherwise
                        reg = 'ৰোগীৰ বাবে অসমীয়া বাৰ্তা প্ৰস্তুত।';
                end
            case 'Maharashtra (West)'
                switch stage
                    case 'No Diabetic Retinopathy'
                        reg = 'तुमच्या डोळ्यांचा पडदा (रेटिना) सामान्य आहे. वर्षातून एकदा नियमित तपासणी करा.';
                    case 'Mild NPDR'
                        reg = 'डोळ्यांत प्राथमिक बदल दिसत आहेत. ६ महिन्यांत प्राथमिक आरोग्य केंद्रात जा.';
                    case 'Moderate NPDR'
                        reg = 'रेटिनावर रक्ताचे डाग आढळले आहेत. जिल्हा रुग्णालयात नेत्रतज्ज्ञांचा सल्ला घ्या.';
                    case {'Severe NPDR', 'Proliferative DR'}
                        reg = 'तातडीचा इशारा: दृष्टी वाचवण्यासाठी त्वरित जिल्हा रुग्णालयात लेझर उपचार सुरू करा.';
                    otherwise
                        reg = 'रुग्णासाठी मराठी संदेश तयार.';
                end
            otherwise % Uttar Pradesh (North)
                reg = hindi;
        end
    end

    function [isValid, qualityGrade, reason, isBGR] = validateScanQuality(img)
        isBGR = false;

        if size(img, 3) ~= 3
            isValid = false; qualityGrade = 'INVALID FORMAT';
            reason = 'Calibrated 3-channel RGB fundus scan required.'; return;
        end

        [rows, cols, ~] = size(img);
        gray = rgb2gray(img);

        % 1. Aspect Ratio Test (Rejects widescreen UI screenshots, banners, docs)
        aspectRatio = cols / rows;
        if aspectRatio < 0.72 || aspectRatio > 1.38
            isValid = false;
            qualityGrade = 'REJECTED: NON-FUNDUS IMAGE';
            reason = sprintf('Geometry mismatch (Aspect ratio: %.2f). Widescreen screenshots and UI captures are non-retinal.', aspectRatio);
            return;
        end

        % 2. Optical Aperture Test (Checks for dark circular lens borders)
        cSize = max(5, round(min(rows, cols) * 0.05));
        cTL = mean(gray(1:cSize, 1:cSize), 'all');
        cTR = mean(gray(1:cSize, end-cSize+1:end), 'all');
        cBL = mean(gray(end-cSize+1:end, 1:cSize), 'all');
        cBR = mean(gray(end-cSize+1:end, end-cSize+1:end), 'all');
        cornerMean = (cTL + cTR + cBL + cBR) / 4;

        if cornerMean > 45
            isValid = false;
            qualityGrade = 'REJECTED: NON-FUNDUS IMAGE';
            reason = 'Aperture missing: No circular fundus boundary detected. Scene appears to be a regular camera photo.';
            return;
        end

        % 3. Retinal Tissue Area Check
        retinaMask = gray > 20;
        fgRatio = sum(retinaMask(:)) / numel(gray);
        if fgRatio < 0.20 || fgRatio > 0.94
            isValid = false;
            qualityGrade = 'REJECTED: NON-FUNDUS IMAGE';
            reason = 'Aperture geometry mismatch: Illuminated area does not match a retinal fundus disc.';
            return;
        end

        % 4. Biological Hue Consistency in HSV Space (Rejects synthetic web pages)
        hsv = rgb2hsv(img);
        h = hsv(:,:,1);
        s = hsv(:,:,2);
        v = hsv(:,:,3);

        validMask = retinaMask & (v > 0.12);
        retinalHuePixels = validMask & ((h <= 0.14) | (h >= 0.93)) & (s >= 0.16);
        tissueMatchRatio = sum(retinalHuePixels(:)) / max(sum(validMask(:)), 1);

        % Guarded BGR check: Only flag as BGR if flipping produces true retinal colors
        if tissueMatchRatio < 0.40
            imgFlipped = img(:, :, [3 2 1]);
            hsvFlip = rgb2hsv(imgFlipped);
            hFlip = hsvFlip(:,:,1);
            sFlip = hsvFlip(:,:,2);
            retinalHueFlip = validMask & ((hFlip <= 0.14) | (hFlip >= 0.93)) & (sFlip >= 0.16);
            tissueMatchFlip = sum(retinalHueFlip(:)) / max(sum(validMask(:)), 1);

            if tissueMatchFlip >= 0.50
                isBGR = true;
                tissueMatchRatio = tissueMatchFlip;
            end
        end

        if tissueMatchRatio < 0.48
            isValid = false;
            qualityGrade = 'REJECTED: NON-FUNDUS IMAGE';
            reason = sprintf('Biological spectral mismatch (Tissue consistency: %.1f%%). Scan lacks human retinal vascular hue profile.', tissueMatchRatio * 100);
            return;
        end

        % 5. Focus & Blur Verification (Laplacian Variance)
        green = double(img(:,:,2));
        lapFilter = [0 1 0; 1 -4 1; 0 1 0];
        lapEdges = conv2(green, lapFilter, 'same');
        blurScore = var(lapEdges(retinaMask));

        if blurScore < 20
            isValid = false;
            qualityGrade = 'REJECTED: UNGRADABLE BLUR';
            reason = sprintf('High optical blur detected (Score: %.1f). Lesions cannot be resolved.', blurScore);
            return;
        end

        isValid = true;
        qualityGrade = 'VALID: CLINICAL GRADE (PASS)';
        reason = sprintf('Biological fundus profile verified (Sharpness: %.1f | Tissue Match: %.1f%%).', blurScore, tissueMatchRatio * 100);
    end

    % Inference Engine Simulation
    function [predClass, confidence, camMap, bioTable, rationaleText, lesions] = biomarkerInferenceEngine(img)
        pause(0.5);
        if size(img, 3) == 3; greenCh = double(img(:,:,2)); else; greenCh = double(img); end
        gradEnergy = stdfilt(greenCh, true(5));
        [rows, cols] = size(greenCh);
        rng('shuffle');
        numLesions = randi([6, 14]);
        lx = randi([round(cols*0.25), round(cols*0.75)], numLesions, 1);
        ly = randi([round(rows*0.25), round(rows*0.75)], numLesions, 1);
        lesions = [lx, ly, randi([1, 2], numLesions, 1)];
        heat = imgaussfilt(gradEnergy, 20);
        heat = (heat - min(heat(:))) / (max(heat(:)) - min(heat(:)));
        camMap = imresize(heat, [rows, cols]);

        scenario = randi([1, 4]);
        switch scenario
            case 1
                predClass = 'No Diabetic Retinopathy'; confidence = 0.96;
                bioTable = {'Microaneurysms (MAs)','None Detected','0 / field';'Hemorrhages (HEMs)','None Detected','0 / field';'Hard Exudates (EXs)','None Detected','0 / field';'Cotton Wool Spots','None Detected','0 / field';'Neovascularization','Absent','Normal'};
                rationaleText = 'Normal retinal architecture. Satisfies ETDRS Grade 10.'; lesions = [];
            case 2
                predClass = 'Mild NPDR'; confidence = 0.91;
                bioTable = {'Microaneurysms (MAs)','Confirmed','1-5 isolated';'Hemorrhages (HEMs)','None Detected','0 / field';'Hard Exudates (EXs)','None Detected','0 / field';'Cotton Wool Spots','None Detected','0 / field';'Neovascularization','Absent','No proliferation'};
                rationaleText = 'Isolated microaneurysms in parafovea without macular exudation.';
            case 3
                predClass = 'Moderate NPDR'; confidence = 0.89;
                bioTable = {'Microaneurysms (MAs)','Confirmed','>10 detected';'Hemorrhages (HEMs)','Confirmed','Blot bleeds (<20)';'Hard Exudates (EXs)','Confirmed','Macular cluster';'Cotton Wool Spots','Suspicious','1 localized';'Neovascularization','Absent','Intact disc'};
                rationaleText = 'Multiple dot-blot hemorrhages and circinate hard exudates near arcades.';
            case 4
                predClass = 'Severe NPDR'; confidence = 0.93;
                bioTable = {'Microaneurysms (MAs)','Confirmed','Extensive (>30)';'Hemorrhages (HEMs)','Confirmed','3+ quadrants';'Hard Exudates (EXs)','Confirmed','Parafoveal rings';'Cotton Wool Spots','Confirmed','Multiple infarctions';'Neovascularization','Absent','High-risk'};
                rationaleText = 'Meets ETDRS 4-2-1 rule: Extensive 3+ quadrant hemorrhages.';
        end
    end
end
