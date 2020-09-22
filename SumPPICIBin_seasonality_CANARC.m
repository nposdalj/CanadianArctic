clearvars
close all

%% Parameters defined by user
filePrefix = 'CANARC_PI'; % File name to match. 
siteabrev = 'CA'; %abbreviation of site.
sp = 'Pm'; % your species code
itnum = '2'; % which iteration you are looking for
srate = 200; % sample rate
tpwsPath = 'E:\Project_Sites\CANARC\TPWS_120to125'; %directory of TPWS files
effortXls = 'E:\Project_Sites\CANARC\Pm_Effort.xlsx'; % specify excel file with effort times
saveDir = 'E:\Seasonality\CANARC'; %specify directory to save files
manualDir = 'E:\Project_Sites\CANARC\guysbight_log.xls'; %location of manual logging for Guys Bight
PlotSiteName = 'Pond Inlet in the Canadian Arctic';

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
    binEffort = intervalToBinTimetabl(effort.Start,effort.End,p); % convert intervals in bins when there is multiple lines of effort
    %binEffort.sec = binEffort.bin*(p.binDur*60);
else
    binEffort = intervalToBinTimetable_Only1RowEffort(effort.Start,effort.End,p); % convert intervals in bins when there is only one line of effort
    %binEffort.sec = binEffort.bin*(p.binDur*60);
end
%% get average of detection by effort
NktTkt = positiveCounts/secMonitEffort;
NktTktbin = positiveBins/binMonitEffort;
%% save workspace to avoid running previous parts again
save([saveDir,'\',siteabrev,'_workspace130.mat']);
%% load workspace
load([saveDir,'\',siteabrev,'_workspace130.mat']);
%% group data by 5min bins, days, weeks, and seasons
%group data by 5 minute bins
binTable = synchronize(binData,binEffort);
binTable.Properties.VariableNames{'effortBin'} = 'Effort_Bin';
binTable.Properties.VariableNames{'effortSec'} = 'Effort_Sec';
binTable.maxPP = [];
binidx1 = (binTable.Count >= 1);
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
dayTable.Properties.VariableNames{'effortBin'} = 'Effort_Bin';
dayTable.Properties.VariableNames{'effortSec'} = 'Effort_Sec';
dayTableZeros = dayTable;
dayTable(~dayTable.Effort_Bin,:)=[]; %removes days with no effort, NOT days with no presence

%group data by week
weekData = retime(dayData,'weekly','mean');
weekEffort = retime(binEffort,'weekly','sum');
weekTable = retime(dayTable,'weekly','sum');
%weekTable(~weekTable.Effort_Bin,:)=[]; %removes days with no effort, NOT days with no presence

%group data by month
monthData = retime(dayData, 'monthly', 'mean');
monthEffort = retime(binEffort,'monthly','sum');
monthTable = retime(dayTable, 'monthly','sum');
monthTable(~monthTable.Effort_Bin,:)=[]; %removes days with no effort, NOT days with no presence
%% statistical methods from Diogou, et al. 2019 - by daily 5 min bins ** USE THIS **
[pp,~]=size(dayTable);
dayTable.MaxEffort_Bin = ones(pp,1)*(288); %total number of bins possible in one day
dayTable.MaxEffort_Sec = ones(pp,1)*(86400); %seconds in one day

%dealing with duty cycled data
if strcmp(siteabrev,'CB');
dayTable.Effort_Bin(222:507) = 127;%for CB02 ONLY - only .44 of each hour is recorded...
%so effort of 5 min bins for each day is 127 bins
    else 
if strcmp(siteabrev,'QC');
dayTable.Effort_Bin(1:289) = 36; %for QC06 ONLY - only 7.5 mins each hour is recorded...
%so effort of 5 min bins for each day is 36
    else
if strcmp(siteabrev,'ALEUT');
dayTable.Effort_Bin(274:end) = 96; %for ALEUT03BD ONLY - only 0.33 of each hour is recorded...
%so effort of 5 min bins for each day is 96
    else
if strcmp(siteabrev,'HOKE');
dayTable.Effort_Bin(:) = 36; %for HOKE ONLY - only 7.5 mins each hour is recorded...
%so effort of 5 min bins for each day is 36
    else
if strcmp(siteabrev,'CORC');
dayTable.Effort_Bin(:) = 96; %for CORC ONLY - only 0.33 of each hour is recorded...
%so effort of 5 min bins for each day is 96
    else
if strcmp(siteabrev,'CA');
    ge = dayTable.Effort_Bin(435:603); %bin effort (excluding ships but not considering duty cycle)
    geDiff = ge - 288;
    ge(ge >123) = 123;
    ge = ge + geDiff;
    dayTable.Effort_Bin(435:603) = ge; %for CANARC_PI_03 ONLY - only 25.7(or 25%) mins of each hour is recorded....
    %so effort of 5 bins for each day is
    secADJ = 123 * 60; %123 5-min bins a day converted into seconds
    else
dayTable.MaxEffort_Bin = ones(pp,1)*(288);
end
end
end
end
end
end

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

NANidx = ismissing(dayTable(:,{'NormBin'}));
dayTable{:,{'NormBin'}}(NANidx) = 0; %if there was effort, but no detections change the NormBin column to zero
dayBinTAB = timetable2table(dayTable);
writetable(dayBinTAB,[saveDir,'\',siteabrev,'_dayBinTAB130.csv']); %save table to .csv to continue stats in R F:\Seasonality\Kruskal_RankSumSTATS.R
weekBinTAB = timetable2table(weekTable);
weekBinTAB.week = week(weekBinTAB.tbin);
writetable(weekBinTAB,[saveDir,'\',siteabrev,'_weekBinTAB130.csv']);

KW_BINS = kruskalwallis(dayTable.NormBin,dayTable.Season); %Kruskalwallis test for bin presence based on season (bins)
KW_CLICKS = kruskalwallis(dayTable.NormClick, dayTable.Season); %Kruskalwallis test for bin presence based on season (clicks)
%% day table with days grouped together (summed and averaged) ** USE THIS **
dayTable.month = month(dayTable.tbin);
dayTable.day = day(dayTable.tbin,'dayofyear');
[MD,~] = findgroups(dayTable.day);
%dayTable.MD = MD; %adds a column that has the day of the year without months or years (i.e. January 1st = 1)
dayTable.day = categorical(dayTable.day);

if length(MD) < 365
    meantab365 = table(dayTable.day(:), dayTable.NormBin(:));
    meantab365.Properties.VariableNames = {'Day' 'Bin'};
    sumtab365 = meantab365;
else
%sum
sumarray = grpstats(dayTable.NormBin, dayTable.day, @sum); %takes the sum of each day of the year
sumtable = array2table(sumarray);
newcol = (1:length(sumarray))';
sumarray365 = [newcol sumarray];
sumtab365 = array2table(sumarray365);
sumtab365.Properties.VariableNames = {'Day' 'Bin'};

%mean
meanarray = grpstats(dayTable.NormBin, dayTable.day, @mean); %takes the mean of each day of the year
meantable = array2table(meanarray);
newcol_mean = (1:length(meanarray))';
meanarray365 = [newcol_mean meanarray];
meantab365 = array2table(meanarray365);
meantab365.Properties.VariableNames = {'Day' 'Bin'};
end

writetable(meantab365, [saveDir,'\',siteabrev,'_days365GroupedMean130.csv']); %table with the mean for each day of the year
writetable(sumtab365, [saveDir,'\',siteabrev,'_days365GroupedSum130.csv']); %table with the sum for each day of the year
%save table to .csv to continue stats in R F:\Seasonality\Kruskal_RankSumSTATS.R
%% day table with months grouped together (summed and averaged) ** USE THIS **
dayTable.month = month(dayTable.tbin);
[MO,~] = findgroups(dayTable.month);
dayTable.month = categorical(dayTable.month);
MOT = table(dayTable.NormBin,dayTable.month);

%mean
meantabMO = grpstats(MOT, 'Var2');
meantabMO.Properties.VariableNames = {'Month' 'Bin' 'Mean'};

writetable(meantabMO, [saveDir,'\',siteabrev,'_MOGroupedMean130.csv']); %table with the mean for each day of the year

%% Loading the manual data from Guys Bight

manDet = readtable(manualDir); %read manual detections as table
manDet.StartTime = datetime(manDet.StartTime,'ConvertFrom','excel'); %convert times to matlab time
manDet.EndTime = datetime(manDet.EndTime,'ConvertFrom','excel'); %convert times to matlab time
manDet.Parameter1 = manDet.StartTime - manDet.EndTime;
manDet.Parameter2 = manDet.Parameter1./5;
manDet(:,1:4) = [];
manDet(:,3:end) = [];
manDet.Diff = minutes(manDet.StartTime - manDet.EndTime);
manDet.Bins = abs(floor(manDet.Diff/5));

manDet2 = table2timetable(manDet);
manDet2.EndTime = [];
manDet2.Diff = [];
manDet2 = retime(manDet2,'weekly','sum');
manDet2.Properties.VariableNames = {'Count_Bin'};

weekTable2 = synchronize(manDet2,weekTable);

%%
weekTable.Percent = weekTable.Effort_Sec./604800
figure
yyaxis left
bar(weekTable.tbin,weekTable.Count_Bin,'k')
title('Average Weekly Presence of Sperm Whales at Pond Inlet in the Canadian Arctic')
ylabel('Average # of 5-Minute Bins')
hold on
bar(manDet2.StartTime,manDet2.Count_Bin,'k')
yyaxis right
plot(weekTable.tbin,weekTable.Percent,'.r')
ylabel('Percent Effort')
col = [0 0 0];
set(gcf,'defaultAxesColorOrder',[col;col])

%% Weekly group and click count with percent effort reported
weekTable.Percent = (weekTable.Effort_Sec./604800)*100;
figure(6); set(6, 'name','Weekly presence')
set(gca,'defaultAxesColorOrder',[0 0 0;0 0 0]);
subplot(2,1,1);
yyaxis left
bar(weekTable.tbin,weekTable.Count_Click,'k')
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