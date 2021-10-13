% clearvars
labCertDir = 'J:\HAT_B_04-05_combined\labCert';
clasDir = 'J:\HAT_B_04-05_combined\cluster_bins\ToClassify';
labDir = 'J:\HAT_B_04-05_combined\cluster_bins\ToClassify\labels';
errDir = 'I:\ErrorEval';
savDir = fullfile(labCertDir,'LabelCert_Plots');
dep = 'HAT\_B\_04-05';
CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT46+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM Gervais','HFA','Kogia',...
    'MFA','MultiFreq Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'};
% CTs = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT46+CT10',...
%     'CT5','CT8','Cuviers','Gervais','GoM Gervais','HFA','Kogia',...
%     'MFA','MultiFreq Sonar','Rissos','SnapShrimp','Sowerbys',...
%     'Sperm Whale','Trues','AtlGervais+GoMGervais'};
f = 5:0.5:98.5;
t = 0:.01:1;

minPPRL = [120 122 125 127 130];
minNumClicks = [0 20 35 50 75]';

%% Compile data from multiple labCert files

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
                
                % find cases of multiple spectra in one bin and average
                % them (THIS WILL ONLY AVERAGE 2 SPECS, IF 3 OR MORE SPECS
                % IN THE SAME BIN HAVE THE SAME LABEL SOME WILL BE LEFT OUT
                % OF THE AVERAGE)
                specTimes = sumTimeMat(binInd);
                [C, ia, ic] = unique(specTimes);
                reps = setdiff(1:numel(specTimes),ia);
                
                if ~isempty(reps)
                    specs = toClassify(binInd,1:188);
                    thisICI = toClassify(binInd,190:290);
                    wavEnvs = toClassify(binInd,292:491);
                    nspec = nSpecMat(binInd);
                    
                    multRep = find(diff(reps)==1); % find consecutive values in reps
                    if any(multRep)
                        % ADD CODE TO DEAL WITH 3+ SPECS WITH SAME LABEL
                    else
                        for k = 1:size(reps,2) % average & normalize specs, ICI, & waveform envelopes for repeated bins
                            meanSpec = (specs(reps(k)-1,:)*nspec(reps(k)-1))+(specs(reps(k),:)*nspec(reps(k)))/2;
                            specNorm = meanSpec-min(meanSpec);
                            specs(reps(k)-1,:) = specNorm./max(specNorm);
                            meanICI = (thisICI(reps(k)-1,:)*nspec(reps(k)-1))+(thisICI(reps(k),:)*nspec(reps(k)))/2;
                            ICInorm = meanICI-min(meanICI);
                            thisICI(reps(k)-1,:) = ICInorm./max(ICInorm);
                            meanEnvs = (wavEnvs(reps(k)-1,:)*nspec(reps(k)-1))+(wavEnvs(reps(k),:)*nspec(reps(k)))/2;
                            Envsnorm = meanEnvs-min(meanEnvs);
                            wavEnvs(reps(k)-1,:) = Envsnorm./max(Envsnorm);
                        end
                    end
                    specs(reps,:) = [];
                    thisICI(reps,:) = [];
                    wavEnvs(reps,:) = [];
                    setSpecs{1,j} = [setSpecs{1,j};specs];
                    setICI{1,j} = [setICI{1,j};thisICI];
                    setWavEnv{1,j} = [setWavEnv{1,j};wavEnvs];
                    
                else
                    setSpecs{1,j} = [setSpecs{1,j};toClassify(binInd,1:188)];
                    setICI{1,j} = [setICI{1,j};toClassify(binInd,190:290)];
                    setWavEnv{1,j} = [setWavEnv{1,j};toClassify(binInd,292:491)];
                end
            end
            
        end
    end
    
    save(fullfile(savDir,[strrep(dep,'\','') '_setCertainty']),'setCert','setSpecs','setICI','setWavEnv','setRLmax','setRLmean');
    save(fullfile(errDir,[strrep(dep,'\','') '_setCertainty']),'setCert','setSpecs','setICI','setWavEnv','setRLmax','setRLmean');
%% Plot

% for i = 1:size(setCert,2)
%     
%     Lab = setCert{1,i};
%     Specs = setSpecs{1,i};
%     ICI = setICI{1,i};
%     
%     if ~isempty(Lab)  
%         for k = 1:length(minNumClicks)
%             for l = 1:length(minPPRL)
%                 % find bins that meet minPPRL and minNumClicks criteria
%                 goodAmp = find(setRLmean{1,i}>=minPPRL(l));
%                 goodNum = find(Lab(:,3)>=minNumClicks(k));
%                 goodInd = intersect(goodAmp,goodNum);
%                 thisLab = Lab(goodInd,:);
%                 theseSpecs = Specs(goodInd,:);
%                 thisICI = ICI(goodInd,:);
%                 theseEnvs = setWavEnv{1,i}(goodInd,:);
%                 thisRLmean = setRLmean{1,i}(goodInd);
%                 thisRLmax = setRLmax{1,i}(goodInd);
%                 
%                 if ~isempty(thisLab)
%                     % identify correctly/incorrectly labeled bins/specs/ICI
%                     right = thisLab(thisLab(:,4)==1,:);
%                     rightSpecs = theseSpecs(thisLab(:,4)==1,:);
%                     rightICI = thisICI(thisLab(:,4)==1,:);
%                     rightEnv = theseEnvs(thisLab(:,4)==1,:);
%                     rightRLmean = thisRLmean(thisLab(:,4)==1,:);
%                     rightRLmax = thisRLmax(thisLab(:,4)==1,:);
%                     right_perc = round(size(right,1)/size(thisLab,1),3);
%                     wrong = thisLab(thisLab(:,4)==0,:);
%                     wrongSpecs = theseSpecs(thisLab(:,4)==0,:);
%                     wrongICI = thisICI(thisLab(:,4)==0,:);
%                     wrongEnv = theseEnvs(thisLab(:,4)==0,:);
%                     wrongRLmean = thisRLmean(thisLab(:,4)==0,:);
%                     wrongRLmax = thisRLmax(thisLab(:,4)==0,:);
%                     wrong_perc = round(size(wrong,1)/size(thisLab,1),3);
%                     
%                     % sort by label confidence
%                     [right, rInd] = sortrows(right,2);
%                     rightSpecs = rightSpecs(rInd,:);
%                     rightICI = rightICI(rInd,:);
%                     rightEnv = rightEnv(rInd,:);
%                     [wrong, wInd] = sortrows(wrong,2);
%                     wrongSpecs = wrongSpecs(wInd,:);
%                     wrongICI = wrongICI(wInd,:);
%                     wrongEnv = wrongEnv(wInd,:);
%                     
%                     bins = linspace(1,max(thisLab(:,3)),100);
%                     
%                     % Plot
%                     figure(1),clf
%                     
%                     if ~isempty(right)
%                         
%                         subplot(3,4,1)
%                         c = plot(right(:,2),'.','MarkerSize',10);
%                         ylim([0.5 1.1]);
%                         xlim([0 size(right,1)]);
%                         title('Correct Label Confidences')
%                         xlabel('Bin');
%                         ylabel('Label Confidence');
%                         label1 = strcat({'N = '}, string(size(right,1)),{' ('},string(right_perc*100),{'%)'});
%                         h = legend(c,label1,'Location','southeast');
%                         
%                         subplot(3,4,2)
%                         imagesc([],f,rightSpecs');
%                         set(gca,'ydir','normal')
%                         title('Correct Spectra');
%                         xlabel('Bin');
%                         ylabel('Freq (kHz)');
%                         
%                         subplot(3,4,5)
%                         plot(right(:,3),'.','MarkerSize',10)
%                         ylim([0 max([right(:,3);wrong(:,3)])*1.1]);
%                         xlim([0 size(right,1)]);
%                         set(gca,'YScale','log');
%                         title('Correct Label Bin Sizes')
%                         xlabel('Bin');
%                         ylabel('# Clicks');
%                         
%                         subplot(3,4,6)
%                         imagesc([],t,rightICI');
%                         set(gca,'ydir','normal');
%                         grid on
%                         yticks([0 0.2 0.4 0.6 0.8 1]);
%                         title('Correct Label ICI Distribution');
%                         ylabel('ICI (s)');
%                         xlabel('Bin');
%                         
%                         subplot(3,4,9)
%                         hold on
%                         plot(rightRLmean,'.','MarkerSize',10)
%                         plot(rightRLmax,'.','MarkerSize',10)
%                         hold off
%                         ylim([115 max([rightRLmean;rightRLmax;wrongRLmean;wrongRLmax])*1.1]);
%                         xlim([0 size(right,1)]);
%                         title('Correct Label RLs');
%                         xlabel('Bin');
%                         ylabel('dB re 1 \muPa');
%                         legend({'Mean RL','Max RL'},'Location','northeast');
%                         
%                         subplot(3,4,10)
%                         imagesc(rightEnv');
%                         set(gca,'ydir','normal')
%                         title('Correct Labels Mean Waveform Envelope');
%                         xlabel('Bin');
%                         ylabel('Sample #');
%                         
%                     else
%                         annotation('textbox',[.17 .1 .5 .5],'String','No Correct Bins','FitBoxToText','on','FontSize',18);
%                     end
%                     
%                     if ~isempty(wrong)
%                         
%                         subplot(3,4,3)
%                         c = plot(wrong(:,2),'.','MarkerSize',10);
%                         ylim([0.5 1.1]);
%                         xlim([0 size(wrong,1)]);
%                         title('Incorrect Label Cofidences');
%                         xlabel('Bin');
%                         ylabel('Label Confidence');
%                         label2 = strcat({'N = '}, string(size(wrong,1)),{' ('},string(wrong_perc*100),{'%)'});
%                         h = legend(c,label2,'Location','southeast');
%                         
%                         subplot(3,4,4)
%                         imagesc([],f,wrongSpecs');
%                         set(gca,'ydir','normal')
%                         title('Incorrect Spectra');
%                         xlabel('Bin');
%                         ylabel('Freq (kHz)');
%                         
%                         subplot(3,4,7)
%                         plot(wrong(:,3),'.','MarkerSize',10)
%                         ylim([0 max([right(:,3);wrong(:,3)])*1.1]);
%                         xlim([0 size(wrong,1)]);
%                         set(gca,'YScale','log');
%                         title('Incorrect Label Bin Sizes')
%                         xlabel('Bin');
%                         ylabel('# Clicks');
%                         
%                         subplot(3,4,8)
%                         imagesc([],t,wrongICI');
%                         set(gca,'ydir','normal');
%                         grid on
%                         yticks([0 0.2 0.4 0.6 0.8 1]);
%                         title('Incorrect Label ICI Distribution');
%                         ylabel('ICI (s)');
%                         xlabel('Bin');
%                         
%                         subplot(3,4,11)
%                         hold on
%                         plot(wrongRLmean,'.','MarkerSize',10)
%                         plot(wrongRLmax,'.','MarkerSize',10)
%                         hold off
%                         ylim([115 max([rightRLmean;rightRLmax;wrongRLmean;wrongRLmax])*1.1]);
%                         xlim([0 size(wrong,1)]);
%                         title('Incorrect Label RLs');
%                         xlabel('Bin');
%                         ylabel('dB re 1 \muPa');
%                         legend({'Mean RL','Max RL'},'Location','northeast');
%                         
%                         subplot(3,4,12)
%                         imagesc(wrongEnv');
%                         set(gca,'ydir','normal')
%                         title('Incorrect Labels Mean Waveform Envelope');
%                         xlabel('Bin');
%                         ylabel('Sample #');
%                     else
%                         annotation('textbox',[.67 .1 .5 .5],'String','No Incorrect Bins','FitBoxToText','on','FontSize',18);
%                     end
%                     
%                     [ax1 h1] = suplabel({[dep ' ' CTs{i}];['Min PPRL: ' num2str(minPPRL(l)),', Min # Clicks: ' num2str(minNumClicks(k))]},...
%                         't',[.1 .12 .85 .85]);
%                     set(h1,'fontSize',16);
%                     
%                     saveas(gcf,fullfile(savDir,[CTs{i} '_minRL' num2str(minPPRL(l)) '_minClicks' num2str(minNumClicks(k))]),'tiff');
%                 end
%             end
%         end
%     end
% end

%% Compare % error for each click type across deployments

% Load setCert files
errFiles = dir(fullfile(errDir,'*setCertainty.mat'));
site = {};
siteCert = {};
siteRLmean = {};
binsPerSeason = {};
offset = 0;
% figure(99), clf
% hold on
for i = 1:size(errFiles,1)
    site{i,1} = strrep(errFiles(i).name,'_setCertainty.mat','');
    load(fullfile(errDir,errFiles(i).name),'setCert');
    load(fullfile(errDir,errFiles(i).name),'setRLmean');
    for j = 1:size(setCert,2)
        siteCert{i,j} = setCert{1,j};
        siteRLmean{i,j} = setRLmean{1,j};
        
        % Divide bins by season
        if ~isempty(setCert{1,j})
            dvec = datevec(setCert{1,j}(:,1));
            win_ind = find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2);
            spr_ind = find(dvec(:,2)>=3 & dvec(:,2)<=5);
            sum_ind = find(dvec(:,2)>=6 & dvec(:,2)<=8);
            fall_ind = find(dvec(:,2)>=9 & dvec(:,2)<=11);
            
            binsPerSeason{i,j} = [numel(win_ind),numel(spr_ind),numel(sum_ind),numel(fall_ind)];
        else
            binsPerSeason{i,j} = [];
        end
    end
    
    if ~contains(site{i,1},'JAX10C') && ~contains(site{i,1},'USWTR')
        allbins = vertcat(setCert{1,:});
        allbins = allbins(:,1);
%         figure(99)
%         plot(allbins,zeros(size(allbins,1),1)-offset,'*')
%         offset = offset+1;
    end
end

% figure(99)
% datetick
% yticks([-35:1:0]);
% yticklabels(site);
% hold off

% Combine Atl Gervais & GoM Gervais
for l = 1:size(site,1)
    siteCert{l,21} = vertcat(siteCert{l,10},siteCert{l,11});
    siteRLmean{l,21} = vertcat(siteRLmean{l,10},siteRLmean{l,11});
    binsPerSeason{l,21} = sum(vertcat(binsPerSeason{l,10},binsPerSeason{l,11}),1);
end

siteErr = cell(size(siteCert,1),size(siteCert,2));
binsEvaluated = cell(size(siteCert,1),size(siteCert,2));
typeCert = cell(1,size(siteCert,2));
typeRLmean = cell(1,size(siteCert,2));
propBinsLost = cell(1,size(siteCert,2));
propClicksLost = cell(1,size(siteCert,2));
errRange = cell(size(siteErr,1),size(siteErr,2));
meanTypeErr = cell(1,size(siteCert,2));
optThresh = cell(1,size(siteCert,2));

% For each CT:
for j = 1:size(siteCert,2)
    
    % Create error surface at each site
    err = [];
    binsEval = [];
    for st = 1:size(siteCert,1)
        if ~isempty(siteCert{st,j})
            for k = 1:length(minNumClicks)
                for l = 1:length(minPPRL)
                    % find bins that meet minPPRL and minNumClicks criteria
                    goodAmp = find(siteRLmean{st,j}>=minPPRL(l));
                    goodNum = find(siteCert{st,j}(:,3)>=minNumClicks(k));
                    goodInd = intersect(goodAmp,goodNum);
                    thisLab = siteCert{st,j}(goodInd,:);
                    
                    if ~isempty(thisLab)
                        % identify incorrectly labeled bins
                        wrong = thisLab(thisLab(:,4)==0,:);
                        wrong_perc = round(size(wrong,1)/size(thisLab,1),3);
                        err(k,l,st) = wrong_perc;
                        binsEval(k,l,st) = size(thisLab,1);
                    else
                        err(k,l,st) = NaN;
                        binsEval(k,l,st) = 0;
                    end
                end
            end
            siteErr{st,j} = err(:,:,st);
            binsEvaluated{st,j} = binsEval(:,:,st);
        else
            siteErr{st,j} = [];
            binsEvaluated{st,j} = [];
        end
    end
    
    % concatenate evaluated bins across sites for each CT
    typeCert{1,j} = cat(1,siteCert{:,j});
    typeRLmean{1,j} = cat(1,siteRLmean{:,j});
    
    if sum(cellfun(@isempty,siteErr(:,j))) < size(siteCert,1) % if any bins were evaluated for this CT
         % Calculate proportion of bins retained at each RL/# clicks thresh combo
         propbins = [];
         propclicks = [];
         totClicks = sum(typeCert{1,j}(:,3));
         for k = 1:length(minNumClicks)
             for l = 1:length(minPPRL)
                 % find bins that meet minPPRL and minNumClicks criteria
                 goodAmp = find(typeRLmean{1,j}>=minPPRL(l));
                 goodNum = find(typeCert{1,j}(:,3)>=minNumClicks(k));
                 goodInd = intersect(goodAmp,goodNum);
                 goodClicks = sum(typeCert{1,j}(goodInd,3));
                 
                 if ~isempty(goodInd)
                     propbins(k,l) = 1-(size(goodInd,1)./size(typeCert{1,j},1));
                     propclicks(k,l) = 1-(goodClicks./totClicks);
                 else
                     propbins(k,l) = NaN;
                     propclicks(k,l) = NaN;
                 end
             end
         end
         propBinsLost{1,j} = propbins;
         propClicksLost{1,j} = propclicks;
         
         for i = 1:size(siteErr,1)
                 q = [min(min(siteErr{i,j})),max(max(siteErr{i,j}))];
                 if ~isempty(q)
                     errRange{i,j} = q;
                 end
         end
         
%          % Scale error surfaces by # bins evaluated at each grid point,
%          % then normalize back to [0 1]
%          scale_err =  err.*sqrt(binsEval);
%          normScale_err = scale_err./max(max(max(scale_err))); %set highest scaled error value across sites to 1, all others proportional to it
%          
%          % Average scaled error surfaces across sites for this CT
%          scaledErr{1,j} = mean(normScale_err,3,'omitnan');

        % Average error surfaces across sites for this CT
        meanTypeErr{1,j} = mean(err,3,'omitnan');

         % Sort average scaled error & corresponding RL/# clicks thresholds, proportion of bins/clicks lost
        [PPRLgrid NumClicksgrid] = meshgrid(minPPRL,minNumClicks);
        %         [ordErr I] = sort(scaledErr{1,j}(:),'ascend');
        %         optThresh{1,j}(:,1) = scaledErr{1,j}(I);
        [ordErr, I] = sort(meanTypeErr{1,j}(:),'ascend');
        optThresh{1,j}(:,1) = meanTypeErr{1,j}(I);
        optThresh{1,j}(:,2) = PPRLgrid(I);
        optThresh{1,j}(:,3) = NumClicksgrid(I);
        optThresh{1,j}(:,4) = propBinsLost{1,j}(I);
        optThresh{1,j}(:,5) = propClicksLost{1,j}(I);
        
%         figure(999), clf
%         % Plot averaged scaled error surface
%         subplot(1,3,1)
%         surf(minPPRL,minNumClicks,meanTypeErr{1,j})
%         zlim([0 1]);
%         xlabel('Min PPRL');
%         ylabel('Min # Clicks');
%         zlabel('Error');
%         title([CTs{j},' Mean Error']);    
%         % Plot proportion of bins lost
%         subplot(1,3,2)
%         surf(minPPRL,minNumClicks,propBinsLost{1,j})
%         zlim([0 1]);
%         xlabel('Min PPRL');
%         ylabel('Min # Clicks');
%         zlabel('Proportion lost');
%         title([CTs{j},' Proportion of Bins Lost']);
%         % Plot proportion of clicks retained
%         subplot(1,3,3)
%         surf(minPPRL,minNumClicks,propClicksLost{1,j})
%         zlim([0 1]);
%         xlabel('Min PPRL');
%         ylabel('Min # Clicks');
%         zlabel('Proportion lost');
%         title([CTs{j},' Proportion of Clicks Lost']);
%         e = input('Enter to save figure and continue' );
%         saveas(gcf,fullfile(errDir,[CTs{j},'_Error.fig']));
    else
        propBinsLost{1,j} = [];
        meanTypeErr{1,j} = [];
    end
end

% Save
save(fullfile(errDir,'Error_Summary.mat'),'CTs','errFiles','site','siteCert','siteRLmean',...
    'siteErr','meanTypeErr','binsEvaluated','typeCert','typeRLmean','propBinsLost',...
    'propClicksLost','errRange','optThresh','minPPRL','minNumClicks','binsPerSeason','-v7.3');
