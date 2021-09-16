% Use hourly presence data to generate diel plots with night shaded and
% lunar illumination represented.
% Expects all inputs in UTC; times will be adjusted to local for plotting
% Adapted from MAZ on 9/15/2021

clearvars
UTCOffset = -4;
presDir = 'H:\HourlyCT_Totals'; % directory containing hourly presence files
matchStr = '_HourlyTotals_Prob0_RL120_numClicks0.mat';
lumDir = 'H:\IlluminationFiles'; % directory containing lunar illumination and night files
outDir = 'H:\Diel Plots'; % directory to save plots
CTs = {'Blainvilles','Boats','CT11','CT2+CT9','CT3+CT7','CT46+CT10',...
    'CT5','CT8','Cuviers','Gervais','GoM Gervais','HFA','Kogia',...
    'MFA','MultiFreq Sonar','Rissos','SnapShrimp','Sowerbys',...
    'Sperm Whale','Trues'}';

%%

if ~isdir(outDir)
    mkdir(outDir)
end

presFileList = dir(fullfile(presDir,'*.mat'));

for ia = 1:size(presFileList,1)
    
    load(fullfile(presDir,presFileList(ia).name))
    load(fullfile(lumDir,strrep(presFileList(ia).name,matchStr,'_Illum.mat')));
    EffortSpan = [min(hourlyTots(:,1)),max(hourlyTots(:,1))];
    
    for ib = 1:size(CTs,1)
        CT = CTs{ib};
        name = strrep(presFileList(ia).name,matchStr,'');
        name = strrep(name,'_','\_');
        
        thisCT = hourlyTots(hourlyTots(:,ib+1)>0,1);
        thisCT(:,2) = thisCT(:,1) + datenum([0 0 0 1 0 0]);
        
        if ~isempty(thisCT)
            figure(99), clf
            % add shading during nighttime hours
            [nightH,~,~] = visPresence(night, 'Color', 'black', ...
                'LineStyle', 'none', 'Transparency', .15, 'UTCOffset',UTCOffset,...
                'Resolution_m', 1/60, 'DateRange', EffortSpan);
            
            % add lunar illumination data
            lunarH = visLunarIllumination(illum,'UTCOffset',UTCOffset);
            
            % add species presence data
            [BarH, ~, ~] = visPresence(thisCT, 'Color','blue',...
                'UTCOffset',UTCOffset,'Resolution_m',1/60, 'DateRange',EffortSpan,...
                'DateTickInterval',30,'Title',['Presence of ',CT,' at ',name]);
            
            %save plot
            saveName = strrep(presFileList(ia).name,matchStr,['_' CT]);
            saveas(figure(99),fullfile(outDir,saveName),'tiff');
            %         print('-painters','-depsc',fullfile(mapDir,savename));
        end
    end
end
