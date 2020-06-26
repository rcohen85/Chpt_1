%created on 5/29/2020 by MAZ

%%%%dude where's my click take 2- for evaluating cluster performance. Creates a matrix of 
%percentages of bins of each cluster that are within a user-defined time-based 
%distance of bins of any other cluster. i.e., percentage of bins of cluster
%9 that are within 50 minutes of bins of cluster 3. Also creats an
%equivalent matrix of randomly expected overlap based on the prevalence of
%each cluster.

%%output: percFinal which has matrix of percentages, PONorm which has normalized overlap
%%percentages(via weighted average) for each cluster pair, and closeBins which
%%contains one cell per cluster. Each of these cells contains one cell per
%%cluster (i.e., cell 1 contains 9 cells for comparisons between cluster 1
%%and each other cluster 1-9. I.e., closeBins{1}{1,3} has columns that
%%represent each bin of cluster 1; closeBins{1}{1,3}{1,6} contains the bin
%%numbers of all bins in cluster 3 that were within the specified distance
%%of cluster 1 bin #6. If closeBins{1}{1,3}{1,6} contains values [7,8],
%%this means cluster 3 bins 7 and 8 were within x distance of cluster 1 bin
%%6. SimPONorm is the expected random percent overlap, which is the average
%%of many simulations.

inFile = 'I:\WAT_HZ_04\WAT_HZ_04_types_all';
outPref = 'WAT_HZ_04_OverlapMats';
outFolder = 'I:\WAT_HZ_04';

dutyCyc = 0; %duration of off-period of duty cycle. Set to 0 if no duty cycle
binWidth = 5; %length of bins in minutes
intv = 3; %number of bins for the distance gap 
itnum = 500; %number of iterations to run random percent overlap simulation
 
load(inFile)
clusTimesforUse = {Tfinal{:,7}};

%% Calculate randomly expected overlap between each click type
% Randomly seed correct number of bins with each cluster and calculate
% expected overlapwith each other cluster; take mean of many iterations to 
% arrive at each probability

tMin = min(cellfun(@min,clusTimesforUse));
tMax = max(cellfun(@max,clusTimesforUse))+datenum(0,0,0,0,binWidth,0);
timeFull = (tMin:datenum(0,0,0,0,binWidth,0):tMax)'; % set of bins spanning deployment

minsBetween = dutyCyc.*(intv+1) + intv*binWidth;
dnGap = datenum(0,0,0,0,minsBetween,0); % gap length

simPO = []; % simulated percentage overlap
simPOcell = [];
simPONorm = []; % simulated percentage overlap normalized to prevalence of each cluster being compared
cl2 = 1;
countCl = [];
nBins = cellfun('length',clusTimesforUse);
    
tic
for clN = 1:size(clusTimesforUse,2)
    while cl2<=size(clusTimesforUse,2)
        %fprintf('Comparing cluster %d to cluster %d\n',clN,cl2);
        ind1 = randi(length(timeFull),itnum,nBins(clN)); %randomly pick appropriate # of bins to contain cluster(clN)
        ind2 = randi(length(timeFull),itnum,nBins(cl2)); %randomly pick appropriate # of bins to contain cluster(cl2)
        times1 = timeFull(ind1); % start times of random bins of cluster(clN)
        times2 = timeFull(ind2); % start times of random bins of cluster(cl2)
        
        for iD = 1:itnum
            q = abs(bsxfun(@minus,times2(iD,:),times1(iD,:)')); % find time differences btwn each time bin
            tooClose = q <= dnGap; % identify any differences < desired gap
            tooCloseBins = sum(tooClose,2); % these bins of times1 are withing gap distance of at least one bin in times2
            countCl(iD) = sum(tooCloseBins > 0); % total count of bins in times 1 overlapping with any bins in times2 for each iteration
        end
        
%         simPO(clN,cl2) = (mean(countCl)/nBins(clN)).*100; % average percent of cluster(clN) which overlaps with cluster(cl2)
        simPO{clN,cl2} = (countCl)/nBins(clN).*100; % average percent of cluster(clN) which overlaps with cluster(cl2)


        cl2 = cl2 + 1;
        countCl = 0;
    end
    cl2 = 1;
end

% normalize simPO relative to number of bins of each cluster in a pair
for iNorm = 1:size(simPO,1)
    cl1n = nBins(iNorm);
    iN2 = 1;
    while iN2 <= size(simPO,1)
        cl2n = nBins(iN2);
%         simPONorm(iNorm,iN2) = (simPO(iNorm,iN2).*cl1n + simPO(iN2,iNorm).*cl2n)./(cl1n+cl2n);
    simPONorm{iNorm,iN2} = (simPO{iNorm,iN2}.*cl1n + simPO(iN2,iNorm).*cl2n)./(cl1n+cl2n);
        iN2 = iN2+1;
    end
end

% each cluster should overlap with itself 100% of the time, but because of
% how the random overlap is calculated we end up with other values
for iRep = 1:size(simPONorm,1)
%     simPONorm(iRep,iRep) = 100;
    simPONorm{iRep,iRep} = 100;
end
toc
%% Calculate actual overlap between each cluster
% Find all instances of a given cluster showing up within gap distance of
% any other cluster and calculate actual overlap for every pairwise
% combination

tooClose = [];
percClose = [];
percFinal = [];
closePerClus = [];
closeBins = [];
PONorm = [];

%calculate time difference for consideration
minsBetween = dutyCyc.*(intv+1) + intv*binWidth;
dnGap = datenum(0,0,0,0,minsBetween,0);
countCl = 0;
nBins = cellfun('length',clusTimesforUse);

for iClus = 1:size(clusTimesforUse,2) % for each cluster type
    clusTimes = clusTimesforUse{iClus}; % start times of bins contributing to this cluster
    for iComp = 1:size(clusTimesforUse,2) % compare to each other cluster type
        compTimes = clusTimesforUse{iComp};
        for iCount = 1:size(clusTimes,1) % find time differences btwn each time bin & identify those < desired distance gap
            gap = abs(compTimes - clusTimes(iCount)); % identify any differences < desired gap
            tooClose {iCount} = find(gap<=dnGap)'; % these bins of clusTimes are withing gap distance of at least one bin in compTimes
            if ~isempty(tooClose{iCount}) 
                countCl = countCl + 1; %total count of bins in clusTimes overlapping with at least one bin in compTimes
            end
        end
        
        %calculate percentage of bins of clusTimes which overlap with compTimes
        percClose(iComp,:) = (countCl./size(clusTimes,1)).*100;
        closePerClus{iComp} = tooClose;
        
        countCl = 0;
        tooClose = [];
    end
    percFinal(iClus,:) = percClose;
    closeBins{iClus} = closePerClus;
end

%Combine percent overlap of each cluster in a pair to calculate weighted average 
%and make symmetric matrix of percentages normalized by cluster prevalence
for iNorm = 1:size(percFinal,1)
    cl1n = nBins(iNorm);
    iN2 = 1;
    while iN2 <= size(percFinal,1)
        cl2n = nBins(iN2);
        PONorm(iNorm,iN2) = (percFinal(iNorm,iN2).*cl1n + percFinal(iN2,iNorm).*cl2n)./(cl1n+cl2n);
        iN2 = iN2+1;
    end
end


if ~exist(outFolder)
    mkdir(outFolder)
end

outFile = [outFolder,'\',outPref,'.mat'];

save(outFile,'simPONorm','PONorm','closeBins')

%% Plot simulated random overlap distributions and actual overlap

% calculate mean and CI for distributions
combMeans = cellfun(@mean,simPONorm);
combSD = cellfun(@std,simPONorm);

plotSD = combSD.*2;
plotSDpos = plotSD + combMeans;
plotSDneg = combMeans - plotSD;

figure
m = size(simPONorm,1);
iClus2 = 1;

for iClus = 1:m
    while iClus2 <= iClus
%         sbptNum = iClus + iClus2;
%         subplot(m,m,sbptNum)
        
        hist1 = histogram(simPO{iClus,iClus2},30);
        yMax = max(hist1.Values);
        histogram(simPO{iClus,iClus2},30)
        hold on
        plot([combMeans(iClus,iClus2) combMeans(iClus,iClus2)],[0 yMax],'b','LineWidth',2)
        plot([plotSDpos(iClus,iClus2) plotSDpos(iClus,iClus2)],[0 yMax],'r','LineWidth',2)
        plot([plotSDneg(iClus,iClus2) plotSDneg(iClus,iClus2)],[0 yMax],'r','LineWidth',2)
        plot([pfNorm(iClus,iClus2) pfNorm(iClus,iClus2)],[0 yMax],'LineWidth',2)
        hold off
        titTxt = ['Null Distribution vs Real Overlap for cl',num2str(iClus),' and cl',num2str(iClus2)];
        xlabel(['Percentage Overlap (%), ',num2str(lTimeBin),' minute bins'])
        title(titTxt)
        printFile = [outFolder,'\',outPrefix,'_',num2str(iClus),'_',num2str(iClus2)];
        print(fig1,'-dpng',printFile)
        
        iClus2 = iClus2 + 1;
    end
    iClus2 = 1;
end

