%%%assessing overlap of clusters by figuring out what random overlap you
%%%would expect between two types based on their presence in a certain time
%%%bin 


%%created on 6/1/2020 by MAZ
%for use in evaluating cluster similarity, along with DWMC_compDistMat

inFile = 'I:\WAT_BC_02\NEW_CompositeClusters\WAT_BC_02_types_all';
outPref = 'WAT_BC_02_overlapAssessment'; %this and line below are for where you want to save/naming output file
outFolder = 'I:\WAT_BC_02\NEW_CompositeClusters';

load(inFile)

%% 
lTimeBin = 15; %length of time bin in minutes to group data into
binWidth = 5; %size of cluster bins in minutes; just used to find datetime maximum to consider 

clusTimesforUse = {Tfinal{:,7}};
% load('ClusTimes_regroup.mat')
% clusTimesforUse = clusTimes2';

percClus = [];
timeOverlap = [];
timeFull = [];
fullCount = [];

tMin = min(cellfun(@min,clusTimesforUse));
tMax = max(cellfun(@max,clusTimesforUse))+datenum(0,0,0,0,binWidth,0);
timeFull = (tMin:datenum(0,0,0,0,lTimeBin,0):tMax)';

for iClus = 1:size(clusTimesforUse,2)
    %timeFull = [];
    %timeOverlap = [];

    %timeFull = [timeFull',zeros(size(timeFull,2),1)];
    binTimes = clusTimesforUse{iClus};
    
%     for tI = 1:size(clusTimesforUse{iClus},1)
%         
%         timeStart = timeFull(:,1);
%         timeNext = timeFull(:,1)+datenum(0,0,0,0,lTimeBin,0);
%         timeOverlap{tI} = find(timeStart <=binTimes(tI) & binTimes(tI)<timeNext)';
%     end
    
%     timestoOne = unique([timeOverlap{:}]);
    %timeFull(timestoOne,2) = timeFull(timestoOne,2)+1;
    [bin_count, ~, binInd] = histcounts(binTimes,[timeFull(:,1); timeFull(end,1)+datenum(0,0,0,0,lTimeBin,0)]); % divvies up bin times into intervals of interest w/o a loop (yes, vectorizing!)
    timestoOne = unique(binInd)'; % indices of time intervals containing this CT
    %     fullCount = fullCount + size(timestoOne,2); % Just counting # of time
    %     intervals with clusters present might lead to double counting (when
    %     more than one cluster is present in an interval)
    fullCount = [fullCount;timeFull(timestoOne)]; % running tally of start times of all time intervals containing clicks
    
    percClus(iClus) = size(timestoOne,2); % number of time intervals containing this CT
end

fullCount = unique(fullCount); % start times of all intervals in which clicks were present
%percClus = percClus./length(fullCount) * 100; % don't want to multiply percentages by 100 before using them as probabilities
percClus = percClus./length(fullCount); % prevalence of each CT represented as a percent of all time intervals containing clicks
%randOverlap = (percClus'*percClus)./100; % since probabilities not multiplied by 100 above, need to multiply by 100 here, not divide
randOverlap = (percClus'*percClus)*100;

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