%%  Part 1: Estimation (and validation) of the DCM

clc
clearvars
warning off

%% Data loading 

addpath('D-STEAM_v2\Src\');
load '../../Data/Processed Data/Daily_data.mat'
load '../../Data/Processed Data/Daily_summary_table.mat'

data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
p=7; %n° covariates 
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
X(1:daily_data.num_stations,4,1:d)=daily_data.weather_data{7}; % cloud cover
%distance data tempo invariante
X(1:daily_data.num_stations,5,1:d)=daily_data.distances{1}; % distances
% Lockdown 
X(1:daily_data.num_stations,6,1:d)=Lockdown;
X(1:daily_data.num_stations,7,1:d)=daily_data.weather_data{9}; % UV index
data.X_beta{1} = X; %Xbeta
data.X_beta_name{1} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4}  ...
    daily_data.weather_var_names{7} ,'Distance' 'Lockdown' ...
    daily_data.weather_var_names{9}};

%data.X_z{1} = [ones(daily_data.num_stations, 1) X(:,6,1) X(:,8,1) X(:,7,1)];
%data.X_z_name{1} = {'constant','Distance','Holidays','Lockdown'};


data.X_z{1} = [ones(daily_data.num_stations, 1)];
data.X_z_name{1} = {'constant'};

data.X_p{1} = X(:,1,1);
data.X_p_name{1} = {'constant'}; 

obj_stem_varset_p = stem_varset(data.Y, data.Y_name, [], [], ...
                                data.X_beta, data.X_beta_name, ...
                                data.X_z, data.X_z_name, ...
                                data.X_p,data.X_p_name);

%Coordinates
obj_stem_gridlist_p = stem_gridlist();
obj_stem_grid = stem_grid([daily_data.lat, daily_data.lon], 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid);
clear X Lockdown Holidays;
obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00',d);
S_val=[4 42	50	32	38	30	25	49	31	33	28	43	46	51	26]; % station choose randomly for the crossvalidation
obj_stem_validation = stem_validation({daily_data.bs_var_names{1}},{S_val},0,{'point'});
shape = [];
obj_stem_modeltype = stem_modeltype('DCM'); %dico a stem il tipo
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
    [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);
obj_stem_par_constraints=stem_par_constraints(); 
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);%specifico il tipo di correlazione spaziale
%stem_model object creation
pick_selected_model = stem_model(obj_stem_data, obj_stem_par); % creo il modello con dentro sia i dati che i parametri
clear data

%Data transform
pick_selected_model.stem_data.log_transform;
pick_selected_model.stem_data.standardize;

%Starting values
obj_stem_par.beta = pick_selected_model.get_beta0();
obj_stem_par.theta_p = 0.01; %km
obj_stem_par.v_p = 1;
obj_stem_par.sigma_eta = diag([0.02 ]);
obj_stem_par.G = diag([0.9 ]);
obj_stem_par.sigma_eps = 0.3; %varianza epsilon
 
pick_selected_model.set_initial_values(obj_stem_par);



%Model estimation
exit_toll = 0.0001;
max_iterations = 200;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations=200;
obj_stem_EM_options.exit_tol_par=exit_toll;


pick_selected_model.EM_estimate(obj_stem_EM_options);
pick_selected_model.set_varcov % calcola la matrice di varianza e covarianza di theta(perametri) quindi 
% stem mi fornisce l'incertezza sulla stima dei parametri
pick_selected_model.set_logL;
pick_selected_model.print;

pick_selected_model.stem_EM_result.stem_kalmansmoother_result.plot;


sqrt(mean(pick_selected_model.stem_validation_result{1, 1}.cv_mse_s))
median(pick_selected_model.stem_validation_result{1, 1}.cv_R2_s)
Res_pickups=pick_selected_model.stem_validation_result{1, 1}.res_back;

MSE_s_p=ones(15,1);
RMSE_s_p=ones(15,1);

for i=1:15
    sum_res_s_p=0;
    for j=1:366
        if isnan(Res_pickups(i,j))
            Res_pickups(i,j)=0;
        end

        sum_res_s_p=sum_res_s_p+ Res_pickups(i,j)^2;
    end
    MSE_s_p(i,1)=sum_res_s_p/366;
    RMSE_s_p(i,1)=sqrt(sum_res_s_p/366);
end

MSE_t_p=ones(1,366);
RMSE_t_p=ones(1,366);
for i=1:366
    sum_res_t_p=0;
    for j=1:15
        if isnan(Res_pickups(j,i))
            Res_pickups(j,i)=0;
        end
        sum_res_t_p=sum_res_t_p+ Res_pickups(j,i)^2;
    end
    MSE_t_p(1,i)=sum_res_t_p/15;
    RMSE_t_p(1,i)=sqrt(sum_res_t_p/15);
end
%plot(RMSE_t_p)
%plot(RMSE_t_d)
%Summary

RMSE_s_p_MIN=round(min(RMSE_s_p),2);
RMSE_s_p_MAX=round(max(RMSE_s_p),2);
RMSE_s_p_MEAN=round(mean(RMSE_s_p));
RMSE_s_p_MEDIAN=round(median(RMSE_s_p),2);
RMSE_t_p_MIN=round(min(RMSE_t_p),2);
RMSE_t_p_MAX=round(max(RMSE_t_p),2);
RMSE_t_p_MEAN=round(mean(RMSE_t_p),2);
RMSE_t_p_MEDIAN=round(median(RMSE_t_p),2);


save('.\Risultati\pick_selected_model','pick_selected_model')