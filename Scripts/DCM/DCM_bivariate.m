%%  Part 1: Estimation (and validation) of the DCM

%clc
%clearvars
%warning off

%% Data loading 

addpath('D-STEAM_v2\Src\');
load '../Data/Processed Data/Daily_data.mat'
load '../Data/Processed Data/Daily_summary_table.mat'


data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
p=12; %n° covariates 
n1 = size(data.Y{1}, 1); % number of stations
d = size(data.Y{1}, 2); %time istant (days)

data.Y{2} = daily_data.bs_data{2};
data.Y_name{2} = daily_data.bs_var_names{2};
p=12; %n° covariates 
n1 = size(data.Y{1}, 1); % number of stations
d = size(data.Y{1}, 2); %time istant (days)


%construct Lockdown and Holidays Matrix
Lockdown=ones(daily_data.num_stations,d);
Holidays=ones(daily_data.num_stations,d);
for i=1:d
    for j=1:daily_data.num_stations
        Lockdown(j,i)=daily_data.lockdown_days(i)*0.001;
        Holidays(j,i)=daily_data.non_working_days(i)*0.001;
    end
end

%construct Lockdown and Holidays Matrix
Lockdown=ones(daily_data.num_stations,d);
Holidays=ones(daily_data.num_stations,d);
for i=1:d
    for j=1:daily_data.num_stations
        Lockdown(j,i)=daily_data.lockdown_days(i);
        Holidays(j,i)=daily_data.non_working_days(i);
    end
end

%construct X
X=ones(daily_data.num_stations,p,d); %costant covariate
% weather data
X(1:daily_data.num_stations,2,1:d)=daily_data.weather_data{2}; %  feel-like temperature
X(1:daily_data.num_stations,3,1:d)=daily_data.weather_data{4}; % rainfall
X(1:daily_data.num_stations,4,1:d)=daily_data.weather_data{6}; % windspeed
X(1:daily_data.num_stations,5,1:d)=daily_data.weather_data{7}; % cloud cover
%distance data tempo invariante
X(1:daily_data.num_stations,6,1:d)=daily_data.distances{1}; % distances
% Lockdown and Holidays
X(1:daily_data.num_stations,7,1:d)=Lockdown;
X(1:daily_data.num_stations,8,1:d)=Holidays;

X(1:daily_data.num_stations,9,1:d)=daily_data.weather_data{3}; % humidity
X(1:daily_data.num_stations,10,1:d)=daily_data.weather_data{5}; % snowfall
X(1:daily_data.num_stations,11,1:d)=daily_data.weather_data{8}; % visibility
X(1:daily_data.num_stations,12,1:d)=daily_data.weather_data{9}; % UV index

data.X_beta{1} = X; %Xbeta
data.X_beta_name{1} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4} daily_data.weather_var_names{6} ...
    daily_data.weather_var_names{7} ,'Distance' 'Lockdown' 'Holidays'...
    daily_data.weather_var_names{3} daily_data.weather_var_names{5}...
    daily_data.weather_var_names{8} daily_data.weather_var_names{9}};

data.X_beta{2} = X; %Xbeta
data.X_beta_name{2} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4} daily_data.weather_var_names{6} ...
    daily_data.weather_var_names{7} ,'Distance' 'Lockdown' 'Holidays'...
    daily_data.weather_var_names{3} daily_data.weather_var_names{5}...
    daily_data.weather_var_names{8} daily_data.weather_var_names{9}};



data.X_z{1} = ones(daily_data.num_stations, 1);
data.X_z_name{1} = {'constant' };

data.X_z{2} = ones(daily_data.num_stations, 1) ;
data.X_z_name{2} = {'constant' };
data.X_p{1} =data.X_beta{1}(:, 1, 1); 
data.X_p_name{1} = {'constant'}; 

data.X_p{2} = data.X_beta{2}(:, 1, 1); 
data.X_p_name{2} = {'constant'}; 

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
                                data.X_beta, data.X_beta_name, ...
                                data.X_z, data.X_z_name, ...
                                data.X_p,data.X_p_name);

obj_stem_gridlist_p = stem_gridlist();

ground.coordinates{1} = [daily_data.lat, daily_data.lon];
ground.coordinates{2} = [daily_data.lat, daily_data.lon];
obj_stem_grid1 = stem_grid(ground.coordinates{1}, 'deg', 'sparse', 'point');
obj_stem_grid2 = stem_grid(ground.coordinates{2}, 'deg', 'sparse', 'point');
% aggiungo alla lista di griglie le griglie create
obj_stem_gridlist_p.add(obj_stem_grid1);
obj_stem_gridlist_p.add(obj_stem_grid2);
clear X Lockdown Holidays;
obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val = sort(randperm(n1,round(n1*0.3)))
obj_stem_validation = stem_validation({daily_data.bs_var_names{2} daily_data.bs_var_names{1}},{S_val S_val} ,0,{'point','point'});
shape=[];
obj_stem_modeltype = stem_modeltype('DCM'); %dico a stem il tipo
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
    [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);
obj_stem_par_constraints=stem_par_constraints();
obj_stem_par_constraints.time_diagonal=0;
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);
%stem_model object creation
obj_stem_model = stem_model(obj_stem_data, obj_stem_par);
clear data


%Data transform
obj_stem_model.stem_data.log_transform;
obj_stem_model.stem_data.standardize;
obj_stem_par.v_p = [1 0.6; 0.6 1]
obj_stem_par.beta = obj_stem_model.get_beta0(); 
obj_stem_par.theta_p = 0.06;
obj_stem_par.sigma_eta = diag([0.2 0.2 ]);  
obj_stem_par.G = diag([0.8 0.8 ]);
obj_stem_par.sigma_eps = diag([0.3 0.3]);

obj_stem_model.set_initial_values(obj_stem_par);
%Model estimation
exit_toll = 0.001;
max_iterations = 100;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations = 100;
obj_stem_EM_options.exit_tol_par=0.001;
obj_stem_model.EM_estimate(obj_stem_EM_options);
obj_stem_model.set_varcov;
obj_stem_model.set_logL;

obj_stem_model.print;        
obj_stem_model.stem_EM_result.stem_kalmansmoother_result.plot;
sqrt(mean(obj_stem_model.stem_validation_result{1, 1}.cv_mse_s))
median(obj_stem_model.stem_validation_result{1, 1}.cv_R2_s)
sqrt(mean(obj_stem_model.stem_validation_result{1, 2}.cv_mse_s))
median(obj_stem_model.stem_validation_result{1, 2}.cv_R2_s)

