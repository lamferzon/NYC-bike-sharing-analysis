
% Estimation and validation of the f-HDG model*

clc
clearvars
warning off

%% Data loading 

addpath('../D-STEAM_v2/Src/');
load ../../Data/'Processed Data'/Hourly_data.mat
load S_val.mat

%% Regressors configuration

flag = 2;
switch flag
    case 1 % entire dataset
        data = hourly_data;
    case 2 % only feels-like temperature and lockdown
        data = hourly_data(:, [1:6 13:16]);
    case 3 % only feels-like temperature, distance and dummy variables
        data = hourly_data(:, [1:6 11:16]);
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

% validation
 
o_data.stem_validation = stem_validation('pickups', S_val);

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
o_par.v_z = eye(n_basis.z)*.5;
o_model.set_initial_values(o_par);

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
o_model.plot_par
o_model.plot_validation

%% Model saving

switch flag
    case 1
        save('..\..\Data\Outputs\f_HDG_model_1', 'o_model');
    case 2
        save('..\..\Data\Outputs\f_HDG_model_2', 'o_model');
    case 3
        save('..\..\Data\Outputs\f_HDG_model_3', 'o_model');
end