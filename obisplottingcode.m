%This code is used to plot data from OBIS Seamap.

T = readtable('obis_seamap_dataset_280_points_csv.csv'); %Dataset 1 (Canadian Wildlife Service 1970s-1980s)

T2 = readtable('obis_seamap_dataset_1726_points_csv.csv'); %Dataset 2 (Happy Whale)

T3 = readtable('ExtractedVisuals_Flipped.csv'); %Extracted Visuals (data picking)
T3.Var1 = -(T3.Var1);

Davidson = readtable('Davidson_Thesis3_Flipped.csv'); %just the left side of the map

table = T(200604:200631,:); %Dataset 1 (Sperm Whales only for Canadian Wildlife service dataset (1))

%Extract latitude and longitudes
LatCanada = table.latitude; %Canadian Wildlife dataset
LongCanada = table.longitude; %Canadian

LatHappy = T2.latitude; %Happy Whale dataset
LongHappy = T2.longitude; %Happy Whale

LatDav = Davidson.Var2(string(Davidson.Var3) == 'Davidson');
LongDav = Davidson.Var1(string(Davidson.Var3) == 'Davidson');
LongDav = -1*LongDav;

LatFou = T3.Var2(string(T3.Var3) == 'Frouin-Mouy');
LongFou = T3.Var1(string(T3.Var3) == 'Frouin-Mouy');

LatiNat = T3.Var2(string(T3.Var3) == 'iNaturalist');
LongiNat = T3.Var1(string(T3.Var3) == 'iNaturalist');

%HARP Lat and Long
LatHARP = 72.72;
LongHARP = -76.23;
%% Adding HMAP data
HMAP = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\Full_Dataset4.csv');
IDX = find(contains(HMAP.Dataset4_SPECIES,'Sperm'));
HMAP2 = HMAP(IDX,{'LAT','LON','GROUND'});

%site of interest only
pat = {'Davis','Greenland','Touqussaq'};
IDX2 = find(contains(HMAP.GROUND,pat));
HMAP3 = HMAP(IDX2,:);
%within lat and long
idxlat = find(HMAP3.LAT >= 59.62); 
HMAP4 = HMAP3(idxlat,:);
idxlon = find(HMAP3.LON <= -45);
HMAP5 = HMAP4(idxlon,:);

LatHMAP = HMAP5.LAT;
LongHMAP = HMAP5.LON;
%% Adding OBIS data
OBIS = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\OBIS.csv');
IDX3 = find(contains(OBIS.institutionCode,'HMAP'));
OBIS2 = OBIS;
OBIS2(IDX3,:) = [];

%within lat and long
idxlat = find(OBIS2.decimalLatitude >= 59.62); 
OBIS3 = OBIS2(idxlat,:);
idxlon = find(OBIS3.decimalLongitude <= -45);
OBIS4 = OBIS3(idxlon,:);

LatOBIS = OBIS4.decimalLatitude;
LongOBIS = OBIS4.decimalLongitude;
%%
%Plotting
%Canadian Wildlife service dataset
%below is the color of your markers, edit if needed
F = [0 0 0];
E = [0.75, 0.75, 0];
D = [0 0.5 0];
C = [1 0.5 0];
B = [0.5 0 0];
A = [0 0 0.25];
%size of markers 
markSize = 220;
markSize2 = 170;
figure
% geoscatter(LatCanada,LongCanada,markSize,'.','MarkerEdgeColor',C);
% geobasemap landcover
% hold on
s = geoscatter(HMAP5.LAT,HMAP5.LON,markSize,'.','MarkerEdgeColor',B);
row = dataTipTextRow('Grounds',HMAP5.GROUND);
s.DataTipTemplate.DataTipRows(end+1) = row;
geobasemap landcover
hold on
r = geoscatter(LatOBIS,LongOBIS,markSize,'.','MarkerEdgeColor',A);
row = dataTipTextRow('Source',OBIS2.institutionCode);
r.DataTipTemplate.DataTipRows(end+1) = row;
geobasemap landcover
hold on
geoscatter(LatFou,LongFou,markSize,'.','MarkerEdgeColor',E);
geobasemap landcover
hold on
% geoscatter(LatHappy,LongHappy,markSize,'.','MarkerEdgeColor',B);
% geobasemap landcover
% hold on
geoscatter(LatiNat,LongiNat,markSize,'.','MarkerEdgeColor',C);
geobasemap landcover
hold on
% geoscatter(LatDav,LongDav,markSize,'.', 'MarkerEdgeColor',A);
% geobasemap landcover
% hold on
geoscatter(LatHARP,LongHARP,markSize,'.','MarkerEdgeColor',F);
geobasemap landcover
hold on
[~,objh] = legend('HMAP','OBIS','Frouin-Mouy','iNaturalist')
objh1 = findobj(objh,'type','patch');
set(objh1,'MarkerSize',30);
hold off


