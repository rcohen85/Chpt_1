%% Find bins of each class which were apparently misclassified by the neural
% net and plot spectra and ICI to determine if they were mistakenly
% included in their respective test sets to begin with (e.g. some bin specs
% included in the sperm whale train/test set are actually boats which have
% been misclassified by the clustering or manual labeling step)

% Update this section for each new test output and each class you wish to
% consider

baseDir = 'G:\cluster_NNet\TrainTest'; % folder where test set lives
testDir = fullfile(baseDir,'20200625-144042'); % folder where nnet output lives
load(fullfile(baseDir,'TestSet_MSPICIWV_500.mat')); % update name of testing data file
load(fullfile(testDir,'TestOutput'));
testOut = double(testOut'+1);

n = 500; % number of training examples of each class
sp = 'CT4/6+CT10';
lab = 6; % label of class of interest in test label set

%%
ind = (lab-1)*n+1:lab*n; % indices of class of interest in test set
outName = ['Misclassed_' sp];

q = find(testOut(ind)~=lab);
q = q+ind(1)-1;
nl = 3; % number of rows of subplots, one subplot per bin
ml = ceil(length(q)/nl); % number of columns of subplots
labEval = [];

figure(1)
for i = 1:length(q)
    subplot(1,2,1)
    plot(5.5:0.5:99,testMSPICIWV(q(i),1:188));
    text(60,0.85,{'Predicted',['Label: ', num2str(testOut(q(i)))]});
    xlabel('Frequency (kHz)');
    ylabel('Normalized Amplitude');
    
    subplot(1,2,2)
      bar(0:0.01:1,testMSPICIWV(q(i),190:290));
    text(0.6,0.85,{'Predicted',['Label: ', num2str(testOut(q(i)))]});
    xlim([0 1]);
    xlabel('Seconds');
    ylabel('Counts');
    
    suplabel(['Misclassified Bin ',num2str(i),' of ',num2str(length(q))],'t');
    
    % take user input to decide if NNet label is correct or not
    a = input('Enter 1 for correct, 0 for incorrect, or 2 for uncertain\n');
    labEval = [labEval;a];
end

corrClass = sum(labEval==1);
corrClassProp = corrClass/length(q)*100;
fprintf('NNet correctly labeled %.2f %% of "misclassified" %s bins\n',corrClassProp,sp);

textColors = {};
for i = 1:length(q)
    
    if labEval(i)==1
   textColors{i} = [0.4660 0.6740 0.1880];
    elseif labEval(i)==0
        textColors{i} = [1 0 0];
    elseif labEval(i)==2
        textColors{i} = [0.9290 0.6940 0.1250];
    end
end

figure(2)
clf
for i = 1:length(q)
    subplot(nl,ml,i)
    plot(5.5:0.5:99,testMSPICIWV(q(i),1:188));
    text(60,0.85,{'Predicted',['Label: ', num2str(testOut(q(i)))]},...
        'Color',textColors{i});
    xlabel('Frequency (kHz)');
    ylabel('Normalized Amplitude');
end
suplabel(['Mean Spectra of "Misclassified" ',sp,' Bins'],'t');

figure(3)
clf
for i = 1:length(q)
    subplot(nl,ml,i)
    bar(0:0.01:1,testMSPICIWV(q(i),190:290));
    text(0.6,0.85,{'Predicted',['Label: ', num2str(testOut(q(i)))]},...
        'Color',textColors{i});
    xlim([0 1]);
    xlabel('Seconds');
    ylabel('Counts');
end
suplabel(['ICI Distributions of "Misclassified" ',sp,' Bins'],'t');


% saveas(figure(2),fullfile(testDir,[outName '_Specs']),'tiff');
% saveas(figure(3),fullfile(testDir,[outName '_ICIdists']),'tiff');

