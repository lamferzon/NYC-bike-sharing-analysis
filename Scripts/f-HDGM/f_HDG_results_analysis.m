
% Analysis of the results of the f-HDG model*

% Model 1: entire dataset
% Model 2: only feels-like temperature, distance and dummy variables
% Model 3: only feels-like temperature and dummy lockdown

clc
clearvars
warning off

%% Data loading

stem_model_L = load("..\..\Data\Outputs\f_HDG_model_1.mat");
stem_model_L = stem_model_L.o_model;
stem_model_M = load("..\..\Data\Outputs\f_HDG_model_3.mat");
stem_model_M = stem_model_M.o_model;
stem_model_S = load("..\..\Data\Outputs\f_HDG_model_2.mat");
stem_model_S = stem_model_S.o_model;
load ("..\..\Data\Processed data\Hourly_data.mat")
load ("..\..\Data\Processed data\Daily_data.mat")

%% Results extraction

for i = 1:3
    switch i
        case 1
            model = stem_model_L;
            m_type = "L";
        case 2
            model = stem_model_M;
            m_type = "M";
        case 3
            model = stem_model_S;
            m_type = "S";
    end
    % Model information

    mod.model_info.model_type = "f-HDG";
    mod.model_info.model_case = "univariate";
    mod.model_info.correlation_type = model.stem_par.correlation_type;
    mod.model_info.y_name = model.stem_data.stem_varset_p.Y_name{1,1};
    mod.model_info.num_profiles = size(model.stem_data.X_beta_name, 1);
    mod.model_info.num_stations = 51;
    mod.model_info.T = size(model.stem_data.X_beta, 1);
    
    % Spline parameters

    mod.spline_par.spline_type = model.stem_data.stem_fda.spline_type;
    mod.spline_par.num_basis_beta = model.stem_data.stem_fda.spline_nbasis_beta;
    mod.spline_par.num_basis_z = model.stem_data.stem_fda.spline_nbasis_z;
    mod.spline_par.num_basis_sigma_eps = model.stem_data.stem_fda.spline_nbasis_sigma;

    % Model parameters

    mod.model_par.X_beta_names = model.stem_data.stem_varset_p.X_beta_name{1,1};
    idx = 1;
    for j = 1:size(mod.model_par.X_beta_names, 1)
        mod.model_par.beta{j, 1} = model.stem_par.beta(idx:mod.spline_par.num_basis_beta*j);
        idx = mod.spline_par.num_basis_beta*j + 1;
    end
    chi2p = model.beta_Chi2_test;
    mod.model_par.beta_chi2_test_p_values = chi2p(2:end, 3);
    mod.model_par.varcov = model.stem_par.varcov;
    mod.model_par.G_diag = diag(model.stem_par.G);
    mod.model_par.sigma_eps = model.stem_par.sigma_eps;
    mod.model_par.theta_z = model.stem_par.theta_z;
    mod.model_par.V_z_diag = diag(model.stem_par.v_z);

    % Model validation
    num_val_stations = size(model.stem_data.stem_validation.stem_gridlist{1,3}.grid{1,1}.coordinate, 1);
    val_coord = model.stem_data.stem_validation.stem_gridlist{1,3}.grid{1,1}.coordinate;
    val_id = zeros(num_val_stations, 1);
    for j = 1:num_val_stations
        Y_coord = hourly_data.Y_coordinate;
        idx = find(Y_coord == val_coord(j,1));
        idx = idx(1,1);
        val_id(j, 1) = idx;
    end
    val_stations = table(val_id, val_coord(:,1), val_coord(:,2));
    val_stations.Properties.VariableNames = ["Id", "Lat", "Lon"];
    mod.model_val.val_stations = val_stations;
    y_back = model.stem_validation_result.y_back;
    y_back_hat = model.stem_validation_result.y_hat_back;
    % t
    [MSE_t, RMSE_t, MAPE_t] = idxCalculator(y_back, y_back_hat, "t", 0);
    [MSE_t_round, RMSE_t_round, MAPE_t_round] = idxCalculator(y_back, y_back_hat, "t", 1);
    mod.model_val.t_domain.MSE_t = MSE_t;
    mod.model_val.t_domain.MSE_t_round = MSE_t_round;
    mod.model_val.t_domain.RMSE_t = RMSE_t;
    mod.model_val.t_domain.RMSE_t_round = RMSE_t_round;
    mod.model_val.t_domain.MAPE_t = MAPE_t;
    mod.model_val.t_domain.MAPE_t_round = MAPE_t_round;
    mod.model_val.t_domain.R2_t = model.stem_validation_result.cv_R2_t;
    mod.model_val.t_domain.summary_t = resTableCreator(mod.model_val.t_domain, "t");
    % h
    [MSE_h, RMSE_h, MAPE_h] = idxCalculator(y_back, y_back_hat, "h", 0);
    [MSE_h_round, RMSE_h_round, MAPE_h_round] = idxCalculator(y_back, y_back_hat, "h", 1);
    mod.model_val.h_domain.MSE_h = MSE_h;
    mod.model_val.h_domain.MSE_h_round = MSE_h_round;
    mod.model_val.h_domain.RMSE_h = RMSE_h;
    mod.model_val.h_domain.RMSE_h_round = RMSE_h_round;
    mod.model_val.h_domain.MAPE_h = MAPE_h;
    mod.model_val.h_domain.MAPE_h_round = MAPE_h_round;
    mod.model_val.h_domain.R2_h = model.stem_validation_result.cv_R2_h;
    mod.model_val.h_domain.summary_h = resTableCreator(mod.model_val.h_domain, "h");
    % s
    [MSE_s, RMSE_s, MAPE_s] = idxCalculator(y_back, y_back_hat, "s", 0);
    [MSE_s_round, RMSE_s_round, MAPE_s_round] = idxCalculator(y_back, y_back_hat, "s", 1);
    mod.model_val.s_domain.MSE_s = MSE_s;
    mod.model_val.s_domain.MSE_s_round = MSE_s_round;
    mod.model_val.s_domain.RMSE_s = RMSE_s;
    mod.model_val.s_domain.RMSE_s_round = RMSE_s_round;
    mod.model_val.s_domain.MAPE_s = MAPE_s;
    mod.model_val.s_domain.MAPE_s_round = MAPE_s_round;
    mod.model_val.s_domain.R2_s = model.stem_validation_result.cv_R2_s;
    mod.model_val.s_domain.summary_s = resTableCreator(mod.model_val.s_domain, "s");

    switch i
        case 1
            f_HDG_results.model_L = mod;
        case 2
            f_HDG_results.model_M = mod;
        case 3
            f_HDG_results.model_S = mod;
    end
    
    % Trend of beta 

    t = model.plot_par;
    file_name = "Trend_beta_" + m_type + ".pdf";
    if i == 2
        path = "..\..\Paper\Images\Data analysis\f-HDGM\Chosen\";
    else
        path = "..\..\Paper\Images\Data analysis\f-HDGM\Beta trends\";
    end

    % exportgraphics(t, path + file_name, 'BackgroundColor', 'none');
    
    % Plots concerning the model validation

    t = tiledlayout(2, 1, 'TileSpacing', 'Compact', 'Padding', 'Compact');
    nexttile
    plot(0:1:23, mod.model_val.h_domain.RMSE_h, 'Color', "#4DBEEE")
    xlim([0 23])
    ylim([0 3])
    hold on
    plot(0:1:23, mod.model_val.h_domain.RMSE_h_round, 'LineStyle', ':', 'LineWidth', 1,...
        'Color', "#4DBEEE")
    axis = gca;
    axis.XGrid = 'on';
    axis.XAxis.TickLabelInterpreter = 'latex';
    axis.YAxis.TickLabelInterpreter = 'latex';
    ylabel("RMSE$_h$", 'Interpreter', 'latex')
    xlabel("Hour", 'Interpreter', 'latex')

    yyaxis right
    plot(0:1:23, mod.model_val.h_domain.MSE_h, 'Color', "#D95319")
    xlim([0 23])
    hold on
    plot(0:1:23, mod.model_val.h_domain.MSE_h_round, 'LineStyle', ':', 'LineWidth', 1,...
        'Color', "#D95319")
    axis = gca;
    axis.YAxis(2,1).TickLabelInterpreter = 'latex';
    axis.YColor = "#D95319";
    ylabel("MSE$_h$", 'Interpreter', 'latex')
    legend("No rounding", "Rounding", "", "", 'Interpreter', 'latex', 'Location', 'northwest')

    nexttile
    winter_RMSE = mod.model_val.t_domain.RMSE_t(1:day(datetime(2020,3,21), "dayofyear"));
    winter_RMSE_plot = [winter_RMSE; NaN(366 - size(winter_RMSE, 1), 1)];
    lockdown_RMSE = mod.model_val.t_domain.RMSE_t(day(datetime(2020,3,22), "dayofyear"):day(datetime(2020,5,14), "dayofyear"));
    lockdown_RMSE_plot = [NaN(size(winter_RMSE, 1), 1); lockdown_RMSE; NaN(366 - size(lockdown_RMSE, 1) - size(winter_RMSE, 1), 1)];
    summer_RMSE = mod.model_val.t_domain.RMSE_t(day(datetime(2020,5,15), "dayofyear"):day(datetime(2020,9,21), "dayofyear"));
    summer_RMSE_plot = [NaN(size(winter_RMSE,1) + size(lockdown_RMSE,1), 1); summer_RMSE; NaN(366 - size(summer_RMSE, 1) - size(winter_RMSE,1) - size(lockdown_RMSE,1), 1)];
    autumn_RMSE = mod.model_val.t_domain.RMSE_t(day(datetime(2020,9,22), "dayofyear"):day(datetime(2020,12,31), "dayofyear"));
    autumn_RMSE_plot = [NaN(366 - size(autumn_RMSE, 1), 1); autumn_RMSE];
    plot(daily_data.datetime_calendar, winter_RMSE_plot, 'Color', "#D95319")
    hold on
    plot(daily_data.datetime_calendar, lockdown_RMSE_plot, 'Color', "#77AC30")
    plot(daily_data.datetime_calendar, summer_RMSE_plot, 'Color', "#EDB120")
    plot(daily_data.datetime_calendar, autumn_RMSE_plot, 'Color', "#7E2F8E")
    xlim([daily_data.datetime_calendar(1,1) daily_data.datetime_calendar(1,366)])
    axis = gca;
    axis.XGrid = 'on';
    axis.XAxis.TickLabelInterpreter = 'latex';
    axis.YAxis.TickLabelInterpreter = 'latex';
    ylabel("RMSE$_t$", 'Interpreter', 'latex')
    xlabel("Day", 'Interpreter', 'latex')
    yline(mean(winter_RMSE), '--', 'Color', "#D95319", 'Interpreter', 'latex', 'LineWidth', 1)
    yline(mean(lockdown_RMSE), '--', 'Color', "#77AC30", 'LineWidth', 1, 'Interpreter', 'latex')
    yline(mean(summer_RMSE), 'Color', "#EDB120", 'LineStyle', '--', 'LineWidth', 1)
    yline(mean(autumn_RMSE), 'Color', "#7E2F8E", 'LineStyle', '--', 'LineWidth', 1)
    legend("", "", "", "", "Mean winter", "Mean lockdown", "Mean summer",...
        "Mean autumn", 'Interpreter', 'latex', 'NumColumns', 4, 'Location', 'south')
    
    if i == 2
        path = "..\..\Paper\Images\Data analysis\f-HDGM\Chosen\";
    else
        path = "..\..\Paper\Images\Data analysis\f-HDGM\Validation\";
    end
    file_name = "RMSE_" + m_type + ".pdf";
    
    % exportgraphics(t, path + file_name, 'BackgroundColor', 'none');
end

% save("..\..\Results\f_HDGM_results", "f_HDG_results");

%% Profiles plotting

lat0 = 40.7184; 
lon0 = -74.0389;
t_start = day(datetime(2020, 7, 1),"dayofyear");
t_end = day(datetime(2020, 7, 30),"dayofyear");
stem_model_M.plot_profile(lat0, lon0, t_start, t_end);

%% Functions

function [MSE, RMSE, MAPE] = idxCalculator(y, y_hat, domain, roundYoN)
    T = size(y{1,1}, 2);
    H = size(y, 1);
    S = size(y{1,1}, 1);
    if roundYoN == 1
        for i = 1:H
            y_hat{i,1} = round(y_hat{i,1});
        end
    end
    switch domain
        case "t"
            MSE = zeros(T, 1);
            RMSE = zeros(T, 1);
            MAPE = zeros(T, 1);
            for t = 1:T
                sum1 = 0;
                sum2 = 0;
                for s = 1:S
                    for h = 1:H
                        sum1 = sum1 + (y{h,1}(s,t) - y_hat{h,1}(s,t))^2;
                        if y{h,1}(s,t) == 0
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/1);
                        else
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/y{h,1}(s,t));
                        end
                    end
                end
                MSE(t, 1) = sum1/(H*S);
                RMSE(t, 1) = sqrt(sum1/(H*S));
                MAPE(t, 1) = (sum2/(H*S))*100;
            end
        case "h"
            MSE = zeros(H, 1);
            RMSE = zeros(H, 1);
            MAPE = zeros(H, 1);
            for h = 1:H
                sum1 = 0;
                sum2 = 0;
                for t = 1:T
                    for s = 1:S
                        sum1 = sum1 + (y{h,1}(s,t) - y_hat{h,1}(s,t))^2;
                        if y{h,1}(s,t) == 0
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/1);
                        else
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/y{h,1}(s,t));
                        end
                    end
                end
                MSE(h, 1) = sum1/(T*S);
                RMSE(h, 1) = sqrt(sum1/(T*S));
                MAPE(h, 1) = (sum2/(T*S))*100;
            end
        case "s"
            MSE = zeros(S, 1);
            RMSE = zeros(S, 1);
            MAPE = zeros(S, 1);
            for s = 1:S
                sum1 = 0;
                sum2 = 0;
                for t = 1:T
                    for h = 1:H
                        sum1 = sum1 + (y{h,1}(s,t) - y_hat{h,1}(s,t))^2;
                        if y{h,1}(s,t) == 0
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/1);
                        else
                            sum2 = sum2 + abs((y{h,1}(s,t) - y_hat{h,1}(s,t))/y{h,1}(s,t));
                        end
                    end
                end
                MSE(s, 1) = sum1/(T*H);
                RMSE(s, 1) = sqrt(sum1/(T*H));
                MAPE(s, 1) = (sum2/(T*H))*100;
            end
    end
end

function [res_table] = resTableCreator(struct, choice)
    res_table = array2table(zeros(6, 10));
    res_table.Properties.VariableNames = ["Val_index", "Min", "Q1", "Mean", "Median", "Q3",...
        "Max", "Std", "Skewness", "Kurtosis"];
    idx_names = ['MSE_' + choice; 'MSE_' + choice + '_round';...
        'RMSE_' + choice; 'RMSE_' + choice + '_round';...
        'MAPE_' + choice; 'MAPE_' + choice + '_round'];
    res_table.Val_index = idx_names;
    for i = 1:6
        data = getfield(struct, idx_names(i,1));
        res_table.Min(i) = round(min(data), 2);
        res_table.Q1(i) = round(prctile(data, 25), 2);
        res_table.Mean(i) = round(mean(data), 2);
        res_table.Median(i) = round(prctile(data, 50), 2);
        res_table.Q3(i) = round(prctile(data, 75), 2);
        res_table.Max(i) = round(max(data), 2);
        res_table.Std(i) = round(std(data), 2);
        res_table.Skewness(i) = round(skewness(data), 2);
        res_table.Kurtosis(i) = round(kurtosis(data), 2);
    end
end