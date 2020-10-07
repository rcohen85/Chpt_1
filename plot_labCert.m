
labCertDir = 'G:\WAT_BC_01\WAT_BC_01_TPWS';
clasDir = 'I:\WAT_BC_01\NEW_ClusterBins_120dB\ToClassify';
labDir = 'I:\WAT_BC_01\NEW_ClusterBins_120dB\ToClassify\labels';
savDir = fullfile(labCertDir,'LabelCert_Plots');
dep = 'WAT\_BC\_01';
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT46+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM Gervais','HFA','Kogia',...
    'MFA','MultiFreq Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'};
f = 5:0.5:98.5;
t = 0:.01:1;

minPPRL = 120;
minNumClicks = 100;

%%
if ~isdir(savDir)
    mkdir(savDir)
end

labCertFiles = dir(fullfile(labCertDir,'*labCert.mat'));

setCert = cell(1,size(CTs,2));
setRLmax = cell(1,size(CTs,2));
setRLmean = cell(1,size(CTs,2));
setSpecs = cell(1,size(CTs,2));
setICI = cell(1,size(CTs,2));
setWavEnv = cell(1,size(CTs,2));

for i = 1:size(labCertFiles,1)
    load(fullfile(labCertDir,labCertFiles(i).name),'labelCertainty','RL');
    load(fullfile(clasDir,strrep(labCertFiles(i).name,'labCert','clusters_PR95_PPmin120_toClassify')));
    load(fullfile(labDir,strrep(labCertFiles(i).name,'labCert','clusters_PR95_PPmin120_predLab')));
    
    
    for j = 1:size(RL,2)
        
        setCert{1,j} = [setCert{1,j};labelCertainty{1,j}];
        setRLmax{1,j} = [setRLmax{1,j};RL{1,j}];
        setRLmean{1,j} = [setRLmean{1,j};RL{2,j}];
        
        if ~isempty(setCert{1,j})
            
            binTimes = setCert{1,j}(:,1);
            binInd = ismember(sumTimeMat(:,1),binTimes);
            binInd(predLabels~=j-1)=0;
            
            % find cases of multiple spectra in one bin and average them
            specTimes = sumTimeMat(binInd);
            [C, ia, ic] = unique(specTimes);
            reps = setdiff(1:numel(specTimes),ia);
            
            if ~isempty(reps)
                specs = toClassify(binInd,1:188);
                ICI = toClassify(binInd,190:290);
                wavEnvs = toClassify(binInd,291:491);
                nspec = nSpecMat(binInd);
                for k = 1:size(reps,2) % average & normalize specs, ICI, & waveform envelopes for repeated bins
                    meanSpec = (specs(reps(k)-1,:)*nspec(reps(k)-1))+(specs(reps(k),:)*nspec(reps(k)))/2;
                    specNorm = meanSpec-min(meanSpec);
                    specs(reps(k)-1,:) = specNorm./max(specNorm);
                    meanICI = (ICI(reps(k)-1,:)*nspec(reps(k)-1))+(ICI(reps(k),:)*nspec(reps(k)))/2;
                    ICInorm = meanICI-min(meanICI);
                    ICI(reps(k)-1,:) = ICInorm./max(ICInorm);
                    meanEnvs = (wavEnvs(reps(k)-1,:)*nspec(reps(k)-1))+(wavEnvs(reps(k),:)*nspec(reps(k)))/2;
                    Envsnorm = meanEnvs-min(meanEnvs);
                    Envs(reps(k)-1,:) = Envsnorm./max(Envsnorm);
                end
                specs(reps,:) = [];
                ICI(reps,:) = [];
                Envs(reps,:) = [];
                setSpecs{1,j} = [setSpecs{1,j};specs];
                setICI{1,j} = [setICI{1,j};ICI];
                setWavEnv{1,j} = [setWavEnv{1,j};Envs];
                
            else
                setSpecs{1,j} = [setSpecs{1,j};toClassify(binInd,1:188)];
                setICI{1,j} = [setICI{1,j};toClassify(binInd,190:290)];
                setWavEnv{1,j} = [setWavEnv{1,j};toClassify(binInd,291:491)];
            end
        end
        
    end
end

for i = 1:size(setCert,2)
    
    thisLab = setCert{1,i};
    theseSpecs = setSpecs{1,i};
    thisICI = setICI{1,i};
    
    if ~isempty(thisLab)
        
        % find bins that meet minPPRL and minNumClicks criteria
        goodAmp = find(setRLmean{1,i}>=minPPRL);
        goodNum = find(thisLab(:,3)>=minNumClicks);
        goodInd = intersect(goodAmp,goodNum);
        thisLab = thisLab(goodInd,:);
        theseSpecs = theseSpecs(goodInd,:);
        thisICI = thisICI(goodInd,:);
        theseEnvs = setWavEnv{1,i}(goodInd,:);
        thisRLmean = setRLmean{1,i}(goodInd);
        thisRLmax = setRLmax{1,i}(goodInd);
        
        if ~isempty(thisLab)
            % identify correctly/incorrectly labeled bins/specs/ICI
            right = thisLab(thisLab(:,4)==1,:);
            rightSpecs = theseSpecs(thisLab(:,4)==1,:);
            rightICI = thisICI(thisLab(:,4)==1,:);
            rightEnv = theseEnvs(thisLab(:,4)==1,:);
            rightRLmean = thisRLmean(thisLab(:,4)==1,:);
            rightRLmax = thisRLmax(thisLab(:,4)==1,:);
            right_perc = round(size(right,1)/size(thisLab,1),3);
            wrong = thisLab(thisLab(:,4)==0,:);
            wrongSpecs = theseSpecs(thisLab(:,4)==0,:);
            wrongICI = thisICI(thisLab(:,4)==0,:);
            wrongEnv = theseEnvs(thisLab(:,4)==0,:);
            wrongRLmean = thisRLmean(thisLab(:,4)==0,:);
            wrongRLmax = thisRLmax(thisLab(:,4)==0,:);
            wrong_perc = round(size(wrong,1)/size(thisLab,1),3);
            
            % sort by label confidence
            [right, rInd] = sortrows(right,2);
            rightSpecs = rightSpecs(rInd,:);
            rightICI = rightICI(rInd,:);
            [wrong, wInd] = sortrows(wrong,2);
            wrongSpecs = wrongSpecs(wInd,:);
            wrongICI = wrongICI(wInd,:);
            
            bins = linspace(1,max(thisLab(:,3)),100);
            
            % Plot
            figure(1),clf
            subplot(3,4,1)
            c = plot(right(:,2),'.','MarkerSize',10);
            ylim([0.5 1.1]);
            title('Correct Label Confidences')
            xlabel('Bin');
            ylabel('Label Confidence');
            label1 = strcat({'N = '}, string(size(right,1)),{' ('},string(right_perc*100),{'%)'});
            h = legend(c,label1,'Location','southeast');
            
            subplot(3,4,2)
            imagesc([],f,rightSpecs');
            set(gca,'ydir','normal')
            title('Correct Spectra');
            xlabel('Bin');
            ylabel('Freq (kHz)');
            
            subplot(3,4,3)
            c = plot(wrong(:,2),'.','MarkerSize',10);
            ylim([0.5 1.1]);
            title('Incorrect Label Cofidences');
            xlabel('Bin');
            ylabel('Label Confidence');
            label2 = strcat({'N = '}, string(size(wrong,1)),{' ('},string(wrong_perc*100),{'%)'});
            h = legend(c,label2,'Location','southeast');
            
            subplot(3,4,4)
            imagesc([],f,wrongSpecs');
            set(gca,'ydir','normal')
            title('Incorrect Spectra');
            xlabel('Bin');
            ylabel('Freq (kHz)');
            
            subplot(3,4,5)
            plot(right(:,3),'.','MarkerSize',10)
            ylim([0 max([right(:,3);wrong(:,3)])*1.1]);
            set(gca,'YScale','log');            
            title('Correct Label Bin Sizes')
            xlabel('Bin');
            ylabel('# Clicks');
            
            subplot(3,4,6)
            imagesc([],t,rightICI');
            set(gca,'ydir','normal');
            grid on
            xticks([0 0.2 0.4 0.6 0.8 1]);
            title('Correct Label ICI Distribution');
            xlabel('ICI (s)');
            ylabel('Counts');
            
            subplot(3,4,7)
            plot(wrong(:,3),'.','MarkerSize',10)
            ylim([0 max([right(:,3);wrong(:,3)])*1.1]);
            set(gca,'YScale','log');
            title('Incorrect Label Bin Sizes')
            xlabel('Bin');
            ylabel('# Clicks');
            
            subplot(3,4,8)
            imagesc([],t,wrongICI');
            set(gca,'ydir','normal');
            grid on
            xticks([0 0.2 0.4 0.6 0.8 1]);
            title('Incorrect Label ICI Distribution');
            xlabel('ICI (s)');
            ylabel('Counts');
            
            subplot(3,4,9)
            hold on
            plot(rightRLmean,'.','MarkerSize',10)
            plot(rightRLmax,'.','MarkerSize',10)
            hold off
            ylim([0 max([rightRLmean;rightRLmax;wrongRLmean;wrongRLmax])*1.1]);
            title('Correct Label RLs');
            xlabel('Bin');
            ylabel('dB re 1 \muPa');
            
            subplot(3,4,10)
            imagesc(rightEnv');
            set(gca,'ydir','normal')
            title('Correct Labels Mean Waveform Envelope');
            xlabel('Bin');
            ylabel('Sample #');
            
            subplot(3,4,11)
            hold on
            plot(wrongRLmean,'.','MarkerSize',10)
            plot(wrongRLmax,'.','MarkerSize',10)
            hold off
            ylim([0 max([rightRLmean;rightRLmax;wrongRLmean;wrongRLmax])*1.1]);
            title('Incorrect Label RLs');
            xlabel('Bin');
            ylabel('dB re 1 \muPa');
            
            subplot(3,4,12)
            imagesc(wrongEnv');
            set(gca,'ydir','normal')
            title('Incorrect Labels Mean Waveform Envelope');
            xlabel('Bin');
            ylabel('Sample #');
            
            
            [ax1 h1] = suplabel({[dep ' ' CTs{i}];['Min PPRL: ' num2str(minPPRL),', Min # Clicks: ' num2str(minNumClicks)]},'t');
            set(h1,'fontSize',16);
            
            saveas(gcf,fullfile(savDir,[CTs{i} '_minRL' num2str(minPPRL) '_minClicks' num2str(minNumClicks)]),'tiff');
        end
    end
    
end

save(fullfile(savDir,'setCertainty'),'setCert');
