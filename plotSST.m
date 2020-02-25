clearvars

baseDir = 'F:\Data\GHRSST_2016-2017'; % directory containing SST .nc files
saveDir = 'F:\Data\GHRSST_2016-2017\Plots'; % directory to save plots
stDt = '05-01-2016';
endDt = '04-30-2017';
interval = 8; % # days over which SST is averaged

%sites = {'HZ', 'OC', 'NC', 'BC', 'WC', 'NFC', 'HAT', 'GS', 'BP', 'BS', 'JAX'};
sites = {'NFC'};
% HARPs = [41.06165 66.35155;
%     40.22999 67.97798;
%     39.83295 69.98194;
%     39.19192 72.22735;
%     38.37337 73.36985;
%     37.16452 74.46585;
%     35.30183 74.87895;
%     33.66992 75.9977;
%     32.10527 77.09067;
%     30.58295 77.39002;
%     30.27818 80.22085];
HARPs = [37.16452 74.46585];

% Iteratively load SST files and extract data from HARP sites:
cd(baseDir)
fileSet = dir('*.nc');
lfs = length(fileSet);

sst_mat = zeros(size(sites,2),lfs);

for i = 1:lfs
    fileName = fileSet(i).name;
    sst = ncread(fileName,'analysed_sst');
    sst = sst';
    lat = ncread(fileName,'lat');
    lon = ncread(fileName,'lon');
    for j = 1:size(sites,2)
        [v, lat_ind] = min(abs(lat-HARPs(j,1)));
        [v, lon_ind] = min(abs(lon+HARPs(j,2)));
        sst_mat(j,i) = sst(lat_ind,lon_ind);
    end
end

% Plot timeseries for each HARP site:
daterange = datenum(stDt):datenum(interval):datenum(endDt);
deg = char(176);

cd(saveDir);
for i = 1:size(sites,2)
plot(daterange,sst_mat(i,:),'o','MarkerSize',15,'LineWidth',6);
ylim([min(min(sst_mat))-5, max(max(sst_mat))+5]);
datetick('x');
xtickangle(45);
ylabel([deg 'C']);
xlabel('2018');
title(sprintf('8-day Averaged SST at Site %s',cell2mat(sites(i))));
ax = gca;
ax.FontSize = 40;
saveas(gcf,sprintf('SST_%s',cell2mat(sites(i))),'tiff');
end
