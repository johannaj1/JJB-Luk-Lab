%% importing the data into MATLAB as individual sheets per dilution and species
cd('/Users/johannab/Documents/Penn 2nd year/Luk Lab/Projects/Food project/SAA of brain lysate w chicken monomer/round 6 (chicken IP)/');
% modify the directory above and/or the sheets created below as needed;
% make sure to replace sheet names later in code if modified!! and modify
% sheet numbers if not starting from 1st sheet!!
% Also: change rep #s if using something other than 3 replicates

mono_ft_211_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 2);
mono_ft_211_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 3);
mono_el_211_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 4);
mono_el_211_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 5);
mono_211 = {mono_ft_211_neat, mono_ft_211_diluted,mono_el_211_neat, mono_el_211_diluted};
mono_211_names = {'mono ft 211 neat', 'mono ft 211 diluted', 'mono el 211 neat', 'mono el 211 diluted'};


mono_ft_9027_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 6);
mono_ft_9027_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 7);
mono_el_9027_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 8);
mono_el_9027_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 9);
mono_9027 = {mono_ft_9027_neat, mono_ft_9027_diluted, mono_el_9027_neat, mono_el_9027_diluted};
mono_9027_names = {'mono ft 9027 neat', 'mono ft 9027 diluted', 'mono el 9027 neat', 'mono el 9027 diluted'};


homo_ft_211_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 10);
homo_ft_211_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 11);
homo_el_211_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 12);
homo_el_211_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 13);
homo_211 = {homo_ft_211_neat, homo_ft_211_diluted, homo_el_211_neat, homo_el_211_diluted};
homo_211_names = {'homo ft 211 neat', 'homo ft 211 diluted', 'homo el 211 neat', 'homo el 211 diluted'};

homo_ft_9027_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 14);
homo_ft_9027_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 15);
homo_el_9027_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 16);
homo_el_9027_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 17);
homo_9027 = {homo_ft_9027_neat, homo_ft_9027_diluted, homo_el_9027_neat, homo_el_9027_diluted};
homo_9027_names = {'homo ft 9027 neat', 'homo ft 9027 diluted', 'homo el 9027 neat', 'homo el 9027 diluted'};

homo_neat = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 18);
homo_diluted = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 19);
homo = {homo_neat, homo_diluted};
homo_names = {'homo neat', 'homo diluted'};

mono_only = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 20);
master_mix_only = readtable('SAA_chk_brain_ip_111125.xlsx', 'Sheet', 21);
controls = {mono_only, master_mix_only};
control_names = {'mono only', 'master mix only'};

%% graphing mono_211

for i = 1:length(mono_211)
    currentData = mono_211{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([mono_211_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of mono_211
mono_211_curves = cell(4,4);
mono_211_gof = cell(4,4);
for array_index = 1:4
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(mono_211{array_index}.Time_hours(2:end), ...
                                           table2array(mono_211{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                mono_211_curves{array_index, rep - 1} = fit_result;
                mono_211_gof{array_index, rep - 1} = gof_result;
            else
                mono_211_curves{array_index, rep - 1} = NaN;
                mono_211_gof{array_index, rep - 1} = NaN;
            end
        catch
            mono_211_curves{array_index, rep - 1} = NaN;
            mono_211_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of mono_211
for array_index = 1:4
    for rep = 2:5
        fit_result = mono_211_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            mono_211_t50(array_index, rep - 1) = NaN;
            mono_211_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(mono_211{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(mono_211{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                mono_211_t50(array_index, rep - 1) = t50;
            else
                mono_211_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                mono_211_lagtime(array_index, rep - 1) = lagtime;
            else
                mono_211_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for mono_211
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:4
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = mono_211{1}.Time_hours;
        yData = table2array(mono_211{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(mono_211_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(mono_211_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end

%% graphing mono_9027

for i = 1:length(mono_9027)
    currentData = mono_9027{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([mono_9027_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of mono_9027
mono_9027_curves = cell(4,4);
mono_9027_gof = cell(4,4);
for array_index = 1:4
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(mono_9027{array_index}.Time_hours(2:end), ...
                                           table2array(mono_9027{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                mono_9027_curves{array_index, rep - 1} = fit_result;
                mono_9027_gof{array_index, rep - 1} = gof_result;
            else
                mono_9027_curves{array_index, rep - 1} = NaN;
                mono_9027_gof{array_index, rep - 1} = NaN;
            end
        catch
            mono_9027_curves{array_index, rep - 1} = NaN;
            mono_9027_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of mono_9027
for array_index = 1:4
    for rep = 2:5
        fit_result = mono_9027_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            mono_9027_t50(array_index, rep - 1) = NaN;
            mono_9027_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(mono_9027{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(mono_9027{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                mono_9027_t50(array_index, rep - 1) = t50;
            else
                mono_9027_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                mono_9027_lagtime(array_index, rep - 1) = lagtime;
            else
                mono_9027_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for mono_9027
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:4
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = mono_9027{1}.Time_hours;
        yData = table2array(mono_9027{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(mono_9027_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(mono_9027_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end

%% graphing homo_211

for i = 1:length(homo_211)
    currentData = homo_211{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([homo_211_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of homo_211
homo_211_curves = cell(4,4);
homo_211_gof = cell(4,4);
for array_index = 1:4
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(homo_211{array_index}.Time_hours(2:end), ...
                                           table2array(homo_211{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                homo_211_curves{array_index, rep - 1} = fit_result;
                homo_211_gof{array_index, rep - 1} = gof_result;
            else
                homo_211_curves{array_index, rep - 1} = NaN;
                homo_211_gof{array_index, rep - 1} = NaN;
            end
        catch
            homo_211_curves{array_index, rep - 1} = NaN;
            homo_211_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of homo_211
for array_index = 1:4
    for rep = 2:5
        fit_result = homo_211_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            homo_211_t50(array_index, rep - 1) = NaN;
            homo_211_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(homo_211{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(homo_211{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                homo_211_t50(array_index, rep - 1) = t50;
            else
                homo_211_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                homo_211_lagtime(array_index, rep - 1) = lagtime;
            else
                homo_211_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for homo_211
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:4
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = homo_211{1}.Time_hours;
        yData = table2array(homo_211{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(homo_211_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(homo_211_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end

%% graphing homo_9027

for i = 1:length(homo_9027)
    currentData = homo_9027{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([homo_9027_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of homo_9027
homo_9027_curves = cell(4,4);
homo_9027_gof = cell(4,4);
for array_index = 1:4
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(homo_9027{array_index}.Time_hours(2:end), ...
                                           table2array(homo_9027{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                homo_9027_curves{array_index, rep - 1} = fit_result;
                homo_9027_gof{array_index, rep - 1} = gof_result;
            else
                homo_9027_curves{array_index, rep - 1} = NaN;
                homo_9027_gof{array_index, rep - 1} = NaN;
            end
        catch
            homo_9027_curves{array_index, rep - 1} = NaN;
            homo_9027_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of homo_9027
for array_index = 1:4
    for rep = 2:5
        fit_result = homo_9027_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            homo_9027_t50(array_index, rep - 1) = NaN;
            homo_9027_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(homo_9027{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(homo_9027{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                homo_9027_t50(array_index, rep - 1) = t50;
            else
                homo_9027_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                homo_9027_lagtime(array_index, rep - 1) = lagtime;
            else
                homo_9027_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for homo_9027
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:4
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = homo_9027{1}.Time_hours;
        yData = table2array(homo_9027{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(homo_9027_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(homo_9027_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end
%% graphing homo

for i = 1:length(homo)
    currentData = homo{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([homo_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of homo
homo_curves = cell(2,4);
homo_gof = cell(2,4);
for array_index = 1:2
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(homo{array_index}.Time_hours(2:end), ...
                                           table2array(homo{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                homo_curves{array_index, rep - 1} = fit_result;
                homo_gof{array_index, rep - 1} = gof_result;
            else
                homo_curves{array_index, rep - 1} = NaN;
                homo_gof{array_index, rep - 1} = NaN;
            end
        catch
            homo_curves{array_index, rep - 1} = NaN;
            homo_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of homo
for array_index = 1:2
    for rep = 2:5
        fit_result = homo_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            homo_t50(array_index, rep - 1) = NaN;
            homo_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(homo{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(homo{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                homo_t50(array_index, rep - 1) = t50;
            else
                homo_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                homo_lagtime(array_index, rep - 1) = lagtime;
            else
                homo_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for homo
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:2
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = homo{1}.Time_hours;
        yData = table2array(homo{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(homo_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(homo_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end

%% graphing controls

for i = 1:length(controls)
    currentData = controls{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;

    subplot(2, 2, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 4');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title([control_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3', 'Replicate 4', 'Location', 'northeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of controls
control_curves = cell(2,4);
control_gof = cell(2,4);
for array_index = 1:2
    for rep = 2:5
        try
            [fit_result, gof_result] = fit(controls{array_index}.Time_hours(2:end), ...
                                           table2array(controls{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.01
                control_curves{array_index, rep - 1} = fit_result;
                control_gof{array_index, rep - 1} = gof_result;
            else
                control_curves{array_index, rep - 1} = NaN;
                control_gof{array_index, rep - 1} = NaN;
            end
        catch
            control_curves{array_index, rep - 1} = NaN;
            control_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of controls
for array_index = 1:2
    for rep = 2:5
        fit_result = control_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            control_t50(array_index, rep - 1) = NaN;
            control_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(controls{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(controls{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0 && t50 < 100
                control_t50(array_index, rep - 1) = t50;
            else
                control_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0 && lagtime < 100
                control_lagtime(array_index, rep - 1) = lagtime;
            else
                control_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for controls
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0], [1,0.690,0]};

for array_index = 1:2
    fig = figure;
    hold on;
    grid on;
    for rep = 2:5
        xData = controls{1}.Time_hours;
        yData = table2array(controls{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(control_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(control_names{array_index});
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3', 'Replicate 4', 'Sigmoidal fit of rep. 4'},'Location', 'northeast');

    xlim([min(xData) max(xData)]);
    ylim([0 300000]);
end
%% plot t50 values
figure;

%mono_211 graph
x = 1:length(mono_211_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 1);
b1 = bar(x, mean(mono_211_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(mono_211_names)
    y = mono_211_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', mono_211_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(mono_211_t50, 2, 'omitnan'), (std(mono_211_t50, 0, 2) / sqrt(size(mono_211_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Chicken monomer IPed with 211')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%mono_9027 graph
x = 1:length(mono_9027_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 2);
b1 = bar(x, mean(mono_9027_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(mono_9027_names)
    y = mono_9027_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', mono_9027_names);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(mono_9027_t50, 2, 'omitnan'), (std(mono_9027_t50, 0, 2) / sqrt(size(mono_9027_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Chicken monomer IPed with 9027')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%homo_211 graph
x = 1:length(homo_211_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 4);
b1 = bar(x, mean(homo_211_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(homo_211_names)
    y = homo_211_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_211_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_211_t50, 2, 'omitnan'), (std(homo_211_t50, 0, 2) / sqrt(size(homo_211_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Chicken brain homogenate IPed with 211')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%homo_9027 graph
x = 1:length(homo_9027_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 5);
b1 = bar(x, mean(homo_9027_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(homo_9027_names)
    y = homo_9027_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_9027_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_9027_t50, 2, 'omitnan'), (std(homo_9027_t50, 0, 2) / sqrt(size(homo_9027_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Chicken brain homogenate IPed with 9027')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%homo graph
x = 1:length(homo_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 3);
b1 = bar(x, mean(homo_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors(1:2,1:3);
hold on;

for i = 1:length(homo_names)
    y = homo_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_t50, 2, 'omitnan'), (std(homo_t50, 0, 2) / sqrt(size(homo_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Chicken brain homogenate non-IPed')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

% control graph
subplot(2, 3, 6);
b1 = bar(x, mean(control_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors(1:2,1:3);
hold on;

for i = 1:length(control_names)
    y = control_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', control_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(control_t50, 2, 'omitnan'), (std(control_t50, 0, 2) / sqrt(size(control_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Controls')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;
%% plot lag times
figure;

%mono_211 graph
x = 1:length(mono_211_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 1);
b1 = bar(x, mean(mono_211_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(mono_211_names)
    y = mono_211_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', mono_211_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(mono_211_lagtime, 2, 'omitnan'), (std(mono_211_lagtime, 0, 2) / sqrt(size(mono_211_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Chicken monomer IPed with 211')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

%mono_9027 graph
x = 1:length(mono_9027_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 2);
b1 = bar(x, mean(mono_9027_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(mono_9027_names)
    y = mono_9027_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', mono_9027_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(mono_9027_lagtime, 2, 'omitnan'), (std(mono_9027_lagtime, 0, 2) / sqrt(size(mono_9027_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Chicken monomer IPed with 9027')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

%homo_211 graph
x = 1:length(homo_211_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 4);
b1 = bar(x, mean(homo_211_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(homo_211_names)
    y = homo_211_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_211_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_211_lagtime, 2, 'omitnan'), (std(homo_211_lagtime, 0, 2) / sqrt(size(homo_211_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Chicken brain homogenate IPed with 211')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

%homo_9027 graph
x = 1:length(homo_9027_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 5);
b1 = bar(x, mean(homo_9027_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(homo_9027_names)
    y = homo_9027_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_9027_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_9027_lagtime, 2, 'omitnan'), (std(homo_9027_lagtime, 0, 2) / sqrt(size(homo_9027_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Chicken brain homogenate IPed with 9027')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

%homo graph
x = 1:length(homo_names);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
];


subplot(2, 3, 3);
b1 = bar(x, mean(homo_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors(1:2,1:3);
hold on;

for i = 1:length(homo_names)
    y = homo_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', homo_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(homo_lagtime, 2, 'omitnan'), (std(homo_lagtime, 0, 2) / sqrt(size(homo_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Chicken brain homogenate non-IPed')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

% control graph
subplot(2, 3, 6);
b1 = bar(x, mean(control_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors(1:2,1:3);
hold on;

for i = 1:length(control_names)
    y = control_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', control_names);
xtickangle(45);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(control_lagtime, 2, 'omitnan'), (std(control_lagtime, 0, 2) / sqrt(size(control_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Controls')
subtitle('Time to reach 10% max fluorescence (Lag time)');
hold off;

%% Perform Kruskal-Wallis test for T50

t50_for_kw = [mono_211_t50(1,:)', mono_9027_t50(1,:)', homo_211_t50(1,:)', homo_9027_t50(1,:)', homo_t50(1,:)', control_t50(1,:)'];

[p_t50, tbl_t50, stats_t50] = kruskalwallis(t50_for_kw);

H_t50 = tbl_t50{2, 5};
N_t50 = size(t50_for_kw,1)*size(t50_for_kw,2);
cohens_h_t50 = H_t50 / (N_t50 - 1);

fprintf('Kruskal-Wallis H statistic: %.4f\n', H_t50);
fprintf('Cohen''s h: %.4f\n', cohens_h_t50);

disp(['p-value: ', num2str(p_t50)]);
disp('ANOVA table:');
disp(tbl_t50);


%% Perform Kruskal-Wallis test for lag time

lagtime_for_kw = [mono_211_lagtime(1,:)', mono_9027_lagtime(1,:)', homo_211_lagtime(1,:)', homo_9027_lagtime(1,:)', homo_lagtime(1,:)', control_lagtime(1,:)'];

[p_lagtime, tbl_lagtime, stats_lagtime] = kruskalwallis(lagtime_for_kw);

H_lagtime = tbl_lagtime{2, 5};
N_lagtime = size(lagtime_for_kw,1)*size(lagtime_for_kw,2);
cohens_h_lagtime = H_lagtime / (N_lagtime - 1);

fprintf('Kruskal-Wallis H statistic: %.4f\n', H_lagtime);
fprintf('Cohen''s h: %.4f\n', cohens_h_lagtime);

disp(['p-value: ', num2str(p_lagtime)]);
disp('ANOVA table:');
disp(tbl_lagtime);