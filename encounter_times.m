%% DEFUNCT: USE AGGREGATE_ENCOUNTER_TIMES

function [boutTimes] = encounter_times(inDir,binSize,minGap,minBout)

boutTimes = struct('ClickType',[],'NumBouts',[],'BoutStarts',[],...
        'BoutEnds',[],'BoutDurs',[],'WhichFile',{});

fileList = dir(fullfile(inDir,'*binned_labels*.mat'));

for iA = 1:length(fileList)
    
    load(fullfile(inDir,fileList(iA).name));
    CTnum = size(binned_labels,2);
        
    for iB = 1:CTnum
        
        if isempty(binned_labels(iB).BinTimes)
            boutTimes(iB).ClickType = binned_labels(iB).ClickType;
            boutTimes(iB).NumBouts = [boutTimes(iB).NumBouts0;
            boutTimes(iB).BoutStarts = [];
            boutTimes(iB).BoutEnds = [];
            boutTimes(iB).BoutDurs = [];
            boutTimes(iB).WhichFile = [];
            continue
        else
            binTimes = binned_labels(iB).BinTimes;
            dt = diff(binTimes*24*60); % time between bin starts (minutes)
            gapTimes = find(dt > minGap); % start indices of gaps
            sb = [binTimes(1);binTimes(gapTimes+1)];   % start time of bout
            eb = [binTimes(gapTimes);binTimes(end)]+(binSize/(24*60));   % end time of bout
            boutDur = (eb - sb)*24*60; % bout duration (minutes)
            
            if ~isempty(minBout)
                bdI = find(boutDur > minBout);
                boutDur = boutDur(bdI);
                sb = sb(bdI);
                eb = eb(bdI);
                nb = length(sb);
            end
            
            boutTimes(iB).ClickType = binned_labels(iB).ClickType;
            boutTimes(iB).NumBouts = nb;
            boutTimes(iB).BoutStarts = sb;
            boutTimes(iB).BoutEnds = eb;
            boutTimes(iB).BoutDurs = boutDur;
            boutTimes(iB).WhichFile = cellstr(repmat(fileList(iA).name,nb,1));
        end
    end
    outName = strrep(fileList(iA).name,'binned_labels','boutTimes');
    save(fullfile(inDir,outName));
end
end