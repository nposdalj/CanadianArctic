clearvars
close all

%This code was written on 9/14/2020 to evaluate the effect of duty cycle on
%the CANARC data set. CANARC_PI_03 is duty cycled, so I 'duty cycled'
%deployments 1 (less presence) and 4 (more presence) to see how I should
%'supplement' deployment 03 for duty cycling. I use several different
%methods to evaluate this.

%NP

%% Parameters defined by user
filePrefix = 'CANARC_PI'; % File name to match 
siteabrev = 'CANARC'; %abbreviation of site.
sp = 'Pm'; % your species code
itnum = '2'; % which iteration you are looking for
srate = 200; % sample rate
tpwsPath = 'E:\Project_Sites\CANARC\TPWS_120to125'; %directory of TPWS files
effortXls = 'E:\Project_Sites\CANARC\Pm_Effort.xlsx'; % specify excel file with effort times
saveDir = 'E:\Project_Sites\CANARC'; %specify directory to save files
load([saveDir,'\',siteabrev,'_workspace125.mat']); %load workspace from sumPPICIbin_seasonality code
%% group data by 5min bins, days, weeks, and seasons
%group data by 5 minute bins
binDataIDX = (binData.Count < 5); %remove anything with less than 5 clicks in a bin
binData.Count(binDataIDX) = 0;
binTable = synchronize(binData,binEffort);
binTable.Properties.VariableNames{'bin'} = 'Effort_Bin';
binTable.Properties.VariableNames{'sec'} = 'Effort_Sec';
binTable.maxPP = [];
%binidx1 = (binTable.Count < 5);
%binTable.Count(binidx1) = 0;
[y,~]=size(binTable);
binTable.PreAbs = zeros(y,1);
binidx2 = (binTable.Count >= 5);
binTable.PreAbs(binidx2) = 1; %table with 0 for no presence in 5min bin and 1 with presence in 5min bin
%no effort bins are excluded 
binTable.Year = year(binTable.tbin); %add year
binTable.Minutes = minute(binTable.tbin); %add minutes
binTable.Day = day(binTable.tbin, 'dayofyear'); %add julian day

Click = retime(binData(:,1),'daily','sum'); % #click per day
binDataIDX_zeros = binData.Count == 0;
binData(~binData.Count,:) = [];
Bin = retime(binData(:,1),'daily','count'); % #bin per day

%group data by day
dayData = synchronize(Click,Bin);
dayEffort = retime(binEffort,'daily','sum');
dayTab = synchronize(dayData,dayEffort);
dayTable = synchronize(dayData,dayEffort);
dayTable.Properties.VariableNames{'bin'} = 'Effort_Bin';
dayTable.Properties.VariableNames{'sec'} = 'Effort_Sec';
dayTableZeros = dayTable;
[y,~]=size(dayTable);
dayTable.PreAbs = zeros(y,1);
dayTableidx1 = (dayTable.Count_Click >=5);
dayTable.PreAbs(dayTableidx1) = 1; %table with 0 for no presence in 5min bin and 1 with presence in 5min bin
dayTable(~dayTable.Effort_Bin,:)=[]; %removes days with no effort, NOT days with no presence
dayTable.Year = year(dayTable.tbin); % add year

%% Evaluating the duty cycle for 2016 - this method looks at two listening phases
%the 15 minutes on 20 minutes off cycle (1) and the 15 minutes off, 15
%minutes on, 5 minutes off cycle (2)

%15-minute listening phase 1
end2016 = find(binTable.Year == 2016,1,'last');
out1 = binTable(1:7:find(binTable.Year == 2016,1,'last'),:);
out2 = binTable(2:7:find(binTable.Year == 2016,1,'last'),:);
out3 = binTable(3:7:find(binTable.Year == 2016,1,'last'),:);
out_phase1 = [out1; out2; out3];
out_phase1 = sortrows(out_phase1,'tbin');
out_phas1idx = out_phase1.Count > 1;
[yy,~]=size(out_phase1);
out_phase1.BinCount = zeros(yy,1);
out_phase1.BinCount(out_phas1idx) = 1;

%15-minute listening phase 2
out4 = binTable(4:7:find(binTable.Year == 2016,1,'last'),:);
out5 = binTable(5:7:find(binTable.Year == 2016,1,'last'),:);
out6 = binTable(6:7:find(binTable.Year == 2016,1,'last'),:);
out_phase2 = [out4; out5; out6];
out_phase2 = sortrows(out_phase2,'tbin');
out_phas1idx2 = out_phase2.Count > 1;
[yy,~]=size(out_phase2);
out_phase2.BinCount = zeros(yy,1);
out_phase2.BinCount(out_phas1idx2) = 1;

%re-time re-sampled data for day data
out_phase1_dayTable = retime(out_phase1,'daily','sum');
out_phase1_dayTableIDX = out_phase1_dayTable.Count > 0;
out_phase1_dayTable.PreAbs(out_phase1_dayTableIDX) = 1;
out_phase2_dayTable = retime(out_phase2,'daily','sum');
out_phase2_dayTableIDX = out_phase2_dayTable.Count > 0;
out_phase2_dayTable.PreAbs(out_phase2_dayTableIDX) = 1;

% days missed with detections
DaysMissed = synchronize(dayTable(dayTable.Year == 2016,5),out_phase1_dayTable(:,4),out_phase2_dayTable(:,4));

ContData = ['Continuous data had ',num2str(sum(DaysMissed.PreAbs_3)),' days with sperm whale detections in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(sum(DaysMissed.PreAbs_1)),' days with sperm whale detections in 2016'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(sum(DaysMissed.PreAbs_2)),' days with sperm whale detections in 2016'];
disp(DutyCycle2)

% clicks missed
ClicksMissed = synchronize(dayTable(dayTable.Year == 2016,1),out_phase1_dayTable(:,1),out_phase2_dayTable(:,1));
ContData = ['Continuous data had ',num2str(nansum(ClicksMissed.Count_Click)),' clicks total in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(sum(ClicksMissed.Count_2)),' clicks total in 2016'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(sum(ClicksMissed.Count_3)),' clicks total in 2016'];
disp(DutyCycle2)

% bins missed per day
BinsMissed = synchronize(dayTable(dayTable.Year == 2016,2),out_phase1_dayTable(:,8),out_phase2_dayTable(:,8));
ContData = ['Continuous data had ',num2str(nansum(BinsMissed.Count_Bin)),' Bins total in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(sum(BinsMissed.BinCount_2)),' Bins total in 2016'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(sum(BinsMissed.BinCount_3)),' Bins total in 2016'];
disp(DutyCycle2)

% what percent to inflate the duty cycled data by
%clicks inflation
ClicksMissed.AvgDutCycle = mean(ClicksMissed{:,2:3},2); %average number of clicks with a duty cycle
ClicksMissed.Inflation = ClicksMissed.AvgDutCycle./ClicksMissed.Count_Click;

%bin inflation
BinsMissed.AvgDutCycle = mean(BinsMissed{:,2:3},2); %average number of bins with a duty cycle
BinsMissed.Inflation = BinsMissed.AvgDutCycle./BinsMissed.Count_Bin;

%% Plotting 2016
%plot the two listening phases with the original data

%Number of clicks in individual bins
figure
subplot(3,1,1)
bar(out_phase1.tbin,out_phase1.Count)
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylim([min(out_phase1.Count) max(out_phase1.Count)])
title('Duty Cycle Regime 1')
set(gca, 'YScale', 'log')
subplot(3,1,2)
bar(out_phase2.tbin,out_phase2.Count)
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylabel('# of Clicks in Each 5-min Bin');
ylim([min(out_phase2.Count) max(out_phase2.Count)])
title('Duty Cycle Regime 2')
set(gca, 'YScale', 'log')
subplot(3,1,3)
bar(binTable.tbin(binTable.Year ==2016),binTable.Count(binTable.Year ==2016))
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylim([min(binTable.Count(binTable.Year==2016)) max(binTable.Count(binTable.Year==2016))])
title('Continuous Data')
sgtitle({'Comparing Click Detections in 5-Minute Bins in 2016:', 'Duty Cycle Regimes vs. Continuous Data'});
set(gca, 'YScale', 'log')

%Clicks per day
figure
subplot(3,1,1)
bar(out_phase1_dayTable.tbin,out_phase1_dayTable.Count)
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylim([min(out_phase1_dayTable.Count) max(out_phase1_dayTable.Count)])
title('Duty Cycle Regime 1')
subplot(3,1,2)
bar(out_phase2_dayTable.tbin,out_phase2_dayTable.Count)
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylabel('# of Clicks Per Day');
ylim([min(out_phase2_dayTable.Count) max(out_phase2_dayTable.Count)])
title('Duty Cycle Regime 2')
subplot(3,1,3)
bar(dayTable.tbin(dayTable.Year ==2016),dayTable.Count_Click(dayTable.Year ==2016))
xlim([datetime('08-Aug-2016'),datetime('23-Aug-2016')]); 
ylim([min(dayTable.Count_Click(dayTable.Year==2016)) max(dayTable.Count_Click(dayTable.Year==2016))])
title('Continuous Data')
sgtitle({'Comparing Clicks Detections Per Day in 2016:', 'Duty Cycle Regimes vs. Continuous Data'});

%% Evaluating the duty cycle for 2018 and 2019

%15-minute listening phase 1
out11 = binTable(find(binTable.Year ==2018,1,'first'):7:find(binTable.Year == 2019,1,'last'),:);
out22 = binTable(find(binTable.Year ==2018,1,'first')+1:7:find(binTable.Year == 2019,1,'last'),:);
out33 = binTable(find(binTable.Year ==2018,1,'first')+2:7:find(binTable.Year == 2019,1,'last'),:);
out_phase11 = [out11; out22; out33];
out_phase11 = sortrows(out_phase11,'tbin');
out_phas1idx = out_phase11.Count > 1;
[yy,~]=size(out_phase11);
out_phase11.BinCount = zeros(yy,1);
out_phase11.BinCount(out_phas1idx) = 1;

%15-minute listening phase 2
out44 = binTable(find(binTable.Year ==2018,1,'first')+3:7:find(binTable.Year == 2019,1,'last'),:);
out55 = binTable(find(binTable.Year ==2018,1,'first')+4:7:find(binTable.Year == 2019,1,'last'),:);
out66 = binTable(find(binTable.Year ==2018,1,'first')+5:7:find(binTable.Year == 2019,1,'last'),:);
out_phase22 = [out44; out55; out66];
out_phase22 = sortrows(out_phase22,'tbin');
out_phas1idx2 = out_phase22.Count > 1;
[yy,~]=size(out_phase22);
out_phase22.BinCount = zeros(yy,1);
out_phase22.BinCount(out_phas1idx2) = 1;

%re-time re-sampled data for day data
out_phase11_dayTable = retime(out_phase11,'daily','sum');
out_phase11_dayTableIDX = out_phase11_dayTable.Count > 0;
out_phase11_dayTable.PreAbs(out_phase11_dayTableIDX) = 1;
out_phase22_dayTable = retime(out_phase22,'daily','sum');
out_phase22_dayTableIDX = out_phase22_dayTable.Count > 0;
out_phase22_dayTable.PreAbs(out_phase22_dayTableIDX) = 1;

% days missed with detections
DaysMissed2 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),5),out_phase11_dayTable(:,4),out_phase22_dayTable(:,4));
ContData = ['Continuous data had ',num2str(nansum(DaysMissed2.PreAbs_1)),' days with sperm whale detections in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(nansum(DaysMissed2.PreAbs_2)),' days with sperm whale detections in 2018 and 2019'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(nansum(DaysMissed2.PreAbs_3)),' days with sperm whale detections in 2018 and 2019'];
disp(DutyCycle2)

% clicks missed
ClicksMissed2 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),1),out_phase11_dayTable(:,1),out_phase22_dayTable(:,1));
ContData = ['Continuous data had ',num2str(nansum(ClicksMissed2.Count_Click)),' clicks total in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(nansum(ClicksMissed2.Count_2)),' clicks total in 2018 and 2019'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(nansum(ClicksMissed2.Count_3)),' clicks total in 2018 and 2019'];
disp(DutyCycle2)

% bins missed per day
BinsMissed2 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),2),out_phase11_dayTable(:,8),out_phase22_dayTable(:,8));
ContData = ['Continuous data had ',num2str(nansum(BinsMissed2.Count_Bin)),' Bins total in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle1 had ',num2str(nansum(BinsMissed2.BinCount_2)),' Bins total in 2018 and 2019'];
disp(DutyCycle1)
DutyCycle2 = ['Duty Cycle2 had ',num2str(nansum(BinsMissed2.BinCount_3)),' Bins total'];
disp(DutyCycle2)

% what percent to inflate the duty cycled data by
%clicks inflation
ClicksMissed2.AvgDutCycle = mean(ClicksMissed2{:,2:3},2); %average number of clicks with a duty cycle
ClicksMissed2.Inflation = ClicksMissed2.AvgDutCycle./ClicksMissed2.Count_Click;

%bin inflation
BinsMissed2.AvgDutCycle = mean(BinsMissed2{:,2:3},2); %average number of bins with a duty cycle
BinsMissed2.Inflation = BinsMissed2.AvgDutCycle./BinsMissed2.Count_Bin;

%% Plotting 2018 and 2019
%plot the two listening phases with the original data

%clicks in 5-minute bins
figure
subplot(3,1,1)
bar(out_phase11.tbin,out_phase11.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase11.Count) max(out_phase11.Count)])
set(gca, 'YScale', 'log')
title('Duty Cycle Regime 1')
subplot(3,1,2)
bar(out_phase22.tbin,out_phase22.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase22.Count) max(out_phase22.Count)])
set(gca, 'YScale', 'log')
title('Duty Cycle Regime 2')
ylabel('# of Clicks Per Day')
subplot(3,1,3)
bar(binTable.tbin(binTable.Year == 2018 | 2019),binTable.Count(binTable.Year == 2018 | 2019))
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(binTable.Count(binTable.Year== 2018 | 2019)) max(binTable.Count(binTable.Year== 2018 | 2019))])
set(gca, 'YScale', 'log')
title('Continuous Data')
sgtitle({'Comparing Clicks Detections in 5-Minute Bins in 2018 and 2019:', 'Duty Cycle Regimes vs. Continuous Data'});

%re-time re-sampled data for day data
out_phase11_dayTable = retime(out_phase11,'daily','sum');
out_phase22_dayTable = retime(out_phase22,'daily','sum');

%Clicks per day log scale
figure
subplot(3,1,1)
bar(out_phase11_dayTable.tbin,out_phase11_dayTable.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase11_dayTable.Count) max(out_phase11_dayTable.Count)])
set(gca, 'YScale', 'log')
title('Duty Cycle Regime 1')
subplot(3,1,2)
bar(out_phase22_dayTable.tbin,out_phase22_dayTable.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase22_dayTable.Count) max(out_phase22_dayTable.Count)])
title('Duty Cycle Regime 2')
set(gca, 'YScale', 'log')
ylabel('# of 5-min Bins Per Day (log scale)')
subplot(3,1,3)
bar(dayTable.tbin(dayTable.Year ==2019 | 2018),dayTable.Count_Click(dayTable.Year ==2019 | 2018))
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(dayTable.Count_Click(dayTable.Year==2019 | 2018)) max(dayTable.Count_Click(dayTable.Year==2019 | 2018))])
set(gca, 'YScale', 'log')
title('Continuous Data')
sgtitle({'Comparing Click Detections Per Day in 2018 and 2019:', 'Duty Cycle Regimes vs. Continuous Data'});

%clicks per day
figure
subplot(3,1,1)
bar(out_phase11_dayTable.tbin,out_phase11_dayTable.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase11_dayTable.Count) max(out_phase11_dayTable.Count)])
title('Duty Cycle Regime 1')
subplot(3,1,2)
bar(out_phase22_dayTable.tbin,out_phase22_dayTable.Count)
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(out_phase22_dayTable.Count) max(out_phase22_dayTable.Count)])
title('Duty Cycle Regime 2')
ylabel('# of 5-min Bins Per Day')
subplot(3,1,3)
bar(dayTable.tbin(dayTable.Year ==2019 | 2018),dayTable.Count_Click(dayTable.Year ==2019 | 2018))
xlim([datetime('01-Jul-2018'),datetime('31-Oct-2019')]); 
ylim([min(dayTable.Count_Click(dayTable.Year==2019 | 2018)) max(dayTable.Count_Click(dayTable.Year==2019 | 2018))])
title('Continuous Data')
sgtitle({'Comparing 5-Min Bin Detections Per Day in 2018 and 2019:', 'Duty Cycle Regimes vs. Continuous Data'});

%% Evaluating duty cycle a different way
%With this method, you randomly sample 3, 5-minute bins out of every 35 minutes
%seperate tables by year and add bin count
%2015
binTable2016 = binTable(1:find(binTable.Year == 2016,1,'last'),:); 
binTable2016IDX = binTable2016.Count > 1;
[yy,~]=size(binTable2016);
binTable2016.BinCount = zeros(yy,1);
binTable2016.BinCount(binTable2016IDX) = 1;

%2018/2019
binTable2018_19 = binTable(find(binTable.Year == 2018,1,'first'):find(binTable.Year == 2019,1,'last'),:);out_phas1idx2 = out_phase22.Count > 1;
binTable2018_19IDX = binTable2018_19.Count > 1;
[yy,~]=size(binTable2018_19);
binTable2018_19.BinCount = zeros(yy,1);
binTable2018_19.BinCount(binTable2018_19IDX) = 1;

%find size of tables
[y16,~] = size(binTable2016);
[y1819,~] = size(binTable2018_19);

%subsample 3 random 5 minute bins (15 minutes total) out of every 35 minute
%cycle (7 rows)

%2016
SubS2016 = []; 
for i = 1:7:y16-1
    dataRange = binTable2016(i:i+6,:);
    SubS = datasample(dataRange,3,'Replace',false);
    SubS2016 = [SubS2016; SubS];
end

%2018 and 2019
SubS2018_19 = []; 
for i = 1:7:y1819-1
    dataRange2 = binTable2018_19(i:i+6,:);
    SubS = datasample(dataRange2,3,'Replace',false);
    SubS2018_19 = [SubS2018_19; SubS];
end

%re-time re-sampled data for day data
%2016
SubS2016_dayTable = retime(SubS2016,'daily','sum');
SubS2016_dayTableIDX = SubS2016_dayTable.Count > 0;
SubS2016_dayTable.PreAbs(SubS2016_dayTableIDX) = 1;

%2018/2019
SubS2018_19_dayTable = retime(SubS2018_19,'daily','sum');
SubS2018_19_dayTableIDX = SubS2018_19_dayTable.Count > 0;
SubS2018_19_dayTable.PreAbs(SubS2018_19_dayTableIDX) = 1;

% days missed with detections
%2016
DaysMissed_16 = synchronize(dayTable((dayTable.Year == 2016),5),SubS2016_dayTable(:,4));
ContData = ['Continuous data had ',num2str(nansum(DaysMissed_16.PreAbs_1)),' days with sperm whale detections in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(DaysMissed_16.PreAbs_2)),' days with sperm whale detections in 2016'];
disp(DutyCycle1)

%2018/2019
DaysMissed_1819 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),5),SubS2018_19_dayTable(:,4));
ContData = ['Continuous data had ',num2str(nansum(DaysMissed_1819.PreAbs_1)),' days with sperm whale detections in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(DaysMissed_1819.PreAbs_2)),' days with sperm whale detections in 2018 and 2019'];
disp(DutyCycle1)

% clicks missed
%2016
ClicksMissed_16 = synchronize(dayTable((dayTable.Year == 2016),1),SubS2016_dayTable(:,1));
ContData = ['Continuous data had ',num2str(nansum(ClicksMissed_16.Count_Click)),' clicks total in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(ClicksMissed_16.Count)),' clicks total in 2016'];
disp(DutyCycle1)

%2018/2019
ClicksMissed_1819 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),1),SubS2018_19_dayTable(:,1));
ContData = ['Continuous data had ',num2str(nansum(ClicksMissed_1819.Count_Click)),' clicks total in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(ClicksMissed_1819.Count)),' clicks total in 2018 and 2019'];
disp(DutyCycle1)

% bins missed per day
%2016
BinsMissed_16 = synchronize(dayTable((dayTable.Year == 2016),2),SubS2016_dayTable(:,8));
ContData = ['Continuous data had ',num2str(nansum(BinsMissed_16.Count_Bin)),' Bins total in 2016'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(BinsMissed_16.BinCount)),' Bins total in 2016'];
disp(DutyCycle1)

%2018/2019
BinsMissed_1819 = synchronize(dayTable((dayTable.Year == 2018 | dayTable.Year == 2019),2),SubS2018_19_dayTable(:,8));
ContData = ['Continuous data had ',num2str(nansum(BinsMissed_1819.Count_Bin)),' Bins total in 2018 and 2019'];
disp(ContData)
DutyCycle1 = ['Duty Cycle had ',num2str(nansum(BinsMissed_1819.BinCount)),' Bins total in 2018 and 2019'];
disp(DutyCycle1)

% what percent to inflate the duty cycled data by
%clicks inflation
ClicksMissed_16.Inflation = ClicksMissed_16.Count./ClicksMissed_16.Count_Click; %2016
ClicksMissed_1819.Inflation = ClicksMissed_1819.Count./ClicksMissed_1819.Count_Click; %2018/2019

%bin inflation
BinsMissed_16.Inflation = BinsMissed_16.BinCount./BinsMissed_16.Count_Bin; %2016
BinsMissed_1819.Inflation = BinsMissed_1819.BinCount./BinsMissed_1819.Count_Bin; %2018/2019

max(ClicksMissed_16.Inflation)
min(ClicksMissed_16.Inflation)
nanmean(ClicksMissed_16.Inflation)
nanmedian(ClicksMissed_16.Inflation)

max(BinsMissed_16.Inflation)
min(BinsMissed_16.Inflation)
nanmean(BinsMissed_16.Inflation)
nanmedian(BinsMissed_16.Inflation)

max(ClicksMissed_1819.Inflation)
min(ClicksMissed_1819.Inflation)
nanmean(ClicksMissed_1819.Inflation)
nanmedian(ClicksMissed_1819.Inflation)

max(BinsMissed_1819.Inflation)
min(BinsMissed_1819.Inflation)
nanmean(BinsMissed_1819.Inflation)
nanmedian(BinsMissed_1819.Inflation)

%% Evaluating the duty cycle by shifting the 15 minute listening period by 1 minute
%within the entire 35 minute cycle. This will result in 35 samples.
%group data by 1 minute bins
tbin = datetime([vTT(:,1:4), floor(vTT(:,5)), ...
    zeros(length(vTT),1)]); %round to the nearest minute
data = timetable(tbin,TTall,PPall);
MinData = varfun(@max,data,'GroupingVariable','tbin','InputVariable','PPall');
MinData.Properties.VariableNames{'GroupCount'} = 'Count'; % #clicks per bin
MinData.Properties.VariableNames{'max_PPall'} = 'maxPP';

%Calculate 1-minute bin effort
if er > 1
    MinbinEffort = intervalTo1MinBinTimetable(effort.Start,effort.End,p); % convert intervals in bins when there is multiple lines of effort
    %binEffort.sec = binEffort.bin*(p.binDur*60);
else
    %binEffort = intervalToBinTimetable_Only1RowEffort(effort.Start,effort.End,p); % convert intervals in bins when there is only one line of effort
    %binEffort.sec = binEffort.bin*(p.binDur*60);
end

clickTable = synchronize(MinData,MinbinEffort); %table with clicks per 1-min bin
clickTable.Properties.VariableNames{'effortBin'} = 'Effort_Bin';
clickTable.Properties.VariableNames{'effortSec'} = 'Effort_Sec';
clickTable.maxPP = [];

clickTable = timetable2table(clickTable);
clickTable.Year = year(clickTable.tbin);

%2016
clickTable2016 = clickTable(find(clickTable.Year == 2016,1,'first'):find(clickTable.Year == 2016,1,'last'),:);
clickTable2016.Effort_Bin = [];
clickTable2016.Effort_Sec = [];
clickTable2016.Year = [];
[cT16,~] = size(clickTable2016);

clickTable2016 = table2timetable(clickTable2016);

All_2016_Clicks = [];
for j = 1:35
    Sub_2016 = [];
    for i = j:35:cT16-2
        cycleRange = i:i+34;
        columnsToDelete = cycleRange > 312481;
        cycleRange(columnsToDelete) = [];
        dataRange = clickTable2016(cycleRange,:);
        [xx,~] = size(dataRange);
        if xx < 15
            SubS = dataRange;
        else
            SubS = dataRange(1:15,:);
        end
        Sub_2016 = [Sub_2016;SubS];
    end
    Sub_2016.Properties.VariableNames{'Count'} = ['Count_Sub',num2str(j)];
    if j > 1
        All_2016_Clicks = synchronize(All_2016_Clicks,Sub_2016);
    else
        All_2016_Clicks = synchronize(clickTable2016,Sub_2016);
    end
end

binEffort.Year = year(binEffort.tbin); 
binEffort16 = binEffort(find(binEffort.Year == 2016,1,'first'):find(binEffort.Year == 2016,1,'last'),:);

All_2016_Bins = synchronize(binEffort16,All_2016_Clicks,'regular','sum','TimeStep',minutes(5));

%remove bins with less than 5 clicks for continuous data
Count2016IDX = (All_2016_Bins.Count < 5);
All_2016_Bins.Count(Count2016IDX) = 0;

for i = 1:35
    variableName = ['Count_Sub',num2str(i)];
    All2016IDX = (All_2016_Bins.(variableName) < 5); %remove anything with less than 5 clicks in a bin
    All_2016_Bins.(variableName)(All2016IDX) = 0;
end

%Average # of bins with sperm whales
%All_2016_Bins{:,2:end}(All_2016_Bins{:,2:end} == 0) = NaN;
%All_2016_Bins.DutyAvg = mean(All_2016_Bins{:,3:end},2,'omitnan'); %average number of clicks in each bin
All_2016_Bins.DutyAvg = mean(All_2016_Bins{:,3:end},2);
All_2016_Bins.Diff = All_2016_Bins.Count - All_2016_Bins.DutyAvg; %average number of missed clicks in each bin
%what to multiply the duty cycled data by to supplement so it can look like the continuous data
All_2016_Bins.Supp = All_2016_Bins.Count./All_2016_Bins.DutyAvg; 
%what does the duty cycle percent look like, compared to the actual duty cycle which was recording 43% of the time
All_2016_Bins.DutyPercent = All_2016_Bins.DutyAvg./All_2016_Bins.Count; 
%Multiply the duty cycled average number of clicks in each bin by the
%'supplement' so you can see what number of clicks you'd have if you
%recorded continuously
All_2016_Bins.Adj = All_2016_Bins.DutyAvg .* All_2016_Bins.Supp;
All_2016_Bins.DiffAdj = All_2016_Bins.Count - All_2016_Bins.Adj; %sanity check, what's the difference between the 
%actual recorded number of clicks and the 'adjusted' number of clicks based
%on the supplemented duty cycled data

%Missed Clicks in 5-Minute bins
figure
idx = All_2016_Bins.Diff > 0;
hist(All_2016_Bins.Diff(idx))
title('Histogram of Missed Clicks in 5-Minute Bins in 2016')
xlabel('# of Missed Clicks in Each 5-Min Bin')
ylabel('Count')

%Average Duty cycle
Mean_2016 = nanmean(All_2016_Bins.DutyPercent);
Avg2016_DutyCycle = ['The average duty cycle for 2016 was ',num2str(Mean_2016)];
disp(Avg2016_DutyCycle)

%Average # of days with sperm whales 
%retime bin table for daily
columnIndices2Delete = [1 38 39 40 41 42 43];
All_2016_BinsINT = All_2016_Bins;
All_2016_BinsINT(:,columnIndices2Delete) = [];
All_2016_Days = retime(All_2016_BinsINT,'daily','sum');

%recalculate all columns
%All_2016_Days{:,2:end}(All_2016_Days{:,2:end} == 0) = NaN;
All_2016_Days.DutyAvg = mean(All_2016_Days{:,3:end},2); %average number of clicks in each bin
All_2016_Days.Diff = All_2016_Days.Count - All_2016_Days.DutyAvg; %average number of missed clicks in each bin
%what to multiply the duty cycled data by to supplement so it can look like the continuous data
All_2016_Days.Supp = All_2016_Days.Count./All_2016_Days.DutyAvg; 
%what does the duty cycle percent look like, compared to the actual duty cycle which was recording 43% of the time
All_2016_Days.DutyPercent = All_2016_Days.DutyAvg./All_2016_Days.Count; 
%Multiply the duty cycled average number of clicks in each bin by the
%'supplement' so you can see what number of clicks you'd have if you
%recorded continuously
All_2016_Days.Adj = All_2016_Days.DutyAvg .* All_2016_Days.Supp;
All_2016_Days.DiffAdj = All_2016_Days.Count - All_2016_Days.Adj; %sanity check, what's the difference between the 
%actual recorded number of clicks and the 'adjusted' number of clicks based
%on the supplemented duty cycled data

%Missed 5-Minute bins each day
figure
idx = All_2016_Days.Diff > 0;
hist(All_2016_Days.Diff(idx))
title('Histogram of Missed 5-Minute Bins each day in 2016')
xlabel('# of Missed 5-Min Bins Each Day')
ylabel('Count')

%Average Duty cycle
Mean_2016 = nanmean(All_2016_Days.DutyPercent);
Avg2016_DutyCycle = ['The average duty cycle for 2016 was ',num2str(Mean_2016)];
disp(Avg2016_DutyCycle)

%2018/2019 deployment
clickTable20189 = clickTable(find(clickTable.Year == 2018,1,'first'):find(clickTable.Year == 2019,1,'last'),:);
clickTable20189.Effort_Bin = [];
clickTable20189.Effort_Sec = [];
clickTable20189.Year = [];
[cT189,~] = size(clickTable20189);

clickTable20189 = table2timetable(clickTable20189);

All_20189_Clicks = [];
for j = 1:35
    Sub_20189 = [];
    for i = j:35:cT189-2
        cycleRange = i:i+34;
        columnsToDelete = cycleRange > 549204;
        cycleRange(columnsToDelete) = [];
        dataRange = clickTable20189(cycleRange,:);
        [xx,~] = size(dataRange);
        if xx < 15
            SubS = dataRange;
        else
            SubS = dataRange(1:15,:);
        end
        Sub_20189 = [Sub_20189;SubS];
    end
    Sub_20189.Properties.VariableNames{'Count'} = ['Count_Sub',num2str(j)];
    if j > 1
        All_20189_Clicks = synchronize(All_20189_Clicks,Sub_20189);
    else
        All_20189_Clicks = synchronize(clickTable20189,Sub_20189);
    end
end

binEffort.Year = year(binEffort.tbin); 
binEffort189 = binEffort(find(binEffort.Year == 2018,1,'first'):find(binEffort.Year == 2019,1,'last'),:);

All_20189_Bins = synchronize(binEffort189,All_20189_Clicks,'regular','sum','TimeStep',minutes(5));

%remove bins with less than 5 clicks for continuous data
Count20189IDX = (All_20189_Bins.Count < 5);
All_20189_Bins.Count(Count20189IDX) = 0;

for i = 1:35
    variableName = ['Count_Sub',num2str(i)];
    All20189IDX = (All_20189_Bins.(variableName) < 5); %remove anything with less than 5 clicks in a bin
    All_20189_Bins.(variableName)(All20189IDX) = 0;
end

%Average # of bins with sperm whales
All_20189_Bins.DutyAvg = mean(All_20189_Bins{:,3:end},2);
All_20189_Bins.Diff = All_20189_Bins.Count - All_20189_Bins.DutyAvg; %average number of missed clicks in each bin
%what to multiply the duty cycled data by to supplement so it can look like the continuous data
All_20189_Bins.Supp = All_20189_Bins.Count./All_20189_Bins.DutyAvg; 
%what does the duty cycle percent look like, compared to the actual duty cycle which was recording 43% of the time
All_20189_Bins.DutyPercent = All_20189_Bins.DutyAvg./All_20189_Bins.Count; 
%Multiply the duty cycled average number of clicks in each bin by the
%'supplement' so you can see what number of clicks you'd have if you
%recorded continuously
All_20189_Bins.Adj = All_20189_Bins.DutyAvg .* All_20189_Bins.Supp;
All_20189_Bins.DiffAdj = All_20189_Bins.Count - All_20189_Bins.Adj; %sanity check, what's the difference between the 
%actual recorded number of clicks and the 'adjusted' number of clicks based
%on the supplemented duty cycled data

%Missed Clicks in 5-Minute bins
figure
idx = All_20189_Bins.Diff > 0;
hist(All_20189_Bins.Diff(idx))
title('Histogram of Missed Clicks in 5-Minute Bins in 2018/2019')
xlabel('# of Missed Clicks in Each 5-Min Bin')
ylabel('Count')

%Average Duty cycle
Mean_20189 = nanmean(All_20189_Bins.DutyPercent);
Avg20189_DutyCycle = ['The average duty cycle for 2018/2019 was ',num2str(Mean_20189)];
disp(Avg20189_DutyCycle)

%Average # of days with sperm whales 
%retime bin table for daily
columnIndices2Delete = [1 38 39 40 41 42 43];
All_20189_BinsINT = All_20189_Bins;
All_20189_BinsINT(:,columnIndices2Delete) = [];
All_20189_Days = retime(All_20189_BinsINT,'daily','sum');

%recalculate all columns
%All_2016_Days{:,2:end}(All_2016_Days{:,2:end} == 0) = NaN;
All_20189_Days.DutyAvg = mean(All_20189_Days{:,3:end},2); %average number of clicks in each bin
All_20189_Days.Diff = All_20189_Days.Count - All_20189_Days.DutyAvg; %average number of missed clicks in each bin
%what to multiply the duty cycled data by to supplement so it can look like the continuous data
All_20189_Days.Supp = All_20189_Days.Count./All_20189_Days.DutyAvg; 
%what does the duty cycle percent look like, compared to the actual duty cycle which was recording 43% of the time
All_20189_Days.DutyPercent = All_20189_Days.DutyAvg./All_20189_Days.Count; 
%Multiply the duty cycled average number of clicks in each bin by the
%'supplement' so you can see what number of clicks you'd have if you
%recorded continuously
All_20189_Days.Adj = All_20189_Days.DutyAvg .* All_20189_Days.Supp;
All_20189_Days.DiffAdj = All_20189_Days.Count - All_20189_Days.Adj; %sanity check, what's the difference between the 
%actual recorded number of clicks and the 'adjusted' number of clicks based
%on the supplemented duty cycled data

%Missed 5-Minute bins each day
figure
idx = All_20189_Days.Diff > 0;
hist(All_20189_Days.Diff(idx))
title('Histogram of Missed 5-Minute Bins each day in 2018/2019')
xlabel('# of Missed 5-Min Bins Each Day')
ylabel('Count')

%Average Duty cycle
Mean_20189 = nanmean(All_20189_Days.DutyPercent);
Avg20189_DutyCycle = ['The average duty cycle for 2018/2019 was ',num2str(Mean_20189)];
disp(Avg20189_DutyCycle)

