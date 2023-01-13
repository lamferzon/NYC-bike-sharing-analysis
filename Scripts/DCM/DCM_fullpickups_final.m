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
fullpick_model = stem_model(obj_stem_data, obj_stem_par); % creo il modello con dentro sia i dati che i parametri
clear data

%Data transform
fullpick_model.stem_data.log_transform;
fullpick_model.stem_data.standardize;

%Starting values
obj_stem_par.beta = fullpick_model.get_beta0();
obj_stem_par.theta_p = 0.01; %km
obj_stem_par.v_p = 1;
obj_stem_par.sigma_eta = diag([0.02 ]);
obj_stem_par.G = diag([0.9]);
obj_stem_par.sigma_eps = 0.3; %varianza epsilon
 
fullpick_model.set_initial_values(obj_stem_par);


% Starting values
%obj_stem_par.beta = obj_stem_model.get_beta0(); % stima di beta0 tramite OLS 
%obj_stem_par.theta_p =100; %km (questo valore può essere ricavato da un variogramma)
%Più theta è alto e più la mia indormazione posso trascinarla dove non ho il dato
%obj_stem_par.v_p = 1;
%obj_stem_par.sigma_eta = 0.2; % sono scalari perchè lo z è scalare
%(abbiamo solo una costante come covariata)
%obj_stem_par.G = 0.8; % sono scalari perchè lo z è scalare (è positivo
%perchè mi aspetto che la correlazione  sia positiva)
%obj_stem_par.sigma_eps = 0.3; %varianza epsilon (innovazione)
% questi sono valori iniziali, poi sarà l'em che andrà a stimarmeli
% Quindi rispetto al modello puramente spaziale devo fornigli anche questi
% due valori iniziali 

%Model estimation
exit_toll = 0.0001;
max_iterations = 200;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations=200;
obj_stem_EM_options.exit_tol_par=exit_toll;


fullpick_model.EM_estimate(obj_stem_EM_options);
fullpick_model.set_varcov % calcola la matrice di varianza e covarianza di theta(perametri) quindi 
% stem mi fornisce l'incertezza sulla stima dei parametri
fullpick_model.set_logL;
fullpick_model.print;

fullpick_model.stem_EM_result.stem_kalmansmoother_result.plot;

%{
– EM_estimate: computation of parameter estimates;
– set_varcov: computation of the estimated variance-covariance matrix;
– plot_profile: plot of functional data;
– print: print estimated model summary;
– beta_Chi2_test: testing significance of covariates;
– plot_par: plot functional parameter;
– plot_validation: plot MSE validation.
%}
sqrt(mean(fullpick_model.stem_validation_result{1, 1}.cv_mse_s))
median(fullpick_model.stem_validation_result{1, 1}.cv_R2_s)
Res_pickups=fullpick_model.stem_validation_result{1, 1}.res_back;
%Res_duration=fullmodel.stem_validation_result{1, 2}.res_back;
MSE_s_p=ones(15,1);
RMSE_s_p=ones(15,1);
%MSE_s_d=ones(15,1);
%RMSE_s_d=ones(15,1);
%compute MSE_s and RMSE_s
for i=1:15
    sum_res_s_p=0;
    %sum_res_s_d=0;
    for j=1:366
        if isnan(Res_pickups(i,j))
            Res_pickups(i,j)=0;
        end
      %  if isnan(Res_duration(i,j))
      %      Res_duration(i,j)=0;
     %   end
        sum_res_s_p=sum_res_s_p+ Res_pickups(i,j)^2;
       % sum_res_s_d=sum_res_s_d+ Res_duration(i,j)^2;
    end
    MSE_s_p(i,1)=sum_res_s_p/366;
    RMSE_s_p(i,1)=sqrt(sum_res_s_p/366);
    %MSE_s_d(i,1)=sum_res_s_d/366;
    %RMSE_s_d(i,1)=sqrt(sum_res_s_d/366);
end

MSE_t_p=ones(1,366);
RMSE_t_p=ones(1,366);
%MSE_t_d=ones(1,366);
%RMSE_t_d=ones(1,366);
for i=1:366
    sum_res_t_p=0;
    %sum_res_t_d=0;
    for j=1:15
        if isnan(Res_pickups(j,i))
            Res_pickups(j,i)=0;
        end
     %   if isnan(Res_duration(j,i))
      %      Res_duration(j,i)=0;
      %  end
        sum_res_t_p=sum_res_t_p+ Res_pickups(j,i)^2;
   %     sum_res_t_d=sum_res_t_d+ Res_duration(j,i)^2;
    end
    MSE_t_p(1,i)=sum_res_t_p/15;
    RMSE_t_p(1,i)=sqrt(sum_res_t_p/15);
   % MSE_t_d(1,i)=sum_res_t_d/15;
   % RMSE_t_d(1,i)=sqrt(sum_res_t_d/15);
end
%plot(RMSE_t_p)
%plot(RMSE_t_d)
%Summary

RMSE_s_p_MIN=round(min(RMSE_s_p),2);
RMSE_s_p_MAX=round(max(RMSE_s_p),2);
RMSE_s_p_MEAN=round(mean(RMSE_s_p));
RMSE_s_p_MEDIAN=round(median(RMSE_s_p),2);

%RMSE_s_d_MIN=round(min(RMSE_s_d));
%RMSE_s_d_MAX=round(max(RMSE_s_d));
%RMSE_s_d_MEAN=round(mean(RMSE_s_d));
%RMSE_s_d_MEDIAN=round(median(RMSE_s_d));

RMSE_t_p_MIN=round(min(RMSE_t_p),2);
RMSE_t_p_MAX=round(max(RMSE_t_p),2);
RMSE_t_p_MEAN=round(mean(RMSE_t_p),2);
RMSE_t_p_MEDIAN=round(median(RMSE_t_p),2);

%RMSE_t_d_MIN=round(min(RMSE_t_d));
%RMSE_t_d_MAX=round(max(RMSE_t_d));
%RMSE_t_d_MEAN=round(mean(RMSE_t_d));
%RMSE_t_d_MEDIAN=round(median(RMSE_t_d));
save('.\Risultati\fullpick','fullpick_model')