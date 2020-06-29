clearvars;
inDir = 'I:\NFC_A_02\NEW_ClusterBins_120dB';
fList = dir(fullfile(inDir,'*clusters*.mat'));
if ~isdir(fullfile(inDir,'ToClassify'))
    mkdir(fullfile(inDir,'ToClassify'))
end

if ~isdir(fullfile(inDir,'ToClassify','labels'))
    mkdir(fullfile(inDir,'ToClassify','labels'))
end  
for iFile = 1:length(fList)
    load(fullfile(fList(iFile).folder,fList(iFile).name));
    
    cInt = vertcat(binData.cInt);
    goodBins = find(cInt>1);
    
    sumTimeMat = [];
    for iTimes = 1:size(binData,1)
        if ismember(iTimes,goodBins)
        sumTimeMat = [sumTimeMat;repmat(binData(iTimes).tInt,...
            size(binData(iTimes).nSpec,2),1)];
        end
    end
    
    
    nSpecMat = horzcat(binData(goodBins).nSpec)';
    catSpec = vertcat(binData(goodBins).sumSpec);
    catSpec = catSpec(:,2:189);
    catSpecMin = catSpec - min(catSpec,[],2);
    catSpecNorm = catSpecMin./max(catSpecMin,[],2);
    
    catDTT = vertcat(binData(goodBins).dTT);
    catDTTNorm = catDTT./max(catDTT,[],2);
    
    catEnv = vertcat(binData(goodBins).envMean);
    if size(catEnv,2) == 300
        catEnv = catEnv(:,51:250);
    end
    catEnvmin = min(catEnv,[],2);
    catEnvNorm = catEnv - catEnvmin;
    catEnvNorm = catEnvNorm./(max(catEnvNorm,[],2));
    
    toClassify = [catSpecNorm,...
        zeros(size(nSpecMat,1),1),...
        catDTTNorm,...
        zeros(size(nSpecMat,1),1),...
        catEnvNorm];

    
    outFileName = strrep(fList(iFile).name,'.mat','_toClassify.mat');
    save(fullfile(fList(iFile).folder,'ToClassify',outFileName),...
        'toClassify','sumTimeMat','nSpecMat','-v7.3')
end
