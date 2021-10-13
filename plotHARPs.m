%% Takes gridded SST data and plots western North Atlantic region with HARP locations on top

myFile = fullfile('C:\Users\RCohen\Downloads','AQUA_MODIS.20200601_20200630.L3m.MO.NSST.sst.4km.nc');

% Load data from NetCDF file:
SST = ncread(myFile,'sst');
Lat = ncread(myFile,'lat');
Long = ncread(myFile,'lon');

[Lon_mat Lat_mat] = meshgrid(Long,Lat);
SST = SST';

% imagesc(SST) % just plot SST data real quick to take a look at it

% Trim data to western N Atl:
[maxlatval maxlat] = min(abs(Lat-47));
[minlatval minlat] = min(abs(Lat-22));
[maxlonval maxlon] = min(abs(Long+85));
[minlonval minlon] = min(abs(Long+60));

Atl_sst = SST(maxlat:minlat, maxlon:minlon);
Atl_lat = Lat(maxlat:minlat);
Atl_lon = Long(maxlon:minlon);

% Atl Harp sites
sites = {'HZ', 'OC', 'NC', 'BC', 'WC', 'NFC', 'HAT', 'GS', 'BP', 'BS', 'JAX'};
HARPs = [41.06165 66.35155;  % WAT_HZ
    40.22999 67.97798;       % WAT_OC
    39.83295 69.98194;       % WAT_NC
    39.19192 72.22735;       % WAT_BC
    38.37337 73.36985;       % WAT_WC
    37.16452 74.46585;       % NFC
    35.30183 74.87895;       % HAT
    33.66992 75.9977;        % WAT_GS
    32.10527 77.09067;       % WAT_BP
    30.58295 77.39002;       % WAT_BS
    30.27818 80.22085];      % JAX

% Find HARP indices in lat/lon vecs
ind = [];
for i = 1:size(HARPs,1)
    [q ind1] = min(abs(Atl_lat-HARPs(i,1)));
    [q ind2] = min(abs(Atl_lon+HARPs(i,2)));
    ind = [ind;ind1 ind2];
end

figure(1)
colormap jet
clims = [0 35];
deg = char(176);
imagesc(Atl_sst,clims);
h = colorbar
hold on % Plot HARPs as different color stars based on typical water temps
plot(ind(1:5,2),ind(1:5,1),'pk','MarkerFaceColor','m','MarkerSize',13);
plot(ind(6:7,2),ind(6:7,1),'pk','MarkerFaceColor','y','MarkerSize',13);
plot(ind(8:11,2),ind(8:11,1),'pk','MarkerFaceColor','c','MarkerSize',13);
hold off
yticks([49 169 289 409 529]);
yticklabels({['45' deg],['40' deg],['35' deg], ['30' deg], ['25' deg]})
xticks([121 241 361 481 601]);
xticklabels({['80' deg],['75' deg],['70' deg], ['65' deg], ['60' deg]})
xlabel('Longitude');
ylabel('Latitude');
ylabel(h,['SST (' deg 'C)']);
title({'Atlantic Autonomous Passive', 'Acoustic Monitoring Sites'});
% set(gca,'fontSize',23);
set(gca,'fontSize',20);
for i = 1:size(sites,2)
    if i >= 1 && i <= 5
        text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','m','FontWeight','bold');
    elseif i >= 6 && i <= 7
        text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','k','FontWeight','bold');
    elseif i >= 8 && i <= 11
        text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','b','FontWeight','bold');
    end
end

saveas(gcf,fullfile('G:\Figures','Atl_HARP_Sites'),'tiff');

%% Plot HARP locations on high resolution map


% Atl Harp sites
sites = {'HZ', 'OC', 'NC', 'BC', 'WC', 'NFC', 'HAT', 'GS', 'BP', 'BS', 'JAX'};
HARPs = [41.06165 -66.35155;  % WAT_HZ
    40.22999 -67.97798;       % WAT_OC
    39.83295 -69.98194;       % WAT_NC
    39.19192 -72.22735;       % WAT_BC
    38.37337 -73.36985;       % WAT_WC
    37.16452 -74.46585;       % NFC
    35.30183 -74.87895;       % HAT
    33.66992 -75.9977;        % WAT_GS
    32.10527 -77.09067;       % WAT_BP
    30.58295 -77.39002;       % WAT_BS
    30.27818 -80.22085];      % JAX_D

% pos = [1530 735 100 40];

lat_lims = [24 46];
lon_lims = [-82.00 -63];

h = figure(1)
gb = geobubble(HARPs(:,1),HARPs(:,2),'BubbleWidthRange',10,'BubbleColorList',[255 0 0]./255,'LegendVisible','off');
geolimits(lat_lims,lon_lims)
gb.Basemap = 'landcover';
% title({'Atlantic Autonomous Passive', 'Acoustic Monitoring Sites'});
set(gca,'FontSize',12);
for i = 1:size(sites,2)
   t = uicontrol(h,'Style','text','String',sites{i},'Position',(HARPs(i,:)+[0 1]));
end

saveas(gcf,fullfile('I:\Figures','Atl_HARP_Sites'),'tiff');
print('-painters','-depsc',fullfile('I:\Figures','Atl_HARP_Sites'));
