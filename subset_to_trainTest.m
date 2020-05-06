
% inDir - directory containing TPWS, IDI, binned_label and BoutTimes files
% varargin - can provide (in order) directory to save training/testing
% files; filename to save training files; filename to save testing files

function [trainMSPICI, trainLabelSet, testMSPICI, testLabelSet] = subset_to_trainTest(inDir,varargin)
%% Divide bouts between training and testing data
load(fullfile(inDir,'BoutTimes_3min'));

testBoutSet = [];
testFiles = {};

trainBoutSet = [];
trainFiles = {};

for iA = 1:length(boutTimes)-1
    
    nBouts = boutTimes(iA).NumBouts;
    
    if nBouts > 1 || nBouts == 0
        testBoutIdx = sort(randsample(nBouts,ceil(.3*nBouts),false)); % select ~1/3 of bouts for testing
        trainBoutIdx = setdiff(1:nBouts,testBoutIdx)';    % remaining ~2/3 bouts for training
        
        tr = [trainBoutIdx, repmat(iA,length(trainBoutIdx),1)]; % training bout index within boutTimes and label tracking click type
        if ~isempty(trainBoutIdx)
        trF = cellstr(boutTimes(iA).WhichFile(trainBoutIdx,:));  % binned_label files in which training bouts are found
        else
            trF = {};
        end
        trainBoutSet = [trainBoutSet;tr];
        trainFiles = [trainFiles;trF];
        
        te = [testBoutIdx, repmat(iA,length(testBoutIdx),1)]; % testing bout index within boutTimes and label tracking click type
        if ~isempty(testBoutIdx)
        teF = cellstr(boutTimes(iA).WhichFile(testBoutIdx,:));   % binned_label files in which testing bouts are found
        else
            teF = {};
        end
        testBoutSet = [testBoutSet;te];
        testFiles = [testFiles;teF];
        
        if isempty(trF) || isempty(teF)
            fprintf('Warning: No training/testing data for %s',string(boutTimes(iA).ClickType));
        end
        
    else
        fprintf('Warning: Only one bout for %s, not sufficient to both train and test\n',...
            string(boutTimes(iA).ClickType))
        
        tr = [1, iA];
        trF = cellstr(boutTimes(iA).WhichFile(1,:));
        trainBoutSet = [trainBoutSet;tr]; % training bout indices within boutTimes and labels tracking click type
        trainFiles = [trainFiles;trF];
        
        te = [1,iA];
        teF = cellstr(boutTimes(iA).WhichFile(1,:));    % testing bout indices within boutTimes and label tracking click type
        testBoutSet = [testBoutSet;te];
        testFiles = [testFiles;teF];
    end
end

%% Load binned_labels files and pull appropriate spectra and ICI into
% train/test sets
fileList = dir(fullfile(inDir,'*binned_labels_3min.mat'));

% initialize structs to hold train/test specs & ICI for each click type
trainSet = struct('ClickType',[],'Specs',[],'ICI',[]);
testSet = struct('ClickType',[],'Specs',[],'ICI',[]);

% Get spectra and ICI from each binned_labels file
for iB = 1:length(fileList)
    fileName = fileList(iB).name;
    load(fullfile(inDir,fileName)); % load one binned_labels file
        
    trFIdx = strcmp(trainFiles,fileName);   % indices of training bouts from this file, within trainBoutSet
    trBouts = trainBoutSet(trFIdx,:); % indices of training bouts from this file, within boutTimes & CT labels 
    teFIdx = strcmp(testFiles,fileName);    % indices of testing bouts from this file, within testBoutSet
    teBouts = testBoutSet(teFIdx,:);  % indices of testing bouts from this file, within boutTimes & CT labels 
    
    for iC = 1:length(boutTimes)-1 
        
        if iB == 1
            trainSet(iC).ClickType = boutTimes(iC).ClickType;
            testSet(iC).ClickType = boutTimes(iC).ClickType;
        end
        
        if ~isempty(boutTimes(iC).BoutStarts)
            thisCT_trBouts = trBouts(trBouts(:,2)==iC,1);
            thisCT_teBouts = teBouts(teBouts(:,2)==iC,1);
            
            % find start and end times of bouts
            trainBoutTimes = [boutTimes(iC).BoutStarts(thisCT_trBouts),boutTimes(iC).BoutEnds(thisCT_trBouts)]; 
            testBoutTimes = [boutTimes(iC).BoutStarts(thisCT_teBouts),boutTimes(iC).BoutEnds(thisCT_teBouts)];
            
            % find which bins fall into each bout
            trainBinsInBout = any(binned_labels(iC).BinTimes >= trainBoutTimes(:,1)'...
                & binned_labels(iC).BinTimes < trainBoutTimes(:,2)',2);
            testBinsInBout = any(binned_labels(iC).BinTimes >= testBoutTimes(:,1)'...
                & binned_labels(iC).BinTimes < testBoutTimes(:,2)',2);
            
            % pull spectra & ICI of bins found in bouts in this file
            trainBoutSpecs = binned_labels(iC).BinSpecs(trainBinsInBout,:);
            trainBoutICI = binned_labels(iC).ICI_dists(trainBinsInBout,:);
            
            testBoutSpecs = binned_labels(iC).BinSpecs(testBinsInBout,:);
            testBoutICI = binned_labels(iC).ICI_dists(testBinsInBout,:);
            
            % store spectra & ICI by click type
            trainSet(iC).Specs = [trainSet(iC).Specs;trainBoutSpecs];
            trainSet(iC).ICI = [trainSet(iC).ICI;trainBoutICI];
            
            testSet(iC).Specs = [testSet(iC).Specs;testBoutSpecs];
            testSet(iC).ICI = [testSet(iC).ICI;testBoutICI];
        end
    end
    
end

% Beef up small train/test sets by sampling with replacement, then store 
% concatenated spectra and ICI for all click types in one array; create 
% corresponding label vector

% trICIMax = max(max(cell2mat(vertcat(trainSet.ICI))));
% teICIMax = max(max(cell2mat(vertcat(testSet.ICI))));

trainLabelSet = [];
trainMSPSet = [];
trainDTTSet = [];

testLabelSet = [];
testMSPSet = [];
testDTTSet = [];

for iD = 1:length(trainSet)

%     trainSet(iD).ICI = num2cell(cell2mat(trainSet(iD).ICI)/trICIMax,2); % normalize ICI
%     testSet(iD).ICI = num2cell(cell2mat(testSet(iD).ICI)/teICIMax,2);
    
    trainIdx = 1:size(trainSet(iD).Specs,1);
    testIdx = 1:size(testSet(iD).Specs,1);
    if isempty(trainSet(iD).Specs)
        fprintf('Warning: No training data for %s\n',string(trainSet(iD).ClickType));
        expandedTrainIdx = [];
    elseif size(trainIdx,2) >= 50000
        expandedTrainIdx = randsample(trainIdx,50000);
    else
        expandedTrainIdx = randsample(trainIdx,50000,true); % resample w replacement in case of small set
    end
    if isempty(testSet(iD).Specs)
        fprintf('Warning: No testing data for %s\n',string(testSet(iD).ClickType));
        expandedTestIdx = [];
    elseif size(testIdx,2) >= 5000
        expandedTestIdx = randsample(testIdx,5000);
    else
        expandedTestIdx = randsample(testIdx,5000,true); % resample w replacement in case of small set
    end
    
    trainLabelSet = [trainLabelSet;iD*ones(size(expandedTrainIdx'))];
    trainMSPSet = [trainMSPSet;cell2mat(trainSet(iD).Specs(expandedTrainIdx,:))];
    trainDTTSet = [trainDTTSet;cell2mat(trainSet(iD).ICI(expandedTrainIdx,:))];
    
    testLabelSet = [testLabelSet;iD*ones(size(expandedTestIdx'))];
    testMSPSet = [testMSPSet;cell2mat(testSet(iD).Specs(expandedTestIdx,:))];
    testDTTSet = [testDTTSet;cell2mat(testSet(iD).ICI(expandedTestIdx,:))];
  
end

% Concatenate spectra and ICI data
testMSPICI = [testMSPSet,zeros(size(testMSPSet,1),1), testDTTSet];
trainMSPICI = [trainMSPSet,zeros(size(trainMSPSet,1),1), trainDTTSet];

% If provided with file names, save train and test sets and respective labels
if length(varargin) == 3
    outDir = varargin{1};
    train_saveFileName = fullfile(outDir,varargin{2});
    test_saveFileName = fullfile(outDir,varargin{3});
save(train_saveFileName,'trainMSPICI','trainLabelSet','-v7.3');
save(test_saveFileName,'testMSPICI','testLabelSet','-v7.3');

end
end