%% Take mergedTypes output by make_ClusterLevel_trainSet_from_autoLabel_folders
% and simulate new examples for minority classes to improve classifier
% performance 
clearvars

% directory containing MergedTypes file
inDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp'; 

load(fullfile(inDir,'MergedTypes'));

type = 3; % row containing CT of interest in myTypeList
N = 1833; % total # examples needed (per class) to make train & test sets with no repeats
f = 5:0.5:98.5; % freq vector corresponding to spectra
t = 0:.01:1; % time vector corresponding to ICI distributions

%% Add Gaussian distributed noise to existing examples to create new examples

% calculate how many examples to simulate to reach N
n = N - size(mergedTypes(type).clusterSpectra,1);

if n <= 0
    fprintf('Real examples already equal/exceed number needed, exiting script\n');
    return
end

% generate smoothed white noise to be added to n existing examples
specNoise = movmean(0.025.*randn(n,size(mergedTypes(type).clusterSpectra,2)),4,2);
iciNoise = movmean(0.025.*randn(n,size(mergedTypes(type).clusterICI,2)),4,2);
envNoise = movmean(0.025.*randn(n,size(mergedTypes(type).clusterEnv,2)),4,2);

% randomly select bins to add noise to
if n<size(mergedTypes(type).clusterSpectra,1)
    templates = randsample(size(mergedTypes(type).clusterSpectra,1),n,false);
else
    templates = randsample(size(mergedTypes(type).clusterSpectra,1),n,true);
end

templateSpecs = mergedTypes(type).clusterSpectra(templates,:);
templateICIs = mergedTypes(type).clusterICI(templates,:);
templateEnvs = mergedTypes(type).clusterEnv(templates,:);

% multiply noise by templates to preserve variability in main peaks and tamp 
% down noise elsewhere
specNoise = specNoise.*templateSpecs;
iciNoise = iciNoise.*templateICIs;
envNoise = envNoise.*templateEnvs;

% add noise to templates
templateSpecs_lin = 10.^(templateSpecs./10); % do spectral addition in linear space
newSpecs_lin = templateSpecs_lin + specNoise;
noisySpecs = 10.*log10(abs(newSpecs_lin)); % revert spectra to dB
noisyICI = templateICIs + iciNoise;
noisyEnv = templateEnvs + envNoise;

% smooth noisy examples; don't bother smoothing ICI, dists are usually
% spiky
newSpecs = movmean(noisySpecs,3);
newEnv = movmean(noisyEnv,2);

% normalize new examples
normSpecs = newSpecs - min(newSpecs,[],2);
normSpecs = normSpecs./max(normSpecs,[],2);

normICI = noisyICI - min(noisyICI,[],2);
normICI = normICI./max(normICI,[],2);

normEnv = newEnv - min(newEnv,[],2);
normEnv = normEnv./max(normEnv,[],2);

% plot new examples and compare to real examples before adding to
% mergedTypes
realSpecs = vertcat(mergedTypes(type).clusterSpectra);
realICI = vertcat(mergedTypes(type).clusterICI);
realEnv = vertcat(mergedTypes(type).clusterEnv);

figure(1)
subplot(2,3,1)
imagesc([],f,realSpecs');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Frequency (kHz)');
title('Real Spectra')
subplot(2,3,2)
imagesc([],[],realEnv');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Sample #');
title('Real Waveform Envelopes')
subplot(2,3,3)
imagesc([],t,realICI');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Time (s)');
title('Real ICI Distributions')
subplot(2,3,4)
imagesc([],f,normSpecs');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Frequency (kHz)');
title('Simulated Spectra')
subplot(2,3,5)
imagesc([],[],normEnv');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Sample #');
title('Simulated Waveform Envelopes')
subplot(2,3,6)
imagesc([],t,normICI');set(gca,'ydir','normal')
xlabel('Bin')
ylabel('Time (s)');
title('Simulated ICI Distributions')

a = input('Enter 1 to save simulated examples in mergedTypes, 0 to end script without saving: ');

if a==1
    mergedTypes(type).clusterSpectra = [mergedTypes(type).clusterSpectra;normSpecs];
    mergedTypes(type).clusterICI = [mergedTypes(type).clusterICI;normICI];
    mergedTypes(type).clusterEnv = [mergedTypes(type).clusterEnv;normEnv];
    
    save(fullfile(inDir,'MergedTypes'),'mergedTypes','myTypeList');
    fprintf('Simulated examples added to mergedTypes and saved\n');
   
elseif a==0
    fprintf('WARNING: Simulated examples have not been added to mergedTypes or saved\n');
end

%% Add uniformly distributed noise to existing examples to create new examples
% % calculate how many examples to simulate to reach N
% n = abs(length(mergedTypes(type).clusterSpectra) - N);
% 
% % generate smoothed white noise to be added to n existing examples
% specNoise = movmean(rand(n,size(mergedTypes(type).clusterSpectra,2)).*0.1,5,2);
% iciNoise = movmean(rand(n,size(mergedTypes(type).clusterICI,2)).*0.1,5,2);
% envNoise = movmean(rand(n,size(mergedTypes(type).clusterEnv,2)).*0.1,5,2);
% 
% % randomly select bins to add noise to
% templates = randsample(length(mergedTypes(type).clusterSpectra),n,false);
% 
% templateSpecs = mergedTypes(type).clusterSpectra(templates,:);
% templateICIs = mergedTypes(type).clusterICI(templates,:);
% templateEnvs = mergedTypes(type).clusterEnv(templates,:);
% 
% % multiply noise by templates to preserve variability in main peaks and tamp 
% % down noise elsewhere
% specNoise = specNoise.*templateSpecs;
% iciNoise = iciNoise.*templateICIs;
% envNoise = envNoise.*templateEnvs;
% 
% % add noise to templates
% templateSpecs_lin = 10.^(templateSpecs./10); % do spectral addition in linear space
% newSpecs_lin = templateSpecs_lin + specNoise;
% noisySpecs = 10.*log10(abs(newSpecs_lin)); % revert spectra to dB
% noisyICI = templateICIs + iciNoise;
% noisyEnv = templateEnvs + envNoise;
% 
% % smooth noisy examples
% newSpecs = movmean(noisySpecs,5);
% newICI = movmean(noisyICI,2); % ICI dists shouldn't be as smooth as specs/envs
% newEnv = movmean(noisyEnv,5);
% 
% % normalize new examples
% normSpecs = newSpecs - min(newSpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);
% 
% normICI = newICI - min(newICI,[],2);
% normICI = normICI./max(normICI,[],2);
%
% normEnv = newEnv - min(newEnv,[],2);
% normEnv = normEnv./max(normEnv,[],2);

%% Randomly select from actual distribution of values in each spectral/ICI/env bin
% to assemble new spectra/ICI dists/mean envelopes
% n = abs(length(mergedTypes(type).clusterSpectra) - N);
% 
% specs = vertcat(mergedTypes(type).clusterSpectra);
% ici = vertcat(mergedTypes(type).clusterICI);
% env = vertcat(mergedTypes(type).clusterEnv);
% 
% % calculate distributions for each spectral/ICI/env bin
% Spd = cell(1,size(specs,2));
% for i = 1:size(specs,2)
%     Spd{i} = fitdist(specs(:,i),'Kernel');
% end
% 
% Ipd = cell(1,size(ici,2));
% for i = 1:size(ici,2)
%     Ipd{i} = fitdist(ici(:,i),'Kernel');
% end
% 
% Epd = cell(1,size(env,2));
% for i = 1:size(env,2)
%     Epd{i} = fitdist(env(:,i),'Kernel');
% end
% 
% 
% % take random draws from each spectral/ICI/env bin to construct new
% % examples
% newSpecs = zeros(n,size(specs,2));
% for i = 1:size(specs,2)
%     newSpecs(:,i) = abs(random(Spd{i},n,1));
% end
% 
% newICI = zeros(n,size(ici,2));
% for i = 1:size(ici,2)
%     newICI(:,i) = abs(random(Ipd{i},n,1));
% end
% 
% newEnv = zeros(n,size(env,2));
% for i = 1:size(env,2)
%     newEnv(:,i) = abs(random(Epd{i},n,1));
% end
% 
% % smooth simulated examples
% smoothSpecs = zeros(n,size(specs,2));
% smoothICI = zeros(n,size(ici,2)); % ICI dists shouldn't be as smooth as specs/envs
% smoothEnv = zeros(n,size(env,2));
% for i = 1:n
%     smoothSpecs(i,:) = movmean(newSpecs(i,:),5);
%     smoothICI(i,:) = movmean(newICI(i,:),2);
%     smoothEnv(i,:) = movmean(newEnv(i,:),5);
% end
% 
% % normalize new examples
% normSpecs = smoothSpecs - min(smoothSpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);
% 
% normSpecs = smoothSpecs - min(smoothSpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);
% 
% normSpecs = smoothSpecs - min(smoothSpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);
% 


