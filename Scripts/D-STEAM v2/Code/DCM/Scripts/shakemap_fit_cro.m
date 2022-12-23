clc
clearvars
load shakemap_cro.mat

addpath('../../../Src/');

lon_eq=18.16;
lat_eq=43.07;

d = distdim(distance(lat_eq,lon_eq,shakemap.latitude,shakemap.longitude),'deg','km');

x_radial_1 = exp(-d/20);
x_radial_2 = exp(-d/40);
x_radial_3 = exp(-d/80);
x_radial_4 = exp(-d/160);
x_radial_5 = exp(-d/320);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Data  building     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

ground.Y{1} = shakemap.magnitude*2+1;
ground.Y_name{1} = 'EQN_intensity';
n1 = size(ground.Y{1}, 1);
T = size(ground.Y{1}, 2);

%load covariates for the NO2 monitoring stations
ground.X_beta{1} = [ones(n1, 1) x_radial_1 x_radial_2 x_radial_3 x_radial_4 x_radial_5];
ground.X_beta_name{1} = {'constant','radial_decay_1','radial_decay_2','radial_decay_3','radial_decay_4','radial_decay_5'};

ground.X_z = [];
ground.X_z_name = [];

ground.X_p{1} = ones(n1, 1);
ground.X_p_name{1} = {'constant'};

obj_stem_varset_p = stem_varset(ground.Y, ground.Y_name, [], [], ...
                                ground.X_beta, ground.X_beta_name, ...
                                ground.X_z, ground.X_z_name, ...
                                ground.X_p,ground.X_p_name);

%Coordinates
obj_stem_gridlist_p = stem_gridlist();
ground.coordinates{1} = [shakemap.latitude, shakemap.longitude];
obj_stem_grid = stem_grid(ground.coordinates{1}, 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Model building     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj_stem_datestamp = stem_datestamp('01-01-2009 00:00', '01-01-2009 00:00', T);

%stem_data object creation
shape = shaperead('../Maps/worldmap');

obj_stem_modeltype = stem_modeltype('DCM');
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
                          [], [], obj_stem_datestamp, [], obj_stem_modeltype, shape);
%stem_par object creation
obj_stem_par_constraints=stem_par_constraints();
obj_stem_par = stem_par(obj_stem_data, 'exponential',obj_stem_par_constraints);
%stem_model object creation
obj_stem_model = stem_model(obj_stem_data, obj_stem_par);
clear ground

%Starting values
obj_stem_par.beta = obj_stem_model.get_beta0();
obj_stem_par.theta_p = 5; %km
obj_stem_par.v_p = 0.15;
obj_stem_par.sigma_eps = 0.3;
 
obj_stem_model.set_initial_values(obj_stem_par);

%Model estimation
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations=10;
obj_stem_model.EM_estimate(obj_stem_EM_options);

%Kriging
min_lat = min(shakemap.latitude)-1;
max_lat = max(shakemap.latitude)+1;
min_lon = min(shakemap.longitude)-1;
max_lon = max(shakemap.longitude)+1;

step = 0.05;

lat = min_lat:step:max_lat;
lon = min_lon:step:max_lon;

[LON,LAT] = meshgrid(lon,lat);
krig_coordinates = [LAT(:) LON(:)];

d = distdim(distance(lat_eq,lon_eq,krig_coordinates(:,1),krig_coordinates(:,2)),'deg','km');

x_radial_1 = exp(-d/20);
x_radial_2 = exp(-d/40);
x_radial_3 = exp(-d/80);
x_radial_4 = exp(-d/160);
x_radial_5 = exp(-d/320);

obj_stem_krig_grid = stem_grid(krig_coordinates, 'deg', 'regular','pixel',size(LAT),'square',0.01,0.01);

obj_stem_krig_data = stem_krig_data(obj_stem_krig_grid,[ones(length(LON(:)),1) x_radial_1 x_radial_2 x_radial_3 x_radial_4 x_radial_5],{'constant','radial_decay_1','radial_decay_2','radial_decay_3','radial_decay_4','radial_decay_5'});
obj_stem_krig = stem_krig(obj_stem_model,obj_stem_krig_data);

obj_stem_krig_options = stem_krig_options();
obj_stem_krig_options.block_size = 1500;

obj_stem_krig_result = obj_stem_krig.kriging(obj_stem_krig_options);

s = shaperead('CNTR_BN_03M_2010.shp');

figure
subplot(1,2,1);
mapshow(lon,lat,obj_stem_krig_result{1}.y_hat,'DisplayType','texturemap');
axis equal
hold on
plot(18.16,43.07,'pr','MarkerSize',16,'LineWidth',2)
L=shakemap.magnitude==1;
plot(shakemap.longitude(L),shakemap.latitude(L),'.g');
L=shakemap.magnitude==2;
plot(shakemap.longitude(L),shakemap.latitude(L),'.y');
L=shakemap.magnitude==3;
plot(shakemap.longitude(L),shakemap.latitude(L),'.r');
mapshow(s);
xlim([min_lon,max_lon]);
ylim([min_lat,max_lat]);
colorbar
title('Estimated MMI');

subplot(1,2,2);
mapshow(lon,lat,sqrt(obj_stem_krig_result{1}.diag_Var_y_hat),'DisplayType','texturemap');
axis equal
hold on
plot(18.16,43.07,'pr','MarkerSize',16,'LineWidth',2)
mapshow(s);
xlim([min_lon,max_lon]);
ylim([min_lat,max_lat]);
colorbar
title('Std.Dev. of estimated MMI')


figure
beta = obj_stem_model.stem_par.beta;
d = 0:0.1:500;

x_radial_1 = exp(-d/20);
x_radial_2 = exp(-d/40);
x_radial_3 = exp(-d/80);
x_radial_4 = exp(-d/160);
x_radial_5 = exp(-d/320);

mmi = beta(1)+x_radial_1*beta(2)+x_radial_2*beta(3)+x_radial_3*beta(4)+x_radial_4*beta(5)+x_radial_5*beta(6);

plot(d,mmi)