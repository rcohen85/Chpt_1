%% Loop through directory of TPWS1 files and merge into larger files combining 
% multiple xwav disks
clearvars
inDir = 'G:\TPWS_test'; % directory containing TPWS1 files
savDir = 'G:\TPWS_test'; % directory to save output merged TPWS
dep = 'WAT_BC_03'; % name of deployment, for saving merged TPWS file

fList = dir(fullfile(inDir,'*TPWS1.mat'));

MTT = [];
MPP = [];
MSN = [];
MSP = [];
f = [];

for iFile = 1:length(fList)
    
    % load existing TPWS file
    data = load(fullfile(inDir,fList(iFile).name));
    
    % combine data
    MTT = [MTT;data.MTT];
    MPP = [MPP; data.MPP];
    MSN = [MSN; data.MSN];
    MSP = [MSP;data.MSP];
    
    if isfield(data, 'f')
        f = data.f;
    end
    
    fprintf('Done with file %d of %d\n',iFile,length(fList));
    
end

% sort into chronological order
[MTT, I] = sortrows(MTT);
MPP = MPP(I,:);
MSN = MSN(I,:);
MSP = MSP(I,:);

% save merged file
if ~isempty(f)
    save (fullfile(savDir,[dep '_TPWS1.mat']),'MTT','MPP','MSN','MSP','f');
else
    save (fullfile(savDir,[dep '_TPWS1.mat']),'MTT','MPP','MSN','MSP');
end



%% Code for simulating TPWS files

% clearvars
% savDir = 'G:\TPWS_test';
% savName = 'test2_TPWS1';
% strt = datenum('4-30-2000 12:00:00','mm-dd-yyyy HH:MM:SS');
% fin = datenum('5-12-2001 12:00:00','mm-dd-yyyy HH:MM:SS');
% int = 1;
% MTT = [];
% MPP = [];
% MSN = [];
% MSP = [];
% MTT = (strt:datenum(0,0,0,int,0,0):fin)';
% PP = 118:0.25:165;
% MPP = datasample(PP,length(MTT))';
% fs = 100000;
% t = 0:0.00001:0.002;
% f = 25000:100:80000;
% a = 500;
% for i = 1:length(MTT)
% MSN(i,:) = a*sin(2*pi*datasample(f,1).*t);
% end
% nfft = 400;
% MSP = 20*log10(abs(fft(MSN,nfft,2)));
% MSP = MSP(:,1:nfft/2);
% f = 0:((fs/2)/1000)/((nfft/2)):((fs/2)/1000);
% 
% save(fullfile(savDir,savName),'MTT','MPP','MSN','MSP','f','-v7.3');

