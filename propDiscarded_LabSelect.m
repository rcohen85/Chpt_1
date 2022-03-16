propDiscarded = cell({'Blainvilles';'Boats';'UD36';'UD26';'UD28';...
    'UD19';'UD47';'UD38';'Cuviers';'Gervais';'GoM_Gervais';'HFA';...
    'Kogia';'MFA';'MultiFreq_Sonar';'Rissos';'SnapShrimp';'Sowerbys';...
    'Sperm Whale';'Trues'});

%%
inDir = 'J:\NFC_A_04\clusterBins\ToClassify\labels';
load(fullfile(inDir,'FlagMat_0.mat'));

for i = 1:20
    
    prop = 1-(sum(flagMat(i).Flag)./size(flagMat(i).Flag,1));
    prop = prop*100;
    propDiscarded{i,2} = prop;
    
end

%% Fix HAT_B_01-03 FlagMat files (combine original with flags for remade files)

load('H:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels\FlagMat_0_missingData.mat');
q = load('H:\HAT_B_01-03\NEW_ClusterBins_120dB\ToClassify\labels\new_LabelSelect_files\FlagMat_0.mat');

for i = 1:20
   flagMat(i).BinTimes = [flagMat(i).BinTimes;q.flagMat(i).BinTimes]; 
   flagMat(i).BinSpecs = [flagMat(i).BinSpecs;q.flagMat(i).BinSpecs];
   flagMat(i).ICI = [flagMat(i).ICI;q.flagMat(i).ICI];
   flagMat(i).Env = [flagMat(i).Env;q.flagMat(i).Env];
   flagMat(i).File = [flagMat(i).File;q.flagMat(i).File];
   flagMat(i).WhichCell = [flagMat(i).WhichCell;q.flagMat(i).WhichCell];
   flagMat(i).Probs = [flagMat(i).Probs;q.flagMat(i).Probs];
   flagMat(i).nSpec = [flagMat(i).nSpec;q.flagMat(i).nSpec];
   flagMat(i).Flag = [flagMat(i).Flag;q.flagMat(i).Flag];
   
   [B,I] = sort(flagMat(i).BinTimes);
   flagMat(i).BinTimes = flagMat(i).BinTimes(I,:); 
   flagMat(i).BinSpecs = flagMat(i).BinSpecs(I,:);
   flagMat(i).ICI = flagMat(i).ICI(I,:);
   flagMat(i).Env = flagMat(i).Env(I,:);
   flagMat(i).File = flagMat(i).File(I,:);
   flagMat(i).WhichCell = flagMat(i).WhichCell(I,:);
   flagMat(i).Probs = flagMat(i).Probs(I,:);
   flagMat(i).nSpec = flagMat(i).nSpec(I,:);
   flagMat(i).Flag = flagMat(i).Flag(I,:);
   
   [C,ia,ic] = unique([flagMat(i).BinTimes,flagMat(i).WhichCell],'rows');
   flagMat(i).BinTimes = flagMat(i).BinTimes(ia,:); 
   flagMat(i).BinSpecs = flagMat(i).BinSpecs(ia,:);
   flagMat(i).ICI = flagMat(i).ICI(ia,:);
   flagMat(i).Env = flagMat(i).Env(ia,:);
   flagMat(i).File = flagMat(i).File(ia,:);
   flagMat(i).WhichCell = flagMat(i).WhichCell(ia,:);
   flagMat(i).Probs = flagMat(i).Probs(ia,:);
   flagMat(i).nSpec = flagMat(i).nSpec(ia,:);
   flagMat(i).Flag = flagMat(i).Flag(ia,:);
    
end