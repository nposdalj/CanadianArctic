%% 
%This code was modified from another script to plot weekly averages of sperm whales across
%sites.
%06/23/2020
%NP and CAS

%The modified version plots weekly averages as subplots with sea ice
%extent.
%03/15/2020
%NP

close all
clear all

%% Specity directories
SaveDir = 'E:\Project_Sites\CANARC\Plots'; %where the xlsx documents are saved
filePrefix = 'CANARC_PI'; %site name for plots

%% load necessary files
DayTable = readtable('E:\Project_Sites\CANARC\Plots\DailyIceTable.xlsx');
DayTable.Day = day(DayTable.tbin,'dayofyear');
WeekTable = readtable('E:\Project_Sites\CANARC\Plots\WeeklyIceTable.xlsx');
WeekTable.Week = week(WeekTable.tbin);
%%
% Plotting

% Average weekly bin count subplot
figure
subplot(5,1,1)
bar1 = bar(WeekTable.Week(WeekTable.Year==2015),WeekTable.DutyBin(WeekTable.Year==2015),'k'); %year 2015
title('2015')
xlim([30 40])
ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2015))])
subplot(5,1,2)
bar2 = bar(WeekTable.Week(WeekTable.Year==2016),WeekTable.DutyBin(WeekTable.Year==2016),'k'); %year 2016
title('2016')
xlim([30 40])
ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2016))])
subplot(5,1,3)
bar3 = bar(WeekTable.Week(WeekTable.Year==2017),WeekTable.DutyBin(WeekTable.Year==2017),'k'); %year 2017
title('2017')
xlim([30 40])
ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2017))])
ylabel('Average Weekly Bin Counts)')
subplot(5,1,4)
bar4 = bar(WeekTable.Week(WeekTable.Year==2018),WeekTable.DutyBin(WeekTable.Year==2018),'k');  %year 2018
title('2018')
xlim([30 40])
ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2018))])
subplot(5,1,5)
bar5 = bar(WeekTable.Week(WeekTable.Year==2019),WeekTable.DutyBin(WeekTable.Year==2019),'k');  %year 2019
title('2019')
xlim([30 40])
ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2019))])
xlabel('Week #')
sgtitle('Average Weekly Bin Counts in Pond Inlet 2015-2019')
% Save plot
weeklyfn = [filePrefix,'_averageWeeklyBin_Subplots'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

% Average daily bin count subplot
figure
subplot(5,1,1)
bar1 = bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'k'); %year 2015
title('2015')
% xlim([min(DayTable.Day(DayTable.Year == 2015)) max(DayTable.Day(DayTable.Year == 2015))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2015))])
subplot(5,1,2)
bar2 = bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'k'); %year 2016
title('2016')
% xlim([min(DayTable.Day(DayTable.Year == 2016)) max(DayTable.Day(DayTable.Year == 2016))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2016))])
subplot(5,1,3)
bar3 = bar(DayTable.Day(DayTable.Year==2017),DayTable.DutyBin(DayTable.Year==2017),'k'); %year 2017
title('2017')
% xlim([min(DayTable.Day(DayTable.Year == 2017)) max(DayTable.Day(DayTable.Year == 2017))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2017))])
ylabel('Average Daily Bin Counts')
subplot(5,1,4)
bar4 = bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'k');  %year 2018
title('2018')
% xlim([min(DayTable.Day(DayTable.Year == 2018)) max(DayTable.Day(DayTable.Year == 2018))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2018))])
subplot(5,1,5)
bar5 = bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'k');  %year 2019
title('2019')
% xlim([min(DayTable.Day(DayTable.Year == 2019)) max(DayTable.Day(DayTable.Year == 2019))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2019))])
xlabel('Day of Year')
sgtitle('Average Daily Bin Counts in Pond Inlet 2015-2019')
% Save plot
dailyfn = [filePrefix,'_averageDailyBin_Subplots'];
saveas(gcf,fullfile(SaveDir,dailyfn),'png')

%% Adding SeaIce to plots
figure
subplot(5,1,1)
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'k'); %year 2015
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Ice(DayTable.Year==2015));
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Percent(DayTable.Year==2015),[-0.01 1.01],'.r');
addaxislabel(1,'5-Minute Bins/Day')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
title('2015')
% xlim([min(DayTable.Day(DayTable.Year == 2015)) max(DayTable.Day(DayTable.Year == 2015))])
xlim([192 300])
ylim([0 max(DayTable.DutyBin(DayTable.Year==2015))])