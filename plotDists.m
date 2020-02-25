%% Plot OBIS Visual data as seasonal maps

% clear all

sp = 'Tt';
comName = 'Bottlenose Dolphin';
datDir = 'G:\OBIS_Vis_data';
saveDir = 'G:\OBIS_Vis_data\Seasonal_Maps';

% Set lat/long limits to plot only your region of interest
% lat_lims = [25.34 45.66];
% lon_lims = [-81.52 -60.90];
lat_lims = [25 45];
lon_lims = [-82.00 -62];

load([datDir,'\DataSets\Effort\All_Survey_Tracks.mat']);
load([datDir,'\DataSets\Effort\All_Seasonal_Tracks.mat']);

%% Load sighting data, find data points missing datetime info
cd([datDir,'\',sp]);

a = readtable('Datapoints.csv');
a = sortrows(a,20);
if iscell(a.date_time)
    miss_ind = find(cellfun(@isempty,a.date_time));
else
    miss_ind = find(isempty(a.date_time));
end
tot = [1:length(a.date_time)];
keep_ind = setdiff(tot,miss_ind);

% Are we looking at the right number of species?
q = unique(a.scientific);
fprintf('\nData contains sightings for %d species\n',length(q));

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
% cd([datDir,'\DataSets\Effort']);
% 
% fileList = cellstr(ls(cd));
% match = '.*_lines_csv';
% fileMatchIdx = find(~cellfun(@isempty,regexp(fileList,match))>0);
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
% for n = 113%:length(fileMatchIdx)
%     
% fprintf('Getting survey tracks from file %d of %d\n',n,length(fileMatchIdx))    
% s = readtable([cd,'\',fileList{fileMatchIdx(n)}]);
% 
% if any(strcmp('lon_s',s.Properties.VariableNames))
%     lons = table2array(s(:,'lon_s')); % Segment start long
%     lats = table2array(s(:,'lat_s')); % Segment start lat
%     lone = table2array(s(:,'lon_e')); % Segment end long
%     late = table2array(s(:,'lat_e')); % Segment end lat
% elseif any(strcmp('beglon',s.Properties.VariableNames))
%     lons = table2array(s(:,'beglon'));
%     lats = table2array(s(:,'beglat'));
%     lone = table2array(s(:,'endlon'));
%     late = table2array(s(:,'endlat'));
% else
%     fprintf('Warning: Can"t parse segment start/end lat/lons for trackline file %d of %d\n',n,length(fileMatchIdx))
%     return
% end
% 
% if any(strcmp('datetime_s',s.Properties.VariableNames))
%     segSt = datenum(table2array(s(:,'datetime_s')));
%     stDvec = datevec(table2array(s(:,'datetime_s')));
%     segEnd = datenum(table2array(s(:,'datetime_e')));
% elseif any(strcmp('z_beg_datetime',s.Properties.VariableNames))
%     segSt = datenum(table2array(s(:,'z_beg_datetime')));
%     stDvec = datevec(table2array(s(:,'z_beg_datetime')));
%     segEnd = datenum(table2array(s(:,'z_end_datetime')));
% else
%     fprintf('Warning: Can"t parse segment start/end dates for trackline file %d of %d\n',n,length(fileMatchIdx))
%     return
% end
% 
% dataIDs = table2array(s(:,'dataset_id'));
% 
% % Find indices of segments which start or end within lat/lon region of interest
% a = find(lats>=lat_lims(1) & lats<=lat_lims(2));
% b = find(late>=lat_lims(1) & late<=lat_lims(2));
% c = find(lons>=lon_lims(1) & lons<=lon_lims(2));
% d = find(lone>=lon_lims(1) & lone<=lon_lims(2));
% idx = unique([a;b;c;d]);
% 
% for i = 388592:length(idx)
%     if ~isnan(lons(i)) && ~isnan(lats(i)) && ~isnan(lons(i)) && ~isnan(lone(i))
%         l(1,1) = lons(idx(i));
%         l(1,2) = lats(idx(i));
%         l(1,3) = segSt(idx(i));
%         l(2,1) = lone(idx(i));
%         l(2,2) = late(idx(i));
%         l(2,3) = segEnd(idx(i));
%         l(1:2,4) = dataIDs(idx(i));
%         l(3,:) = NaN;
%         
%         lines = [lines;l];
%         
%         if stDvec(idx(i),2)==12 | stDvec(idx(i),2)==1 | stDvec(idx(i),2)==2
%             win_lines = [win_lines;l];
%         elseif stDvec(idx(i),2)==3 | stDvec(idx(i),2)==4 | stDvec(idx(i),2)==5
%             spr_lines = [spr_lines;l];
%         elseif stDvec(idx(i),2)==6 | stDvec(idx(i),2)==7 | stDvec(idx(i),2)==8
%             sum_lines = [sum_lines;l];
%         elseif stDvec(idx(i),2)==9 | stDvec(idx(i),2)==10 | stDvec(idx(i),2)==11
%             fall_lines = [fall_lines;l];
%         end
%         
%         if rem(i,100)==0
%             fprintf('Done with index %d of %d\n',i,length(idx))
%         end
%     end
% end
% % if n==1
% %     save('Survey_Tracks4','lines');
% %     save('Seasonal_Tracks4','win_lines','spr_lines','sum_lines','fall_lines');
% % else
% %     save('Survey_Tracks','lines','-append'); % Save after each file in case of crashes
% %     save('Seasonal_Tracks','win_lines','spr_lines','sum_lines','fall_lines','-append');
% % end
% 
% end
% toc
% 
% save('Survey_Tracks','lines');
% save('Seasonal_Tracks','win_lines','spr_lines','sum_lines','fall_lines');
% 

%% Plot all sightings across all years
grey  = [200 200 200]./255;

figure(1)  % Plot all sightings & tracklines for all years of data
clf
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(lines(:,2),lines(:,1),'Color',grey);
c = plotm(dat.latlon(:,1),dat.latlon(:,2),'.','MarkerSize',10);
title([comName,' Sightings']);
set(gca,'fontSize',14)
numsit = string(length(dat.obs_dnum));
label1 = strcat('N = ',numsit);
h = legend(c,label1,'Location','southeast');
set(h,'fontSize',14);

cd(saveDir)
saveName = [sp,' All Sightings'];
saveas(figure(1),saveName,'fig')
saveas(figure(1),saveName,'tiff') 

%% Plot all sightings in particular date range

% Pull out subset of sighting & trackline data by date
dvec = datevec(dat.obs_dnum);
ind = find(dvec(:,1)==2016 | dvec(:,1)==2017);
ldvec = datevec(lines(:,3));
lin_ind = find(ldvec(:,1)==2016 | ldvec(:,1)==2017 | isnan(ldvec(:,1)));
line_subset = lines(lin_ind,:);

figure(2)  % Plot sightings & tracklines only for years specified above
clf
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(line_subset(:,2),line_subset(:,1),'Color',grey);
if ~isempty(ind)
    c = plotm(dat.latlon(ind,1),dat.latlon(ind,2),'.','MarkerSize',10);
else
    c = plotm(NaN,NaN);
end
title([comName,' Sightings ''16-''17']);
set(gca,'fontSize',13)
numsit = string(length(dat.obs_dnum(ind)));
label1 = strcat('N = ',numsit);
b = plot(NaN,NaN);
label2 = strcat(string(sum(dat.grp_sz(ind),'omitnan')),' Total Individuals');
[~, objH] = legend([c,b],label1,label2,'Location','southeast');
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.08 pos(2:3)]);
set(objH(1:2),'fontSize',12);

cd(saveDir)
saveName = [sp,' All Sightings ''16-''17'];
saveas(figure(2),saveName,'fig')
saveas(figure(2),saveName,'tiff') 

%% Plot seasonal sightings across all years
% option to add total # individuals sighted per season in legend

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

figure(3)
clf
% subplot(2,2,1)
subplot('Position',[0.0965 0.48 0.25 0.444]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(win_lines(:,2),win_lines(:,1),'Color',grey);
if ~isempty(win_ind)
    c = plotm(dat.latlon(win_ind,1),dat.latlon(win_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Winter');
set(gca,'fontSize',12);
label1 = strcat('N = ',lwin);
h = legend(c,label1,'Location','southeast');
set(h,'fontSize',11)
% b = plot(NaN,NaN); % dummy point to allow another legend entry
% label2 = strcat(string(sum(dat.grp_sz(win_ind))),' Total Individuals');
% [~, objH] = legend([c,b],label1,label2,'Location','southeast');
% set(findobj(objH(5)),'Vis','off');
% pos = get(objH(2), 'Pos');
% set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot('Position',[0.0965 0.48 0.25 0.444]);
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(spr_lines(:,2),spr_lines(:,1),'Color',grey);
if ~isempty(spr_ind)
    c = plotm(dat.latlon(spr_ind,1),dat.latlon(spr_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Spring');
set(gca,'fontSize',12);
label1 = strcat('N = ',lspr);
h = legend(c,label1,'Location','southeast');
set(h,'fontSize',11)
% b = plot(NaN,NaN); % dummy point to allow another legend entry
% label2 = strcat(string(sum(dat.grp_sz(spr_ind))),' Total Individuals');
% [~, objH] = legend([c,b],label1,label2,'Location','southeast');
% set(findobj(objH(5)),'Vis','off');
% pos = get(objH(2), 'Pos');
% set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot(2,2,4)
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(sum_lines(:,2),sum_lines(:,1),'Color',grey);
if ~isempty(sum_ind)
    c = plotm(dat.latlon(sum_ind,1),dat.latlon(sum_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Summer');
set(gca,'fontSize',12);
label1 = strcat('N = ',lsum);
h = legend(c,label1,'Location','southeast');
set(h,'fontSize',11)
% b = plot(NaN,NaN); % dummy point to allow another legend entry
% label2 = strcat(string(sum(dat.grp_sz(sum_ind))),' Total Individuals');
% [~, objH] = legend([c,b],label1,label2,'Location','southeast');
% set(findobj(objH(5)),'Vis','off');
% pos = get(objH(2), 'Pos');
% set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot(2,2,3)
worldmap(lat_lims,lon_lims);
setm(gca,'mapprojection','mercator');
load coastlines
plotm(coastlat,coastlon,'k');
geoshow(fall_lines(:,2),fall_lines(:,1),'Color',grey);
if ~isempty(fall_ind)
    c = plotm(dat.latlon(fall_ind,1),dat.latlon(fall_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Fall');
set(gca,'fontSize',12);
label1 = strcat('N = ',lfall);
h = legend(c,label1,'Location','southeast');
set(h,'fontSize',11)
% b = plot(NaN,NaN); % dummy point to allow another legend entry
% label2 = strcat(string(sum(dat.grp_sz(fall_ind))),' Total Individuals');
% [~, objH] = legend([c,b],label1,label2,'Location','southeast');
% set(findobj(objH(5)),'Vis','off');
% pos = get(objH(2), 'Pos');
% set(objH(2), 'Pos', [0.08 pos(2:3)]);

[ax,h3]=suplabel([comName,' Sightings'] ,'t',[.075 .079 .85 .89] );
set(ax,'fontSize',13)

% Save seasonal plots
cd(saveDir)
saveName = [sp,' Seasonal Sightings'];
saveas(figure(3),saveName,'fig')
saveas(figure(3),saveName,'tiff') 


%% Plot seasonal sightings for particular date range
% Total # individuals sighted per season included in legend

% load([datDir,'\DataSets\Effort\All_Seasonal_Tracks.mat']);

% Pull out subset of seasonal trackline data by year if desired
w = find(year(win_lines(:,3))==2016 | year(win_lines(:,3))==2017 | isnan(win_lines(:,3)));
spr = find(year(spr_lines(:,3))==2016 | year(spr_lines(:,3))==2017 | isnan(spr_lines(:,3)));
sm = find(year(sum_lines(:,3))==2016 | year(sum_lines(:,3))==2017 | isnan(sum_lines(:,3)));
f = find(year(fall_lines(:,3))==2016 | year(fall_lines(:,3))==2017 | isnan(fall_lines(:,3)));

% Split up sightings by season and by year
dvec = datevec(dat.obs_dnum);
x = find(dvec(:,1)==2016);
y = find(dvec(:,1)==2017);
win_ind = intersect(y,(find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2)));
spr_ind = intersect(y,(find(dvec(:,2)>=3 & dvec(:,2)<=5)));
sum_ind = intersect(x,(find(dvec(:,2)>=6 & dvec(:,2)<=8)));
fall_ind = intersect(x,(find(dvec(:,2)>=9 & dvec(:,2)<=11)));

lwin = string(length(win_ind));
lspr = string(length(spr_ind));
lsum = string(length(sum_ind));
lfall = string(length(fall_ind));

grey  = [200 200 200]./255;

figure(4)
clf
subplot(2,2,1)
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(win_lines(w,2),win_lines(w,1),'Color',grey);
if ~isempty(win_ind)
    c = plotm(dat.latlon(win_ind,1),dat.latlon(win_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Winter');
set(gca,'fontSize',12);
label1 = strcat('N = ',lwin);
% h = legend(c,label1,'Location','southeast');
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(win_ind))),' Total Individuals');
[~, objH] = legend([c,b],label1,label2,'Location','southeast');
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot(2,2,2)
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(spr_lines(spr,2),spr_lines(spr,1),'Color',grey);
if ~isempty(spr_ind)
    c = plotm(dat.latlon(spr_ind,1),dat.latlon(spr_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Spring');
set(gca,'fontSize',12);
label1 = strcat('N = ',lspr);
% h = legend(c,label1,'Location','southeast');
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(spr_ind))),' Total Individuals');
[~, objH] = legend([c,b],label1,label2,'Location','southeast');
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot(2,2,4)
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(sum_lines(sm,2),sum_lines(sm,1),'Color',grey);
if ~isempty(sum_ind)
    c = plotm(dat.latlon(sum_ind,1),dat.latlon(sum_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Summer');
set(gca,'fontSize',12);
label1 = strcat('N = ',lsum);
% h = legend(c,label1,'Location','southeast');
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(sum_ind))),' Total Individuals');
[~, objH] = legend([c,b],label1,label2,'Location','southeast');
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.08 pos(2:3)]);

subplot(2,2,3)
worldmap(lat_lims,lon_lims);
load coastlines
plotm(coastlat,coastlon,'k','LineWidth',2);
geoshow(fall_lines(f,2),fall_lines(f,1),'Color',grey);
if ~isempty(fall_ind)
    c = plotm(dat.latlon(fall_ind,1),dat.latlon(fall_ind,2),'.','MarkerSize',8);
else
    c = plotm(NaN,NaN);
end
title('Fall');
set(gca,'fontSize',12);
label1 = strcat('N = ',lfall);
% h = legend(c,label1,'Location','southeast');
% set(h,'fontSize',11)
b = plot(NaN,NaN); % dummy point to allow another legend entry
label2 = strcat(string(sum(dat.grp_sz(fall_ind))),' Total Individuals');
[~, objH] = legend([c,b],label1,label2,'Location','southeast');
set(findobj(objH(5)),'Vis','off');
pos = get(objH(2), 'Pos');
set(objH(2), 'Pos', [0.08 pos(2:3)]);

[ax,h3]=suplabel([comName,' Sightings ''16-''17'] ,'t',[.075 .079 .85 .89] );
set(ax,'fontSize',13)

% Save seasonal plots
cd(saveDir)
saveName = [sp,' Seasonal Sightings ''16-''17'];
saveas(figure(4),saveName,'fig')
saveas(figure(4),saveName,'tiff') 
