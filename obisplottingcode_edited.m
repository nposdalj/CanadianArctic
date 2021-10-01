%% Adding HMAP data
HMAP = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\Full_Dataset4.csv');
IDX = find(contains(HMAP.Dataset4_SPECIES,'Sperm'));
HMAP2 = HMAP(IDX,{'LAT','LON','GROUND'});

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
OBIS = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\OBIS.csv');
IDX3 = find(contains(OBIS.institutionCode,'HMAP'));
OBIS2 = OBIS;
OBIS2(IDX3,:) = [];

%within lat and long
idxlat = find(OBIS2.decimalLatitude >= 59.62); 
OBIS3 = OBIS2(idxlat,:);
idxlon = find(OBIS3.decimalLongitude <= -45);
OBIS4 = OBIS3(idxlon,:);
%% Adding Froun-Mouy and iNaturalist data
FrouinMouy = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\FrouinMouy.csv');
FrouinMouy.Var1 = -(FrouinMouy.Var1);

iNat = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\iNat.csv');
iNat.Var1 = -(iNat.Var1);
%% Adding WSDB Data
WSDB = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\WSDB_SpermWhale_May2021.xlsx');
%% Adding CWS data
CWS = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\q SPWH sightings.xlsx');
idxlat = find(CWS.Lat >= 59.62);
CWS2 = CWS(idxlat,:);
idxlon = find(CWS2.Long <= -45);
CWS3 = CWS2(idxlon,:);
%% HARP information
%HARP Lat and Long
LatHARP = 72.72;
LongHARP = -76.23;
%% Dataset 280 effort
Dataset280 = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\obis_seamap_dataset_280_points.csv');
idxlat = find(Dataset280.latitude >= 59.62);
Dataset280_2 = Dataset280(idxlat,:);
idxlon = find(Dataset280_2.longitude <= -45);
Dataset280_3 = Dataset280_2(idxlon,:);
effort_280 = boundary(Dataset280_3.latitude,Dataset280_3.longitude);

Dataset280 = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\q survey effort_2.xlsx');
idxlat = find(Dataset280.LatStart >= 59.62);
Dataset280_2 = Dataset280(idxlat,:);
idxlon = find(Dataset280_2.LongStart <= -45);
Dataset280_3 = Dataset280_2(idxlon,:);
effort_280 = boundary(Dataset280_3.LatStart,Dataset280_3.LongStart);

%% Reeves 1985 Stranding data
% Reeves = readtable('C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\Reeves1985.xlsx');
%%
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

[~,objh] = legend('HMAP','WSDB','PIROP','Happywhale','IMR','NAFO','Frouin-Mouy','iNaturalist','Recording Site');
objh1 = findobj(objh,'type','patch');
set(objh1,'MarkerSize',30);
hold off
exportgraphics(gcf,'I:\.shortcut-targets-by-id\1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS\Arctic_Sperm whales\figures\OBIS_HighQuality.pdf','ContentType','vector','Resolution',300);

%% Write tables for continuation in R
writetable(HMAP5,'C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\HMAP_R.csv');
writetable(OBIS4,'C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\OBIS_R.csv');
writetable(iNat,'C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\iNat_R.csv');
writetable(FrouinMouy,'C:\Users\nposd\Documents\GitHub\CanadianArctic\VisualData\FrouinMouy_R.csv');
