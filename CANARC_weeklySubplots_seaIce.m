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
GDrive = 'H';
SaveDir = [GDrive,':\My Drive\Manuscripts\CANARC\figures']; %where the xlsx documents are saved
filePrefix = 'CANARC_PI'; %site name for plots
%% load necessary files
DayTable = table2timetable(readtable([GDrive,':\My Drive\Manuscripts\CANARC\data\CANARC_PI Analysis\Workspace_Tables\DailyIceTablePI.xlsx']));
DayTable.Day = day(DayTable.tbin,'dayofyear');
DayTable.Year = year(DayTable.tbin);
% WeekTable = table2timetable(readtable([GDrive,':\My Drive\Manuscripts\CANARC\data\CANARC_PI Analysis\Workspace_Tables\WeeklyIceTable.xlsx']));
% WeekTable.Week = week(WeekTable.tbin);
% WeekTable.Year = year(WeekTable.tbin);

%%Load PI Ice Data
DayTable = table2timetable(readtable([GDrive,':\My Drive\Manuscripts\CANARC\data\CANARC_PI Analysis\Workspace_Tables\DailyIceTablePI.xlsx']));
DayTable.Day = day(DayTable.tbin,'dayofyear');
DayTable.Year = year(DayTable.tbin);
%%
% Plotting

% % Average weekly bin count subplot
% figure
% subplot(5,1,1)
% bar1 = bar(WeekTable.Week(WeekTable.Year==2015),WeekTable.DutyBin(WeekTable.Year==2015),'k'); %year 2015
% title('2015')
% xlim([30 42])
% ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2015))])
% subplot(5,1,2)
% bar2 = bar(WeekTable.Week(WeekTable.Year==2016),WeekTable.DutyBin(WeekTable.Year==2016),'k'); %year 2016
% title('2016')
% xlim([30 42])
% ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2016))])
% subplot(5,1,3)
% bar3 = bar(WeekTable.Week(WeekTable.Year==2017),WeekTable.DutyBin(WeekTable.Year==2017),'k'); %year 2017
% title('2017')
% xlim([30 42])
% ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2017))])
% ylabel('Average Weekly Bin Counts)')
% subplot(5,1,4)
% bar4 = bar(WeekTable.Week(WeekTable.Year==2018),WeekTable.DutyBin(WeekTable.Year==2018),'k');  %year 2018
% title('2018')
% xlim([30 42])
% ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2018))])
% subplot(5,1,5)
% bar5 = bar(WeekTable.Week(WeekTable.Year==2019),WeekTable.DutyBin(WeekTable.Year==2019),'k');  %year 2019
% title('2019')
% xlim([30 42])
% ylim([0 max(WeekTable.DutyBin(WeekTable.Year==2019))])
% xlabel('Week #')
% sgtitle('Average Weekly Bin Counts in Pond Inlet 2015-2019')
% % Save plot
% weeklyfn = [filePrefix,'_averageWeeklyBin_Subplots'];
% saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

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
%daily
figure
%sgtitle({'Daily Bin Counts in Pond Inlet', '2015-2019 with Sea Ice Concentration'})
subplot(5,1,1)
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'k'); %year 2015
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Ice(DayTable.Year==2015),[0 0.5]);
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Percent(DayTable.Year==2015),[-0.01 1.01],'.r');
title('2015')
xlim([182 300])
subplot(5,1,2)
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'k'); %year 2016
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Ice(DayTable.Year==2016),[0 0.5]);
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Percent(DayTable.Year==2016),[-0.01 1.01],'.r');
xlim([182 300])
title('2016')
subplot(5,1,3)
bar(DayTable.Day(DayTable.Year==2017),DayTable.DutyBin(DayTable.Year==2017),'k'); %year 2017
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Ice(DayTable.Year==2017),[0 0.5]);
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Percent(DayTable.Year==2017),[-0.01 1.01],'.r');
addaxislabel(1,'5-Minute Bins/Day')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
title('2017')
xlim([182 300])
subplot(5,1,4)
bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'k');  %year 2018
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Ice(DayTable.Year==2018),[0 0.5]);
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Percent(DayTable.Year==2018),[-0.01 1.01],'.r');
title('2018')
xlim([182 300])
subplot(5,1,5)
bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'k');  %year 2019
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Ice(DayTable.Year==2019),[0 0.5]);
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Percent(DayTable.Year==2019),[-0.01 1.01],'.r');
title('2019')
xlim([182 300])
xlabel('Day of Year')
% Save plot
dailyfn = [filePrefix,'_DailySeaIce_Subplots'];
saveas(gcf,fullfile(SaveDir,dailyfn),'png')

% %weekly
% figure
% subplot(5,1,1)
% bar(WeekTable.Week(WeekTable.Year==2015),WeekTable.DutyBin(WeekTable.Year==2015),'k'); %year 2015
% addaxis(WeekTable.Week(WeekTable.Year==2015),WeekTable.Ice(WeekTable.Year==2015),[0 0.5]);
% addaxis(WeekTable.Week(WeekTable.Year==2015),WeekTable.Percent(WeekTable.Year==2015),[-0.01 1.01],'.r');
% title('2015')
% xlim([28 44])
% subplot(5,1,2)
% bar(WeekTable.Week(WeekTable.Year==2016),WeekTable.DutyBin(WeekTable.Year==2016),'k'); %year 2016
% addaxis(WeekTable.Week(WeekTable.Year==2016),WeekTable.Ice(WeekTable.Year==2016),[0 0.5]);
% addaxis(WeekTable.Week(WeekTable.Year==2016),WeekTable.Percent(WeekTable.Year==2016),[-0.01 1.01],'.r');
% xlim([28 44])
% title('2016')
% subplot(5,1,3)
% bar(WeekTable.Week(WeekTable.Year==2017),WeekTable.DutyBin(WeekTable.Year==2017),'k'); %year 2017
% addaxis(WeekTable.Week(WeekTable.Year==2017),WeekTable.Ice(WeekTable.Year==2017),[0 0.5]);
% addaxis(WeekTable.Week(WeekTable.Year==2017),WeekTable.Percent(WeekTable.Year==2017),[-0.01 1.01],'.r');
% addaxislabel(1,'Average 5-Minute Bins/Week')
% addaxislabel(2,'Sea Ice Extent (million square km)')
% addaxislabel(3,'Percent Effort')
% title('2017')
% xlim([28 44])
% subplot(5,1,4)
% bar(WeekTable.Week(WeekTable.Year==2018),WeekTable.DutyBin(WeekTable.Year==2018),'k');  %year 2018
% addaxis(WeekTable.Week(WeekTable.Year==2018),WeekTable.Ice(WeekTable.Year==2018),[0 0.5]);
% addaxis(WeekTable.Week(WeekTable.Year==2018),WeekTable.Percent(WeekTable.Year==2018),[-0.01 1.01],'.r');
% title('2018')
% xlim([27 44])
% subplot(5,1,5)
% bar(WeekTable.Week(WeekTable.Year==2019),WeekTable.DutyBin(WeekTable.Year==2019),'k');  %year 2019
% addaxis(WeekTable.Week(WeekTable.Year==2019),WeekTable.Ice(WeekTable.Year==2019),[0 0.5]);
% addaxis(WeekTable.Week(WeekTable.Year==2019),WeekTable.Percent(WeekTable.Year==2019),[-0.01 1.01],'.r');
% title('2019')
% xlim([28 44])
% xlabel('Day of Year')
% %sgtitle('Average Weekly Bin Countss in Pond Inlet 2015-2019 with Sea Ice Concentration')
% % Save plot
% weeklyfn = [filePrefix,'_WeeklySeaIce_Subplots'];
% saveas(gcf,fullfile(SaveDir,weeklyfn),'png')

%% Adding SeaIce from the Pond Inlet only to plots
%daily
figure
%sgtitle({'Daily Bin Counts in Pond Inlet', '2015-2019 with Sea Ice Concentration'})
subplot(5,1,1)
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'k'); %year 2015
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Mean(DayTable.Year==2015),[0 100]);
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Percent(DayTable.Year==2015),[-0.01 1.01],'.r');
%title('2015')
xlim([182 300])
subplot(5,1,2)
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'k'); %year 2016
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Mean(DayTable.Year==2016),[0 100]);
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Percent(DayTable.Year==2016),[-0.01 1.01],'.r');
xlim([182 300])
%title('2016')
subplot(5,1,3)
bar(DayTable.Day(DayTable.Year==2017),DayTable.DutyBin(DayTable.Year==2017),'k'); %year 2017
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Mean(DayTable.Year==2017),[0 100]);
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Percent(DayTable.Year==2017),[-0.01 1.01],'.r');
addaxislabel(1,'5-Minute Bins/Day')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
%title('2017')
xlim([182 300])
subplot(5,1,4)
bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'k');  %year 2018
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Mean(DayTable.Year==2018),[0 100]);
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Percent(DayTable.Year==2018),[-0.01 1.01],'.r');
%title('2018')
xlim([182 300])
subplot(5,1,5)
bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'k');  %year 2019
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Mean(DayTable.Year==2019),[0 100]);
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Percent(DayTable.Year==2019),[-0.01 1.01],'.r');
%title('2019')
xlim([182 300])
xlabel('Day of Year')
% Save plot
dailyfn = [filePrefix,'_DailySeaIcePI_Subplots'];
saveas(gcf,fullfile(SaveDir,dailyfn),'png')

%% Adding SeaIce from the Pond Inlet only to plots
%Per suggestions changing effort to open circles
effort = [0.4660 0.6740 0.1880]; %light green color
%daily
figure
%sgtitle({'Daily Bin Counts in Pond Inlet', '2015-2019 with Sea Ice Concentration'})
subplot(5,1,1)
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'k'); %year 2015
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Mean(DayTable.Year==2015),[0 100],'blue','LineWidth',1.5);
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Percent(DayTable.Year==2015),[-0.01 1.01],'.','Color',effort);
%title('2015')
xlim([182 300])
subplot(5,1,2)
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'k'); %year 2016
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Mean(DayTable.Year==2016),[0 100],'blue','LineWidth',1);
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Percent(DayTable.Year==2016),[-0.01 1.01],'.','Color',effort);
xlim([182 300])
%title('2016')
subplot(5,1,3)
bar(DayTable.Day(DayTable.Year==2017),DayTable.DutyBin(DayTable.Year==2017),'k'); %year 2017
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Mean(DayTable.Year==2017),[0 100],'blue','LineWidth',1);
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Percent(DayTable.Year==2017),[-0.01 1.01],'.','Color',effort);
addaxislabel(1,'5-Minute Bins/Day')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
%title('2017')
xlim([182 300])
subplot(5,1,4)
bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'k');  %year 2018
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Mean(DayTable.Year==2018),[0 100],'blue','LineWidth',1);
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Percent(DayTable.Year==2018),[-0.01 1.01],'.','Color',effort);
%title('2018')
xlim([182 300])
subplot(5,1,5)
bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'k');  %year 2019
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Mean(DayTable.Year==2019),[0 100],'blue','LineWidth',1);
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Percent(DayTable.Year==2019),[-0.01 1.01],'.','Color',effort);
%title('2019')
xlim([182 300])
xlabel('Day of Year')
% Save plot
dailyfn = [filePrefix,'_DailySeaIcePI_Subplots_BlueGreen'];
saveas(gcf,fullfile(SaveDir,dailyfn),'png')
%% Adding SeaIce from the Pond Inlet only to plots
%Per suggestions changing effort to open circles
PM = [0 .5 .5]; %light green color
ICE = [91, 207, 244] / 255;
effort = [0.7, 0.7, 0.7];
%daily
figure
%sgtitle({'Daily Bin Counts in Pond Inlet', '2015-2019 with Sea Ice Concentration'})
subplot(5,1,1)
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'FaceColor',PM,'LineWidth',1.5);
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Mean(DayTable.Year==2015),[0 100],'Color',ICE); %year 2015
addaxis(DayTable.Day(DayTable.Year==2015),DayTable.Percent(DayTable.Year==2015),[-0.01 1.01],'.','Color',effort);
hold on
bar(DayTable.Day(DayTable.Year==2015),DayTable.DutyBin(DayTable.Year==2015),'FaceColor',PM,'LineWidth',1.5);
%title('2015')
xlim([182 300])
subplot(5,1,2)
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'FaceColor',PM,'LineWidth',1.5);
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Mean(DayTable.Year==2016),[0 100],'Color',ICE); %year 2016
addaxis(DayTable.Day(DayTable.Year==2016),DayTable.Percent(DayTable.Year==2016),[-0.01 1.01],'.','Color',effort);
xlim([182 300])
hold on
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'FaceColor',PM,'LineWidth',1.5);
%title('2016')
subplot(5,1,3)
bar(DayTable.Day(DayTable.Year==2017),DayTable.DutyBin(DayTable.Year==2017),'FaceColor',PM,'LineWidth',1.5);
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Mean(DayTable.Year==2017),[0 100],'Color',ICE); %year 2017
addaxis(DayTable.Day(DayTable.Year==2017),DayTable.Percent(DayTable.Year==2017),[-0.01 1.01],'.','Color',effort);
addaxislabel(1,'5-Minute Bins/Day')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
%title('2017')
xlim([182 300])
hold on
bar(DayTable.Day(DayTable.Year==2016),DayTable.DutyBin(DayTable.Year==2016),'FaceColor',PM,'LineWidth',1.5);
subplot(5,1,4)
bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'FaceColor',PM,'LineWidth',1.5);
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Mean(DayTable.Year==2018),[0 100],'Color',ICE); %year 2018
addaxis(DayTable.Day(DayTable.Year==2018),DayTable.Percent(DayTable.Year==2018),[-0.01 1.01],'.','Color',effort);
%title('2018')
xlim([182 300])
hold on
bar(DayTable.Day(DayTable.Year==2018),DayTable.DutyBin(DayTable.Year==2018),'FaceColor',PM,'LineWidth',1.5);
subplot(5,1,5)
bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'FaceColor',PM,'LineWidth',1.5);
ylim([0 100])
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Mean(DayTable.Year==2019),[0 100],'Color',ICE); %year 2018
addaxis(DayTable.Day(DayTable.Year==2019),DayTable.Percent(DayTable.Year==2019),[-0.01 1.01],'.','Color',effort);
%title('2019')
xlim([182 300])
hold on
bar(DayTable.Day(DayTable.Year==2019),DayTable.DutyBin(DayTable.Year==2019),'FaceColor',PM,'LineWidth',1.5);
xlabel('Day of Year')
% Save plot
dailyfn = [filePrefix,'_DailySeaIcePI_Subplots_PM_Color'];
saveas(gcf,fullfile(SaveDir,dailyfn),'png')
exportgraphics(gcf,'H:\My Drive\Manuscripts\CANARC\figures\DailySeaIcePI_Subplots_PM_Color.pdf','ContentType','vector','Resolution',300);