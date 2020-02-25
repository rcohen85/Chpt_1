% recalcSpec_TPWS.m

% Script takes TPWS with long (BW) timeseries and spectra, trims time
% series, recalculates spectra, resaves MTT, MSN, MSP, MPP, and f to TPWS1
% of same name as original.
% Output:

% A TPWS1.m file containing 4 variables:
%   MTT: An Nx2 vector of detection start and end times, where N is the
%   number of detections
%   MPP: An Nx1 vector of recieved level (RL) amplitudes.
%   MSP: An NxF vector of detection spectra, where F is dictated by the
%   parameters of the fft used to generate the spectra and any
%   normalization preferences.
%   f = An Fx1 frequency vector associated with MSP

clearvars

% Setup variables:
inDir = 'F:\Melissa_array_data\Recalc_TPWS'; % directory containing TPWS files
fileSet = dir(inDir);
% fileSet = fullSet(fileSet.name~='.' && fileSet.name~='..'); %trying to
% get it to ignore anything in fileSet other than TPWS files
% ~strcmp(dirSet(itr0).name,'.')

for itr0 = 1:length(fileSet)
    
    thisFile = fileSet(itr0);
    load(char(fullfile(inDir,thisFile.name)),'MSN','MPP','MTT',...
        'MSP','f')

    MSN = MSN(:,500:900);
    
    fs_ind = strfind(thisFile.name,'kHz');
    fs = str2double(thisFile.name(fs_ind-3:fs_ind-1)).*1000; % Hz
    binWidth_Hz = 100;
    NFFT = (fs)./binWidth_Hz;
    
    if rem(NFFT, 2) == 1
        NFFT = NFFT - 1;  % Avoid odd length of fft
    end
    
    fftWindow = hann(size(MSN,2))';
    f = 0:binWidth_Hz:((fs)/2);
    wClick = zeros(1,length(fftWindow));
    
    % account for bin width
    sub = 10*log10(fs/NFFT);
        
    MSP = zeros(size(MSN,1), NFFT/2);
    
    for itr1 = 1:size(MSN,1)
        
        thisClick = MSN(itr1,:);
        
        wClick = thisClick.*fftWindow;
        
        spClick = 20*log10(abs(fft(wClick,NFFT)));
        spClickSub = spClick-sub;
        
        %reduce data to first half of spectra
        spClickSub = spClickSub(1:length(spClick)/2);
        
        MSP(itr1,:) = spClickSub;
        
    end
    
    if f(end)> 100000
        maxf_ind = find(f==100000);
        MSP = MSP(:,1:maxf_ind);
    end
    
    ttppOutName = [fullfile(inDir,thisFile.name)];

    save(ttppOutName,'MTT','MPP','MSP','MSN','f','-v7.3');
    
    fprintf('Done with file %d of %d \n',itr0,length(fileSet));
        
    MTT = [];
    MPP = [];
    MSP = [];
    MSN = [];
    
end