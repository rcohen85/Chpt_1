%% Flag bin-level labels for removal/retention before applying to individual 
% clicks (zID_from_bin_clusters). This script will plot concatenated spectra
% for each label sorted by peak frequency. Follow prompts to select bins on
% the plot and flag them 1 (keep) or 0 (discard). Plots of all spectra for
% a given label, and those retained after flagging, will be saved.

% OUTPUT: one labFlag file corresponding to each _predLab file, containing 
% a single matrix ("labFlag") consisting of two columns:
% 1st column: bin times of each spectrum in the corresponding _toClassify
% and _predLab files
% 2nd column: flag of 1 (keep) or 0 (discard)
% "flagMat" struct which has as many rows as NNet labels, and these fields:
% CT - classes/click types the neural net sorted detections into
% NNet_Lab - number value of neural net label for each click type
% BinTimes - start times of bins to which each (retained) label was applied
% BinSpecs - mean bin spectra 
% ICI - ICI distributions 
% Env - mean waveform envelopes
% File - cluster/toClassify/predLab file each bin comes from
% WhichCell - which mean spectra within the cell was this label applied to
% Probs - label confidence
% Flag - "1" for labels to keep, "0" for labels to discard
% NOTE: single click bins and spectra whose label confidence < labelThresh
% (or NaN label confidence) are excluded from the "flagMat" struct

clearvars

% directory containing toClassify files
clasDir = 'J:\JAX_D_14\clusterBins\ToClassify';
suffix = '_clusters_PR95_PPmin120_toClassify.mat';
% directory containing label files 
labDir = 'J:\JAX_D_14\clusterBins\ToClassify\labels';
% directory to save "flagMat" struct and plots
savDir = 'J:\JAX_D_14\clusterBins\ToClassify\labels';

NNlab = 0:19; % neural net label values
labelThresh = 0; % only labels exceeding this confidence thresh will be saved and plotted
specInd = 1:188; % indices of spectra in toClassify files
iciInd = 190:290; % indices of ICI dists in toClassify files
envInd = 292:491; % indices of mean waveform envelopes in toClassify files
f = 5:0.5:98.5; % freq vector corresponding to spectra
t = 0:.01:1; % time vector corresponding to ICI distributions

% Label names for titling plots; same order as NNlab above
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4/6+CT10',...
    'CT5','CT8','Cuvier''s','Gervais''','GoM\_Gervais''','HFA','Kogia',...
    'MFA','MultiFreq\_Sonar','Risso''s','SnapShrimp','Sowerby''s',...
    'Sperm Whale','True''s'};
% Label names for saving plots; same order as NNlab above; can't have
% forbidden characters like + or /
savname = {'Blainvilles','Boats','CT11','CT2+CT9','CT3+CT7','CT4_6+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM_Gervais','HFA','Kogia',...
    'MFA','MultiFreq_Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'};


%% Create flagMat struct with all mean spectra organized by label

% clasFiles = dir(fullfile(clasDir,'*toClassify.mat'));
% labFiles = dir(fullfile(labDir,'*predLab.mat'));
% nFiles = size(clasFiles,1);
% nn = length(NNlab);
% 
% % initialize struct to hold bin times, spectra, ICI dists, mean waveform 
% % envelopes, cell each spectrum occupies in cluster_bins output, 
% % label confidence, and deployment info, etc.
% flagMat = struct('CT',[],'NNet_Lab',[],'BinTimes',[],'BinSpecs',[],'ICI',[],...
%     'Env',[],'File',[],'WhichCell',[],'Probs',[],'nSpec',[],'Flag',[]);
% for i = 1:nn
%     flagMat(i).CT = savname{i};
%     flagMat(i).NNet_Lab = NNlab(i);
% end
% 
% % load one cluster & corresponding label file at a time, pull out desired
% % info for each NNet label
% for i=1:nFiles
%     load(fullfile(clasDir, clasFiles(i).name));
%     load(fullfile(labDir, labFiles(i).name));
%     
%     q = isnan(probs);
%     if sum(sum(q))>0
%     fprintf('WARNING: NaN label probabilities in %s, \nthese labels will not be retained.\n',labFiles(i).name);
%     fprintf('Press any key to continue:\n');
%     pause
%     end
%     
%     stringGrab = clasFiles(i).name;
%     stringGrab = erase(stringGrab,suffix);
%     
%     for j=1:nn
%         % find bins labeled with target label, with prob > labelThresh
%         labInd = find(predLabels==NNlab(j));
%         labInd = labInd(probs(labInd,j)>=labelThresh);
%         
%         % If high confidence labels exist, find times of labeled bins
%         if ~isempty(labInd)
%             if exist('toClassify')
%                 labTime = sumTimeMat(labInd,1);
%                 labSpec = toClassify(labInd,specInd);
%                 labICI = toClassify(labInd,iciInd);
%                 labEnv = toClassify(labInd,envInd);
%                 labFile = cellstr(repmat(stringGrab,length(labInd),1,1));
%                 labCell = whichCell(labInd);
%                 labProbs = probs(labInd,j);
%                 nSpec = nSpecMat(labInd);
%             else
%                 fprintf('Error: Don''t recognize variable names\n');
%                 return
%             end
%             
%             flagMat(j).BinTimes = [flagMat(j).BinTimes;labTime];
%             flagMat(j).BinSpecs = [flagMat(j).BinSpecs;labSpec];
%             flagMat(j).ICI = [flagMat(j).ICI;labICI];
%             flagMat(j).Env = [flagMat(j).Env;labEnv];
%             flagMat(j).File = [flagMat(j).File;labFile];
%             flagMat(j).WhichCell = [flagMat(j).WhichCell;labCell];
%             flagMat(j).Probs = [flagMat(j).Probs;labProbs];
%             flagMat(j).nSpec = [flagMat(j).nSpec;nSpec];
%         end
%         
%     end
%     fprintf('Done with file %d of %d\n',i,nFiles);
% end
% 
% % Sort bins into chronological order within each label, repeated bins are ordered based on values of WhichCell
% for j = 1:nn
%     times_unsorted = [vertcat(flagMat(j).BinTimes),vertcat(flagMat(j).WhichCell)];
%     [B, sortInd] = sortrows(times_unsorted); 
%     
%     flagMat(j).BinTimes = flagMat(j).BinTimes(sortInd);
%     flagMat(j).BinSpecs = flagMat(j).BinSpecs(sortInd,:);
%     flagMat(j).ICI = flagMat(j).ICI(sortInd,:);
%     flagMat(j).Env = flagMat(j).Env(sortInd,:);
%     flagMat(j).File = flagMat(j).File(sortInd,:);
%     flagMat(j).WhichCell = flagMat(j).WhichCell(sortInd);
%     flagMat(j).Probs = flagMat(j).Probs(sortInd);
%     flagMat(j).nSpec = flagMat(j).nSpec(sortInd);
% end
% 
% % save(fullfile(labDir,['FlagMat_' num2str(labelThresh*100)]),'flagMat','labelThresh','f','t','-v7.3');
% 
%% Plot bins by label, sorted by peak frequency, and ask for user input to 
% % determine how to flag labels

temp = struct('CT',[],'BinTimes',[],'WhichCell',[],'Flag',[]);

N = length(CTs);

for i = [10,11,18]%1:N %for each CT, determine which labels to keep and which to flag
    if ~isempty(flagMat(i).BinTimes)
        catSpecs = vertcat(flagMat(i).BinSpecs);
        [~, maxind] = max(catSpecs,[],2);
        [B, I] = sortrows(maxind);
        catSpecs = catSpecs(I,:);
        probs = vertcat(flagMat(i).Probs);
        probs = probs(I);
        ICI = vertcat(flagMat(i).ICI);
        meanICI = mean(ICI,1);
        
        figure(1); clf
        subplot(2,4,1:3)
        imagesc([],f,catSpecs');
        set(gca,'ydir','normal');
        colormap(jet);
        ylabel('Frequency (kHz)');
        xlabel('Bin Number');
        title(CTs{i});
        set(gca,'fontSize',14);
        subplot(2,4,4)
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
                fprintf('WARNING: Entry not allowed\n');
                a = [];
            end
        end
        
        if a==1 || a==0
            temp(i).BinTimes = flagMat(i).BinTimes;
            temp(i).WhichCell = flagMat(i).WhichCell;
            if a==1
                temp(i).Flag = repmat(1,size(flagMat(i).BinTimes,1),1);
            else
                temp(i).Flag = repmat(0,size(flagMat(i).BinTimes,1),1);
            end
            
        elseif a==2
            b = 1;
            indVec = [];
            while b==1
                c = [];
                fprintf('Double click single bin or click first and last of a range of bins to flag:\n');
                binSelect = ginput(2);
                sorted_ind = round(binSelect(1,1)):round(binSelect(2,1));
                ind = I(sorted_ind); % go from indices of bins sorted by prob back to indices of bins in "flagMat" struct
                [Lia, Locb] = ismember(ind,indVec);
                if sum(Lia)>=1
                    fprintf('WARNING: Some or all of the selected bin(s) already have flags which will be overwritten\n');
                    Locb = Locb(Locb~=0);
                    indVec(Locb) = [];
                    temp(i).BinTimes(Locb) = [];
                    temp(i).WhichCell(Locb) = [];
                    temp(i).Flag(Locb) = [];
                end
                indVec = [indVec,ind'];
                
                while isempty(c)
                    c = input('Enter 1 to keep, 0 to discard label(s) for this selection: ');
                    if isempty(c) || (c~=1 && c~=0)
                        fprintf('WARNING: Entry not allowed\n');
                        c = [];
                    end
                end
                temp(i).CT = flagMat(i).CT;
                temp(i).BinTimes = [temp(i).BinTimes; flagMat(i).BinTimes(ind)];
                temp(i).WhichCell = [temp(i).WhichCell; flagMat(i).WhichCell(ind)];
                if c==1
                    temp(i).Flag = [temp(i).Flag; repmat(1,size(flagMat(i).BinTimes(ind),1),1)];
                elseif c==0
                    temp(i).Flag = [temp(i).Flag; repmat(0,size(flagMat(i).BinTimes(ind),1),1)];
                end
                b = [];
                while isempty(b)
                    b = input('Make another selection? Enter 1 for "yes", 0 for "no": ');
                    if isempty(b) || (b~=1 && b~=0)
                        fprintf('WARNING: Entry not allowed\n');
                        b = [];
                    end
                end
            end
            
            d = [];
            while isempty(d)
                d = input('Keep or discard remaining bin labels for this CT? Enter 1 for "keep", 0 for "discard": ');
                if isempty(d) || (d~=1 && d~=0)
                    fprintf('WARNING: Entry not allowed\n');
                    d = [];
                end
            end
            
            remInd = setdiff(1:size(flagMat(i).BinTimes,1),indVec);
            temp(i).BinTimes = [temp(i).BinTimes; flagMat(i).BinTimes(remInd)];
            temp(i).WhichCell = [temp(i).WhichCell; flagMat(i).WhichCell(remInd)];
            temp(i).Flag = [temp(i).Flag; repmat(d,size(remInd,2),1)];
        end
        
        % Put bins back in chronological order, plug flags into flagMat
        times_unsorted = [vertcat(temp(i).BinTimes),vertcat(temp(i).WhichCell)];
        [B, sortInd] = sortrows(times_unsorted);
        temp(i).BinTimes = temp(i).BinTimes(sortInd);
        temp(i).WhichCell = temp(i).WhichCell(sortInd);
        temp(i).Flag = temp(i).Flag(sortInd);
        
        flagMat(i).Flag = temp(i).Flag;
        
        % Plot specs flagged 1, sorted by peak freq
        catSpecs_keep = vertcat(flagMat(i).BinSpecs(flagMat(i).Flag==1,:));
        [~, maxind] = max(catSpecs_keep,[],2);
        [C, Ix] = sortrows(maxind);
        catSpecs_keep = catSpecs_keep(Ix,:);
        ICI_keep = vertcat(flagMat(i).ICI(flagMat(i).Flag==1,:));
        meanICI_keep = mean(ICI_keep,1);
        
        subplot(2,4,5:7)
        imagesc([],f,catSpecs_keep');
        set(gca,'ydir','normal');
        colormap(jet);
        ylabel('Frequency (kHz)');
        xlabel('Bin Number');
        title('Flagged to Keep');
        set(gca,'fontSize',14);
        subplot(2,4,8)
        plot(t,meanICI_keep,'LineWidth',2);
        grid on
        xticks([0 0.25 0.5 0.75 1]);
        xlabel('ICI (s)');
        ylabel('Normalized Counts');
        set(gca,'fontSize',14);
        
        e = input('Enter to save plot and continue' );
        
        % Save both catSpec plots
        saveas(gcf,fullfile(savDir,[savname{i} '_Thresh' num2str(labelThresh*100)]),'tiff');
    end
end

save(fullfile(labDir,['FlagMat_' num2str(labelThresh*100)]),'flagMat','labelThresh','f','t','-v7.3');

%% Construct labFlag files corresponding to each predLabels file based on flagMat

fprintf('Creating labFlag files\n');

clasFiles = dir(fullfile(clasDir,'*toClassify.mat'));

times_unsorted = [vertcat(flagMat.BinTimes),vertcat(flagMat.WhichCell),... %times of bins jumps from end of file back to start with each species
    vertcat(flagMat.Flag)];
[times, I] = sortrows(times_unsorted); % put bins back in chronological order; repeated bins are ordered based on values of WhichCell
cells = times(:,2);
flags = times(:,3);
files = vertcat(flagMat.File);
files = files(I);
% flag = flags(I);
% cells = cells(I);

for iA = 1:size(clasFiles,1) %for each toClassify file
        
        load(fullfile(clasDir,clasFiles(iA).name),'sumTimeMat');
        
        % get the name of the file
        stringGrab = clasFiles(iA).name;
        stringGrab = erase(stringGrab,suffix);
        
        % find bin times and corresponding flags and cells for this file
        newFile = strcmp(files,stringGrab);
        thisFileTimes = times(newFile,1);
        thisFileFlags = flags(newFile);
        thisFileCells = cells(newFile);
        
        if ~isempty(thisFileTimes)
            % add flags into labFlag matrix of all bin times in this file
            % any spectra without a flag in flagMat are automatically flagged 0
            % (i.e. single-click bins or spectra whose label confidences were < labelThresh)
            labFlag = sumTimeMat(:,1);
%             labFlag(:,2) = 0;
            
            iB = 1;
            while iB <= length(thisFileTimes) % how to vectorize this?
                r = find(thisFileTimes == thisFileTimes(iB)); % how many spectra from this bin were retained?
                q = find(labFlag == thisFileTimes(iB)); % indices of all spectra originally in this bin in toClassify & predLab files
                for iC = 1:length(r)
                    cellInd = iB+iC-1;
                    thisCell = q(thisFileCells(cellInd)); % index of original cell of this spectrum
                    labFlag(thisCell,2) = thisFileFlags(cellInd);
                end
                iB = iB + length(r);
            end
            
            name = strrep(clasFiles(iA).name,'toClassify',['labFlag_' num2str(labelThresh*100)]);
            save(fullfile(labDir,name),'labFlag','labelThresh','-v7.3');
        end
end


%% Combine labFlag files
% 
% flagFiles = dir(fullfile(labDir,['*labFlag_' num2str(labelThresh*100),'_new.mat']));
% newDir = fullfile(labDir,'New_labFlags');
% mkdir(newDir);
% 
% for iA = 1:size(flagFiles,1)
%     
%     newFile = flagFiles(iA).name;
%     oldFile = strrep(newFile, '_new.mat', '.mat');
%     
%     orig = load(fullfile(labDir,oldFile));
%     new = load(fullfile(labDir,newFile));
%     labFlag = orig.labFlag(:,1);
%     labFlag(:,2) = orig.labFlag(:,2) + new.labFlag(:,2);
%     labFlag(labFlag(:,2)>0,2) = 1;
%     
%     save(fullfile(newDir,oldFile),'labFlag','labelThresh','-v7.3');
% end




