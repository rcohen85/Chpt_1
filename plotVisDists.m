%% Plot OBIS Visual data as seasonal maps

clearvars

sp = 'Zc';
comName = 'Cuvier''s Beaked Whale';
sightDir = 'J:\OBIS_Vis_data';
effortDir = 'J:\OBIS_Vis_data\DataSets\Effort';
mapSaveDir = 'J:\OBIS_Vis_data\Seasonal_Maps';

% Set lat/long limits to plot only your region of interest
% lat_lims = [25.34 45.66];
% lon_lims = [-81.52 -60.90];
lat_lims = [24 46];
lon_lims = [-82.00 -63];

load(fullfile(effortDir,'All_Survey_Tracks.mat'));
load(fullfile(effortDir,'All_Seasonal_Tracks.mat'));

%% Load sighting data, find data points missing datetime info

a = readtable(fullfile(sightDir,sp,'Datapoints.csv'));
a = sortrows(a,20);
if iscell(a.date_time)
    miss_ind = find(cellfun(@isempty,a.date_time));
else
    miss_ind = find(isempty(a.date_time));
end
tot = 1:length(a.date_time);
keep_ind = setdiff(tot,miss_ind);

% Pull observation datetimes, locations, group sizes, species, and obs
% platform info
if iscell(a.date_time)
    dat.obs_dnum = datenum(cell2mat(a.date_time(keep_ind)));
%     dat.obs_dvec = datevec(cell2mat(a.date_time(keep_ind)));
else
    dat.obs_dnum = datenum(a.date_time(keep_ind));
%     dat.obs_dvec = datevec(a.date_time(keep_ind));
end
dat.latlon = [a.latitude(keep_ind), a.longitude(keep_ind)];
dat.grp_sz = a.count(keep_ind);
dat.spec = a.scientific(keep_ind);
dat.plat = a.platform(keep_ind);

%% Load survey track lines and compile into one big array

% fileList = dir([effortDir,'\*_lines_csv.csv']);
% lines = [];
% win_lines = [];
% spr_lines = [];
% sum_lines = [];
% fall_lines = [];
% l = [];
% 
% % Compile all track segments into one file, as well as into files by season;
% % formatted for plotting w geoshow
% tic
% for n = 1:length(fileList)
%     
%     fprintf('Getting survey tracks from file %d of %d\n',n,size(fileList,1))
%     s = readtable(fullfile(effortDir,fileList(n).name));
%     
%     if any(strcmp('lon_s',s.Properties.VariableNames))
%         lons = table2array(s(:,'lon_s')); % Segment start long
%         lats = table2array(s(:,'lat_s')); % Segment start lat
%         lone = table2array(s(:,'lon_e')); % Segment end long
%         late = table2array(s(:,'lat_e')); % Segment end lat
%     elseif any(strcmp('beglon',s.Properties.VariableNames))
%         lons = table2array(s(:,'beglon'));
%         lats = table2array(s(:,'beglat'));
%         lone = table2array(s(:,'endlon'));
%         late = table2array(s(:,'endlat'));
%     else
%         fprintf('Warning: Can"t parse segment start/end lat/lons for trackline file %d of %d\n',n,length(fileList))
% %         return
%     end
%     
%     if any(strcmp('datetime_s',s.Properties.VariableNames))
%         segSt = datenum(table2array(s(:,'datetime_s')));
%         stDvec = datevec(table2array(s(:,'datetime_s')));
%         segEnd = datenum(table2array(s(:,'datetime_e')));
%     elseif any(strcmp('z_beg_datetime',s.Properties.VariableNames))
%         segSt = datenum(table2array(s(:,'z_beg_datetime')));
%         stDvec = datevec(table2array(s(:,'z_beg_datetime')));
%         segEnd = datenum(table2array(s(:,'z_end_datetime')));
%     else
%         fprintf('Warning: Can"t parse segment start/end dates for trackline file %d of %d\n',n,length(fileMatchIdx))
%         return
%     end
%     
%     dataIDs = table2array(s(:,'dataset_id'));
%     
%     % Find indices of segments which start or end within lat/lon region of interest
%     a = find(lats>=lat_lims(1) & lats<=lat_lims(2));
%     b = find(late>=lat_lims(1) & late<=lat_lims(2));
%     c = find(lons>=lon_lims(1) & lons<=lon_lims(2));
%     d = find(lone>=lon_lims(1) & lone<=lon_lims(2));
%     idx = unique([a;b;c;d]);
%     
%     for i = 1:length(idx)
%         if ~isnan(lons(i)) && ~isnan(lats(i)) && ~isnan(lons(i)) && ~isnan(lone(i))
%             l(1,1) = lons(idx(i));
%             l(1,2) = lats(idx(i));
%             l(1,3) = segSt(idx(i));
%             l(2,1) = lone(idx(i));
%             l(2,2) = late(idx(i));
%             l(2,3) = segEnd(idx(i));
%             l(1:2,4) = dataIDs(idx(i));
%             l(3,:) = NaN;
%             
%             lines = [lines;l];
%             
%             if stDvec(idx(i),2)==12 | stDvec(idx(i),2)==1 | stDvec(idx(i),2)==2
%                 win_lines = [win_lines;l];
%             elseif stDvec(idx(i),2)==3 | stDvec(idx(i),2)==4 | stDvec(idx(i),2)==5
%                 spr_lines = [spr_lines;l];
%             elseif stDvec(idx(i),2)==6 | stDvec(idx(i),2)==7 | stDvec(idx(i),2)==8
%                 sum_lines = [sum_lines;l];
%             elseif stDvec(idx(i),2)==9 | stDvec(idx(i),2)==10 | stDvec(idx(i),2)==11
%                 fall_lines = [fall_lines;l];
%             end
%             
%             if rem(i,100)==0
%                 fprintf('Done with index %d of %d\n',i,length(idx))
%             end
%         end
%     end
%     % if n==1
%     %     save('Survey_Tracks4','lines');
%     %     save('Seasonal_Tracks4','win_lines','spr_lines','sum_lines','fall_lines');
%     % else
%     %     save('Survey_Tracks','lines','-append'); % Save after each file in case of crashes
%     %     save('Seasonal_Tracks','win_lines','spr_lines','sum_lines','fall_lines','-append');
%     % end
%     
% end
% toc
% 
% save(fullfile(effortDir,'Survey_Tracks'),'lines');
% save(fullfile(effortDir,'Seasonal_Tracks'),'win_lines','spr_lines','sum_lines','fall_lines');


%% Plot all sightings across all years
% grey  = [200 200 200]./255;
% 
% figure(1)  % Plot all sightings & tracklines for all years of data
% clf
% worldmap(lat_lims,lon_lims);
% load coastlines
% plotm(coastlat,coastlon,'k','LineWidth',2);
% geoshow(lines(:,2),lines(:,1),'Color',grey);
% c = plotm(dat.latlon(:,1),dat.latlon(:,2),'.','MarkerSize',10);
% title([comName,' Sightings']);
% set(gca,'fontSize',14)
% numsit = string(length(dat.obs_dnum));
% label1 = strcat('N = ',numsit);
% h = legend(c,label1,'Location','southeast');
% set(h,'fontSize',14);
% 
% cd(saveDir)
% saveName = [sp,' All Sightings'];
% saveas(figure(1),saveName,'fig')
% saveas(figure(1),saveName,'tiff') 

%% Plot seasonal sightings and tracklines across all years
% option to add total # individuals sighted per season in legend

% HARP locations
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

% Split up sightings by season
dvec = datevec(dat.obs_dnum);
win_ind = (find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2));
spr_ind = (find(dvec(:,2)>=3 & dvec(:,2)<=5));
sum_ind = (find(dvec(:,2)>=6 & dvec(:,2)<=8));
fall_ind = (find(dvec(:,2)>=9 & dvec(:,2)<=11));

lwin = string(length(win_ind));
lspr = string(length(spr_ind));
lsum = string(length(sum_ind));
lfall = string(length(fall_ind));

grey  = [200 200 200]./255;

figure(10)
clf
% % subplot('Position',[0.15 0.48 0.25 0.444]);
subplot('Position',[0.05 0.12 0.175 0.7]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(win_lines(:,2),win_lines(:,1),'Color',grey);
if ~isempty(win_ind)
    c = plotm(dat.latlon(win_ind,1),dat.latlon(win_ind,2),'.','MarkerSize',12);
else
    c = plotm(NaN,NaN);
end
plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
title('Winter');
set(gca,'fontSize',12);
label1 = strcat('N = ',lwin);
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(win_ind),'omitnan')),' Individuals');
[~, objH] = legend([c,b],label1,label2,'Position',[0.12 0.21 0.08 0.033]);
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.15 pos(2:3)]);

% subplot('Position',[0.575 0.48 0.25 0.444]);
subplot('Position',[0.28 0.12 0.175 0.7]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(spr_lines(:,2),spr_lines(:,1),'Color',grey);
if ~isempty(spr_ind)
    c = plotm(dat.latlon(spr_ind,1),dat.latlon(spr_ind,2),'.','MarkerSize',12);
else
    c = plotm(NaN,NaN);
end
plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
title('Spring');
set(gca,'fontSize',12);
label1 = strcat('N = ',lspr);
% h = legend(c,label1,'Position',[0.71 0.6 0.095 0.033]);
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(spr_ind),'omitnan')),' Individuals');
[~, objH] = legend([c,b],label1,label2,'Position',[0.35 0.21 0.08 0.033]);
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.15 pos(2:3)]);

% subplot('Position',[0.575 0.028 0.25 0.444]);
subplot('Position',[0.51 0.12 0.175 0.7]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(sum_lines(:,2),sum_lines(:,1),'Color',grey);
if ~isempty(sum_ind)
    c = plotm(dat.latlon(sum_ind,1),dat.latlon(sum_ind,2),'.','MarkerSize',12);
else
    c = plotm(NaN,NaN);
end
plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
title('Summer');
set(gca,'fontSize',12);
label1 = strcat('N = ',lsum);
% h = legend(c,label1,'Position',[0.71 0.15 0.095 0.033]);
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(sum_ind),'omitnan')),' Individuals');
[~, objH] = legend([c,b],label1,label2,'Position',[0.58 0.21 0.08 0.033]);
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.15 pos(2:3)]);

% subplot('Position',[0.0969 0.028 0.25 0.444]);
% subplot('Position',[0.15 0.028 0.25 0.444]);
subplot('Position',[0.74 0.12 0.175 0.7]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(fall_lines(:,2),fall_lines(:,1),'Color',grey);
if ~isempty(fall_ind)
    c = plotm(dat.latlon(fall_ind,1),dat.latlon(fall_ind,2),'.','MarkerSize',12);
else
    c = plotm(NaN,NaN);
end
plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
title('Fall');
set(gca,'fontSize',12);
label1 = strcat('N = ',lfall);
% h = legend(c,label1,'Position',[0.285 0.15 0.095 0.033]);
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(fall_ind),'omitnan')),' Individuals');
[~, objH] = legend([c,b],label1,label2,'Position',[0.81 0.21 0.08 0.033]);
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.15 pos(2:3)]);

[ax,h3]=suplabel([comName,' Sightings'] ,'t',[.05 .05 .85 .89] );
set(ax,'fontSize',14)

% Save seasonal plots
saveName = [sp,' Seasonal Sightings and Tracklines'];
saveas(figure(10),fullfile(mapSaveDir,saveName),'tiff') 
% print('-painters','-depsc',fullfile(mapSaveDir,saveName));


%% Plot sightings and tracklines separately to later combine in Adobe Illustrator
% 
% % HARP locations
% HARPs = [41.06165 -66.35155;  % WAT_HZ
%     40.22999 -67.97798;       % WAT_OC
%     39.83295 -69.98194;       % WAT_NC
%     39.19192 -72.22735;       % WAT_BC
%     38.37337 -73.36985;       % WAT_WC
%     37.16452 -74.46585;       % NFC
%     35.30183 -74.87895;       % HAT
%     33.66992 -75.9977;        % WAT_GS
%     32.10527 -77.09067;       % WAT_BP
%     30.58295 -77.39002;       % WAT_BS
%     30.27818 -80.22085];      % JAX_D
% 
% % Split up sightings by season
% dvec = datevec(dat.obs_dnum);
% win_ind = (find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2));
% spr_ind = (find(dvec(:,2)>=3 & dvec(:,2)<=5));
% sum_ind = (find(dvec(:,2)>=6 & dvec(:,2)<=8));
% fall_ind = (find(dvec(:,2)>=9 & dvec(:,2)<=11));
% 
% lwin = string(length(win_ind));
% lspr = string(length(spr_ind));
% lsum = string(length(sum_ind));
% lfall = string(length(fall_ind));
% 
% 
% % % Plot tracklines & HARPs
% % lat_lims = [24 46];
% % lon_lims = [-82.00 -63];
% % grey  = [225 225 225]./255;
% % 
% % figure(10)
% % clf
% % % % subplot('Position',[0.15 0.48 0.25 0.444]);
% % subplot('Position',[0.05 0.12 0.175 0.7]);
% % worldmap(lat_lims,lon_lims);
% % setm(gca,'mapprojection','mercator');
% % geoshow(win_lines(:,2),win_lines(:,1),'Color',grey);
% % plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
% % title('Winter');
% % set(gca,'fontSize',12);
% % 
% % % subplot('Position',[0.575 0.48 0.25 0.444]);
% % subplot('Position',[0.28 0.12 0.175 0.7]);
% % worldmap(lat_lims,lon_lims);
% % setm(gca,'mapprojection','mercator');
% % geoshow(spr_lines(:,2),spr_lines(:,1),'Color',grey);
% % plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
% % title('Spring');
% % set(gca,'fontSize',12);
% % 
% % % subplot('Position',[0.575 0.028 0.25 0.444]);
% % subplot('Position',[0.51 0.12 0.175 0.7]);
% % worldmap(lat_lims,lon_lims);
% % setm(gca,'mapprojection','mercator');
% % geoshow(sum_lines(:,2),sum_lines(:,1),'Color',grey);
% % plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
% % title('Summer');
% % set(gca,'fontSize',12);
% % 
% % % subplot('Position',[0.0969 0.028 0.25 0.444]);
% % % subplot('Position',[0.15 0.028 0.25 0.444]);
% % subplot('Position',[0.74 0.12 0.175 0.7]);
% % worldmap(lat_lims,lon_lims);
% % setm(gca,'mapprojection','mercator');
% % geoshow(fall_lines(:,2),fall_lines(:,1),'Color',grey);
% % plotm(HARPs(:,1),HARPs(:,2),'*r','MarkerSize',6);
% % title('Fall');
% % set(gca,'fontSize',12);
% % 
% % [ax,h3]=suplabel('Tracklines & HARPs' ,'t',[.05 .05 .85 .89] );
% % set(ax,'fontSize',14)
% % 
% % saveas(figure(10),fullfile(mapSaveDir,'Tracklines_HARPs'),'tiff') 
% % print('-painters','-depsc',fullfile(mapSaveDir,'Tracklines_HARPs'));
% 
% % Plot sightings
% lat_lims = [26 44];
% lon_lims = [-82.00 -63];
% 
% figure(11),clf
% gb(1) = geobubble(dat.latlon(win_ind,1),dat.latlon(win_ind,2),ones(size(win_ind,1),1,1),...
%     'BubbleWidthRange',3,'InnerPosition',[0.05 0.12 0.175 0.7],'BubbleColorList',...
%     [0,0,255]./255,'ScalebarVisible','off','LegendVisible','off');
% gb(1).Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Winter');
% 
% gb(2) = geobubble(dat.latlon(spr_ind,1),dat.latlon(spr_ind,2),ones(size(spr_ind,1),1,1),...
%     'BubbleWidthRange',3,'InnerPosition',[0.28 0.12 0.175 0.7],'BubbleColorList',...
%     [0,0,255]./255,'ScalebarVisible','off','LegendVisible','off');
% gb(2).Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Spring');
% 
% gb(3) = geobubble(dat.latlon(sum_ind,1),dat.latlon(sum_ind,2),ones(size(sum_ind,1),1,1),...
%     'BubbleWidthRange',3,'InnerPosition',[0.51 0.12 0.175 0.7],'BubbleColorlist',...
%     [0,0,255]./255,'ScalebarVisible','off','LegendVisible','off');
% gb(3).Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Summer');
% 
% gb(4) = geobubble(dat.latlon(fall_ind,1),dat.latlon(fall_ind,2),ones(size(fall_ind,1),1,1),...
%     'BubbleWidthRange',3,'InnerPosition',[0.74 0.12 0.175 0.7],'BubbleColorList',...
%     [0,0,255]./255,'ScalebarVisible','off','LegendVisible','off');
% gb(4).Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Fall');
% 
% [ax,h3]=suplabel([comName,' Sightings'] ,'t',[.05 .05 .85 .89] );
% set(ax,'fontSize',14)
% 
% % Save seasonal plots
% saveas(figure(11),fullfile(mapSaveDir,[sp 'Sightings']),'tiff') 
% print('-painters','-depsc',fullfile(mapSaveDir,[sp 'Sightings']));
