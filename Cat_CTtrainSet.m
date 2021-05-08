% Load cluster bins and labels from multiple sites, organize by NNet label,
% and plot concatenated bins by label

clearvars
% directory containing toClassify files
binDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp\CT4_6+CT10';
% directory containing label files 
CT = 'CT4\6+CT10';

binFiles = dir([binDir '\*.mat']); 
nFiles = size(binFiles,1);
data = struct('BinSpecs',[],'ICI',[],'Deployment',[]);
numBins = [];

% load one file at a time, pull out spectra and bin ICI dists
for i = 1:nFiles
    load([binDir '\' binFiles(i).name]);
    n = size(thisType.Tfinal{1,1},1);
    
    stringGrab = binFiles(i).name;
    dep = strrep(stringGrab,'Copy of','');
    dep = strrep(dep,'.mat','');
    depVec = cellstr(repmat(dep,n,1));
    
    data.BinSpecs = [data.BinSpecs;thisType.Tfinal{1,1}];
    data.ICI = [data.ICI;thisType.Tfinal{1,2}];
    data.Deployment = [data.Deployment;depVec];
    numBins = [numBins;n];
    
end

%% Plotting concatenated spectra
f = 5:0.5:100;
depEdges = cumsum(numBins);

figure
% subplot(2,1,1)
imagesc([],f,data.BinSpecs');
set(gca,'ydir','normal');
colormap(jet);
hold on
for y = 1:length(depEdges)
    line(repmat(depEdges(y),length(f),1),f,'Color','k','LineWidth',1);
    line(repmat(depEdges(y),length(f),1),f,'LineStyle','--','Color','w','LineWidth',1);
end
hold off
ylim([5 95]);
ylabel('Frequency (kHz)');
colorbar
caxis([0 1]);
% xticks([(size(w,1)/2), size(w,1) + (size(n,1)/2), size(w,1) + size(n,1)...
%     + (size(h,1)/2), size(w,1) + size(n,1) + size(h,1) + (size(j,1)/2)]);
% xticklabels({'WAT','NFC','HAT','JAX'});
title(CT);
set(gca,'fontSize',14);
