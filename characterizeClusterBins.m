% Characterize number of spectra per bin in clusterBins output
clearvars
inDir = 'J:\HAT_B_04-05_combined\cluster_bins';
fileList = dir(fullfile(inDir,'*_clusters_PR95_PPmin120.mat'));
sumSpec = [];
numSpecs = [];
propSpecs = {'Single','Double','Triple','4+'};

for i = 1:size(fileList,1)
    
    load(fullfile(inDir,fileList(i).name));
    sumSpec = struct2cell(binData);
    numSpecs = [numSpecs, cellfun(@(x) size(x,1),sumSpec(1,:))];
    
end

whichSingle = sum(numSpecs==1);
whichDouble = sum(numSpecs==2);
whichTriple = sum(numSpecs==3);
which4plus = sum(numSpecs>=4);

propSpecs{2,1} = whichSingle/size(numSpecs,2);
propSpecs{2,2} = whichDouble/size(numSpecs,2);
propSpecs{2,3} = whichTriple/size(numSpecs,2);
propSpecs{2,4} = which4plus/size(numSpecs,2);