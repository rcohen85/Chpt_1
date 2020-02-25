%% Pull and characterize clicks and noise from desired TA or HARP encounter
% using detector metadata. Vector of noise sample start times needed.

clearvars
tic

spec = 'Gsp';
boutNo = 2;

TPWSdir = 'G:\HARP_Vis_Matches\NFC_A_02\TPWS';
% wavdir = 'G:\TA_Vis\GU1703\Gg\Recordings';
savdir = 'G:\HARP_Vis_Matches\Best_Bouts';
TPWSfile = 'NFC_A_02_TPWS1';
% wavFile = 'SEFSC_GU1703_SD500kHz4Ch_EAoil5mix_HP1245_20170709_183454_068.wav'; % click-free file for noise sample
% savFile = 'Gsp_BoutSpecs.mat';
zFD = 'NFC_A_02_FD1';

% Specify start and end time of interest:
boutst = datenum('2016-05-09 17:55:00');
boutend = datenum('2017-05-09 18:02:00');

% cd(wavdir)
% fid = fopen(wavFile);
% hdr = io_readWavHeader(wavFile,'_(\d*)_(\d*)');
% fclose(fid);

%% From TPWS files
cd(TPWSdir);
load(TPWSfile);
if ~isempty(zFD)
    load(zFD);
end

if (MTT(1) >= 1.4e+06)
    MTT = MTT - datenum(2000,00,00);
end

% Make sure clicks are sorted by time
[MTT ind] = sortrows(MTT);
MSP = MSP(ind,:);
MSN = MSN(ind,:);
MPP = MPP(ind);

% Calculate ICI from click times
clickICI = diff(MTT)*(60*60*24);

% Remove FD; if FD file isn't provided this step won't do anything
[tru_clickTimes tru_id] = setdiff(MTT(:,1),zFD);
tru_id = sortrows(tru_id);
tru_clickSn = MSN(tru_id,:);
tru_clickSpecs = MSP(tru_id,:);
tru_ICI = clickICI(tru_id(1:end-1));

% Identify clicks during desired bout
clst_ind = find(datenum(tru_clickTimes) >= boutst);
clst_ind = clst_ind(1);
clend_ind = find(datenum(tru_clickTimes) <= boutend);
clend_ind = clend_ind(end);

% Identify clipped clicks; don't really need this for HARP data, just TA
% noClip = [];
% for i = 1:length(tru_clickSn)
%     if iscell(tru_clickSn)
%         sn = tru_clickSn{i};
%     else
%         sn = tru_clickSn(i,:);
%     end
%     clip = find(abs(sn) > 0.95*(2^hdr.nBits)/2);
%     if isempty(clip)
%         noClip = [noClip;i];
%     end
% end

% Identify buzzes
keepFlag = ones(size(tru_clickTimes(:,1)));
iCT = 1;
while iCT <= size(tru_clickTimes,1)
    thisClickTime = tru_clickTimes(iCT(:,1));
    tDiff = (tru_clickTimes(:,1) - thisClickTime)*(60*60*24);
    echoes = find(tDiff <= 0.005 & tDiff > 0);
    keepFlag(echoes,1) = 0; % flag clicks close in time for deletion
    if isempty(echoes) % advance to next detection
        iCT = iCT +1;
    else % or if some were flagged, advance to next true detection
        iCT = echoes(end)+1;
    end
end
noBuzz = find(keepFlag==1);

% Pull only good clicks (not clipped, not in buzzes) from bout
% goodClicks = intersect(noClip,noBuzz);
% keepInd = intersect(goodClicks,clst_ind:clend_ind);
keepInd = intersect(noBuzz,clst_ind:clend_ind);

boutClickTimes = tru_clickTimes(keepInd);
boutClickSpecs = tru_clickSpecs(keepInd,:);
boutClickSn = tru_clickSn(keepInd,:);
boutICI = tru_ICI(keepInd(keepInd~=length(tru_clickTimes)));

%% If desired, load wave file to extract larger noise sample
% cd(wavdir)
% fid = fopen(wavFile);
% lgN = io_readWav(fid, hdr, 1, hdr.Chunks{1,2}.nSamples,...
%     'Units', 'samples','Channels', 1, 'Normalize', 'unscaled')';
% fclose(fid);
% 
% NFFT = ceil(hdr.fs * 2000 / 1E6);
% if rem(NFFT, 2) == 1
%     NFFT = NFFT - 1;  % Avoid odd length of fft
% end
% 
% % Bandpass filter the raw timeseries
% [B,A] = butter(5, [5000 95500]./(hdr.fs/2),'bandpass');
% filtNoise = filtfilt(B,A,lgN);
% 
% % Need to FFT data in chunks and then average
% s = spectrogram(filtNoise,hanning(NFFT),0,NFFT);
% lgNoiseSpec = 20*log10(abs(s));
% sub = 10*log10(hdr.fs/NFFT); % account for FFT bin width
% lgNoiseSub = lgNoiseSpec-sub;
% avgLgNoise = mean(lgNoiseSub,2);
% fnoise = linspace(0,hdr.fs./2000,NFFT./2+1);
% nf1 = find(fnoise==4.5);
% nf2 = find(fnoise==95.5);
% cf1 = find(f==4.5);
% cf2 = find(f==95.5);
% 
% lgN = []; % clear large var when done with it to free up memory
% 
% % Subtract noise from each click spectrum (needs to be done to
% % un-normalized spectra)
% lin_boutClickSpecs = 10.^(boutClickSpecs/20); % convert click spectra to linear space
% lin_avgNoise = 10.^(avgLgNoise/20); % convert average noise spectra to linear space;
% lincorr_clickSpecs = lin_boutClickSpecs(:,1:cf2) - lin_avgNoise(nf1:nf2)'; % subtract linear average noise spectra
% corr_clickSpecs = 20*log10(abs(lincorr_clickSpecs));
% 
% % Normalize click spectra to enable comparison within and across bouts
% normcorr_ClickSpecs = corr_clickSpecs - min(corr_clickSpecs,[],2);
% normcorr_ClickSpecs = normcorr_ClickSpecs./max(normcorr_ClickSpecs,[],2);
normcorr_ClickSpecs = boutClickSpecs - min(boutClickSpecs,[],2);
normcorr_ClickSpecs = normcorr_ClickSpecs./max(normcorr_ClickSpecs,[],2);
% 
% % Calculate average normalized click
% norm_avgClick = mean(normcorr_ClickSpecs);
% 
% % For shits, calculate avg click spectrum from un-normalized, clicks,subtract 
% % noise, and then normalize and compare to above
% avgClick = mean(boutClickSpecs);
% lin_avgClick = 10.^(avgClick/20); % convert average click spectra to linear space
% lincorr_avgClick = lin_avgClick(1:cf2) - lin_avgNoise(nf1:nf2)';
% corr_avgClick = 20*log10(abs(lincorr_avgClick)); % revert corrected click spectra to dB
% 
% suspect_avgClick = corr_avgClick - min(corr_avgClick);
% suspect_avgClick = suspect_avgClick./max(suspect_avgClick);

%% Plots 
cd(savdir);

% Plot average noise spectrum
% figure (1)
% plot(f(cf1:cf2),avgLgNoise(nf1:nf2),'LineWidth',2);
% xlabel('Frequency (Hz)');
% ylabel('Amplitude (dB)');
% title('Average Noise');
% xlim([5 96]);
% ylim([-10 50]);
% grid on
% saveas(gcf,sprintf('%s Bout %d Average Noise.tif',spec,boutNo),'tiff');
% 
% Plot normalized concatenated click spectra
figure(2)
% imagesc([],f(cf1:cf2),normcorr_ClickSpecs')
imagesc([],f,normcorr_ClickSpecs([1000:3300,4000:end],:)')
set(gca,'ydir','normal','fontSize',18);
xlabel('Click Number');
ylabel('Frequency (kHz)');
colormap(jet)
colorbar
saveas(gcf,sprintf('%s Bout %d Concatenated Spectra_minusJunkDetections.tif',spec,boutNo),'tiff');
% 
% % Plot corrected average click spectrum
% figure(3)
% plot(f(cf1:cf2),norm_avgClick,'LineWidth',2);
% % plot(f,norm_avgClick,'LineWidth',2);
% xlabel('Frequency (kHz)');
% ylabel('Normalized Amplitude');
% % title('Corrected Average Click');
% title('Average Click');
% xlim([5 96]);
% ylim([0 1]);
% grid on
% saveas(gcf,sprintf('%s Bout %d Average Click.tif',spec,boutNo),'tiff');
% 
% % Plot ICI histogram
% figure(4)
% histogram(boutICI,[0:0.005:0.3]);
% xlabel('ICI (sec)');
% ylabel('Count');
% saveas(gcf,sprintf('%s Bout %d ICI.tif',spec,boutNo),'tiff');

% Plot ICI over course of bout
figure(5)
plot(boutICI([1000:3300,4000:end],:),'.','MarkerSize',10);
ylim([0 0.3]);
xlim([0 size(boutICI([1000:3300,4000:end],:),1)]);
xlabel('Click Number');
ylabel('ICI (s)');
set(gca,'fontSize',18);
saveas(gcf,sprintf('%s Bout %d ICI_minusJunkDetections.tif',spec,boutNo),'tiff');

% Save normalized spectra (all individual, and also bout average), ICI
if exist(savFile) ~= 2
    avgClicks = {};
    BoutSpecs = {};
    BoutICI = {};
    fvec = {};
    avgClicks = [avgClicks;norm_avgClick];
    BoutSpecs = [BoutSpecs;normcorr_ClickSpecs];
    BoutICI = [BoutICI;boutICI];
    fvec = [fvec;f(1:cf2)];
%     fvec = [fvec;f];
    save(savFile,'avgClicks','BoutSpecs','BoutICI','fvec');
elseif exist(savFile) == 2
    load(savFile);
%     avgClicks = [avgClicks;norm_avgClick];
%     BoutSpecs = [BoutSpecs;normcorr_ClickSpecs];
    BoutICI = [BoutICI;boutICI];
%     fvec = [fvec;f(cf1:cf2)];
%     fvec = [fvec;f];
    save(savFile,'avgClicks','BoutSpecs','BoutICI','fvec');
end

toc
%% If loading detector output from .mat files instead of TPWS
% % Load .mat files of detected clicks, noise samples, and FD; if bout spans 
% % more than one .mat file, combine data from several .mat files
% 
% %load('Gsp_192_FD1.mat');
% zFD = [];
% load('Gsp_20130819_180126.mat'); 
% % If clickTimes are in seconds from start of wave file, need to convert to
% % full datetime by adding to file start time
% f1st = datetime(2013,08,19,18,01,26);
% Cdnum = datenum(seconds(clickTimes(:,1)) + f1st);
% Ndnum = datenum(seconds(noiseTimes(:,1)) + f1st);
% clickICI = diff(clickTimes);
% 
% x = load('Gsp_20130819_180716.mat','clickTimes','yFiltBuff','specClickTf',...
%     'noiseTimes','yNFilt','specNoiseTf');
% f2st = datetime(2013,08,19,18,07,16);
% x.Cdnum = datenum(seconds(clickTimes(:,1)) + f2st);
% x.Ndnum = datenum(seconds(noiseTimes(:,1)) + f2st);
% x.clickICI = diff(x.clickTimes);
% 
% clickTimes = [clickTimes;vertcat(x.clickTimes)];
% yFiltBuff = [yFiltBuff;vertcat(x.yFiltBuff)];
% specClickTf = [specClickTf;vertcat(x.specClickTf)];
% noiseTimes = [noiseTimes;vertcat(x.noiseTimes)];
% yNFilt = [yNFilt;vertcat(x.yNFilt)];
% specNoiseTf = [specNoiseTf;vertcat(x.specNoiseTf)];
% Cdnum = [Cdnum;x.Cdnum];
% Ndnum = [Ndnum;x.Ndnum];
% clickICI = [clickICI;x.clickICI];
% 
% % Remove FD
% [tru_clickTimes tru_id] = setdiff(Cdnum(:,1),zFD);
% tru_clickSn = yFiltBuff(tru_id,:);
% tru_clickSpecs = specClickTf(tru_id,:);
% tru_ICI = clickICI(tru_id);
% % This only works when you have as many noise samples as clicks
% % tru_noiseTimes = noiseTimes(tru_id);
% % tru_noiseSn = yNFilt(tru_id,:);
% % tru_noiseSpecs = specNoiseTf(tru_id,:);
% 
% % Identify clicks and noise samples during desired bout
% clst_ind = find(datenum(tru_clickTimes) >= boutst);
% clst_ind = clst_ind(1);
% clend_ind = find(datenum(tru_clickTimes) <= boutend);
% clend_ind = clend_ind(end);
% 
% nst_ind = find(datenum(noiseTimes) >= boutst);
% nst_ind = nst_ind(1);
% nend_ind = find(noiseTimes <= boutend);
% nend_ind = nend_ind(end);
% 
% boutClickSpecs = tru_clickSpecs(clst_ind:clend_ind,:);
% boutClickSn = tru_clickSn(clst_ind:clend_ind,:);
% boutICI = tru_ICI(clst_ind:clend_ind);
% boutNoiseSpecs = specNoiseTf(nst_ind:nend_ind,:);
% boutNoiseSn = yNFilt(nst_ind:nend_ind,:);
% 
% % Calculate average click and noise spectra and noise percentiles
% avgClick = mean(boutClickSpecs);
% lin_boutNoiseSpecs = 10.^(boutNoiseSpecs/20); % convert noise to liner space
% lin_avgNoise = mean(lin_boutNoiseSpecs); % average noise in linear space
% avgNoise = 20*log10(abs(lin_avgNoise));
% N = prctile(boutNoiseSpecs,[25, 50, 75],1);
% lin_avgNoise = 10.^(avgLgNoise/20);

% Plot average click and noise spectra and noise percentiles
% figure(2);clf
% hold on
% plot(f(1:cf2),avgClick(1:cf2),'LineWidth',2)
% plot(f,avgNoise,'LineWidth',2)
% plot(f,N(1,:),'LineWidth',2)
% plot(f,N(2,:),'LineWidth',2)
% plot(f,N(3,:),'LineWidth',2)
% plot(f(1:cf2),avgLgNoise(nf1:nf2),'LineWidth',2)
% hold off
% ylim([-10 45]);
% xlim([5 96]);
% xlabel('Frequency (kHz)');
% ylabel('Amplitude');
% legend('Average Click','Average Noise','25th Percentile','50th Percentile',...
%     '75th Percentile','Location','southwest');
% % legend('Average Click','Average Noise','Location','southwest');
% grid on
% 


%% Generate & Plot ICIgram

% % Calculate icigram
% boutDtimes = datetime(boutClickTimes,'ConvertFrom','datenum');
% boutdur = seconds(boutDtimes(end) - boutDtimes(1)); % bout duration (seconds)
% winstep = 10; % 10-second icigram time bins
% nwins = ceil(boutdur/winstep); % # of time bins needed to span bout
% st = boutDtimes(1);
% 
% winEdges = st;
% for i = 1:nwins
%     winEdges(i+1) = st+seconds(winstep*i);
% end
% 
% binEdges = [0:0.005:0.3]; %ICI histogram bin limits
% binCounts = []; % concatenated ICI histograms
% for i = 1:nwins
%     idx = find(boutDtimes >= winEdges(i) & boutDtimes < winEdges(i+1));
%     h = histogram(boutICI(idx),binEdges);
%     binCounts(:,i) = h.BinCounts;
% end
% 
% normbinCounts = binCounts - min(binCounts);
% normbinCounts = normbinCounts ./ max(normbinCounts); % normalized concatenated ICI hists

% % Plot ICIgram
% figure(7)
% imagesc(datenum(winEdges(1:end-1)),binEdges(1:end-1),normbinCounts);
% set(gca,'ydir','normal');
% datetick;
% xlim(datenum([winEdges(1) winEdges(end-1)]));
% colorbar
% colormap(jet)
% caxis([0 1]);
% xlabel('Time');
% ylabel('Inter-Click-Interval (s)');
% title('ICIgram');
