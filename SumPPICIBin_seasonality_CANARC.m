clearvars
close all

%% Parameters defined by user
filePrefix = 'CANARC_PI'; % File name to match
siteabrev = 'CANARC'; %abbreviation of site.
sp = 'Pm'; % your species code
itnum = '2'; % which iteration you are looking for
srate = 200; % sample rate
tpwsPath = 'E:\Project_Sites\CANARC\TPWS_120to125'; %directory of TPWS files
effortXls = 'E:\Project_Sites\CANARC\Pm_Effort.xlsx'; % specify excel file with effort times
saveDir = 'E:\Project_Sites\CANARC'; %specify directory to save files
manualDir = 'E:\Project_Sites\CANARC\guysbight_log2.xls'; %location of manual logging for Guys Bight
manualEffort = 'E:\Project_Sites\CANARC\GuysBight_Effort.xlsx'; %location of Guys Bight effort
PlotSiteName = 'Pond Inlet in the Canadian Arctic';
IceData = 'C:\Users\nposd\Documents\GitHub\CanadianArctic\SeaIceData_BaffinBay.csv'
%% define subfolder that fit specified iteration
if itnum > 1
   for id = 2: str2num(itnum) % iterate id times according to itnum
       subfolder = ['TPWS',num2str(id)];
       tpwsPath = (fullfile(tpwsPath,subfolder));
   end
end
%% Find all TPWS files that fit your specifications (does not look in subdirectories)
% Concatenate parts of file name
if isempty(sp)
    detfn = [filePrefix,'.*','TPWS',itnum,'.mat'];
else
    detfn = [filePrefix,'.*',sp,'.*TPWS',itnum,'.mat'];
end

% Get a list of all the files in the start directory
fileList = cellstr(ls(tpwsPath));

% Find the file name that matches the filePrefix
fileMatchIdx = find(~cellfun(@isempty,regexp(fileList,detfn))>0);
if isempty(fileMatchIdx)
    % if no matches, throw error
    error('No files matching filePrefix found!')
end
%% Get effort times matching prefix file
%when multiple sites in the effort table
allEfforts = readtable(effortXls); %read effort table
site = siteabrev; %abbreviation used in effort table

siteNUM = unique(allEfforts.Sites);
[sr,~] = size(siteNUM);

if sr > 1
    effTable = allEfforts(ismember(allEfforts.Sites,site),:); %effort is for multiple sites
else
    effTable = allEfforts; %effort is for one site only
end

% make Variable Names consistent
startVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'Start.*Effort'))>0,1,'first');
endVar = find(~cellfun(@isempty,regexp(effTable.Properties.VariableNames,'End.*Effort'))>0,1,'first');
effTable.Properties.VariableNames{startVar} = 'Start';
effTable.Properties.VariableNames{endVar} = 'End';

Start = datetime(x2mdate(effTable.Start),'ConvertFrom','datenum');
End = datetime(x2mdate(effTable.End),'ConvertFrom','datenum');

effort = timetable(Start,End);
%% Concatenate all detections from the same site
concatFiles = fileList(fileMatchIdx);
%% get default parameters
p = sp_setting_defaults('sp',sp,'analysis','SumPPICIBin');
%% Concatenate variables
PPall = []; TTall = []; ICIall = []; % initialize matrices
parfor idsk = 1 : length(concatFiles)
    % Load file
    fprintf('Loading %d/%d file %s\n',idsk,length(concatFiles),fullfile(tpwsPath,concatFiles{idsk}))
    D = load(fullfile(tpwsPath,concatFiles{idsk}));
    
    % find times outside effort (sometimes there are detections
    % which are from the audio test at the beggining of the wav file)
    within = cell2mat(arrayfun(@(x)sum(isbetween(x,datenum(effort.Start),datenum(effort.End))),D.MTT,'uni',false)); %#ok<PFBNS>
    goodIdx = find(within ~= 0);
    MTT = D.MTT(goodIdx); % only keep the good detections
    MPP = D.MPP(goodIdx);
    
    % concatenate
    TTall = [TTall; MTT];   % group start times
    PPall = [PPall; MPP];   % group peak-to-peak
    
    % Inter-Click Interval
    ici = diff(MTT)*24*60*60*1000; % in ms
    ICIall = [ICIall;[ici; nan]];  % group inter-click interval
end
%% After parfor data may not be sorted. Sort all the variables.
[~,sorted] = sort(TTall);
TTall = TTall(sorted);
PPall = PPall(sorted);
ICIall = ICIall(sorted);
%% Create timetable per click
tbin = datetime(TTall,'ConvertFrom','datenum');
clickData = timetable(tbin,PPall,ICIall);
clear tbin
%% Convert times to bin vector times
vTT = datevec(TTall);
tbin = datetime([vTT(:,1:4), floor(vTT(:,5)/p.binDur)*p.binDur, ...
    zeros(length(vTT),1)]);
%% create table and get click counts and max pp per bin
data = timetable(tbin,TTall,PPall);
binData = varfun(@max,data,'GroupingVariable','tbin','InputVariable','PPall');
binData.Properties.VariableNames{'GroupCount'} = 'Count'; % #clicks per bin
binData.Properties.VariableNames{'max_PPall'} = 'maxPP';

positiveCounts = sum(binData.Count);
positiveBins = length(binData.Count);
%% group effort in bins
effort.diffSec = seconds(effort.End-effort.Start);
effort.bins = effort.diffSec/(60*p.binDur);
effort.roundbin = round(effort.diffSec/(60*p.binDur));

secMonitEffort = sum(effort.diffSec);
binMonitEffort = sum(effort.roundbin);

[er,~] = size(effort.Start);

if er > 1
    binEffort = intervalToBinTimetable(effort.Start,effort.End,p); % convert intervals in bins when there is multiple lines of effort
    binEffort.sec = binEffort.bin*(p.binDur*60);
else
    binEffort = intervalToBinTimetable_Only1RowEffort(effort.Start,effort.End,p); % convert intervals in bins when there is only one line of effort
    binEffort.sec = binEffort.bin*(p.binDur*60);
end
%% get average of detection by effort
NktTkt = positiveCounts/secMonitEffort;
NktTktbin = positiveBins/binMonitEffort;
%% save workspace to avoid running previous parts again
save([saveDir,'\',siteabrev,'_workspace125.mat']);
%% load workspace
load([saveDir,'\',siteabrev,'_workspace125.mat']);
%% group data by 5min bins, days, weeks, and seasons
%group data by 5 minute bins
binidx = (binData.Count >=5); %removes bins with less than 5 clicks
binData.Count(binidx == 0) = NaN;
binTable = synchronize(binData,binEffort);
binTable.Properties.VariableNames{'bin'} = 'Effort_Bin';
binTable.Properties.VariableNames{'sec'} = 'Effort_Sec';
binTable.maxPP = [];
binidx1 = (binTable.Count >= 5);
[y,~]=size(binTable);
binTable.PreAbs = zeros(y,1);
binTable.PreAbs(binidx1) = 1; %table with 0 for no presence in 5min bin and 1 with presence in 5min bin
%no effort bins are excluded 

Click = retime(binData(:,1),'daily','sum'); % #click per day
Bin = retime(binData(:,1),'daily','count'); % #bin per day

%group data by day
dayData = synchronize(Click,Bin);
dayEffort = retime(binEffort,'daily','sum');
dayTab = synchronize(dayData,dayEffort);
dayTable = synchronize(dayData,dayEffort);
dayTable.Properties.VariableNames{'bin'} = 'Effort_Bin';
dayTable.Properties.VariableNames{'sec'} = 'Effort_Sec';
dayTableZeros = dayTable;
dayTable(~dayTable.Effort_Bin,:)=[]; %removes days with no effort, NOT days with no presence
%% statistical methods from Diogou, et al. 2019 - by daily 5 min bins ** USE THIS **
[pp,~]=size(dayTable);
dayTable.MaxEffort_Bin = ones(pp,1)*(288); %total number of bins possible in one day
dayTable.MaxEffort_Sec = ones(pp,1)*(86400); %seconds in one day

%dealing with duty cycled data; supplementing the data
if strcmp(siteabrev,'CANARC');
     ge = dayTable.Effort_Bin(435:603); %bin effort (excluding ships but not considering duty cycle)
     ge = ge/288; %proportion of data that was not 'ships' considering full recording effort
     dayTable.Effort_Bin(435:603) = ge * 123.264; 
     
%      geDiff = ge - 288; %find how many bins were excluded because of ships
%      geDuty = 123.264 + geDiff; %subtract the bins excluded from ships, from 123 (max effort of bins with the duty cycle)
%      geDuty = max(geDuty,0); %make any negative values zero
%      dayTable.Effort_Bin(435:603) = geDuty; %for CANARC_PI_03 ONLY - only 25.7(or 25%) mins of each hour is recorded....
     dayTable.MaxEffort_Bin(435:603) = 123.264;
     dayTable.MaxEffort_Sec(435:603) = 123.264 * 5 * 60;
     dayTable.Effort_Sec(435:603) = dayTable.Effort_Bin(435:603) * 5 * 60;
     %dayTable.Count_Bin(435:603) = floor(dayTable.Count_Bin(435:603)*2.3784); %adjusted the bin count to match the duty cycle
else
    dayTable.MaxEffort_Bin = ones(pp,1)*(288);
end

%Calcuates proportion of recording hours with clicks
dayTable.Minutes = dayTable.Count_Bin * 5; %convert bins to minutes
dayTable.Hours = (dayTable.Count_Bin * 5) ./ 60; %convert the number of bins sperm whales were detected in to hours per day
dayTable.HoursProp = dayTable.Hours./(dayTable.Effort_Sec ./ (60 * 60)); %proportion of hours per day w/clicks

dayTable.NormEffort_Bin = dayTable.Effort_Bin./dayTable.MaxEffort_Bin; %what proportion of the day was there effort
dayTable.NormEffort_Sec = dayTable.Effort_Sec./dayTable.MaxEffort_Sec; %what proportion of the day was there effort
dayTable.NormBin = dayTable.Count_Bin ./ dayTable.NormEffort_Bin; %what would the normalized bin count be given the amount of effort
dayTable.NormClick = dayTable.Count_Click ./ dayTable.NormEffort_Sec; %what would be the normalized click count given the amount of effort

dayTable.Season = zeros(pp,1);
dayTable.month = month(dayTable.tbin);
summeridxD = (dayTable.month == 6  | dayTable.month == 7 | dayTable.month == 8);
fallidxD = (dayTable.month == 9  | dayTable.month == 10 | dayTable.month == 11);
winteridxD = (dayTable.month == 12  | dayTable.month == 1 | dayTable.month == 2);
springidxD = (dayTable.month == 3  | dayTable.month == 4 | dayTable.month == 5);

%adds the season according to the month the data was collected
dayTable.Season(summeridxD) = 1;
dayTable.Season(fallidxD) = 2;
dayTable.Season(winteridxD) = 3;
dayTable.Season(springidxD) = 4;

%add year and day to data
dayTable.Year = year(dayTable.tbin); 
dayTable.day = day(dayTable.tbin,'dayofyear');

NANidx = ismissing(dayTable(:,{'NormBin'}));
dayTable{:,{'NormBin'}}(NANidx) = 0; %if there was effort, but no detections change the NormBin column to zero
dayBinTAB = timetable2table(dayTable);
writetable(dayBinTAB,[saveDir,'\',siteabrev,'_dayBinTAB125.csv']); %save table to .csv to continue stats in R F:\Seasonality\Kruskal_RankSumSTATS.R
%% Loading the manual data from Guys Bight
manDet = readtable(manualDir); %read manual detections as table

%dealing with effort for manual data
manEff = readtable(manualEffort); %read Guys Bight effort as table
manEff.Properties.VariableNames = {'Sites','Deployments','Start','End'};
Start_man = datetime(manEff.Start,'ConvertFrom','datenum');
End_man = datetime(manEff.End,'ConvertFrom','datenum');
effort_man = timetable(Start_man,End_man);
%group effort in bins
effort_man.diffSec = seconds(effort_man.End_man-effort_man.Start_man);
effort_man.bins = effort_man.diffSec/(60*p.binDur);
effort_man.roundbin = round(effort_man.diffSec/(60*p.binDur));
secMonitEffort = sum(effort_man.diffSec);
binMonitEffort = sum(effort_man.roundbin);
binEffort_man = intervalToBinTimetable_Only1RowEffort(effort_man.Start_man,effort_man.End_man,p); % convert intervals in bins when there is only one line of effort
binEffort_man.sec = binEffort_man.bin*(p.binDur*60);
binEffort_day = retime(binEffort_man,'daily','sum');

%Calculating Recording Effort for Guys Bight
%recorded for 5 minutes, off for 60 minutes
dailyPercentage_recording = 5/60;
minsPERday = 24 * 60 * dailyPercentage_recording; %minutes per day with recording effort
secPERday = minsPERday * 60; %seconds per day with recording effort
binsPERday = minsPERday/5; %number of 5 min bins per day

%Since the data is duty cycled 5/60, I'm going to adjust the effort for bin
%and sec per day
binEffort_day.bin = binEffort_day.bin*dailyPercentage_recording;
binEffort_day.sec = binEffort_day.sec*dailyPercentage_recording;

manDet.StartTime = datetime(manDet.StartTime,'ConvertFrom','excel'); %convert times to matlab time
manDet.EndTime = datetime(manDet.EndTime,'ConvertFrom','excel'); %convert times to matlab time
manDet.Parameter1 = manDet.StartTime - manDet.EndTime;
manDet.Parameter2 = manDet.Parameter1./5;
manDet(:,1:4) = [];
manDet(:,3:end) = [];
manDet.Diff = minutes(manDet.StartTime - manDet.EndTime);
manDet.Bins = abs(floor(manDet.Diff/5));
manDet.Properties.VariableNames = {'tbin', 'EndTime', 'Diff', 'Count_Bin'};
manDet.EndTime = [];
manDet.Diff = [];
manDet = retime(table2timetable(manDet),'daily','sum');

manDet = synchronize(manDet,binEffort_day); %group manual detections and effort
manDet.Properties.VariableNames = {'Count_Bin','Effort_Bin','Effort_Sec'};
manDet.Minutes = manDet.Count_Bin * 5; %convert bins to minutes
manDet.Hours = (manDet.Count_Bin * 5) ./ 60; %convert the number of bins sperm whales were detected in to hours per day
manDet.HoursProp = manDet.Hours./(manDet.Effort_Sec ./ (60 * 60)); %proportion of hours per day w/clicks
manDet.month = month(manDet.tbin);
manDet.Year = year(manDet.tbin);
manDet.day = day(manDet.tbin,'dayofyear');

columns2delete = [1 5 6 10 11 12 13 14];
dayTable(:,columns2delete) = [];
dayTable2 = [manDet; dayTable];

%summarize data weekly
weekTable = retime(dayTable2,'weekly','mean');
weekTable2 = retime(dayTable2,'weekly','sum');

%summmarize data monthly
monthTable = retime(dayTable2,'monthly','mean');
monthTable2 = retime(dayTable2,'monthly','sum');
monthTable.Year = year(monthTable.tbin);
monthTable.month = month(monthTable.tbin);
%% Daily Table
dayTable2.Percent = dayTable2.Effort_Sec./86400;
figure
yyaxis left
bar(dayTable2.tbin,dayTable2.HoursProp,'k')
title('Proportion of Hours Per Day with Sperm Whales at Pond Inlet in the Canadian Arctic')
ylabel('Propertion of Hours/Day')
yyaxis right
plot(dayTable2.tbin, dayTable2.Percent, '.r')
ylabel('Percent Effort')
ylim([-0.01 1.01])
col = [0 0 0];
set(gcf,'defaultAxesColorOrder',[col;col])
%% Weekly Table
weekTable.Percent = weekTable2.Effort_Sec./604800
figure
yyaxis left
bar(weekTable.tbin,weekTable.HoursProp,'k')
title('Average Proportion of Hours Per Week with Sperm Whales at Pond Inlet in the Canadian Arctic')
ylabel('Proportion of Hours/Week')
yyaxis right
plot(weekTable.tbin,weekTable.Percent,'.r')
ylabel('Percent Effort')
ylim([-0.01 1.01])
col = [0 0 0];
set(gcf,'defaultAxesColorOrder',[col;col])
%% loading Ice data
Ice = readtable(IceData);
Ice.Year = floor(Ice.Date/100);
Ice.month = floor(Ice.Date-Ice.Year*100);
monthTable_Ice = join(monthTable, Ice);
%% Monthly Plot - 2 axis
monthTable.Percent = monthTable2.Effort_Sec./2628288;
monthTable.Percent(isnan(monthTable.Percent))=0;
monthTable.EffortPlot = 1-monthTable.Percent;
maxx = max(monthTable_Ice.Value);
Index_effort = monthTable.Percent >= 1;
monthTable.Percent(Index_effort) = 1;
% figure(5); set(5,'name','Monthly presence','DefaultAxesColor',[.8 .8 .8]) 
% set(gca,'defaultAxesColorOrder',[0 0 0; 0 0 0]);
figure
% yyaxis left
bar(monthTable.tbin,monthTable.HoursProp,'k')
addaxis(monthTable_Ice.tbin,monthTable_Ice.Value,[0 1.2])
addaxis(monthTable.tbin,monthTable.Percent,[-0.01 1.01],'.r');
addaxislabel(1,'Average Proportion of Hours/Week')
addaxislabel(2,'Sea Ice Extent (million square km)')
addaxislabel(3,'Percent Effort')
xlim([min(monthTable.tbin) max(monthTable.tbin)])
title({'Average Proportion of Hours Per Month with Sperm Whales','at Pond Inlet in the Canadian Arctic'})
col = [0 0 0];
set(gcf,'defaultAxesColorOrder',[col;col])
monthly_Ice = [filePrefix,'_',p.speName,'monthlyPresence_seaIceExtent'];
saveas(gcf,fullfile(saveDir,monthly_Ice),'png')
 %% Monthly Plotlyyy with 3 y-axis
% monthTable_Ice.Percent = monthTable.Percent;
% figure
% ylabels{1} = 'Average Proportion of Hours';
% ylabels{2} = 'Percent Effort';
% ylabels{3} = 'Sea Ice Extent';
% [ax,hlines] = plotyyy(monthTable_Ice.tbin,monthTable_Ice.HoursProp,monthTable_Ice.tbin,monthTable_Ice.Percent,monthTable_Ice.tbin,monthTable_Ice.Value)
% legend(hlines,'y = Average Proportion of Hours','y = Percent Effort','y = Sea Ice Extent')
%% Weekly group and click count with percent effort reported
weekTable.Percent = (weekTable.Effort_Sec./604800)*100;
figure(6); set(6, 'name','Weekly presence')
set(gca,'defaultAxesColorOrder',[0 0 0;0 0 0]);
subplot(2,1,1);
yyaxis left
bar(weekTable.tbin,weekTable.HoursProp,'k')
xlim([weekTable.tbin(1) weekTable.tbin(end)])
title({'Average Weekly Presence of Sperm Whales', ['at ' PlotSiteName]})
ylabel({'Weekly Mean'; 'of clicks per day'});
hold on
yyaxis right
plot(weekTable.tbin,weekTable.Percent,'.r')
ylim([-1 101]);
ylabel('Percent Effort')
if length(weekTable.tbin) > 53 && length(weekTable.tbin) <= 104 % 2 years
    step = calmonths(1);
elseif length(weekTable.tbin) > 104 && length(weekTable.tbin) <= 209 % 4 years
    step = calmonths(2);
elseif length(weekTable.tbin) > 209 && length(weekTable.tbin) <= 313 % 6 years
    step = calmonths(3);
elseif length(weekTable.tbin) > 313 && length(weekTable.tbin) <= 417 % 8 years
    step = calmonths(4);
elseif length(weekTable.tbin) >= 417 % more than 8 years
    step = calyears(1);
end
% define tick steps only if more than 1 year of data
% if length(weekTable.tbin) > 53
%     xtickformat('MMMyy')
%     xticks(weekTable.tbin(1):step:weekTable.tbin(end))
%     xtickangle(45)
% end
hold off

subplot(2,1,2);
yyaxis left
bar(weekTable.tbin,weekTable.Count_Bin,'k')
hold on
bar(manDet2.StartTime,manDet2.Count_Bin,'k')
x1 = datetime(2015,07,01);
xlim([x1 weekTable.tbin(end)])
ylabel({'Weekly Mean'; 'of 5-min bins per day'});
hold on
yyaxis right
plot(weekTable.tbin,weekTable.Percent,'.r')
ylim([-1 101]);
ylabel('Percent Effort')
col = [0 0 0];
set(gcf,'defaultAxesColorOrder',[col;col]);

if length(weekTable.tbin) > 53 && length(weekTable.tbin) <= 104 % 2 years
    step = calmonths(1);
elseif length(weekTable.tbin) > 104 && length(weekTable.tbin) <= 209 % 4 years
    step = calmonths(2);
elseif length(weekTable.tbin) > 209 && length(weekTable.tbin) <= 313 % 6 years
    step = calmonths(3);
elseif length(weekTable.tbin) > 313 && length(weekTable.tbin) <= 417 % 8 years
    step = calmonths(4);
elseif length(weekTable.tbin) >= 417 % more than 8 years
    step = calyears(1);
end
% define tick steps only if more than 1 year of data
% if length(weekTable.tbin) > 53
%     xtickformat('MMMyy')
%     xticks(weekTable.tbin(1):step:weekTable.tbin(end))
%     xtickangle(45)
% end
hold off
 
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_weeklypresence_withPercentEffort'];
saveas(gcf,fullfile(saveDir,weeklyfn),'png')