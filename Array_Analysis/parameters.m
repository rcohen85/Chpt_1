function [peakFr,bw10db,bw3db,F0,rmsSignal,rmsNoise,snrRMS,snrPP,ppSignal,ppNoise ...
                ,specClick] = parameters_RC(yFilt,yNFilt, ...
                dur,fs,N,offset,PtfN)

%Take timeseries out of existing file and apply transfer function
%1) calculate spectra, compute peak, center frequency and bandwidth
%2) calculate signal to noise ratio
%3) calculate signal peak to peak: copied from tfParametersArray.m in
%analyze_HARP_100203

%sb 100211

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1) calculate spectra, compute compute click parameters
specClick=zeros(size(yFilt,1),N);
specNoise=zeros(size(yNFilt,1),N);

%analysis of one click after the other
for s=1:size(yFilt,1)               

    %pick yFilt as defined by teager energy duration + 30 pts on each side
    durClick=dur(s);
    posStart=offset-29; %timeseries has n(offset) points picked before start of yFilt
%     posEnd=round(offset+1+(durClick/1000)*fs+30);
    posEnd=round(offset+1+(durClick/1000)+30);
    
    if posEnd-posStart>N
        posEnd=offset-30+N;
    end
    
    wind=hann(posEnd-posStart+1);
    wClick=[]; % windowed click
    wClick=yFilt(s,(posStart:posEnd)).*wind.';
    noZero=N-length(wClick);
    addZeros=zeros(noZero,1).';
    wClick=[wClick addZeros];
    spClick=20*log10(abs(fft(wClick,N)));
    
    %pick N points of noise and window
    N2=301;
    windNoise=hann(N2);
    wNoise=yNFilt(s,(end-99-N2:end-100)).*windNoise.';
    spNoise=20*log10(abs(fft(wNoise,N)));

    specClick(s,:)=spClick;
    specNoise(s,:)=spNoise;
end

%account for bin width
sub=10*log10(fs/N);
specClick=specClick-sub;
specNoise=specNoise-sub;

%reduce data to first half of spectra
specClick=specClick(:,1:N/2);
specNoise=specNoise(:,1:N/2);

% %preallocate
% specClickTf=zeros(size(specClick,1),size(specClick,2));
% specNoiseTf=zeros(size(specNoise,1),size(specNoise,2));
% %add transfer function
% for i=1:size(specClick,1)
%     specClickTf(i,:)=specClick(i,:)+PtfN;
%     specNoiseTf(i,:)=specNoise(i,:)+PtfN;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute parameters of yFilt
peakFr=zeros(size(yFilt,1),1);
bw10db=zeros(size(yFilt,1),3);
bw3db=zeros(size(yFilt,1),3);
F0=zeros(size(yFilt,1),1);

%analysis of one yFilt after the other
for n=1:size(specClick,1)%(specClickTf,1)          
    
    %specClick=specClickTf(n,:);
    spClick = specClick(n,:);
%     noise=specNoiseTf(n,:);
    
    %%%%%
    %calculate peak frequency
    %max value in the first half samples of the spectrogram within
    %10-100 kHz
    f=0:((fs/2)/1000)/((N/2)-1):((fs/2)/1000);
    [valMx posMx]=max(spClick);

    %calculation from spectrogram -> from 0 to 100kHz in 256 steps (FFT=512)
    peakFr(n,1)=(fs/2)*posMx/(length(spClick)); %peak frequency in kHz
    
    %%%%%
    %calculate bandwidth
    
    %-3dB bandwidth   
    %calculation of -3dB bandwidth - amplitude associated with the halfpower points of a pressure pulse (see Au 1993, p.118); 
    low=valMx-3; %p1/2power = 10log(p^2max/2) = 20log(pmax)-3dB = 0.707*pmax; 1/10^(3/20)=0.707

    %walk along spectrogram until low is reached on either side
    slopeup=fliplr(spClick(1:posMx));
    slopedown=spClick(posMx:round(length(spClick)));

    for e3dB=1:length(slopeup)
       if slopeup(e3dB)<low %stop at value < -3dB: point of lowest frequency
           break
       end
    end


    for o3dB=1:length(slopedown)
       if slopedown(o3dB)<low %stop at value < -3dB: point of highest frequency
           break
       end
    end


    %-10dB bandwidth
    low=valMx-10;

    %walk along spectrogram until low is reached on either side
    slopeup=fliplr(spClick(1:posMx));
    slopedown=spClick(posMx:end);
 
    for e10dB=1:length(slopeup)
       if slopeup(e10dB)<low %stop at value < -10dB: point of lowest frequency
           break
       end
    end


    for o10dB=1:length(slopedown)
       if slopedown(o10dB)<low %stop at value < -10dB: point of highest frequency
           break
       end
    end


    %calculation from spectrogram -> from 0 to 100kHz in 256 steps (FFT=512)
    high3dB=(fs/(2*1000))*((posMx+o3dB)/(length(spClick))); %-3dB highest frequency in kHz
    low3dB=(fs/(2*1000))*(posMx-e3dB)/(length(spClick)); %-3dB lowest frequency in kHz
    high10dB=(fs/(2*1000))*((posMx+o10dB)/(length(spClick))); %-10dB highest frequency in kHz
    low10dB=(fs/(2*1000))*(posMx-e10dB)/(length(spClick)); %-10dB lowest frequency in kHz
    bw3=high3dB-low3dB;
    bw10=high10dB-low10dB;
    
    bw3db(n,1)=low3dB;
    bw3db(n,2)=high3dB;
    bw3db(n,3)=bw3;
    
    bw10db(n,1)=low10dB;
    bw10db(n,2)=high10dB;
    bw10db(n,3)=bw10;
    
    %%%%%
    %calculate further yFilt parameters
    
    %frequency centroid (or center frequency) in kHz
    linearSpec=10.^(spClick/20);
    Freq_vec=0:(fs/2)/(length(linearSpec)-1):0.5*fs;
    F0(n)=(sum(Freq_vec.*linearSpec(1:length(linearSpec)).^2)/sum(linearSpec(1:length(linearSpec)).^2))/1000; % Au 1993, equation 10-3

%     %RMS bandwidth in kHz
%     nc_msbandw=(sum(Freq_vec.^2.*linearSpec(1:length(linearSpec)).^2)/sum(linearSpec(1:length(linearSpec)).^2)); % Au 1993, equation 10-4
%     ms_bandw=nc_msbandw-F0(n).^2; % Au 1993, equation 10-6
%     %nc_rmsbandw=sqrt(nc_msbandw);
%     rmsBandw(n)=(sqrt(ms_bandw))/1000; % Root of mean square bandwidth -> RMS
% 
%     %time centroid in s = centroid of the time waveform
%     yFiltDur=dur(n)/1000;
%     tClick=floor(yFiltDur*fs);
%     t=0:yFiltDur/(tClick-1):yFiltDur;
%     t0(n)=sum(t.*tClick.^2)/sum(tClick.^2); % Au 1993, equation 10-29
% 
%     %rms duration in s
%     rmsDuration(n)=sqrt(sum((t-t0(n)).^2.*tClick.^2)/sum(tClick.^2));
% 
%     %time bandwidth product
%     timeBandw(n)=rmsDuration(n)*rmsBandw(n);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %possibly bandpass filter noise for rms noise calculation
%bandpass filter from 25 to 75 kHz
Fc1 = 5000;   % First Cutoff Frequency
Fc2 = 70000;  % Second Cutoff Frequency

order = 10;     % strong
[B,A] = butter(order/2, [Fc1 Fc2]/(fs/2)); 

for i=1:size(yNFilt,1)
    yN=yNFilt(i,:);
    yN = filtfilt(B,A,yN); %filter noise
    yNFilt(i,:)=yN;
end

%calculate rms level of signal and noise
n = length(yNFilt);
yrmsNoise=zeros(size(yNFilt,1),1);
rmsNoise=zeros(size(yNFilt,1),1);
for i=1:size(yNFilt,1)
    yrmsNoise(i) = sqrt(sum(yNFilt(i,:).*yNFilt(i,:))/n);
    rmsNoise(i) = 20*log10(yrmsNoise(i));
end

%calculate rms level of signal
%signal starts at tsFiltCountAll(101,:) and has duration(i)
yrms=zeros(size(yFilt,1),1);
rmsSignal=zeros(size(yFilt,1),1);
for i=1:size(yFilt,1)
    n = round((dur(i)/1000)*fs);
    if n>355
        n=355;
    end
    yrms(i) = sqrt(sum(yFilt(i,(101:101+n)).*yFilt(i,(101:101+n)))/n);
    rmsSignal(i) = 20*log10(yrms(i));
end

snrRMS=rmsSignal-rmsNoise;

%convert normalized timeseries into counts for calculation of absolute
%values (eg RLpp)
click=yFilt*2^15; % array needs 2^15, HARP needs 2^14
noise=yNFilt*2^15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calculate RLpp at peak frequency: find min/max value of timeseries,
%convert to dB, add transfer function value of peak frequency (should come
%out to be about 9dB lower than value of spectra at peak frequency)

%find lowest and highest number in timeseries (counts) and add those
high=max(click.');
low=min(click.');
highNoise=max(noise.');
lowNoise=min(noise.');
ppCount=high+abs(low);
ppNoiseCount=highNoise+abs(lowNoise);

%calculate dB value of counts and add transfer function value at peak
%frequency to get ppSignal and ppNoise (dB re 1uPa)
P=20*log10(ppCount);
pNoise=20*log10(ppNoiseCount);

ppSignal=zeros(length(peakFr),1);
ppNoise=zeros(length(peakFr),1);

for i=1:length(peakFr)
    %take each peak frequency and find closest f in frequency vector
    peakLow=floor(peakFr(i));
    if peakLow == (fs/2)/1000
        fLow = N/2;
    else
    fLow=find(f>peakLow);
    end
    
%     %add PtfN transfer function at peak frequency to P
%     tfPeak=PtfN(fLow(1));
%     ppSignal(i)=P(i)+tfPeak;
%     ppNoise(i)=pNoise(i)+tfPeak; 
      ppSignal(i) = P(i);
      ppNoise(i) = pNoise(i);
end

% to represent correct sound pressure levels on a plot of ambient noise levels, calculate
%-10 dB bandwidth and add 10 log (bandwidth) to ppSignal and ppNoise
%old method
% for i=size(bw10db,1)
%     add=10*log(bw10db(n,3));
%     Ppp(i)=Ppp(i)+add;
%     PppNoise(i)=PppNoise(i)+add;
% end
%method from analyze_HARP_sbp100203
bw10log=10*log10(bw10db(:,3)*1000);
% bw10log=bw10log.';
ppSignal=ppSignal+bw10log;
ppNoise=ppNoise+bw10log;

% signal to noise ratio from Ppp levels(at peak frequency)
snrPP=[];
snrPP=ppSignal-ppNoise;
           