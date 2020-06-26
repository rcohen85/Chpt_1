clearvars;

binDir = 'I:\WAT_BS_01\NEW_ClusterBins_120dB';
TPWSDir = 'I:\WAT_BS_01\TPWS';
outDir = 'I:\WAT_BS_01';
binList = dir(fullfile(binDir,'*clusters*.mat'));
TPWSList = dir(fullfile(TPWSDir,'*_TPWS1.mat'));

%%
if ~isdir(fullfile(outDir,'ClusterToClassify_ClickLevel'))
    mkdir(fullfile(outDir,'ClusterToClassify_ClickLevel'))
end

if ~isdir(fullfile(outDir,'ClusterToClassify_ClickLevel','labels'))
    mkdir(fullfile(outDir,'ClusterToClassify_ClickLevel','labels'))
end  

for iFile = 1:length(binList)
    
    toClassify = [];
    Specs = [];
    ICI = [];
    Env = [];

    load(fullfile(binList(iFile).folder,binList(iFile).name));
    load(fullfile(TPWSList(iFile).folder,TPWSList(iFile).name));
     
    % divvy clicks from TPWS into bins
    binEdges = vertcat(binData.tInt);
    [N, edges, whichBin] = histcounts(MTT,[binEdges(:,1);binEdges(end,2)]);
    bins = 1:length(binData);
    
    % for each bin, pull appropriate spectra & ICI dist, calculate click
    % envelopes, normalize all
    for iA = 1:length(binData) 
         
       clicksinBin = find(whichBin==iA);
        
       % if there's only 1 cluster in bin and all the clicks are in it:
       if length(binData(iA).nSpec)==1 && length(clicksinBin)==binData(iA).nSpec
           binSpecs = MSP(clicksinBin);
           binICI = repmat(binData(iA).dTT,length(clicksinBin),1,1);
           if size(MSN,2)==200
                binEnv = abs(hilbert(MSN(clicksinBin,:)'))';
            elseif size(MSN,2)==300
                binEnv = abs(hilbert(MSN(clicksinBin,51:250)'))';
           end
           
       % if there's more than 1 cluster in this bin, OR not all the clicks are
       % in a cluster:
       elseif length(binData(iA).nSpec)>1 || length(clicksinBin)>sum(binData(iA).nSpec)
       
     
       end
    
       Specs = [Specs; binSpecs];
       ICI = [ICI; binICI];
       Env = [Env; binEnv];
       
    end 

%     NORMALIZE SPECS, ICI, & ENV
    
    toClassify = [SpecNorm,zeros(length(clicksinBin),1,1),binICI,...
        zeros(length(clicksinBin),1,1),EnvNorm];
   
    outFileName = strrep(fList(iFile).name,...
        '.mat',...
        '_toClassify.mat');
    save(fullfile(fList(iFile).folder,'ClusterToClassify',outFileName),'toClassify','sumTimeMat','nSpecMat','-v7.3')
end
