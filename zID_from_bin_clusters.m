%

clearvars
baseDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp'; % directory of training folders
modDir = 'I:\cluster_NNet\TrainTest\20200803-091722\NNet.h5'; % path of trained model

binClustDir = 'I:\WAT_BS_02\NEW_ClusterBins_120dB'; % directory of cluster_bins output
labelDir = 'I:\WAT_BS_02\NEW_ClusterBins_120dB\ToClassify\labels'; % directory of labels
flagStr = '_0'; % [] or any string following "_labFlag" in file names of labFlag files
TPWSDir = 'J:\Shared drives\MBARC_All\TPWS\WAT\WAT_composite_clusters\WAT_BS_02\WAT_BS_02_TPWS'; % directory of TPWS files
CpB_saveName = 'WAT_BS_02_CpB_0'; % name to save Counts per Bin matrix

minCounts = 0; % minimum counts required to consider labels, should be higher for dolphin than bw
labelThresh = 0; % predction confidence threshold to be met in order for labels to be retained
falseIdx = []; % anything matching these labels will be labeled as false and
% saved as zFD in FD1 files

binClustFList = dir(fullfile(binClustDir,'*.mat'));
TPWSFlist = dir(fullfile(TPWSDir,'\*TPWS1.mat'));
saveDir = fullfile(TPWSDir,'zID_0');
if ~isdir(saveDir)
    mkdir(saveDir)
end

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));

legend = struct('Name',[],'zID_Label',[]);
for i = 1:length(typeList)
    legend(i).Name = typeList(i).name;
    legend(i).zID_Label = i;
end
% legend(i+1).Name = 'Unidentified';
% legend(i+1).zID_Label = length(typeList)+1;

%%
countsPerBinAll = [];
binTimesAll = [];
totBinSpecs = 0;
labeledBinSpecs = 0;
totClicks = 0;
labeledClicks = 0;

for iFile = 1:length(binClustFList)
    zID = [];
    % load cluster bins
    load(fullfile(binClustDir,binClustFList(iFile).name))
    cInt = vertcat(binData.cInt);
    goodBins = find(cInt>1); % need to leave out bins w a single click due to miscalculation of envMean in old version of cluster_bins
    
    % load MTT
    TPWSName = TPWSFlist(iFile).name;
    load(fullfile(TPWSDir,TPWSName),'MTT', 'MPP')
    % prune low amp clicks
    MTT = MTT(MPP>=120);
    
    % load labels (and flags, if they exist)
    labelName = strrep(TPWSName,'TPWS1','clusters_PR95_PPmin120_predLab');
    flagName = strrep(labelName,'predLab',['labFlag' flagStr]);
    zIDName = strrep(TPWSName,'TPWS1','ID1');
    zFDName = strrep(TPWSName,'TPWS1','FD1');
    
    load(fullfile(labelDir,labelName))
    if exist(fullfile(labelDir,flagName),'file')==2
        load(fullfile(labelDir,flagName))
    end
    probs = double(probs);
    predLabels = predLabels'+1; % neural net labels start at 0, add 1 to prevent issues in detEdit
    
    countsPerBin = zeros(length(binData),length(typeList)+1);
    count = 1; % index to keep track of which label corresponds to which mean spectrum (some bins unlabeled bc single click bins not included in toClassify)
    for iC = 1:length(binData)
        if ismember(iC,goodBins)
            % find the times of this bin's clicks in the MTT vector
            MTTIdx = find(MTT>=binData(iC).tInt(1,1)& MTT<binData(iC).tInt(1,2));
            
            % Figure out best label(s) for this bin
            n = size(binData(iC).sumSpec,1); % how many mean spectra in this bin?
            labelSet = [];
            probSet = [];
            flagSet = [];
            if n == 1  % find labels and probs corresponding to mean spectra in this bin
                labelSet = predLabels(count);
                probSet = probs(count,labelSet);
                if exist('labFlag')
                    flagSet = labFlag(count,2);
                end
            else
                labelSet = predLabels(count:(count+n-1));
                specVec = count:count+n-1;
                for iPs = 1:n
                    probSet(iPs) = probs(specVec(iPs),labelSet(iPs));
                end
                if exist('labFlag')
                    flagSet = labFlag(count:(count+n-1),2);
                end
            end
            
            nInSet = [];
            cTimes = {};
            for iProb = 1:length(labelSet) % for each label in the set..
                nInSet(iProb) = sum(binData(iC).nSpec(iProb)); % find number of click spectra assigned that label
                cTimes{iProb} = binData(iC).clickTimes{1,iProb}; % find times of clicks assigned that label
            
%                 if size(binData(iC).sumSpec,1)==1 && nInSet(iProb) > length(cTimes{iProb}) % should only 
%                     % come up when # clicks in the bin exceeds maxNetworkSz in cluster_bins
%                 nInSet(iProb) = double(length(cTimes{iProb}));
%                 end
            
            end
            
            if minCounts>0
                probSet(nInSet<minCounts) = NaN; % if threshold has been set, discard labels below min counts threshold
                if ~isempty(flagSet)
                    probSet(flagSet==0) = NaN; % also discard confidences for labels flagged 0
                end
            else % if no minCounts threshold set, just discard confidences for labels flagged 0
                if ~isempty(flagSet)
                    probSet(flagSet==0) = NaN; 
                end
            end
            
            % Determine labels for clicks in this bin:
            if max(probSet)<labelThresh || (sum(isnan(probSet)) == length(probSet)) % IF NO STRONG LABELS, leave all clicks unlabeled
%                 nSpec = [];
%                 unIDtimes = setdiff(MTT(MTTIdx),vertcat(cTimes{1,:}));
%                 for iS = 1:length(nInSet)
%                     nSpec = [nSpec;repmat(nInSet(iS),nInSet(iS),1)];
%                 end
%                 zID = [zID;...
%                     [vertcat(cTimes{1,:}),... % times of clicks with weak label(s)
%                     double(repmat(length(typeList)+1,size(cTimes{1,:},1),1)),...% "unidentified" label for these clicks
%                     NaN(size(cTimes{1,:},1),1),... % NaN label confidence for these clicks
%                     nSpec]]; % nSpec of weak label(s)
% %                     unIDtimes,... % times of isolated/unlabeled clicks
% %                     double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
% %                     NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
% %                     ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1); % save total # clicks in this bin
            elseif sum(probSet>=labelThresh)==1 % IF ONLY ONE STRONG LABEL IN THIS SET, assign
                % appropriate clicks to that label, other clicks left unlabeled 
                if length(probSet)>1
                    [bestScore,bestLabelIdx] = max(probSet);
                    iDnum = labelSet(bestLabelIdx); % single strong label
                    nBestSpec = nInSet(bestLabelIdx); % number of specs under strong label
%                     remSpecIdx = setdiff(1:length(probSet),bestLabelIdx); % indices of remaining (weak) label(s)
%                     remSpecTimes = vertcat(cTimes{1,remSpecIdx});
%                     nRemSpec = [];
%                     for iS = 1:length(nInSet)
%                         if iS==bestLabelIdx
%                             continue
%                         end
%                         nRemSpec = [nRemSpec;repmat(nInSet(iS),nInSet(iS),1)]; % number of specs under each remaining (weak) label                      
%                         countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+nInSet(iS);
%                     end                     
                    unIDtimes = setdiff(MTT(MTTIdx),cTimes{1,bestLabelIdx});
                    zID = [zID;...
                        [cTimes{1,bestLabelIdx},... % times of clicks with strong label
                        double(repmat(iDnum,size(cTimes{1,bestLabelIdx},1),1)),... % strong label
                        repmat(probSet(bestLabelIdx),size(cTimes{1,bestLabelIdx},1),1),... % confidence of strong label
                        repmat(nBestSpec,size(cTimes{1,bestLabelIdx},1),1)]]; % nSpec of strong label
%                         remSpecTimes,... % click times of remaining (weak) labels
%                         double(repmat(length(typeList)+1,size(remSpecTimes,1),1)),... % "unidentified" label for these clicks
%                         NaN(size(remSpecTimes,1),1),... % NaN label confidence for these clicks
%                         nRemSpec]]; % nSpec of weak labels
%                         unIDtimes,... % times of isolated/unlabeled clicks
%                         double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
%                         NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
%                         ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                    countsPerBin(iC,iDnum) = countsPerBin(iC,iDnum)+nBestSpec;
                    countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(unIDtimes,1);
                else
                    unIDtimes = setdiff(MTT(MTTIdx),cTimes{1,1});
                    zID = [zID;...
                        [cTimes{1,1},... % times of clicks with strong label
                        double(repmat(labelSet(1),size(cTimes{1,1},1),1)),... % strong label
                        repmat(probSet(1),size(cTimes{1,1},1),1),... % confidence of strong label
                        repmat(nInSet,size(cTimes{1,1},1),1)]]; % nSpec of strong label
%                         unIDtimes,... % times of isolated/unlabeled clicks
%                         double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
%                         NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
%                         ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                    countsPerBin(iC,labelSet(1)) = countsPerBin(iC,labelSet(1))+nInSet;
                    countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(unIDtimes,1);
                end
            elseif sum(probSet>=labelThresh)> 1 % IF THERE ARE MULTIPLE STRONG OPTIONS, assign
                % appropriate clicks to each label, other clicks left unlabeled
                posLabelsIdx = find(probSet>=labelThresh);
%                 negLabelsIdx = setdiff(1:length(probSet),posLabelsIdx);
                for uI = 1:length(probSet)
                    if ismember(uI,posLabelsIdx)
                        iDnum = labelSet(uI);
                        prProb = probSet(uI);
                        nSpec = nInSet(uI);
                        zID = [zID;...
                            [cTimes{1,uI},... % times of clicks with strong labels
                            double(repmat(iDnum,size(cTimes{1,uI},1),1)),... % strong labels
                            repmat(probSet(uI),size(cTimes{1,uI},1),1),... % confidence of strong labels
                            repmat(nSpec,size(cTimes{1,uI},1),1)]]; %nSpec of strong labels
                        countsPerBin(iC,iDnum) = countsPerBin(iC,iDnum)+nSpec;
%                     elseif ismember(uI,negLabelsIdx)
%                         nSpec = nInSet(uI);
%                         zID = [zID;...
%                             [cTimes{1,uI},... % times of clicks with remaining (weak) labels
%                             double(repmat(length(typeList)+1,size(cTimes{1,uI},1),1)),... % "unidentified" label for these clicks
%                             NaN(size(cTimes{1,uI},1),1),... % NaN label confidence for these clicks
%                             repmat(nSpec,size(cTimes{1,uI},1),1)]]; % nSpec of weak labels
%                         countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+...
%                             nInSet(uI);
                    end
                end
                unIDtimes = setdiff(MTT(MTTIdx),vertcat(cTimes{1,posLabelsIdx}));
%                 zID = [zID;...
%                     [unIDtimes,... % times of isolated/unlabeled clicks
%                     double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
%                     NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
%                     ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(unIDtimes,1);
            end
            count = count+n; % advance index to first label/prob for next good bin
        end
    end
    
    remUnIDtimes = setdiff(MTT,zID(:,1));
%     zID = [zID;...
%         [remUnIDtimes,... % times of isolated/unlabeled clicks
%         double(repmat(length(typeList)+1,size(remUnIDtimes,1),1)),... % "unidentified" label for these clicks
%         NaN(size(remUnIDtimes,1),1),... % NaN label confidence for these clicks
%         ones(size(remUnIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
    countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(remUnIDtimes,1);
    
    zID = sortrows(zID);
    
    if ~isempty(falseIdx)
        falseLabels = sum(bsxfun(@eq,zID(:,2),falseIdx),2)>0;
        zFD = zID(falseLabels,1);
        zID = zID(~falseLabels,:);
        save(fullfile(saveDir,zFDName),'zFD')
    end
    
    save(fullfile(saveDir,zIDName),'zID','legend','labelThresh','minCounts','modDir')
    
    % running tallies to calculate proportions of bins/clicks that end up
    % with labels
    countsPerBinAll = [countsPerBinAll;countsPerBin];
    tTemp = vertcat(binData.tInt);
    binTimesAll = [binTimesAll;tTemp(:,1)];
    
    totBinSpecs = totBinSpecs + size(horzcat(binData.nSpec),2);
    if exist('labFlag')
        labeledBinSpecs = labeledBinSpecs + sum(labFlag(:,2));
    else
        aboveThreshLabels = length(find(max(probs,[],2)>=labelThresh));
        labeledBinSpecs = labeledBinSpecs + aboveThreshLabels;
    end
    totClicks = totClicks + length(MTT);
    labeledClicks = labeledClicks + length(zID(zID(:,2)~=length(typeList)+1));
    
    fprintf('Done with file %d of %d\n',iFile,length(binClustFList))
end
%%
propBinSpecsLabeled = labeledBinSpecs/totBinSpecs;
propClicksLabeled = labeledClicks/totClicks;

save(fullfile(labelDir,CpB_saveName),'countsPerBinAll',...
    'binTimesAll','propBinSpecsLabeled','propClicksLabeled','labelThresh');
