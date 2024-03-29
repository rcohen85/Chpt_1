% Lunar illumination and night data are in UTC

interval = 5;
saveDir = 'J:\Chpt_2\IlluminationFiles';

% site names
depNames = {['WAT_HZ_02';'WAT_HZ_03';'WAT_HZ_04'];['WAT_OC_02';'WAT_OC_03';...
    'WAT_OC_04'];['WAT_NC_02';'WAT_NC_03';'WAT_NC_04'];['WAT_BC_01';'WAT_BC_02';...
    'WAT_BC_03'];['WAT_WC_01';'WAT_WC_02';'WAT_WC_03'];['NFC_A_02';'NFC_A_03';...
    'NFC_A_04'];['HAT_A_06';'HAT_B_01';'HAT_B_03';'HAT_B_04';'HAT_B_05'];...
    ['WAT_GS_01';'WAT_GS_02';'WAT_GS_03'];['WAT_BP_01';'WAT_BP_02';'WAT_BP_03'];...
    ['WAT_BS_01';'WAT_BS_02';'WAT_BS_03'];['JAX_D_13';'JAX_D_14';'JAX_D_15']};

% save names
siteNames = {'WAT_HZ','WAT_OC','WAT_NC','WAT_BC','WAT_WC','NFC','HAT',...
    'WAT_GS','WAT_BP','WAT_BS','JAX'};

% site lat/lons; order should correspond to site names above
HARPs = {[41.0618333 66.35158; % WAT_HZ
    41.06165 66.35155;
    41.06165 66.35155];  
    [40.2633167 67.98623; % WAT_OC
    40.2633333 67.98633;
    40.23 67.97798];       
    [39.8323833 69.9821; % WAT_NC
    39.8325833 69.98192;
    39.83295 69.98193];       
    [39.19105 72.2287; % WAT_BC
    39.1905 72.22713;
    39.1919167 72.22735];       
    [38.37415 73.37068; % WAT_WC
    38.37385 73.37015;
    38.3733667 73.36985];       
    [37.1665167 74.4666; % NFC
    37.1674 74.46633;
    37.1645167 74.46585];       
    [35.3018333 74.87895; % HAT
    35.5841333 74.74985;
    35.5835167 74.74307;
    35.5897667 74.7476;
    35.5893 74.7545];       
    [33.6656333 76.00138; % WAT_GS
    33.6670167 75.99947;
    33.6699167 75.9977];        
    [32.1060333 77.09432; % WAT_BP
    32.10695 77.0901;
    32.1052667 77.09067];       
    [30.5837833 77.39072; % WAT_BS
    30.5830333 77.39043;
    30.58295 77.39002];       
    [30.1518333 79.77022; % JAX_D
    30.1526833 79.76988;
    30.15225 79.7706]};      

%effort periods; cells should correspond to HARP site names above
% note: these times have been rounded
effort = {[datenum([2016,04,22,18,00,00]), datenum([2017,06,19,7,05,00]);
    datenum([2017,07,09,0,00,00]),datenum([2018,01,13,15,25,00]);
    datenum([2018,06,11,17,55,00]),datenum([2019,05,10,06,30,00])];
[datenum([2016,04,24,05,55,00]), datenum([2017,05,18,06,35,00]);
    datenum([2017,07,07,23,55,00]),datenum([2018,04,16,5,55,00]);
    datenum([2018,06,10,6,00,00]),datenum([2019,05,19,4,30,00])];
[datenum([2016,04,21,18,00,00]), datenum([2017,05,24,14,50,00]);
    datenum([2017,07,16,18,00,00]),datenum([2018,06,09,13,00,00]);
    datenum([2018,06,10,0,00,00]),datenum([2019,06,03,4,40,00])];
[datenum([2016,04,20,18,00,00]), datenum([2017,06,10,23,04,05]);
    datenum([2017,06,30,12,00,00]),datenum([2018,06,03,11,30,00]);
    datenum([2018,06,03,12,00,00]),datenum([2019,05,19,19,30,00])];
[datenum([2016,04,20,6,00,00]), datenum([2017,06,29,20,55,00]);
    datenum([2017,06,30,0,00,00]),datenum([2018,06,02,20,40,00]);
    datenum([2018,06,02,22,00,00]),datenum([2019,05,19,8,30,00])];
[datenum([2016,04,30,12,00,00]), datenum([2017,06,28,18,35,00]);
    datenum([2017,06,30,0,00,00]),datenum([2018,06,02,16,15,00]);
    datenum([2018,06,02,12,00,00]),datenum([2019,05,18,17,45,00])];
[ datenum([2016,04,29,12,00,00]),datenum([2017,02,06,8,55,00]);
    datenum([2017,05,09,12,00,00]),datenum([2017,10,25,14,10,00]);
    datenum([2017,10,26,12,00,00]),datenum([2018,06,01,0,50,00]);
    datenum([2018,06,01,4,00,00]),datenum([2018,12,14,14,40,00]);
    datenum([2018,12,14,0,00,00]),datenum([2019,05,17,18,15,00])];
[datenum([2016,04,29,0,00,00]), datenum([2017,06,27,18,35,00]);
    datenum([2017,06,28,0,00,00]),datenum([2018,06,26,11,30,00]);
    datenum([2018,06,28,23,55,00]),datenum([2019,06,18,14,15,00])];
[datenum([2016,04,28,12,00,00]), datenum([2017,06,27,4,55,00]);
    datenum([2017,06,27,12,00,00]),datenum([2018,06,28,13,05,00]);
    datenum([2018,06,28,0,00,00]),datenum([2019,05,28,4,00,00])];
[datenum([2016,04,27,18,00,00]), datenum([2017,06,26,15,20,00]);
    datenum([2017,06,26,18,00,00]),datenum([2018,06,23,7,30,00]);
    datenum([2018,06,28,0,00,00]),datenum([2019,06,16,20,10,00])];
[datenum([2016,04,26,18,00,00]),datenum([2017,06,25,19,20,00]);
    datenum([2017,06,25,18,00,00]),datenum([2017,10,28,17,25,0]);
    datenum([2018,06,27,0,00,00]),datenum([2019,06,15,11,00,00])]};
% effort = {[datenum([2016,04,22,18,00,00]),datenum([2019,05,10,6,33,44])];
% [datenum([2016,04,24,5,59,59]),datenum([2019,05,19,4,33,45])];
% [datenum([2016,04,21,18,00,00]),datenum([2019,06,03,4,43,45])];
% [datenum([2016,04,20,18,00,00]),datenum([2019,05,19,19,30,00])];
% [datenum([2016,04,20,6,00,00]),datenum([2019,05,19,8,32,30])];
% [datenum([2016,04,30,12,00,00]),datenum([2019,05,18,17,46,40])];
% [datenum([2016,04,29,12,00,00]),datenum([2019,05,17,18,17,30])];
% [datenum([2016,04,29,0,00,00]),datenum([2019,06,18,14,17,09])];
% [datenum([2016,04,28,12,00,00]),datenum([2019,05,28,4,01,15])];
% [datenum([2016,04,27,18,00,00]),datenum([2019,06,16,20,13,45])];
% [datenum([2016,04,26,18,00,00]),datenum([2019,06,15,11,03,45])]};

%%
queries = dbInit('Server','breach.ucsd.edu','Port',9779);

% Tethys expects longitudes in [0 360], not [-180 180] or 180W to 180E
for i = 1:size(HARPs,1)
    HARPs{i,1}(:,2) = 360 - HARPs{i,1}(:,2);
end

illum = [];
dep.illum = [];
dep.night = [];

for ia = 1:size(depNames,1)
    for ib = 1:size(depNames{ia,1},1)
        
        % break deployment up into 1-month chunks
        monthChunks = effort{ia,1}(ib,1):datenum([0 0 30 0 0 0]):effort{ia,1}(ib,2);
        if monthChunks(end)<effort{ia,1}(ib,2)
            monthChunks = [monthChunks,effort{ia,1}(ib,2)];
        end
        monthChunks(end) = monthChunks(end)+datenum([0 0 0 0 5 0]);
        
        % pull data one month at a time
        for ic = 1:(size(monthChunks,2)-1)
            
            dateRange = [monthChunks(ic),monthChunks(ic+1)-datenum([0 0 0 0 5 0])];
            % get lunar illumination data
            dep.illum = dbGetLunarIllumination(queries, HARPs{ia,1}(ib,1),HARPs{ia,1}(ib,2),dateRange(1),dateRange(2), interval, 'getDaylight', false);
            
            % get night duration data
                    dep.night = dbDiel(queries,HARPs{ia,1}(ib,1),HARPs{ia,1}(ib,2),effort{ia,1}(ib,1),effort{ia,1}(ib,2));
            
            illum = [illum;dep.illum];%night = [night;dep.night];
            dep.illum = [];
            %dep.night = [];
            
        end
        
        if ib==size(depNames{ia,1},1) % if we've got data for all deployments at this site, save it
%             saveName = fullfile(saveDir,[siteNames{ia,1},'_Illum_combined.mat']);
%             save(saveName,'illum','night','-v7.3');
            T = array2table(illum,'VariableNames',{'Date','MoonFrac','Azimuth','Elevation','Magnitude','SurfaceBrightness'});
            T.Date = datestr(T.Date);
            saveName = fullfile(saveDir,[siteNames{1,ia},'_Illum_5min.csv']);
            writetable(T,saveName,'WriteVariableNames',true);
        end
    end
end


