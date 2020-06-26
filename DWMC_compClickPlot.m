%%created on 5/29/2020 by MAZ
%for use in evaluating cluster similarity, along with DWMC_compDistMat

inFile = 'I:\WAT_NC_03\NEW_CompositeClusters\WAT_NC_03_types_all';
dep = 'WAT\_NC\_03'; %used for plot title
outPref = 'WAT_NC_03_clusPlot'; %this and line below are for where you want to save/naming output file
outFolder = 'I:\WAT_NC_03\NEW_CompositeClusters';

dutyCyc = 0; %duration of off-period of duty cycle. Set to 0 or [] if no duty cycle
binWidth = 5; %length of time bins in minutes
timeInt = 15; %time interval you want to consider (i.e., 60 minutes) for 
%presence/absence assessment. Set to [] if using duty-cycle data.

load(inFile)

clusTimesforUse = {Tfinal{:,7}}; % start times of bins contributing to each type
% load('ClusTimes_regroup.mat')
% clusTimesforUse = clusTimes2';

%% plotting stuff
% xmin = min(vertcat(clusTimesforUse{:}));
% xmax = max(vertcat(clusTimesforUse{:}));
yOff = 1;

tMin = min(cellfun(@min,clusTimesforUse));
tMax = max(cellfun(@max,clusTimesforUse))+datenum(0,0,0,0,binWidth,0);
timeFull = (tMin:datenum(0,0,0,0,timeInt,0):tMax)';

% fig1 = figure;
figure(1), clf
hold on
for iClus = 1:size(clusTimesforUse,2)
    %timeFull = [];
    %timeOverlap = [];

%     tMin = min(clusTimesforUse{iClus});
%     tMax = max(clusTimesforUse{iClus})+datenum(0,0,0,0,binWidth,0);
     
    if ~isempty(dutyCyc)
        timeInt = dutyCyc+binWidth;
    end
%     timeFull = (tMin:datenum(0,0,0,0,timeInt,0):tMax)'; % start times of all intervals containing this type, no time gaps
    
    binTimes = unique(clusTimesforUse{iClus}); % start times of bins containing this type; don't need repeated times
    %timeStart = timeFull(:,1);
%     timeNext = timeFull(:,1)+datenum(0,0,0,0,timeInt,0); % end times of intervals of interest
%     
%     for tI = 1:size(clusTimesforUse{iClus},1) % find which intervals of interest contain bins where this type showed up        
%         %timeOverlap{tI} = find(timeStart <=binTimes(tI) & binTimes(tI)<=timeNext)'; %RC NOTE: careful, order matters in logical statements! 
%         % The indices returned correspond to the elements in the FIRST LISTED variable which satisfy the condition. The way this is written
%         % here you're comparing indices in timeStart with indices in binTimes, which I don't think accomplishes what you want
%         timeOverlap{tI} = find(timeFull(:,1) <=binTimes(tI) & timeNext > binTimes(tI))'; % to avoid double counting bins, need to
%         % find when time bin is greater than or equal to start time of a given interval of interest, but LESS than (and NOT equal to)
%         % start time of next interval. This is actually still double-counting just a couple bins, not sure why it's letting
%         % these violations of the condition through.. See below for alternate solution to this whole for-loop!
%     end
%     
%      
%     timestoOne = unique([timeOverlap{:}]); % indices of bin start times containing this type
    %timeFull(timestoOne,2) = timeFull(timestoOne,2)+yOff;
    
    % Can replace lines 42:55 with this:
    [bin_count, ~, binInd] = histcounts(binTimes,[timeFull; timeFull(end)+datenum(0,0,0,0,timeInt,0)]); % divvies up bin times into intervals of interest w/o a loop (yes, vectorizing!)
    timestoOne = unique(binInd)';
    plotVal = repmat(yOff,length(timestoOne),1);

    %plot(timeFull(:,1),timeFull(:,2),'.','MarkerSize',10)
    plot(timeFull(timestoOne),plotVal,'.','MarkerSize',10)
    yOff = yOff-0.1;

end

hold off

xlim([tMin tMax])
%ylim([1 1.55])
datetick

set(gca,'ytick',[])

xlabel('Time')
ylabel('Presence (20 minute bins)')
tit2Txt = ['Presence of ',dep,' Clusters'];
title(tit2Txt)

if ~exist(outFolder)
    mkdir(outFolder)
end

legend('show','Location','northeastoutside')
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.1, 0.9, 0.6]);

outFile = [outFolder,'\',outPref];
print(outFile,'-dpng')

