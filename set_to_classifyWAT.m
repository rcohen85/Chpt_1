clearvars;
inDir = 'F:\WAT_WC_01_d4-8\ClusterBins_120dB';
fList = dir(fullfile(inDir,'*clusters*.mat'));
if ~isdir(fullfile(inDir,'ClusterToClassify'))
    mkdir(fullfile(inDir,'ClusterToClassify'))
end

if ~isdir(fullfile(inDir,'ClusterToClassify','labels'))
    mkdir(fullfile(inDir,'ClusterToClassify','labels'))
end  
for iFile = 1:length(fList)
    load(fullfile(fList(iFile).folder,fList(iFile).name));
    sumTimeMat = [];
    %     whichCell = [];
    for iTimes = 1:size(binData,1)
        sumTimeMat = [sumTimeMat;repmat(binData(iTimes).tInt,...
            size(binData(iTimes).nSpec,2),1)];
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
