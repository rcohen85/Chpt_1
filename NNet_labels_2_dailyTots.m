% Use cluster_bins output and corresponding NNet labels to calculate daily
% click type presence at each site in hours.

clearvars
TPWSDir = 'I:\JAX10C\TPWS'; % directory containing TPWS files
clusDir = 'I:\JAX10C\NEW_ClusterBins_120dB'; % directory containing cluster_bins output
saveName = 'JAX10C_DailyTotals'; % filename to save 
NNetDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp'; % directory containing NNet training folders
saveDir = 'G:\DailyCT_Totals'; % directory to save output
labFlagStr = 'labFlag_0';
RLThresh = 120;
numClicksThresh = 0;
probThresh = 0;

%%
TPWSfList = dir(fullfile(TPWSDir,'*TPWS1.mat'));
clusfList = dir(fullfile(clusDir,'*.mat'));
labelDir = fullfile(clusDir,'ToClassify\labels');
labelfList = dir(fullfile(labelDir,'*predLab.mat'));

typeList = dir(NNetDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));
spNameList = {typeList(:).name}'; % species names corresponding to NNet labels 

% Compile labeled bins across the deployment; columns correspond to spNameList;
% each cell contains the start/end times of  all bins given that label 
% (meeting the user thresholds) across the deployment

labeledBins = cell(1,size(spNameList,1));
binFeatures = cell(3,size(spNameList,1));
for iF = 1:size(clusfList,1) % for each file
    load(fullfile(TPWSfList(iF).folder,TPWSfList(iF).name),'MTT','MPP')
    load(fullfile(clusfList(iF).folder,clusfList(iF).name),'binData')
    load(fullfile(clusfList(iF).folder,'/ToClassify',strrep(clusfList(iF).name,'.mat','_toClassify.mat')));
    load(fullfile(labelfList(iF).folder,labelfList(iF).name));
    if ~isempty(labFlagStr)
    load(fullfile(labelfList(iF).folder,strrep(labelfList(iF).name,'predLab',labFlagStr)));
    end
    
    % calculate mean PPRL for each bin spec in toClassify
    meanPPRL = [];
    binTimes = vertcat(binData.tInt);
    binTimes(:,2) = [];
    for iB = 1:size(sumTimeMat,1) % for each bin spec
        % find times of clicks contributing to this spec
        binInd = find(binTimes==sumTimeMat(iB,1));
        clickTimes = binData(binInd).clickTimes{1,whichCell(iB)}; 
        
        [~,timesInTPWS] = ismember(clickTimes,MTT); % find indices of clicks in TPWS vars
        clickRLs = MPP(timesInTPWS); % get RLs of clicks
        clickRLs_lin = 10.^(clickRLs./20); % return to linear space
        meanRL = 20*log10(mean(clickRLs_lin)); % average and revert to log space
        meanPPRL = [meanPPRL;meanRL];
    end
    
    % get rid of labels which don't meet thresholds
    probs = double(probs);
    predLabels = double(predLabels)+1;
    probIdx = sub2ind(size(probs),1:size(probs,1),double(predLabels));
    myProbs = probs(probIdx)';
    predLabels(labFlag(:,2)==0) = NaN;
    predLabels(myProbs<probThresh) = NaN;
    predLabels(meanPPRL<RLThresh) = NaN;
    predLabels(nSpecMat<numClicksThresh)=NaN;
    
    for iS = 1:size(typeList,1) % collect bins and bin features by label
        labeledBins{1,iS} = [labeledBins{1,iS};sumTimeMat(predLabels==iS,:)];
        binFeatures{1,iS} = [binFeatures{1,iS};myProbs(predLabels==iS)];
        binFeatures{2,iS} = [binFeatures{2,iS};meanPPRL(predLabels==iS)];
        binFeatures{3,iS} = [binFeatures{3,iS};nSpecMat(predLabels==iS)];
    end
    
end

% Sum daily hourly presence of each CT; resolution is cluster_bins dur; column 1
% is the date, remaining columns correspond to spNameList
depSt = floor(min(min(vertcat(labeledBins{1,:}))));
depEnd = floor(max(max(vertcat(labeledBins{1,:}))));
dvec = depSt:1:depEnd;
dailyTots = zeros(length(dvec),size(spNameList,1),1);
dailyTots(:,1) = datenum(dvec);
for iCT = 1:size(spNameList,1) % for each CT
    binDays = sort(floor(labeledBins{1,iCT}(:,1))); % find day each labeled bin falls on
    [N,~,bin] = histcounts(binDays,[dvec,dvec(end)+1]); % sort bins into days of the deployment
    dailyTots(:,iCT+1) = N*0.0833;
end

save(fullfile(saveDir,[saveName '_Prob' num2str(probThresh) '_RL' num2str(RLThresh) '_numClicks' num2str(numClicksThresh)]),...
    'spNameList','RLThresh','numClicksThresh','probThresh','labeledBins','binFeatures','dailyTots');
