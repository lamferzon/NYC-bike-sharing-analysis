%da eseguire dopo main_fit_2021 (dopo aver generato res.mat)

clc
clearvars

addpath('/home/francesco/EQN_reports/matlab_code/supplementary/D-STEM/Src');

load res

magnitude_case = 1;

if magnitude_case==1
    L=res.estimated_magnitude<4;
elseif magnitude_case==2
    L=res.estimated_magnitude>=4;
end

res.delta=res.delta(L);
res.detection_lat=res.detection_lat(L);
res.detection_lon=res.detection_lon(L);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Data  building     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

ground.Y{1} = res.delta;
ground.Y_name{1} = 'delta';
N = size(ground.Y{1}, 1);
T = size(ground.Y{1}, 2);

ground.X_beta = [];
ground.X_beta_name = [];

ground.X_z = [];
ground.X_z_name = [];

ground.X_p{1} = ones(N,1);
ground.X_p_name{1} = {'constant'};


obj_stem_varset_p = stem_varset(ground.Y, ground.Y_name, [], [], ...
                                ground.X_beta, ground.X_beta_name, ...
                                ground.X_z, ground.X_z_name, ...
                                ground.X_p,ground.X_p_name);

%Coordinates
obj_stem_gridlist_p = stem_gridlist();
ground.coordinates = [res.detection_lat, res.detection_lon];
obj_stem_grid = stem_grid(ground.coordinates, 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Model building     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

obj_stem_datestamp = stem_datestamp('01-01-2000 00:00', '01-01-2000 00:00', T);
obj_stem_modeltype = stem_modeltype('DCM');
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, ...
                          [], [], obj_stem_datestamp,[],obj_stem_modeltype);
%stem_par object creation
obj_stem_par = stem_par(obj_stem_data, 'exponential');
%stem_model object creation
obj_stem_model = stem_model(obj_stem_data, obj_stem_par);

%Starting values
obj_stem_par.theta_p = 30; %km
obj_stem_par.v_p = 1.0;
obj_stem_par.sigma_eps = 0.22;

obj_stem_model.set_initial_values(obj_stem_par);

%Model estimation
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations=100;
obj_stem_model.EM_estimate(obj_stem_EM_options);

step_deg=0.2; %deg
lat=90:-step_deg:-90;
lon=-180+step_deg/2:step_deg:180-step_deg/2;
[lon_mat,lat_mat]=meshgrid(lon,lat);

% deleting polar zones
idx=find(lat<-85|lat>85);
lat_mat(idx,:)=[];
lon_mat(idx,:)=[];

krig_coordinates=[lat_mat(:) lon_mat(:)];
obj_stem_krig_grid = stem_grid(krig_coordinates, 'deg', 'regular','pixel',size(lat_mat),'square',0.75,0.75);
X_krig=ones(length(krig_coordinates),1); 
X_krig_names={'constant'};
obj_stem_krig_data = stem_krig_data(obj_stem_krig_grid,X_krig,X_krig_names);
obj_stem_krig = stem_krig(obj_stem_model,obj_stem_krig_data);

obj_stem_krig_options = stem_krig_options();
obj_stem_krig_options.back_transform = 0;
obj_stem_krig_options.no_varcov = 1;
obj_stem_krig_options.block_size = 15000;

obj_stem_krig_result = obj_stem_krig.kriging(obj_stem_krig_options);

if magnitude_case==1
    obj_stem_krig_result1=obj_stem_krig_result;
    save obj_stem_krig_result1 obj_stem_krig_result1
elseif magnitude_case==2
    obj_stem_krig_result2=obj_stem_krig_result;
    save obj_stem_krig_result2 obj_stem_krig_result2
end

map=obj_stem_krig_result{1}.y_hat(:);
map_lat=obj_stem_krig_result{1,1}.stem_grid.coordinate(:,1);
map_lon=obj_stem_krig_result{1,1}.stem_grid.coordinate(:,2);
