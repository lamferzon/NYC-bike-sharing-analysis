clc
clearvars

addpath('..\D-STEAM_v2\Src\')
load('..\..\Data\Processed data\Daily_data.mat')

data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
d=366; %days
p=5; %n° covariates

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
X=ones(daily_data.num_stations,p,d); %costant covriate
% weather data
X(1:daily_data.num_stations,2,1:d)=daily_data.weather_data{2};
X(1:daily_data.num_stations,3,1:d)=daily_data.weather_data{4};
X(1:daily_data.num_stations,4,1:d)=daily_data.distances{1};
X(1:daily_data.num_stations,5,1:d)=daily_data.weather_data{9};
data.X_beta{1} = X; %Xbeta
data.X_beta_name{1} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4} ,'Distance' ...
    daily_data.weather_var_names{9}};

data.X_z{1} = ones(daily_data.num_stations, 1);
data.X_z_name{1} = {'constant'};
%Xz del paper ma in questo caso è solo una e costante, non come nel DCM
%dove posso decidere diverse z

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
    data.X_beta, data.X_beta_name, ...
    data.X_z, data.X_z_name);
clear X Lockdown Holidays;
obj_stem_gridlist_p = stem_gridlist();
obj_stem_grid = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid);

%      Model building     %

obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val=[]; %tolgo la stazione S_val per fare validazione 20 32 35 36
obj_stem_validation=stem_validation({daily_data.bs_var_names{1}},{S_val},0,{'point'});

shape = [];
obj_stem_modeltype = stem_modeltype('HDGM'); %dico a stem il tipo
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
    [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);

obj_stem_par_constraints=stem_par_constraints();
obj_stem_par_constraints.time_diagonal=0;
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);
%stem_model object creation
obj_stem_model = stem_model(obj_stem_data, obj_stem_par);
clear data;
%Data transform
obj_stem_model.stem_data.log_transform;
obj_stem_model.stem_data.standardize;

%Starting values
obj_stem_par.beta = obj_stem_model.get_beta0();
obj_stem_par.theta_z = 0.5;
obj_stem_par.v_z = 0.2;
obj_stem_par.sigma_eta = 0.2;
obj_stem_par.G = 0.8;
obj_stem_par.sigma_eps = 0.3;

obj_stem_model.set_initial_values(obj_stem_par);

%Model estimation
exit_toll = 0.0001;
max_iterations = 200;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.exit_tol_par = exit_toll;
obj_stem_EM_options.max_iterations = max_iterations;
obj_stem_model.EM_estimate(obj_stem_EM_options);
obj_stem_model.set_varcov;
obj_stem_model.set_logL;

obj_stem_model.print

%% VALIDATION
clc
clearvars

addpath('..\D-STEAM_v2\Src\')
load('..\..\Data\Processed data\Daily_data.mat')
data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
d=366; %days
p=5; %n° covariates
%construct X
X=ones(daily_data.num_stations,p,d); %costant covriate
% weather data
X(1:daily_data.num_stations,2,1:d)=daily_data.weather_data{2};
X(1:daily_data.num_stations,3,1:d)=daily_data.weather_data{4};
X(1:daily_data.num_stations,4,1:d)=daily_data.distances{1};
X(1:daily_data.num_stations,5,1:d)=daily_data.weather_data{9};
data.X_beta{1} = X; %Xbeta
data.X_beta_name{1} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4} ,'Distance' ...
    daily_data.weather_var_names{9}};

data.X_z{1} = ones(daily_data.num_stations, 1);
data.X_z_name{1} = {'constant'};
%Xz del paper ma in questo caso è solo una e costante, non come nel DCM
%dove posso decidere diverse z

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
    data.X_beta, data.X_beta_name, ...
    data.X_z, data.X_z_name);
clear X Lockdown Holidays;
obj_stem_gridlist_p = stem_gridlist();
obj_stem_grid = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid);

%      Model building     %

obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val=[4	42	50	32	38	30	25	49	31	33	28	43	46	51	26];
obj_stem_validation=stem_validation({daily_data.bs_var_names{1}},{S_val},0,{'point'});

shape = [];
obj_stem_modeltype = stem_modeltype('HDGM'); %dico a stem il tipo
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
    [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);

obj_stem_par_constraints=stem_par_constraints();
obj_stem_par_constraints.time_diagonal=0;
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);
%stem_model object creation
obj_stem_model = stem_model(obj_stem_data, obj_stem_par);
clear data;
%Data transform
obj_stem_model.stem_data.log_transform;
obj_stem_model.stem_data.standardize;

%Starting values
obj_stem_par.beta = obj_stem_model.get_beta0();
obj_stem_par.theta_z = 0.5;
obj_stem_par.v_z = 0.2;
obj_stem_par.sigma_eta = 0.2;
obj_stem_par.G = 0.8;
obj_stem_par.sigma_eps = 0.3;

obj_stem_model.set_initial_values(obj_stem_par);

%Model estimation
exit_toll = 0.001;
max_iterations = 200;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.exit_tol_par = exit_toll;
obj_stem_EM_options.max_iterations = max_iterations;
obj_stem_model.EM_estimate(obj_stem_EM_options);
obj_stem_model.set_varcov;
obj_stem_model.set_logL;

%CV MSE
obj_stem_model.stem_validation_result{1}.cv_mse_s
%CV R2
obj_stem_model.stem_validation_result{1}.cv_R2_s
%CV MSE Mean
sum_MSE=0;
sum_R2=0;
for i=1:15
sum_MSE = sum_MSE + obj_stem_model.stem_validation_result{1}.cv_mse_s(i);
sum_R2 = sum_R2 + obj_stem_model.stem_validation_result{1}.cv_R2_t(i);
end
MSE_Mean=sum_MSE/15;
R2_Mean=sum_R2/15;
MSE_Mean
R2_Mean
  