% Load cluster bins and labels from multiple sites, organize by NNet label,
% and plot concatenated bins by label

clearvars
% directory containing toClassify files
binDir = 'I:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify';
% directory containing label files 
labDir = 'I:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels2';
NNlab = 0:21; % neural net labels
savDir = 'I:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels2';
clusterSuffix = '_clusters_PR95_PPmin120_toClassify.mat';
saveName = 'HAT_B_01-03_BinsbyLabel';
labelThresh = 0.97;
specInd = 1:188;
iciInd = 190:290;
envInd = (292:491);
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
    'CT5','CT8','Cuvier''s','Gervais''','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
    'Kogia','MFA','MultiFreq Sonar','Risso''s','Sowerby''s','Sperm Whale',...
    'Spiky Sonar','True''s','Wideband Sonar'};

%%
binFiles = dir(fullfile(binDir,'*toClassify.mat'));
labFiles = dir(fullfile(labDir,'*predLab.mat'));
nFiles = size(binFiles,1);
nn = length(NNlab);

% initialize matrix to hold spectra, times, and deployment info
data = struct('CT',[],'NNet_Lab',[],'BinTimes',[],'BinSpecs',[],'ICI',[],...
    'Env',[],'File',[],'WhichCell',[],'Probs',[]);
for i = 1:nn
    data(i).CT = CTs{i};
    data(i).NNet_Lab = NNlab(i);
end

% load one cluster & corresponding label file at a time, pull out spectra,
% bin start times, and bin ICI dist for each NNet label
for i=1:nFiles
    load(fullfile(binDir, binFiles(i).name));
    load(fullfile(labDir, labFiles(i).name));
    
    stringGrab = binFiles(i).name;
    stringGrab = erase(stringGrab,clusterSuffix);
    
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
            else
                fprintf('Error: Don''t recognize cluster variable names\n');
                return
            end
            
            data(j).BinTimes = [data(j).BinTimes;labTime];
            data(j).BinSpecs = [data(j).BinSpecs;labSpec];
            data(j).ICI = [data(j).ICI;labICI];
            data(j).Env = [data(j).Env;labEnv];
            data(j).File = [data(j).File;labFile];
            data(j).WhichCell = [data(j).WhichCell;labCell];
            data(j).Probs = [data(j).Probs;labProbs];
        end
        
    end
    fprintf('Done with file %d of %d\n',i,nFiles);
end

% Sort bins into chronological order
for j = 1:nn
[B, sortInd] = sortrows(data(j).BinTimes);
data(j).BinTimes = data(j).BinTimes(sortInd);
data(j).BinSpecs = data(j).BinSpecs(sortInd,:);
data(j).ICI = data(j).ICI(sortInd,:);
data(j).Env = data(j).Env(sortInd,:);
data(j).File = data(j).File(sortInd,:);
data(j).WhichCell = data(j).WhichCell(sortInd);
data(j).Probs = data(j).Probs(sortInd);
end

save(fullfile(savDir, saveName),'data','-v7.3');

%% Plotting concatenated spectra
% clearvars
% cd('G:\New_Atl_CTs\CatSpecs');
N = length(CTs); % number of labels
% Names for NNet labels, in numeric order (0:N-1); for plot titles
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
    'CT5','CT8','Cuvier''s','Gervais''','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
    'Kogia','MFA','MultiFreq Sonar','Risso''s','Sowerby''s','Sperm Whale',...
    'Spiky Sonar','True''s','Wideband Sonar'};
% Names for labels, in numeric order (1:n); for saving plots
savname = {'Blainvilles','Boats','CT11','CT2_CT9','CT3_CT7','CT4_6C_T10',...
    'CT5','CT8','Cuviers','Gervais','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
    'Kogia','MFA','MultiFreq Sonar','Rissos','Sowerbys','Sperm Whale',...
    'Spiky Sonar','Trues','Wideband Sonar'};
f = 5:0.5:98.5;

% Load files containing bin spectra with their corresponding labels
% HAT = load('HAT');
% WAT = load('WAT');
% NFC = load('NFC');
% JAX = load('JAX');

for i = 1:N
    
%     w = WAT.data(i).BinSpecs;
%     n = NFC.data(i).BinSpecs;
%     h = HAT.data(i).BinSpecs;
%     j = JAX.data(i).BinSpecs;
%     
%     catSpecs = [w;n;h;j];
      catSpecs = vertcat(data(i).BinSpecs);
%     
%     wICI = WAT.data(i).ICI;
%     nICI = NFC.data(i).ICI;
%     hICI = HAT.data(i).ICI;
%     jICI = JAX.data(i).ICI;
    
%     ICI = [wICI;nICI;hICI;jICI];
    ICI = vertcat(data(i).ICI);
    meanICI = mean(ICI,1);
    t = 0:.01:1;
    
%     k = [size(w,1), size(w,1) + size(n,1), size(w,1) + size(n,1) + size(h,1)];
    
    figure(1)
    subplot(1,4,1:3)
    imagesc([],f,catSpecs');
    set(gca,'ydir','normal');
    colormap(jet);
%     for y = 1:length(k)
%         line(repmat(k(y),length(f),1),f,'Color','k','LineWidth',3);
%         line(repmat(k(y),length(f),1),f,'LineStyle','--','Color','w','LineWidth',3);
%     end
    ylabel('Frequency (kHz)');
    xlabel('Bin Number');
%     xticks([(size(w,1)/2), size(w,1) + (size(n,1)/2), size(w,1) + size(n,1)...
%         + (size(h,1)/2), size(w,1) + size(n,1) + size(h,1) + (size(j,1)/2)]);
%     xticklabels({'WAT','NFC','HAT','JAX'});
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
    %    through plots
    
    saveas(gcf,fullfile(savDir,savname{i}),'tiff');
%     w = [];
%     n = [];
%     h = [];
end
