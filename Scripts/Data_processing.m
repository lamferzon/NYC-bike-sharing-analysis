
% *Part 1: data processing*

%  Preliminary data processing regarding bike sharing and meteorological parameters 
%  in New York City during 2020, starting from January 1th to December 31th.

clc
clearvars
warning off

%% Bike sharing data (expected execution time: ~ 1 hour) 

%  Information extraction
tic;
disp("Start processing of bike sharing data")
disp(" ")
bike_path = "C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Data\Bike sharing";
months = ["January" "February" "March" "April" "May" "June" "July" "August"...
    "September" "October" "November" "December"];

DS = readtable(bike_path + "\" + months(1, 1) + "2020.csv");
id_stations = sort(unique(DS.startStationId));
daily_calendar = datetime(2020, 1, (1:366));
hourly_calendar = repmat(datetime('now'), 24, 366);
for i=1:366
    hourly_calendar(:, i) = datetime(2020, 1, i, (0:23), 0, 0);
end
hourly_calendar = hourly_calendar(:)';
 
daily_counters_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_counters_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_counters_table.idStation = id_stations;
hourly_counters_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_counters_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_counters_table.idStation = id_stations;

daily_age_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_age_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_age_table.idStation = id_stations;
hourly_age_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_age_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_age_table.idStation = id_stations;

daily_duration_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_duration_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_duration_table.idStation = id_stations;
hourly_duration_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_duration_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_duration_table.idStation = id_stations;

daily_male_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_male_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_male_table.idStation = id_stations;
hourly_male_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_male_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_male_table.idStation = id_stations;

daily_female_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_female_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_female_table.idStation = id_stations;
hourly_female_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_female_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_female_table.idStation = id_stations;

daily_unknown_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_unknown_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_unknown_table.idStation = id_stations;
hourly_unknown_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_unknown_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_unknown_table.idStation = id_stations;

daily_subscriber_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_subscriber_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_subscriber_table.idStation = id_stations;
hourly_subscriber_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_subscriber_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_subscriber_table.idStation = id_stations;

daily_customer_table = array2table(NaN(length(id_stations), length(daily_calendar)+1));
daily_customer_table.Properties.VariableNames = ["idStation" string(daily_calendar)];
daily_customer_table.idStation = id_stations;
hourly_customer_table = array2table(NaN(length(id_stations), length(hourly_calendar)+1));
hourly_customer_table.Properties.VariableNames = ["idStation" string(hourly_calendar)];
hourly_customer_table.idStation = id_stations;

% hourly data extraction

disp("Start hourly data extraction")
disp(" ")
day_counter = 1;
hour_counter = 1;
for i=1:length(months)
    disp(months(1, i) + " start")
    Bike_data = readtable(bike_path + "\" + months(1, i) + "2020.csv");
    for k=1:sum(month(daily_calendar, 'name') == months(1, i))
        disp(" Day: " + k + "/" + i)
        for h=0:23
            disp("  Hour: " + h)
            for j=1:length(id_stations)
                selector = Bike_data.startStationId == id_stations(j, 1)...
                & Bike_data.starttime.Day == k & Bike_data.starttime.Hour == h;
                temp = Bike_data(selector, :);
                % counting of the hourly number of picks-up per station
                count = size(temp, 1);
                hourly_counters_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {count};
                 % calculation of the hourly average users' age per station
                avg_age = mean(2020*ones(size(temp, 1), 1) - temp{:, "birthYear"});
                hourly_age_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {avg_age};
                % calculation of the hourly average trip duration per station
                avg_duration = mean(temp{:, "tripduration"});
                hourly_duration_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {avg_duration};
                % counting of the male/female/unknown hourly users per station
                male_count = size(temp(temp.gender==1, :), 1);
                hourly_male_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {male_count};
                female_count = size(temp(temp.gender==2, :), 1);
                hourly_female_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {female_count};
                unknown_count = size(temp(temp.gender==0, :), 1);
                hourly_unknown_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {unknown_count};
                % counting of the subscriber/customer hourly users per station
                subscriber_count = size(temp(temp.usertype=="Subscriber", :), 1);
                hourly_subscriber_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {subscriber_count};
                customer_count = size(temp(temp.usertype=="Customer", :), 1);
                hourly_customer_table(hourly_counters_table.idStation==id_stations(j, 1),...
                    hour_counter + 1) = {customer_count};
            end
            hour_counter = hour_counter + 1;
        end
        day_counter = day_counter + 1;
    end
    disp(months(1, i) + " done.")
    disp(" ")
end

% daily data extraction

disp("Start daily data extraction")
disp(" ")
day_counter = 1;
for i=1:length(months)
    disp(months(1, i) + " start")
    Bike_data = readtable(bike_path + "\" + months(1, i) + "2020.csv");
    for k=1:sum(month(daily_calendar, 'name') == months(1, i))
        disp(" Day: " + k + "/" + i)
        for j=1:length(id_stations)
            selector = Bike_data.startStationId == id_stations(j, 1)...
                & Bike_data.starttime.Day == k;
            temp = Bike_data(selector, :);
            % counting of the daily number of picks-up per station
            count = size(temp, 1);
            daily_counters_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {count};
            % calculation of the daily average users' age per station
            avg_age = mean(2020*ones(size(temp, 1), 1) - temp{:, "birthYear"});
            daily_age_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {avg_age};
            % calculation of the daily average trip duration per station
            avg_duration = mean(temp{:, "tripduration"});
            daily_duration_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {avg_duration};
            % counting of the male/female/unknown daily users per station
            male_count = size(temp(temp.gender==1, :), 1);
            daily_male_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {male_count};
            female_count = size(temp(temp.gender==2, :), 1);
            daily_female_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {female_count};
            unknown_count = size(temp(temp.gender==0, :), 1);
            daily_unknown_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {unknown_count};
            % counting of the subscriber/customer daily users per station
            subscriber_count = size(temp(temp.usertype=="Subscriber", :), 1);
            daily_subscriber_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {subscriber_count};
            customer_count = size(temp(temp.usertype=="Customer", :), 1);
            daily_customer_table(daily_counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {customer_count};
        end
        day_counter = day_counter + 1;
    end
    disp(months(1, i) + " done.")
    disp(" ")
end

num_stations = length(id_stations);
lat_stations = zeros(num_stations, 1);
lon_stations = zeros(num_stations, 1);
for i=1:num_stations
    temp = Bike_data(Bike_data.startStationId==id_stations(i, 1), :);
    lat_stations(i, 1) = temp{1, "startStationLatitude"};
    lon_stations(i, 1) = temp{1, "startStationLongitude"};
end

% In 2020, the US federal holidays fell on the following dates:
% - Wednesday, January 1 – New Year:s Day
% - Monday, January 20 – Birthday of Martin Luther King, Jr.
% - Monday, February 17 – Washington-s Birthday
% - Monday, May 25 – Memorial Day
% - Friday, July 3 – Independence Day
% - Monday, September 7 – Labor Day
% - Monday, October 12 – Columbus Day
% - Wednesday, November 11 – Veterans Day
% - Thursday, November 26 – Thanksgiving Day
% - Friday, December 25 – Christmas Day

daily_calendar = convertTo(daily_calendar, "datenum");
hourly_calendar = convertTo(hourly_calendar, "datenum");

sundays = convertTo(datetime(2020, 1, 5), "datenum"):7:convertTo(datetime(2020, 12, 27), "datenum");
holidays = convertTo([datetime(2020, 1, 1) datetime(2020, 1, 20) ...
    datetime(2020, 2, 17) datetime(2020, 5, 25) datetime(2020, 7, 3) ...
    datetime(2020, 9, 7) datetime(2020, 10, 12) datetime(2020, 11, 11) ...
    datetime(2020, 11, 26) datetime(2020, 12, 25)], "datenum");
non_working_days = ismember(daily_calendar, [sundays holidays]);

% Lockdown dates due to COVID-19 pandemic in New York City:
% - March 22, 2020: NYS on Pause Program begins, all non-essential workers
%   must stay home;
% - May 15, 2020: Governor Cuomo allows drive-in theaters, landscaping, and
%   low-risk recreational activities to reopen.

lockdown = convertTo(datetime(2020, 3, 22),...
    "datenum"):1:convertTo(datetime(2020, 5, 15), "datenum");
lockdown_days = ismember(daily_calendar, lockdown);

% Data formatting and export

bike_sharing_data.daily_data{1} = daily_counters_table{:,2:end};
bike_sharing_data.daily_data{2} = daily_duration_table{:,2:end};
bike_sharing_data.daily_data{3} = daily_age_table{:,2:end};
bike_sharing_data.daily_data{4} = daily_male_table{:,2:end};
bike_sharing_data.daily_data{5} = daily_female_table{:,2:end};
bike_sharing_data.daily_data{6} = daily_unknown_table{:,2:end};
bike_sharing_data.daily_data{7} = daily_subscriber_table{:,2:end};
bike_sharing_data.daily_data{8} = daily_customer_table{:,2:end};
bike_sharing_data.hourly_data{1} = hourly_counters_table{:,2:end};
bike_sharing_data.hourly_data{2} = hourly_duration_table{:,2:end};
bike_sharing_data.hourly_data{3} = hourly_age_table{:,2:end};
bike_sharing_data.hourly_data{4} = hourly_male_table{:,2:end};
bike_sharing_data.hourly_data{5} = hourly_female_table{:,2:end};
bike_sharing_data.hourly_data{6} = hourly_unknown_table{:,2:end};
bike_sharing_data.hourly_data{7} = hourly_subscriber_table{:,2:end};
bike_sharing_data.hourly_data{8} = hourly_customer_table{:,2:end};
bike_sharing_data.var_names{1} = 'access counters';
bike_sharing_data.var_names{2} = 'avg trip duration';
bike_sharing_data.var_names{3} = 'avg clients age';
bike_sharing_data.var_names{4} = 'male counters';
bike_sharing_data.var_names{5} = 'female counters';
bike_sharing_data.var_names{6} = 'unknown gender counters';
bike_sharing_data.var_names{7} = 'subscribers counters';
bike_sharing_data.var_names{8} = 'customers counters';
bike_sharing_data.unit_of_measure{1} = 'dimensionless';
bike_sharing_data.unit_of_measure{2} = 's';
bike_sharing_data.unit_of_measure{3} = 'years';
bike_sharing_data.unit_of_measure{4} = 'dimensionless';
bike_sharing_data.unit_of_measure{5} = 'dimensionless';
bike_sharing_data.unit_of_measure{6} = 'dimensionless';
bike_sharing_data.unit_of_measure{7} = 'dimensionless';
bike_sharing_data.unit_of_measure{8} = 'dimensionless';
bike_sharing_data.daily_calendar = daily_calendar;
bike_sharing_data.hourly_calendar = hourly_calendar;
bike_sharing_data.non_working_days = non_working_days;
bike_sharing_data.lockdown_days = lockdown_days;
bike_sharing_data.temporal_granularity{1}  = 'day';
bike_sharing_data.temporal_granularity{2}  = 'hour';
bike_sharing_data.measure_type = 'observed';
bike_sharing_data.data_type = 'point';
bike_sharing_data.data_source = 'https://www.kaggle.com/datasets/vineethakkinapalli/citibike-bike-sharingnewyork-cityjan-to-apr-2021';
bike_sharing_data.num_stations = num_stations;
bike_sharing_data.location  = 'New York City';
bike_sharing_data.id = id_stations;
bike_sharing_data.lat = lat_stations;
bike_sharing_data.lon = lon_stations;
bike_sharing_data.coordinate_unit = 'degree';
bike_sharing_data.processing_authors{1} = 'Alessandro Chaar';
bike_sharing_data.processing_authors{2} = 'Lorenzo Leoni';
bike_sharing_data.processing_authors{3} = 'Nicola Zambelli';
bike_sharing_data.processing_date = convertTo(datetime(2022, 12, 4), "datenum");
bike_sharing_data.processing_machine = 'PCWIN64';
%% 

save("C:/Users/nicol/OneDrive/Desktop/Bike_sharing_data.mat",...
    "bike_sharing_data");

clearvars -except bike_sharing_data
disp("Processing of bike sharing data done.")
toc;

%% Meteorological data

%  Information extraction

tic;
disp(" ")
disp("Start processing of meteorological data")
disp(" ")

daily_meteo_path = "C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Data\NYC_meteo_daily_data.csv";
hourly_meteo_path = "C:\Users\nicol\OneDrive\Documenti\NY-bike-sharing-anaysis\Data\NYC_meteo_hourly_data.csv";
Daily_meteo_DS = readtable(daily_meteo_path);
Hourly_meteo_DS = readtable(hourly_meteo_path);
Hourly_meteo_DS = Hourly_meteo_DS(1:(24*366), :);

daily_calendar = convertTo(datetime(2020, 1, (1:366)), "datenum");
hourly_calendar = repmat(datetime('now'), 24, 366);
for i=1:366
    hourly_calendar(:, i) = datetime(2020, 1, i, (0:23), 0, 0);
end
hourly_calendar = convertTo(hourly_calendar(:)', "datenum");

% Data formatting and export

meteo_data.daily_data{1} = Daily_meteo_DS{:, "temp"}';
meteo_data.daily_data{2} = Daily_meteo_DS{:, "feelslike"}';
meteo_data.daily_data{3} = Daily_meteo_DS{:, "humidity"}';
meteo_data.daily_data{4} = Daily_meteo_DS{:, "precip"}';
meteo_data.daily_data{5} = Daily_meteo_DS{:, "snow"}';
meteo_data.daily_data{6} = Daily_meteo_DS{:, "windspeed"}';
meteo_data.daily_data{7} = Daily_meteo_DS{:, "cloudcover"}';
meteo_data.daily_data{8} = Daily_meteo_DS{:, "visibility"}';
meteo_data.daily_data{9} = Daily_meteo_DS{:, "uvindex"}';
meteo_data.hourly_data{1} = Hourly_meteo_DS{:, "temp"}';
meteo_data.hourly_data{2} = Hourly_meteo_DS{:, "feelslike"}';
meteo_data.hourly_data{3} = Hourly_meteo_DS{:, "humidity"}';
meteo_data.hourly_data{4} = Hourly_meteo_DS{:, "precip"}';
meteo_data.hourly_data{5} = Hourly_meteo_DS{:, "snow"}';
meteo_data.hourly_data{6} = Hourly_meteo_DS{:, "windspeed"}';
meteo_data.hourly_data{7} = Hourly_meteo_DS{:, "cloudcover"}';
meteo_data.hourly_data{8} = Hourly_meteo_DS{:, "visibility"}';
meteo_data.hourly_data{9} = Hourly_meteo_DS{:, "uvindex"}';
meteo_data.var_names{1} = 'avg temperature';
meteo_data.var_names{2} = 'avg feels like temperature';
meteo_data.var_names{3} = 'humidity';
meteo_data.var_names{4} = 'rainfall';
meteo_data.var_names{5} = 'snowfall';
meteo_data.var_names{6} = 'windspeed';
meteo_data.var_names{7} = 'cloud cover';
meteo_data.var_names{8} = 'visibility';
meteo_data.var_names{9} = 'UV index';
meteo_data.unit_of_measure{1} = '°C';
meteo_data.unit_of_measure{2} = '°C';
meteo_data.unit_of_measure{3} = '%';
meteo_data.unit_of_measure{4} = 'mm';
meteo_data.unit_of_measure{5} = 'cm';
meteo_data.unit_of_measure{6} = 'km/h';
meteo_data.unit_of_measure{7} = '%';
meteo_data.unit_of_measure{8} = 'km';
meteo_data.unit_of_measure{9} = 'dimensionless';
meteo_data.daily_calendar = daily_calendar;
meteo_data.hourly_calendar = hourly_calendar;
meteo_data.temporal_granularity{1}  = 'day';
meteo_data.temporal_granularity{2}  = 'hour';
meteo_data.measure_type = 'observed';
meteo_data.data_type = 'global';
meteo_data.data_source = 'https://www.visualcrossing.com/weather/weather-data-services/New%20York/us/last15days#';
meteo_data.location  = 'New York City';
meteo_data.processing_authors{1} = 'Alessandro Chaar';
meteo_data.processing_authors{2} = 'Lorenzo Leoni';
meteo_data.processing_authors{3} = 'Nicola Zambelli';
meteo_data.processing_date = convertTo(datetime(2022, 12, 5), "datenum");
meteo_data.processing_machine = 'PCWIN64';

save("C:/Users/nicol/OneDrive/Desktop/Meteo_data.mat",... 
    "meteo_data");

clearvars -except bike_sharing_data meteo_data
disp("Processing of meteorological data done.")
toc;

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
