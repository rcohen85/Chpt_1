function [yFiltClick, yNFiltClick]=extractFilterTimeseries ...
    (wavNames,wavDir,clickStart,a,n,fs,offset,N)

cd(wavDir)
wavFile=wavNames(a,:);
clSamples=round(clickStart*fs);
% 
% start n(offset) samples before calculated start
s=clSamples(n)-(offset+1);

% end 512 samples after start, + xx extra
if offset == 200
    e=s+799;
else
    e=s+1599;
end

% start 1050 samples before calculated start for noise samples
if offset == 200
     sN=clSamples(n)-1050;
     eN=clSamples(n);
else
    sN=clSamples(n)-1599;
    eN=clSamples(n);
end

%get click samples
y = audioread(wavFile,[s e]);
y=y(:,1); %picks channel 1: so this is the one you select the tranfer function for
y = y.';

%get noise samples
yN = audioread(wavFile,[sN eN]);
yN=yN(:,1);
yN = yN.';

% bandpass filter y and yN
Fc1 = 5000;   % First Cutoff Frequency
Fc2 = fs/2;

order = 10;     % Order
%[B,A] = butter(order/2, [Fc1/(fs/2) Fc2/(fs/2)]);
[B,A] = butter(order/2, [Fc1/(fs/2) 0.99]);
yFiltClick = filtfilt(B,A,y); %filter click
yNFiltClick = filtfilt(B,A,yN); %filter noise before click

