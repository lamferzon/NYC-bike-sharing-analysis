%clc
%clearvars

%% Data loading

%The ozone profiles data set is loaded. The data set is a MATLAB table
load ../Data/Beijing_O3

%% Objects creation

%model type
o_modeltype = stem_modeltype('f-HDGM');

%A MATLAB structure is used to store spline information for all model terms
input_fda.spline_type = 'Fourier';
input_fda.spline_range = [0 24];
input_fda.spline_nbasis_z = 7;
input_fda.spline_nbasis_beta = 5; 
input_fda.spline_nbasis_sigma = 5;
%The structure is passed as input of stem_fda constructor
o_fda = stem_fda(input_fda);

%A MATLAB structure is used to store the minimal information needed to
%create an object of class stem_data
input_data.stem_modeltype = o_modeltype;
input_data.data_table = Beijing_O3;
input_data.stem_fda = o_fda;
%The structure is passed as input of stem_data constructor
o_data = stem_data(input_data);

%An object of class stem_par is created. The stem_data object and the 
%spatial correlation type are needed to shape the stem_par object internal 
%structure
o_par = stem_par(o_data,'exponential');

%Data and model parameters define a stem_model object
o_model = stem_model(o_data,o_par);

%Initial values for model parameters are provided
n_basis=o_fda.get_basis_number;

o_par.beta = o_model.get_beta0();
o_par.sigma_eps = o_model.get_coe_log_sigma_eps0();
o_par.theta_z = ones(1,n_basis.z)*0.18;
o_par.G = diag(ones(n_basis.z,1)*0.5);
o_par.v_z = eye(n_basis.z)*10;

o_model.set_initial_values(o_par);

%Figure 2 of the paper
lat0 = 40; 
lon0 = 116;
t_start = 880;
t_end = 900;
o_model.plot_profile(lat0,lon0,t_start,t_end);

%% Model estimation

%EM parameters
o_EM_options = stem_EM_options();
o_EM_options.exit_tol_par = 0.0001; %exit tolerance on parameter vector changes
o_EM_options.exit_tol_loglike = 0.0001; %exit tolerance on log-likelihood changes
o_EM_options.max_iterations = 200; %maximum number of EM iterations

%EM estimation
o_model.EM_estimate(o_EM_options);

%Variance-covariance matrix evaluation
delta=0.001; %parameter for approximating the variance-covariance matrix
o_model.set_varcov(delta);
o_model.set_logL();

%% Print and plots

%model estimation results
o_model.print
o_model.beta_Chi2_test

%Figure 3 of the paper
o_model.plot_par

%% Model saving
if ~exist('../Output/','dir')
    mkdir('../Output/')
end
save('../Output/ozone_model.mat', 'o_model', '-v7.3');
