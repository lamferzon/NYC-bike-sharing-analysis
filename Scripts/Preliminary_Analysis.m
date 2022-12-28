% *Part 2: preliminary analysis*

clc
clearvars
warning off

load('../Data/Processed data/Daily_data.mat')
transport_ST = readtable('../Data/Sources/Train stations/Jersey_City_train_stations_data.csv');

%% Creation of the summary table

% Bike sharing data analysis

% station-by-station pickups analysis

pickups_data = daily_data.bs_data{1};
Station_ID = daily_data.id;
Lat = daily_data.lat;
Lon = daily_data.lon;
Min = round(min(pickups_data, [], 2), 2);
Q1 = round(prctile(pickups_data, 25, 2), 2);
Mean = round(mean(pickups_data, 2), 2);
Median = round(prctile(pickups_data, 50, 2), 2);
Q3 = round(prctile(pickups_data, 75, 2), 2);
Max = round(max(pickups_data, [], 2), 2);
Std = round(std(pickups_data, 0, 2), 2);
Skewness = round(skewness(pickups_data, 1, 2), 2);
Kurtosis = round(kurtosis(pickups_data, 1, 2), 2);
JB_test = zeros(daily_data.num_stations, 1);
for i = 1:daily_data.num_stations
    JB_test(i,1) = jbtest(pickups_data(i,:));
end
pickups_summary = table(Station_ID, Lat, Lon, Min, Q1, Mean, Median, Q3,...
    Max, Std, Skewness, Kurtosis, JB_test);
pickups_summary.Properties.VariableUnits = ["dimensionless", "deg", "deg", "#", "#",...
    "#", "#", "#", "#", "#", "dimensionless", "dimensionless", "dimensionless"];
daily_summary_table.bs_summary{1} = pickups_summary;

% mean pickups analysis 

avg_pickups = mean(pickups_data, 1);
Min = round(min(avg_pickups), 2);
Q1 = round(prctile(avg_pickups, 25), 2);
Mean = round(mean(avg_pickups), 2);
Median = round(prctile(avg_pickups, 50), 2);
Q3 = round(prctile(avg_pickups, 75), 2);
Max = round(max(avg_pickups), 2);
Std = round(std(avg_pickups), 2);
Skewness = round(skewness(avg_pickups), 2);
Kurtosis = round(kurtosis(avg_pickups), 2);
JB_test = jbtest(avg_pickups);
mean_pickups_summary = table(Min, Q1, Mean, Median, Q3,...
    Max, Std, Skewness, Kurtosis, JB_test);
mean_pickups_summary.Properties.VariableUnits = ["#", "#", "#", "#", "#",...
    "#", "#", "dimensionless", "dimensionless", "dimensionless"];
daily_summary_table.bs_summary{2} = mean_pickups_summary; 

% station-by-station trip duration (min) analysis

duration_data = daily_data.bs_data{2}/60;
Station_ID = daily_data.id;
Lat = daily_data.lat;
Lon = daily_data.lon;
Min = round(min(duration_data, [], 2), 2);
Q1 = round(prctile(duration_data, 25, 2), 2);
Mean = round(mean(duration_data, 2, 'omitnan'), 2);
Median = round(prctile(duration_data, 50, 2), 2);
Q3 = round(prctile(duration_data, 75, 2), 2);
Max = round(max(duration_data, [], 2), 2);
Std = round(std(duration_data, 0, 2, 'omitnan'), 2);
Skewness = round(skewness(duration_data, 1, 2), 2);
Kurtosis = round(kurtosis(duration_data, 1, 2), 2);
JB_test = zeros(daily_data.num_stations, 1);
for i = 1:daily_data.num_stations
    JB_test(i,1) = jbtest(duration_data(i,:));
end
trip_duration_summary = table(Station_ID, Lat, Lon, Min, Q1, Mean, Median, Q3,...
    Max, Std, Skewness, Kurtosis, JB_test);
trip_duration_summary.Properties.VariableUnits = ["dimensionless", "deg", "deg",...
    "min", "min", "min", "min", "min", "min", "min", "dimensionless",...
    "dimensionless", "dimensionless"];
daily_summary_table.bs_summary{3} = trip_duration_summary;

% mean trip duration analysis

avg_duration = mean(duration_data, 1, 'omitnan');
Min = round(min(avg_duration), 2);
Q1 = round(prctile(avg_duration, 25), 2);
Mean = round(mean(avg_duration, 'omitnan'), 2);
Median = round(prctile(avg_duration, 50), 2);
Q3 = round(prctile(avg_duration, 75), 2);
Max = round(max(avg_duration), 2);
Std = round(std(avg_duration, 'omitnan'), 2);
Skewness = round(skewness(avg_duration), 2);
Kurtosis = round(kurtosis(avg_duration), 2);
JB_test = jbtest(avg_duration);
mean_trip_duration_summary = table(Min, Q1, Mean, Median, Q3,...
    Max, Std, Skewness, Kurtosis, JB_test);
mean_trip_duration_summary.Properties.VariableUnits = ["min", "min", "min",...
    "min", "min", "min", "min", "dimensionless", "dimensionless", "dimensionless"];
daily_summary_table.bs_summary{4} = mean_trip_duration_summary; 

daily_summary_table.bs_vars{1} = 'pickups';
daily_summary_table.bs_vars{2} = 'mean pickups';
daily_summary_table.bs_vars{3} = 'trip duration';
daily_summary_table.bs_vars{4} = 'mean trip duration';

% weather data analysis

weather_vars_units = daily_data.weather_units_of_measure;

for i = 1:length(daily_data.weather_data)
    weather_data = daily_data.weather_data{i}(1,:);
    Min = round(min(weather_data), 2);
    Q1 = round(prctile(weather_data, 25), 2);
    Mean = round(mean(weather_data), 2);
    Median = round(prctile(weather_data, 50), 2);
    Q3 = round(prctile(weather_data, 75), 2);
    Max = round(max(weather_data), 2);
    Std = round(std(weather_data, 'omitnan'), 2);
    Skewness = round(skewness(weather_data), 2);
    Kurtosis = round(kurtosis(weather_data), 2);
    JB_test = jbtest(weather_data);
    weather_summary = table(Min, Q1, Mean, Median, Q3, Max, Std, Skewness,...
        Kurtosis, JB_test);
    var_unit = weather_vars_units{i};
    weather_summary.Properties.VariableUnits = [var_unit, var_unit, var_unit,...
        var_unit, var_unit, var_unit, var_unit, "dimensionless", "dimensionless",...
        "dimensionless"];
    daily_summary_table.weather_summary{i} = weather_summary;
end

daily_summary_table.weather_vars = daily_data.weather_var_names;

% distances analysis

distances = daily_data.distances{1}(:,1);
Min = round(min(distances), 2);
Q1 = round(prctile(distances, 25), 2);
Mean = round(mean(distances), 2);
Median = round(prctile(distances, 50), 2);
Q3 = round(prctile(distances, 75), 2);
Max = round(max(distances), 2);
Std = round(std(distances), 2);
Skewness = round(skewness(distances), 2);
Kurtosis = round(kurtosis(distances), 2);
JB_test = jbtest(distances);
distances_summary = table(Min, Q1, Mean, Median, Q3,...
    Max, Std, Skewness, Kurtosis, JB_test);
distances_summary.Properties.VariableUnits = ["deg", "deg", "deg",...
    "deg", "deg", "deg", "deg", "dimensionless", "dimensionless", "dimensionless"];
daily_summary_table.distances_summary{1} = distances_summary;

daily_summary_table.distances_vars{1} = 'distances from the nearest train station';

% save("..\Data\Processed data\Daily_summary_table.mat", "daily_summary_table");

%% Creation of the histograms and box-plots of the variables

vars = table(avg_pickups', avg_duration', daily_data.weather_data{1}(1,:)',...
    daily_data.weather_data{2}(1,:)', daily_data.weather_data{3}(1,:)',...
    daily_data.weather_data{4}(1,:)', daily_data.weather_data{5}(1,:)',...
    daily_data.weather_data{6}(1,:)', daily_data.weather_data{7}(1,:)',...
    daily_data.weather_data{8}(1,:)', daily_data.weather_data{9}(1,:)');
vars_names = ["Mean_pickups", "Mean_trip_duration", "Mean_temperature",...
    "Mean_feels_like_temperature", "Humidity", "Rainfall", "Snowfall",...
    "Wind_speed", "Cloud_cover", "Visibility", "UV_index"];
vars_units = ["Mean pickups [pickups/station]", "Mean trip duration [min]",...
    "Mean temperature [$^{\circ}$C]", "Mean feels-like temperature [$^{\circ}$C]",...
    "Humidity [$\%$]", "Rainfall [mm]", "Snowfall [cm]", "Wind speed [km/h]",...
    "Cloud cover [$\%$]", "Visibility [km]", "UV index"];

for i = 1:size(vars, 2)
    figure
    t = tiledlayout(1, 2, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    nexttile
    if i == 11
        C = categorical(vars{:,11}, [0 1 2 3 4 5 6 7 8 9 10],...
            {'0','1','2','3','4','5','6','7','8','9','10'});
        h = get(histogram(C, 'FaceColor', '#0072BD'));
        xline(median(vars{:,i})+1, 'Color', 'red', 'LineWidth', 1.5,...
        'LineStyle', '-.')
    else
        h = get(histogram(vars{:,i}, 'NumBins', 15, 'FaceColor', '#0072BD'));
        xline(median(vars{:,i}), 'Color', 'red', 'LineWidth', 1.5,...
        'LineStyle', '-.')
        xlim([h.BinLimits(1,1)-1 h.BinLimits(1,2)+1])
    end
    xlabel(vars_units(i), 'Interpreter', 'latex')
    ylabel("Frequency", 'Interpreter', 'latex')
    ax = gca;
    ax.XAxis.TickLabelInterpreter = 'latex';
    ay = gca;
    ay.YAxis.TickLabelInterpreter = 'latex';
    nexttile
    boxplot(vars{:,i}, 'Orientation', 'horizontal',...
        'Notch', 'off', 'OutlierSize', 1.5)
    if i == 11
        xlim([-1 11])
    else
        xlim([h.BinLimits(1,1)-1 h.BinLimits(1,2)+1])
    end
    xlabel(vars_units(i), 'Interpreter', 'latex')
    ax = gca;
    set(gca,'YTickLabel',[]);
    ax.XAxis.TickLabelInterpreter = 'latex';
    ay = gca;
    ay.YAxis.TickLabelInterpreter = 'latex';
    % file_name = i + "_" + vars_names(i) + "_hist.pdf";
    % path = "..\Paper\Images\Dataset description\Histograms\" + file_name;
    % exportgraphics(t, path, 'BackgroundColor', 'none');
end

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
t = geoscatter(transport_ST, "Lat", "Lon", "filled", "Marker", "square",...
    "MarkerFaceColor", "k");
t.SizeData = 100;
legend("Bike sharing stations", "Subway/train stations", "FontSize", 14)
title('\textbf{Bike sharing and subway/train stations}', 'Interpreter',...
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
rainfall = daily_data.weather_data{4};
plot(daily_calendar, rainfall(1,:))
ylabel('Rainfall [mm]', 'Interpreter', 'latex')

%% Avg number of daily bicycle pickups at stations vs avg daily temperature

figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Mean number of daily bicycle pickups at stations '...
    'vs mean daily temperature}'], 'Interpreter', 'latex')
patch('Faces', f, 'Vertices', v, 'EdgeColor', 'none',...
    'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
ax = gca;
ax.XAxis.TickLabelInterpreter = 'latex';
xlabel("Time", 'Interpreter', 'latex')
ay = gca;
ay.YAxis.TickLabelInterpreter = 'latex';
ylabel('Mean pickups [pickups/station]', 'Interpreter', 'latex')
text(135, 52, '\textbf{Lockdown}', 'VerticalAlignment', 'baseline', 'Rotation',  90,...
    'Interpreter', 'latex', 'Color', 'red')
hold on
yyaxis right
plot(daily_calendar, daily_data.weather_data{1}(1,:))
ylabel('Mean daily temperature [°C]', 'Interpreter', 'latex')

%% Avg number of daily bicycle pickups at stations vs avg windspeed

figure
plot(daily_calendar, avg_service_usage)
title(['\textbf{Average number of daily bicycle pickups at stations '...
    'vs average windspeed}'], 'Interpreter', 'latex')
patch('Faces', f, 'Vertices', v, 'EdgeColor', 'none',...
    'FaceColor', [.7 .7 .7], 'FaceAlpha',.25)
ax = gca;
ax.XAxis.TickLabelInterpreter = 'latex';
xlabel("Time", 'Interpreter', 'latex')
ay = gca;
ay.YAxis.TickLabelInterpreter = 'latex';
ylabel('Mean picks-up [pickups/station]', 'Interpreter', 'latex')
text(135, 52, '\textbf{Lockdown}', 'VerticalAlignment', 'baseline', 'Rotation',  90,...
    'Interpreter', 'latex', 'Color', 'red')
hold on
yyaxis right
plot(daily_calendar, daily_data.weather_data{6}(1,:))
ylabel('average windspeed [km/h]', 'Interpreter', 'latex')

%% Avg number of daily bicycle pickups at stations during holidays and weekends

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
title(['\textbf{Average number of daily bicycle pickups at stations '...
    'during holidays and weekends}'], 'Interpreter', 'latex')
legend("Avg number of daily bicycle picks-up ", "Holidays and weekends",...
    'Interpreter', 'latex')

%% Linear regression model for weather variables

X = [daily_data.weather_data{1}(1,:); daily_data.weather_data{2}(1,:); daily_data.weather_data{3}(1,:)
    daily_data.weather_data{4}(1,:); daily_data.weather_data{5}(1,:); daily_data.weather_data{6}(1,:)
    daily_data.weather_data{7}(1,:); daily_data.weather_data{8}(1,:); daily_data.weather_data{9}(1,:)
    daily_data.lockdown_days; daily_data.non_working_days]';
fitlm(X, avg_service_usage')

% removal of the variables that do not satisfy the t-test
X = [daily_data.weather_data{2}(1,:); daily_data.weather_data{6}(1,:); 
    daily_data.weather_data{7}(1,:); daily_data.lockdown_days; daily_data.non_working_days]';
lm_model = fitlm(X, avg_service_usage', "linear");

plot(daily_calendar, lm_model.Fitted)
hold on
plot(daily_calendar, avg_service_usage)