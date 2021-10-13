% recalculate mean RL in linear space

clearvars
labCertDir = 'H:\WAT_OC_02\WAT_OC_02_TPWS';
labCertFiles = dir(fullfile(labCertDir,'*labCert.mat'));

for i = 1:size(labCertFiles,1)
    
    load(fullfile(labCertDir,labCertFiles(i).name));
    load(fullfile(labCertDir,strrep(labCertFiles(i).name,'labCert','TPWS1')),'MTT','MPP');
    load(fullfile(labCertDir,strrep(labCertFiles(i).name,'labCert','ID1')));
    binTimes = (floor(MTT(1)):datenum([0,0,0,0,5,0]):ceil(MTT(end)))';
    RL = cell(2,size(labelCertainty,2));
    
    for j = 1:size(labelCertainty,2) % for each click type
        if ~isempty(labelCertainty{1,j}) % if any bins were evaluated for this type
            thisLabTimes = zID(zID(:,2)==j); % find all clicks labeled as this type
            [N,~,bin] = histcounts(thisLabTimes,binTimes); % sort clicks into bins
            
            for k = 1:size(labelCertainty{1,j},1) % for each bin evaluated
                q = find(binTimes==labelCertainty{1,j}(k,1));
                thisBinTimes = thisLabTimes(bin==q); % get times of clicks in this bin
                [~,timesInTPWS] = ismember(thisBinTimes,MTT); % find indices of clicks in TPWS vars
                clickRLs = MPP(timesInTPWS); % get RLs of clicks
                clickRLs_lin = 10.^(clickRLs./20); % return to linear space
                meanRL = 20*log10(mean(clickRLs_lin)); % average and revert to log space
                RL{1,j}(k,1) = max(clickRLs);
                RL{2,j}(k,1) = meanRL; % replace incorrectly calculated mean RL
                
            end
        end
    end
    save(fullfile(labCertDir,labCertFiles(i).name),'labelCertainty','RL','p');
end

