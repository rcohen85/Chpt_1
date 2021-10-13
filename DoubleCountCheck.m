%% Quantify inflation of bins/minutes/hours of presence due to double counting

inDir = 'I:\DoubleCountingDiscrepancy\DailyCT_Totals_DOUBLECOUNTED';
saveDir = 'I:\DoubleCountingDiscrepancy';
fileList = dir(fullfile(inDir,'*.mat'));
Site = {};
DiscrepancyBins = [];
DiscrepancyMins = [];
DiscrepancyHours = [];
PercDiscrepancy = [];


for ia = 1:size(fileList)
    
    load(fullfile(inDir,fileList(ia).name));
    Site{ia,1} = strrep(fileList(ia).name,'_DailyTotals_Prob0_RL120_numClicks0.mat','');
    
    
    uniqueBins = cellfun(@(x) unique(x,'rows'),labeledBins,'UniformOutput',0);
    diffBins = cellfun(@(x,y) abs(size(x,1)-size(y,1)),labeledBins,uniqueBins,'UniformOutput',0);
    diffMins = cellfun(@(x) x*5, diffBins,'UniformOutput',0);
    diffHours = cellfun(@(x) x/60, diffMins, 'UniformOutput',0);
    Perc = cellfun(@(x,y) x/size(y,1),diffBins,labeledBins,'UniformOutput',0);
    
    DiscrepancyBins = [DiscrepancyBins;diffBins];
    DiscrepancyMins = [DiscrepancyMins;diffMins];
    DiscrepancyHours = [DiscrepancyHours;diffHours];
    PercDiscrepancy = [PercDiscrepancy;Perc];
    
    spNameList = spNameList';
    
end

save(fullfile(saveDir,'DoubleCountExtent'),'DiscrepancyBins','DiscrepancyMins',...
    'DiscrepancyHours','spNameList','Site','PercDiscrepancy')
%% Quantify difference in final seasonal averages

doubleDir = 'I:\DoubleCountingDiscrepancy\SeasonalCT_Totals_DOUBLECOUNTED';
correctDir = 'I:\SeasonalCT_Totals';
saveDir = 'I:\DoubleCountingDiscrepancy';
doubleFList = dir(fullfile(doubleDir,'*Seasonal_Totals_Prob0_PPRL120_numClicks50.mat'));
correctFList = dir(fullfile(correctDir,'*Seasonal_Totals_Prob0_PPRL120_numClicks50.mat'));

for ia = 1:size(doubleFList,1)
    db = load(fullfile(doubleDir,doubleFList(ia).name));
    cor = load(fullfile(correctDir,correctFList(ia).name));
    
    db = table2cell(db.seasonalData);
    cor = table2cell(cor.seasonalData);
    
    hourDiff = cellfun(@(x,y) abs(x-y), db(:,2:5), cor(:,2:5));
    percDiff = cellfun(@(x,y) x/y, num2cell(hourDiff), db(:,2:5));
    
    sites = db(:,1);
    
    savename = (strrep(doubleFList(ia).name,'_Seasonal_Totals_Prob0_PPRL120_numClicks50',''));
    save(fullfile(saveDir,savename),'sites','hourDiff','percDiff');
end





