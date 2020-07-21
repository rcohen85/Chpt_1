%% Take mergedTypes output by make_ClusterLevel_trainSet_from_autoLabel_folders
% and simulate new examples for minority classes to improve classifier
% performance 

% directory containing MergedTypes file
inDir = 'I:\cluster_NNet\Set_w_Combos_HighAmp'; 

load(fullfile(inDir,'MergedTypes'));

type = 2; % row containing CT of interest in myTypeList
N = 5500; % total # examples needed (per class) to make train & test sets with no repeats

%% Add uniformly distributed noise to existing examples to create new examples
% calculate how many examples to simulate to reach N
n = abs(length(mergedTypes(type).clusterSpectra) - N);

% % calculate mean spectra, ICI, and waveform envelope for this type
% meanSpec = mean(vertcat(mergedTypes(type).clusterSpectra));
% meanICI = mean(vertcat(mergedTypes(type).clusterICI));
% meanEnv = mean(vertcat(mergedTypes(type).clusterEnv));

% generate smoothed white noise to be added to n existing examples
specNoise = movmean(rand(n,size(mergedTypes(type).clusterSpectra,2)).*0.1,5,2);
iciNoise = movmean(rand(n,size(mergedTypes(type).clusterICI,2)).*0.1,5,2);
envNoise = movmean(rand(n,size(mergedTypes(type).clusterEnv,2)).*0.1,5,2);
% % generate white noise to be added to n existing examples
% specNoise = rand(n,size(mergedTypes(type).clusterSpectra,2)).*0.1;
% iciNoise = rand(n,size(mergedTypes(type).clusterICI,2)).*0.1;
% envNoise = rand(n,size(mergedTypes(type).clusterEnv,2)).*0.1;


% % multiply by means to preserve variability in main peaks and tamp down
% % noise elsewhere
% specNoise = specNoise.*meanSpec;
% iciNoise = iciNoise.*meanICI;
% envNoise = envNoise.*meanEnv;

% randomly select bins to add noise to
templates = randsample(length(mergedTypes(type).clusterSpectra),n,false);

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
noisyICI = TemplateICIs + iciNoise;
noisyEnv = TemplateEnvs + envNoise;

% smooth noisy examples
% newSpecs = movmean(noisySpecs,5);

% normalize new examples
% normSpecs = newSpecs - min(newSpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);
normSpecs = noisySpecs - min(noisySpecs,[],2);
normSpecs = normSpecs./max(normSpecs,[],2);


%% Add Gaussian distributed noise to existing examples to create new examples
% calculate how many examples to simulate to reach N
n = abs(length(mergedTypes(type).clusterSpectra) - N);

% % calculate mean spectra, ICI, and waveform envelope for this type
% meanSpec = mean(vertcat(mergedTypes(type).clusterSpectra));
% meanICI = mean(vertcat(mergedTypes(type).clusterICI));
% meanEnv = mean(vertcat(mergedTypes(type).clusterEnv));

% generate smoothed white noise to be added to n existing examples
specNoise = movmean(0.02.*randn(n,size(mergedTypes(type).clusterSpectra,2))+0.05,5,2);
iciNoise = movmean(0.02.*randn(n,size(mergedTypes(type).clusterICI,2))+0.05,5,2);
envNoise = movmean(0.02.*randn(n,size(mergedTypes(type).clusterEnv,2))+0.05,5,2);
% % generate white noise to be added to n existing examples
% specNoise = 0.02.*randn(n,size(mergedTypes(type).clusterSpectra,2))+0.05;
% iciNoise = 0.02.*randn(n,size(mergedTypes(type).clusterICI,2))+0.05;
% envNoise = 0.02.*randn(n,size(mergedTypes(type).clusterEnv,2))+0.05;


% % multiply by means to preserve variability in main peaks and tamp down
% % noise elsewhere
% specNoise = specNoise.*meanSpec;
% iciNoise = iciNoise.*meanICI;
% envNoise = envNoise.*meanEnv;

% randomly select bins to add noise to
templates = randsample(length(mergedTypes(type).clusterSpectra),n,false);

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
noisyICI = TemplateICIs + iciNoise;
noisyEnv = TemplateEnvs + envNoise;

% smooth noisy examples
newSpecs = movmean(noisySpecs,5);

% normalize new examples
normSpecs = newSpecs - min(newSpecs,[],2);
normSpecs = normSpecs./max(normSpecs,[],2);
% normSpecs = noisySpecs - min(noisySpecs,[],2);
% normSpecs = normSpecs./max(normSpecs,[],2);


%% Randomly select from actual distribution of values in each spectral/ICI/env bin
% to assemble new spectra/ICI dists/mean envelopes

n = abs(length(mergedTypes(type).clusterSpectra) - N);

specs = vertcat(mergedTypes(type).clusterSpectra);
ici = vertcat(mergedTypes(type).clusterICI);
env = vertcat(mergedTypes(type).clusterEnv);

% calculate distributions for each spectral/ICI/env bin
sEdges = 0:0.01:1;
sN = zeros(length(sEdges)-1,size(specs,2));
for i = 1:size(specs,2)
[sN(:,i) sEdges] = histcounts(specs(:,i), sEdges);
end

iEdges = 0:0.01:1;
iN = zeros(length(iEdges)-1,size(ici,2));
for i = 1:size(specs,2)
[iN(:,i) iEdges] = histcounts(ici(:,i), iEdges);
end

sEdges = 0:0.01:1;
sN = zeros(length(sEdges)-1,size(specs,2));
for i = 1:size(specs,2)
[sN(:,i) sEdges] = histcounts(specs(:,i), sEdges);
end

