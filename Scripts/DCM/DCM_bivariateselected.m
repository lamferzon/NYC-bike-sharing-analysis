clc
clearvars
warning off

%% Data loading 

addpath('D-STEAM_v2\Src\');
load '../../Data/Processed Data/Daily_data.mat'
load '../../Data/Processed Data/Daily_summary_table.mat'


data.Y{1} = daily_data.bs_data{1};
data.Y_name{1} = daily_data.bs_var_names{1};
c1=6; %n° covariates of y1
n1 = size(data.Y{1}, 1); % number of stations
d = size(data.Y{1}, 2); %time istant (days)

data.Y{2} = daily_data.bs_data{2};
data.Y_name{2} = daily_data.bs_var_names{2};
c2=6; %n° covariates of y2



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
X1=ones(daily_data.num_stations,c1,d); %costant covariate
% weather data
X1(1:daily_data.num_stations,2,1:d)=daily_data.weather_data{2}; %  feel-like temperature
X1(1:daily_data.num_stations,3,1:d)=daily_data.weather_data{4}; % rainfall
%distance data tempo invariante
X1(1:daily_data.num_stations,4,1:d)=daily_data.distances{1}; % distances
% Lockdown and Holidays
X1(1:daily_data.num_stations,5,1:d)=Lockdown;
X1(1:daily_data.num_stations,6,1:d)=daily_data.weather_data{9}; % UV index
data.X_beta{1} =X1; %Xbeta
data.X_beta_name{1} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4},'Distance' 'Lockdown' ...
     daily_data.weather_var_names{9}};


X2=ones(daily_data.num_stations,c2,d); %costant covariate
% weather data
X2(1:daily_data.num_stations,2,1:d)=daily_data.weather_data{2}; %  feel-like temperature
X2(1:daily_data.num_stations,3,1:d)=daily_data.weather_data{4}; % rainfall
%distance data tempo invariante
X2(1:daily_data.num_stations,4,1:d)=daily_data.distances{1}; % distances
% Lockdown and Holidays
X2(1:daily_data.num_stations,5,1:d)=Holidays;
X2(1:daily_data.num_stations,6,1:d)=daily_data.weather_data{9}; % UV index
data.X_beta{2} = X2; %Xbeta
data.X_beta_name{2} = {'costant' daily_data.weather_var_names{2}...
    daily_data.weather_var_names{4},'Distance'  'Holidays'...
    daily_data.weather_var_names{9}};

data.X_z{1} = [ones(daily_data.num_stations, 1 ) X1(:,4,1)];
data.X_z_name{1} = {'constant','Distance'};

data.X_z{2} = [ones(daily_data.num_stations, 1 ) X2(:,4,1)  ];
data.X_z_name{2} = {'constant','Distance'};

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
%S_val = sort(randperm(n1,round(n1*0.3)))
S_val=[4 42	50	32	38	30	25	49	31	33	28	43	46	51	26]; % station choose randomly for the crossvalidation
obj_stem_validation = stem_validation({daily_data.bs_var_names{1} daily_data.bs_var_names{2}},{S_val S_val} ,0,{'point','point'});
shape=[];
obj_stem_modeltype = stem_modeltype('DCM'); 
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
    [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);
obj_stem_par_constraints=stem_par_constraints();
obj_stem_par_constraints.time_diagonal=1;
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);
%stem_model object creation
bivariate_selected_model = stem_model(obj_stem_data, obj_stem_par);
clear data


%Data transform
bivariate_selected_model.stem_data.log_transform;
bivariate_selected_model.stem_data.standardize;
obj_stem_par.v_p = [1 0.6; 0.6 1]
obj_stem_par.beta = bivariate_selected_model.get_beta0(); 
obj_stem_par.theta_p = 0.06;
obj_stem_par.sigma_eta = diag([0.02 0.02 0.02 0.02]);  
obj_stem_par.G = diag([0.8 0.8 0.8 0.8]);
obj_stem_par.sigma_eps = diag([0.3 0.3]);

bivariate_selected_model.set_initial_values(obj_stem_par);
%Model estimation
exit_toll = 0.001;
max_iterations = 100;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations = 300;
obj_stem_EM_options.exit_tol_par=0.001;
bivariate_selected_model.EM_estimate(obj_stem_EM_options);
bivariate_selected_model.set_varcov;
bivariate_selected_model.set_logL;

bivariate_selected_model.print        
bivariate_selected_model.stem_EM_result.stem_kalmansmoother_result.plot
saveas(gcf,'bivariate_selected_model.png')
sqrt(mean(bivariate_selected_model.stem_validation_result{1, 1}.cv_mse_s))
%median(bivariate_selected_model.stem_validation_result{1, 1}.cv_R2_s)
sqrt(mean(bivariate_selected_model.stem_validation_result{1, 2}.cv_mse_s))
%median(bivariate_selected_model.stem_validation_result{1, 2}.cv_R2_s)

Res_pickups=bivariate_selected_model.stem_validation_result{1, 1}.res_back;
Res_duration=bivariate_selected_model.stem_validation_result{1, 2}.res_back;
MSE_s_p=ones(15,1);
RMSE_s_p=ones(15,1);
MSE_s_d=ones(15,1);
RMSE_s_d=ones(15,1);
%compute MSE_s and RMSE_s
for i=1:15
    sum_res_s_p=0;
    sum_res_s_d=0;
    for j=1:366
        if isnan(Res_pickups(i,j))
            Res_pickups(i,j)=0;
        end
        if isnan(Res_duration(i,j))
            Res_duration(i,j)=0;
        end
        sum_res_s_p=sum_res_s_p+ Res_pickups(i,j)^2;
        sum_res_s_d=sum_res_s_d+ Res_duration(i,j)^2;
    end
    MSE_s_p(i,1)=sum_res_s_p/366;
    RMSE_s_p(i,1)=sqrt(sum_res_s_p/366);
    MSE_s_d(i,1)=sum_res_s_d/366;
    RMSE_s_d(i,1)=sqrt(sum_res_s_d/366);
end

MSE_t_p=ones(1,366);
RMSE_t_p=ones(1,366);
MSE_t_d=ones(1,366);
RMSE_t_d=ones(1,366);
for i=1:366
    sum_res_t_p=0;
    sum_res_t_d=0;
    for j=1:15
        if isnan(Res_pickups(j,i))
            Res_pickups(j,i)=0;
        end
        if isnan(Res_duration(j,i))
            Res_duration(j,i)=0;
        end
        sum_res_t_p=sum_res_t_p+ Res_pickups(j,i)^2;
        sum_res_t_d=sum_res_t_d+ Res_duration(j,i)^2;
    end
    MSE_t_p(1,i)=sum_res_t_p/15;
    RMSE_t_p(1,i)=sqrt(sum_res_t_p/15);
    MSE_t_d(1,i)=sum_res_t_d/15;
    RMSE_t_d(1,i)=sqrt(sum_res_t_d/15);
end
%plot(RMSE_t_p)
%plot(RMSE_t_d)
%Summary

RMSE_s_p_MIN=round(min(RMSE_s_p),2);
RMSE_s_p_MAX=round(max(RMSE_s_p),2);
RMSE_s_p_MEAN=round(mean(RMSE_s_p),2);
RMSE_s_p_MEDIAN=round(median(RMSE_s_p),2);

RMSE_s_d_MIN=round(min(RMSE_s_d),2);
RMSE_s_d_MAX=round(max(RMSE_s_d),2);
RMSE_s_d_MEAN=round(mean(RMSE_s_d),2);
RMSE_s_d_MEDIAN=round(median(RMSE_s_d),2);

RMSE_t_p_MIN=round(min(RMSE_t_p),2);
RMSE_t_p_MAX=round(max(RMSE_t_p),2);
RMSE_t_p_MEAN=round(mean(RMSE_t_p),2);
RMSE_t_p_MEDIAN=round(median(RMSE_t_p),2);

RMSE_t_d_MIN=round(min(RMSE_t_d),2);
RMSE_t_d_MAX=round(max(RMSE_t_d),2);
RMSE_t_d_MEAN=round(mean(RMSE_t_d),2);
RMSE_t_d_MEDIAN=round(median(RMSE_t_d),2);
save('.\Risultati\bivariate_selected_model','bivariate_selected_model')