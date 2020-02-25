function analyze_array_RC

%loads all .cTg files of a folder, takes information of
%start and end of each click, opens the corresponding wave file and saves
%all clicks of each file into one .mat file.

%bandpass filters data, adjusts for transfer function, computes click
%paramters and finds slopes of pulses

%sbp 100211
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Settings
% Provide directories containing .cTg files and .wav files:
fileIndir = 'G:\TA_Vis\GU1703\Spice_metadata\Gg';
wavIndir = 'G:\TA_Vis\GU1703\Gg\4ch_wavs';

% Adjust # timeseries samples used based on known click durations:
offset = 100; % start this # samples before click onset
len = 400; % total number of samples to analyze for each click

%chan = input('Enter channel to analyze: ');
chan = 1;

%define FFT resolution for spectral calculation
binWidth_Hz = 200;

%% Begin Analysis
% get file names of .cTg files
d = dir(fullfile(fileIndir,'*.cHR'));
fileNames = char(d.name);

% get file names of .wav files
d = dir(fullfile(wavIndir,'*.wav'));
wavNames = char(d.name);

% define directory where .mat files should be saved
% saveDir = fileIndir;
saveDir = 'G:\TA_Vis\GU1703\Spice_metadata\Gg\Files_w_clickTimes_Noise';

% % choose transfer function for HARP
% str1 = 'Select Directory containing .tf transfer function for this HARP';
% indir = 'E:\Data\check for animals\';
% [tfFile tfDir] = uigetfile('*.tf',str1,indir);

%compute each wav file and its detections
for itr0 = 1:size(fileNames,1)  % for every .cTg file read data
    
    cd(fileIndir);

    token = fileNames(itr0,:);
    [clickStart,clickEnd,~] = textread(token,'%f %f %s');
    
    fprintf('Folder %1s: %2d clicks from file %3d of%4d to be analyzed\n', wavIndir,...
        length(clickStart), itr0, size(fileNames,1));
    
    if ~isempty(clickStart)
        
        wavFile = wavNames(itr0,:);
        cd(wavIndir)
        
        [y, fs] = audioread(wavFile);
        siz = length(y);
        NFFT = (fs)./binWidth_Hz;
        if rem(NFFT, 2) == 1
            NFFT = NFFT - 1;  % Avoid odd length of fft
        end
        
        %find if clickStart and clickEnd are far enough from start
        %and end of the wavFile to extract timeseries, otherwise disregard click
        clSamples = round(clickStart*fs); % Click start sample #s
        
        s = zeros(length(clSamples),1); % start sample # for each click
        e = zeros(length(clSamples),1); % end sample # for each click
        sN = zeros(length(clSamples),1); % noise start sample # for each click
        eN = zeros(length(clSamples),1); % noise end sample # for each click
        
        n = 1;
        for h = 1:length(clSamples)
            st = clSamples(h)-(offset);
            en = st + len;
            
            % Select noise samples (2.5 ms prior to click onset)
            strtN = clSamples(h)-(2.5*(fs/1000));
            endN = clSamples(h);
            
            if st > 0 && en < siz(1)
                s(n) = st;
                e(n) = en;
                sN(n) = strtN;
                eN(n) = endN;
            else
                s(n) = [];
                e(n) = [];
                sN(n) = [];
                eN(n) = [];
            end
            
            if st <= 0
                clickStart(n)=[];
                clickEnd(n)=[];
                n = n-1; %reduce number of clicks to one less if deleted
            end
            
            if strtN <= 0 && st > 0
                clickStart(n) = [];
                clickEnd(n) = [];
                n = n-1;
            end
            
            if en > siz(1)
                clickStart(n) = [];
                clickEnd(n) = [];
                n = n-1;
            end
            n = n+1; % increment one for next click
        end
        
        pos = [clickStart clickEnd];
        dur = (clickEnd-clickStart)*1000; %duration in ms
        %calculate inter-click interval
        pos1 = [pos(:,1);0];
        pos2 = [0;pos(:,1)];
        ici = pos1(2:end-1)-pos2(2:end-1);
        ici = ici*1000; %inter-click interval in ms
        
        yFilt = zeros(length(clickStart),401);
        yNFilt = zeros(length(clickStart),(eN(1)-sN(1))+1);
        
        peakFr = zeros(length(clickStart),1);
        bw10db = zeros(length(clickStart),3);
        bw3db = zeros(length(clickStart),3);
        F0 = zeros(length(clickStart),1);
        rmsSignal = zeros(length(clickStart),1);
        rmsNoise = zeros(length(clickStart),1);
        snr = zeros(length(clickStart),1);
        specClick = zeros(length(clickStart),NFFT/2);
        specNoise = zeros(length(clickStart),NFFT/2);
        slope = zeros(length(clickStart),2);
        nSamples = zeros(length(clickStart),1);
        
        cd(saveDir)
        % extract and filter timeseries of each click
        for itr1 = 1:length(clickStart)
       
            yClick = y(s(itr1):e(itr1),chan);
            yN = y(sN(itr1):eN(itr1),chan);
            
            % Bandpass filter click and noise timeseries:
            Fc1 = 500;
            FC2 = fs/2;
            [B,A] = butter(5,[Fc1/(fs/2), 0.99]);
            FiltClick = filtfilt(B,A,yClick)';
            FiltN = filtfilt(B,A,yN)';
            
            if ~isempty(FiltClick)
                yFilt(itr1,:) = FiltClick(1,:); % filtered click timeseries
                yNFilt(itr1,:) = FiltN(1,:); % filtered noise timeseries    
            else
                pos(itr1,:) = [];
                dur(itr1) = [];
                yFilt(itr1,:) = [];
                yNFilt(itr1,:) = [];
                peakFr(itr1) = [];
                bw10db(itr1,:) = [];
                bw3db(itr1,:) = [];
                F0(itr1) = [];
                Ppp(itr1) = [];
                rmsSignal(itr1) = [];
                rmsNoise(itr1) = [];
                snr(itr1) = [];
                specClick(itr1,:) = [];
                specNoise(itr1,:) = [];
                slope(itr1,:) = [];
                nSamples(itr1) = [];
            end
        end

        %save all extracted timeseries in file
        seq = strfind(wavNames(itr0,:), '.wav');
        newMatFile = ([wavNames(itr0,1:(seq-1)),'.mat']);
        save(newMatFile,'pos','dur','ici','yFilt','yNFilt','fs','NFFT','offset');
        
        fprintf('Clicks of file %1d out of %2d extracted and saved\n', itr0,...
            size(fileNames,1));
        
        %         %load transfer function
        %         tf=[tfDir,tfFile];
        %         [tfFreq,tfPower] = textread(tf,'%f %f'); %load transfer function
        %         F=1:1:fs/2;
        %         Ptf = interp1(tfFreq,tfPower,F,'linear','extrap');
        %         PtfN = downsample(Ptf,ceil(fs/N));
        %PtfN = [];
        
        % Compute spectra, calculate click parameters:
        
        [peakFr,bw10db,bw3db,F0,rmsSignal,rmsNoise,snrRMS,snrPP,ppSignal,...
            ppNoise,specClick,specNoise,f] = parameters_RC(yFilt,yNFilt,dur,fs,NFFT,offset);
        
        yFiltBuff = yFilt;
        rawInfo = wavNames(itr0,:);
%         rawStart = datetime([rawInfo(end-18:end-15),'-',rawInfo(end-14:end-13),'-',rawInfo(end-12:end-11)...
%             ' ',rawInfo(end-9:end-8),':',rawInfo(end-7:end-6),':',rawInfo(end-5:end-4),'.000'],...
%             'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
        rawStart = datetime([rawInfo(end-22:end-19),'-',rawInfo(end-18:end-17),'-',rawInfo(end-16:end-15)...
            ' ',rawInfo(end-13:end-12),':',rawInfo(end-11:end-10),':',rawInfo(end-9:end-8),'.',rawInfo(end-6:end-4)],...
            'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
        clickTimes = datenum(rawStart + seconds(sortrows(pos(:,1)))); % start datetime of each click
        noiseTimes = datenum(clickTimes - seconds(0.0025)); % start datetime of each noise sample
                
        cd(saveDir)
        %         save(newMatFile,'peakFr','bw10db','bw3db','F0','ppSignal','ppNoise', ...
        %             'rmsSignal','rmsNoise','snrRMS','snrPP','specClickTf','specNoiseTf','-append');]
        save(newMatFile,'peakFr','bw10db','bw3db','F0','f','ppSignal','ppNoise', ...
            'rmsSignal','rmsNoise','snrRMS','snrPP','f','yFiltBuff','clickTimes',...
            'noiseTimes','rawStart','specClick','specNoise','-append');
        fprintf('Click parameters of file %1d out of %2d extracted and saved\n', itr0,...
            size(fileNames,1));
        
        y = [];
        fs = [];
    end
end
