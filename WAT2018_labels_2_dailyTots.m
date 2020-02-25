% Use cluster_bins output and corresponding NNet labels to calculate daily
% click type presence at each site in hours.
% Assumes 19 NNet labels (0:18) corresponding to this order of CTs:
% {'CT10','CT2','CT3','CT4_6','CT5','CT7','CT8','CT9','Blainvilles','Boats'...
%,'Cuviers','Echosounder','Gervais','Kogia','Noise','Rissos','Sowerbys',...
% 'Spermwhale','Trues'}


clearvars
inDir = 'G:\New_Atl_CTs\Labeled_Clicks\NFC_HAT_WATLabels\HAT_A_06\ClusterToClassify';
baseDir = 'I:\forNNet\WAT_2018_trainingExamples';
saveName = 'HAT_A_06_DailyTotals'; % filename to save 
saveDir = 'G:\New_Atl_CTs\DailyCT_Totals\OtherDeps';
labelDir = fullfile(inDir,'labels');
fList = dir(fullfile(inDir,'*.mat'));

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));
spNameList = [{typeList(:).name}';'UO']; % species names corresponding to NNet labels 

% Compile labeled bins across the deployment; rows correspond to spNameList; 
% columns to cluster_bins files; each cell contains the start/end times of 
% all bins given that label in that file which meet the min prob and min 
% nspec thresholds
labeledBins = {}; 
for iF = 1:size(fList,1)
    load(fullfile(fList(iF).folder,fList(iF).name))
    load(fullfile(labelDir,strrep(fList(iF).name,'toClassify.mat','predLab.mat')))
    probs = double(probs);
    predLabels = double(predLabels)+1;
    probIdx = sub2ind(size(probs),[1:size(probs,1)],double(predLabels));
    myProbs = probs(probIdx);
    predLabels(myProbs<.99) = NaN;
    predLabels(nSpecMat<50)=NaN;
    for iS = 1:19
        labeledBins{iS,iF} = sumTimeMat(predLabels==iS,:);
    end
    labeledBins{20,iF} =  sumTimeMat(isnan(predLabels),:);
    
end

% Sum daily hourly presence of each species/CT; 5-min resolution; column 1
% is the date, columns 2:21 correspond to spNameList
depSt = floor(min(min(vertcat(labeledBins{:,:}))));
depEnd = floor(max(max(vertcat(labeledBins{:,:}))));
dvec = depSt:1:depEnd;
dailyTots = zeros(length(dvec),21,1);
dailyTots(:,1) = datenum(dvec);
for iCT = 1:20 % for each CT
%     if sum(iCT == [10,12,15])>0
%         % if it's anthro or noise, skip it
%         continue
%     end
    binDays = sort(floor(vertcat(labeledBins{iCT,:}))); % find day each labeled bin falls on
    for dayIdx = 1:length(dailyTots(:,1)) %for each day of the deployment
        same_days =[];
        same_days = find(binDays(:,1) == dailyTots(dayIdx,1)); % find all bins falling in that day
        if ~isempty(same_days)
            dailyTots(dayIdx,iCT+1)= length(same_days)*0.0833; % sum 
        end
    end
end

save(fullfile(saveDir,saveName),'dailyTots');