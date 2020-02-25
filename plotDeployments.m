HZ = [datenum([2015,06,26]), datenum([2016,04,22]);
    datenum([2016,04,22]), datenum([2017,07,08]);
    datenum([2017,07,08]),datenum([2018,06,11]);
    datenum([2018,06,11]),datenum([2019,05,21])];
OC = [datenum([2015,04,25]), datenum([2016,04,23]);
    datenum([2016,04,24]), datenum([2017,07,07]);
    datenum([2017,07,07]),datenum([2018,06,09]);
    datenum([2018,06,10]),datenum([2019,05,21])];
NC = [datenum([2015,04,26]), datenum([2016,04,21]);
    datenum([2016,04,21]), datenum([2017,05,24]);
    datenum([2017,07,16]),datenum([2018,06,09]);
    datenum([2018,06,09]),datenum([2019,05,21])];
BC = [datenum([2016,04,20]), datenum([2017,06,10]);
    datenum([2017,06,30]),datenum([2018,06,03]);
    datenum([2018,06,03]),datenum([2019,05,21])];
WC = [datenum([2016,04,20]), datenum([2017,06,29]);
    datenum([2017,06,29]),datenum([2018,06,02]);
    datenum([2018,06,02]),datenum([2019,05,21])];
NFC = [datenum([2014,06,19]), datenum([2015,04,04]);
    datenum([2016,04,30]), datenum([2017,06,28]);
    datenum([2017,06,29]),datenum([2018,06,02]);
    datenum([2018,06,02]),datenum([2019,05,21])];
% NFC = [ datenum([2016,04,30]), datenum([2017,06,28]);
%     datenum([2017,06,29]),datenum([2018,06,02]);
%     datenum([2018,06,02]),datenum([2019,05,21])];
HAT = [datenum([2012,03,15]), datenum([2012,04,11]);
    datenum([2012,10,29]), datenum([2013,05,09]);
    datenum([2013,05,29]),datenum([2014,03,14]);
    datenum([2014,05,08]),datenum([2014,12,11]);
    datenum([2015,04,06]),datenum([2016,01,21]);
    datenum([2016,04,29]),datenum([2017,02,06]);
    datenum([2017,05,09]),datenum([2017,10,25]);
    datenum([2017,05,09]),datenum([2017,06,28]);
    datenum([2017,10,26]),datenum([2018,05,31]);
    datenum([2017,10,26]),datenum([2018,06,01]);
    datenum([2018,06,01]),datenum([2018,12,14])];
% HAT = [ datenum([2016,04,29]),datenum([2017,02,06]);
%     datenum([2017,05,09]),datenum([2017,10,25]);
%     datenum([2017,05,09]),datenum([2017,06,28]);
%     datenum([2017,10,26]),datenum([2018,05,31]);
%     datenum([2017,10,26]),datenum([2018,06,01]);
%     datenum([2018,06,01]),datenum([2018,12,14]);
%     datenum([2018,12,13]),datenum([2019,05,21])];
GS = [datenum([2016,04,28]), datenum([2017,06,27]);
    datenum([2017,06,27]),datenum([2018,06,28]);
    datenum([2018,06,28]),datenum([2019,05,21])];
BP = [datenum([2016,04,28]), datenum([2017,06,27]);
    datenum([2017,06,27]),datenum([2018,06,27]);
    datenum([2018,06,27]),datenum([2019,05,21])];
BS = [datenum([2016,04,27]), datenum([2017,06,26]);
    datenum([2017,06,26]),datenum([2018,06,27]);
    datenum([2018,06,27]),datenum([2019,05,21])];
JAX = [datenum([2009,04,01]), datenum([2009,05,24]);
    datenum([2009,04,01]), datenum([2009,09,05]);
    datenum([2009,09,16]),datenum([2009,12,27]);
    datenum([2010,02,21]),datenum([2010,07,30]);
    datenum([2010,03,09]),datenum([2010,08,19]);
    datenum([2010,08,26]),datenum([2011,01,25]);
    datenum([2010,08,26]),datenum([2011,02,01]);
    datenum([2011,02,01]),datenum([2011,07,14]);
    datenum([2013,05,12]),datenum([2013,06,20]);
    datenum([2014,02,17]),datenum([2014,08,23]);
    datenum([2014,08,23]),datenum([2015,05,29]);
    datenum([2015,07,02]),datenum([2015,11,04]);
    datenum([2016,04,26]),datenum([2017,06,25]);
    datenum([2017,06,25]),datenum([2018,06,28]);
    datenum([2018,06,28]),datenum([2019,05,21])];
% JAX = [datenum([2016,04,26]),datenum([2017,06,25]);
%     datenum([2017,06,25]),datenum([2018,06,28]);
%     datenum([2018,06,28]),datenum([2019,05,21])];


sites = {HZ,OC,NC,BC,WC,NFC,HAT,GS,BP,BS,JAX};
dates = [datenum([2009,01,01]):1:datenum([2019,05,21])];
% dates = [datenum([2016,01,01]):1:datenum([2019,05,21])];
dates(2:length(sites)+1,:) = NaN;

q = length(sites);
for i = 1:length(sites)
    for j = 1:length(sites{i})
        a = find(dates(1,:)>=sites{i}(j,1));
        b = find(dates(1,:)<=sites{i}(j,end));
        ind = intersect(a,b);
        dates(i+1,ind) = q;
    end
    q = q-1;
end

figure
plot(dates(1,:),dates(12,:),'.','MarkerSize',25);
hold on
plot(dates(1,:),dates(11,:),'.','MarkerSize',25);
plot(dates(1,:),dates(10,:),'.','MarkerSize',25);
plot(dates(1,:),dates(9,:),'.','MarkerSize',25);
plot(dates(1,:),dates(8,:),'.','MarkerSize',25);
plot(dates(1,:),dates(7,:),'.','MarkerSize',25);
plot(dates(1,:),dates(6,:),'.','MarkerSize',25);
plot(dates(1,:),dates(5,:),'.','MarkerSize',25);
plot(dates(1,:),dates(4,:),'.','MarkerSize',25);
plot(dates(1,:),dates(3,:),'.','MarkerSize',25);
plot(dates(1,:),dates(2,:),'.','MarkerSize',25);
hold off
ylim([0 12]);
yticks([1 2 3 4 5 6 7 8 9 10 11]);
yticklabels({'JAX','BS','BP','GS','HAT','NFC','WC','BC','NC','OC','HZ'});
xlabel('Date');
ylabel('Site');
title('Atlantic HARP Deployments');
set(gca,'fontSize',25)
% xticks([datenum(2009,01,01),datenum(2010,01,01),datenum(2011,01,01),...
%     datenum(2012,01,01),datenum(2013,01,01),datenum(2014,01,01),...
%     datenum(2015,01,01), datenum(2016,01,01),datenum(2017,01,01),...
%     datenum(2018,01,01),datenum(2019,01,01)]);
datetick('x');
xlim([dates(1,1827) dates(1,end)]);

saveas(gcf,'Atl_HARP_Deps','tiff');