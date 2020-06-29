%% Calculate proportion of clicks included in cluster_bins mean spectra,
% and proportion isolated, across entire deployment


inDir = 'I:\WAT_WC_02\NEW_ClusterBins_120dB'; %directory containing cluster_bins output
binList = dir(fullfile(inDir,'*clusters*.mat'));

percSpec_perFile = zeros(length(binList),1,1);

for iA = 1:length(binList)
    
     load(fullfile(binList(iA).folder,binList(iA).name));
     percSpec = sum(horzcat(binData.percSpec))/length(binData);
     
     percSpec_perFile(iA) = percSpec;
    
end

figure
histogram(percSpec_perFile,0:0.01:1);
title('Proportion of Clicks Included in Clusters, Per File');
xlabel('%');
ylabel('Counts');

total_percSpec = mean(percSpec_perFile)*100;
total_percIso = (100-total_percSpec);

fprintf('%.2f %% of clicks included in mean spectra, %.2f %% isolated\n',...
    total_percSpec,total_percIso);