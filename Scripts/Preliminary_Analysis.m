% Preliminary Analysis

clc
clearvars
warning off

%load DATA
%cd("C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Scripts")

load('..\Data\Processed Data\Bike_sharing_data.mat')
load('..\Data\Processed Data\Meteo_data.mat')
Transport_ST=readtable('../Data/Jersey _City_train_stations.csv');

%% Stations Analysis

lat_b=bike_sharing_data.lat(1:51);
lon_b=bike_sharing_data.lon(1:51);
lat_t=Transport_ST.Lat;
lon_t=Transport_ST.Lon;
%compute nearest train station for each BS station
dist=ones(length(lat_b),1);
dist_i=ones(length(lat_t),1);
for i=1:length(lat_b) %for each bike station
    for j=1:length(lat_t) %for each train station
        dist_i(j)= distance('gc',lat_b(i),lon_b(i),lat_t(j),lon_t(j)); %deg
        dist_i(j)=deg2km(dist_i(j));  %deg->km
    end
    dist(i)=min(dist_i);
end
Dist_tbl=table(lat_b,lon_b,dist);
save("..\Data\Processed Data\Nearest_TS_Distance.mat","Dist_tbl")
s=geoscatter(Dist_tbl,"lat_b","lon_b","filled");
s.ColorVariable="dist";
s.SizeData=100;
c = colorbar;
c.Label.String = "Nearest subway/train station distance [km]";
c.FontSize=18;
hold on
t=geoscatter(Transport_ST,"Lat","Lon","filled","Marker","square","MarkerFaceColor","k");
t.SizeData=100;
legend("Bike Sharing Stations","Subway/train station","FontSize",14)
title(['\textbf{Bike Sharing and subway/train stations}'], 'Interpreter', 'latex',"FontSize",24)

%% README.md cover creation
avg_service_usage = mean(bike_sharing_data.daily_data{1}, 1);
daily_calendar = datetime(bike_sharing_data.daily_calendar, "ConvertFrom", "datenum");
start_ld = datetime(2020, 3, 22);
end_ld = datetime(2020, 5, 15);

figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'vs daily rainfall}'], 'Interpreter', 'latex')
v = [81 0; 135 0; 135 60; 81 60];
f = [1 2 3 4];
patch('Faces', f, 'Vertices', v, 'EdgeColor', 'none',...
    'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
ax = gca;
ax.XAxis.TickLabelInterpreter = 'latex';
xlabel("Time", 'Interpreter', 'latex')
ay = gca;
ay.YAxis.TickLabelInterpreter = 'latex';
ylabel('Average picks-up [picks-up/station]', 'Interpreter', 'latex')
text(135, 52, '\textbf{Lockdown}', 'VerticalAlignment', 'baseline', 'Rotation',  90,...
    'Interpreter', 'latex', 'Color', 'red')
yyaxis right
plot(daily_calendar, meteo_data.daily_data{4})
ylabel('Rainfall [mm]', 'Interpreter', 'latex')
%% Avg number of daily bicycle picks-up at stations vs Avg Daily Temperature
figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'vs Average Daily Temperature}'], 'Interpreter', 'latex')
patch('Faces', f, 'Vertices', v, 'EdgeColor', 'none',...
    'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
ax = gca;
ax.XAxis.TickLabelInterpreter = 'latex';
xlabel("Time", 'Interpreter', 'latex')
ay = gca;
ay.YAxis.TickLabelInterpreter = 'latex';
ylabel('Average picks-up [picks-up/station]', 'Interpreter', 'latex')
text(135, 52, '\textbf{Lockdown}', 'VerticalAlignment', 'baseline', 'Rotation',  90,...
    'Interpreter', 'latex', 'Color', 'red')
hold on
yyaxis right
plot(daily_calendar, meteo_data.daily_data{1})
ylabel('Average Daily Temperature [°C]', 'Interpreter', 'latex')
%% Avg number of daily bicycle picks-up at stations vs Avg Windspeed [km/h]
figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'vs Average Windspeed}'], 'Interpreter', 'latex')
patch('Faces', f, 'Vertices', v, 'EdgeColor', 'none',...
    'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
ax = gca;
ax.XAxis.TickLabelInterpreter = 'latex';
xlabel("Time", 'Interpreter', 'latex')
ay = gca;
ay.YAxis.TickLabelInterpreter = 'latex';
ylabel('Average picks-up [picks-up/station]', 'Interpreter', 'latex')
text(135, 52, '\textbf{Lockdown}', 'VerticalAlignment', 'baseline', 'Rotation',  90,...
    'Interpreter', 'latex', 'Color', 'red')
hold on
yyaxis right
plot(daily_calendar, meteo_data.daily_data{6})
ylabel('Average Windspeed [km/h]', 'Interpreter', 'latex')
%% Avg number of daily bicycle picks-up at stations in Holidays/Weekends
figure
plot(daily_calendar, avg_service_usage)
%Saturaday and sunday patch
for i=4:7:366
    vi = [i-1 0; i+1 0; i+1 60; i-1 60];
    patch('Faces', f, 'Vertices', vi, 'EdgeColor', 'none',...
        'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
end
holiday=[1 20 48 146 185 251 286 316 331 360];
c=1;
for i=1:1:360
    if i==holiday(c)
        c=c+1;
        vi = [i-1 0; i+1 0; i+1 60; i-1 60];
        patch('Faces', f, 'Vertices', vi, 'EdgeColor', 'none',...
            'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
    end
end
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'in Weekends/Holidays Time }'], 'Interpreter', 'latex')
legend("Avg number of daily bicycle picks-up ","Weekends/Holidays Time")

%% Modello di Regressione lineare su variabili meteo
X=[ meteo_data.daily_data{1};meteo_data.daily_data{2};meteo_data.daily_data{3}
    meteo_data.daily_data{4};meteo_data.daily_data{5};meteo_data.daily_data{6}
    meteo_data.daily_data{7};meteo_data.daily_data{8};meteo_data.daily_data{9}]';
lm_model=fitlm(X,avg_service_usage');
lm_model
%rimozione covariate che non soddisfano il test
X=[ meteo_data.daily_data{2};
    meteo_data.daily_data{6};meteo_data.daily_data{7}]';
lm_model=fitlm(X,avg_service_usage',"linear");
plot(daily_calendar,lm_model.Fitted)
hold on
plot(daily_calendar,avg_service_usage)