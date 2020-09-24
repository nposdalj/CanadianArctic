%% 
%This code was created to plot average click and bin counts of sperm whales
%in the Canadian Arctic over multiple years and deployments.
%09/08/2020
%NP and CAS

close all
clear all

%% Specity directories
Site1Dir = 'G:\Project Sites\CANARC\TPWS_120to125'; %TPWS directory for site 1
filePrefix = 'CANARC_PI'; %site name for plots
itnum = '2'; %which iteration of TPWS are you looking for
sp = 'Pm'; %species code
SaveDir = 'G:\Project Sites\CANARC\Plots'; %save plots
p = sp_setting_defaults('sp',sp,'analysis','SumPPICIBin'); 
%% define subfolder that fit specified iteration
%Site 1
if itnum > 1
   for id = 2:str2num(itnum) % iterate id times according to itnum
       subfolder = ['TPWS',num2str(id)];
       Site1Dir = (fullfile(Site1Dir,subfolder));
   end
end
%% Find all TPWS files that fit your specifications (does not look in subdirectories)
% Concatenate parts of file name
detfn = [sp,'.*TPWS',itnum,'.mat'];

% Get a list of all the files in the start directory
fileList1 = cellstr(ls(Site1Dir)); %Site 1

% Find the file name that matches the filePrefix *** Where I started
% adjusting the code (CAS)
fileMatchIdx1 = find(~cellfun(@isempty,regexp(fileList1,detfn))>0); %
if isempty(fileMatchIdx1) %
     % if no matches, throw error
    error('No files matching filePrefix found!')
end
%% Concatenate all detections from the same site
concatFiles1 = fileList1(fileMatchIdx1); %

%% Concatenate variables for site 1
PPall1 = []; TTall1 = []; ICIall1 = []; % initialize matrices
parfor idsk = 1 : length(concatFiles1)
    % Load file
    fprintf('Loading %d/%d file %s\n',idsk,length(concatFiles1),fullfile(Site1Dir,concatFiles1{idsk}))
    D = load(fullfile(Site1Dir,concatFiles1{idsk}));
    
    MTT = D.MTT;
    MPP = D.MPP;
    
    % concatenate
    TTall1 = [TTall1; MTT];   % group start times
    PPall1 = [PPall1; MPP];   % group peak-to-peak
    
    % Inter-Click Interval
    ici = diff(MTT)*24*60*60*1000; % in ms
    ICIall1 = [ICIall1;[ici; nan]];  % group inter-click interval
end



%% After parfor data may not be sorted. Sort all the variables. Site 1
[~,sorted] = sort(TTall1);
TTall1  = TTall1(sorted);
PPall1 = PPall1(sorted);
ICIall1 = ICIall1(sorted);


%% Create timetable per click for Site 1 
tbin1 = datetime(TTall1,'ConvertFrom','datenum');
clickData1 = timetable(tbin1,PPall1,ICIall1);
clear tbin1



%% Convert times to bin vector times for Site 1 (STARTED HERE 6/26)
vTT1 = datevec(TTall1);
tbin1 = datetime([vTT1(:,1:4), floor(vTT1(:,5)/p.binDur)*p.binDur, ...
    zeros(length(vTT1),1)]);



%% create table and get click counts and max pp per bin for Site 1
data1 = timetable(tbin1,TTall1,PPall1);
binData1 = varfun(@max,data1,'GroupingVariable','tbin1','InputVariable','PPall1');
binData1.Properties.VariableNames{'GroupCount'} = 'Count'; % #clicks per bin
binData1.Properties.VariableNames{'max_PPall1'} = 'maxPP1';
positiveCounts1 = sum(binData1.Count);
positiveBins1 = length(binData1.Count);

%% group data by 5min bins, days, weeks

%group data by day for site 1
Click1 = retime(binData1(:,1),'daily','sum'); % #click per day
Bin1 = retime(binData1(:,1),'daily','count'); % #bin per day
dayData1 = synchronize(Click1,Bin1);
dayData1.year = year(dayData1.tbin1);
dayData1.Day = day(dayData1.tbin1,'dayofyear');

%group data by week for site 1
weekData1 = retime(dayData1,'weekly','mean');
weekData1.Week = week(weekData1.tbin1);
weekData1.year = year(weekData1.tbin1);
weekTable1 = timetable2table(weekData1); 
weekTable1.tbin1 = [];
weekTable1(~weekTable1.Count_Bin1,:) = [];


%%
% Plotting

% Average weekly click count (log scale)
figure
bar1 = bar(weekData1.Week(weekData1.year==2019),weekData1.Count_Click1(weekData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(weekData1.Week(weekData1.year==2018),weekData1.Count_Click1(weekData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(weekData1.Week(weekData1.year==2017),weekData1.Count_Click1(weekData1.year==2017),'m') %year 2017
hold on
bar4 = bar(weekData1.Week(weekData1.year==2016),weekData1.Count_Click1(weekData1.year==2016),'y') %year 2016
legend
hold on
xlim([29 37])
set(gca,'YScale','log')
title('Average Weekly Click Counts in Pond Inlet 2016-2019')
ylabel('Average Weekly Click Count (log scale)')
xlabel('Week #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageWeeklyClick_OverlapPlot_logscale'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off


% Average weekly Bin count (log scale)
figure
bar1 = bar(weekData1.Week(weekData1.year==2019),weekData1.Count_Bin1(weekData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(weekData1.Week(weekData1.year==2018),weekData1.Count_Bin1(weekData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(weekData1.Week(weekData1.year==2017),weekData1.Count_Bin1(weekData1.year==2017),'m') %year 2017
hold on
bar4 = bar(weekData1.Week(weekData1.year==2016),weekData1.Count_Bin1(weekData1.year==2016),'y') %year 2016
legend
hold on
xlim([29 37])
set(gca,'YScale','log')
title('Average Weekly Bin Counts in Pond Inlet 2016-2019')
ylabel('Average Weekly Bin Count (log scale)')
xlabel('Week #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageWeeklyBin_OverlapPlot_logscale'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off

% Average daily bin count (log scale)
figure
bar1 = bar(dayData1.Day(dayData1.year==2019),dayData1.Count_Bin1(dayData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(dayData1.Day(dayData1.year==2018),dayData1.Count_Bin1(dayData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(dayData1.Day(dayData1.year==2017),dayData1.Count_Bin1(dayData1.year==2017),'m') %year 2017
hold on
bar4 = bar(dayData1.Day(dayData1.year==2016),dayData1.Count_Bin1(dayData1.year==2016),'y') %year 2016
hold on
xlim([190 300])
set(gca,'YScale','log')
title('Average Daily Bin Counts in Pond Inlet 2016-2019')
ylabel('Average Daily Bin Count (log scale)')
xlabel('Day #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageDailyBin_OverlapPlot_logscale'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off

% Average daily click count (log scale)
figure
bar1 = bar(dayData1.Day(dayData1.year==2019),dayData1.Count_Click1(dayData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(dayData1.Day(dayData1.year==2018),dayData1.Count_Click1(dayData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(dayData1.Day(dayData1.year==2017),dayData1.Count_Click1(dayData1.year==2017),'m') %year 2017
hold on
bar4 = bar(dayData1.Day(dayData1.year==2016),dayData1.Count_Click1(dayData1.year==2016),'y') %year 2016
hold on
xlim([190 300])
set(gca,'YScale','log')
title('Average Daily Click Counts in Pond Inlet 2016-2019')
ylabel('Average Daily Click Count (log scale)')
xlabel('Day #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageDailyClick_OverlapPlot_logscale'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off


% Average weekly click count 
figure
bar1 = bar(weekData1.Week(weekData1.year==2019),weekData1.Count_Click1(weekData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(weekData1.Week(weekData1.year==2018),weekData1.Count_Click1(weekData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(weekData1.Week(weekData1.year==2017),weekData1.Count_Click1(weekData1.year==2017),'m') %year 2017
hold on
bar4 = bar(weekData1.Week(weekData1.year==2016),weekData1.Count_Click1(weekData1.year==2016),'y') %year 2016
legend
hold on
xlim([29 37])
title('Average Weekly Click Counts in Pond Inlet 2016-2019')
ylabel('Average Weekly Click Count')
xlabel('Week #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageWeeklyClick_OverlapPlot'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off


% Average weekly Bin count
figure
bar1 = bar(weekData1.Week(weekData1.year==2019),weekData1.Count_Bin1(weekData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(weekData1.Week(weekData1.year==2018),weekData1.Count_Bin1(weekData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(weekData1.Week(weekData1.year==2017),weekData1.Count_Bin1(weekData1.year==2017),'m') %year 2017
hold on
bar4 = bar(weekData1.Week(weekData1.year==2016),weekData1.Count_Bin1(weekData1.year==2016),'y') %year 2016
legend
hold on
xlim([29 37])
title('Average Weekly Bin Counts in Pond Inlet 2016-2019')
ylabel('Average Weekly Bin Count')
xlabel('Week #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageWeeklyBin_OverlapPlot'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off

% Average daily bin count 
figure
bar1 = bar(dayData1.Day(dayData1.year==2019),dayData1.Count_Bin1(dayData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(dayData1.Day(dayData1.year==2018),dayData1.Count_Bin1(dayData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(dayData1.Day(dayData1.year==2017),dayData1.Count_Bin1(dayData1.year==2017),'m') %year 2017
hold on
bar4 = bar(dayData1.Day(dayData1.year==2016),dayData1.Count_Bin1(dayData1.year==2016),'y') %year 2016
hold on
xlim([190 300])
set(gca,'YScale','log')
title('Average Daily Bin Counts in Pond Inlet 2016-2019')
ylabel('Average Daily Bin Count')
xlabel('Day #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageDailyBin_OverlapPlot'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off

% Average daily click count 
figure
bar1 = bar(dayData1.Day(dayData1.year==2019),dayData1.Count_Click1(dayData1.year==2019),'c')  %year 2019
hold on
bar2 = bar(dayData1.Day(dayData1.year==2018),dayData1.Count_Click1(dayData1.year==2018),'b')  %year 2018
hold on
bar3 = bar(dayData1.Day(dayData1.year==2017),dayData1.Count_Click1(dayData1.year==2017),'m') %year 2017
hold on
bar4 = bar(dayData1.Day(dayData1.year==2016),dayData1.Count_Click1(dayData1.year==2016),'y') %year 2016
hold on
xlim([190 300])
title('Average Daily Click Counts in Pond Inlet 2016-2019')
ylabel('Average Daily Click Count')
xlabel('Day #')
plots = get(gca, 'Children');
legend(plots([1, 2, 3, 4]), {'Year 2016', 'Year 2017', 'Year 2018', 'Year 2019'});
% Save plot
weeklyfn = [filePrefix,'_',p.speName,'_averageDailyClick_OverlapPlot'];
saveas(gcf,fullfile(SaveDir,weeklyfn),'png')
saveas(gcf,fullfile(SaveDir,weeklyfn),'fig')
hold off
