%% Build neural network training/testing sets from bin_labeled_clicks and
% aggregate_encounter_times output

% inDir - directory containing TPWS, IDI, binned_label and BoutTimes files
% trainSize - # examples per class for training set
% testSize - # examples per class for testing set
% saveSuffix - string appended to end of binned_clicks & aggregate_encounter_times
% file names indicating binSize and/or minClicks and/or minPP; e.g. '5min';
% leave [] if no string
% plotDir - provide directory to save plots of train/test data for each
% click type; or leave [] to skip plotting
% varargin - can also provide (in order) directory to save training/testing
% files; filename to save training files; filename to save testing files.
% NOTE: if varargin not provided, train/test variables will be created in
% workspace but not saved

function [trainMSPICIWV, trainLabelSet, testMSPICIWV, testLabelSet] = subset_to_trainTest(inDir,trainSize,testSize,saveSuffix,plotDir,varargin)
% Divide bouts between training and testing data
if ~isempty(saveSuffix)
    load(fullfile(inDir,['BoutTimes_' saveSuffix]));
else
    load(fullfile(inDir,'BoutTimes'));
end

testBoutSet = [];
testFiles = {};

trainBoutSet = [];
trainFiles = {};

for iA = 1:length(boutTimes)-1
    
    nBouts = boutTimes(iA).NumBouts;
    
    if nBouts > 1 || nBouts == 0
        testBoutIdx = sort(randsample(nBouts,ceil(.2*nBouts),false)); % select ~20% of bouts for testing
        trainBoutIdx = setdiff(1:nBouts,testBoutIdx)';    % remaining ~80% of bouts for training
        
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
if ~isempty(saveSuffix)
    fileList = dir(fullfile(inDir,['*binned_labels_' saveSuffix '.mat']));
else
    fileList = dir(fullfile(inDir,'*binned_labels.mat'));
end

% initialize structs to hold train/test specs & ICI for each click type
trainSet = struct('ClickType',[],'Specs',[],'ICI',[],'WV',[]);
testSet = struct('ClickType',[],'Specs',[],'ICI',[],'WV',[]);

% Get spectra, ICI, and envelope shape from each binned_labels file
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
            
            % pull spectra, ICI, & envelope shape of bins found in bouts in this file
            trainBoutSpecs = binned_labels(iC).BinSpecs(trainBinsInBout,:);
            trainBoutICI = binned_labels(iC).ICI_dists(trainBinsInBout,:);
            trainBoutWV = binned_labels(iC).EnvShape(trainBinsInBout,:);
            
            testBoutSpecs = binned_labels(iC).BinSpecs(testBinsInBout,:);
            testBoutICI = binned_labels(iC).ICI_dists(testBinsInBout,:);
            testBoutWV = binned_labels(iC).EnvShape(testBinsInBout,:);
            
            % store spectra, ICI, & envelope shape by click type
            trainSet(iC).Specs = [trainSet(iC).Specs;trainBoutSpecs];
            trainSet(iC).ICI = [trainSet(iC).ICI;trainBoutICI];
            trainSet(iC).WV = [trainSet(iC).WV;trainBoutWV];
            
            testSet(iC).Specs = [testSet(iC).Specs;testBoutSpecs];
            testSet(iC).ICI = [testSet(iC).ICI;testBoutICI];
            testSet(iC).WV = [testSet(iC).WV;testBoutWV];
        end
    end
    
end

%% Plot Train/Test Bins
if ~isempty(plotDir)
    for i = 1:length(trainSet)
        figure
        subplot(1,3,1)
        imagesc([],p.f,cell2mat(vertcat(trainSet(i).Specs))');
        title([p.Labels{i} ' Train CatSpec']);
        xlabel('Bin');
        ylabel('Frequency (kHz)');
        set(gca,'ydir','normal')
        
        subplot(1,3,2)
        bar(sum(cell2mat(trainSet(i).ICI),'omitnan'));
        title([p.Labels{i} ' Train ICI Dist']);
        xlim([0 100]);
        xticklabels({'0','0.2','0.4','0.6','0.8','1'});
        xlabel('ICI (s)');
        ylabel('Counts');
        
        subplot(1,3,3)
        imagesc([],[],cell2mat(vertcat(trainSet(i).WV))');
        title([p.Labels{i} ' Train Mean Waveform Envelope']);
        xlabel('Bin');
        ylabel('Sample');
        set(gca,'ydir','normal');
        ylim([50 150]);
        
        saveas(gcf,fullfile(plotDir,[p.Labels{i} '_Train']),'tiff');
    end
    
    for i = 1:length(trainSet)
        figure
        subplot(1,3,1)
        imagesc([],p.f,cell2mat(vertcat(testSet(i).Specs))');
        title([p.Labels{i} ' Test CatSpec']);
        xlabel('Bin');
        ylabel('Frequency (kHz)');
        set(gca,'ydir','normal')
        
        subplot(1,3,2)
        bar(sum(cell2mat(testSet(i).ICI),'omitnan'));
        title([p.Labels{i} ' Test ICI Dist']);
        xlim([0 100]);
        xticklabels({'0','0.2','0.4','0.6','0.8','1'});
        xlabel('ICI (s)');
        ylabel('Counts');
        
        subplot(1,3,3)
        imagesc([],[],cell2mat(vertcat(testSet(i).WV))');
        title([p.Labels{i} ' Test Mean Waveform Envelope']);
        xlabel('Bin');
        ylabel('Sample');
        set(gca,'ydir','normal');
        ylim([50 150]);
        
        saveas(gcf,fullfile(plotDir,[p.Labels{i} '_Test']),'tiff');
    end
end
%% Beef up small train/test sets by sampling with replacement, then store
% concatenated spectra and ICI for all click types in one array; create
% corresponding label vector

trainLabelSet = [];
trainMSPSet = [];
trainDTTSet = [];
trainWVSet = [];

testLabelSet = [];
testMSPSet = [];
testDTTSet = [];
testWVSet = [];

for iD = 1:length(trainSet) % for each click type
    
    trainIdx = 1:size(trainSet(iD).Specs,1);
    testIdx = 1:size(testSet(iD).Specs,1);
    if isempty(trainSet(iD).Specs)
        fprintf('Warning: No training data for %s\n',string(trainSet(iD).ClickType));
        expandedTrainIdx = [];
    elseif size(trainIdx,2) >= trainSize % if too many examples, subsample
        expandedTrainIdx = randsample(trainIdx,trainSize);
    else
        expandedTrainIdx = randsample(trainIdx,trainSize,true); % if too few examples, resample w replacement
    end
    if isempty(testSet(iD).Specs)
        fprintf('Warning: No testing data for %s\n',string(testSet(iD).ClickType));
        expandedTestIdx = [];
    elseif size(testIdx,2) >= testSize % if too many examples, subsample
        expandedTestIdx = randsample(testIdx,testSize);
    else
        expandedTestIdx = randsample(testIdx,testSize,true); % if too few examples, resample w replacement
    end
    
    trainLabelSet = [trainLabelSet;iD*ones(size(expandedTrainIdx'))];
    trainMSPSet = [trainMSPSet;cell2mat(trainSet(iD).Specs(expandedTrainIdx,:))];
    trainDTTSet = [trainDTTSet;cell2mat(trainSet(iD).ICI(expandedTrainIdx,:))];
    trainWVSet = [trainWVSet;cell2mat(trainSet(iD).WV(expandedTrainIdx,:))];
    
    testLabelSet = [testLabelSet;iD*ones(size(expandedTestIdx'))];
    testMSPSet = [testMSPSet;cell2mat(testSet(iD).Specs(expandedTestIdx,:))];
    testDTTSet = [testDTTSet;cell2mat(testSet(iD).ICI(expandedTestIdx,:))];
    testWVSet = [testWVSet;cell2mat(testSet(iD).WV(expandedTestIdx,:))];
    
end

% Concatenate spectra, ICI, & mean waveform data
testMSPICIWV = [testMSPSet,zeros(size(testMSPSet,1),1),testDTTSet,...
    zeros(size(testMSPSet,1),1),testWVSet];
trainMSPICIWV = [trainMSPSet,zeros(size(trainMSPSet,1),1), trainDTTSet...
    ,zeros(size(trainMSPSet,1),1),trainWVSet];

% If provided with file names, save train and test sets and respective labels
if length(varargin) == 3
    outDir = varargin{1};
    train_saveFileName = fullfile(outDir,varargin{2});
    test_saveFileName = fullfile(outDir,varargin{3});
    save(train_saveFileName,'trainMSPICIWV','trainLabelSet','-v7.3');
    save(test_saveFileName,'testMSPICIWV','testLabelSet','-v7.3');
    
end
end


