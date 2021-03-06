%% Calculate summary stats for click types used to train a neural net; plot
% mean spectra, ICI distributions, mean waveform envelopes

clearvars

% directory containing folders with composite_clusters output training examples
trainDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp';
saveDir = 'I:\cluster_NNet\TrainSetSummary';
TPWSDirs = {'J:\JAX10C'};
samps = 3e3; %WARNING: make sure all classes have at least this many clicks 
% available or indexing will get messed up later on
f = 4.5:0.5:99.5;

%% Figure out how many clicks contributed to each class and which deployments 
% they came from; then pick random sample from each class

% trainSet = dir(trainDir);
% trainSet(1:2) = [];
% ClickSummary = {};
% ICIdata = {};
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
%           ICImodes = [];
%         
%         for i = 1:size(compClustFiles,1)  % run through composite_clusters files and count how many clicks
%             if contains(compClustFiles(i).name,'type') %&& ~contains(compClustFiles(i).name,'NFC')...
%                     %&& ~contains(compClustFiles(i).name,'HAT') && ~contains(compClustFiles(i).name,'JAX')
%                 load([typeDir '\' compClustFiles(i).name]);
%                 
% %                 stringGrab = compClustFiles(i).name;
% %                 if ~isempty(strfind(stringGrab,'Copy of '))
% %                     dep = strrep(stringGrab,'Copy of ','');
% %                 else
% %                     dep = stringGrab;
% %                 end
%                 
%                 totNumClicks = totNumClicks + size(thisType.clickTimes,1);
%                 clickTimes = [clickTimes;thisType.clickTimes];
%                 sortedTimes = sort(unique(thisType.Tfinal{1,7}));
%                 edges = [sortedTimes; sortedTimes(end)+(5/(60*24))];
%                 [~,~, whichBin] = histcounts(thisType.clickTimes,edges);
%                 whichBin(whichBin==0) = [];
%                 whichTPWS = TPWSList(1,thisType.fileNumExpand(whichBin))';
%                 TPWS = [TPWS;whichTPWS];
%                   ICImodes = [ICImodes;thisType.Tfinal{1,4}'];
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
%         ICIdata{t,1} = CT;
%         ICIdata{t,2} = ICImodes;
% 
%         t = t+1;
%     end
% end
% 
% save(fullfile(saveDir,'ClickSummary'),'ClickSummary','-v7.3');
% save(fullfile(saveDir,'ICIdata'),'ICIdata','-v7.3');
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
% 
% % open TPWS files one at a time and grab appropriate clicks for each class
% for i = 192:209;%1:size(uniqueTPWSfiles,1)
%     
%     % get filepath
%     findTPWS = strcmp({fullFileList.name},uniqueTPWSfiles{i});
%     
%     % load TPWS vars
%     if sum(findTPWS)==0 || sum(findTPWS)>1
%         fprintf('Warning: %s not found or found in multiple locations, skipping to next file\n',uniqueTPWSfiles{i});
%     elseif sum(findTPWS)==1
%         
%         fprintf('Pulling clicks from file %d of %d\n',i,size(uniqueTPWSfiles,1));
%         tic
%         load(fullfile(fullFileList(findTPWS).folder,fullFileList(findTPWS).name));
%         toc
%         % find which clicks need to be saved for which classes
%         findClicks = find(strcmp(allTPWSfiles,uniqueTPWSfiles{i})); %indices of all clicks from this TPWS
%         classEdges = 1:samps:size(allTPWSfiles,1)+samps;
%         classEdges(end) = classEdges(end)-1;
%         [N,~,class] = histcounts(findClicks,classEdges); %bin these indices by class      
%         C = unique(class);
%         
%         % save clicks to appropriate classes
%         for k = 1:size(C)
%             
%             clicksThisClass = find(class==C(k));
%             timesThisClass = allClickTimes(findClicks(clicksThisClass));
%             [~,indsThisClass,ib] = intersect(MTT,timesThisClass);
%             
%             if size(timesThisClass,1)==size(indsThisClass,1)
%                 compiledClicks{C(k),2} = [compiledClicks{C(k),2};MTT(indsThisClass)];
%                 compiledClicks{C(k),3} = [compiledClicks{C(k),3};MSP(indsThisClass,:)];
%                 compiledClicks{C(k),4} = [compiledClicks{C(k),4};MSN(indsThisClass,:)];
%                 compiledClicks{C(k),5} = [compiledClicks{C(k),5};MPP(indsThisClass)];
%                 compiledClicks{C(k),6} = [compiledClicks{C(k),6};allTPWSfiles(findClicks(clicksThisClass))];
%             else
%                 fprintf('  Didn''t locate the correct number of clicks for class %d\n',C(k));
%                 compiledClicks{C(k),2} = [compiledClicks{C(k),2};MTT(indsThisClass)];
%                 compiledClicks{C(k),3} = [compiledClicks{C(k),3};MSP(indsThisClass,:)];
%                 compiledClicks{C(k),4} = [compiledClicks{C(k),4};MSN(indsThisClass,:)];
%                 compiledClicks{C(k),5} = [compiledClicks{C(k),5};MPP(indsThisClass)];
%                 compiledClicks{C(k),6} = [compiledClicks{C(k),6};allTPWSfiles(findClicks(clicksThisClass(ib)))];
%             end
%         end
%     end
%     
%     if mod(i,10)==0
%        save(fullfile(saveDir,'CompiledClicks'),'compiledClicks','-v7.3');
%     end
% end

%% Compute summary statistics for each CT
load(fullfile(saveDir,'CompiledClicks.mat'));
load(fullfile(saveDir,'ICIdata.mat'));
summaryStats = struct('CT',[],'MeanSpecs',[],'ICIdists',[],'PeakFreq',[],'BW_3dB',[]);

for i = 1:size(compiledClicks,1)
    if ~isempty(compiledClicks{i,2})
        %     % linearize, normalize, average
        %     linSpecs = 10.^(compiledClicks{i,3}./20);
        %     linSpecs = linSpecs-min(linSpecs,[],2);
        %     linSpecs_norm = linSpecs./max(linSpecs,[],2);
        %     sumSpec = 20*log10(mean(linSpecs_norm,1));
        %     specPerctle_linNorm = 20*log10(prctile(linSpecs_norm,[25,75]));
        %
        %     figure
        %     hold on
        %     plot(4.5:0.5:99.5,sumSpec,'k','LineWidth',2)
        %     plot(4.5:0.5:99.5,specPerctle_linNorm(1,:),'--k','LineWidth',2)
        %     plot(4.5:0.5:99.5,specPerctle_linNorm(2,:),'--k','LineWidth',2)
        %     hold off
        %     title('Linearize, Normalize, Average')
        
        % Compute mean spectrum & percentiles (normalize, linearize, average)
        specs = compiledClicks{i,3};
        specs_0 = specs-min(compiledClicks{i,3},[],2);
        specs_norm = specs_0./max(specs_0,[],2);
        specPerctle_norm = prctile(specs_norm,[25,75]);
        specsNorm_lin = 10.^(specs_norm./20);
        sumSpec_norm = 20*log10(mean(specsNorm_lin,1));
        
        % Find peaks in mean spectrum
        [p locs] = findpeaks(sumSpec_norm);
        pks = f(locs);
        
        % Calculate average -3dB bandwidth
        specMax = max(specs,[],2); 
        threedBVal = specMax-3;
        dist = abs(specs-threedBVal);
        [M,I] = min(dist

        
minDist = min(dist);
minIdx  = (dist == minDist);
minVal  = a(minIdx)
        
        % Compute & align waveform envelopes
        envSet = abs(hilbert(compiledClicks{i,4}'))';
        midLine = (size(envSet,2))/2;
        midLineBuff = round(midLine*.10);
        [~,I] = max(envSet(:,midLine-midLineBuff:midLine+midLineBuff),[],2);
        peakLoc = I+ (midLine-midLineBuff);
        offsetIdx = peakLoc-midLine;
        envSetAlign = zeros(size(envSet));
        for iE = 1:size(envSet,1)
            thisEnv = envSet(iE,:);
            if offsetIdx(iE)<0
                alignedIdx = 1:(peakLoc(iE)+midLine);
                thisEnvPadded = [zeros(1,abs(offsetIdx(iE))),thisEnv(alignedIdx)];
            else
                alignedIdx = (offsetIdx(iE)+1):size(envSet,2);
                thisEnvPadded = [thisEnv(alignedIdx),zeros(1,abs(offsetIdx(iE)))];
            end
            envSetAlign(iE,:) = thisEnvPadded;
        end
        envSet = envSet./max(envSet,[],2);
        
        if size(ICIdata{i,2},1)<=1000
            plotICI = ICIdata{i,2};
        else
            plotICI = randsample(ICIdata{i,2},1000);
        end
        [N,edges] = histcounts(plotICI,0:0.01:1);
        N = N-min(N);
        N_norm = N/max(N);
        
        % Find ICI mode of modes
        modeOfModes = find(max(N_norm));
        
        % Plot summary spectrum, catSpecs, catEnvs, ICI mode dist
        figure(99),clf
        subplot(1,4,1)
        hold on
        plot(4.5:0.5:99.5,sumSpec_norm,'k','LineWidth',2)
        plot(4.5:0.5:99.5,specPerctle_norm(1,:),'--k','LineWidth',2)
        plot(4.5:0.5:99.5,specPerctle_norm(2,:),'--k','LineWidth',2)
        hold off
        grid on
        ylim([0 1]);
        xlim([5 100]);
        xlabel('Frequency (kHz)')
        ylabel('Normalized Amplitude');
        title('Mean Spectrum');
        
        subplot(1,4,2)
        imagesc([],f,specs_norm');
        set(gca,'YDir','Normal');
        xlabel('Click Number');
        ylabel('Frequency (kHz)');
        title('Concatenated Clicks');
        
        subplot(1,4,3)
        imagesc(envSet');
        set(gca,'YDir','Normal');
        xlabel('Click Number');
        ylabel('Sample Number');
        title('Concatenated Waveform Envelopes');
        
        subplot(1,4,4)
        title('Modal ICI Values');
        bar(N_norm,1);
        xlim([0 100]);
        xticks([0,20,40,60,80,100]);
        xticklabels({'0','0.2','0.4','0.6','0.8','1'});
        ylim([0 1]);
        xlabel('ICI (s)');
        ylabel('Relative Counts');
        
        [ax, h1] = suplabel(compiledClicks{i,1},'t',[.08 .087 .85 .89]);
        set(ax,'fontSize',14);
        
        saveas(gcf,fullfile(saveDir,compiledClicks{i,1}),'tiff');
        
        summaryStats(i).CT = compiledClicks(i).name;
        summaryStats(i).MeanSpecs = sumSpec;
        summaryStats(i).modalICIdists = N_norm;
        summaryStats(i).PeakFreq = pf;
    end
end

%% Plot
% f = 5:0.5:98.5;

% q = size(summaryStats,2);
% m = ceil(q/n); % number of columns of subplots

% for i = 1:size(summaryStats,2)
%     
%     figure(1)
%     subplot(1,2,1)
%     plot(f,summaryStats(i).MeanSpecs)
%     xlim([5,100])
%     ylim([0 1])
%     xlabel('Frequency (kHz)');
%     ylabel('Normalized Amplitude');
%     
%     subplot(1,2,2)
%    
%     
% end

