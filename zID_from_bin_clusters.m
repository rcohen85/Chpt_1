clearvars
binClustDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB'; % directory of cluster_bins output
baseDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp'; % directory of training folders
labelDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels3'; % directory of labels
flagStr = '_0'; % [] or any string following "_labFlag" in file names of labFlag files
TPWSDir = 'F:\HAT_B_01-03\TPWS'; % directory of TPWS files
CpB_saveName = 'HAT_B_01-03_CpB_0'; % name to save Counts per Bin matrix

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
countsPerBinAll = [];
binTimesAll = [];

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));

legend = struct('Name',[],'zID_Label',[]);
for i = 1:length(typeList)
legend(i).Name = typeList(i).name;
legend(i).zID_Label = i;
end
legend(i+1).Name = 'Unidentified';
legend(i+1).zID_Label = length(typeList)+1;
%%
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
    if exist(fullfile(labelDir,flagName))==2
        load(fullfile(labelDir,flagName))
    end
    probs = double(probs); 
    predLabels = predLabels'+1; % neural net labels start at 0, add 1 to prevent issues in detEdit
    
    countsPerBin = zeros(length(binData),length(typeList)+1);
    count = 1; % index to keep track of which label corresponds to which mean spectrum (some bins unlabeled bc single click bins not include in toClassify)
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
            end
            
            if minCounts>0
                probSet(nInSet<minCounts) = NaN; % if threshold has been set, discard labels below min counts threshold
%                 nSpecSet = nInSet(nInSet>=minCounts);
                if ~isempty(flagSet)
                    probSet(flagSet==0) = NaN; % discard confidences for labels flagged 0
                end
            else
%                 nSpecSet = nInSet;
                if ~isempty(flagSet)
                    probSet(flagSet==0) = NaN; % discard confidences for labels flagged 0
                end
            end
            
            % Determine labels for clicks in this bin:
            if max(probSet)<labelThresh % if no strong labels, assign all clicks to "unidentified" label
                nSpec = [];
                unIDtimes = setdiff(MTT(MTTIdx),vertcat(cTimes));
                for iS = 1:length(nInSet)
                    nSpec = [nSpec;repmat(nInSet(iS),nInSet(iS),1)];
                end
                zID = [zID;...
                    [vertcat(cTimes),... % times of clicks with weak label(s)
                    double(repmat(length(typeList)+1,size(MTTIdx,1),1)),...% "unidentified" label for these clicks
                    NaN(size(MTTIdx,1),1),... % NaN label confidence for these clicks
                    nSpec; % nSpec of weak label(s)
                    unIDtimes,... % times of isolated/unlabeled clicks
                    double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
                    NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
                    ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1); % save total # clicks in this bin
            elseif sum(probSet>=labelThresh)==1 % if only one strong label in this
                % set, assign appropriate clicks to that label, other clicks labeled "unidentified"
                [bestScore,bestLabelIdx] = max(probSet);
                iDnum = labelSet(bestLabelIdx); % single strong label
                nBestSpec = nInSet(bestLabelIdx); % number of specs under strong label
                remSpecIdx = 1:length(probSet)
                remSpecIdx(remSpecIdx==bestLabelIdx) = []; % indices of remaining (weak) labels
                remSpecTimes = vertcat(cTimes{1,remSpecIdx});
                nRemSpec = [];
                for iS = 1:length(nInSet)
                    if iS==bestLabelIdx
                        continue
                    end 
                    nRemSpec = [nRemSpec;repmat(nInSet(iS),nInSet(iS),1)]; % number of specs under each remaining (weak) label
                end
                unIDtimes = setdiff(MTT(MTTIdx),cTimes{1,bestLabelIdx});
                countsPerBin(iC,iDnum) = countsPerBin(iC,iDnum)+...
                    nBestSpec;
                zID = [zID;...
                    [cTimes{1,bestLabelIdx},... % times of clicks with strong label
                    double(repmat(iDnum,size(cTimes{1,bestLabelIdx},1),1)),... % strong label
                    repmat(probSet(bestLabelIdx),size(cTimes{1,bestLabelIdx},1),1),... % confidence of strong label
                    repmat(nBestSpec,size(cTimes{1,bestLabelIdx},1),1);... % nSpec of strong label
                    remSpecTimes,... % click times of remaining (weak) labels
                    double(repmat(length(typeList)+1,size(remSpecTimes,1),1)),... % "unidentified" label for these clicks
                    NaN(size(remSpecTimes,1),1),... % NaN label confidence for these clicks
                    nRemSpec;... % nSpec of weak labels
                    unIDtimes,... % times of isolated/unlabeled clicks
                    double(repmat(length(typeList)+1,size(unIDtimes,1),1)),... % "unidentified" label for these clicks
                    NaN(size(unIDtimes,1),1),... % NaN label confidence for these clicks
                    ones(size(unIDtimes,1),1)]]; % nSpec set to one since these clicks were never in a mean spectrum
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(unIDtimes,1);               
            elseif sum(probSet>=labelThresh)> 1 % if there are multiple options, assign 
                % appropriate clicks to each label, isolated clicks labeled "unidentified"
                posLabelsIdx = find(probSet>=labelThresh);
                highProbLabels = labelSet(posLabelsIdx);
                prunedProbs = probSet(posLabelsIdx);
                prunednSpec = nInSet(posLabelsIdx);
                for uI = 1:length(highProbLabels)
                    iDnum = highProbLabels(uI);
                    prProb = prunednProbs(uI);
                    nSpec = prunednSpec(uI);
                    zID = [zID;...
                        [cTimes{1,posLabelsIdx(uI)},...
                        double(repmat(iDnum,size(cTimes{1,posLabelsIdx(uI)},1),1)),...
                        repmat(nSpec,size(cTimes{1,posLabelsIdx(uI)},1),1)]];
                    countsPerBin(iC,iDnum) = countsPerBin(iC,iDnum)+...
                        nInSet(posLabelsIdx(uI));
                end
                unIDtimes = setdiff(MTT(MTTIdx),vertcat(cTimes{1,posLabelsIdx}));
                zID = [zID;...
                    [unIDtimes,...
                    double(repmat(length(typeList)+1,size(unIDtimes,1),1)),...
                    NaN(size(unIDtimes,1),1),...
                    ones(size(unIDtimes,1),1)]];
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1)-sum(nInSet);
            end
            count = count+n; % advance index to first label/prob for next bin
        end
    end
    
    zID = sortrows(zID);
    
    if ~isempty(falseIdx)
        falseLabels = sum(bsxfun(@eq,zID(:,2),falseIdx),2)>0;
        zFD = zID(falseLabels,1);
        zID = zID(~falseLabels,:);
        save(fullfile(saveDir,zFDName),'zFD')
    end
    
    save(fullfile(saveDir,zIDName),'zID','legend','labelThresh','minCounts')

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
