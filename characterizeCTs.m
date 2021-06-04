%% Calculate summary stats for click types used to train a neural net; plot
% mean spectra, ICI distributions, mean waveform envelopes

% clearvars
% 
% % directory containing folders with composite_clusters output training examples
% trainDir = 'I:\cluster_NNet\TrainSetSummary\MostRepresentativeClusters';
% saveDir = 'I:\cluster_NNet\TrainSetSummary';
% TPWSDirs = {'J:\','H:\HAT_B_01-03'};
% samps = 3e3; %WARNING: make sure all classes have at least this many clicks 
% % available or indexing will get messed up later on

%% Figure out how many clicks contributed to each class and which deployments 
% they came from; then pick random sample from each class

% trainSet = dir(trainDir);
% trainSet(1:2) = [];
% ClickSummary = {};
% t = 1;
% 
% for k = 1:size(trainSet,1) %for each click type
%     if trainSet(k).isdir == 1
%         
%         typeDir = fullfile(trainSet(k).folder,trainSet(k).name);
%         compClustFiles = dir([typeDir '\*.mat']);
%         CT = trainSet(k).name;
%         totNumClicks = 0;
%         clickTimes = [];
%         TPWS = {};
%         
%         for i = 1:size(compClustFiles,1)  % run through composite_clusters files and count how many clicks
%             if contains(compClustFiles(i).name,'type') %&& ~contains(compClustFiles(i).name,'NFC')...
%                     %&& ~contains(compClustFiles(i).name,'HAT') && ~contains(compClustFiles(i).name,'JAX')
%                 load([typeDir '\' compClustFiles(i).name]);
%                 
%                 stringGrab = compClustFiles(i).name;
%                 if ~isempty(strfind(stringGrab,'Copy of '))
%                     dep = strrep(stringGrab,'Copy of ','');
%                 else
%                     dep = stringGrab;
%                 end
%                 
%                 totNumClicks = totNumClicks + size(thisType.clickTimes,1);
%                 clickTimes = [clickTimes;thisType.clickTimes];
%                 sortedTimes = sort(unique(thisType.Tfinal{1,7}));
%                 edges = [sortedTimes; sortedTimes(end)+(5/(60*24))];
%                 [~,~, whichBin] = histcounts(thisType.clickTimes,edges);
%                 whichBin(whichBin==0) = [];
%                 whichTPWS = TPWSList(1,thisType.fileNumExpand(whichBin))';
%                 TPWS = [TPWS;whichTPWS];
%                 
%             end
%         end
%         
%         ClickSummary{t,1} = CT;
%         ClickSummary{t,2} = totNumClicks;
%         %         ClickSummary{t,3} = clickTimes; % can't save everything, file gets huuuuuge!
%         %         ClickSummary{t,4} = TPWS;
%         
%         
%         clickInds = sort(randsample(ClickSummary{t,2},samps));
%         ClickSummary{t,3} = clickTimes(clickInds);
%         ClickSummary{t,4} = TPWS(clickInds);
%         
%         t = t+1;
%     end
% end
% 
% save(fullfile(saveDir,'ClickSummary'),'ClickSummary','-v7.3');
%%

% fullFileList = [];
% 
% % Find all TPWS files in your directories
% for k = 1:size(TPWSDirs,2)
%     fileList = dir(fullfile(TPWSDirs{k},'**\*TPWS1.mat'));
%     fullFileList = [fullFileList;fileList];
% end
% 
% % figure out which files you actually need to open
% allTPWSfiles = vertcat(ClickSummary{:,4});
% [uniqueTPWSfiles,ia,ic] = unique(allTPWSfiles);
% 
% allClickTimes = vertcat(ClickSummary{:,3});
% 
% compiledClicks = cell(size(ClickSummary,1),6);
% compiledClicks(1:size(ClickSummary,1),1) = ClickSummary(1:size(ClickSummary,1),1);

% open TPWS files one at a time and grab appropriate clicks for each class
for i = 371:size(uniqueTPWSfiles,1)
    
    % get filepath
    findTPWS = strcmp({fullFileList.name},uniqueTPWSfiles{i});
    
    % load TPWS vars
    if sum(findTPWS)==0 || sum(findTPWS)>1
        fprintf('Warning: %s not found or found in multiple locations, skipping to next file\n',uniqueTPWSfiles{i});
    elseif sum(findTPWS)==1
        
        fprintf('Pulling clicks from file %d of %d\n',i,size(uniqueTPWSfiles,1));
        tic
        load(fullfile(fullFileList(findTPWS).folder,fullFileList(findTPWS).name));
        toc
        % find which clicks need to be saved for which classes
        findClicks = find(strcmp(allTPWSfiles,uniqueTPWSfiles{i})); %indices of all clicks from this TPWS
        classEdges = 1:samps:size(allTPWSfiles,1)+samps;
        classEdges(end) = classEdges(end)-1;
        [N,~,class] = histcounts(findClicks,classEdges); %bin these indices by class      
        C = unique(class);
        
        % save clicks to appropriate classes
        for k = 1:size(C)
            
            clicksThisClass = find(class==C(k));
            timesThisClass = allClickTimes(findClicks(clicksThisClass));
            [~,indsThisClass,ib] = intersect(MTT,timesThisClass);
            
            if size(timesThisClass,1)==size(indsThisClass,1)
                compiledClicks{C(k),2} = [compiledClicks{C(k),2};MTT(indsThisClass)];
                compiledClicks{C(k),3} = [compiledClicks{C(k),3};MSP(indsThisClass,:)];
                compiledClicks{C(k),4} = [compiledClicks{C(k),4};MSN(indsThisClass,:)];
                compiledClicks{C(k),5} = [compiledClicks{C(k),5};MPP(indsThisClass)];
                compiledClicks{C(k),6} = [compiledClicks{C(k),6};allTPWSfiles(findClicks(clicksThisClass))];
            else
                fprintf('  Didn''t locate the correct number of clicks for class %d\n',C(k));
                compiledClicks{C(k),2} = [compiledClicks{C(k),2};MTT(indsThisClass)];
                compiledClicks{C(k),3} = [compiledClicks{C(k),3};MSP(indsThisClass,:)];
                compiledClicks{C(k),4} = [compiledClicks{C(k),4};MSN(indsThisClass,:)];
                compiledClicks{C(k),5} = [compiledClicks{C(k),5};MPP(indsThisClass)];
                compiledClicks{C(k),6} = [compiledClicks{C(k),6};allTPWSfiles(findClicks(clicksThisClass(ib)))];
            end
        end
    end
    
    if mod(i,10)==0
       save(fullfile(saveDir,'CompiledClicks'),'compiledClicks','-v7.3');
    end
end

%% Compute summary statistics for each CT
summaryStats = struct('CT',[],'MeanSpecs',[],'ICIdists',[],'PeakFreq',[],'BW_3dB',[]);

%             if size(thisType.Tfinal{1,1},2) == 188
%                 data.BinSpecs = [data.BinSpecs;thisType.Tfinal{1,1}];
%                 
%             elseif size(thisType.Tfinal{1,1},2) == 191
%                 data.BinSpecs = [data.BinSpecs;thisType.Tfinal{1,1}(2:189)];
%             end
%             data.ICI = [data.ICI;thisType.Tfinal{1,2}];
%             data.Deployment = [data.Deployment;depVec];

%      sumSpec = mean(data.BinSpecs,1);
%      sumSpec = sumSpec-min(sumSpec);
%      sumSpec_norm = sumSpec./max(sumSpec);
%      
%      ICI = sum(data.ICI,1);
%      
%      pf = f(find(sumSpec_norm == max(sumSpec_norm)));
%      
%      summaryStats(b).CT = trainSet(k).name;
%      summaryStats(b).MeanSpecs = sumSpec_norm;
%      summaryStats(b).ICIdists = ICI;
%      summaryStats(b).PeakFreq = pf;
%% Plot
% f = 5:0.5:98.5;

% q = size(summaryStats,2);
% m = ceil(q/n); % number of columns of subplots

for i = 1:size(summaryStats,2)
    
    figure(1)
    subplot(1,2,1)
    plot(f,summaryStats(i).MeanSpecs)
    xlim([5,100])
    ylim([0 1])
    xlabel('Frequency (kHz)');
    ylabel('Normalized Amplitude');
    
    subplot(1,2,2)
   
    
end

