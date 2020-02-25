% Function to iterate over a set of directories, loop through multichannel
% wav files in each directory, and save desired channels to new files. This
% function was written to deal with variable channel numbers in SEFSC towed
% array data and will extract the data from the last two hydrophones (which
% should be 1 Reson, 1 APC Intl) for wav files with 4, 5, or 6 channels of
% data. Channels being saved can be adjusted by changing column numbers in
% lines 47/48, 55/56, and 64/65.
% RC 2/19

function s = read_chanX(inDir)

dirSet = dir(inDir); % get info about sub-directories
idx = ismember({dirSet.name},{'.', '..'});
idy = [dirSet.isdir]==0;
dirSet = dirSet(~(idx|idy));
lds = length(dirSet);

for itr0 = 1:lds % Loop through sub-directories
    
    thisDir = dirSet(itr0);
    cd(fullfile(inDir,thisDir.name));
    fileSet = dir('*.wav');
    
    % Create directories where HF (Reson) and MF (APC Intl) channels will be
    % saved
    outDirHF = fullfile(inDir,thisDir.name,'HF');
    outDirMF = fullfile(inDir,thisDir.name,'MF');
    
    if exist(outDirHF,'dir')~=7
        fprintf('Creating output directory %s\n',outDirHF)
        mkdir(outDirHF)
    end
    
    if exist(outDirMF,'dir')~=7
        fprintf('Creating output directory %s\n',outDirMF)
        mkdir(outDirMF)
    end
    
    j = 1;
    lfs = length(fileSet);
    
    fprintf('Beginning data extraction for directory %1d of %2d:\n', itr0, lds);
    tic
    
    for itr1 = 1:lfs %iterate through wave files
        
        thisFile = fileSet(itr1);
        info = audioinfo(thisFile.name); % get file info, including # channels
        [file, Fs] = audioread(thisFile.name); % read in audio data
        outNameHF = fullfile(outDirHF,thisFile.name); % full path to output HF file
        outNameMF = fullfile(outDirMF,thisFile.name); % full path to output MF file
        
        if info.NumChannels == 4 % 5-channel end array only; HPs 1, 2, 4, 5 recorded
            Res = file(:,3); % Data from HP 4
            APC = file(:,4); % Data from HP 5
            audiowrite(outNameHF,Res,Fs); % write Reson data to HF file
            audiowrite(outNameMF,APC,Fs); % write APC data to MF file
            fprintf('Done with file %1d of %2d\n',itr1,lfs);
            
        elseif info.NumChannels == 5 % 4-channel in-line array plus 5-channel end array;
            %HPs 1, 4, 5, 8, 9 recorded
            Res = file(:,4); % Data from HP 8
            APC = file(:,5); % Data from HP 9
            audiowrite(outNameHF,Res,Fs);
            audiowrite(outNameMF,APC,Fs);
            fprintf('Done with file %1d of %2d\n',itr1,lfs);
            
        elseif info.NumChannels == 6 % 4-channel in-line array plus 5-channel end array;
            %HPs 1, 4, 5, 6, 8, 9 recorded
            Res = file(:,5); %Data from HP 8
            APC = file(:,6); % Data from HP 9
            audiowrite(outNameHF,Res,Fs);
            audiowrite(outNameMF,APC,Fs);
            fprintf('Done with file %1d of %2d\n',itr1,lfs);
            
        else
            fprintf('Warning: Not equipped to handle number of channels detected\n  Skipping file %1d of %2d\n',itr1,lfs);
            s{j} = thisFile.name;
        end
        file = [];
    end
end
toc
end


