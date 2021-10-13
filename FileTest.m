
clearvars
inDir = 'J:\WAT_BC_03\TPWS';
fileList = dir(fullfile(inDir,'*TPWS1.mat'));
names = cell(size(fileList,1),1);
for i=11:size(fileList,1)
    load(fullfile(inDir,fileList(i).name),'MSN');
    names{i} = fileList(i).name;
    MTT = [];
end