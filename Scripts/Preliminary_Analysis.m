% *Part 2: preliminary analysis*

clc
clearvars
warning off

load('../Data/Processed data/Daily_data.mat')
Transport_ST = readtable('../Data/Sources/Train stations/Jersey_City_train_stations_data.csv');

%% Creation of the summary table

% Bike sharing data analysis

% station-by-station pickups analysis

daily_summary_table.pickups_summary{1} = min(daily_data.bs_data{1}, [], 2);
daily_summary_table.pickups_summary{2} = prctile(daily_data.bs_data{1}, 25, 2);
daily_summary_table.pickups_summary{3} = mean(daily_data.bs_data{1}, 2);
daily_summary_table.pickups_summary{4} = prctile(daily_data.bs_data{1}, 50, 2);
daily_summary_table.pickups_summary{5} = prctile(daily_data.bs_data{1}, 75, 2);
daily_summary_table.pickups_summary{6} = max(daily_data.bs_data{1}, [], 2);
daily_summary_table.pickups_summary{7} = std(daily_data.bs_data{1}, 0, 2);
daily_summary_table.pickups_summary{8} = skewness(daily_data.bs_data{1}, 1, 2);
daily_summary_table.pickups_summary{9} = kurtosis(daily_data.bs_data{1}, 1, 2);
daily_summary_table.pickups_summary{10} = zeros(daily_data.num_stations, 1);
for i = 1:daily_data.num_stations
    daily_summary_table.pickups_summary{10}(i,1) = jbtest(daily_data.bs_data{1}(i,:));
end

% mean pickups analysis 

avg_pickups = mean(daily_data.bs_data{1}, 1);
daily_summary_table.mean_pickups_summary{1} = min(avg_pickups);
daily_summary_table.mean_pickups_summary{2} = prctile(avg_pickups, 25);
daily_summary_table.mean_pickups_summary{3} = mean(avg_pickups);
daily_summary_table.mean_pickups_summary{4} = prctile(avg_pickups, 50);
daily_summary_table.mean_pickups_summary{5} = prctile(avg_pickups, 75);
daily_summary_table.mean_pickups_summary{6} = max(avg_pickups);
daily_summary_table.mean_pickups_summary{7} = std(avg_pickups);
daily_summary_table.mean_pickups_summary{8} = skewness(avg_pickups);
daily_summary_table.mean_pickups_summary{9} = kurtosis(avg_pickups);
daily_summary_table.mean_pickups_summary{10} = jbtest(avg_pickups);

% station-by-station trip duration analysis

daily_summary_table.duration_summary{1} = min(daily_data.bs_data{2}, [], 2);
daily_summary_table.duration_summary{2} = prctile(daily_data.bs_data{2}, 25, 2);
daily_summary_table.duration_summary{3} = mean(daily_data.bs_data{2}, 2, 'omitnan');
daily_summary_table.duration_summary{4} = prctile(daily_data.bs_data{2}, 50, 2);
daily_summary_table.duration_summary{5} = prctile(daily_data.bs_data{2}, 75, 2);
daily_summary_table.duration_summary{6} = max(daily_data.bs_data{2}, [], 2);
daily_summary_table.duration_summary{7} = std(daily_data.bs_data{2}, 0, 2, 'omitnan');
daily_summary_table.duration_summary{8} = skewness(daily_data.bs_data{2}, 1, 2);
daily_summary_table.duration_summary{9} = kurtosis(daily_data.bs_data{2}, 1, 2);
daily_summary_table.duration_summary{10} = zeros(daily_data.num_stations, 1);
for i = 1:daily_data.num_stations
    daily_summary_table.duration_summary{10}(i,1) = jbtest(daily_data.bs_data{2}(i,:));
end

daily_summary_table.station_id = daily_data.id;

% mean trip duration analysis

avg_duration = mean(daily_data.bs_data{2}, 1, 'omitnan');
daily_summary_table.mean_duration_summary{1} = min(avg_duration);
daily_summary_table.mean_duration_summary{2} = prctile(avg_duration, 25);
daily_summary_table.mean_duration_summary{3} = mean(avg_duration);
daily_summary_table.mean_duration_summary{4} = prctile(avg_duration, 50);
daily_summary_table.mean_duration_summary{5} = prctile(avg_duration, 75);
daily_summary_table.mean_duration_summary{6} = max(avg_duration);
daily_summary_table.mean_duration_summary{7} = std(avg_duration);
daily_summary_table.mean_duration_summary{8} = skewness(avg_duration);
daily_summary_table.mean_duration_summary{9} = kurtosis(avg_duration);
daily_summary_table.mean_duration_summary{10} = jbtest(avg_duration);

% weather data analysis

for i = 1:10
    daily_summary_table.weather_summary{i} = zeros(length(daily_data.weather_data), 1);
    for j = 1:length(daily_data.weather_data)
        switch i
            case 1
                daily_summary_table.weather_summary{i}(j,1) = min(daily_data.weather_data{j}(1,:));
            case 2
                daily_summary_table.weather_summary{i}(j,1) = prctile(daily_data.weather_data{j}(1,:), 25);
            case 3
                daily_summary_table.weather_summary{i}(j,1) = mean(daily_data.weather_data{j}(1,:));
            case 4
                daily_summary_table.weather_summary{i}(j,1) = prctile(daily_data.weather_data{j}(1,:), 50);
            case 5
                daily_summary_table.weather_summary{i}(j,1) = prctile(daily_data.weather_data{j}(1,:), 75);
            case 6
                daily_summary_table.weather_summary{i}(j,1) = max(daily_data.weather_data{j}(1,:));
            case 7
                daily_summary_table.weather_summary{i}(j,1) = std(daily_data.weather_data{j}(1,:));
            case 8
                daily_summary_table.weather_summary{i}(j,1) = skewness(daily_data.weather_data{j}(1,:));
            case 9
                daily_summary_table.weather_summary{i}(j,1) = kurtosis(daily_data.weather_data{j}(1,:));
            case 10
                daily_summary_table.weather_summary{i}(j,1) = jbtest(daily_data.weather_data{j}(1,:));
        end
    end
end

daily_summary_table.weather_variables = daily_data.weather_var_names';
daily_summary_table.statistical_indeces = {'Min', 'Q1', 'Mean', 'Median', 'Q3', 'Max',...
    'Std', 'Skewness', 'Kurtosis', 'JB test'};

% save("..\Data\Processed data\Daily_summary_table.mat", "daily_summary_table");

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
plot(daily_calendar, daily_data.weather_data{1}(1,:))
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
plot(daily_calendar, daily_data.weather_data{6}(1,:))
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