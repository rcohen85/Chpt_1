%created on 5/29/2020 by MAZ

%%%%dude where's my click take 2- for evaluating cluster performance. Creates a matrix of 
%percentages of bins of each cluster that are within a user-defined time-based 
%distance of bins of any other cluster. i.e., percentage of bins of cluster
%9 that are within 50 minutes of bins of cluster 3. 

%%output: percFinal which has matrix of percentages, pfNorm which has normalized percentages
%%(via weighted average) for each cluster pair, and closeBins which
%%contains one cell per cluster. Each of these cells contains one cell per
%%cluster (i.e., cell 1 contains 9 cells for comparisons between cluster 1
%%and each other cluster 1-9. I.e., closeBins{1}{1,3} has columns that
%%represent each bin of cluster 1; closeBins{1}{1,3}{1,6} contains the bin
%%numbers of all bins in cluster 3 that were within the specified distance
%%of cluster 1 bin #6. If closeBins{1}{1,3}{1,6} contains values [7,8],
%%this means cluster 3 bins 7 and 8 were within x distance of cluster 1 bin
%%6. 

inFile = 'H:\reProcessed\Kauai\Kauai01\TPWS\clusterBins_pp120\composite_final\KA01_pp120_types_all';
outPref = 'KA01_relationMat_reClus';
outFolder = 'H:\reProcessed\Kauai\Kauai01\clusterEval';

dutyCyc = 15; %duration of off-period of duty cycle. Set to 0 if no duty cycle
nBin = 2; %number of bins for the distance gap 
binWidth = 5; %length of bin in minutes 
%% doing stuff

tooClose = [];
percClose = [];
percFinal = [];
closePerClus = [];
closeBins = [];
pfNorm = [];


load(inFile)

%calculate time difference for consideration
minsBetween = dutyCyc.*(nBin+1) + nBin*binWidth;
dnGap = datenum(0,0,0,0,minsBetween,0);
countCl = 0;

%compute matrix of cluster relatedness (in terms of how often they show up
%together, essentially) 

clusTimesforUse = {Tfinal{:,7}};
% load('ClusTimes_regroup.mat')
% clusTimesforUse = clusTimes2';

for iClus = 1:size(clusTimesforUse,2)
    clusTimes = clusTimesforUse{iClus};
    for iComp = 1:size(clusTimesforUse,2)
        compTimes = clusTimesforUse{iComp};
        for iCount = 1:size(clusTimes,1)
            gap = abs(compTimes - clusTimes(iCount));
            tooClose {iCount} = find(gap<=dnGap)';
            if ~isempty(tooClose{iCount})
                countCl = countCl + 1;
            end
        end
        
        %calculate percentage that were close 
        percClose(iComp,:) = (countCl./size(clusTimes,1)).*100; %percentage of bins of clus1...
        %that were within two bins of compClus
        countCl = 0;
        closePerClus{iComp} = tooClose;
    end
    percFinal(iClus,:) = percClose;
    closeBins{iClus} = closePerClus;
end


%calculate weighted average and make symmetric matrix of normalized
%percentages
for iNorm = 1:size(percFinal,1)
    cl1n = size([clusTimesforUse{iNorm}],1);
    iN2 = 1;
    while iN2 <= size(percFinal,1)
        cl2n = size([clusTimesforUse{iN2}],1);
        pfNorm(iNorm,iN2) = (percFinal(iNorm,iN2).*cl1n + percFinal(iN2,iNorm).*cl2n)./(cl1n+cl2n);
        iN2 = iN2+1;
    end
end


if ~exist(outFolder)
    mkdir(outFolder)
end

outFile = [outFolder,'\',outPref,'.mat'];

save(outFile,'percFinal','closeBins','pfNorm')
