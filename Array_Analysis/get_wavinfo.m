%% Function to retrieve 

function x = get_wavinfo(inDir)

cd(inDir);
files = dir('*.wav');
lfs = length(files);

for i = 1:lfs
    
     thisWave = files(i).name;
     info = audioinfo(thisWave);
     x.File_Name(i) = {thisWave};
     x.Num_Channels(i) = info.NumChannels;
     x.Fs(i) = info.SampleRate;
     x.Num_Samples(i) = info.TotalSamples;
     x.Duration(i) = info.Duration;
     x.BitsPerSample(i) = info.BitsPerSample;
end

q = unique(x.Fs);

fprintf('Sampling rate(s): %d\n',q);

end