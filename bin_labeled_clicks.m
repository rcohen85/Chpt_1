% Loop through TWPS and associated ID1 files, bin labeled clicks and
% calculate mean spectra and ICI dist per bin

function [binned_labels] = bin_labeled_clicks(inDir,outDir,Labels,binSize,minClicks,minPP)

TPWSlist = dir(fullfile(inDir,'*TPWS1.mat'));
labelList = dir(fullfile(inDir,'*ID1.mat'));

if size(TPWSlist,1) ~= size(labelList,1)
    fprintf('Warning: input file mismatch; make sure each TPWS1 file has an ID1 file\n');
    x = input('Press Enter to continue, or CtrlC to stop function\n');
end

for iA = 1:size(TPWSlist,1)  % TPWS index
    
    fprintf('Binning TPWS %d of %d\n',iA,size(TPWSlist,1));
    
    % Load TPWS and associated labels
    load(fullfile(inDir,TPWSlist(iA).name),'MTT','MSP','MPP');
    load(fullfile(inDir,labelList(iA).name));
    
    % Determine bin start/end times
    [yr, mon, day, hr, min, sec] = datevec(zID(1,1));
    st = datenum([yr,mon,day,hr,min,0]);
    [yr, mon, day, hr, min, sec] = datevec(zID(end,1));
    min = min+1;
    e = datenum([yr,mon,day,hr,min,0]);
    
    bin_inc = binSize/(60*24);
    bin_vec = (st:bin_inc:e)';
    
    % For each label, determine which clicks belong to each bin, test for
    % minPP and minClick thresholds, then calculate mean spectra and ICI
    % dist for each bin
    binned_labels = struct('ClickType',[],'BinTimes',[],'BinSpecs',[],'ICI_dists',[],'ClickTimes',[]);
    
    for iB = 1:size(Labels,1)  % label index
        
        binned_labels(iB).ClickType = Labels(iB,1);
        
        % get times of this label
        labelInd1 = zID(:,2)==cell2mat(Labels(iB,2));
        thisLabel = zID(labelInd1,:);
        
        if isempty(thisLabel)
            continue
        else
            % find clicks in TPWS and remove clicks below minPP threshold,
            % then find remaining clicks in thisLabel
            [~, clickInd, ~] = intersect(MTT,thisLabel(:,1));
            clickInd(MPP(clickInd) <= minPP) = [];                          % good click indices in TPWS vars
            [~, ~, labelInd2] = intersect(MTT(clickInd),thisLabel(:,1));
            goodLabels = thisLabel(labelInd2,:);                            % labels of good clicks
            
            % divvy clicks into bins
            edges = [bin_vec; bin_vec(end)+bin_inc];
            [bin_count, ~, binInd] = histcounts(goodLabels(:,1),edges);
            
            % identify bins meeting the minClicks thresh; discard all
            % clicks and labels not meeting minClicks thresh
            goodBins = find(bin_count > minClicks(iB));
            Lia = ismember(binInd,goodBins);
            binInd(Lia==0) = [];
            clickInd(Lia==0) = [];
            goodLabels(Lia==0,:) = [];
            
            % calculate mean specs & ICI dists for good bins
            [g gN] = grp2idx(binInd);
            specs_cell = splitapply(@(x){x},MSP(clickInd,:),g);
            binSpecs = cellfun(@mean,specs_cell,'UniformOutput',false);
            
            ICI = diff(MTT)*24*60*60;
            ICI(end+1) = NaN;
            ICI_cell = splitapply(@(x){x},ICI(clickInd),g);
            wrapper = @(x) histcounts(x,0:.01:.6); % create wrapper on histcounts so second argument
            % is already supplied when called by cellfun
            binICI_dists = cellfun(wrapper,ICI_cell,'UniformOutput',false);
            
            % get times of good clicks, grouped by bin
            ctimes = splitapply(@(x){x},MTT(clickInd,:),g);
            
            % store bin times, mean specs, ICI dists, & click times for this label
            binned_labels(iB).BinTimes = bin_vec(goodBins);
            binned_labels(iB).BinSpecs = binSpecs;
            binned_labels(iB).ICI_dists = binICI_dists;
            binned_labels(iB).ClickTimes = ctimes;
        end
        
    end
    
    outName = strrep(TPWSlist(iA).name,'TPWS1','binned_labels');
    save(fullfile(outDir,outName),'binned_labels','p')
    
end

end


 
 
 
 