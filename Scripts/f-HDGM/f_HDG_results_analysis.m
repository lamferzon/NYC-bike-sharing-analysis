
% Analysis of the results of the f-HDG model*

clc
clearvars
warning off

%% Data loading

full_model = load("..\..\Data\Outputs\f_HDG_model_1.mat");
full_model = full_model.o_model;
simply_model = load("..\..\Data\Outputs\f_HDG_model_2.mat");
simply_model = simply_model.o_model;

%%
full_model.plot_validation