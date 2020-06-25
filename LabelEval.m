%load zID & TPWS file
% Note: zID col 2 are indices, not labels
labelSet = unique(zID(:,2));
site = 'WAT\_WC';

for i = 1:length(labels)
   
    [~,thisLabel,~] = intersect(MTT,zID(zID(:,2)==i,1));
    if ~isempty(thisLabel)
        specSet = MSP(thisLabel,:);
        specSetNorm = specSet - min(specSet,[],2);
        specSetNorm = specSetNorm./max(specSetNorm,[],2);
        RLSet = MPP(thisLabel);
        
        figure
        subplot(1,2,1)
        imagesc([],f,specSetNorm');
        title(['CatSpecs, Label: ',labels{1,i},' ',site]);
        xlabel('Click Number');
        ylabel('Frequency (kHz)');
        set(gca,'ydir','normal');
        colormap(jet);
        
        subplot(1,2,2)
        histogram(RLSet);
        title(['Received Levels, Label: ',labels{1,i},' ',site]);
        xlabel('Amplitude (dB re 1 \muPa)');
        ylabel('Counts');
    end
    
end

%% Compare temporal occurrence of types
% load composite_clusters output for desired types as separate variables
% plot variables belonging to same CT as same color
figure
plot(type7.thisType.tIntMat,1,'r*')
hold on
plot(type11.thisType.tIntMat,1,'r*')
plot(type1.thisType.tIntMat,1,'b*')
plot(type9.thisType.tIntMat,1,'b*')
plot(type10.thisType.tIntMat,1,'b*')
plot(type22.thisType.tIntMat,1,'b*')
ylim([0 2]);
datetick('x',26);
hold off
title('CompositeClusters\_7 CT3 & CT7 (Types 1,7,9,10,11,22)');