clc
clearvars

addpath('..\D-STEAM_v2\Src\')
load('..\..\Data\Processed data\Daily_data.mat')

%load Observation
data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
data.Y{2} = daily_data.bs_data{2};
data.Y_name{2} = daily_data.bs_var_names{2};
d=366; %days
p=12;

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
X(1:daily_data.num_stations,4,1:d)=daily_data.weather_data{6};
X(1:daily_data.num_stations,5,1:d)=daily_data.weather_data{7};
%distance data tempo invariante
X(1:daily_data.num_stations,6,1:d)=daily_data.distances{1};
% Lockdown and Holidays
X(1:daily_data.num_stations,7,1:d)=Lockdown;
X(1:daily_data.num_stations,8,1:d)=Holidays;

X(1:daily_data.num_stations,9,1:d)=daily_data.weather_data{3};
X(1:daily_data.num_stations,10,1:d)=daily_data.weather_data{5};
X(1:daily_data.num_stations,11,1:d)=daily_data.weather_data{8};
X(1:daily_data.num_stations,12,1:d)=daily_data.weather_data{9};

%load Covariates
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
data.X_z_name{1} = {'constant'};
data.X_z{2} = ones(daily_data.num_stations, 1);
data.X_z_name{2} = {'constant'};
%Xz del paper ma in questo caso è solo una e costante, non come nel DCM
%dove posso decidere diverse z

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
    data.X_beta, data.X_beta_name, ...
    data.X_z, data.X_z_name);
clear X Lockdown Holidays;
obj_stem_gridlist_p = stem_gridlist();
obj_stem_grid1 = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_grid2 = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid1);
obj_stem_gridlist_p.add(obj_stem_grid2);

%      Model building     %

obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val1=[]; %tolgo la stazione S_val per fare validazione 20 32 35 36
S_val2=[];
obj_stem_validation=stem_validation({daily_data.bs_var_names{1},daily_data.bs_var_names{2}},{S_val1,S_val2},0,{'point','point'});

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
obj_stem_par.theta_z = 10;
obj_stem_par.v_z = [1 0.6;0.6 1];
obj_stem_par.sigma_eta = diag([0.2 0.2]);
obj_stem_par.G = diag([0.8 0.8]);
obj_stem_par.sigma_eps = diag([0.3 0.3]);

obj_stem_model.set_initial_values(obj_stem_par);

%Model estimation
exit_toll = 0.001;
max_iterations = 100;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.exit_tol_par = exit_toll;
obj_stem_EM_options.max_iterations = max_iterations;
obj_stem_model.EM_estimate(obj_stem_EM_options);
obj_stem_model.set_varcov;
obj_stem_model.set_logL;

obj_stem_model.print
%% Validation 
clc
clearvars
addpath('..\D-STEAM_v2\Src\')
load('..\..\Data\Processed data\Daily_data.mat')
%load Observation
data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
data.Y{2} = daily_data.bs_data{2};
data.Y_name{2} = daily_data.bs_var_names{2};
d=366; %days
p=12;

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
X(1:daily_data.num_stations,4,1:d)=daily_data.weather_data{6};
X(1:daily_data.num_stations,5,1:d)=daily_data.weather_data{7};
%distance data tempo invariante
X(1:daily_data.num_stations,6,1:d)=daily_data.distances{1};
% Lockdown and Holidays
X(1:daily_data.num_stations,7,1:d)=Lockdown;
X(1:daily_data.num_stations,8,1:d)=Holidays;

X(1:daily_data.num_stations,9,1:d)=daily_data.weather_data{3};
X(1:daily_data.num_stations,10,1:d)=daily_data.weather_data{5};
X(1:daily_data.num_stations,11,1:d)=daily_data.weather_data{8};
X(1:daily_data.num_stations,12,1:d)=daily_data.weather_data{9};

%load Covariates
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
data.X_z_name{1} = {'constant'};
data.X_z{2} = ones(daily_data.num_stations, 1);
data.X_z_name{2} = {'constant'};
%Xz del paper ma in questo caso è solo una e costante, non come nel DCM
%dove posso decidere diverse z

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
    data.X_beta, data.X_beta_name, ...
    data.X_z, data.X_z_name);
clear X Lockdown Holidays;
obj_stem_gridlist_p = stem_gridlist();
obj_stem_grid1 = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_grid2 = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid1);
obj_stem_gridlist_p.add(obj_stem_grid2);

%      Model building     %

obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val1=[4	42	50	32	38	30	25	49	31	33	28	43	46	51	26];
S_val2=[4	42	50	32	38	30	25	49	31	33	28	43	46	51	26];
obj_stem_validation=stem_validation({daily_data.bs_var_names{1},daily_data.bs_var_names{2}},{S_val1,S_val2},0,{'point','point'});

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
obj_stem_par.theta_z = 10;
obj_stem_par.v_z = [1 0.6;0.6 1];
obj_stem_par.sigma_eta = diag([0.2 0.2]);
obj_stem_par.G = diag([0.8 0.8]);
obj_stem_par.sigma_eps = diag([0.3 0.3]);

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

%CV MSE Mean and R2 Mean
sum_MSE_1=0;
sum_R2_1=0;
sum_MSE_2=0;
sum_R2_2=0;
for i=1:15
sum_MSE_1 = sum_MSE_1 + obj_stem_model.stem_validation_result{1}.cv_mse_s(i);
sum_R2_1 = sum_R2_1 + obj_stem_model.stem_validation_result{1}.cv_R2_t(i);
sum_MSE_2=sum_MSE_2 + obj_stem_model.stem_validation_result{2}.cv_mse_s(i);
sum_R2_2=sum_R2_2 + obj_stem_model.stem_validation_result{2}.cv_R2_t(i);
end
MSE_Mean_1=sum_MSE_1/15;
R2_Mean_1=sum_R2_1/15;
MSE_Mean_2=sum_MSE_2/15;
R2_Mean_2=sum_R2_2/15;
MSE_Mean_1
R2_Mean_1

MSE_Mean_2
R2_Mean_2