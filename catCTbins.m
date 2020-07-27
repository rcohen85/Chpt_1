%% Load toClassify files and labels, organize by NNet label, and plot 
% concatenated bins by label. Requires toClassify files and predLab output
% from neural net. 
% OUTPUT: "data" struct has as many rows as NNet labels, and these fields:
% BinTimes - start times of bins to which each (retained) label was applied
% BinSpecs - mean bin spectra 
% ICI - ICI distributions 
% Env - mean waveform envelopes
% File - cluster/toClassify/predLab file each bin comes from
% WhichCell - which mean spectra within the cell was this label applied to
% Probs - label confidence
% NOTE: single click bins and spectra whose label confidence < labelThresh
% are excluded from the "data" struct

clearvars
% directory containing toClassify files
binDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify';
suffix = '_clusters_PR95_PPmin120_toClassify.mat';
% directory containing label files 
labDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels3';
NNlab = 0:19; % neural net label values
% directory to save "data" struct and plots
savDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels3';
saveName = 'HAT_B_01-03_BinsbyLabel_Thresh0'; % file name for saving "data" struct

labelThresh = 0; % only labels exceeding this confidence thresh will be saved and plotted
specInd = 1:188; % indices of spectra in toClassify files
iciInd = 190:290; % indices of ICI dists in toClassify files
envInd = (292:491); % indices of mean waveform envelopes in toClassify files
f = 5:0.5:98.5; % freq vector corresponding to spectra
t = 0:.01:1; % time vector corresponding to ICI distributions

% Label names for titling plots; same order as NNlab above
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
    'CT5','CT8','Cuvier''s','Gervais''','GoM\_Gervais''','HFA','Kogia',...
    'MFA','MultiFreq\_Sonar','Risso''s','SnapShrimp','Sowerby''s',...
    'Sperm Whale','True''s'};
% Label names for saving plots; same order as NNlab above; can't have
% forbidden characters like + or /
savname = {'Blainvilles','Boats','CT11','CT2+CT9','CT3+CT7','CT4_6+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM_Gervais','HFA','Kogia',...
    'MFA','MultiFreq_Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'};

%% Organize all labeled spectra into one big array

binFiles = dir(fullfile(binDir,'*toClassify.mat'));
labFiles = dir(fullfile(labDir,'*predLab.mat'));
nFiles = size(binFiles,1);
nn = length(NNlab);

% initialize struct to hold bin times, spectra, ICI dists, mean waveform 
% envelopes, cell each spectrum occupies in cluster_bins output, 
% label confidence, and deployment info, etc.
data = struct('CT',[],'NNet_Lab',[],'BinTimes',[],'BinSpecs',[],'ICI',[],...
    'Env',[],'File',[],'WhichCell',[],'Probs',[],'nSpec',[]);
for i = 1:nn
    data(i).CT = CTs{i};
    data(i).NNet_Lab = NNlab(i);
end

% load one cluster & corresponding label file at a time, pull out desired
% info for each NNet label
for i=1:nFiles
    load(fullfile(binDir, binFiles(i).name));
    load(fullfile(labDir, labFiles(i).name));
    
    stringGrab = binFiles(i).name;
    stringGrab = erase(stringGrab,suffix);
    
    for j=1:nn
        % find bins labeled with target label, with prob > labelThresh
        labInd = find(predLabels==NNlab(j));
        labInd = labInd(probs(labInd,j)>=labelThresh);
        
        % If high confidence labels exist, find times of labeled bins
        if ~isempty(labInd)
            if exist('toClassify')
                labTime = sumTimeMat(labInd,1);
                labSpec = toClassify(labInd,specInd);
                labICI = toClassify(labInd,iciInd);
                labEnv = toClassify(labInd,envInd);
                labFile = cellstr(repmat(stringGrab,length(labInd),1,1));
                labCell = whichCell(labInd);
                labProbs = probs(labInd,j);
                nSpec = nSpecMat(labInd);
            else
                fprintf('Error: Don''t recognize variable names\n');
                return
            end
            
            data(j).BinTimes = [data(j).BinTimes;labTime];
            data(j).BinSpecs = [data(j).BinSpecs;labSpec];
            data(j).ICI = [data(j).ICI;labICI];
            data(j).Env = [data(j).Env;labEnv];
            data(j).File = [data(j).File;labFile];
            data(j).WhichCell = [data(j).WhichCell;labCell];
            data(j).Probs = [data(j).Probs;labProbs];
            data(j).nSpec = [data(j).nSpec;nSpec];
        end
        
    end
    fprintf('Done with file %d of %d\n',i,nFiles);
end

% Sort bins into chronological order within each label
for j = 1:nn
[B, sortInd] = sortrows(data(j).BinTimes);
data(j).BinTimes = data(j).BinTimes(sortInd);
data(j).BinSpecs = data(j).BinSpecs(sortInd,:);
data(j).ICI = data(j).ICI(sortInd,:);
data(j).Env = data(j).Env(sortInd,:);
data(j).File = data(j).File(sortInd,:);
data(j).WhichCell = data(j).WhichCell(sortInd);
data(j).Probs = data(j).Probs(sortInd);
data(j).nSpec = data(j).nSpec(sortInd);
end

save(fullfile(savDir, saveName),'data','labelThresh','f','t','-v7.3');

%% Plot concatenated spectra for each label

N = length(CTs); % number of labels

for i = 1:N
    
    catSpecs = vertcat(data(i).BinSpecs);
    ICI = vertcat(data(i).ICI);
    meanICI = mean(ICI,1);
        
    figure(1)
    subplot(1,4,1:3)
    imagesc([],f,catSpecs');
    set(gca,'ydir','normal');
    colormap(jet);
    ylabel('Frequency (kHz)');
    xlabel('Bin Number');
    title(CTs{i});
    set(gca,'fontSize',14);
    subplot(1,4,4)
    plot(t,meanICI,'LineWidth',2);
    grid on
    xticks([0 0.25 0.5 0.75 1]);
    xlabel('ICI (s)');
    ylabel('Normalized Counts');
    set(gca,'fontSize',14);
    
    fprintf('Click figure for next plot\n');
    w = waitforbuttonpress; %uncomment if you want to click to step
    %    through plots as they're generated
    
    saveas(gcf,fullfile(savDir,[savname{i} '_Thresh' num2str(labelThresh*100)]),'tiff');
end

%% Old plotting code
% clearvars
% cd('G:\New_Atl_CTs\CatSpecs');
% N = length(CTs); % number of labels
% % Names for NNet labels, in numeric order (0:N-1); for plot titles
% CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
%     'CT5','CT8','Cuvier''s','Gervais''','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
%     'Kogia','MFA','MultiFreq Sonar','Risso''s','Sowerby''s','Sperm Whale',...
%     'Spiky Sonar','True''s','Wideband Sonar'};
% % Names for labels, in numeric order (1:n); for saving plots (can't have
% % forbidden characters like + or /)
% savname = {'Blainvilles','Boats','CT11','CT2_CT9','CT3_CT7','CT4_6C_T10',...
%     'CT5','CT8','Cuviers','Gervais','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
%     'Kogia','MFA','MultiFreq Sonar','Rissos','Sowerbys','Sperm Whale',...
%     'Spiky Sonar','Trues','Wideband Sonar'};
% f = 5:0.5:98.5;
% 
% % Load files containing bin spectra with their corresponding labels
% HAT = load('HAT');
% WAT = load('WAT');
% NFC = load('NFC');
% JAX = load('JAX');
% 
% for i = 1:N
%     
%     w = WAT.data(i).BinSpecs;
%     n = NFC.data(i).BinSpecs;
%     h = HAT.data(i).BinSpecs;
%     j = JAX.data(i).BinSpecs;
%     
%     catSpecs = [w;n;h;j];
%     
%     wICI = WAT.data(i).ICI;
%     nICI = NFC.data(i).ICI;
%     hICI = HAT.data(i).ICI;
%     jICI = JAX.data(i).ICI;
%     
%     ICI = [wICI;nICI;hICI;jICI];
%     meanICI = mean(ICI,1);
%     t = 0:.01:0.6;
%     
%     k = [size(w,1), size(w,1) + size(n,1), size(w,1) + size(n,1) + size(h,1)];
%     
%     figure(1)
%     subplot(1,4,1:3)
%     imagesc([],f,catSpecs');
%     set(gca,'ydir','normal');
%     colormap(jet);
%     for y = 1:length(k)
%         line(repmat(k(y),length(f),1),f,'Color','k','LineWidth',3);
%         line(repmat(k(y),length(f),1),f,'LineStyle','--','Color','w','LineWidth',3);
%     end
%     ylabel('Frequency (kHz)');
%     xlabel('Bin Number');
%     xticks([(size(w,1)/2), size(w,1) + (size(n,1)/2), size(w,1) + size(n,1)...
%         + (size(h,1)/2), size(w,1) + size(n,1) + size(h,1) + (size(j,1)/2)]);
%     xticklabels({'WAT','NFC','HAT','JAX'});
%     title(CTs{i});
%     set(gca,'fontSize',14);
%     subplot(1,4,4)
%     plot(t,meanICI,'LineWidth',2);
%     grid on
%     xticks([0 0.25 0.5 0.75 1]);
%     xlabel('ICI (s)');
%     ylabel('Normalized Counts');
%     set(gca,'fontSize',14);
%     
%     fprintf('Click figure for next plot\n');
%     w = waitforbuttonpress; %uncomment if you want to click to step
%        through plots
%     
%     saveas(gcf,fullfile(savDir,savname{i}),'tiff');
%     w = [];
%     n = [];
%     h = [];
% end
