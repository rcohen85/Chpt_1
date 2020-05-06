% Looks at binned labeled click data output by bin_labeled_clicks and
% determines start/end times of encounters with each label
% inDir - directory containing binned_labels files
% binSize - bin duration in minutes
% maxGap - maximum alloweable gap between clicks to consider them part of
% the same encounter
% minBout - minimum duration of an encounter

function boutTimes = aggregate_encounter_times(inDir,binSize,maxGap,minBout)

fileList = dir(fullfile(inDir,'*binned_labels_3min.mat'));
boutTimes = struct('ClickType',[],'NumBouts',{},'BoutStarts',[],...
        'BoutEnds',[],'BoutDurs',[],'WhichFile',{});
    
for iA = 1:length(fileList)
    
    fileName = fileList(iA).name;
    load(fullfile(inDir,fileName));
    
    for iB = 1:size(binned_labels,2)
        
        if iA == 1
            boutTimes(iB).ClickType = binned_labels(iB).ClickType;
        end
        
        if ~isempty(binned_labels(iB).BinTimes)
            binTimes = binned_labels(iB).BinTimes;
            dt = diff(binTimes*24*60); % time between bin starts (minutes)
            gapTimes = find(dt > maxGap); % start indices of gaps
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
            
            fileName_rep = repmat(fileName,nb,1);
            fileName_cell = mat2cell(fileName_rep,repmat(1,size(fileName_rep,1),1));

            boutTimes(iB).NumBouts = sum(boutTimes(iB).NumBouts) + nb;
            boutTimes(iB).BoutStarts = [boutTimes(iB).BoutStarts; sb];
            boutTimes(iB).BoutEnds = [boutTimes(iB).BoutEnds; eb];
            boutTimes(iB).BoutDurs = [boutTimes(iB).BoutDurs; boutDur];
            boutTimes(iB).WhichFile = [boutTimes(iB).WhichFile;fileName_cell];    
            
        elseif isempty(binned_labels(iB).BinTimes)
            
            boutTimes(iB).NumBouts = sum(boutTimes(iB).NumBouts);
            
        end
    end
    fprintf('Done with file %d of %d\n',iA,length(fileList));
end
    outName = 'BoutTimes_3min';
    save(fullfile(inDir,outName),'boutTimes');
end