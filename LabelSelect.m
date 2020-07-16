%% Flag bin-level labels for removal/retention before applying to individual 
% clicks (zID_from_bin_clusters). This script will plot concatenated spectra
% for each label sorted by peak frequency. Follow prompts to select bins on
% the plot and flag them 1 (keep) or 0 (discard).
% "data" struct generated by catCTbins
% should be in same directory as _predLab files
% OUTPUT: one labFlag file corresponding to each _predLab file, containing 
% a single matrix ("labFlag") consisting of two columns:
% 1st column: bin times of each spectrum in the corresponding _toClassify
% and _predLab files
% 2nd column: flag of 1 (keep) or 0 (discard)

labDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels2';
clasDir = 'F:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify';
suffix = '_clusters_PR95_PPmin120_toClassify.mat';
dataMat = 'HAT_B_01-03_BinsbyLabel_Thresh85'; % name of file containing "data" struct generated by catCTbins
load(fullfile(labDir,dataMat));

CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
    'CT5','CT8','Cuvier''s','Gervais''','HFA 15kHz','HFA 50kHz','HFA 70kHz',...
    'Kogia','MFA','MultiFreq Sonar','Risso''s','Sowerby''s','Sperm Whale',...
    'Spiky Sonar','True''s','Wideband Sonar'};
f = 5:0.5:98.5; % freq vector corresponding to spectra

%% Plot bins by label, sorted by peak frequency, and ask for user input to 
% determine how to flag labels

flagMat = struct('CT',[],'BinTimes',[],'Probs',[],'WhichCell',[],'File',[],'Flag',[]);
N = length(CTs);

for i = 1:N %for each CT, determine which labels to keep and which to flag
    
%     probs = vertcat(data(i).Probs);
%     [probs, I] = sortrows(probs);
    catSpecs = vertcat(data(i).BinSpecs);
    [~, maxind] = max(catSpecs,[],2);
    [B, I] = sortrows(maxind);
    catSpecs = catSpecs(I,:);
    probs = vertcat(data(i).Probs);
    probs = probs(I);
    ICI = vertcat(data(i).ICI);
    meanICI = mean(ICI,1);
    t = 0:.01:1;
    
    figure(1)
    subplot(1,4,1:3)
    imagesc([],f,catSpecs');
    set(gca,'ydir','normal');
    colormap(jet);
    ylabel('Frequency (kHz)');
    xlabel('Bin Number');
    title(CTs{i});
    set(gca,'fontSize',14);
    subplot(1,4,4)
    plot(t,meanICI,'LineWidth',2);
    grid on
    xticks([0 0.25 0.5 0.75 1]);
    xlabel('ICI (s)');
    ylabel('Normalized Counts');
    set(gca,'fontSize',14);
    
    a = [];
    b = [];
    
    while isempty(a)
        a = input('Enter 1 to keep all labels, 0 to discard all labels, or 2 to select bins to flag: ');
        if a~=1 && a~=0 && a ~=2
            fprintf('WARNING: Entry not allowed');
            a = []
        end
    end
    
    if a==1 || a==0
        flagMat(i).CT = data(i).CT;
        flagMat(i).BinTimes = data(i).BinTimes;
        flagMat(i).Probs = data(i).Probs;
        flagMat(i).WhichCell = data(i).WhichCell;
        flagMat(i).File = data(i).File;
        if a==1
            flagMat(i).Flag = repmat(1,size(data(i).BinTimes,1),1);
        else
            flagMat(i).Flag = repmat(0,size(data(i).BinTimes,1),1);
        end
        
    elseif a==2
        b = 1;
        indVec = [];
        while b==1
            c = [];
            fprintf('Double click single bin or click first and last of a range of bins to flag:\n');
            binSelect = ginput(2);
            sorted_ind = round(binSelect(1,1)):round(binSelect(2,1));
            ind = I(sorted_ind); % go from indices of bins sorted by prob back to indices of bins in "data" struct
            [Lia, Locb] = ismember(ind,indVec);
            if sum(Lia)>=1
                fprintf('WARNING: Some or all of the selected bin(s) already have flags which will be overwritten\n');
                indVec(Locb) = [];
                flagMat(i).BinTimes(Locb) = [];
                flagMat(i).Probs(Locb) = [];
                flagMat(i).WhichCell(Locb) = [];
                flagMat(i).File(Locb) = [];
                flagMat(i).Flag(Locb) = [];
            end
            indVec = [indVec,ind'];
            
            while isempty(c)
                c = input('Enter 1 to keep, 0 to discard label(s) for this selection: ');
                if c~=1 && c~=0
                    fprintf('WARNING: Entry not allowed');
                    c = []
                end
            end
            flagMat(i).CT = data(i).CT;
            flagMat(i).BinTimes = [flagMat(i).BinTimes; data(i).BinTimes(ind)];
            flagMat(i).Probs = [flagMat(i).Probs;data(i).Probs(ind)];
            flagMat(i).WhichCell = [flagMat(i).WhichCell; data(i).WhichCell(ind)];
            flagMat(i).File = [flagMat(i).File; data(i).File(ind)];
            if c==1
                flagMat(i).Flag = [flagMat(i).Flag; repmat(1,size(data(i).BinTimes(ind),1),1)];
            elseif c==0
                flagMat(i).Flag = [flagMat(i).Flag; repmat(0,size(data(i).BinTimes(ind),1),1)];
            end
            b = [];
            while isempty(b)
                b = input('Make another selection? Enter 1 for "yes", 0 for "no": ');
                if b~=1 && b~=0
                    fprintf('WARNING: Entry not allowed');
                    b = []
                end
            end
        end
        
        d = [];
        while isempty(d)
            d = input('Keep or discard remaining bin labels for this CT? Enter 1 for "keep", 0 for "discard": ');
            if d~=1 && d~=0
                fprintf('WARNING: Entry not allowed');
                d = []
            end
        end
        
        remInd = setdiff(1:size(data(i).BinTimes,1),indVec);
        flagMat(i).BinTimes = [flagMat(i).BinTimes; data(i).BinTimes(remInd)];
        flagMat(i).Probs = [flagMat(i).Probs;data(i).Probs(remInd)];
        flagMat(i).WhichCell = [flagMat(i).WhichCell; data(i).WhichCell(remInd)];
        flagMat(i).File = [flagMat(i).File; data(i).File(remInd)];
        flagMat(i).Flag = [flagMat(i).Flag; repmat(d,size(remInd,2),1)];
    end
    
    % Put bins back in chronological order
    [B, sortInd] = sortrows(flagMat(i).BinTimes);
    flagMat(i).BinTimes = flagMat(i).BinTimes(sortInd);
    flagMat(i).Probs = flagMat(i).Probs(sortInd);
    flagMat(i).WhichCell = flagMat(i).WhichCell(sortInd);
    flagMat(i).File = flagMat(i).File(sortInd);
    flagMat(i).Flag = flagMat(i).Flag(sortInd);
    
end

save(fullfile(labDir,'FlagMat_85'),'flagMat','-v7.3');

%% Construct labFlag files corresponding to each predLabels file based on flagMat

clasFiles = dir(fullfile(clasDir,'*toClassify.mat'));

times_unsorted = vertcat(flagMat.BinTimes); %times of bins jump from end of file back to start with each species
[times, I] = sortrows(times_unsorted); % put bins back in chronological order
files = vertcat(flagMat.File);
files = files(I);
flags = vertcat(flagMat.Flag);
flag = flags(I);
cells = vertcat(flagMat.WhichCell);
cells = cells(I);

for iA = 1:length(clasFiles) %for each toClassify file
    
    load(fullfile(clasDir,clasFiles(iA).name),'sumTimeMat');
    
    % get the name of the file
    stringGrab = clasFiles(iA).name;
    stringGrab = erase(stringGrab,suffix);
    
    % find bin times and corresponding flags for this file
    thisFile = strcmp(files,stringGrab);
    thisFileTimes = times(thisFile);
    thisFileFlags = flags(thisFile);
    thisFileCells = cells(thisFile);
    
    % add flags into labFlag matrix of all bin times in this file
    % any spectra without a flag in flagMat are automatically flagged 0
    % (i.e. single-click bins or spectra whose label confidences were < labelThresh)
    labFlag = sumTimeMat(:,1);
    
    iB = 1;
    while iB <= length(thisFileTimes) % how to vectorize this?
        r = find(thisFileTimes == thisFileTimes(iB)); % how many spectra from this bin were retained?
        q = find(labFlag == thisFileTimes(iB)); % indices of all spectra originally in this bin
        for iC = 1:length(r)
            cellInd = iB+iC-1;
            thisCell = q(thisFileCells(cellInd)); % index of original cell of this spectrum
            labFlag(thisCell,2) = thisFileFlags(cellInd);
        end
        iB = iB + length(r);
    end  
        
    saveName = strrep(clasFiles(iA).name,'toClassify','labFlag_85');
    save(fullfile(labDir,saveName),'labFlag','-v7.3');

end

