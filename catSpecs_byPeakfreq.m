% Load cell array of spectra sorted by click type
load('G:\New_NNet_TrainTest\TrainTest\3min_TestBins_Pruned');
f = 5:0.5:98.5;
types = {'CT10','CT2','CT3','CT4/6','CT5','CT7','CT8','CT9','Blainville''s',...
    'Boats','Cuvier''s','Echosounder','Gervais''','Kogia','Noise','Risso''s',...
    'Sowerby''s','SpermWhale','True''s'};
newTestSet = struct('ClickType',[],'Specs',[],'ICI',[],'WV',[]);

for i = 1:length(types)
CT = cell2mat(vertcat(testSet(i).Specs));
ICI = cell2mat(vertcat(testSet(i).ICI));
WV = cell2mat(vertcat(testSet(i).WV));
[~, maxind] = max(CT,[],2);
[B, ind] = sortrows(maxind);

figure;imagesc([],f,CT(ind,:)');
title([types{i} ' CatSpec']);
xlabel('Bin');
ylabel('Frequency (kHz)');
set(gca,'ydir','normal');

figure;bar(sum(ICI(ind,:),'omitnan'));
title([types{i} ' ICI']);
xlim([0 60]);
xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});
xlabel('ICI (s)');
ylabel('Counts');

figure;imagesc([],[],WV(ind,:)');
title([types{i} ' Envelope']);
xlabel('Bin');
ylabel('Sample');
set(gca,'ydir','normal');
ylim([50 150]);

ind2(1) = input('Enter start index:\');
ind2(2) = input('Enter end index:');

figure;imagesc([],f,CT(ind(ind2(1):ind2(2)),:)');
title(types{i});
xlabel('Bin');
ylabel('Frequency (kHz)');
set(gca,'ydir','normal');

figure;bar(sum(ICI(ind(ind2(1):ind2(2)),:),'omitnan'));
title([types{i} ' ICI']);
xlim([0 60]);
xticklabels({'0','0.1','0.2','0.3','0.4','0.5','0.6'});
xlabel('ICI (s)');
ylabel('Counts');

figure;imagesc([],[],WV(ind(ind2(1):ind2(2)),:)');
title([types{i} ' Envelope']);
xlabel('Bin');
ylabel('Sample');
set(gca,'ydir','normal');
ylim([50 150]);

newTestSet(i).ClickType = types{i};
newTestSet(i).Specs = mat2cell(CT(ind(ind2(1):ind2(2)),:),ones(size(CT(ind(ind2(1):ind2(2)),:),1),1,1));
newTestSet(i).ICI = mat2cell(ICI(ind(ind2(1):ind2(2)),:),ones(size(ICI(ind(ind2(1):ind2(2)),:),1),1,1));
newTestSet(i).WV = mat2cell(WV(ind(ind2(1):ind2(2)),:),ones(size(WV(ind(ind2(1):ind2(2)),:),1),1,1));
% newTestSet(i-3).Specs = mat2cell(CT,ones(size(CT,1),1,1));
% newTestSet(i-3).ICI = mat2cell(ICI,ones(size(ICI,1),1,1));
% newTestSet(i-3).WV = mat2cell(WV,ones(size(WV,1),1,1));

maxind = [];

end

testSet = newTestSet;
save('3min_TestBins_Pruned_CombinedTypes','testSet','-v7.3');
