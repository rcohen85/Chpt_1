%% Calculate montly & seasonal total hours of click presence for 19 Atl CTs
% Plot monthly & seasonal distributions of click types across Atlantic HARP
% sites using scaled circles
% Note: this script expects daily totals of all 19 CTs (NNet labels 0:18)
% but can accept any subset of the Atl sites
clearvars

% Load daily totals at each site
dayDir = 'G:\New_Atl_CTs\DailyCT_Totals'; % directory containing CT daily totals for each site
seasDir = 'G:\New_Atl_CTs\Seasonal_CT_Totals';
fileList = dir(fullfile(dayDir,'*DailyTotals.mat'));
% CTs matches the order of correspondence of NNet labels 0:18 to their
% report names
CTs = {'CT10','CT2','CT3','CT4_6','CT5','CT7','CT8','CT9','Blainvilles','Boats',...
    'Cuviers','Echosounder','Gervais','Kogia','Noise','Rissos','Sowerbys',...
    'Spermwhale','Trues'};

% Set lat/long limits to plot only your region of interest
% lat_lims = [25 45];
% lon_lims = [-82.00 -62];
lat_lims = [26 44];
lon_lims = [-82.00 -63];

%% Calculate cumulative monthly hours for each site (May 2016 - Apr 2017)
%  ******** NOT UPDATED FOR NEW DAILYTOTALS MATRICES ********
% monDat = {}; % initialize cell array to hold monthly data for all sites
% for i = 1:length(fileList)
%     fileName = fileList(i).name;
%     ind = strfind(fileName,'_');
%     monDat{i,1} = fileName(1:ind(2)-1); % List sites
%     
%     load(fileList(i).name);
%     dvec = datevec(allDat(:,1));
%     
%     if any(regexp(fileName,'HAT_')) %HAT data pulled from 2017-2018 year has different monthly overlaps
%         if ~isempty(allDat)           
%             for j = 1:12 % Sum detections by month; don't count a month twice if the deployment is >1yr
%                 if any(find(j==1:5)) %
%                     a = find(dvec(:,2)==j);
%                     b = find(dvec(:,1)==2018);
%                     monind = intersect(a,b);
%                     monDat{i,j+1} = sum(allDat(monind,2));
%                 elseif any(find(j==6:12))
%                     a = find(dvec(:,2)==j);
%                     b = find(dvec(:,1)==2017);
%                     monind = intersect(a,b);
%                     monDat{i,j+1} = sum(allDat(monind,2));
%                 end
%             end
%         end
%     else
%         if ~isempty(allDat)            
%             for j = 1:12 % Sum detections by month
%                 if any(find(j==5:12)) 
%                     a = find(dvec(:,2)==j);
%                     b = find(dvec(:,1)==2016);
%                     monind = intersect(a,b);
%                     monDat{i,j+1} = sum(allDat(monind,2));
%                 elseif any(find(j==1:4))
%                     a = find(dvec(:,2)==j);
%                     b = find(dvec(:,1)==2017);
%                     monind = intersect(a,b);
%                     monDat{i,j+1} = sum(allDat(monind,2));
%                 end
%             end
%         end
%     end
%     
%     % Add site lat/lon info
%     if strcmp(monDat{i,1},'WAT_HZ')
%         monDat{i,14} = 41.06165;
%         monDat{i,15} = -66.35155;
%     elseif strcmp(monDat{i,1},'WAT_OC')
%         monDat{i,14} = 40.22999;
%         monDat{i,15} = -67.97798;
%     elseif strcmp(monDat{i,1},'WAT_NC')
%         monDat{i,14} = 39.83295;
%         monDat{i,15} = -69.98194;
%     elseif strcmp(monDat{i,1},'WAT_BC')
%         monDat{i,14} = 39.19192;
%         monDat{i,15} = -72.22735;
%     elseif strcmp(monDat{i,1},'WAT_WC')
%         monDat{i,14} = 38.37337;
%         monDat{i,15} = -73.36985;
%     elseif strcmp(monDat{i,1},'NFC_A')
%         monDat{i,14} = 37.16452;
%         monDat{i,15} = -74.46585;
%     elseif strcmp(monDat{i,1},'HAT_A')
%         monDat{i,14} = 35.30183;
%         monDat{i,15} = -74.87895;
%     elseif strcmp(monDat{i,1},'HAT_B')
%         monDat{i,14} = 35.5841;
%         monDat{i,15} = -74.7499;
%     elseif strcmp(monDat{i,1},'WAT_GS')
%         monDat{i,14} = 33.66992;
%         monDat{i,15} = -75.9977;
%     elseif strcmp(monDat{i,1},'WAT_BP')
%         monDat{i,14} = 32.10527;
%         monDat{i,15} = -77.09067;
%     elseif strcmp(monDat{i,1},'WAT_BS')
%         monDat{i,14} = 30.58295;
%         monDat{i,15} = -77.39002;
%     elseif strcmp(monDat{i,1},'JAX_D')
%         monDat{i,14} = 30.27818;
%         monDat{i,15} = -80.22085;
%     end
%     
% end
% % Save data as table for use with geobubble
% monDat = cell2table(monDat,'VariableNames',{'Site','Jan','Feb','Mar','Apr',...
%     'May','Jun','Jul','Aug','Sept','Oct','Nov','Dec','Lat','Lon'});
% save('All_Sites_Monthly_Totals','monDat');

%% Calculate cumulative seasonal hours for each site
seasDat = {}; % initialize cell array to hold seasonal data for all sites
for i = 1:length(fileList)
    fileName = fileList(i).name;
    ind = strfind(fileName,'_');
    
    load(fullfile(dayDir,fileList(i).name));
    dvec = datevec(dailyTots(:,1));
    
    for iCT = 2:20 % columns of dailyTots corresponding to NNet labels 0:18
        
        seasDat{i,1,iCT-1} = fileName(1:ind(2)-1); % List sites
        
        if any(regexp(fileName,'HAT_')) % using HAT data from a different year than the rest of the sites
            if ~isempty(dailyTots)
                % Sum detections by season; some months recorded twice, choose
                % which to use by indicating year
                win_ind = find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2);
                a = find(dvec(:,2)>=3 & dvec(:,2)<=5);
                b = find(dvec(:,1)==2018);
                spr_ind = intersect(a,b);
                c = find(dvec(:,2)>=6 & dvec(:,2)<=8);
                d = find(dvec(:,1)==2017);
                sum_ind = intersect(c,d);
                fall_ind = find(dvec(:,2)>=9 & dvec(:,2)<=11);
                
                seasDat{i,2,iCT-1} = sum(dailyTots(win_ind,iCT));
                seasDat{i,3,iCT-1} = sum(dailyTots(spr_ind,iCT));
                seasDat{i,4,iCT-1} = sum(dailyTots(sum_ind,iCT));
                seasDat{i,5,iCT-1} = sum(dailyTots(fall_ind,iCT));
            end
        else
            if ~isempty(dailyTots)
                % Sum detections by season; some months recorded twice, choose
                % which to use by indicating year
                win_ind = find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2);
                a = find(dvec(:,2)==3 | dvec(:,2)==4 & dvec(:,1)==2017);
                b = find(dvec(:,2)==5 & dvec(:,1)==2016);
                spr_ind = sort(vertcat(a,b));
                c = find(dvec(:,2)>=6 & dvec(:,2)<=8);
                d = find(dvec(:,1)==2016);
                sum_ind = intersect(c,d);
                fall_ind = find(dvec(:,2)>=9 & dvec(:,2)<=11);
                
                seasDat{i,2,iCT-1} = sum(dailyTots(win_ind,iCT));
                seasDat{i,3,iCT-1} = sum(dailyTots(spr_ind,iCT));
                seasDat{i,4,iCT-1} = sum(dailyTots(sum_ind,iCT));
                seasDat{i,5,iCT-1} = sum(dailyTots(fall_ind,iCT));
            end
        end
        
        % Add site lat/lon info
        if strcmp(seasDat{i,1,iCT-1},'WAT_HZ')
            seasDat{i,6,iCT-1} = 41.06165;
            seasDat{i,7,iCT-1} = -66.35155;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_OC')
            seasDat{i,6,iCT-1} = 40.22999;
            seasDat{i,7,iCT-1} = -67.97798;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_NC')
            seasDat{i,6,iCT-1} = 39.83295;
            seasDat{i,7,iCT-1} = -69.98194;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_BC')
            seasDat{i,6,iCT-1} = 39.19192;
            seasDat{i,7,iCT-1} = -72.22735;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_WC')
            seasDat{i,6,iCT-1} = 38.37337;
            seasDat{i,7,iCT-1} = -73.36985;
        elseif strcmp(seasDat{i,1,iCT-1},'NFC_A')
            seasDat{i,6,iCT-1} = 37.16452;
            seasDat{i,7,iCT-1} = -74.46585;
        elseif strcmp(seasDat{i,1,iCT-1},'HAT_A')
            seasDat{i,6,iCT-1} = 35.30183;
            seasDat{i,7,iCT-1} = -74.87895;
        elseif strcmp(seasDat{i,1,iCT-1},'HAT_B')
            seasDat{i,6,iCT-1} = 35.5841;
            seasDat{i,7,iCT-1} = -74.7499;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_GS')
            seasDat{i,6,iCT-1} = 33.66992;
            seasDat{i,7,iCT-1} = -75.9977;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_BP')
            seasDat{i,6,iCT-1} = 32.10527;
            seasDat{i,7,iCT-1} = -77.09067;
        elseif strcmp(seasDat{i,1,iCT-1},'WAT_BS')
            seasDat{i,6,iCT-1} = 30.58295;
            seasDat{i,7,iCT-1} = -77.39002;
        elseif strcmp(seasDat{i,1,iCT-1},'JAX_D')
            seasDat{i,6,iCT-1} = 30.27818;
            seasDat{i,7,iCT-1} = -80.22085;
        end
    end
end

for iCT = 1:19
seasDat_oneCT = cell2table(seasDat(:,:,iCT),'VariableNames',{'Site','Winter','Spring',...
    'Summer','Fall','Lat','Lon'});
save(fullfile(seasDir,['All_Sites_Seasonal_Totals_' CTs{iCT}]),'seasDat_oneCT');
end

%% Plot monthly data

% load('All_Sites_Monthly_Totals.mat');
% 
% minbub = floor(min(min(monDat{:,2:13})));
% maxbub = ceil(max(max(monDat{:,2:13})));
% 
% figure(1)
% clf
% geobubble(monDat.Lat,monDat.Lon,monDat.Dec,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.07 0.765 0.16 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Dec');
% geobubble(monDat.Lat,monDat.Lon,monDat.Jan,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.39 0.765 0.16 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Jan');
% geobubble(monDat.Lat,monDat.Lon,monDat.Feb,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.7 0.765 0.16 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Feb');
% geobubble(monDat.Lat,monDat.Lon,monDat.Mar,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.07 0.525 0.16 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Mar');
% geobubble(monDat.Lat,monDat.Lon,monDat.Apr,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.39 0.525 0.16 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Apr');
% geobubble(monDat.Lat,monDat.Lon,monDat.May,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.7 0.525 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('May');
% geobubble(monDat.Lat,monDat.Lon,monDat.Jun,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.07 0.285 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Jun');
% geobubble(monDat.Lat,monDat.Lon,monDat.Jul,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.39 0.285 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Jul');
% geobubble(monDat.Lat,monDat.Lon,monDat.Aug,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.7 0.285 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Aug');
% geobubble(monDat.Lat,monDat.Lon,monDat.Sept,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.07 0.05 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Sept');
% geobubble(monDat.Lat,monDat.Lon,monDat.Oct,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.39 0.05 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Oct');
% geobubble(monDat.Lat,monDat.Lon,monDat.Nov,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.7 0.05 0.15 0.18],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub]);
% geolimits(lat_lims,lon_lims)
% title('Nov');
% 
% [ax,h3]=suplabel(sprintf('%s Monthly Cumulative Hours',CTs),'t',[.075 .085 .85 .89] );
% 
% saveas(figure(1),'Monthly CT Presence','fig')
% saveas(figure(1),'Monthly CT Presence','tiff') 

%% Plot seasonal data
seasDir = 'G:\New_Atl_CTs\Seasonal_CT_Totals';
fileList = dir(fullfile(seasDir,'All_Sites_Seasonal_Totals*.mat'));
% CT_names doesn't match the order of CTs above, it matches the order in
% which seasonal data files are read into Matlab
CT_names = {'Blainvilles','Boats','CT10','CT2','CT3','CT4\_6','CT5','CT7','CT8','CT9',...
    'Cuviers','Echosounder','Gervais','Kogia','Noise','Rissos','Sowerbys',...
    'Spermwhale','Trues'};

% Plot with bubblemap legends
for i = 1:length(CTs)
load(fullfile(seasDir,fileList(i).name));

minbub = floor(min(min(seasDat_oneCT{:,2:5})));
maxbub = ceil(max(max(seasDat_oneCT{:,2:5})));

figure(2)
clf
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Winter,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.525 0.25 0.35],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255);
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Winter');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Spring,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.525 0.25 0.35],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255);
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Spring');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Summer,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.075 0.25 0.35],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255);
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Summer');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Fall,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.075 0.25 0.35],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255);
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Fall');
[ax,h3]=suplabel(sprintf('%s\nCumulative Hours Per Season',CT_names{i}),...
    't',[.075 .05 .85 .89] );

if i == 6
    savename = ['CT4_6_SeasonalMaps'];
else
    savename = [CT_names{i} '_SeasonalMaps'];
end
% saveas(figure(2),'Seasonal CT Presence','fig')
saveas(figure(2),fullfile(seasDir,savename),'tiff')

end

% Plot without bubblemap legends
for i = 1:length(CTs)
load(fullfile(seasDir,fileList(i).name));

minbub = floor(min(min(seasDat_oneCT{:,2:5})));
maxbub = ceil(max(max(seasDat_oneCT{:,2:5})));

figure(3)
clf
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Winter,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.525 0.33 0.36],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255,'LegendVisible','off');
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Winter');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Spring,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.525 0.33 0.36],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255,'LegendVisible','off');
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Spring');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Summer,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.075 0.33 0.36],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255,'LegendVisible','off');
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Summer');
gb = geobubble(seasDat_oneCT.Lat,seasDat_oneCT.Lon,seasDat_oneCT.Fall,...
    'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.075 0.33 0.36],...
    'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
    [241,92,34]/255,'LegendVisible','off');
gb.Basemap = 'grayland';
geolimits(lat_lims,lon_lims)
title('Fall');
[ax,h3]=suplabel(sprintf('%s\nCumulative Hours Per Season',CT_names{i}),...
    't',[.075 .05 .85 .89] );

if i == 6
    savename = ['CT4_6_SeasonalMaps'];
else
    savename = [CT_names{i} '_SeasonalMaps'];
end
% saveas(figure(3),'Seasonal CT Presence','fig')
saveas(figure(3),fullfile(seasDir,savename),'tiff')
end