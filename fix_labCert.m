% recalculate mean RL in linear space

labCertDir = 'G:\WAT_BC_01\TPWS';
labCertFiles = dir(fullfile(labCertDir,'*labCert.mat'));

for i = 1:size(labCertFiles,1)
    
    load(fullfile(labCertDir,labCertFiles(i).name),'labelCertainty','RL');
    load(fullfile(labCertDir,strrep(labCertFiles(i).name,'labCert','TPWS1')),'MTT','MPP');
    load(fullfile(labCertDir,strrep(labCertFiles(i).name,'labCert','ID1')));
    
    for j = 1:size(RL,2)
        
        
    end
    
    
end