
% inDir - directory containing TPWS, IDI, binned_label and BoutTimes files
% varargin - can provide (in order) directory to save training/testing
% files; filename to save training files; filename to save testing files

function [trainMSPICI, trainLabelSet, testMSPICI, testLabelSet] = subset_to_trainTest(inDir,varargin)
% Divide bouts between training and testing data
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
% f = 5:0.5:98.5;
% 
% figure;imagesc([],f,cell2mat(vertcat(trainSet(1).Specs))');title('CT10 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(2).Specs))');title('CT2 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(3).Specs))');title('CT3 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(4).Specs))');title('CT4/6 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(5).Specs))');title('CT5 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(6).Specs))');title('CT7 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(7).Specs))');title('CT8 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(8).Specs))');title('CT9 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(9).Specs))');title('Blainville''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(10).Specs))');title('Boats CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(11).Specs))');title('Cuvier''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(12).Specs))');title('Echosounder CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(13).Specs))');title('Gervais'' CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(14).Specs))');title('Kogia CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(15).Specs))');title('Noise CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(16).Specs))');title('Risso''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(17).Specs))');title('Sowerby''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(18).Specs))');title('Sperm Whale CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(trainSet(19).Specs))');title('True''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% 
% figure;bar(sum(cell2mat(trainSet(19).ICI),'omitnan'));title('True''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(18).ICI),'omitnan'));title('Sperm Whale ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(17).ICI),'omitnan'));title('Sowerby''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(16).ICI),'omitnan'));title('Risso''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(15).ICI),'omitnan'));title('Noise ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(14).ICI),'omitnan'));title('Kogia ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(13).ICI),'omitnan'));title('Gervais'' ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(12).ICI),'omitnan'));title('Echosounder ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(11).ICI),'omitnan'));title('Cuvier''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(10).ICI),'omitnan'));title('Boats ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(9).ICI),'omitnan'));title('Blainville''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(8).ICI),'omitnan'));title('CT9 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(7).ICI),'omitnan'));title('CT8 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(6).ICI),'omitnan'));title('CT7 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(5).ICI),'omitnan'));title('CT5 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(4).ICI),'omitnan'));title('CT4/6 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(3).ICI),'omitnan'));title('CT3 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(2).ICI),'omitnan'));title('CT2 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(trainSet(1).ICI),'omitnan'));title('CT10 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% 
% figure;imagesc([],[],cell2mat(vertcat(trainSet(1).WV))');title('CT10 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(2).WV))');title('CT2 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(3).WV))');title('CT3 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(4).WV))');title('CT4/6 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(5).WV))');title('CT5 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(6).WV))');title('CT7 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(7).WV))');title('CT8 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(8).WV))');title('CT9 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(9).WV))');title('Blainville''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(10).WV))');title('Boats Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(11).WV))');title('Cuvier''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(12).WV))');title('Echosounder Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(13).WV))');title('Gervais'' Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(14).WV))');title('Kogia Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(15).WV))');title('Noise Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(16).WV))');title('Risso''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(17).WV))');title('Sowerby''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(18).WV))');title('Sperm Whale Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(trainSet(19).WV))');title('True''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% 
% 
% 
% figure;imagesc([],f,cell2mat(vertcat(testSet(1).Specs))');title('CT10 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(2).Specs))');title('CT2 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(3).Specs))');title('CT3 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(4).Specs))');title('CT4/6 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(5).Specs))');title('CT5 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(6).Specs))');title('CT7 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(7).Specs))');title('CT8 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(8).Specs))');title('CT9 CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(9).Specs))');title('Blainville''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(10).Specs))');title('Boats CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(11).Specs))');title('Cuvier''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(12).Specs))');title('Echosounder CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(13).Specs))');title('Gervais'' CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(14).Specs))');title('Kogia CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(15).Specs))');title('Noise CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(16).Specs))');title('Risso''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(17).Specs))');title('Sowerby''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(18).Specs))');title('Sperm Whale CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% figure;imagesc([],f,cell2mat(vertcat(testSet(19).Specs))');title('True''s CatSpec');xlabel('Bin');ylabel('Frequency (kHz)');set(gca,'ydir','normal')
% 
% figure;bar(sum(cell2mat(testSet(19).ICI),'omitnan'));title('True''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(18).ICI),'omitnan'));title('Sperm Whale ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(17).ICI),'omitnan'));title('Sowerby''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(16).ICI),'omitnan'));title('Risso''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(15).ICI),'omitnan'));title('Noise ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(14).ICI),'omitnan'));title('Kogia ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(13).ICI),'omitnan'));title('Gervais'' ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(12).ICI),'omitnan'));title('Echosounder ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(11).ICI),'omitnan'));title('Cuvier''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(10).ICI),'omitnan'));title('Boats ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(9).ICI),'omitnan'));title('Blainville''s ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(8).ICI),'omitnan'));title('CT9 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(7).ICI),'omitnan'));title('CT8 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(6).ICI),'omitnan'));title('CT7 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(5).ICI),'omitnan'));title('CT5 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(4).ICI),'omitnan'));title('CT4/6 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(3).ICI),'omitnan'));title('CT3 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(2).ICI),'omitnan'));title('CT2 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% figure;bar(sum(cell2mat(testSet(1).ICI),'omitnan'));title('CT10 ICI');xlim([0 60]);xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});xlabel('ICI (s)');ylabel('Counts');
% 
% figure;imagesc([],[],cell2mat(vertcat(testSet(1).WV))');title('CT10 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(2).WV))');title('CT2 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(3).WV))');title('CT3 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(4).WV))');title('CT4/6 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(5).WV))');title('CT5 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(6).WV))');title('CT7 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(7).WV))');title('CT8 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(8).WV))');title('CT9 Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(9).WV))');title('Blainville''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(10).WV))');title('Boats Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(11).WV))');title('Cuvier''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(12).WV))');title('Echosounder Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(13).WV))');title('Gervais'' Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(14).WV))');title('Kogia Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(15).WV))');title('Noise Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(16).WV))');title('Risso''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(17).WV))');title('Sowerby''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(18).WV))');title('Sperm Whale Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% figure;imagesc([],[],cell2mat(vertcat(testSet(19).WV))');title('True''s Envelope');xlabel('Bin');ylabel('Sample');set(gca,'ydir','normal');ylim([50 150]);
% 

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
    elseif size(trainIdx,2) >= 50000 % if too many examples, subsample
        expandedTrainIdx = randsample(trainIdx,50000);
    else
        expandedTrainIdx = randsample(trainIdx,50000,true); % if too few examples, resample w replacement
    end
    if isempty(testSet(iD).Specs)
        fprintf('Warning: No testing data for %s\n',string(testSet(iD).ClickType));
        expandedTestIdx = [];
    elseif size(testIdx,2) >= 5000 % if too many examples, subsample
        expandedTestIdx = randsample(testIdx,5000);
    else
        expandedTestIdx = randsample(testIdx,5000,true); % if too few examples, resample w replacement
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

% Concatenate spectra and ICI data
testMSPICI = [testMSPSet,zeros(size(testMSPSet,1),1),testDTTSet];
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


