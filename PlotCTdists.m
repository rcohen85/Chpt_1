%% Calculate seasonal hours of click presence for Atl CTs
% Plot seasonal distributions of click types across Atlantic HARP
% sites using scaled circles
% Note: this script is hard coded for the Atlantic recording sites
% Seasons are hard coded thus:
% Winter: December, January, February
% Spring: March, April, May
% Summer: June, July, August
% Fall: September, October, November
% Normalization for effort doesn't account for possibility of a leap year
% (old monthly binning & plotting code at bottom, not updated)

clearvars

% Load daily totals at each site
dayDir = 'G:\DailyCT_Totals'; % directory containing CT daily totals for each site
matchStr = '_DailyTotals_Prob0_RL120_numClicks0.mat';
errDir = 'G:\ErrorEval'; % directory containing error summary from plot_labCert
seasDir = 'G:\SeasonalCT_Totals'; % directory to save seasonal data
mapDir = 'G:\SeasonalMaps';
RLThresh = 120;
numClicksThresh = 50;
probThresh = 0;

% Set lat/long limits to plot only your region of interest
lat_lims = [26 44];
lon_lims = [-82.00 -63];

%% Calculate cumulative seasonal hours for each site
fileList = dir(fullfile(dayDir,['*' matchStr]));
siteList = cellstr(char(fileList(:).name));
for k = 1:size(siteList,1)
    ind = strfind(siteList{k,1},'_');
    siteList{k,1} = siteList{k,1}(1:ind(2)-1);
end

seasDat = cell(size(fileList,1),8); % initialize cell array to hold seasonal data for all sites

% Load error summary
if ~isempty(errDir)
load(fullfile(errDir,'Error_Summary.mat'),'site','siteErr','minPPRL','minNumClicks');
end

% Calculate duration of each season in a full non-leap year
yearVec = datevec(datenum('2001-01-01'):1:datenum('2001-12-31'));
win_dur = numel(find(yearVec(:,2)==12 | yearVec(:,2)==1 | yearVec(:,2)==2));
spr_dur = numel(find(yearVec(:,2)>=3 & yearVec(:,2)<=5));
sum_dur = numel(find(yearVec(:,2)>=6 & yearVec(:,2)<=8));
fall_dur = numel(find(yearVec(:,2)>=9 & yearVec(:,2)<=11));

for iS = 1:size(fileList,1) % for each DailyTotals file
    
    load(fullfile(dayDir,fileList(iS).name),'dailyTots','binFeatures','spNameList');
    dvec = datevec(dailyTots(:,1));
    
    for iCT = 1:size(dailyTots,2)-1 % for each label
        
        seasDat{iS,1,iCT} = siteList(iS); % List site
        
        if ~isempty(dailyTots)
            
            % Remove bins not meeting thresholds
            dailyTots(binFeatures{1,iCT}<probThresh,iCT+1) = NaN;
            dailyTots(binFeatures{2,iCT}<RLThresh,iCT+1) = NaN;
            dailyTots(binFeatures{3,iCT}<numClicksThresh,iCT+1) = NaN;
            
            % Divide bins by season
            win_ind = find(dvec(:,2)==12 | dvec(:,2)==1 | dvec(:,2)==2);
            spr_ind = find(dvec(:,2)>=3 & dvec(:,2)<=5);
            sum_ind = find(dvec(:,2)>=6 & dvec(:,2)<=8);
            fall_ind = find(dvec(:,2)>=9 & dvec(:,2)<=11);
            
            % Sum remaining bins for each season
            seasDat{iS,2,iCT} = sum(dailyTots(win_ind,iCT+1),'omitnan');
            seasDat{iS,3,iCT} = sum(dailyTots(spr_ind,iCT+1),'omitnan');
            seasDat{iS,4,iCT} = sum(dailyTots(sum_ind,iCT+1),'omitnan');
            seasDat{iS,5,iCT} = sum(dailyTots(fall_ind,iCT+1),'omitnan');
            
            % Normalize seasons by effort
            seasDat{iS,2,iCT} = seasDat{iS,2,iCT}/(numel(win_ind)/win_dur);
            seasDat{iS,3,iCT} = seasDat{iS,3,iCT}/(numel(spr_ind)/spr_dur);
            seasDat{iS,4,iCT} = seasDat{iS,4,iCT}/(numel(sum_ind)/sum_dur);
            seasDat{iS,5,iCT} = seasDat{iS,5,iCT}/(numel(fall_ind)/fall_dur);
            
        end
        
        % Add site error rate
        if ~isempty(errDir)
            fullDep = strrep(fileList(iS).name,matchStr,'');
            depMatch = find(strcmp(site(:),fullDep));
            RLmatch = find(minPPRL==RLThresh);
            NumMatch = find(minNumClicks==numClicksThresh);
            if ~isempty(siteErr{depMatch,iCT})
                seasDat{iS,6,iCT} = siteErr{depMatch,iCT}(NumMatch,RLmatch);
            else
                seasDat{iS,6,iCT} = NaN;
            end
        end
                
        % Add site lat/lon info
        if strcmp(seasDat{iS,1,iCT},'WAT_HZ')
            seasDat{iS,7,iCT} = 41.06165;
            seasDat{iS,8,iCT} = -66.35155;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_OC')
            seasDat{iS,7,iCT} = 40.22999;
            seasDat{iS,8,iCT} = -67.97798;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_NC')
            seasDat{iS,7,iCT} = 39.83295;
            seasDat{iS,8,iCT} = -69.98194;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_BC')
            seasDat{iS,7,iCT} = 39.19192;
            seasDat{iS,8,iCT} = -72.22735;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_WC')
            seasDat{iS,7,iCT} = 38.37337;
            seasDat{iS,8,iCT} = -73.36985;
        elseif strcmp(seasDat{iS,1,iCT},'NFC_A')
            seasDat{iS,7,iCT} = 37.16452;
            seasDat{iS,8,iCT} = -74.46585;
        elseif strcmp(seasDat{iS,1,iCT},'HAT_A')
            seasDat{iS,7,iCT} = 35.30183;
            seasDat{iS,8,iCT} = -74.87895;
        elseif strcmp(seasDat{iS,1,iCT},'HAT_B')
            seasDat{iS,7,iCT} = 35.5841;
            seasDat{iS,8,iCT} = -74.7499;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_GS')
            seasDat{iS,7,iCT} = 33.66992;
            seasDat{iS,8,iCT} = -75.9977;
        elseif strcmp(seasDat{iS,1,iCT},'USWTR_A')
            seasDat{iS,7,iCT} = 33.791383;
            seasDat{iS,8,iCT} = -76.523817;
        elseif strcmp(seasDat{iS,1,iCT},'USWTR_B')
            seasDat{iS,7,iCT} = 33.811067;
            seasDat{iS,8,iCT} = -76.428283;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_BP')
            seasDat{iS,7,iCT} = 32.10527;
            seasDat{iS,8,iCT} = -77.09067;
        elseif strcmp(seasDat{iS,1,iCT},'WAT_BS')
            seasDat{iS,7,iCT} = 30.58295;
            seasDat{iS,8,iCT} = -77.39002;
        elseif strcmp(seasDat{iS,1,iCT},'JAX_C')
            seasDat{iS,7,iCT} = 30.326433;
            seasDat{iS,8,iCT} = -80.204933;
        elseif strcmp(seasDat{iS,1,iCT},'JAX_D')
            seasDat{iS,7,iCT} = 30.27818;
            seasDat{iS,8,iCT} = -80.22085;
        end
    end
end
% Average seasonal presence across repeated deployments at each site
% NOTE: HAT_A and HAT_B are combined
for i=1:size(siteList,1)
        if strcmp(siteList{i,1},'HAT_A') || strcmp(siteList{i,1},'HAT_B')
        siteList{i,1} = siteList{i,1}(1:3);
        end
end
iS=1;
while iS <= size(siteList,1)

    reps = strcmp(siteList{iS,1},siteList);
    for iCT = 1:size(seasDat,3)
        depDat = cell2mat(seasDat(reps,2:6,iCT));
        depDat = num2cell(mean(depDat,'omitnan'));
        seasDat(iS,2:6,iCT) = depDat;
    end    
    
    firstOccur = find(reps==1,1);
    reps(firstOccur) = 0;
    seasDat(reps,:,:) = [];
    siteList(reps) = [];
    iS = iS+1;
end


for iCT = 1:size(spNameList,1)
    seasonalData = cell2table(seasDat(:,:,iCT),'VariableNames',{'Site','Winter','Spring',...
        'Summer','Fall','Error','Lat','Lon'});
    save(fullfile(seasDir,[spNameList{iCT,1} '_Seasonal_Totals_Prob' num2str(probThresh)...
        '_PPRL' num2str(RLThresh) '_numClicks' num2str(numClicksThresh)]),'seasonalData');
end

%% Plot seasonal data

fileList = dir(fullfile(seasDir,['*Seasonal_Totals_Prob' num2str(probThresh)...
    '_PPRL' num2str(RLThresh) '_numClicks' num2str(numClicksThresh) '*']));

errBins = linspace(0,1,21);
% cMap = interp1([0;1;2;3],[0 153 0; 153 153 0; 153 76 0; 153 0 0]./255,linspace(0,4,19),'spline');
% cMap(20,:) = [0 0 204]./255;
% cMap(cMap<0) = 0;
% cMap(cMap>1) = 1;

% cMap = interp1([1:10]',[77,138,198;84,158,179;96,171,158;119,183,125;166,190,84;209,181,65;228,156,57;230,121,50;223,72,40;184,34,30]./255,linspace(0,10,20),'spline');
cMap = [77,138,198;84,158,179;96,171,158;119,183,125;166,190,84;209,181,65;228,156,57;230,121,50;223,72,40;210,51,35]./255;
cMap = vertcat(cMap, repmat([184,34,30]./255,10,1,1));
cMap(21,:) = [102 100 102]./255;

% Plot and save bubblemaps
% To plot without legends, add 'LegendVisible','off' to each call of
% geobubble
for iS = 1:size(fileList,1)
    load(fullfile(seasDir,fileList(iS).name));
    ind = strfind(fileList(iS).name,'_');
    CT = fileList(iS).name(1:ind(1)-1);
    if(strcmp(CT,'CT4') || strcmp(CT,'GoM'))
        CT = fileList(iS).name(1:ind(2)-1);
        CT = [CT(1:ind(1)-1) '\' CT(ind(1):end)];
    end
    
    % Sort error into error bins to determine bubble color
    if any(~isnan(seasonalData.Error))
        [~,~,bin] = histcounts(seasonalData.Error,errBins);
        bin(bin==0) = NaN;
        errCategories = {};
        for iB = 1:size(bin,1)
            if ~isnan(seasonalData.Error(iB))
                if errBins(bin(iB))<0.1 && errBins(bin(iB)+1)>=0.1
                    range = cellstr(sprintf('0%d%% - %d%%',round(errBins(bin(iB))*100), round(errBins(bin(iB)+1)*100)));
                elseif errBins(bin(iB))<0.1 && errBins(bin(iB)+1)<0.1
                    range = cellstr(sprintf('0%d%% - 0%d%%',round(errBins(bin(iB))*100), round(errBins(bin(iB)+1)*100)));
                else
                    range = cellstr(sprintf('%d%% - %d%%',round(errBins(bin(iB))*100), round(errBins(bin(iB)+1)*100)));
                end
                errCategories(iB) = range;
            else
                errCategories(iB) = cellstr('0');
            end
        end
        seasonalData.ErrCats = categorical(errCategories');
        seasonalData.ErrCats = removecats(seasonalData.ErrCats,'0');
        bin(isnan(bin)) = size(cMap,1);
        cMap_type = cMap(unique(bin),:);
        
        % Scale bubbles by error
        seasonalData.Winter(~isnan(seasonalData.Error)) = seasonalData.Winter(~isnan(seasonalData.Error)).*(1-seasonalData.Error(~isnan(seasonalData.Error)));
        seasonalData.Spring(~isnan(seasonalData.Error)) = seasonalData.Spring(~isnan(seasonalData.Error)).*(1-seasonalData.Error(~isnan(seasonalData.Error)));
        seasonalData.Summer(~isnan(seasonalData.Error)) = seasonalData.Summer(~isnan(seasonalData.Error)).*(1-seasonalData.Error(~isnan(seasonalData.Error)));
        seasonalData.Fall(~isnan(seasonalData.Error)) = seasonalData.Fall(~isnan(seasonalData.Error)).*(1-seasonalData.Error(~isnan(seasonalData.Error)));
    else
        seasonalData.ErrCats = categorical(seasonalData.Error);
        cMap_type = cMap(end,:);
    end

%     if any(~isnan(bin))
%         cMap = interp1([0;1],[0 153 0; 153 0 0]./255,linspace(0,1,size(unique(bin),1)),'spline');
%         cMap(size(unique(bin),1)+1,:) = [0 0 204]./255;
%     else
%         cMap = [0 0 204]./255;
%     end
       
    minbub = floor(min(min(seasonalData{:,2:5})));
    maxbub = ceil(max(max(seasonalData{:,2:5})));
    
    figure(2)
    clf
    gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Winter,...
        seasonalData.ErrCats,'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.525 0.25 0.35],...
        'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
        cMap_type);
    gb.Basemap = 'grayland';
    geolimits(lat_lims,lon_lims)
    title('Winter');
    gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Spring,...
        seasonalData.ErrCats,'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.525 0.25 0.35],...
        'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
        cMap_type);
    gb.Basemap = 'grayland';
    geolimits(lat_lims,lon_lims)
    title('Spring');
    gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Summer,...
        seasonalData.ErrCats,'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.075 0.25 0.35],...
        'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
        cMap_type);
    gb.Basemap = 'grayland';
    geolimits(lat_lims,lon_lims)
    title('Summer');
    gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Fall,...
        seasonalData.ErrCats,'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.075 0.25 0.35],...
        'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
        cMap_type);
    gb.Basemap = 'grayland';
    geolimits(lat_lims,lon_lims)
    title('Fall');
    [ax,h3]=suplabel(sprintf('%s\nCumulative Hours Per Season\nConf Min: %d, Mean PPRL Min: %d, # Clicks Min: %d',CT,probThresh,RLThresh,numClicksThresh),...
        't',[.075 .05 .85 .89] );
%     e = input('Enter to save figure and continue' );
    
    savename = strrep(fileList(iS).name,'Seasonal_Totals','Seasonal_Maps');
    savename = strrep(savename,'.mat','');
    saveas(figure(2),fullfile(mapDir,savename),'tiff')
    
end

%% Plot without bubblemap legends (each map is bigger)
% for iS = 1:size(fileList,1)
% load(fullfile(seasDir,fileList(iS).name));
% ind = strfind(fileList(iS).name,'_');
% CT = fileList(iS).name(1:ind(1)-1);
%
% minbub = floor(min(min(seasonalData{:,2:5})));
% maxbub = ceil(max(max(seasonalData{:,2:5})));
%
% figure(3)
% clf
% gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Winter,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.525 0.33 0.36],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
%     [241,92,34]/255,'LegendVisible','off');
% gb.Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Winter');
% gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Spring,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.525 0.33 0.36],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
%     [241,92,34]/255,'LegendVisible','off');
% gb.Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Spring');
% gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Summer,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.575 0.075 0.33 0.36],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
%     [241,92,34]/255,'LegendVisible','off');
% gb.Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Summer');
% gb = geobubble(seasonalData.Lat,seasonalData.Lon,seasonalData.Fall,...
%     'BubbleWidthRange',[2 20],'InnerPosition',[0.15 0.075 0.33 0.36],...
%     'ScalebarVisible','off','SizeLimits',[minbub maxbub],'BubbleColorList',...
%     [241,92,34]/255,'LegendVisible','off');
% gb.Basemap = 'grayland';
% geolimits(lat_lims,lon_lims)
% title('Fall');
% [ax,h3]=suplabel(sprintf('%s\nCumulative Hours Per Season',CT),...
%     't',[.075 .05 .85 .89] );
%
% % if iS == 6
% %     savename = ['CT4_6_SeasonalMaps'];
% % else
% %     savename = [CT '_SeasonalMaps'];
% % end
%
% savename = strrep(fileList(iS).name,'Seasonal_Totals','Seasonal_Maps');
% saveas(figure(3),fullfile(mapDir,savename),'tiff')
% end

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