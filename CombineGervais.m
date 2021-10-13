fileList = dir(fullfile('H:\DailyCT_Totals\minClicks50','*.mat'));

for i = 1:size(fileList,1)
    
   load(fullfile(fileList(i).folder,fileList(i).name));
   spNameList{21,1} = 'AtlGervais+GomGervais';
   binFeatures{1,21} = [binFeatures{1,10};binFeatures{1,11}];
   binFeatures{2,21} = [binFeatures{2,10};binFeatures{2,11}];
   binFeatures{3,21} = [binFeatures{3,10};binFeatures{3,11}];
   dailyTots(:,22) = dailyTots(:,11)+dailyTots(:,12);
   labeledBins{1,21} = [labeledBins{1,10};labeledBins{1,11}];
   
   save(fullfile(fileList(i).folder,fileList(i).name), 'spNameList',...
       'RLThresh','numClicksThresh','probThresh','labeledBins','binFeatures','dailyTots','-v7.3');
    
end