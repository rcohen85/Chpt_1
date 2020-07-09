%% Concatenate labeled clicks to compare consistency of combined click types

% Sort clicks by label; do this separately for each project/region that was
% independently clustered, as the labels will be particular to that run

% Load TPWS & label files 
clearvars
TPWSdir = 'I:\WAT_BS_01\TPWS';
labelDir = 'I:\WAT_BS_01\TPWS';
% saveName = 'NFC_CTs';

TPWSList = dir([TPWSdir,'\*_TPWS1.mat']);
%labelList = dir([labelDir,'\*_predLab.mat']);
labelList = dir([labelDir,'\*_ID1mat']);

CTs = {};

% Loop through files and add to the CTs array
ct_ind = [];
for i = 1:length(labelList)
    fprintf('Getting clicks from file %d of %d\n',i,length(labelList)) 
    
    %load([labelDir,'\',labelList(i).name],'predLabels');
    load([labelDir,'\',labelList(i).name],'zID');
    load([TPWSdir,'\',TPWSList(i).name],'MSP','MSN','MTT');
    nCTs = unique(predLabels); 
    ici = diff(MTT)*60*60*24;
    
    % each row of CTs will contain click spectra, time series, and ICI for one
    % click type
    for j = 1:length(nCTs)
        ind = find(predLabels==nCTs(j));
        if length(ind) <= 5000  
            k = length(ind);
        else
            k = 5000; % grab a subset of the labeled clicks to moderate file size
        end
        ct_ind = sort(datasample(ind,k,'Replace',false));
        if i==1
            CTs{j,1} = nCTs(j);
            CTs{j,2} = MSP(ct_ind,:);
            CTs{j,3} = ici(ct_ind);
            CTs{j,4} = MSN(ct_ind,:);
        else
            CTs{j,2} = [CTs{j,2};MSP(ct_ind,:)];
            CTs{j,3} = [CTs{j,3};ici(ct_ind)];
            CTs{j,4} = [CTs{j,4};MSN(ct_ind,:)];            
        end
        ct_ind = [];
    end
    predLabels = [];
    MTT = [];
    MSP = [];
    MSN = [];
    
end

CTs = cell2struct(CTs,{'NN_Label','Spectra','ICI','Timeseries'},2);
% save(saveName,'CTs','-v7.3');
%% Plot concatenated clicks for each click label
% clearvars
project = 'WAT\_BS\_01';
saveDir = 'I:\WAT_BS_01\TPWS\zID';
% load('HAT_CTs');
f = 4.5:0.5:99.5;

for i = 1:length(CTs)
figure(1)
clf
% Concatenated spectra
subplot(3,2,[1 2])
imagesc([],f,CTs(i).Spectra');
set(gca,'ydir','normal')
colormap(jet)
xlabel('Click Number');
ylabel('Frequency (kHz)');
set(gca,'fontSize',13);
% ICI
subplot(3,2,[3 4])
plot(CTs(i).ICI,'.')
ylim([0 0.7]);
xlim([0 length(CTs(i).ICI)]);
xlabel('Click Number');
ylabel('ICI (s)');
set(gca,'fontSize',13);
grid on
% mean spectrum
subplot(3,2,5)
plot(f,mean(CTs(i).Spectra));
xlabel('Frequency (kHz)');
ylabel('Normalized Amplitude');
set(gca,'fontSize',13);
% mean waveform
subplot(3,2,6)
plot(mean(CTs(i).Timeseries));
xlabel('Sample');
ylabel('Counts');
set(gca,'fontSize',13);

[ax,h3]=suplabel(sprintf('%s NNet Label %d',project,CTs(i).NN_Label),'t',[.075 .075 .85 .89] );
set(ax,'fontSize',16);
saveas(figure(1),fullfile(saveDir,sprintf('%s_NNet_%d',project,CTs(i).NN_Label)),'tiff');
end

%% Concatenate clicks sharing a label across sites

clearvars
cd('G:\Report_CTs\Labeled_Clicks\Subset_for_CatSpecs');
NFC = load('NFC_CTs');
HAT = load('HAT_CTs');
WAT = load('WAT_CTs');
f = 4.5:0.5:99.5;

saveDir = 'G:\Report_CTs\WAT3_7_NH1_J1';
saveName = 'WAT3_7_NH1_Comparison';
catSpecs = [WAT.CTs(4).Spectra;WAT.CTs(7).Spectra;HAT.CTs(3).Spectra];
catICI = [WAT.CTs(4).ICI;WAT.CTs(7).ICI;HAT.CTs(3).ICI];
meanSpecs = [mean(WAT.CTs(4).Spectra);mean(WAT.CTs(7).Spectra);mean(HAT.CTs(3).Spectra)];
meanTS = {mean(WAT.CTs(4).Timeseries);mean(WAT.CTs(7).Timeseries);mean(HAT.CTs(3).Timeseries)};

norm_catSpecs = (catSpecs - min(catSpecs,[],2));
norm_catSpecs = norm_catSpecs./max(norm_catSpecs,[],2);
norm_meanSpecs = (meanSpecs - min(meanSpecs,[],2));
norm_meanSpecs = norm_meanSpecs./max(norm_meanSpecs,[],2);

k = [length(WAT.CTs(5).Spectra) length(WAT.CTs(5).Spectra)+length(WAT.CTs(7).ICI)];

figure(2)
clf
subplot(4,3,1:3)
imagesc([],f,norm_catSpecs');
set(gca,'ydir','normal');
colormap(jet)
xlabel('Click Number');
ylabel('Frequency (kHz)');
for i = 1:length(k)
    line(repmat(k(i),length(f),1),f,'Color','b','LineWidth',2);
end
subplot(4,3,4:6)
plot(catICI,'.');
ylim([0 0.4]);
xlabel('Click Number');
ylabel('ICI (s)');
xlim([0 length(catICI)]);
grid on

for i = 1:size(norm_meanSpecs,1)
subplot(4,3,i+6)
plot(f,norm_meanSpecs(i,:));
xlabel('Frequency (kHz)');
ylabel('Normalized Amplitude');
xticks([0 25 50 75 100]);
grid on
end

for i = 1:size(meanTS,1)
subplot(4,3,i+9)
plot(meanTS{i,:});
xlabel('Sample');
ylabel('Counts');
end

[ax,h3]=suplabel('WAT CT3 & CT7, NFC/HAT CT1','t',[.075 .072 .85 .89] );
set(ax,'fontSize',16);

cd(saveDir)
saveas(figure(2),saveName,'fig')
saveas(figure(2),saveName,'tiff') 
