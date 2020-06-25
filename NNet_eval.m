% Produce several plot types to evaluate the performance of a neural net
% Load NNet test data and output predicted labels
clearvars

baseDir = 'G:\cluster_NNet\TrainTest';
load(fullfile(baseDir,'TestSet_MSPICIWV_500.mat')); % update name of testing data file
%load('G:\forNNet\TestSet_WAT2018_binLevel_Expand');
q = 500; % # test examples per class
testDir = fullfile(baseDir,'20200625-132623'); % update folder where NNet output was saved
cd(testDir);
load('TestOutput')
testOut = testOut+1;
f = 5.5:0.5:99;
%labels = [1:9,11,13,14,16:19];
types = {'Blainville''s','Boats','CT11','CT2+CT9','CT3+CT7','CT4\6+CT10','CT5',...
    'CT8','Cuvier''s','Gervais''','Kogia','Risso''s','Sonar','Sowerby''s',...
    'SpermWhale','True''s'};



%% Confusion Matrix
% True labels are rows, predicted labels are columns
C = confusionmat(testLabelSet,double(testOut));
C = C/q*100; 
C = horzcat([1:length(myTypeList)]',C);
C = array2table(C,'VariableNames',{'TrueClass','Predicted_1','Predicted_2',...
    'Predicted_3','Predicted_4','Predicted_5','Predicted_6','Predicted_7',...
    'Predicted_8','Predicted_9','Predicted_10','Predicted_11','Predicted_12',...
    'Predicted_13','Predicted_14','Predicted_15','Predicted_16'});

writetable(C,fullfile(testDir,'ConfusionMatrix.csv'));

%% Plot spectra by predicted label

n = 1;
figure(99); clf
for i = 1:size(C,1)
%     if i == 10 || i == 12 || i == 15
%         continue
%     end
    
    CTind = find(testOut==i);
    subplot(4,4,n)
    imagesc([],f,testMSPICIWV(CTind,1:188)');
    set(gca,'ydir','normal');
    title(types{n});

    
    n = n+1;
end

suplabel('Bin','x');
suplabel('Frequency (kHz)','y');
suplabel('Concatenated Spectra as Labeled by NNet','t');

saveas(gcf,fullfile(testDir,'CatSpecs'),'tiff');


%% Plot incorrectly labeled spectra
k = 1;
n = 1;
figure(999); clf
for i = 1:size(C,1)
%     if i == 10 || i == 12 || i == 15
%         k = k+q;
%         continue
%     end
    exIdx = k:k+q-1;
    thisLabel = find(testOut==i);
    misclassIdx = setdiff(thisLabel,exIdx);
    
    subplot(4,4,n)
    imagesc([],f,testMSPICIWV(misclassIdx,1:188)');
    set(gca,'ydir','normal');
    title(types{n});
    
    n = n+1;
    k = k+q;
end

suplabel('Bin','x');
suplabel('Frequency (kHz)','y');
suplabel('Incorrectly Labeled Spectra by Predicted Class','t');

saveas(gcf,fullfile(testDir,'MisclassSpecs'),'tiff');

%% Precision/Recall Curves

% Percent of data set classified vs. prediction confidence
maxprobs = max(probs,[],2);
thresh = [0,0.25,0.5,0.75,0.8,0.85,0.9,0.95,0.98,0.99,1];
k = 1;
n = 1;
figure(9999); clf
for iA = 1:size(C,1)
%     if iA==10 || iA==12 || iA==15
%         k = k+q;
%         continue
%     end
    
    classProp = zeros(length(thresh),1,1);
    for iB = 1:length(thresh)       
        meetsThresh = maxprobs(k:k+q-1)>= thresh(iB);
        classProp(iB) = sum(meetsThresh)/q;
    end
    AUC = trapz(thresh,classProp);
    
    figure(9999)
    subplot(4,4,n)
    plot(thresh,classProp)
    title(types{n});
    xlim([0 1]);
    ylim([0 1]);
    text(0.05,0.15,['AUC: ',num2str(AUC)]);
    grid on
    
    k = k+q;
    n = n+1;
end

suplabel('Label Confidence','x');
suplabel('% Recall','y');
suplabel('% True Set Classified vs. Prediction Confidence','t');

saveas(gcf,fullfile(testDir,'PrecisionRecall_1'),'tiff');


% Percent correct labels vs. prediction confidence
maxprobs = max(probs,[],2);
thresh = [0,0.25,0.5,0.75,0.8,0.85,0.9,0.95,0.98,0.99,1];
k = 1;
n = 1;
figure(99999); clf
for iA = 1:size(C,1)
%     if iA==10 || iA==12 || iA==15
%         k = k+q;
%         continue
%     end
%     
    correctProp = zeros(length(thresh),1,1);
    for iB = 1:length(thresh)   
        thisLabel = find(testOut==iA); % find indices of everything labeled this class
        CTind = k:k+q-1; % indices that are truly this class
        notCTind = setdiff(1:length(maxprobs),k:k+q-1); % indices incorrectly labeled this class
        meetsThresh = find(maxprobs>= thresh(iB)); % indices of all labels with prob >= this thresh value
        meetsThresh_true = intersect(intersect(meetsThresh,CTind),thisLabel); % indices of everything truly this class which was labeled this class with certainty >= this thresh value
        meetsThresh_false = intersect(intersect(meetsThresh,notCTind),thisLabel); % indices of everything incorrectly labeled this class with certainty >= this thresh value
        
        correctProp(iB) = length(meetsThresh_true)/(length(meetsThresh_true)+length(meetsThresh_false)); % proportion of everything labeled this class which was actually correct
        if isnan(correctProp(iB))
            correctProp(iB) = 0;
        end
    end
    AUC = trapz(thresh,correctProp);
    
    figure(99999)
    subplot(4,4,n)
    plot(thresh,correctProp)
    title(types{n});
    xlim([0 1]);
    ylim([0 1]);
    text(0.05,0.15,['AUC: ',num2str(AUC)]);
    grid on
    
    k = k+q;
    n = n+1;
end

suplabel('Label Confidence','x');
suplabel('% Correctly Labeled','y');
suplabel('% Correctly Classified vs. Prediction Confidence','t');

saveas(gcf,fullfile(testDir,'PrecisionRecall_2'),'tiff');

%%
% q = 1;
% k = 1;
% figure(9999)
% for n = 1:size(C,1)
%     if n==10 || n==12 || n==15
%         continue
%     else
%         %         tp =  sum(testOut(q:q+5000)==n)/5000;
%         %         fp = (sum(testOut==n)-sum(testOut(q:q+5000)==n))/90000;
%         %         fn = sum(testOut(q:q+5000)~=n)/5000;
%         %         prec = tp/(tp+fp);
%         %         rec = tp/(tp+fn);
%         labels = double(testLabelSet==n);
%         scores = double(testOut==n);
%         [X,Y] = perfcurve(labels, scores, 1, 'XCrit', 'tpr', 'YCrit', 'prec');
%         subplot(4,4,k)
%         plot(X,Y)
%         xlim([0 1]);
%         ylim([0 1]);
%         title(types{k})
%     end
%     suplabel('Recall','x');
%     suplabel('Precision','y');
%     suplabel('Precision-Recall Curves','t');
%    
%     q = (n*5000)+1;
%     k = k+1;
% end
% 
% saveas(gcf,fullfile(testDir,'PrecisionRecall'),'tiff');
