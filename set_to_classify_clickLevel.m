clearvars;
binDir = 'G:\WAT_BS_01_Detector\ClusterBins_120dB';
TPWSDir = 'G:\WAT_BS_01_Detector\WAT_BS_01_TPWS';
outDir = 'G:\WAT_BS_01_Detector';
binList = dir(fullfile(binDir,'*clusters*.mat'));
TPWSList = dir(fullfile(TPWSDir,'*_TPWS1.mat'));

if ~isdir(fullfile(outDir,'ClusterToClassify_ClickLevel'))
    mkdir(fullfile(outDir,'ClusterToClassify_ClickLevel'))
end

if ~isdir(fullfile(outDir,'ClusterToClassify_ClickLevel','labels'))
    mkdir(fullfile(outDir,'ClusterToClassify_ClickLevel','labels'))
end  

for iFile = 1:length(binList)
    
    load(fullfile(binList(iFile).folder,binList(iFile).name));
    load(fullfile(TPWSList(iFile).folder,TPWSList(iFile).name));
    
    sumTimeMat = [];
    %     whichCell = [];
    for iTimes = 1:size(binData,1)
        sumTimeMat = [sumTimeMat;repmat(binData(iTimes).tInt,...
            size(binData(iTimes).nSpec,2),1)]; % bin start times of each bin mean spectrum
        %         whichCell = [whichCell;[1:size(binData(iTimes).nSpec,2)]'];
    end
    nSpecMat = horzcat(binData.nSpec)';
    catSpec = vertcat(binData.sumSpec);
    catSpec = catSpec(:,2:end);
    catSpecMin = catSpec - repmat(min(catSpec,[],2),1,size(catSpec,2));
    catSpecNorm = catSpecMin./max(catSpecMin,[],2);
    
    catDTT = vertcat(binData.dTT);
    toClassify = [catSpecNorm,...
        zeros(size(sumTimeMat,1),1),...
        catDTT./max(catDTT,[],2)];
    %     nnVec(nSpecMat<100,:) = [];
    %     catTimes(nSpecMat<100,:) = [];
    %     whichCell(nSpecMat<100,:) = [];
    outFileName = strrep(fList(iFile).name,...
        '.mat',...
        '_toClassify.mat');
    save(fullfile(fList(iFile).folder,'ClusterToClassify',outFileName),'toClassify','sumTimeMat','nSpecMat','-v7.3')
end
