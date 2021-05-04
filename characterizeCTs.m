%% Calculate summary stats for click types used to train a neural net; plot
% mean spectra and ICI distributions

clearvars
% directory containing folders with composite_clusters output training examples
trainDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp';

%%
trainSet = dir(trainDir);
trainSet(1:2) = [];

for k = 1:size(trainSet,1) %for each click type
    if trainSet(k).isdir == 1 
        typeDir = fullfile(trainSet(k).folder,trainSet(k).name);
        compClustFiles = dir([typeDir '\*.mat']);
        nFiles = size(compClustFiles,1);
        clickTimes = [];
        deploy = [];
        TPWSind = [];
        TPWSfiles = [];     
       
        for i = 1:nFiles  % run through composite_clusters files and pull out click times & TPWS indices
            load([typeDir '\' compClustFiles(i).name]);
            
            stringGrab = compClustFiles(i).name;
            if ~isempty(strfind(stringGrab,'Copy of '))
            dep = strrep(stringGrab,'Copy of ','');
            end
            typeInd = strfind(dep,'_');
            dep = dep(1:typeInd(end)-1);
            depVec = cellstr(repmat(dep,size(thisType.clickTimes,1),1));
    
           clickTimes = [clickTimes;thisType.clickTimes];
           deploy = [deploy;depVec];
           TPWSfiles = [TPWSfiles;TPWSList(thisType.fileNumExpand)'];
           TPWSind = [TPWSind;thisType.fileNumExpand];         
           
        end

    end
end

%% Run through TPWS and pull out click spectra, ICI, PPRL, & time
% series

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

