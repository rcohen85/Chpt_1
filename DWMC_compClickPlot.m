%%created on 5/29/2020 by MAZ
%for use in evaluating cluster similarity, along with DWMC_compDistMat

inFile = 'H:\reProcessed\Kauai\Kauai01\TPWS\clusterBins_pp120\composite_final\KA01_pp120_types_all';
dep = 'KA01_regrouup'; %used for plot title
outPref = 'KA01_clusPlot_regroup'; %this and line below are for where you want to save/naming output file
outFolder = 'H:\reProcessed\Kauai\Kauai01\clusterEval';

dutyCyc = 15; %duration of off-period of duty cycle. Set to [] if no duty cycle
binWidth = 5; %length of bin in minutes
timeInt = []; %time interval you want to consider (i.e., 60 minutes) for 
%presence/absence assessment. Set to [] if using duty-cycle data.

load(inFile)

clusTimesforUse = {Tfinal{:,7}}; % start times of bins contributing to each type
% load('ClusTimes_regroup.mat')
% clusTimesforUse = clusTimes2';

%% plotting stuff
xmin = min(vertcat(clusTimesforUse{:}));
xmax = max(vertcat(clusTimesforUse{:}));
yOff = 1.5;

fig1 = figure;
for iClus = 1:size(clusTimesforUse,2)
    timeFull = [];
    timeOverlap = [];

    tMin = min(clusTimesforUse{iClus});
    tMax = max(clusTimesforUse{iClus})+datenum(0,0,0,0,binWidth,0);
    
    if ~isempty(dutyCyc)
        timeInt = dutyCyc+binWidth;
    end
    timeFull = tMin:datenum(0,0,0,0,timeInt,0):tMax; % total span of time bins containing this type, no time gaps
    timeFull = [timeFull',zeros(size(timeFull,2),1)];
    
    for tI = 1:size(clusTimesforUse{iClus},1)
        binTimes = clusTimesforUse{iClus}; % start times of bins containing this type
        timeStart = timeFull(:,1);
        timeNext = timeFull(:,1)+datenum(0,0,0,0,timeInt,0);
        timeOverlap{tI} = find(timeStart <=binTimes(tI) & binTimes(tI)<=timeNext)'; %RC NOTE: order matters in logical statements! 
        % The indices returned correspond to the elements in the first variable which satisfy the condition. The way this is written
        % here you're comparing indices in timeStart with indices in binTimes, which doesn't make sense
    end
    
    timestoOne = unique([timeOverlap{:}]); % indices of bin start times containing this type
    timeFull(timestoOne,2) = timeFull(timestoOne,2)+yOff;
    
hold on
    %plot(timeFull(timestoOne,1),timeFull(timestoOne,2),'.','MarkerSize',10)
    plot(timeFull(timestoOne,1),yOff,'.','MarkerSize',10)
yOff = yOff-0.1;

end

hold off

xlim([xmin xmax])
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

