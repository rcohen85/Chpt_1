%%%assessing overlap of clusters by figuring out what random overlap you
%%%would expect between two types based on their presence in a certain time
%%%bin 


%%created on 6/1/2020 by MAZ
%for use in evaluating cluster similarity, along with DWMC_compDistMat

inFile = 'I:\KA02_types_all';
outPref = 'KA02_overlapAssessment'; %this and line below are for where you want to save/naming output file
outFolder = 'I:\';

load(inFile)

%%
dutyCyc = []; %set to [] if no duty cycle. Otherwise, set to number of minutes
%of cycle, i.e., with a cycle of 5 of every 20 minutes, set this parameter
%to 20
lTimeBin = 15; %length of time bin in minutes to group data into
binWidth = 5; %size of cluster bins in minutes; just used to find datetime maximum to consider

clusTimesforUse = {Tfinal{:,7}};
% load('HI16_regroup.mat')
% clusTimesforUse = HI16_combNoise;

percClus = [];
timeOverlap = [];
timeFull = [];
fullCount = 0;

allTimes = vertcat(clusTimesforUse{:});

tMin = min(allTimes);
tMax = max(allTimes)+datenum(0,0,0,0,binWidth,0);
% 
% timeFull = tMin:datenum(0,0,0,0,lTimeBin,0):tMax;
% timeFull = [timeFull',zeros(size(timeFull,2),1)];
% 
% for iClus = 1:size(clusTimesforUse,2)
%     %     timeOverlap = [];
%     
%     %     for tI = 1:size(clusTimesforUse{iClus},1)
%     binTimes = clusTimesforUse{iClus};
%     %         timeStart = timeFull(:,1);
%     %         timeNext = timeFull(:,1)+datenum(0,0,0,0,lTimeBin,0);
%     %         timeOverlap{tI} = find(timeStart <=binTimes(tI) & binTimes(tI)<=timeNext)';
%     %     end
%     %
%     %from R.Cohen
%     [bin_count, ~, binInd] = histcounts(binTimes,[timeFull(:,1); timeFull(end,1)+datenum(0,0,0,0,lTimeBin,0)]); % divvies up bin times into intervals of interest w/o a loop (yes, vectorizing!)
%     timestoOne = unique(binInd)';
%     
%     %     timestoOne = unique([timeOverlap{:}]);
%     timeFull(timestoOne,2) = timeFull(timestoOne,2)+1;
%     fullCount = fullCount + size(timestoOne,2);
%     
%     percClus(iClus) = size(timestoOne,2);
% end
% 
% % percClus = percClus./fullCount * 100;
% percClus = percClus./size(timeFull,1) * 100;
% randOverlap = (percClus'*percClus)./100;
% 
% %prob of clX* prob clX understandably DOESN'T equal 100% because of how
% %it's calculated, but it should, so replace all diagonal values with 100.
% %If it was possible to have a bin labelled as clX twice, then what's stored
% %in here would be correct. But since that's not how it works, doing this.
% 
% for iRep = 1:size(randOverlap,1)
%     randOverlap(iRep,iRep) = 100;
% end


%% rand distribution
%create a random distribution of overlap for each cluster pairing, can then
%compare actual to this and see what's up
simPO = [];
%get 5 minute intervals to use for simulation to be most similar to
%DWMC_compDistMat
if ~isempty(dutyCyc)
    timeFullBins = tMin:datenum(0,0,0,0,binWidth,0):tMax;
    dutyBins = dutyCyc/binWidth; %length of cycle in number of bins
    timeFullBins = timeFullBins(1:dutyBins:end);
else
    timeFullBins = tMin:datenum(0,0,0,0,binWidth,0):tMax;
end
nFullBins = size(timeFullBins,2);

cl2 = 1;
%change percClus to be % of total bins in deployment that are a certain
%type
for iB = 1:size(Tfinal,1)
    percClus(iB) = (size(Tfinal{iB,1},1)./nFullBins).*100;
end
% percsForSim = round(percClus);
dnGap = datenum(0,0,0,0,lTimeBin,0);
countCl = 0;
countCltracker = [];
tic
for clN = 1:size(clusTimesforUse,2)
    while cl2<=size(clusTimesforUse,2)
        for iD = 1:1500
%             nBin1 = round((percClus(clN)/100).*fullCount);
%             nBin2 = round((percClus(cl2)/100).*fullCount);
            nBin1 = round((percClus(clN)/100).*nFullBins);
            nBin2 = round((percClus(cl2)/100).*nFullBins);
            bins1 = randi([1 nFullBins],1,nBin1);
            bins2 = randi([1 nFullBins],1,nBin2);
            times1 = timeFullBins(bins1);
            times2 = timeFullBins(bins2);
            for iCount = 1:size(times1,2)
                gap = abs(times2 - times1(iCount));
                tooClose = find(gap<=dnGap);
                if ~isempty(tooClose)
                    countCl = countCl + 1;
                end
            end
            countCltracker = [countCltracker;countCl];
            %calculate percentage that were close
            percClose(iD,:) = (countCl./size(times1,2)).*100; %percentage of bins of clus1...
            %that were within two bins of compClus
            countCl = 0;
        end
        simPO{clN,cl2} = percClose;
        cl2 = cl2 + 1;
        nBinsForNorm(clN) = nBin1;
        
        %             [overlap,~] = intersect(times1,times2);
        %             if ~isempty(overlap)
        %                 simPercOver(iD,:) = (length(overlap)/fullCount) *100;
        %             else
        %                 simPercOver(iD,:) = 0;
        %             end
    end
    %         simPO{clN,cl2} = simPercOver;
    cl2 = 1;
end

%calculate weighted average and make symmetric matrix of normalized
%percentages
simPONorm = [];
for iNorm = 1:size(simPO,1)
    cl1n = nBinsForNorm(iNorm);
    iN2 = 1;
    while iN2 <= size(simPO,1)
        cl2n = nBinsForNorm(iN2);
        simPONorm{iNorm,iN2} = (simPO{iNorm,iN2}.*cl1n + simPO{iN2,iNorm}.*cl2n)./(cl1n+cl2n);
        iN2 = iN2+1;
    end
end
toc

% if ~exist(outFolder)
%     mkdir(outFolder)
% end
% 
% outFile = [outFolder,'\',outPref,'.mat'];
% 
% save(outFile,'percClus','randOverlap','simPO','lTimeBin','simPONorm')
% 


