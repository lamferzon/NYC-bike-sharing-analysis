% Preliminary Analysis

clc
clearvars
warning off

load('C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Data\Processed Data\Bike_sharing_data.mat')
load('C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Data\Processed Data\Meteo_data.mat')

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
%% stations location

lat = [min(bike_sharing_data.lat)-0.01 max(bike_sharing_data.lat)+0.01];
lon = [min(bike_sharing_data.lon)-0.01 max(bike_sharing_data.lon)+0.01];

uif = uifigure;
g = geoglobe(uif);
geoplot3(g,lat,lon,[])

geoplot3(g,bike_sharing_data.lat(1:51),bike_sharing_data.lon(1:51),500,"o", ...
    'HeightReference','terrain','Color','b','LineWidth',4)
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
