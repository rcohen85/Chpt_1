% Loop through TWPS and associated ID1 files, bin labeled clicks and
% calculate mean spectra and ICI dist per bin
% inDir - directory containing TPWS and associated ID1 files
% outDir - directory to save binned_labels output
% Labels (can be left empty if the one below is correct) - Nx2 cell array in 
% which first column is the name of each click type/species, and the second
% column is the number label used to identify that click type/species in the ID1 file
% binSize - desired time bin duration IN MINUTES
% minClicks - minimum number of clicks in a bin for a mean spectrum & ICI 
% to be calculated; a scalar or an Nx1 vector; default is 50 clicks
% minPP - minimum peak-to-peak amplitude required to retain clicks
% saveSuffix - string to append to end of binned_clicks file names indicating
% binSize and/or minClicks and/or minPP; e.g. '5min'
%
% OUTPUT: a binned_clicks file corresponding to each TPWS and ID1 file
% containing a binned_labels struct with the following fields:
% BinTimes - start times of bins
% BinSpecs - mean spectra for all click types in each bin
% ICI_dists - ICI distributions of clicks corresponding to each mean spec
% EnvShape - mean waveform envelope of clicks corresponding to each mean spec
% ClickTimes - times of clicks corresponding to each mean spec
% Also a struct, p, containing the input arguments (except saveSuffix)

function [binned_labels] = bin_labeled_clicks(inDir,outDir,Labels,binSize,minClicks,minPP,saveSuffix)

if isempty(Labels)
    Labels = {'Blainvilles',1;'Boats',2;'CT11',3;'CT2+CT9',4;'CT3+CT7',5;'CT4/6+CT10',6;...
    'CT5',7;'CT8',8;'Cuviers',9;'Gervais',10;'GoM_Gervais',11;'HFA',12;'Kogia',13;...
    'MFA',14;'MultiFreq_Sonar',15;'Rissos',16;'SnapShrimp',17;'Sowerbys',18;'Sperm Whale',19;...
    'True',20};

end
if isempty(minClicks)
    minClicks = 50;
end

% Create parameter struct to be saved with output
p.inDir = inDir;
p.outDir = outDir;
p.Labels = Labels;
p.binSize = binSize;
p.minClicks = minClicks;
p.minPP = minPP;


TPWSlist = dir(fullfile(inDir,'*TPWS1.mat'));
labelList = dir(fullfile(inDir,'*ID1.mat'));

if size(TPWSlist,1) ~= size(labelList,1)
    fprintf('Warning: input file mismatch; make sure each TPWS1 file has an ID1 file\n');
    x = input('Press Enter to continue, or CtrlC to stop function\n');
end

for iA = 1:size(TPWSlist,1)  % TPWS index
    
    fprintf('Binning TPWS %d of %d\n',iA,size(TPWSlist,1));
    
    % Load TPWS and associated labels
    load(fullfile(inDir,TPWSlist(iA).name));
    load(fullfile(inDir,labelList(iA).name));
    if exist('f','var')
        p.f = f;
    end
    
    % Determine bin start/end times
    [yr, mon, day, hr, mint, sec] = datevec(zID(1,1));
    st = datenum([yr,mon,day,hr,mint,0]);
    [yr, mon, day, hr, mint, sec] = datevec(zID(end,1));
    mint = mint+1;
    e = datenum([yr,mon,day,hr,mint,0]);
    
    bin_inc = binSize/(60*24);
    bin_vec = (st:bin_inc:e)';
    
    % For each label, determine which clicks belong to each bin, test for
    % minPP and minClick thresholds, then calculate mean spectra and ICI
    % dist for each bin
    binned_labels = struct('ClickType',[],'BinTimes',[],'BinSpecs',[],...
        'ICI_dists',[],'EnvShape',[],'ClickTimes',[]);
    
    for iB = 1:size(Labels,1)  % label index
        
        binned_labels(iB).ClickType = Labels(iB,1);
        
        % get times of this label
        labelInd1 = find(zID(:,2)==cell2mat(Labels(iB,2)));
        thisLabel = zID(labelInd1,:);
        
        if isempty(thisLabel)
            continue
        else
            % find clicks in TPWS and remove clicks below minPP threshold,
            % then find remaining loud clicks in thisLabel
            [~, clickInd, ~] = intersect(MTT,thisLabel(:,1));
            clickInd(MPP(clickInd) <= minPP) = [];         % indices of nice loud click in TPWS vars
            [~, ~, labelInd2] = intersect(MTT(clickInd),thisLabel(:,1));
            goodLabels = thisLabel(labelInd2,:);           % labels of nice loud clicks
            
            % divvy clicks into bins
            edges = [bin_vec; bin_vec(end)+bin_inc];
            [bin_count, ~, binInd] = histcounts(goodLabels(:,1),edges); % number of clicks in each bin...
            % & vector telling which bin each element of goodLabels fall into
            
            % identify bins meeting the minClicks thresh; discard all
            % bins, clicks, and labels not meeting minClicks thresh
            if length(minClicks)==length(Labels)
                goodBins = find(bin_count > minClicks(iB));
            elseif length(minClicks)==1
                goodBins = find(bin_count > minClicks); % bins containing exceeding minClicks thresh
            end
            
            Lia = ismember(binInd,goodBins); % find which clicks fall into those bins exceeding minClicks thresh
            binInd(Lia==0) = []; % discard labels for clicks in bins with too few clicks
            clickInd(Lia==0) = [];
            goodLabels(Lia==0,:) = [];
            
            if isempty(clickInd)
                continue
            else
            % calculate normalized mean specs, ICI dists, & mean click envelopes
            % for good bins
            [g gN] = grp2idx(binInd);
            specs_cell = splitapply(@(x){x},MSP(clickInd,2:189),g);
            specMin = cellfun(@(x) min(x,[],2), specs_cell,'UniformOutput',false);
            normSpecs_cell = cellfun(@(A,B) A-B, specs_cell, specMin,'UniformOutput',false);
            specMax = cellfun(@(x) max(x,[],2), normSpecs_cell,'UniformOutput',false);
            normSpecs_cell = cellfun(@(A,B) A./B, normSpecs_cell, specMax,'UniformOutput',false);
            binSpecs = cellfun(@mean,normSpecs_cell,'UniformOutput',false);
            meanMin = cellfun(@(x) min(x,[],2), binSpecs,'UniformOutput',false);
            norm_binSpecs = cellfun(@(A,B) A-B, binSpecs, meanMin,'UniformOutput',false);
            meanMax = cellfun(@(x) max(x,[],2), norm_binSpecs,'UniformOutput',false);
            norm_binSpecs = cellfun(@(A,B) A./B, norm_binSpecs, meanMax,'UniformOutput',false);
            
            ICI = diff(MTT)*24*60*60;
            ICI(end+1) = NaN;
            ICI_cell = splitapply(@(x){x},ICI(clickInd),g);
            binICI_dists = cell2mat(cellfun(@(x) histcounts(x,0:.01:1),ICI_cell,'UniformOutput',false));
            ICImax = max(binICI_dists,[],2);
            %ICImax = cellfun(@max, binICI_dists,'UniformOutput',false);
            normICI_dists = binICI_dists./ICImax;
            %normICI_dists = cellfun(@(A,B) A./B, binICI_dists, ICImax,
            %'UniformOutput',false); %end up with NaNs when 0/0, not able
            %to easily replace with 0s in a cell array
            normICI_dists(isnan(normICI_dists)) = 0;
            normICI_dists = mat2cell(normICI_dists,ones(size(normICI_dists,1),1,1));
           
            if size(MSN,2)==200
                env = abs(hilbert(MSN(clickInd,:)'))';
            elseif size(MSN,2)==300
                env = abs(hilbert(MSN(clickInd,51:250)'))';
            end
            %envDur = sum(env>median(median(env)*5),2);
            %maxDur = size(env,2);
            env_cell = splitapply(@(x){x},env,g);
            %envDur_cell = splitapply(@(x){x},envDur,g);
            %envDur_dists = cellfun(@(x) histc(x,1:maxDur),envDur_cell,'UniformOutput',false);
            envMax = cellfun(@(x) max(x,[],2), env_cell,'UniformOutput',false);
            envMean = cellfun(@(A,B) mean(A./B), env_cell, envMax, 'UniformOutput',false);
            
            % get times of good clicks, grouped by bin
            ctimes = splitapply(@(x){x},MTT(clickInd,:),g);
            
            % store bin times, mean specs, ICI dists, & click times for this label
            binned_labels(iB).BinTimes = bin_vec(goodBins);
            binned_labels(iB).BinSpecs = norm_binSpecs;
            binned_labels(iB).ICI_dists = normICI_dists;
            binned_labels(iB).EnvShape = envMean;
            binned_labels(iB).ClickTimes = ctimes;
            end
        end
        
    end
    
    outName = strrep(TPWSlist(iA).name,'TPWS1',['binned_labels_',saveSuffix]);
    save(fullfile(outDir,outName),'binned_labels','p')
    
end

end





