%% Calculate summary stats for click types used to train a neural net; plot
% mean spectra and ICI distributions

clearvars
% directory containing folders with composite_clusters output training examples
trainDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp';
saveDir = 'G:\cluster_NNet\TrainSetSummary';

%%
trainSet = dir(trainDir);
trainSet(1:2) = [];

for k = 1:size(trainSet,1) %for each click type
    if trainSet(k).isdir == 1
        typeDir = fullfile(trainSet(k).folder,trainSet(k).name);
        compClustFiles = dir([typeDir '\*.mat']);
        CT = trainSet(k).name;
        totNumClicks = 0;
        clicksPerDep = [];
        Dep = {};
        
        for i = 1:size(compClustFiles,1)  % run through composite_clusters files and count how many clicks
            if strfind(compClustFiles(i).name,'type')
                load([typeDir '\' compClustFiles(i).name]);
                
                 stringGrab = compClustFiles(i).name;
                if ~isempty(strfind(stringGrab,'Copy of '))
                    dep = strrep(stringGrab,'Copy of ','');
                else
                    dep = stringGrab;
                end

               totNumClicks = totNumClicks + size(thisType.clickTimes,1);
               clicksPerDep = [clicksPerDep;size(thisType.clickTimes,1)];
               Dep = [Dep;dep];
            end
        end
        
        save(fullfile(saveDir,[CT '_clickSum']),'totNumClicks','clicksPerDep','Dep','-v7.3');
    end
end

%%
trainSet = dir(trainDir);
trainSet(1:2) = [];
TPWSfiles_byCT = {};
b = 1;
letterCode = 97:122;

for k = 1:size(trainSet,1) %for each click type
    letterFlag = 0; % flag for knowing if a letter should be appended to file name
    if trainSet(k).isdir == 1
        typeDir = fullfile(trainSet(k).folder,trainSet(k).name);
        compClustFiles = dir([typeDir '\*.mat']);
        CT = trainSet(k).name;
        clickTimes = [];
        deployment = [];
        depVec = [];
        TPWSfiles = [];
        letterInd = 1;
        
        for i = 1:size(compClustFiles,1)  % run through composite_clusters files and pull out click times & TPWS indices
            if strfind(compClustFiles(i).name,'type')
                load([typeDir '\' compClustFiles(i).name]);
                
                stringGrab = compClustFiles(i).name;
                if ~isempty(strfind(stringGrab,'Copy of '))
                    dep = strrep(stringGrab,'Copy of ','');
                else
                    dep = stringGrab;
                end
                depVec = cellstr(repmat(dep,size(thisType.clickTimes,1),1));
                
                clickTimes = [clickTimes;thisType.clickTimes];
                deployment = [deployment;depVec];
                TPWSfiles = [TPWSfiles;TPWSList(unique(thisType.fileNumExpand))'];
                TPWSfiles = unique(TPWSfiles);
                
                %             if i==1
                %                 save(fullfile(saveDir,CT),'clickTimes','deployment','TPWSfiles');
                %             else
                %                 sC = size(clickTimes,1);
                %                 sT = size(TPWSfiles,1);
                %                 m = matfile(fullfile(saveDir,CT),'Writable',true);
                %                 m.clickTimes(end+1:end+1+sC,1) = clickTimes;
                %                 m.deployment(end+1:end+1+sC) = deployment;
                %                 m.TPWSfiles(end+1:end+1+sT) = TPWSfiles;
                %             end
                if size(clickTimes,1)>5e6 || i==size(compClustFiles,1)
                    if i == size(compClustFiles,1) && letterFlag == 0
                        save(fullfile(saveDir,CT),'clickTimes','deployment','TPWSfiles','-v7.3');
                    else
                        save(fullfile(saveDir,[CT '_' letterCode(letterInd)]),'clickTimes','deployment','TPWSfiles','-v7.3');
                        letterFlag = 1;
                        letterInd = letterInd + 1;
                    end
                    clickTimes = [];
                    deployment = [];
                    TPWSfiles = [];
                end
            end
        end
        
        TPWSfiles_byCT{1,b} = TPWSfiles;
        b = b+1;
    end
end

%% Add in manually compiled bins
for k = 1:size(trainSet,1) %for each click type
    if trainSet(k).isdir == 1
        typeDir = fullfile(trainSet(k).folder,trainSet(k).name);
        compClustFiles = dir([typeDir '\*.mat']);
        CT = trainSet(k).name;
        clickTimes = [];
        deployment = [];
        depVec = [];
        TPWSfiles = [];
        
        for i = 1:size(compClustFiles,1)
            if strfind(compClustFiles(i).name,'Compiled') || strfind(compClustFiles(i).name,'Sonar')
                
            end
        end
    end
end
%% Run through TPWS and pull out click spectra, ICI, PPRL, & time
% series; save each CT separately; save periodically

CTclicks = struct('MTT',[],'MSN',[],'MPP',[],'DTT',[]);

%for WAT deployments
TPWSfileind = unique(TKTK);
for i = 1:size(TPWSfileind,1)
    
end

%for HAT, NFC, & JAX deployments

TPWSfileind = unique(TKTK);
for i = 1:size(TPWSfileind,1)
    
end
%% Compute summary statistics for each CT
summaryStats = struct('CT',[],'MeanSpecs',[],'ICIdists',[],'PeakFreq',[],'BW_3dB',[]);

%             if size(thisType.Tfinal{1,1},2) == 188
%                 data.BinSpecs = [data.BinSpecs;thisType.Tfinal{1,1}];
%                 
%             elseif size(thisType.Tfinal{1,1},2) == 191
%                 data.BinSpecs = [data.BinSpecs;thisType.Tfinal{1,1}(2:189)];
%             end
%             data.ICI = [data.ICI;thisType.Tfinal{1,2}];
%             data.Deployment = [data.Deployment;depVec];

%      sumSpec = mean(data.BinSpecs,1);
%      sumSpec = sumSpec-min(sumSpec);
%      sumSpec_norm = sumSpec./max(sumSpec);
%      
%      ICI = sum(data.ICI,1);
%      
%      pf = f(find(sumSpec_norm == max(sumSpec_norm)));
%      
%      summaryStats(b).CT = trainSet(k).name;
%      summaryStats(b).MeanSpecs = sumSpec_norm;
%      summaryStats(b).ICIdists = ICI;
%      summaryStats(b).PeakFreq = pf;
%% Plot
% f = 5:0.5:98.5;

% q = size(summaryStats,2);
% m = ceil(q/n); % number of columns of subplots

for i = 1:size(summaryStats,2)
    
    figure(1)
    subplot(1,2,1)
    plot(f,summaryStats(i).MeanSpecs)
    xlim([5,100])
    ylim([0 1])
    xlabel('Frequency (kHz)');
    ylabel('Normalized Amplitude');
    
    subplot(1,2,2)
   
    
end

