% Use cluster_bins output and corresponding NNet labels to calculate daily
% click type presence at each site in hours.
% Assumes 19 NNet labels (0:18) corresponding to this order of CTs:
% {'CT10','CT2','CT3','CT4_6','CT5','CT7','CT8','CT9','Blainvilles','Boats'...
%,'Cuviers','Echosounder','Gervais','Kogia','Noise','Rissos','Sowerbys',...
% 'Spermwhale','Trues'}


clearvars
inDir = 'J:\WAT_BC_01\NEW_ClusterBins_120dB\ToClassify'; % directory containing ToClassify files
baseDir = 'G:\cluster_NNet\Set_w_Combos_HighAmp';
saveName = 'WAT_BC_01_DailyTotals'; % filename to save 
saveDir = 'G:\DailyCT_Totals';
RLThresh = 120;
numClicksThresh = 0;
probThresh = 0;

labelDir = fullfile(inDir,'labels');
fList = dir(fullfile(inDir,'*.mat'));

typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));
spNameList = [{typeList(:).name}';'UO']; % species names corresponding to NNet labels 

% Compile labeled bins across the deployment; rows correspond to spNameList; 
% columns to cluster_bins files; each cell contains the start/end times of 
% all bins given that label in that file which meet the min PPRL and min 
% nspec thresholds
labeledBins = {}; 
for iF = 1:size(fList,1)
    load(fullfile(fList(iF).folder,fList(iF).name))
    load(fullfile(labelDir,strrep(fList(iF).name,'toClassify.mat','predLab.mat')))
     load(fullfile(labCertDir,strrep(labCertFiles(i).name,'clusters_PR95_PPmin120_toClassify.mat','TPWS1')),'MTT','MPP');
    load(fullfile(labCertDir,strrep(labCertFiles(i).name,'clusters_PR95_PPmin120_toClassify.mat','ID1')));
    binTimes = (floor(MTT(1)):datenum([0,0,0,0,5,0]):ceil(MTT(end)))';
    
    % calculate 
    
    probs = double(probs);
    predLabels = double(predLabels)+1;
    probIdx = sub2ind(size(probs),1:size(probs,1),double(predLabels));
    myProbs = probs(probIdx);
    predLabels(myProbs<probThresh) = NaN;
    predLabels(meanPPRL<RLThresh) = NaN;
    predLabels(nSpecMat<numClicksThresh)=NaN;
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