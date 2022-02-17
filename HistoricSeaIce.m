%Looking at Historical Sea ice data from 1850
SaveDir = 'H:\My Drive\Manuscripts\CANARC\figures\IceComp\';
%% Load Sea Ice data
SeaIce = readtable('H:\My Drive\Manuscripts\CANARC\data\Sea Ice\1850 Onward\nsidcSeaIceConc1850_c14f_4b41_6a0b.csv');
SeaIce(1,:) = []; %delete first row
%% Pond inlet Lat/Longs - 20km radius
LatHARP = 72.72;
LongHARP = -76.23;
LongHarp360 = 360 + LongHARP;
%% Find cells that are within the radius
[deg,~] = distance(LatHARP,LongHarp360, SeaIce.latitude, SeaIce.longitude);
D = deg2km(deg);
I=find(D<12); %12 is the smallest distance away from the center that I can do, this only includes one lat/lon point

SeaIce_Range = SeaIce(I,:); %index to find the lat/lon of interest

%Convert time to datetime
b=regexp(SeaIce_Range.time,'\T','split');
b=[b{:}];
B=datetime(b(1:2:end).','InputFormat','yyyy-MM-dd');
SeaIce_Range.date = B;

%Average months
SeaIce_Range = table(SeaIce_Range.date, SeaIce_Range.latitude, SeaIce_Range.longitude, SeaIce_Range.seaice_conc);
SeaIce_Range = table2timetable(SeaIce_Range);
SeaIce_Avg = retime(SeaIce_Range,'monthly','mean');
allVars = 1:width(SeaIce_Avg);
newNames = {'lat','lon','concentration'};
SeaIce_Avg =renamevars(SeaIce_Avg,allVars,newNames);

%Find the number of months each year with zero sea ice concentration
Zeros = find(SeaIce_Avg.concentration==0);
ZeroTable = SeaIce_Avg(Zeros,:);
ZeroTable = timetable2table(ZeroTable);
[ZeroTable.Yr,~,~] = ymd(ZeroTable.Var1);

%Find the minimum for each year
SeaIce_YearMin = retime(SeaIce_Avg,'yearly','min');
%% Plot for historical sea ice
figure
plot(SeaIce_Avg.Var1,SeaIce_Avg.concentration);
ylabel('Sea Ice Concentration')
xlabel('Time')
title('Monthly Sea Ice Concentration near Pond Inlet')
% Save plot
weeklyfn = 'HistoricalSeaIce_TimeSeries';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
plot(SeaIce_YearMin.Var1,SeaIce_YearMin.concentration,'.');
ylabel('Sea Ice Concentration')
xlabel('Year')
title('Minimum Sea Ice Concentration near Pond Inlet for Each Year')
ylim([-1 (max(SeaIce_YearMin.concentration)+1)])
% Save plot
weeklyfn = 'HistoricalSeaIce_Minima';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
hist(ZeroTable.Yr)
xlabel('Decade')
ylabel('Months')
title('Number of Months with a Sea Ice Concentration of Zero')
% Save plot
weeklyfn = 'HistoricalSeaIce_Hist';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%Group data by year
ZeroTableYr = retime(table2timetable(ZeroTable),'yearly','count');
bar(ZeroTableYr.Var1,ZeroTableYr.concentration)
%% Compare with JJ's Sea Ice
SeaIce_20km = readtable('H:\My Drive\Manuscripts\CANARC\data\Sea Ice\CANARC_PI_2012-2021_20km_landMask_stats_datestr_fromJJ.csv');
SeaIce_20km = table2timetable(SeaIce_20km);
SeaIce_20km_Month = retime(SeaIce_20km,'monthly','mean');
SeaIce_20km_Min = retime(SeaIce_20km,'yearly','min');

%Find the number of months each year with zero sea ice concentration
Zeros_20km = find(SeaIce_20km_Month.Mean <=5);
ZeroTable_20km = SeaIce_20km_Month(Zeros_20km,:);
ZeroTable_20km = timetable2table(ZeroTable_20km);
[ZeroTable_20km.Yr,~,~] = ymd(ZeroTable_20km.Date);
%% Plot for JJ's Sea Ice
figure
plot(SeaIce_20km.Date,SeaIce_20km.Mean);
ylabel('Sea Ice Concentration')
xlabel('Time')
title('Monthly Sea Ice Concentration near Pond Inlet (JJ)')
% Save plot
weeklyfn = 'JJ_TimeSeries';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
plot(SeaIce_20km_Min.Date,SeaIce_20km_Min.Mean,'.');
ylabel('Sea Ice Concentration')
xlabel('Year')
title('Minimum Sea Ice Concentration near Pond Inlet for Each Year (JJ)')
ylim([-1 (max(SeaIce_YearMin.concentration)+1)])
% Save plot
weeklyfn = 'JJ_Minima';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
hist(ZeroTable_20km.Yr)
xlabel('Year')
ylabel('Months')
title('Number of Months with a Sea Ice Concentration of Zero (JJ)')
% Save plot
weeklyfn = 'JJ_HistZero';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
hist(SeaIce_20km_Month.Mean)
xlabel('Decade')
ylabel('Months')
title('Minimum Sea Ice Concentration (JJ)')
% Save plot
weeklyfn = 'JJ_AllHist';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
%% Plot Sea Ice Concentration Over one Another
%Monthly with Daily
figure
plot(SeaIce_Avg.Var1,SeaIce_Avg.concentration);
hold on
plot(SeaIce_20km.Date,SeaIce_20km.Mean);
ylabel('Sea Ice Concentration')
xlabel('Time')
legend('Historical','JJ')
title('Monthly Sea Ice Concentration near Pond Inlet')
% Save plot
weeklyfn = 'Compare_FullTimeSeries_DayMonth';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%Monthly with Daily zoomed in on time period with overlap
figure
plot(SeaIce_Avg.Var1,SeaIce_Avg.concentration);
hold on
plot(SeaIce_20km.Date,SeaIce_20km.Mean);
ylabel('Sea Ice Concentration')
xlabel('Time')
legend('Historical','JJ')
xlim([datetime(['2012-07-01'],'InputFormat','yyyy-MM-dd') datetime(['2017-12-16'],'InputFormat','yyyy-MM-dd')]) 
title('Monthly vs Daily Sea Ice Concentration near Pond Inlet')
% Save plot
weeklyfn = 'Compare_Overlap_DayMonth';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%Monthly with Monthly
figure
plot(SeaIce_Avg.Var1,SeaIce_Avg.concentration);
hold on
plot(SeaIce_20km_Month.Date,SeaIce_20km_Month.Mean);
ylabel('Sea Ice Concentration')
xlabel('Time')
legend('Historical','JJ')
title('Monthly Sea Ice Concentration near Pond Inlet')
% Save plot
weeklyfn = 'Compare_FullTimeSeries_Month';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%Monthly with Monthly
figure
plot(SeaIce_Avg.Var1,SeaIce_Avg.concentration);
hold on
plot(SeaIce_20km_Month.Date,SeaIce_20km_Month.Mean);
ylabel('Sea Ice Concentration')
xlabel('Time')
legend('Historical','JJ')
xlim([datetime(['2012-07-01'],'InputFormat','yyyy-MM-dd') datetime(['2017-12-16'],'InputFormat','yyyy-MM-dd')]) 
title('Monthly Sea Ice Concentration near Pond Inlet')
% Save plot
weeklyfn = 'Compare_Overlap_Month';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%% Plot yearly median - all the data
SeaIce_Median = retime(SeaIce_Avg,'yearly', @(x) median(x,'omitnan'));

figure
plot(SeaIce_Median.Var1,SeaIce_Median.concentration,'o')
xlabel('Year')
ylabel('Median Sea Ice Concentration')
title('Yearly Median Sea Ice Concentration')
% Save plot
weeklyfn = 'Yearly_Median_SIC';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

[SeaIce_Median.Yr,~,~] = ymd(SeaIce_Median.Var1);
[SeaIce_Avg.Yr,~,~] = ymd(SeaIce_Avg.Var1);

figure
boxplot(SeaIce_Avg.concentration,categorical(SeaIce_Avg.Yr))
figure
violinplot(SeaIce_Avg.concentration,categorical(SeaIce_Avg.Yr))
%% Plot decadal median 
[groups,groupID] = findgroups(floor(SeaIce_Avg.Yr/10)*10); %group by decade
SeaIce_Avg.group = groups;
decMedian = splitapply(@median,SeaIce_Avg.concentration,groups);
plot(groupID,decMedian,'o')

figure
boxplot(SeaIce_Avg.concentration,categorical(SeaIce_Avg.group))
xlabel('Decade')
ylabel('Median Sea Ice Concentration')
title('Decadal Median Sea Ice Concentration')
% Save plot
weeklyfn = 'Decadal_MedianSIC_BoxPlots';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

figure
violinplot(SeaIce_Avg.concentration,categorical(SeaIce_Avg.group))
xlabel('Decade')
ylabel('Median Sea Ice Concentration')
ylabel('Median Sea Ice Concentration')
title('Decadal Median Sea Ice Concentration')
% Save plot
weeklyfn = 'Decadal_MedianSIC_ViolinPlots';
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%% Save tables
writetimetable(SeaIce_Avg,'H:\My Drive\Manuscripts\CANARC\data\Sea Ice\SeaIce_Range_Avg.csv');
writetimetable(SeaIce_Median,'H:\My Drive\Manuscripts\CANARC\data\Sea Ice\SeaIce_Range_Median.csv');