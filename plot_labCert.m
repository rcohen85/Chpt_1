
inDir = 'G:\WAT_OC_02\WAT_OC_02_TPWS';
savDir = fullfile(inDir,'LabelCert_Plots');
dep = 'WAT\_OC\_02';
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT46+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM Gervais','HFA','Kogia',...
    'MFA','MultiFreq Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'};

%%
if ~isdir(savDir)
    mkdir(savDir)
end

fileSet = dir(fullfile(inDir,'*labCert.mat'));
setCert = {};
for i = 1:size(fileSet,1)
    load(fullfile(inDir,fileSet(i).name),'labelCertainty');
    setCert = [setCert;labelCertainty];
end

for i = 1:size(setCert,2)
    
    thisLab = vertcat(setCert{:,i});
    if ~isempty(thisLab)
        right = thisLab(thisLab(:,4)==1,:);
        right_perc = round(size(right,1)/size(thisLab,1),3);
        wrong = thisLab(thisLab(:,4)==0,:);
        wrong_perc = round(size(wrong,1)/size(thisLab,1),3);
        bins = linspace(1,max(thisLab(:,3)),100);
        
        figure(1)
        subplot(2,2,1)
        c = plot(sort(right(:,2)),'o');
        ylim([0 1]);
        title('Correct Labels')
        xlabel('Bin');
        ylabel('Label Confidence');
        label1 = strcat({'N = '}, string(size(right,1)),{' ('},string(right_perc*100),{'%)'});
        h = legend(c,label1,'Location','southeast');

        subplot(2,2,2)
        c = plot(sort(wrong(:,2)),'o');
        ylim([0 1]);
        title('Incorrect Labels');
        xlabel('Bin');
        ylabel('Label Confidence');
        label2 = strcat({'N = '}, string(size(wrong,1)),{' ('},string(wrong_perc*100),{'%)'});
        h = legend(c,label2,'Location','southeast');
        
        subplot(2,2,3)
        histogram(right(:,3),bins);
        title('Correct Labels')
        ylabel('Count');
        xlabel('# Clicks');
        
        subplot(2,2,4)
        histogram(wrong(:,3),bins);
        title('Incorrect Labels')
        ylabel('Count');
        xlabel('# Clicks');
        
        [ax1 h1] = suplabel([dep ' ' CTs{i}],'t');
        set(h1,'fontSize',16);
        
        saveas(gcf,fullfile(savDir,CTs{i}),'tiff');
    end
    
end

save(fullfile(savDir,'setCertainty'),'setCert');
