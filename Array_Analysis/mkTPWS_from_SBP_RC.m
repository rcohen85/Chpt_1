% mkTPWS.m

% CAUTION: This script can produce multi-GB files if you have large numbers
% of clicks in one directory

% Script takes output from Simone/Marie's click detector and puts it into
% a format for use in detEdit.
% Expects standard HARP xwav drive directory structure.


% Output:
% A TTPP.m file containing 5 variables:
%   MTT: An Nx2 vector of detection start and end times, where N is the
%   number of detections
%   MPP: An Nx1 vector of recieved level (RL) amplitudes.
%   MSP: An NxF vector of detection spectra, where F is dictated by the
%   parameters of the fft used to generate the spectra and any
%   normalization preferences.
%   MSN:?? click waveform ??
%   f = An Fx1 frequency vector associated with MSP

clearvars

% Setup variables:
baseDir = 'H:\Melissa_array_data\Rough-tootheddolphin\RecSys_2_MF\triton_det_output'; % directory containing de_detector output
outDir = 'H:\Melissa_array_data\Rough-tootheddolphin\RecSys_2_MF\triton_det_output\TPWS'; % directory where you want to save your TPWS files
speciesName = 'Sb'; % species name, only used to name the output file
recsys = 'MF';
ppThresh = 0; % minimum RL in dBpp. If detections have RL below this
% threshold, they will be excluded from the output file. Useful if you have
% an unmanageable number of detections.
%tf = 'I:\HI_tfs\406_070717\406_070717_invSensit.tf' % transfer function path


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if the output file exists, if not, make it
if exist(outDir,'dir')~=7
    fprintf('Creating output directory %s',outDir)
    mkdir(outDir)
end

maxRows = 300000; % maximum number of clicks per file

N=512;

MTT = zeros(maxRows,1);
MPP = zeros(maxRows,1);
MSP = zeros(maxRows,N);
MSN = zeros(maxRows,1600);
f = [];
dirSet = dir(baseDir);


[~,outName] = fileparts(outDir);

fileSet = what(baseDir);
lfs = length(fileSet.mat);

pos = [];
specClick = [];
ppSignal = [];
yFilt = [];

matIdxStart = 1;
for itr2 = 1:lfs
    thisFile = fileSet.mat(itr2);
    
    load(fullfile(baseDir,char(thisFile)),'-mat','pos','rawStart',...
        'ppSignal','fs','yFilt','specClick')
    
    if ~isempty(pos)
        
        % Prune detections with low received level if needed.
        keepers = find(ppSignal >= ppThresh);
        
        pos = pos(keepers,:);
        % assuming all click times in pos vector are relative to
        % file start time, calculate click time as matlab datenum
        fileStartDnum = datenum(rawStart, 'yyyymmdd_HHMMSS');
        
        % calculate detection times based on associated raw file start:
        % ATTN: Calculating detection times.
        % This assumes that times in the position vector "pos"
        % are relative to the start time of the first raw file.
        posDnum = fileStartDnum + (pos(:,1)/(24*60*60));
        
        matIdxEnd = matIdxStart+length(keepers)-1;
        if matIdxEnd> size(MTT,1)
            disp('Have to add more rows')
            % have to add more rows
            MTT = [MTT;...
                zeros(matIdxEnd-size(MTT,1),size(MTT,2))];
            MPP = [MPP;zeros(matIdxEnd-size(MPP,1),size(MPP,2))];
            MSN = [MSN;...
                zeros(matIdxEnd-size(MSN,1),size(MSN,2))];
            MSP = [MSP;...
                zeros(matIdxEnd-size(MSP,1),size(MSP,2))];
        end
        
        
        % store to vectors:
        MTT(matIdxStart:matIdxEnd) = posDnum;
        MPP(matIdxStart:matIdxEnd) = ppSignal(keepers);
        MSP(matIdxStart:matIdxEnd,:) = specClick(keepers,:);
        MSN(matIdxStart:matIdxEnd,:) = yFilt(keepers,:);
        
        matIdxStart = matIdxEnd + 1; % update startIndx for next time.
        
        if isempty(f) % calculate frequency vector to go with spectra
            f = 0:(fs/(2*1000))/(size(specClick,2)-1):(fs/(2*1000));
        end
        
        posDum = [];
        specClick = [];
        ppSignal = [];
        yFilt = [];
        
        fprintf('Done with file %d of %d \n',itr2,lfs)
    end
    
    if (matIdxEnd>= maxRows && (lfs-itr2>=10)) || itr2 == lfs
        % get rid of unused preallocated rows
        dataRows = MTT>0;
        MTT = MTT(dataRows,:);
        MPP = MPP(dataRows,:);
        MSP = MSP(dataRows,:);
        MSN = MSN(dataRows,:);
        
        % time to dump data to file
        if itr2 == lfs %&& letterFlag == 0
            % we're on the last file and haven't used up any
            % letters
            %ttppOutName =  [fullfile(outDir,dirSet(itr0).name),'_TPWS1','.mat'];
            ttppOutName =  strcat(outDir,'\',speciesName,'_',recsys,'_TPWS1','.mat');
            %fprintf('Done with directory %d of %d \n',itr0,length(dirSet))
            %subTP = 1;
        else
            % we are dumping before reaching last file in
            % folder, so use a letter code
            %ttppOutName = [fullfile(outDir,dirSet(itr0).name),char(letterCode(subTP)),'_TPWS1','.mat'];
            ttppOutName = strcat(outDir,'\',speciesName,'_',recsys,'_TPWS1','.mat');
            %subTP = subTP+1;
            %letterFlag = 1;
        end
        save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3')
        
        MTT = zeros(maxRows,1);
        MPP = zeros(maxRows,1);
        MSP = zeros(maxRows,256);
        MSN = zeros(maxRows,800);
        
        matIdxStart = 1;
        matIdxEnd = matIdxStart;
        
    end
    
end