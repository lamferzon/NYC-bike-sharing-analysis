%% *Part 1: data processing*

%  Preliminary data processing regarding bike sharing and meteorological parameters 
%  in New York City during 2020, starting from January 1th to December 31th.

clc
clearvars
warning off

%% Bike sharing data

%  Information extraction

bike_path = "C:\Users\loren\OneDrive - unibg.it\University\S4HDD (Statistics for High Dimensional Data)\Project\Data\Bike sharing";
months = ["January" "February" "March" "April" "May" "June" "July" "August"...
    "September" "October" "November" "December"];

DS = readtable(bike_path + "\" + months(1, 1) + "2020.csv");
calendar = datetime(2020, 1, (1:366));
id_stations = sort(unique(DS.startStationId));

counters_table = array2table(NaN(length(id_stations), length(calendar)+1));
counters_table.Properties.VariableNames = ["idStation" string(calendar)];
counters_table.idStation = id_stations;

age_table = array2table(NaN(length(id_stations), length(calendar)+1));
age_table.Properties.VariableNames = ["idStation" string(calendar)];
age_table.idStation = id_stations;

duration_table = array2table(NaN(length(id_stations), length(calendar)+1));
duration_table.Properties.VariableNames = ["idStation" string(calendar)];
duration_table.idStation = id_stations;

male_table = array2table(NaN(length(id_stations), length(calendar)+1));
male_table.Properties.VariableNames = ["idStation" string(calendar)];
male_table.idStation = id_stations;

female_table = array2table(NaN(length(id_stations), length(calendar)+1));
female_table.Properties.VariableNames = ["idStation" string(calendar)];
female_table.idStation = id_stations;

unknown_table = array2table(NaN(length(id_stations), length(calendar)+1));
unknown_table.Properties.VariableNames = ["idStation" string(calendar)];
unknown_table.idStation = id_stations;

subscriber_table = array2table(NaN(length(id_stations), length(calendar)+1));
subscriber_table.Properties.VariableNames = ["idStation" string(calendar)];
subscriber_table.idStation = id_stations;

customer_table = array2table(NaN(length(id_stations), length(calendar)+1));
customer_table.Properties.VariableNames = ["idStation" string(calendar)];
customer_table.idStation = id_stations;

day_counter = 1;
for i=1:length(months)
    disp(months(1, i) + " done.")
    Bike_data = readtable(bike_path + "\" + months(1, i) + "2020.csv");
    for k=1:sum(month(calendar, 'name') == months(1, i))
        for j=1:length(id_stations)
            selector = Bike_data.startStationId == id_stations(j, 1)...
                & Bike_data.starttime.Day == k;
            temp = Bike_data(selector, :);
            % counting of the number of starts per station
            count = size(temp, 1);
            counters_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {count};
            % calculation of the average users' age per station
            avg_age = mean(2020*ones(size(temp, 1), 1) - temp{:, "birthYear"});
            age_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {avg_age};
            % calculation of the average trip duration per station
            avg_duration = mean(temp{:, "tripduration"});
            duration_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {avg_duration};
            % counting of the male/female/unknown users per station
            male_count = size(temp(temp.gender==1, :), 1);
            male_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {male_count};
            female_count = size(temp(temp.gender==2, :), 1);
            female_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {female_count};
            unknown_count = size(temp(temp.gender==0, :), 1);
            unknown_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {unknown_count};
            % counting of the subscriber/customer users per station
            subscriber_count = size(temp(temp.usertype=="Subscriber", :), 1);
            subscriber_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {subscriber_count};
            customer_count = size(temp(temp.usertype=="Customer", :), 1);
            customer_table(counters_table.idStation==id_stations(j, 1),...
                day_counter + 1) = {customer_count};
        end
        day_counter = day_counter + 1;
    end
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

calendar = convertTo(datetime(2020, 1, (1:366)), "datenum");
sundays = convertTo(datetime(2020, 1, 5), "datenum"):7:convertTo(datetime(2020, 12, 27), "datenum");
holidays = convertTo([datetime(2020, 1, 1) datetime(2020, 1, 20) ...
    datetime(2020, 2, 17) datetime(2020, 5, 25) datetime(2020, 7, 3) ...
    datetime(2020, 9, 7) datetime(2020, 10, 12) datetime(2020, 11, 11) ...
    datetime(2020, 11, 26) datetime(2020, 12, 25)], "datenum");
non_working_days = ismember(calendar, [sundays holidays]);

% Lockdown dates due to COVID-19 pandemic in New York City:
% - March 22, 2020: NYS on Pause Program begins, all non-essential workers
%   must stay home;
% - May 15, 2020: Governor Cuomo allows drive-in theaters, landscaping, and
%   low-risk recreational activities to reopen.

lockdown = convertTo(datetime(2020, 3, 22),...
    "datenum"):1:convertTo(datetime(2020, 5, 15), "datenum");
lockdown_days = ismember(calendar, lockdown);

clearvars -except counters_table duration_table age_table male_table...
    female_table unknown_table subscriber_table customer_table Bike_data...
    calendar num_stations id_stations lat_stations lon_stations non_working_days...
    lockdown_days

% Data formatting and export

bike_sharing_data.data{1} = counters_table{:,2:end};
bike_sharing_data.data{2} = duration_table{:,2:end};
bike_sharing_data.data{3} = age_table{:,2:end};
bike_sharing_data.data{4} = male_table{:,2:end};
bike_sharing_data.data{5} = female_table{:,2:end};
bike_sharing_data.data{6} = unknown_table{:,2:end};
bike_sharing_data.data{7} = subscriber_table{:,2:end};
bike_sharing_data.data{8} = customer_table{:,2:end};
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
bike_sharing_data.date_time = calendar;
bike_sharing_data.non_working_days = non_working_days;
bike_sharing_data.lockdown_days = lockdown_days;
bike_sharing_data.temporal_granularity  = 'day';
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

save("C:\Users\loren\OneDrive - unibg.it\University\S4HDD (Statistics for High Dimensional Data)\Project\Data\Bike_sharing_data.mat",...
    "bike_sharing_data");

clearvars -except bike_sharing_data non_working_days lockdown_days

%% Meteorological data

%  Information extraction

meteo_path = "C:\Users\loren\OneDrive - unibg.it\University\S4HDD (Statistics for High Dimensional Data)\Project\Data\NY_meteo_data.csv";
Meteo_DS = readtable(meteo_path);
calendar = convertTo(datetime(2020, 1, (1:366)), "datenum");

% Data formatting and export

meteo_data.data{1} = Meteo_DS{:, "temp"}';
meteo_data.data{2} = Meteo_DS{:, "feelslike"}';
meteo_data.data{3} = Meteo_DS{:, "humidity"}';
meteo_data.data{4} = Meteo_DS{:, "precip"}';
meteo_data.data{5} = Meteo_DS{:, "snow"}';
meteo_data.data{6} = Meteo_DS{:, "windspeed"}';
meteo_data.data{7} = Meteo_DS{:, "cloudcover"}';
meteo_data.data{8} = Meteo_DS{:, "visibility"}';
meteo_data.data{9} = Meteo_DS{:, "uvindex"}';
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
meteo_data.date_time = calendar;
meteo_data.non_working_days = non_working_days;
meteo_data.lockdown_days = lockdown_days;
meteo_data.temporal_granularity  = 'day';
meteo_data.measure_type = 'observed';
meteo_data.data_type = 'global';
meteo_data.data_source = 'https://www.visualcrossing.com/weather/weather-data-services/New%20York/us/last15days#';
meteo_data.location  = 'New York City';
meteo_data.processing_authors{1} = 'Alessandro Chaar';
meteo_data.processing_authors{2} = 'Lorenzo Leoni';
meteo_data.processing_authors{3} = 'Nicola Zambelli';
meteo_data.processing_date = convertTo(datetime(2022, 12, 5), "datenum");
meteo_data.processing_machine = 'PCWIN64';

save("C:\Users\loren\OneDrive - unibg.it\University\S4HDD (Statistics for High Dimensional Data)\Project\Data\Meteo_data.mat",...
    "meteo_data");

clearvars -except bike_sharing_data meteo_data

%% README.md cover creation

avg_service_usage = mean(bike_sharing_data.data{1}, 1);
calendar = datetime(bike_sharing_data.date_time, "ConvertFrom", "datenum");
start_ld = datetime(2020, 3, 22);
end_ld = datetime(2020, 5, 15);

figure
plot(calendar, avg_service_usage)
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
ylabel('Average picks-up [picks-up/station]', 'Interpreter', 'latex');
yyaxis right
plot(calendar, meteo_data.data{4})
ylabel('Rainfall [mm]', 'Interpreter', 'latex');