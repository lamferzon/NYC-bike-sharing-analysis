% *Part 2: preliminary analysis*

clc
clearvars
warning off

load('../Data/Processed data/Daily_data.mat')
Transport_ST = readtable('../Data/Sources/Train stations/Jersey_City_train_stations_data.csv');

%% Weather data analysis

meteo_results = array2table(zeros(length(daily_data.meteo_data), 11));
var_names = {'Variable', 'Min', 'Q1', 'Mean', 'Median', 'Q3', 'Max',...
    'Std', 'Skewness', 'Kurtosis', 'JB_test'};
meteo_results.Properties.VariableNames = var_names;
meteo_results.Variable = daily_data.meteo_var_names';
for i = 1:length(daily_data.meteo_data)
    meteo_results.Min(i) = min(daily_data.meteo_data{i}(1,:));
    meteo_results.Q1(i) = prctile(daily_data.meteo_data{i}(1,:), 25);
    meteo_results.Mean(i) = mean(daily_data.meteo_data{i}(1,:));
    meteo_results.Median(i) = median(daily_data.meteo_data{i}(1,:));
    meteo_results.Q3(i) = prctile(daily_data.meteo_data{i}(1,:), 75);
    meteo_results.Max(i) = max(daily_data.meteo_data{i}(1,:));
    meteo_results.Std(i) = std(daily_data.meteo_data{i}(1,:));
    meteo_results.Skewness(i) = skewness(daily_data.meteo_data{i}(1,:));
    meteo_results.Kurtosis(i) = kurtosis(daily_data.meteo_data{i}(1,:));
    meteo_results.JB_test(i) = jbtest(daily_data.meteo_data{i}(1,:));
end
save("..\Data\Processed data\Meteo_results.mat", "meteo_results");

%% Creation of the map of the bike sharing and subway/train stations

Dist_tbl = table(daily_data.lat, daily_data.lon, daily_data.distances{1}(:,1));
Dist_tbl.Properties.VariableNames = ["lat_b", "lon_b", "distances"];
s = geoscatter(Dist_tbl, "lat_b", "lon_b", "filled");
s.ColorVariable = "distances";
s.SizeData = 100;
c = colorbar;
c.Label.String = "Distance of the nearest subway/train station [deg]";
c.FontSize = 18;
hold on
t = geoscatter(Transport_ST, "Lat", "Lon", "filled", "Marker", "square",...
    "MarkerFaceColor", "k");
t.SizeData = 100;
legend("Bike sharing stations", "Subway/train stations", "FontSize", 14)
title(['\textbf{Bike sharing and subway/train stations}'], 'Interpreter',...
    'latex',"FontSize",24)

%% Avg number of daily bicycle picks-up at stations vs daily rainfall

avg_service_usage = mean(daily_data.bs_data{1}, 1);
daily_calendar = daily_data.datetime_calendar;
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
rainfall = daily_data.meteo_data{4};
plot(daily_calendar, rainfall(1,:))
ylabel('Rainfall [mm]', 'Interpreter', 'latex')

%% Avg number of daily bicycle picks-up at stations vs avg daily temperature

figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'vs average daily temperature}'], 'Interpreter', 'latex')
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
plot(daily_calendar, daily_data.meteo_data{1}(1,:))
ylabel('average daily temperature [°C]', 'Interpreter', 'latex')

%% Avg number of daily bicycle picks-up at stations vs avg windspeed

figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle picks-up at stations '...
    'vs average windspeed}'], 'Interpreter', 'latex')
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
plot(daily_calendar, daily_data.meteo_data{6}(1,:))
ylabel('average windspeed [km/h]', 'Interpreter', 'latex')

%% Avg number of daily bicycle picks-up at stations during holidays and weekends

figure
plot(daily_calendar, avg_service_usage)
% Saturday and sunday patch
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
    'during holidays and weekends}'], 'Interpreter', 'latex')
legend("Avg number of daily bicycle picks-up ", "Holidays and weekends")

%% Linear regression model for meteorological variables

X = [daily_data.meteo_data{1}(1,:); daily_data.meteo_data{2}(1,:); daily_data.meteo_data{3}(1,:)
    daily_data.meteo_data{4}(1,:); daily_data.meteo_data{5}(1,:); daily_data.meteo_data{6}(1,:)
    daily_data.meteo_data{7}(1,:); daily_data.meteo_data{8}(1,:); daily_data.meteo_data{9}(1,:)
    daily_data.lockdown_days; daily_data.non_working_days]';
fitlm(X, avg_service_usage')

% removal of the variables that do not satisfy the t-test
X = [daily_data.meteo_data{2}(1,:); daily_data.meteo_data{6}(1,:); 
    daily_data.meteo_data{7}(1,:); daily_data.lockdown_days; daily_data.non_working_days]';
lm_model = fitlm(X, avg_service_usage', "linear")

plot(daily_calendar, lm_model.Fitted)
hold on
plot(daily_calendar, avg_service_usage)