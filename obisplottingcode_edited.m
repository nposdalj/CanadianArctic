%% Adding HMAP data
HMAP = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\Full_Dataset4.csv');
IDX = find(contains(HMAP.Dataset4_SPECIES,'Sperm'));
HMAP2 = HMAP(IDX,{'LAT','LON','GROUND','EN_YEAR'});

%site of interest only
pat = {'Davis','Greenland','Touqussaq'};
IDX2 = find(contains(HMAP2.GROUND,pat));
HMAP3 = HMAP2(IDX2,:);
%within lat and long
idxlat = find(HMAP3.LAT >= 59.62); 
HMAP4 = HMAP3(idxlat,:);
idxlon = find(HMAP3.LON <= -45);
HMAP5 = HMAP4(idxlon,:);
HMAP6 = unique(HMAP5);
%% Adding OBIS data
OBIS = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\OBIS.csv');
IDX3 = find(contains(OBIS.institutionCode,'HMAP'));
OBIS2 = OBIS;
OBIS2(IDX3,:) = [];

%within lat and long
idxlat = find(OBIS2.decimalLatitude >= 59.62); 
OBIS3 = OBIS2(idxlat,:);
idxlon = find(OBIS3.decimalLongitude <= -45);
OBIS4 = OBIS3(idxlon,:);
OBIS4.institutionCode{3} = 'CWS';
OBIS4.institutionCode{4} = 'CWS';
OBIS4.institutionCode{13} = 'CWS';
OBIS4.institutionCode{26} = 'CWS';
OBIS4.institutionCode{30} = 'CWS';
OBIS4.institutionCode{54} = 'CWS';

%Fill in missing years
OBIS4.year{53} = '2017';
OBIS4.year{54} = '1972';
OBIS4.year{17} = '2018';
OBIS4.year{22} = '2012';
OBIS4.year{24} = '2018';
OBIS4.year{26} = '1975';
OBIS4.year{30} = '1975';
%% Adding Froun-Mouy and iNaturalist data
FrouinMouy = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\FrouinMouy.csv');
FrouinMouy.Var1 = -(FrouinMouy.Var1);

iNat = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\iNat.csv');
iNat.Var1 = -(iNat.Var1);
%% Adding WSDB Data
WSDB = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\WSDB_SpermWhale_May2021.xlsx');
%% Adding CWS data
CWS = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\q SPWH sightings.xlsx');
idxlat = find(CWS.Lat >= 59.62);
CWS2 = CWS(idxlat,:);
idxlon = find(CWS2.Long <= -45);
CWS3 = CWS2(idxlon,:);
%% HARP information
%HARP Lat and Long
LatHARP = 72.72;
LongHARP = -76.23;
%% Dataset 280 effort
Dataset280 = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\obis_seamap_dataset_280_points.csv');
idxlat = find(Dataset280.latitude >= 59.62);
Dataset280_2 = Dataset280(idxlat,:);
idxlon = find(Dataset280_2.longitude <= -45);
Dataset280_3 = Dataset280_2(idxlon,:);
effort_280 = boundary(Dataset280_3.latitude,Dataset280_3.longitude);

Dataset280 = readtable('I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\q survey effort_2.xlsx');
idxlat = find(Dataset280.LatStart >= 59.62);
Dataset280_2 = Dataset280(idxlat,:);
idxlon = find(Dataset280_2.LongStart <= -45);
Dataset280_3 = Dataset280_2(idxlon,:);
effort_280 = boundary(Dataset280_3.LatStart,Dataset280_3.LongStart);

%% Reeves 1985 Stranding data
% Reeves = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\Reeves1985.xlsx');
%% Plotting with colors representing data sets, same size markers for everything
%Plotting
%Canadian Wildlife service dataset
%below is the color of your markers, edit if needed
J = [0.4 0.4 0.4]; %dark grey
I = [0 0 1]; %lighter blue
G = [0.4940, 0.1840, 0.5560]; %purple
H = [0.6 0 0.6]; %pink;
F = [0 0 0]; %black
E = [0.75, 0.75, 0]; %mustard yellow
D = [0 0.5 0]; %green
C = [1 0.5 0]; %yellow
B = [0.5 0 0]; %maroon
A = [0 0 0.25]; %navy blue
%size of markers 
markSize = 220;

figure
s = geoscatter(HMAP6.LAT,HMAP6.LON,markSize,'.','MarkerEdgeColor',B);
row = dataTipTextRow('Grounds',HMAP6.GROUND);
s.DataTipTemplate.DataTipRows(end+1) = row;
hold on

r = geoscatter(WSDB.LATITUDE, WSDB.LONGITUDE,markSize,'.','MarkerEdgeColor',E);

r = geoscatter(CWS3.Lat, CWS3.Long,markSize,'.','MarkerEdgeColor',C);

gg = geoplot(Dataset280_3.LatStart(effort_280),Dataset280_3.LongStart(effort_280),'Color',[1 0.5 0]);
gg.Annotation.LegendInformation.IconDisplayStyle = 'off';

r = geoscatter(OBIS4.decimalLatitude(string(OBIS4.institutionCode) == 'Happywhale.com'),OBIS4.decimalLongitude(string(OBIS4.institutionCode) == 'Happywhale.com'),markSize,'.','MarkerEdgeColor',D);
row = dataTipTextRow('Source',OBIS2.institutionCode(string(OBIS4.institutionCode) == 'Happywhale.com'));
r.DataTipTemplate.DataTipRows(end+1) = row;

r = geoscatter(OBIS4.decimalLatitude(string(OBIS4.institutionCode) == 'IMR'),OBIS4.decimalLongitude(string(OBIS4.institutionCode) == 'IMR'),markSize,'.','MarkerEdgeColor',A);
row = dataTipTextRow('Source',OBIS2.institutionCode(string(OBIS4.institutionCode) == 'IMR'));
r.DataTipTemplate.DataTipRows(end+1) = row;

r = geoscatter(OBIS4.decimalLatitude(string(OBIS4.institutionCode) == 'Northwest Atlantic Fisheries Organization (NAFO)'),OBIS4.decimalLongitude(string(OBIS4.institutionCode) == 'Northwest Atlantic Fisheries Organization (NAFO)'),markSize,'.','MarkerEdgeColor',G);
row = dataTipTextRow('Source',OBIS2.institutionCode(string(OBIS4.institutionCode) == 'Northwest Atlantic Fisheries Organization (NAFO)'));
r.DataTipTemplate.DataTipRows(end+1) = row;


geoscatter(FrouinMouy.Var2,FrouinMouy.Var1,markSize,'.','MarkerEdgeColor',H);
geoscatter(iNat.Var2,iNat.Var1,markSize,'.','MarkerEdgeColor',I);
% geoscatter(Reeves.Latitude,Reeves.Longitude,markSize,'.','MarkerEdgeColor',J);
geoscatter(LatHARP,LongHARP,markSize,'.','MarkerEdgeColor',F);
geobasemap landcover

[~,objh] = legend('HMAP','WSDB','PIROP','Happywhale','IMR','NAFO','Frouin-Mouy','Jones, 2018','Recording Site');
objh1 = findobj(objh,'type','patch');
set(objh1,'MarkerSize',30);
hold off
%exportgraphics(gcf,'I:\.shortcut-targets-by-id\1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS\Arctic_Sperm whales\figures\OBIS_HighQuality.pdf','ContentType','vector','Resolution',300);

%% Write tables for continuation in R
% writetable(HMAP5,'I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\HMAP_R.csv');
% writetable(OBIS4,'I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\OBIS_R.csv');
% writetable(iNat,'I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\iNat_R.csv');
% writetable(FrouinMouy,'I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\FrouinMouy_R.csv');
% writetable(Dataset280_3,'I:\My Drive\Manuscripts\CANARC\data\Extracted_Visuals\VisualData_fromGitHub\Dataset280_R.csv');
%% Create one table with date, lat, long, institution/citation
%HMAP
Master = HMAP6(:,{'LAT','LON','EN_YEAR'});
Master.Properties.VariableNames = {'Latitude','Longitude','Year'};
Master.Source = repmat("HMAP", size(Master.Latitude));
%OBIS
OBISM = OBIS4(:,{'decimalLatitude','decimalLongitude','year','institutionCode'});
OBISM.Properties.VariableNames = {'Latitude','Longitude','Year','Source'};
OBISM.Year = str2double(OBISM.Year);
%FrouinMouy
FrouinMouy.Properties.VariableNames = {'Longitude','Latitude','Year','Source'};
%iNat
iNat.Properties.VariableNames = {'Longitude','Latitude','Year','Source'};
%WSDB
WSDBM = WSDB(:,{'LATITUDE','LONGITUDE','WS_DATE',});
WSDBM.Source = repmat("WSDB", size(WSDBM.LATITUDE));
WSDBM.Properties.VariableNames = {'Latitude','Longitude','Year','Source'};
WSDBM.Year = datetime(WSDBM.Year,'InputFormat','dd-MMM-yy');
WSDBM.Year = year(WSDBM.Year);
WSDBM.Year(1) = 1963;
WSDBM.Year(2) = 1963;
%CWS
CWSM = CWS3(:,{'Lat','Long','Date'});
CWSM.Source = repmat("CWS", size(CWSM.Lat));
CWSM.Properties.VariableNames = {'Latitude','Longitude','Year','Source'};
CWSM.Year = year(CWSM.Year);

Master = [Master;OBISM;FrouinMouy;iNat;WSDBM;CWSM];
MasterTable = rmmissing(Master);

MasterTableTT = MasterTable(:,{'Year','Latitude','Longitude','Source'});
MasterTableTT.Year = datetime(string(MasterTableTT.Year),'Format','yyyy');
MasterTableTT = table2timetable(MasterTableTT);
%% Plot OBIS data showing # sightings vs. year
figure
hist(MasterTable.Year,96);
xlabel('Year')
ylabel('# of Sperm Whale Observations');
%% Plot OBIS data showing latitude of the northernmost site by year
MasterTable_YrMean = MasterTableTT(:,{'Latitude'});
YrMean = retime(MasterTable_YrMean,'yearly','max');
YrMean = rmmissing(YrMean);
figure
plot(YrMean.Year,YrMean.Latitude,'o');
xlabel('Year')
ylabel('Northernmost Spermwhale Observation');
%% OBIS map with size of marker indicating oldest to most recent observations using geoscatter and a scale with 30 different sizes
%each year is a different size
%add scale for plotting
scale = (50:30:950)';
YrMean.Scale = scale(1:30);
%match scale with MasterTable
GeoScat = join(MasterTableTT,YrMean);

%six sizes only
%sort timetable
length = 6;
scale = (50:45:290)'; %6 colors only
GeoScat_sorted = sortrows(GeoScat);
[Y,E] = discretize(GeoScat_sorted.Year,6); %make 5 bins based on year
GeoScat_sorted.SizeVal = Y;
GeoScat_sorted.Scale = zeros(200,1);

%add size to each observation based on the date
for n = 1:length
[II,JJ] = size(GeoScat_sorted.Scale(GeoScat_sorted.SizeVal == n));
GeoScat_sorted.Scale(GeoScat_sorted.SizeVal == n) = scale(n);
end

%below is the color of your markers, edit if needed
J = [0.4 0.4 0.4]; %dark grey
I = [0 0 1]; %lighter blue
G = [0.4940, 0.1840, 0.5560]; %purple
H = [0.6 0 0.6]; %pink;
F = [0 0 0]; %black
E = [0.75, 0.75, 0]; %mustard yellow
D = [0 0.5 0]; %green
C = [1 0.5 0]; %yellow
B = [0.5 0 0]; %maroon
A = [0 0 0.25]; %navy blue

figure
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'HMAP'),GeoScat.Longitude(string(GeoScat.Source) == 'HMAP'),GeoScat.Scale(string(GeoScat.Source) == 'HMAP'),'.','MarkerEdgeColor',B);
hold on
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'WSDB'),GeoScat.Longitude(string(GeoScat.Source) == 'WSDB'),GeoScat.Scale(string(GeoScat.Source) == 'WSDB'),'.','MarkerEdgeColor',E);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'CWS'),GeoScat.Longitude(string(GeoScat.Source) == 'CWS'),GeoScat.Scale(string(GeoScat.Source) == 'CWS'),'.','MarkerEdgeColor',C);
gg = geoplot(Dataset280_3.LatStart(effort_280),Dataset280_3.LongStart(effort_280),'Color',[1 0.5 0]);
gg.Annotation.LegendInformation.IconDisplayStyle = 'off';
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Happywhale.com'),GeoScat.Longitude(string(GeoScat.Source) == 'Happywhale.com'),GeoScat.Scale(string(GeoScat.Source) == 'Happywhale.com'),'.','MarkerEdgeColor',D);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'IMR'),GeoScat.Longitude(string(GeoScat.Source) == 'IMR'),GeoScat.Scale(string(GeoScat.Source) == 'IMR'),'.','MarkerEdgeColor',A);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),GeoScat.Longitude(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),GeoScat.Scale(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),'.','MarkerEdgeColor',G);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Frouin-Mouy'),GeoScat.Longitude(string(GeoScat.Source) == 'Frouin-Mouy'),GeoScat.Scale(string(GeoScat.Source) == 'Frouin-Mouy'),'.','MarkerEdgeColor',H);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'iNaturalist'),GeoScat.Longitude(string(GeoScat.Source) == 'iNaturalist'),GeoScat.Scale(string(GeoScat.Source) == 'iNaturalist'),'.','MarkerEdgeColor',I);
geoscatter(LatHARP,LongHARP,markSize,'.','MarkerEdgeColor',F);
geobasemap landcover

[~,objh] = legend('HMAP','WSDB','PIROP','Happywhale','IMR','NAFO','Frouin-Mouy','Jones','Recording Site');
objh1 = findobj(objh,'type','patch');
set(objh1,'MarkerSize',30);
hold off
%% OBIS map with size of marker indicating oldest to most recent observations 
%each year is a different size
%add scale for plotting
scale = (50:30:950)';
YrMean.Scale = scale(1:30);
%match scale with MasterTable
GeoScat = join(MasterTableTT,YrMean);

%below is the color of your markers, edit if needed
J = [0.4 0.4 0.4]; %dark grey
I = [0 0 1]; %lighter blue
G = [0.4940, 0.1840, 0.5560]; %purple
H = [0.6 0 0.6]; %pink;
F = [0 0 0]; %black
E = [0.75, 0.75, 0]; %mustard yellow
D = [0 0.5 0]; %green
C = [1 0.5 0]; %yellow
B = [0.5 0 0]; %maroon
A = [0 0 0.25]; %navy blue

figure
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'HMAP'),GeoScat.Longitude(string(GeoScat.Source) == 'HMAP'),GeoScat.Scale(string(GeoScat.Source) == 'HMAP'),'.','MarkerEdgeColor',B);
hold on
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'WSDB'),GeoScat.Longitude(string(GeoScat.Source) == 'WSDB'),GeoScat.Scale(string(GeoScat.Source) == 'WSDB'),'.','MarkerEdgeColor',E);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'CWS'),GeoScat.Longitude(string(GeoScat.Source) == 'CWS'),GeoScat.Scale(string(GeoScat.Source) == 'CWS'),'.','MarkerEdgeColor',C);
gg = geoplot(Dataset280_3.LatStart(effort_280),Dataset280_3.LongStart(effort_280),'Color',[1 0.5 0]);
gg.Annotation.LegendInformation.IconDisplayStyle = 'off';
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Happywhale.com'),GeoScat.Longitude(string(GeoScat.Source) == 'Happywhale.com'),GeoScat.Scale(string(GeoScat.Source) == 'Happywhale.com'),'.','MarkerEdgeColor',D);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'IMR'),GeoScat.Longitude(string(GeoScat.Source) == 'IMR'),GeoScat.Scale(string(GeoScat.Source) == 'IMR'),'.','MarkerEdgeColor',A);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),GeoScat.Longitude(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),GeoScat.Scale(string(GeoScat.Source) == 'Northwest Atlantic Fisheries Organization (NAFO)'),'.','MarkerEdgeColor',G);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'Frouin-Mouy'),GeoScat.Longitude(string(GeoScat.Source) == 'Frouin-Mouy'),GeoScat.Scale(string(GeoScat.Source) == 'Frouin-Mouy'),'.','MarkerEdgeColor',H);
geoscatter(GeoScat.Latitude_MasterTableTT(string(GeoScat.Source) == 'iNaturalist'),GeoScat.Longitude(string(GeoScat.Source) == 'iNaturalist'),GeoScat.Scale(string(GeoScat.Source) == 'iNaturalist'),'.','MarkerEdgeColor',I);
geoscatter(LatHARP,LongHARP,markSize,'.','MarkerEdgeColor',F);
geobasemap landcover

[~,objh] = legend('HMAP','WSDB','PIROP','Happywhale','IMR','NAFO','Frouin-Mouy','Jones','Recording Site');
objh1 = findobj(objh,'type','patch');
set(objh1,'MarkerSize',30);
hold off
%% Geobubble map with size representing age of observation
%six sizes only
%sort timetable
length = 6;
scale = (50:45:290)'; %6 colors only
GeoScat_sorted = sortrows(GeoScat);
[Y,E] = discretize(GeoScat_sorted.Year,6); %make 5 bins based on year
GeoScat_sorted.SizeVal = Y;
GeoScat_sorted.Size = zeros(200,1);
colors = distinguishable_colors(9);

%add size to each observation based on the date
for n = 1:length
[II,JJ] = size(GeoScat_sorted.Size(GeoScat_sorted.SizeVal == n));
GeoScat_sorted.Size(GeoScat_sorted.SizeVal == n) = scale(n);
end

GeoScat_sorted.Source = categorical(GeoScat_sorted.Source);
figure
gb = geobubble(GeoScat_sorted.Latitude_MasterTableTT,GeoScat_sorted.Longitude,GeoScat_sorted.SizeVal,GeoScat_sorted.Source)
geobasemap landcover
gb.BubbleColorList = colors;
gb.SizeLegendTitle = 'Year';
gb.ColorLegendTitle = 'Data Source';
exportgraphics(gcf,'I:\My Drive\Manuscripts\CANARC\figures\OBIS_Bubble_HighQuality.pdf','ContentType','vector','Resolution',300);
%% Color gradient map -- can't specify the sources so I'm not sure how useful this one is
length = 6;
red = [1, 0, 0];
pink = [255, 192, 203]/255;
%colors_p = validatecolor([linspace(red(1),pink(1),length)', linspace(red(2),pink(2),length)', linspace(red(3),pink(3),length)'],'multiple'); %only works after 2020B i think
colors_p = [linspace(red(1),pink(1),length)', linspace(red(2),pink(2),length)', linspace(red(3),pink(3),length)'];

%sort timetable
GeoScat_sorted = sortrows(GeoScat);
[Y,E] = discretize(GeoScat_sorted.Year,6); %make 5 bins based on year
GeoScat_sorted.ColVal = Y;
GeoScat_sorted.Color = zeros(200,3);

%add color bar to each observation based on the date
for n = 1:length
[II,JJ] = size(GeoScat_sorted.Color(GeoScat_sorted.ColVal == n,:));
GeoScat_sorted.Color(GeoScat_sorted.ColVal == n,:) = repmat(colors_p(n,:),II,1);
end

figure
for n=1:200
    geoscatter(GeoScat_sorted.Latitude_MasterTableTT(n),GeoScat_sorted.Longitude(n),markSize,'.','MarkerEdgeColor',GeoScat_sorted.Color(n,:))
    hold on
end
gg = geoplot(Dataset280_3.LatStart(effort_280),Dataset280_3.LongStart(effort_280),'Color',[1 0.5 0]);
gg.Annotation.LegendInformation.IconDisplayStyle = 'off';
geoscatter(LatHARP,LongHARP,markSize,'.','MarkerEdgeColor',F);
geobasemap landcover
%% Plot as 3 panels
%sort timetable
[Y,E] = discretize(GeoScat_sorted.Year,3); %make 3 bins based on year
GeoScat_sorted.Panel = Y;

figure
for n=1:96
    geoscatter(GeoScat_sorted.Latitude_MasterTableTT(n),GeoScat_sorted.Longitude(n),markSize,'.','MarkerEdgeColor',GeoScat_sorted.Color(n,:))
    hold on
end

