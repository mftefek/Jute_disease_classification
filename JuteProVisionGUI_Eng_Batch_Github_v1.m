function JuteProVisionGUI_Eng_Batch()
    %% Main Window & Theme Configuration
    fig = uifigure('Name', 'Jute ProVision AI - Batch Diagnostic System', ...
                   'Position', [50, 50, 1200, 720], ...
                   'Color', [0.15 0.16 0.19]); 
                   
    % Footer section
    lblFooter = uilabel(fig, 'Position', [20, 10, 400, 20], ...
        'Text', '© 2026 | Developed by MFT.', ...
        'FontWeight', 'bold', 'FontColor', [0.6 0.6 0.6], 'FontSize', 11);
        
    % Network status label (default: checking)
    lblNetwork = uilabel(fig, 'Position', [1000, 10, 180, 20], ...
        'Text', '🌐 Network: Checking...', ...
        'FontWeight', 'bold', 'FontColor', [0.8 0.8 0.8], ...
        'HorizontalAlignment', 'right', 'FontSize', 11);
        
    % Tabs
    tg = uitabgroup(fig, 'Position', [20 40 1160 650]);
    tabAnalysis = uitab(tg, 'Title', '🔬 Batch Analysis', 'BackgroundColor', [0.94 0.94 0.96]);
    tabLogs = uitab(tg, 'Title', '⚙️ System Logs & Settings', 'BackgroundColor', [0.94 0.94 0.96]);
    
    %% Tab 1: Analysis UI Design
    appData.ax = cell(1, 5);
    appData.lblDiag = cell(1, 5);
    
    % Create 5 image slots
    for i = 1:5
        xPos = 25 + (i-1) * 225; 
        
        % Axes configuration (hiding ticks for a cleaner look)
        appData.ax{i} = uiaxes(tabAnalysis, 'Position', [xPos, 380, 210, 210]);
        title(appData.ax{i}, sprintf('Slot %d', i), 'FontSize', 11, 'Color', [0.4 0.4 0.4]);
        appData.ax{i}.XTick = []; appData.ax{i}.YTick = []; 
        appData.ax{i}.Box = 'on'; appData.ax{i}.Color = [0.9 0.9 0.9];
        
        % Labels for diagnosis results
        appData.lblDiag{i} = uilabel(tabAnalysis, 'Position', [xPos, 330, 210, 45], ...
            'Text', 'Diagnosis: N/A', 'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold', 'FontSize', 13, 'FontColor', [0.3 0.3 0.3]);
    end
    
    % Bottom control panels
    pnlInit = uipanel(tabAnalysis, 'Position', [40, 80, 350, 160], 'Title', '1. System Initialization', 'FontWeight', 'bold', 'FontSize', 12);
    
    lblModelStatus = uilabel(pnlInit, 'Position', [20, 80, 310, 25], ...
        'Text', 'Core Engine: Offline', 'FontWeight', 'bold', 'FontColor', [0.7 0 0], 'FontSize', 14);
    
    btnLoadModel = uibutton(pnlInit, 'push', ...
        'Position', [20 20, 310 45], ...
        'Text', 'Initialize AI Core', ...
        'BackgroundColor', [0.1 0.4 0.7], 'FontColor', 'w', 'FontWeight', 'bold', 'FontSize', 14);
        
    pnlAction = uipanel(tabAnalysis, 'Position', [410, 80, 350, 160], 'Title', '2. Batch Action Center', 'FontWeight', 'bold', 'FontSize', 12);
    
    btnTestImage = uibutton(pnlAction, 'push', ...
        'Position', [20 50, 310 50], ...
        'Text', 'Select Up To 5 Images', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.7 0.3], 'FontColor', 'w', 'Enable', 'off');
        
    uilabel(pnlAction, 'Position', [20, 20, 310, 20], ...
        'Text', 'Tip: Use CTRL or SHIFT to multi-select.', 'FontSize', 11, 'FontColor', [0.4 0.4 0.4], 'HorizontalAlignment', 'center');
        
    pnlResult = uipanel(tabAnalysis, 'Position', [780, 80, 350, 160], 'Title', 'System Status', 'FontWeight', 'bold', 'FontSize', 12);
    
    lblResult = uilabel(pnlResult, 'Position', [20 70 310 45], ...
        'Text', 'Awaiting AI Core...', ...
        'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [0.2 0.2 0.2]);
        
    lblTime = uilabel(pnlResult, 'Position', [20 30 310 25], ...
        'Text', 'Batch Execution Time: -', 'FontSize', 12, 'FontColor', [0.4 0.4 0.4]);
        
    %% Tab 2: Logs & Settings Screen
    uilabel(tabLogs, 'Position', [20, 570, 200, 25], 'Text', 'System Event Log:', 'FontWeight', 'bold', 'FontSize', 14);
    
    txtLog = uitextarea(tabLogs, 'Position', [20 70 1120 490], ...
        'Editable', 'off', 'FontName', 'Courier New', 'FontSize', 12, ...
        'BackgroundColor', [0.1 0.1 0.1], 'FontColor', [0 0.8 0]); 
        
    btnExportLog = uibutton(tabLogs, 'push', 'Position', [940 20 200 40], ...
        'Text', '💾 Export Logs to TXT', 'FontWeight', 'bold', ...
        'BackgroundColor', [0.3 0.3 0.3], 'FontColor', 'w');
        
    %% Global Variable Initialization
    % No hardcoded model path; it will be selected at runtime
    appData.net = [];
    appData.classNames = [];
    appData.inputSize = [256 256]; % Default for DarkNet-53 (updates dynamically in the load section for NASNet or other architectures)
    
    %% Callbacks
    btnLoadModel.ButtonPushedFcn = @(btn,event) loadModelFcn();
    btnTestImage.ButtonPushedFcn = @(btn,event) testImageFcn();
    btnExportLog.ButtonPushedFcn = @(btn,event) exportLogFcn();
    
    logAction('System Boot Sequence Initiated (v4.2 Batch Edition). Developer: MFT');
    checkInternetConnection(); 
    
    %% --- HELPER FUNCTIONS ---
    function logAction(msg)
        timeStamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        logMsg = sprintf('[%s] %s', timeStamp, msg);
        currentLogs = txtLog.Value;
        if ischar(currentLogs)
            currentLogs = {currentLogs};
        end
        txtLog.Value = [currentLogs; {logMsg}];
        drawnow;
    end
    
    function checkInternetConnection()
        try
            webread('https://www.google.com', weboptions('Timeout', 3));
            lblNetwork.Text = '🌐 Network: ONLINE';
            lblNetwork.FontColor = [0 0.8 0];
            logAction('Cloud link established.');
        catch
            lblNetwork.Text = '🌐 Network: OFFLINE';
            lblNetwork.FontColor = [1 0.3 0.3];
            logAction('WARNING: No external connection. Running in local mode.');
        end
    end
    
    function loadModelFcn()
        % Prompt user to select the trained .mat model file
        [file, path] = uigetfile({'*.mat', 'MATLAB Model Files (*.mat)'}, 'Select Trained Model (e.g. net.mat)');
        
        % Exit if the user cancels file selection
        if isequal(file, 0)
            logAction('Model selection canceled by user.');
            return;
        end
        
        modelPath = fullfile(path, file);
        logAction(sprintf('Attempting to mount AI Core from: %s', file));
        
        wb = waitbar(0.3, 'Loading Deep Learning parameters into memory...', 'Name', 'Booting AI Core');
        
        try
            data = load(modelPath);
            waitbar(0.7, wb, 'Verifying Core Engine...');
            
            % Identify the network variable name in the .mat file (usually 'trained_net' or 'net')
            if isfield(data, 'trained_net')
                appData.net = data.trained_net;
            elseif isfield(data, 'net')
                appData.net = data.net;
            else
                error('Network object not found in the selected file.');
            end
            
            if isfield(data, 'classNames')
                appData.classNames = data.classNames;
            else
                error('Class definitions missing in the selected file.');
            end
            
            % Try to extract the expected input size dynamically (adds flexibility for different architectures)
            try
                appData.inputSize = appData.net.Layers(1).InputSize(1:2);
            catch
                % Fallback to default (256x256) if extraction fails
            end
            
            waitbar(1.0, wb, 'Initialization Complete');
            logAction(sprintf('SUCCESS: AI Core (%s) loaded and verified.', file));
            
            lblResult.Text = 'System Ready for Batch';
            lblResult.FontColor = [0 0.4 0.8];
            
            % Display the loaded model's filename on the UI
            lblModelStatus.Text = sprintf('Core Engine: %s', file);
            lblModelStatus.FontColor = [0 0.6 0];
            
            % Enable the test button now that the model is loaded
            btnTestImage.Enable = 'on';
            btnLoadModel.Enable = 'off';
            btnLoadModel.BackgroundColor = [0.4 0.4 0.4]; 
            btnLoadModel.Text = 'AI Core Initialized';
            
            close(wb); 
        catch ME
            if ishandle(wb), close(wb); end 
            logAction(['MOUNT FAILED: ' ME.message]);
            uialert(fig, 'Failed to initialize the AI Core. Check if the file contains the network and class names.', 'System Error');
        end
    end
    
    function testImageFcn()
        [files, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select Up To 5 Images', 'MultiSelect', 'on');
        if isequal(files, 0)
            return;
        end
        
        if ischar(files)
            files = {files};
        end
        
        numFiles = length(files);
        
        % Warn and limit to the first 5 images if the user selects more
        if numFiles > 5
            uialert(fig, 'You selected more than 5 images. Only the first 5 will be processed.', 'Batch Limit Exceeded');
            numFiles = 5; 
        end
        
        logAction(sprintf('Batch analysis started for %d images.', numFiles));
        
        % Clear previous images and results from the UI
        for i = 1:5
            cla(appData.ax{i});
            title(appData.ax{i}, sprintf('Slot %d', i), 'FontSize', 11, 'Color', [0.4 0.4 0.4]);
            appData.lblDiag{i}.Text = 'Diagnosis: N/A';
            appData.lblDiag{i}.FontColor = [0.3 0.3 0.3];
        end
        
        wb = waitbar(0, 'Initializing Tensor Operations...', 'Name', 'Batch Neural Analysis');
        tic; 
        
        try
            for i = 1:numFiles
                waitbar(i / (numFiles + 1), wb, sprintf('Processing Image %d of %d...', i, numFiles));
                
                % Read and display the image in its respective slot
                imgStr = fullfile(path, files{i});
                img = imread(imgStr);
                imshow(img, 'Parent', appData.ax{i});
                
                title(appData.ax{i}, sprintf('Slot %d', i), 'FontSize', 11, 'Color', [0.4 0.4 0.4]);
                
                % Resize and classify before feeding into the network
                imgResized = imresize(img, appData.inputSize);
                scores = minibatchpredict(appData.net, imgResized);
                
                % Find the class with the highest score
                [~, idx] = max(scores);
                topClass = string(appData.classNames(idx(1)));
                
                appData.lblDiag{i}.Text = sprintf('DIAGNOSIS:\n%s', upper(topClass));
                appData.lblDiag{i}.FontColor = [0 0.5 0.1]; 
                
                logAction(sprintf('Slot %d -> File: %s | Result: %s', i, files{i}, topClass));
            end
            
            exTime = toc;
            waitbar(1.0, wb, 'Finalizing Batch Results...');
            
            lblResult.Text = sprintf('Batch Processed: %d Item(s)', numFiles);
            lblResult.FontColor = [0 0.6 0];
            lblTime.Text = sprintf('Total Execution Time: %.3f seconds', exTime);
            
            logAction(sprintf('Batch process completed in %.3fs.', exTime));
            pause(0.5); 
            close(wb);
            
        catch ME
            if ishandle(wb), close(wb); end
            logAction(['INFERENCE ERROR: ' ME.message]);
            uialert(fig, 'Batch processing encountered a critical failure. Check logs.', 'Analysis Error');
        end
    end
    
    function exportLogFcn()
        [file, path] = uiputfile('System_Logs_Batch_2026.txt', 'Save Logs As');
        if isequal(file, 0)
            return;
        end
        
        fullPath = fullfile(path, file);
        try
            fid = fopen(fullPath, 'w');
            fprintf(fid, '=== Jute ProVision AI Batch System Logs ===\n');
            fprintf(fid, 'Export Date: %s\n\n', datestr(now));
            
            logs = txtLog.Value;
            for i = 1:length(logs)
                fprintf(fid, '%s\n', logs{i});
            end
            fclose(fid);
            
            logAction(sprintf('Logs successfully exported to: %s', file));
            uialert(fig, 'System logs exported successfully.', 'Export Complete', 'Icon', 'success');
        catch ME
            logAction(['EXPORT ERROR: ' ME.message]);
            uialert(fig, 'Failed to save logs.', 'Export Error');
        end
    end
end