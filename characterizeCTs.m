%% Calculate summary stats for click types used to train a neural net; plot
% mean spectra, ICI distributions, mean waveform envelopes

clearvars

% directory containing folders with composite_clusters output training examples
trainDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp';
saveDir = 'I:\cluster_NNet\TrainSetSummary';
TPWSDirs = {'G:\Shared drives\MBARC_All\TPWS\GOM\MP_10-90kHz'};
samps = 3e3; %WARNING: make sure all classes have at least this many clicks 
% available or indexing will get messed up later on
f = 4.5:0.5:99.5;
Fs = 2e5;
prctlRange = [10 90];

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
%         ICImodes = [];
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
%                 ICImodes = [ICImodes;thisType.Tfinal{1,4}'];
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
% 
% % For manually adding more examples to any class
% % edges = 0:0.01:1;
% % [mx, Ind] = max(thisType.Tfinal{1,2},[],2);
% % compiledICI = edges(Ind)+0.005;
% % ICIdata{20,2} = [ICIdata{20,2};compiledICI']; % CHANGE FIRST INDEX OF ICIdata TO APPROPRIATE CLASS
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
% for i = 1:size(uniqueTPWSfiles,1)
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

%% Compute summary statistics an create plots for each CT
load(fullfile(saveDir,'CompiledClicks.mat'));
load(fullfile(saveDir,'ICIdata.mat'));
summaryStats = struct('CT',[],'MedSpec',[],'SpecPerctles',[],'MedPeakFreq',...
    [],'PeakFreqPerctles',[],'FreqPeaks',[],'modalICIdist',[],'ICIMedOfModes',...
    [],'ICIPerctles',[],'MedBW_3dB',[],'BW_Perctles',[],'MedDuration',[],...
    'Dur_Perctles',[]);

for i = 1:size(compiledClicks,1)
    if ~isempty(compiledClicks{i,2})
        
%         % Find loud clicks and grab random subset
%         loudClicks = find(compiledClicks{i,5}>=125);
%         
%         if size(loudClicks,1)>1000
%             clickInds = loudClicks(randsample(1:size(loudClicks,1),1000));
%         else
%             clickInds = loudClicks;
%         end

        % Grab random subset of clicks
        if size(compiledClicks{i,3},1)>2000
            clickInds = randsample(1:size(compiledClicks{i,3},1),2000);
        else
            clickInds = 1:size(compiledClicks{i,3},1);
        end
        
        % Compute median spectrum & percentiles (linearize, average, revert to dB)
        specs = compiledClicks{i,3}(clickInds,:);
        linSpecs = 10.^(specs./20);
        linSpecs = linSpecs-min(linSpecs,[],2);
%         sumSpec = 20*log10(mean(linSpecs,1));
        medSpec = 20*log10(median(linSpecs));
        specPerctles = 20*log10(prctile(linSpecs,prctlRange));
        
        % Find median peak frequency & percentiles
        [specMax,specMaxInd] = max(specs,[],2);
        peakFreqs = f(specMaxInd);
        medPeakFreq = median(peakFreqs);
        peakFreqPerctls = prctile(peakFreqs,prctlRange);
        
        % Find peaks in mean spectrum
        [pks locs] = findpeaks(medSpec);
        pkFreqs = f(locs);
        
        % Calculate -3dB bandwidth for each click, then average
        minus3dBVal = specMax-3;
        lower3dBfreq = [];
        upper3dBfreq = [];
        for k = 1:size(specs,1)
            slopeup = fliplr(specs(k,1:specMaxInd(k)));
            slopedown = specs(k,specMaxInd(k):end);
            for first3dB = 1:size(slopeup,2)
                if slopeup(first3dB)<minus3dBVal(k)
                    break
                end
            end
            for last3dB = 1:size(slopedown,2)
                if slopedown(last3dB)<minus3dBVal(k)
                    break
                end
            end
            lower3dBfreq = [lower3dBfreq;f(specMaxInd(k)-first3dB+1)];
            upper3dBfreq = [upper3dBfreq;f(specMaxInd(k)+last3dB-1)];
        end
        BW3dB = upper3dBfreq-lower3dBfreq;
        med3dBBW = median(BW3dB);
        BW3dB_perctls = prctile(BW3dB,prctlRange);
        
        % Compute & align waveform envelopes
        envSet = abs(hilbert(compiledClicks{i,4}(clickInds,:)'))';
        midLine = (size(envSet,2))/2;
        midLineBuff = round(midLine*.10);
        [wavMax,wavMaxInd] = max(envSet(:,midLine-midLineBuff:midLine+midLineBuff),[],2);
        peakLoc = wavMaxInd + (midLine-midLineBuff);
        offsetIdx = peakLoc-midLine;
        envSetAlign = zeros(size(envSet));
        for iE = 1:size(envSet,1)
            thisEnv = envSet(iE,:);
            if offsetIdx(iE)<0 % peak is after midline
                alignedIdx = 1:(peakLoc(iE)+midLine);
                thisEnvPadded = [zeros(1,abs(offsetIdx(iE))),thisEnv(alignedIdx)];
            else % peak is before midline
                alignedIdx = (offsetIdx(iE)+1):size(envSet,2);
                thisEnvPadded = [thisEnv(alignedIdx),zeros(1,abs(offsetIdx(iE)))];
            end
            envSetAlign(iE,:) = thisEnvPadded;
        end
        envSetAlign = envSetAlign./max(envSetAlign,[],2);
%         envSet = envSet./max(envSet,[],2);
        
        % Find ICI median of modes
        edges = 0:0.01:1;
        if size(ICIdata{i,2},1)<=1000
            ICImodes = ICIdata{i,2};
        else
            ICImodes = randsample(ICIdata{i,2},1000);
        end
        ICImodes = ICImodes(ICImodes>=0.02);
        medOfModes = median(ICImodes);
        ICIprctls = prctile(ICImodes,prctlRange);
        
        % Normalize ICI mode dist for plotting
        [N,edges] = histcounts(ICImodes,edges);
        N = N-min(N);
        N_norm = N/max(N);              
        
        % Normalize spectra for plotting
        specs_0 = specs-min(specs,[],2);
        specs_norm = specs_0./max(specs_0,[],2);
        
        % Calculate click durations
        clickStart = [];
        clickEnd = [];
        energy = compiledClicks{i,4}(clickInds,:).^2;

        for k = 1:size(energy,1)
            [maxE, maxEind] = max(energy(k,:));
            dataSmooth = smoothdata(energy(k,:),2,'movmean',15); % only works in
%         newer version of Matlab
%             dataSmooth = smooth(energy(k,:),15);
            thresh = prctile(energy(k,:),70);
            N = size(energy(k,:),2);
            leftmost = 5;
            % Find where energy dips below thresh using running mean of smoothed energy
            leftIdx = max(maxEind - 1,leftmost);
            while (leftIdx > leftmost) && (mean(dataSmooth(leftIdx-4:leftIdx)) > thresh) 
                leftIdx = leftIdx - 1;
            end
            
            rightmost = N-5;
            rightIdx = maxEind+1;
            while rightIdx < rightmost && (mean(dataSmooth(rightIdx:rightIdx+4)) > thresh)
                rightIdx = rightIdx+1;
            end

            clickStart = [clickStart;leftIdx];
            clickEnd = [clickEnd;rightIdx];        
        end
        
        clickDurs = 1e6*(clickEnd - clickStart)./Fs; % durations in microseconds
        medDur = median(clickDurs);
        durprctle = prctile(clickDurs,prctlRange);
        
        % Sort spectra & waveform envelopes by duration
%         [sortDurs, sortInd] = sort(clickDurs);
        
        % Sort spectra & waveform envelopes by RL
        RLs = compiledClicks{i,5}(clickInds);
        [sortRLs, sortInd] = sort(RLs);
        
        % Compile & save click type params
        summaryStats(i).CT = compiledClicks{i,1};
        summaryStats(i).MedSpec = medSpec;
        summaryStats(i).SpecPerctles = specPerctles;
        summaryStats(i).MedPeakFreq = medPeakFreq;
        summaryStats(i).PeakFreqPerctles = peakFreqPerctls;
        summaryStats(i).FreqPeaks = pkFreqs;
        summaryStats(i).modalICIdist = N_norm;
        summaryStats(i).ICIMedOfModes = medOfModes;
        summaryStats(i).ICIPerctles = ICIprctls;
        summaryStats(i).MedBW_3dB = med3dBBW;
        summaryStats(i).BW_Perctles = BW3dB_perctls;
        summaryStats(i).MedDuration = medDur;
        summaryStats(i).Dur_Perctles = durprctle;
        save(fullfile(saveDir,'CTSummaryStats.mat'),'summaryStats','-v7.3');
        
        % Plot summary spectrum, catSpecs, catEnvs, ICI mode dist
        figure(99),clf
        subplot(1,4,1)
        hold on
        plot(4.5:0.5:99.5,medSpec,'k','LineWidth',2)
        plot(4.5:0.5:99.5,specPerctles(1,:),'--k','LineWidth',2)
        plot(4.5:0.5:99.5,specPerctles(2,:),'--k','LineWidth',2)
        hold off
        grid on
        xlim([5 100]);
        ylim([min(specPerctles(1,:))-2,max(specPerctles(2,:))+2]);
        xlabel('Frequency (kHz)')
        ylabel('Spectral Level (dBpp re: 1\muPa)');
        set(gca,'fontSize',12);
%         title('Median Power Spectrum');
        
        subplot(1,4,3)
        imagesc([],f,specs_norm(sortInd,:)');
        set(gca,'YDir','Normal');
        xlabel('Click Number');
        ylabel('Frequency (kHz)');
        set(gca,'fontSize',12);
%         title('Concatenated Click Spectra');
%         cb = colorbar;
%         cb.Label.String = 'Relative Spectral Level';
        
        subplot(1,4,2)
        bar(N_norm,1);        
        if i==9
            xlim([2 80]);
            xticks([20,40,60,80]);
            xticklabels({'0.2','0.4','0.6','0.8'});
        elseif i==19
            xlim([2 100]);
            xticks([20,40,60,80,100]);
            xticklabels({'0.2','0.4','0.6','0.8','1'});
        else
            xlim([2 50]);
            xticks([10,20,30,40,50]);
            xticklabels({'0.1','0.2','0.3','0.4','0.5'});
        end
        ylim([0 1]);
%         title('Modal ICI Values');
        xlabel('ICI (s)');
        ylabel('Relative Counts');
        set(gca,'fontSize',12);
        
        subplot(1,4,4)
        imagesc([],0:5:500,envSetAlign(sortInd,50:150)');
        set(gca,'XDir','Normal');
        set(gca,'YDir','Normal');
        xlabel('Click Number');
        ylabel('Time (\mus)');
        set(gca,'fontSize',12);
%         title('Concatenated Waveform Envelopes');
%         cb = colorbar;
%         cb.Label.String = 'Relative Pressure Level';      
        
%         [ax, h1] = suplabel(compiledClicks{i,1},'t',[.08 .075 .85 .89]);
%         set(ax,'fontSize',14);
        
        saveas(gcf,fullfile(saveDir,compiledClicks{i,1}),'tiff');
        print('-painters','-depsc',fullfile(saveDir,compiledClicks{i,1}));
        
    end
end
