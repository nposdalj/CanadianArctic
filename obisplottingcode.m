%This code is used to plot data from OBIS Seamap.

T = readtable('obis_seamap_dataset_280_points_csv.csv'); %Dataset 1 (Canadian Wildlife Service 1970s-1980s)

T2 = readtable('obis_seamap_dataset_1726_points_csv.csv'); %Dataset 2 (Happy Whale)

T3 = readtable('ExtractedVisuals_Flipped.csv'); %Extracted Visuals (data picking)
T3.Var1 = -(T3.Var1);

table = T(200604:200631,:); %Dataset 1 (Sperm Whales only for Canadian Wildlife service dataset (1))

%Extract latitude and longitudes
LatCanada = table.latitude; %Canadian Wildlife dataset
LongCanada = table.longitude; %Canadian

LatHappy = T2.latitude; %Happy Whale dataset
LongHappy = T2.longitude; %Happy Whale

LatDav = T3.Var2(string(T3.Var3) == 'Davidson');
LongDav = T3.Var1(string(T3.Var3) == 'Davidson');

LatFou = T3.Var2(string(T3.Var3) == 'Frouin-Mouy');
LongFou = T3.Var1(string(T3.Var3) == 'Frouin-Mouy');

LatHARP = 72.72;
LongHARP = -76.23;
%%
%Plotting
%Canadian Wildlife service dataset
%below is the color of your markers, edit if needed
E = [0.75, 0.75, 0];
D = [0 1 0];
C = [1 0 0];
B = [0.5 0 0];
A = [0 0 0.25];
%size of markers 
markSize = 120;
markSize2 = 170;
figure
geoscatter(LatCanada,LongCanada,markSize,'.','MarkerEdgeColor',C);
geobasemap landcover
hold on
geoscatter(LatHappy,LongHappy,markSize,'.','MarkerEdgeColor',B);
geobasemap landcover
hold on
geoscatter(LatHARP,LongHARP,markSize2,'.','MarkerEdgeColor',A);
geobasemap landcover
hold on
geoscatter(LatDav,LongDav,markSize,'.','MarkerEdgeColor',D);
geobasemap landcover
hold on
geoscatter(LatFou,LongFou,markSize,'.','MarkerEdgeColor',E);
geobasemap landcover
legend('Canada Dataset','Happy Whale','HARP','Davidson','Fouin-Mouy')
hold off


