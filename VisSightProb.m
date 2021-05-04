%% Calculate sighting probability within a given radius around each HARP site
clearvars

sp = 'Tt';
rad = 50; % radius around HARP sites, in km
sightDir = 'J:\OBIS_Vis_data';
effortDir = 'J:\OBIS_Vis_data\DataSets\Effort';

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

%% Load sighting data & effort data
load(fullfile(effortDir,'All_Seasonal_Tracks.mat'));

a = readtable(fullfile(sightDir,['\' sp '\' 'Datapoints.csv']));
a = sortrows(a,20);
if iscell(a.date_time)
    miss_ind = find(cellfun(@isempty,a.date_time));
else
    miss_ind = find(isempty(a.date_time));
end
tot = 1:length(a.date_time);
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
% dat.spec = a.scientific(keep_ind);
% dat.plat = a.platform(keep_ind);

% Split up sightings by season
dvec = datevec(dat.obs_dnum);
win_ind = (find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2));
spr_ind = (find(dvec(:,2)>=3 & dvec(:,2)<=5));
sum_ind = (find(dvec(:,2)>=6 & dvec(:,2)<=8));
fall_ind = (find(dvec(:,2)>=9 & dvec(:,2)<=11));

%% For each HARP site, in each season, find sightings within specified radius
E = referenceEllipsoid('wgs84','km');
goodSights = cell(size(HARPs,1),4);

for iH = 1:size(HARPs,1)
    
    % calculate distances for each season (in km)
    win_dists = distance(HARPs(iH,1),HARPs(iH,2),dat.latlon(win_ind,1),dat.latlon(win_ind,2),E);
    spr_dists = distance(HARPs(iH,1),HARPs(iH,2),dat.latlon(spr_ind,1),dat.latlon(spr_ind,2),E);
    sum_dists = distance(HARPs(iH,1),HARPs(iH,2),dat.latlon(sum_ind,1),dat.latlon(sum_ind,2),E);
    fall_dists = distance(HARPs(iH,1),HARPs(iH,2),dat.latlon(fall_ind,1),dat.latlon(fall_ind,2),E);
    
    % find distances within specified radius
    goodWin_dists = find(win_dists<=rad);
    goodSpr_dists = find(spr_dists<=rad);
    goodSum_dists = find(sum_dists<=rad);
    goodFall_dists = find(fall_dists<=rad);
    
    goodSights{iH,1} = [dat.latlon(win_ind(goodWin_dists),:),dat.obs_dnum(win_ind(goodWin_dists),:),dat.grp_sz(win_ind(goodWin_dists),:)];
    goodSights{iH,2} = [dat.latlon(spr_ind(goodSpr_dists),:),dat.obs_dnum(spr_ind(goodSpr_dists),:),dat.grp_sz(spr_ind(goodSpr_dists),:)];
    goodSights{iH,3} = [dat.latlon(sum_ind(goodSum_dists),:),dat.obs_dnum(sum_ind(goodSum_dists),:),dat.grp_sz(sum_ind(goodSum_dists),:)];
    goodSights{iH,4} = [dat.latlon(fall_ind(goodFall_dists),:),dat.obs_dnum(fall_ind(goodFall_dists),:),dat.grp_sz(fall_ind(goodFall_dists),:)];

end


%% Calculate effort within specified radius of each HARP



