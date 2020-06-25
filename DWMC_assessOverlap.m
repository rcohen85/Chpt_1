%%%assessing overlap of clusters by figuring out what random overlap you
%%%would expect between two types based on their presence in a certain time
%%%bin 


%%created on 6/1/2020 by MAZ
%for use in evaluating cluster similarity, along with DWMC_compDistMat

inFile = 'H:\reProcessed\Kauai\Kauai01\TPWS\clusterBins_pp120\composite_final\KA01_pp120_types_all';
outPref = 'KA01_overlapAssessment_regroup'; %this and line below are for where you want to save/naming output file
outFolder = 'H:\reProcessed\Kauai\Kauai01\clusterEval';

load(inFile)

%% 
lTimeBin = 60; %length of time bin in minutes to group data into
binWidth = 5; %size of cluster bins in minutes; just used to find datetime maximum to consider 

clusTimesforUse = {Tfinal{:,7}};
% load('ClusTimes_regroup.mat')
% clusTimesforUse = clusTimes2';

percClus = [];
timeOverlap = [];
timeFull = [];
fullCount = 0;

for iClus = 1:size(clusTimesforUse,2)
    timeFull = [];
    timeOverlap = [];

    tMin = min(clusTimesforUse{iClus});
    tMax = max(clusTimesforUse{iClus})+datenum(0,0,0,0,binWidth,0);
    
    timeFull = tMin:datenum(0,0,0,0,lTimeBin,0):tMax;
    timeFull = [timeFull',zeros(size(timeFull,2),1)];
    
    for tI = 1:size(clusTimesforUse{iClus},1)
        binTimes = clusTimesforUse{iClus};
        timeStart = timeFull(:,1);
        timeNext = timeFull(:,1)+datenum(0,0,0,0,lTimeBin,0);
        timeOverlap{tI} = find(timeStart <=binTimes(tI) & binTimes(tI)<=timeNext)';
    end
    
    timestoOne = unique([timeOverlap{:}]);
    timeFull(timestoOne,2) = timeFull(timestoOne,2)+1;
    fullCount = fullCount + size(timestoOne,2);
    
    percClus(iClus) = size(timestoOne,2);
end

percClus = percClus./fullCount * 100;
randOverlap = (percClus'*percClus)./100;

%prob of clX* prob clX understandably DOESN'T equal 100% because of how
%it's calculated, but it should, so replace all diagonal values with 100.
%If it was possible to have a bin labelled as clX twice, then what's stored
%in here would be correct. But since that's not how it works, doing this. 

for iRep = 1:size(randOverlap,1)
    randOverlap(iRep,iRep) = 100;
end


if ~exist(outFolder)
    mkdir(outFolder)
end

outFile = [outFolder,'\',outPref,'.mat'];

save(outFile,'percClus','randOverlap')