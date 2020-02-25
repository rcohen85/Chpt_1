% load BoutSpecs file created by goodBout_clicks_noise

specs = vertcat(BoutSpecs{:});
ICI = vertcat(BoutICI{:});

% Create vector of click numbers delineating bout ends
q = length(BoutSpecs{1});
for i = 2:length(BoutSpecs)-1
    q(i) = q(i-1) + length(BoutSpecs{i});
end
k = [q(11),q(14),q(18)]; % vector delineating different cruises

figure(98)
subplot(2,1,1)
imagesc([],fvec{1},specs')
set(gca,'ydir','normal','fontSize',14);
colormap(jet)
ylabel('Frequency (kHz)')
title('Gsp TA Bouts: Concatenated Spectra');
for i = 1:length(q)
    line(repmat(q(i),183),fvec{1},'Color','b','LineWidth',2);
end
subplot(2,1,2)
plot(ICI,'.')
ylim([0 0.3]);
xlim([0 length(ICI)]);
xlabel('Click Number');
ylabel('ICI (s)');
set(gca,'fontSize',14);
grid on
saveas(gcf,'Gsp_AllCatSpec_byBout.tif','tiff');

figure(99)
subplot(2,1,1)
imagesc([],fvec{1},specs')
set(gca,'ydir','normal','fontSize',14);
colormap(jet)
ylabel('Frequency (kHz)')
xticks([4000]);
xticklabels({'GU1304'});
xtickangle(35);
title('Gsp TA Bouts: Concatenated Spectra');
for i = 1:length(k)
    line(repmat(k(i),length(fvec{1})),fvec{1},'Color','b','LineWidth',2);
end
subplot(2,1,2)
plot(ICI,'.')
ylim([0 0.3]);
xlim([0 length(ICI)]);
xlabel('Click Number');
ylabel('ICI (s)');
set(gca,'fontSize',14);
grid on
saveas(gcf,'Gsp_AllCatSpec_byCruise.tif','tiff');

