%This code is used to plot data from OBIS Seamap
%Created by CS

T = readtable('obis_seamap_dataset_280_points_csv.csv'); %Dataset 1 (Canadian Wildlife Service 1970s-1980s)

T2 = readtable('obis_seamap_dataset_1726_points_csv.csv'); %Dataset 2 (Happy Whale)

%T3 = readtable(''); %Dataset 3

table = T(200604:200631,:); %Dataset 1 (Sperm Whales only for Canadian Wildlife service dataset (1))

%Extract latitude and longitudes
LatCanada = table.latitude; %Canadian Wildlife dataset
LongCanada = table.longitude; %Canadian

LatHappy = T2.latitude; %Happy Whale dataset
LongHappy = T2.longitude; %Happy Whale
%%
%Plotting
%Canadian Wildlife service dataset
%below is the color of your markers, edit if needed
C = [1 0 0];
%size of markers 
markSize = 80;
figure
gm = geoscatter(LatCanada,LongCanada,markSize,'.','MarkerEdgeColor',C);
for iSite = 1
    text(lats(iSite),longs(iSite)-1,labs(iSite),'HorizontalAlignment','right','FontSize',12);
end

geobasemap landcover



