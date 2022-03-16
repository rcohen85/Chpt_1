%% Takes gridded SST data and plots western North Atlantic region with HARP locations on top

myFile = fullfile('H:\Data\MODIS_Aqua_MIDIR_8day_SST','A20181532018160.L3m_8D_SST4_sst4_4km.nc');

% Load data from NetCDF file:
SST = ncread(myFile,'sst4');
Lat = ncread(myFile,'lat');
Long = ncread(myFile,'lon');

[Lon_mat Lat_mat] = meshgrid(Long,Lat);
SST = SST';

% imagesc(SST) % just plot SST data real quick to take a look at it

% Trim data to western N Atl:
[maxlatval maxlat] = min(abs(Lat-47));
[minlatval minlat] = min(abs(Lat-22));
[maxlonval maxlon] = min(abs(Long-(-85)));
[minlonval minlon] = min(abs(Long-(-60)));

Atl_sst = SST(maxlat:minlat, maxlon:minlon);
Atl_lat = Lat(maxlat:minlat);
Atl_lon = Long(maxlon:minlon);

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
    30.27818 -80.22085];      % JAX

% Find HARP indices in lat/lon vecs
ind = [];
for i = 1:size(HARPs,1)
    [q ind1] = min(abs(Atl_lat-HARPs(i,1)));
    [q ind2] = min(abs(Atl_lon-(HARPs(i,2))));
    ind = [ind;ind1 ind2];
end

figure(1)
colormap parula
% clims = [0 35];
deg = char(176);
% imagesc(Atl_sst,clims);
imagesc(Atl_sst);
h = colorbar
% hold on % Plot HARPs as different color stars based on typical water temps
% plot(ind(1:5,2),ind(1:5,1),'pk','MarkerFaceColor','m','MarkerSize',13);
% plot(ind(6:7,2),ind(6:7,1),'pk','MarkerFaceColor','y','MarkerSize',13);
% plot(ind(8:11,2),ind(8:11,1),'pk','MarkerFaceColor','c','MarkerSize',13);
% hold off
hold on % Plot HARPs as magenta circles
plot(ind(:,2),ind(:,1),'ow','MarkerFaceColor','r','MarkerSize',9,'LineWidth',1);
hold off
yticks([49 169 289 409 529]);
yticklabels({['45' deg 'N'],['40' deg 'N'],['35' deg 'N'], ['30' deg 'N'], ['25' deg 'N']})
xticks([121 241 361 481 601]);
xticklabels({['80' deg 'W'],['75' deg 'W'],['70' deg 'W'], ['65' deg 'W'], ['60' deg 'W']})
% xlabel('Longitude');
% ylabel('Latitude');
ylabel(h,['SST (' deg 'C)']);
% title({'Atlantic Autonomous Passive', 'Acoustic Monitoring Sites'});
% set(gca,'fontSize',23);
set(gca,'fontSize',11);
for i = 1:size(sites,2)
%     if i >= 1 && i <= 5
%         text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','m','FontWeight','bold');
%     elseif i >= 6 && i <= 7
%         text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','k','FontWeight','bold');
%     elseif i >= 8 && i <= 11
%         text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',16,'color','b','FontWeight','bold');
%     end

text(ind(i,2),ind(i,1),['  ' sites{i}],'FontSize',12,'color','k','FontWeight','bold');
end

saveas(gcf,fullfile('H:\Data','Atl_HARP_Sites_SST'),'tiff');

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

lat_lims = [24 44];
lon_lims = [-82.00 -64.5];

h = figure(1)
gb = geobubble(HARPs(:,1),HARPs(:,2),'BubbleWidthRange',15,'BubbleColorList',[255 0 0]./255,'LegendVisible','off');
geolimits(lat_lims,lon_lims)
gb.Basemap = 'landcover';
% title({'Atlantic Autonomous Passive', 'Acoustic Monitoring Sites'});
set(gca,'FontSize',16);
for i = 1:size(sites,2)
   t = uicontrol(h,'Style','text','String',sites{i},'Position',[HARPs(i,:)+[0 1],60,20]);
end

saveas(gcf,fullfile('I:\Figures','Atl_HARP_Sites'),'tiff');
print('-painters','-depsc',fullfile('I:\Figures','Atl_HARP_Sites'));
