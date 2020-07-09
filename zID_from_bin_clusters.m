clearvars
binClustDir = 'I:\JAX10C\NEW_ClusterBins_120dB'; % directory of cluster_bins output
binClustFList = dir(fullfile(binClustDir,'*.mat'));
baseDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp'; % directory of training folders

labelDir = 'I:\JAX10C\NEW_ClusterBins_120dB\ToClassify\labels'; % directory of labels
TPWSDir = 'I:\JAX10C\TPWS'; % directory of TPWS files
TPWSFlist = dir(fullfile(TPWSDir,'\*TPWS1.mat'));
saveDir = fullfile(TPWSDir,'zID');
if ~isdir(saveDir)
    mkdir(saveDir)
end  
minCounts = 25; % minimum counts required to consider labels, should be higher for dolphin than bw
labelThresh = 0.97; % predction confidence threshold to be met in order for labels to be retained
countsPerBinAll = [];
binTimesAll = [];

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));

%%% Modify to determine which types are labeled as false, vs. given an ID
%%% number
% falseIdx = []; % anything matching these NNet labels will be labeled as false.
% ** NNet labels start from 0, not 1 **
% idReducer = [1:8,NaN,10,NaN,12:13,NaN,15:19]; % This list should be the same
% length as typeList, where NaNs are in the false rows, and numbers are in
% the other rows, to assign colors. This is the hardest part to understand,
% ask me for clarification.
%%%

%%
totBins = 0; 
labeledBins = 0; 
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
    
    % load labels
    labelName = strrep(TPWSName,'TPWS1','clusters_PR95_PPmin120_predLab');
    zIDName = strrep(TPWSName,'TPWS1','ID1');
    zFDName = strrep(TPWSName,'TPWS1','FD1');
    
    load(fullfile(labelDir,labelName))
    probs = double(probs); predLabels = predLabels';
    countsPerBin = zeros(length(binData),length(typeList)+1);
    count = 1; % index to keep track of which label corresponds to which mean bin spectra (some bins unlabeled bc single click bins not include in toClassify)
    for iC = 1:length(binData)
        if ismember(iC,goodBins)
            % find the times of this bin's clicks in the MTT vector
            MTTIdx = find(MTT>=binData(iC).tInt(1,1)& MTT<binData(iC).tInt(1,2));
            
            % Figure out best label(s) for this bin
            n = size(binData(iC).sumSpec,1); % how many mean spectra in this bin?
            labelSet = [];
            probSet = [];
            if n == 1  % find labels and probs corresponding to mean spectra in this bin
                labelSet = predLabels(count);
                probSet = probs(count,labelSet+1);
            else
                labelSet = predLabels(count:(count+n-1));
                specVec = count:count+n-1;
                for iPs = 1:n
                    probSet(iPs) = probs(specVec(iPs),labelSet(iPs)+1);
                end
                
            end
            
            nInSet = [];
            cTimes = {};
            
            for iProb = 1:length(labelSet) % for each label in the set..
                nInSet(iProb) = sum(binData(iC).nSpec(iProb)); % find number of click spectra assigned that label
                cTimes{iProb} = binData(iC).clickTimes{1,iProb}; % find times of clicks assigned that label
            end
            
            probSet(nInSet<minCounts) = 0; % only keep labels meeting min counts threshold
            
            % Determine labels for clicks in this bin:
            if max(probSet)<labelThresh % if no strong labels, assign all clicks to "unidentified" label
                zID = [zID;[MTT(MTTIdx),double(repmat(length(typeList),size(MTTIdx,1),1))]];
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1); % save total # clicks in this bin
            elseif sum(probSet>=labelThresh)==1 % if only one strong label in this set, assign appropriate clicks to that label, other clicks labeled "unidentified"
                [bestScore,bestLabelIdx] = max(probSet);
                iDnum = labelSet(bestLabelIdx);
                unIDtimes = setdiff(MTT(MTTIdx),cTimes{1,bestLabelIdx});
                countsPerBin(iC,iDnum+1) = countsPerBin(iC,iDnum+1)+...
                    nInSet(bestLabelIdx);
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1)-sum(nInSet);
                zID = [zID;[cTimes{1,bestLabelIdx},double(repmat(iDnum,size(cTimes{1,bestLabelIdx},1),1));...
                    unIDtimes,double(repmat(length(typeList),size(unIDtimes,1),1))]];
            elseif sum(probSet>=labelThresh)> 1 % if there are multiple options, assign appropriate clicks to each label, isolated clicks labeled "unidentified"
                posLabelsIdx = find(probSet>=labelThresh);
                highProbLabels = labelSet(posLabelsIdx);
                prunedProbs = probSet(posLabelsIdx);
                for uI = 1:length(highProbLabels)
                    iDnum = highProbLabels(uI);
                    zID = [zID;[cTimes{1,posLabelsIdx(uI)},double(repmat(iDnum,...
                        size(cTimes{1,posLabelsIdx(uI)},1),1))]];
                    countsPerBin(iC,iDnum+1) = countsPerBin(iC,iDnum+1)+...
                        nInSet(posLabelsIdx(uI));
                end
                unIDtimes = setdiff(MTT(MTTIdx),vertcat(cTimes{1,posLabelsIdx}));
                zID = [zID;[unIDtimes,double(repmat(length(typeList),size(unIDtimes,1),1))]];
                countsPerBin(iC,length(typeList)+1) = countsPerBin(iC,length(typeList)+1)+size(MTTIdx,1)-sum(nInSet);
            end
            count = count+n; % advance index to first label/prob for next bin
        end
    end
    
    zID = sortrows(zID);
    
%     falseLabels = sum(bsxfun(@eq,zID(:,2),falseIdx),2)>0;
%     zFD = zID(falseLabels,1);
%     zID = zID(~falseLabels,:);
    
%     save(fullfile(saveDir,zIDName),'zID')
%     save(fullfile(saveDir,zFDName),'zFD')
    
    countsPerBinAll = [countsPerBinAll;countsPerBin];
    tTemp = vertcat(binData.tInt);
    binTimesAll = [binTimesAll;tTemp(:,1)];
     
    totBins = totBins + size(horzcat(binData.nSpec),2);
    labeledBins = labeledBins + length(predLabels);
    totClicks = totClicks + length(MTT);
    labeledClicks = labeledClicks + length(zID(zID(:,2)~=length(typeList)));
    
    fprintf('Done with file %d of %d\n',iFile,length(binClustFList))
end
%%
propBinsLabeled = labeledBins/totBins;
propClicksLabeled = labeledClicks/totClicks;

save(fullfile(labelDir,strrep(zIDName,'.mat','_CpB.mat')),'countsPerBinAll',...
    'binTimesAll','propBinsLabeled','propClicksLabeled','labelThresh');
