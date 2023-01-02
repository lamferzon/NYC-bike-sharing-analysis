clc
clearvars
warning off

%% Data loading 

addpath('D-STEAM_v2\Src\');
load ../Data/'Processed Data'/Hourly_data.mat

%% Regressors configuration

flag = 2;
switch flag
    case 1 % entire dataset
        data = hourly_data;
    case 2 % no lockdown and snowfall
        data = hourly_data(:, [1:7, 9:12, 14:16]);
    case 3 % no dummy variables and snowfall 
        data = hourly_data(:, [1:7, 9:11, 14:16]);
end

%% Objects creation

% model type selection
o_modeltype = stem_modeltype('f-HDGM');

% splines information
input_fda.spline_type = 'Fourier';
input_fda.spline_range = [0 24];
input_fda.spline_nbasis_z = 7;
input_fda.spline_nbasis_beta = 5; 
input_fda.spline_nbasis_sigma = 5;
o_fda = stem_fda(input_fda);

% object stem_data creation
input_data.stem_modeltype = o_modeltype;
input_data.data_table = data;
input_data.stem_fda = o_fda;
o_data = stem_data(input_data);

% object stem_par creation
o_par = stem_par(o_data,'exponential');

% object stem_model creation
o_model = stem_model(o_data, o_par);

% parameters initialization
n_basis=o_fda.get_basis_number;
o_par.beta = o_model.get_beta0();
o_par.sigma_eps = o_model.get_coe_log_sigma_eps0();
o_par.theta_z = ones(1,n_basis.z)*0.05;
o_par.G = diag(ones(n_basis.z,1)*0.5);
o_par.v_z = eye(n_basis.z)*2;
o_model.set_initial_values(o_par);

%% Profiles plotting

lat0 = 40.7177; 
lon0 = -74.0438;
t_start = 1;
t_end = 60;
o_model.plot_profile(lat0, lon0, t_start, t_end);

%% Model estimation

% EM parameters
o_EM_options = stem_EM_options();
o_EM_options.exit_tol_par = 0.0001; 
o_EM_options.exit_tol_loglike = 0.0001; 
o_EM_options.max_iterations = 200;

% EM estimation
o_model.EM_estimate(o_EM_options);

% Variance-covariance matrix evaluation
delta=0.001;
o_model.set_varcov(delta);
o_model.set_logL();
o_model.plot_par

%% Print and plots

% model estimation results
o_model.print
o_model.beta_Chi2_test

% Figure 3 of the paper
o_model.plot_par

%% Model saving

switch flag
    case 1
        save('..\Scripts\Output\f_HDG_model_1', 'o_model');
    case 2
        save('..\Scripts\Output\f_HDG_model_2', 'o_model');
    case 3
        save('..\Scripts\Output\f_HDG_model_3', 'o_model');
end
