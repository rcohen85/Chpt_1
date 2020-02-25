% Load cluster bins and labels from multiple sites, organize by NNet label,
% and plot concatenated bins by label

clearvars
% directory containing toClassify files
binDir = 'I:\JAX_D_13_Detectormetadata\ClusterBins_120dB\ClusterToClassify';
% directory containing label files 
labDir = 'I:\JAX_D_13_Detectormetadata\ClusterBins_120dB\ClusterToClassify\labels';
NNlab = 0:18; % neural net labels
savDir = 'G:\New_Atl_CTs\CatSpecs';
saveName = 'JAX';

CTs = {'CT10','CT2','CT3','CT4/6','CT5','CT7','CT8','CT9','Blainville''s',...
    'Boats','Cuvier''s','Echosounder','Gervais''','Kogia','Noise','Risso''s',...
    'Sowerby''s','Sperm Whale','True''s'};

binFiles = dir([binDir '\*.mat']); 
labFiles = dir([labDir '\*.mat']); 
nFiles = size(binFiles,1);
nn = length(NNlab);

% initialize matrix to hold spectra, times, and deployment info
data(19) = struct('CT',[],'NNet_Lab',[],'BinTimes',[],'BinSpecs',[],'ICI',[],'Deployment',[]);
for i = 1:nn
    data(i).CT = CTs{i};
    data(i).NNet_Lab = NNlab(i);
end

% load one cluster & corresponding label file at a time, pull out spectra,
% bin start times, and bin ICI dist for each NNet label 
for i=1:nFiles
    load([binDir '\' binFiles(i).name]);
    load([labDir '\' labFiles(i).name]);
    
    stringGrab = binFiles(i).name(1:17);
    
    for j=1:nn
    % find bins labeled with target label with prob greater than 95%
    labInd = find(predLabels==NNlab(j));
    labInd = labInd(find(probs(labInd,j)>=0.98));
    
    % If high confidence labels exist, find times of labeled bins
    if ~isempty(labInd)
        if exist('toClassify')
            labTime = sumTimeMat(labInd,1);
            labSpec = toClassify(labInd,1:188);
            labICI = toClassify(labInd,190:250);
            dep = cellstr(repmat(stringGrab,length(labInd),1,1));
        elseif exist('nnVec')
            labTime = catTimes(labInd,1);
            labSpec = nnVec(labInd,1:188);
            labICI = nnVec(labInd,190:250);
            dep = cellstr(repmat(stringGrab,length(labInd),1,1));
        else
            fprintf('Error: Don''t recognize cluster variable names\n');
            return
        end
        
        data(j).BinTimes = [data(j).BinTimes;labTime];
        data(j).BinSpecs = [data(j).BinSpecs;labSpec];
        data(j).ICI = [data(j).ICI;labICI];
        data(j).Deployment = [data(j).Deployment;dep];
    end
    end
    fprintf('Done with file %d of %d\n',i,nFiles);
end
save([savDir '\' saveName],'data');

%% Plotting concatenated spectra
clearvars
cd('G:\New_Atl_CTs\CatSpecs');
N = 19; % number of labels
% Names for NNet labels, in numeric order (0:N-1); for plot titles
CTs = {'CT10','CT2','CT3','CT4/6','CT5','CT7','CT8','CT9','Blainville''s',...
    'Boats','Cuvier''s','Echosounder','Gervais''','Kogia','Noise','Risso''s',...
    'Sowerby''s','Sperm Whale','True''s'};
% Names for labels, in numeric order (1:n); for saving plots
savname = {'CT10','CT2','CT3','CT4_6','CT5','CT7','CT8','CT9','Blainvilles',...
    'Boats','Cuviers','Echosounder','Gervais','Kogia','Noise','Rissos',...
    'Sowerbys','Sperm Whale','Trues'};
f = 5:0.5:98.5;

% Load files containing bin spectra with their corresponding labels
HAT = load('HAT');
WAT = load('WAT');
NFC = load('NFC');
JAX = load('JAX');

for i = 1:N
    
    w = WAT.data(i).BinSpecs;
    n = NFC.data(i).BinSpecs;
    h = HAT.data(i).BinSpecs;
    j = JAX.data(i).BinSpecs;
    
    catSpecs = [w;n;h;j];
    
    wICI = WAT.data(i).ICI;
    nICI = NFC.data(i).ICI;
    hICI = HAT.data(i).ICI;
    jICI = JAX.data(i).ICI;
    
    ICI = [wICI;nICI;hICI;jICI];
    meanICI = mean(ICI,1);
    t = 0:.01:.6;
    
    k = [size(w,1), size(w,1) + size(n,1), size(w,1) + size(n,1) + size(h,1)];
    
    figure(1)
    subplot(1,4,1:3)
    imagesc([],f,catSpecs');
    set(gca,'ydir','normal');
    colormap(jet);
    for y = 1:length(k)
        line(repmat(k(y),length(f),1),f,'Color','k','LineWidth',3);
        line(repmat(k(y),length(f),1),f,'LineStyle','--','Color','w','LineWidth',3);
    end
    ylabel('Frequency (kHz)');
    xticks([(size(w,1)/2), size(w,1) + (size(n,1)/2), size(w,1) + size(n,1)...
        + (size(h,1)/2), size(w,1) + size(n,1) + size(h,1) + (size(j,1)/2)]);
    xticklabels({'WAT','NFC','HAT','JAX'});
    title(CTs{i});
    set(gca,'fontSize',14);
    subplot(1,4,4)
    plot(t,meanICI,'LineWidth',2);
    grid on
    xticks([0 0.1 0.2 0.3 0.4 0.5 0.6]);
    xlabel('ICI (s)');
    ylabel('Normalized Counts');
    set(gca,'fontSize',14);
    
    fprintf('Click figure for next plot\n');
    w = waitforbuttonpress; %uncomment if you want to click to step
    %    through plots
    
    saveas(gcf,savname{i},'tiff');
    w = [];
    n = [];
    h = [];
end
