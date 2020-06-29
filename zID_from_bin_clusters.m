clearvars
binClustDir = 'F:\WAT_WC_01_d4-8\ClusterBins_120dB'; % directory of cluster_bins output
binClustFList = dir(fullfile(binClustDir,'WAT_WC_01*.mat'));
baseDir = 'G:\forNNet\WAT_2018_trainingExamples'; % directory of training folders

labelDir = 'F:\WAT_WC_01_d4-8\ClusterToClassify\labels'; % directory of laels
TPWSDir = 'F:\WAT_WC_01_d4-8\TPWS'; % directory of TPWS files
TPWSFlist = dir(fullfile(TPWSDir,'\WAT_WC_01*TPWS1.mat'));
saveDir = 'F:\WAT_WC_01_d4-8\TPWS\zID';
minCounts = 25; % minimum counts required to consider labels, should be higher for dolphin than bw
countsPerBinAll = [];
binTimesAll = [];

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));

%%% Modify to determine which types are labeled as false, vs. given an ID
%%% number
falseIdx = [9,11,14]; % anything matching these NNet labels will be labeled as false.
% ** NNet labels start from 0, not 1 **
% idReducer = [1:8,NaN,10,NaN,12:13,NaN,15:19]; % This list should be the same
% length as typeList, where NaNs are in the false rows, and numbers are in
% the other rows, to assign colors. This is the hardest part to understand,
% ask me for clarification.
%%%

%%
for iFile = 1:length(binClustFList)
    zID = [];
    % load cluster bins
    load(fullfile(binClustDir,binClustFList(iFile).name))
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
    probs = double(probs);
    countsPerBin = zeros(length(binData),20);
    count = 1; % index to keep track of which label corresponds to which mean bin spectra
    for iC = 1:length(binData)
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
        if max(probSet)<.85 % if no strong labels, assign all clicks to "unidentified" label
            zID = [zID;[MTT(MTTIdx),double(repmat(19,size(MTTIdx,1),1))]];
            countsPerBin(iC,20) = countsPerBin(iC,20)+size(MTTIdx,1); % save total # clicks in this bin
        elseif sum(probSet>=.85)==1 % if only one strong label in this set, assign appropriate clicks to that label
            [bestScore,bestLabelIdx] = max(probSet);
            iDnum = labelSet(bestLabelIdx);
            unIDtimes = setdiff(MTT(MTTIdx),cTimes{1,bestLabelIdx});
            countsPerBin(iC,iDnum+1) = countsPerBin(iC,iDnum+1)+...
                nInSet(bestLabelIdx);
            countsPerBin(iC,20) = countsPerBin(iC,20)+size(MTTIdx,1)-sum(nInSet);
            zID = [zID;[cTimes{1,bestLabelIdx},double(repmat(iDnum,size(cTimes{1,bestLabelIdx},1),1));...
                unIDtimes,double(repmat(19,size(unIDtimes,1),1))]];
        elseif sum(probSet>=.85)> 1 % if there are multiple options, assign appropriate clicks to each label
            posLabelsIdx = find(probSet>=.85);
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
            zID = [zID;[unIDtimes,double(repmat(19,size(unIDtimes,1),1))]];
            countsPerBin(iC,20) = countsPerBin(iC,20)+size(MTTIdx,1)-sum(nInSet);
        end
        count = count+n; % advance index to labels/probs for next bin
    end
    
    zID = sortrows(zID);
    
    falseLabels = sum(bsxfun(@eq,zID(:,2),falseIdx),2)>0;
    zFD = zID(falseLabels,1);
    zID = zID(~falseLabels,:);
%     zID(:,2) = idReducer(zID(:,2))';
    save(fullfile(saveDir,zIDName),'zID')
    save(fullfile(saveDir,zFDName),'zFD')
    countsPerBinAll = [countsPerBinAll;countsPerBin];
    tTemp = vertcat(binData.tInt);
    binTimesAll = [binTimesAll;tTemp(:,1)];
    
    fprintf('Done with file %d of %d\n',iFile,length(binClustFList))
end
%%
save(fullfile(labelDir,strrep(zIDName,'.mat','_CpB.mat')),'countsPerBinAll','binTimesAll');
