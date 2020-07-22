
clearvars

%%%% Paths to modify
baseDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp';
outDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp';
test_saveFileName = 'TestSet_MSPICIWV_500_noReps.mat';
train_saveFileName = 'TrainSet_MSPICIWV_5000_noReps.mat';
%%%%

%%
typeList = dir(baseDir);
typeList = typeList(3:end);
typeList = typeList(vertcat(typeList.isdir));
typeList(strcmp({typeList.name},'forNNet')) = [];
if ~exist(outDir,'dir')
    mkdir(outDir)
end

mergedTypes = {};
typeNames =  {};
nClicks = [];
saveNames = {};
for iD = 1:size(typeList,1)
    thisTypeDir = fullfile(baseDir,typeList(iD).name);
    [~,typeID] = fileparts(thisTypeDir);
    typeNames{iD,1} = typeID;
    matList = dir(fullfile(thisTypeDir,'*.mat'));
    
    clusterSpectra = [];
    clusterICI = [];
    clusterEnv = [];
    
    for iM = 1:size(matList,1)
        inFile = load(fullfile(thisTypeDir,matList(iM).name));
        thisSpec = inFile.thisType.Tfinal{1};
        if size(thisSpec,2)>188
            thisSpec = thisSpec(:,2:end-2);
        end
        thisEnv = inFile.thisType.Tfinal{10};
        if size(thisEnv,2) == 300
            thisEnv = thisEnv(:,51:250);
        end
        clusterSpectra = [clusterSpectra;thisSpec];
        clusterICI = [clusterICI;inFile.thisType.Tfinal{2}];
        clusterEnv = [clusterEnv;thisEnv];
    end
    mergedTypes(iD).clusterSpectra = clusterSpectra;
    mergedTypes(iD).clusterICI = clusterICI;
    mergedTypes(iD).clusterEnv = clusterEnv;
end


myTypeList = {typeList(:).name}';

save(fullfile(outDir,'MergedTypes'),'mergedTypes','myTypeList');

%% select examples of each type for testSet and trainSet
testLabelSet = [];
testMSPSet = [];
testDTTSet = [];
testEnvSet = [];

trainLabelSet = [];
trainMSPSet = [];
trainDTTSet = [];
trainEnvSet = [];

nM = cellfun(@size,{mergedTypes(:).clusterSpectra},'UniformOutput',false);
nM = cell2mat(nM');
nMax = max(nM(:,1));
nMin = min(nM(:,1));
for iU = 1:length(myTypeList)
    nItems = size(mergedTypes(iU).clusterSpectra,1);
    testSelect = randsample(nItems,ceil(.15*nItems),false);
    if length(testSelect)>500
        expandedTestList = randsample(testSelect,500); 
    else
        expandedTestList = randsample(testSelect,500,true);% beef up tiny sample size.
    end
    trainSelect = setdiff(1:nItems,expandedTestList);
    if length(trainSelect)>5000
        expandedTrainList = randsample(trainSelect,5000); 
    else
        expandedTrainList = randsample(trainSelect,5000,true);% beef up tiny sample size.
    end
    testLabelSet = [testLabelSet;iU*ones(size(expandedTestList))];
    testMSPSet = [testMSPSet;mergedTypes(iU).clusterSpectra(expandedTestList,:)];
    testDTTSet = [testDTTSet;mergedTypes(iU).clusterICI(expandedTestList,:)];
    testEnvSet = [testEnvSet;mergedTypes(iU).clusterEnv(expandedTestList,:)];
    
    
    trainLabelSet = [trainLabelSet;iU*ones(size(expandedTrainList'))];
    trainMSPSet = [trainMSPSet;mergedTypes(iU).clusterSpectra(expandedTrainList,:)];
    trainDTTSet = [trainDTTSet;mergedTypes(iU).clusterICI(expandedTrainList,:)];
    trainEnvSet = [trainEnvSet;mergedTypes(iU).clusterEnv(expandedTrainList,:)];
end

testDTTSet(isnan(testDTTSet))= 0 ;
trainDTTSet(isnan(trainDTTSet))= 0 ;

testDTTSet = testDTTSet./repmat(max(max(testDTTSet,[],2),1),1,size(testDTTSet,2));
trainDTTSet = trainDTTSet./repmat(max(max(trainDTTSet,[],2),1),1,size(trainDTTSet,2));
testMSPICIWV = [testMSPSet,zeros(size(testMSPSet,1),1),testDTTSet,...
    zeros(size(testMSPSet,1),1),testEnvSet];
trainMSPICIWV = [trainMSPSet,zeros(size(trainMSPSet,1),1),trainDTTSet,...
    zeros(size(trainMSPSet,1),1),trainEnvSet];


save(fullfile(outDir,test_saveFileName),'testMSPICIWV','testLabelSet','myTypeList','-v7.3')
save(fullfile(outDir,train_saveFileName),'trainMSPICIWV','trainLabelSet','myTypeList','-v7.3')

