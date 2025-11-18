%% importing the data into MATLAB as individual sheets per dilution and species
cd('/Users/johannab/Documents/Penn 2nd year/Luk Lab/Projects/Food project/Second round SAA w dilution series PFF/8-21-25 (second try)')
% modify the directory above and/or the sheets created below as needed;
% make sure to replace sheet names later in code if modified!! and modify
% sheet numbers if not starting from 1st sheet!!
% Also: change rep #s if using something other than 3 replicates

huPFF_1e2 = readtable('individual_replicates_082125.xlsx', 'Sheet', 1);
huPFF_1e3 = readtable('individual_replicates_082125.xlsx', 'Sheet', 2);
huPFF_1e4 = readtable('individual_replicates_082125.xlsx', 'Sheet', 3);
huPFF_1e5 = readtable('individual_replicates_082125.xlsx', 'Sheet', 4);
huPFF_1e6 = readtable('individual_replicates_082125.xlsx', 'Sheet', 5);
huPFF = {huPFF_1e2, huPFF_1e3, huPFF_1e4, huPFF_1e5, huPFF_1e6};


chPFF_1e2 = readtable('individual_replicates_082125.xlsx', 'Sheet', 6);
chPFF_1e3 = readtable('individual_replicates_082125.xlsx', 'Sheet', 7);
chPFF_1e4 = readtable('individual_replicates_082125.xlsx', 'Sheet', 8);
chPFF_1e5 = readtable('individual_replicates_082125.xlsx', 'Sheet', 9);
chPFF_1e6 = readtable('individual_replicates_082125.xlsx', 'Sheet', 10);
chPFF = {chPFF_1e2, chPFF_1e3, chPFF_1e4, chPFF_1e5, chPFF_1e6};

pgPFF_1e2 = readtable('individual_replicates_082125.xlsx', 'Sheet', 11);
pgPFF_1e3 = readtable('individual_replicates_082125.xlsx', 'Sheet', 12);
pgPFF_1e4 = readtable('individual_replicates_082125.xlsx', 'Sheet', 13);
pgPFF_1e5 = readtable('individual_replicates_082125.xlsx', 'Sheet', 14);
pgPFF_1e6 = readtable('individual_replicates_082125.xlsx', 'Sheet', 15);
pgPFF = {pgPFF_1e2, pgPFF_1e3, pgPFF_1e4, pgPFF_1e5, pgPFF_1e6};

cwPFF_1e2 = readtable('individual_replicates_082125.xlsx', 'Sheet', 16);
cwPFF_1e3 = readtable('individual_replicates_082125.xlsx', 'Sheet', 17);
cwPFF_1e4 = readtable('individual_replicates_082125.xlsx', 'Sheet', 18);
cwPFF_1e5 = readtable('individual_replicates_082125.xlsx', 'Sheet', 19);
cwPFF_1e6 = readtable('individual_replicates_082125.xlsx', 'Sheet', 20);
cwPFF = {cwPFF_1e2, cwPFF_1e3, cwPFF_1e4, cwPFF_1e5, cwPFF_1e6};

msPFF_1e2 = readtable('individual_replicates_082125.xlsx', 'Sheet', 21);
msPFF_1e3 = readtable('individual_replicates_082125.xlsx', 'Sheet', 22);
msPFF_1e4 = readtable('individual_replicates_082125.xlsx', 'Sheet', 23);
msPFF_1e5 = readtable('individual_replicates_082125.xlsx', 'Sheet', 24);
msPFF_1e6 = readtable('individual_replicates_082125.xlsx', 'Sheet', 25);
msPFF = {msPFF_1e2, msPFF_1e3, msPFF_1e4, msPFF_1e5, msPFF_1e6};

negcntrl = readtable('individual_replicates_082125.xlsx', 'Sheet', 26);

PFF_names = {'(0.01 mg/mL)', '(10x dilution)', '(100x dilution)', '(1,000x dilution)', '(10,000x dilution)'};

%% graphing huPFF at different dilutions
for i = 1:length(huPFF)
    currentData = huPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;

    subplot(length(huPFF), 3, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3'); % Scatter plot for rep3
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Human PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'southeast')
    grid on;
 end

%% Fit a sigmoidal model for each replicate of each huPFF dilution
hu_PFF_curves = cell(5,3);
hu_PFF_gof = cell(5,3);
for array_index = 1:5
    for rep = 2:4
        try
            [fit_result, gof_result] = fit(huPFF{array_index}.Time_hours(2:end), ...
                                           table2array(huPFF{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.9
                hu_PFF_curves{array_index, rep - 1} = fit_result;
                hu_PFF_gof{array_index, rep - 1} = gof_result;
            else
                hu_PFF_curves{array_index, rep - 1} = NaN;
                hu_PFF_gof{array_index, rep - 1} = NaN;
            end
        catch
            hu_PFF_curves{array_index, rep - 1} = NaN;
            hu_PFF_gof{array_index, rep - 1} = NaN;
        end
    end
end
%% Calculate the T50 and lag time values for each replicate of each huPFF dilution
for array_index = 1:5
    for rep = 2:4
        fit_result = hu_PFF_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            hu_PFF_t50(array_index, rep - 1) = NaN;
            hu_PFF_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(huPFF{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(huPFF{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                hu_PFF_t50(array_index, rep - 1) = t50;
            else
                hu_PFF_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                hu_PFF_lagtime(array_index, rep - 1) = lagtime;
            else
                hu_PFF_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for huPFF
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4
        xData = huPFF{1}.Time_hours;
        yData = table2array(huPFF{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(hu_PFF_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Human PFF ', PFF_names{array_index}]);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'},'Location', 'southeast');

    xlim([min(xData) max(xData)]);
end


%% graphing chPFF at different dilutions
for i = 1:length(chPFF)
    currentData = chPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;

    subplot(length(chPFF), 3, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3'); % Scatter plot for rep3
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Chicken PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'southeast')
    grid on;
 end


%% Fit a sigmoidal model for each replicate of each chPFF dilution
clear [fit_result, gof_result]
for array_index = 1:5
    for rep = 2:4
        try
            [fit_result, gof_result] = fit(chPFF{array_index}.Time_hours(2:end), ...
                                           table2array(chPFF{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.9
                ch_PFF_curves{array_index, rep - 1} = fit_result;
                ch_PFF_gof{array_index, rep - 1} = gof_result;
            else
                ch_PFF_curves{array_index, rep - 1} = NaN;
                ch_PFF_gof{array_index, rep - 1} = NaN;
            end
        catch
            ch_PFF_curves{array_index, rep - 1} = NaN;
            ch_PFF_gof{array_index, rep - 1} = NaN;
        end
    end
end

%% Calculate the T50 and lag time values for each replicate of each chPFF dilution
for array_index = 1:5
    for rep = 2:4
        fit_result = ch_PFF_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            ch_PFF_t50(array_index, rep - 1) = NaN;
            ch_PFF_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(chPFF{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(chPFF{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                ch_PFF_t50(array_index, rep - 1) = t50;
            else
                ch_PFF_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                ch_PFF_lagtime(array_index, rep - 1) = lagtime;
            else
                ch_PFF_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end


%% Plot the results for chPFF
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4
       
        xData = chPFF{1}.Time_hours;
        yData = table2array(chPFF{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(ch_PFF_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Chicken PFF ', PFF_names{array_index}]);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'},'Location', 'northwest');
    xlim([min(xData) max(xData)]);
end

%% graphing pgPFF at different dilutions
for i = 1:length(pgPFF)
    currentData = pgPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;

    subplot(length(pgPFF), 3, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3'); % Scatter plot for rep3
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Pig PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'southeast')
    grid on;
 end


%% Fit a sigmoidal model for each replicate of each pgPFF dilution
clear [fit_result, gof_result]
for array_index = 1:5
    for rep = 2:4
        try
            [fit_result, gof_result] = fit(pgPFF{array_index}.Time_hours(2:end), ...
                                           table2array(pgPFF{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.9
                pg_PFF_curves{array_index, rep - 1} = fit_result;
                pg_PFF_gof{array_index, rep - 1} = gof_result;
            else
                pg_PFF_curves{array_index, rep - 1} = NaN;
                pg_PFF_gof{array_index, rep - 1} = NaN;
            end
        catch
            pg_PFF_curves{array_index, rep - 1} = NaN;
            pg_PFF_gof{array_index, rep - 1} = NaN;
        end
    end
end

%% Calculate the T50 and lag time values for each replicate of each pgPFF dilution
for array_index = 1:5
    for rep = 2:4
        fit_result = pg_PFF_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            pg_PFF_t50(array_index, rep - 1) = NaN;
            pg_PFF_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(pgPFF{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(pgPFF{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                pg_PFF_t50(array_index, rep - 1) = t50;
            else
                pg_PFF_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                pg_PFF_lagtime(array_index, rep - 1) = lagtime;
            else
                pg_PFF_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for pgPFF
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4
       
        xData = pgPFF{1}.Time_hours;
        yData = table2array(pgPFF{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(pg_PFF_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Pig PFF ', PFF_names{array_index}]);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'}, 'Location', 'northwest');
    xlim([0 max(xData)]);
    ylim([0 300000])
end

%% graphing cwPFF at different dilutions
for i = 1:length(cwPFF)
    currentData = cwPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;

    subplot(length(cwPFF), 3, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3'); % Scatter plot for rep3
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Cow PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'southeast')
    grid on;
 end


%% Fit a sigmoidal model for each replicate of each cwPFF dilution
clear [fit_result, gof_result]
for array_index = 1:5
    for rep = 2:4
        try
            [fit_result, gof_result] = fit(cwPFF{array_index}.Time_hours(2:end), ...
                                           table2array(cwPFF{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.9
                cw_PFF_curves{array_index, rep - 1} = fit_result;
                cw_PFF_gof{array_index, rep - 1} = gof_result;
            else
                cw_PFF_curves{array_index, rep - 1} = NaN;
                cw_PFF_gof{array_index, rep - 1} = NaN;
            end
        catch
            cw_PFF_curves{array_index, rep - 1} = NaN;
            cw_PFF_gof{array_index, rep - 1} = NaN;
        end
    end
end

%% Calculate the T50 and lag time values for each replicate of each cwPFF dilution
for array_index = 1:5
    for rep = 2:4
        fit_result = cw_PFF_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            cw_PFF_t50(array_index, rep - 1) = NaN;
            cw_PFF_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(cwPFF{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(cwPFF{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                cw_PFF_t50(array_index, rep - 1) = t50;
            else
                cw_PFF_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                cw_PFF_lagtime(array_index, rep - 1) = lagtime;
            else
                cw_PFF_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for cwPFF
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4
       
        xData = cwPFF{1}.Time_hours;
        yData = table2array(cwPFF{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(cw_PFF_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Cow PFF ', PFF_names{array_index}]);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'}, 'Location', 'northwest');
    xlim([min(xData) max(xData)]);
end

%% graphing msPFF at different dilutions
for i = 1:length(msPFF)
    currentData = msPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;

    subplot(length(msPFF), 3, i);
    hold on;
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 3'); % Scatter plot for rep3
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Mouse PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'southeast')
    grid on;
 end


%% Fit a sigmoidal model for each replicate of each msPFF dilution
clear [fit_result, gof_result]
for array_index = 1:5
    for rep = 2:4
        try
            [fit_result, gof_result] = fit(msPFF{array_index}.Time_hours(2:end), ...
                                           table2array(msPFF{array_index}(2:end, rep)), ...
                                           'logistic4');
            if gof_result.adjrsquare >= 0.9
                ms_PFF_curves{array_index, rep - 1} = fit_result;
                ms_PFF_gof{array_index, rep - 1} = gof_result;
            else
                ms_PFF_curves{array_index, rep - 1} = NaN;
                ms_PFF_gof{array_index, rep - 1} = NaN;
            end
        catch
            ms_PFF_curves{array_index, rep - 1} = NaN;
            ms_PFF_gof{array_index, rep - 1} = NaN;
        end
    end
end

%% Calculate the T50 and lag time values for each replicate of each msPFF dilution
for array_index = 1:5
    for rep = 2:4
        fit_result = ms_PFF_curves{array_index, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            ms_PFF_t50(array_index, rep - 1) = NaN;
            ms_PFF_lagtime(array_index, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(msPFF{array_index}(:, rep)));
            y_lag = 0.1 * table2array(max(msPFF{array_index}(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                ms_PFF_t50(array_index, rep - 1) = t50;
            else
                ms_PFF_t50(array_index, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                ms_PFF_lagtime(array_index, rep - 1) = lagtime;
            else
                ms_PFF_lagtime(array_index, rep - 1) = NaN;
            end
        end
    end
end

%% Plot the results for msPFF
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4
       
        xData = msPFF{1}.Time_hours;
        yData = table2array(msPFF{array_index}(1:end, rep));

        plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);

        hFit = plot(ms_PFF_curves{array_index, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end
    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Mouse PFF ', PFF_names{array_index}]);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'}, 'Location', 'northwest');
    xlim([min(xData) max(xData)]);
end
%% graphing negcntrl
time = negcntrl.Time_hours;
rep1 = negcntrl.rep1;
rep2 = negcntrl.rep2;
rep3 = negcntrl.rep3;

figure; % Create a subplot for each dataset
    hold on; % Hold on to overlay the plots
    scatter(time, rep1, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'rep1'); % Scatter plot for rep1
    scatter(time, rep2, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'rep2'); % Scatter plot for rep2
    scatter(time, rep3, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'rep3'); % Scatter plot for rep3
    hold off; % Release the hold

    % Add labels and title
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title('Negative control');
    legend('show'); % Show legend
    grid on; % Optional: add grid for better visualization

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    ylim([0 300000]);
    yticks(0:50000:300000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Negative control (no PFF)']);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Location', 'northeast')
    grid on;


    %% Fit a sigmoidal model for each replicate of neg cntrl
    clear [fit_result, gof_result]
    for rep = 2:4
        try
            [fit_result, gof_result] = fit((negcntrl.Time_hours(2:end)), ...
            table2array(negcntrl(2:end, rep)),'logistic4');

            if gof_result.adjrsquare >= 0.9
                negcntrl_curves{1, rep - 1} = fit_result;
                negcntrl_gof{1, rep - 1} = gof_result;
            else
                negcntrl_curves{1, rep - 1} = NaN;
                negcntrl_gof{1, rep - 1} = NaN;
            end
        catch
            negcntrl_curves{1, rep - 1} = NaN;
            negcntrl_gof{1, rep - 1} = NaN;
        end
    end

%% Calculate the T50 and lag time values for each replicate of neg cntrl
    for rep = 2:4
        fit_result = negcntrl_curves{1, rep - 1};
        if ~isa(fit_result, 'cfit') || isempty(fit_result)
            negcntrl_t50(1, rep - 1) = NaN;
            negcntrl_lagtime(1, rep - 1) = NaN;
        else
            a = fit_result.a;
            b = fit_result.b;
            c = fit_result.c;
            d = fit_result.d;
            y_t50 = 0.5 * table2array(max(negcntrl(:, rep)));
            y_lag = 0.1 * table2array(max(negcntrl(:, rep)));

            t50 = c * ((a - y_t50)/(y_t50 - d))^(1/b);
            lagtime = c * ((a - y_lag)/(y_lag - d))^(1/b);

            if isreal(t50) && t50 > 0
                negcntrl_t50(1, rep - 1) = t50;
            else
                negcntrl_t50(1, rep - 1) = NaN;
            end

            if isreal(lagtime) && lagtime > 0
                negcntrl_lagtime(1, rep - 1) = lagtime;
            else
                negcntrl_lagtime(1, rep - 1) = NaN;
            end
        end
    end

%% Plot the results for neg cntrl
colors = {[0.471,0.369,0.941], [0.863,0.149,0.498], [0.996,0.380,0]};

for array_index = 1:5
    fig = figure;
    hold on;
    grid on;
    for rep = 2:4

       xData = negcntrl.Time_hours;
       yData = table2array(negcntrl(:, rep));

       plot(xData, yData, 'o', 'Color', colors{rep - 1}, 'LineWidth', 2);
        hFit = plot(negcntrl_curves{1, rep - 1});
        set(hFit, 'Color', colors{rep - 1});
    end

    hold off;
    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    title(['Negative control (no PFF)']);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    legend({'Replicate 1', 'Sigmoidal fit of rep. 1', 'Replicate 2', 'Sigmoidal fit of rep. 2', 'Replicate 3', 'Sigmoidal fit of rep. 3'}, 'Location', 'northwest');
    xlim([min(xData) max(xData)]);
end

%% plot t50 values
figure;
categories = {'1x','10x','100x','1000x','10,000x'};
x = 1:length(categories);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
    1 0.690 0;
];

%huPFF graph
subplot(2, 3, 1);
b1 = bar(x, mean(hu_PFF_t50, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = hu_PFF_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(hu_PFF_t50, 2, 'omitnan'), (std(hu_PFF_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('T50 (hours)');
title('Human PFF')
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%chPFF graph
subplot(2, 3, 2);
b2 = bar(x, mean(ch_PFF_t50, 2, 'omitnan'));
b2.FaceColor = 'flat';
b2.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = ch_PFF_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(ch_PFF_t50, 2, 'omitnan'), (std(ch_PFF_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('T50 (hours)');
title('Chicken PFF');
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%pgPFF graph
subplot(2, 3, 3);
b3 = bar(x, mean(pg_PFF_t50, 2, 'omitnan'));
b3.FaceColor = 'flat';
b3.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = pg_PFF_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(pg_PFF_t50, 2, 'omitnan'), (std(pg_PFF_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('T50 (hours)');
title('Pig PFF');
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%cwPFF graph
subplot(2, 3, 4);
b4 = bar(x, mean(cw_PFF_t50, 2, 'omitnan'));
b4.FaceColor = 'flat';
b4.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = cw_PFF_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(cw_PFF_t50, 2, 'omitnan'), (std(cw_PFF_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('T50 (hours)');
title('Cow PFF');
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%msPFF graph
subplot(2, 3, 5);
b5 = bar(x, mean(ms_PFF_t50, 2, 'omitnan'));
b5.FaceColor = 'flat';
b5.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = ms_PFF_t50(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(ms_PFF_t50, 2, 'omitnan'), (std(ms_PFF_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('T50 (hours)');
title('Mouse PFF');
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%neg cntrl graph
subplot(2, 3, 6);
x = 1;
categories = {'neg cntrl'};
bar_colors = [0.5 0.5 0.5];

b6 = bar(x, mean(negcntrl_t50, 2, 'omitnan'));
b6.FaceColor = 'flat';
b6.CData = bar_colors;
hold on;

y = negcntrl_t50(1, :);
y = y(~isnan(y));
scatter(repmat(x, size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(negcntrl_t50, 2, 'omitnan'), (std(negcntrl_t50, 0, 2) / sqrt(size(hu_PFF_t50, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('T50 (hours)');
title('Negative control (no PFF)');
subtitle('Time to reach 50% max fluorescence (T50)');
hold off;

%% plot lag time values
figure;
categories = {'1x','10x','100x','1000x','10,000x'};
x = 1:length(categories);
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
    1 0.690 0;
];

%huPFF graph
subplot(2, 3, 1);
b1 = bar(x, mean(hu_PFF_lagtime, 2, 'omitnan'));
b1.FaceColor = 'flat';
b1.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = hu_PFF_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(hu_PFF_lagtime, 2, 'omitnan'), (std(hu_PFF_lagtime, 0, 2) / sqrt(size(hu_PFF_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('Lag time (hours)');
title('Human PFF');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;

%chPFF graph
subplot(2, 3, 2);
b2 = bar(x, mean(ch_PFF_lagtime, 2, 'omitnan'));
b2.FaceColor = 'flat';
b2.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = ch_PFF_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(ch_PFF_lagtime, 2, 'omitnan'), (std(ch_PFF_lagtime, 0, 2) / sqrt(size(ch_PFF_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('Lag time (hours)');
title('Chicken PFF');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;

%pgPFF graph
subplot(2, 3, 3);
b3 = bar(x, mean(pg_PFF_lagtime, 2, 'omitnan'));
b3.FaceColor = 'flat';
b3.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = pg_PFF_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(pg_PFF_lagtime, 2, 'omitnan'), (std(pg_PFF_lagtime, 0, 2) / sqrt(size(pg_PFF_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('Lag time (hours)');
title('Pig PFF');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;

%cwPFF graph
subplot(2, 3, 4);
b4 = bar(x, mean(cw_PFF_lagtime, 2, 'omitnan'));
b4.FaceColor = 'flat';
b4.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = cw_PFF_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(cw_PFF_lagtime, 2, 'omitnan'), (std(cw_PFF_lagtime, 0, 2) / sqrt(size(cw_PFF_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('Lag time (hours)');
title('Cow PFF');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;

%msPFF graph
subplot(2, 3, 5);
b5 = bar(x, mean(ms_PFF_lagtime, 2, 'omitnan'));
b5.FaceColor = 'flat';
b5.CData = bar_colors;
hold on;

for i = 1:length(x)
    y = ms_PFF_lagtime(i, :);
    y = y(~isnan(y));
    scatter(repmat(x(i), size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);
end

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(ms_PFF_lagtime, 2, 'omitnan'), (std(ms_PFF_lagtime, 0, 2) / sqrt(size(ms_PFF_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
xlabel('Dilution of 0.01 mg/mL PFF');
ylabel('Lag time (hours)');
title('Mouse PFF');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;

%neg cntrl graph
subplot(2, 3, 6);
x = 1;
categories = {'neg cntrl'};
bar_colors = [0.5 0.5 0.5];

b6 = bar(x, mean(negcntrl_lagtime, 2, 'omitnan'));
b6.FaceColor = 'flat';
b6.CData = bar_colors;
hold on;

y = negcntrl_lagtime(1, :);
y = y(~isnan(y));
scatter(repmat(x, size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(negcntrl_lagtime, 2, 'omitnan'), (std(negcntrl_lagtime, 0, 2) / sqrt(size(negcntrl_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Negative control (no PFF)');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;


%% plot histograms of 1E-2 T50 and lag time values to check for normality
figure;
subplot(1, 2, 1);
histogram([hu_PFF_t50(1,:);ch_PFF_t50(1,:);pg_PFF_t50(1,:);cw_PFF_t50(1,:);ms_PFF_t50(1,:);negcntrl_t50(1,:)],'BinWidth', 10);
xlim([0 100]);
xticks(0:10:100);
ylim([0 6]);
yticks(0:1:6);
xlabel('T50 (hours)');
ylabel('Number of trials');
title('Distribution of T50 values at 0.01 mg/mL PFF');

subplot(1, 2, 2);
histogram([hu_PFF_lagtime(1,:);ch_PFF_lagtime(1,:);pg_PFF_lagtime(1,:);cw_PFF_lagtime(1,:);ms_PFF_lagtime(1,:);negcntrl_lagtime(1,:)],'BinWidth', 10);
xlim([0 100]);
xticks(0:10:100);
ylim([0 6]);
yticks(0:1:6);
xlabel('Lag time (hours)');
ylabel('Number of trials');
title('Distribution of lag time values at 0.01 mg/mL PFF');

%% Power analysis for a medium effect size (Cohen's h = 0.5 in Kruskal-Wallis)
% Using a simulation (with input from Copilot) bc MATLAB's power analysis
% function does not support Kruskal-Wallis

% Parameters
alpha = 0.05;
power_target = 0.8;
effectSize = 0.5;
numGroups = 6;
numSimulations = 1000;
sampleSizes = 1:30;

groupNames = {'huPFF', 'chkPFF', 'pgPFF', 'cwPFF', 'msPFF', 'neg cntrl'};
power_estimates = zeros(size(sampleSizes));

for i = 1:length(sampleSizes)
    n = sampleSizes(i);
    rejections = 0;
    
    for j = 1:numSimulations
        data = [];
        groupLabelsFull = {};
        
        for g = 1:numGroups
            mu = (g - 1) * effectSize;
            groupData = normrnd(mu, 1, [n, 1]);
            data = [data; groupData];
            
            % Repeat group name n times
            groupLabelsFull = [groupLabelsFull; repmat(groupNames(g), n, 1)];
        end
        
        % Kruskal-Wallis test
        p = kruskalwallis(data, groupLabelsFull, 'off');
        if p < alpha
            rejections = rejections + 1;
        end
    end
    
    power_estimates(i) = rejections / numSimulations;
end


% Plot power curve
figure;
plot(sampleSizes, power_estimates, '-o');
xlabel('Sample Size per Group');
ylabel('Estimated Power');
title('Power Analysis for Kruskal-Wallis Test (6 Groups)');
grid on;

%% Perform Kruskal-Wallis test for T50

t50_for_kw = [hu_PFF_t50(1,:)', ch_PFF_t50(1,:)', pg_PFF_t50(1,:)', cw_PFF_t50(1,:)', ms_PFF_t50(1,:)', negcntrl_t50(1,:)'];

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

lagtime_for_kw = [hu_PFF_lagtime(1,:)', ch_PFF_lagtime(1,:)', pg_PFF_lagtime(1,:)', cw_PFF_lagtime(1,:)', ms_PFF_lagtime(1,:)', negcntrl_lagtime(1,:)'];

[p_lagtime, tbl_lagtime, stats_lagtime] = kruskalwallis(lagtime_for_kw);

H_lagtime = tbl_lagtime{2, 5};
N_lagtime = size(lagtime_for_kw,1)*size(lagtime_for_kw,2);
cohens_h_lagtime = H_lagtime / (N_lagtime - 1);

fprintf('Kruskal-Wallis H statistic: %.4f\n', H_lagtime);
fprintf('Cohen''s h: %.4f\n', cohens_h_lagtime);

disp(['p-value: ', num2str(p_lagtime)]);
disp('ANOVA table:');
disp(tbl_lagtime);


%% Perform Wilcoxon testing for T50 values

t50_for_wilcoxon = {hu_PFF_t50(1,:)', ch_PFF_t50(1,:)', pg_PFF_t50(1,:)', cw_PFF_t50(1,:)', ms_PFF_t50(1,:)', negcntrl_t50(1,:)'};


%Dunn's post-hoc test using multcompare
results_t50 = multcompare(stats_t50, 'CType', 'dunn-sidak', 'Display', 'off');

%Display results
fprintf('Dunn Test Pairwise Comparisons (Dunn-Sidak corrected):\n');
for i = 1:size(results_t50,1)
    g1 = results_t50(i,1);
    g2 = results_t50(i,2);
    p_adj = results_t50(i,6); % column 6 = adjusted p-value
    fprintf('%s vs %s: adjusted p = %.4f\n', groupNames{1,g1}, groupNames{1,g2}, p_adj);
end
hold off;

%% Perform Wilcoxon testing for lag time values

lagtime_for_wilcoxon = {hu_PFF_lagtime(1,:)', ch_PFF_lagtime(1,:)', pg_PFF_lagtime(1,:)', cw_PFF_lagtime(1,:)', ms_PFF_lagtime(1,:)', negcntrl_lagtime(1,:)'};

%Dunn's post-hoc test using multcompare
results_lagtime = multcompare(stats_lagtime, 'CType', 'dunn-sidak', 'Display', 'off');

%Display results
fprintf('Dunn Test Pairwise Comparisons (Dunn-Sidak corrected):\n');
for i = 1:size(results_t50,1)
    g1 = results_lagtime(i,1);
    g2 = results_lagtime(i,2);
    p_adj = results_lagtime(i,6); % column 6 = adjusted p-value
    fprintf('%s vs %s: adjusted p = %.4f\n', groupNames{1,g1}, groupNames{1,g2}, p_adj);
end
hold off;

%% Plotting t50 and lag time values with significant p-values shown

%t50 plot
bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
    1 0.690 0;
    0.5 0.5 0.5;
];

groupMeans_t50 = mean(t50_for_kw, 'omitnan');
groupSEM_t50 = std(t50_for_kw) ./ sqrt(size(t50_for_kw, 1));

figure;
subplot(1,2,1)
b = bar(groupMeans_t50);
b.FaceColor = 'flat';
b.CData = bar_colors;
hold on;

numGroups = size(t50_for_kw, 2);
for i = 1:numGroups
    x = repmat(i, size(t50_for_kw, 1), 1);
    jitter = 0.1 * randn(size(x));
    scatter(x + jitter, t50_for_kw(:,i), 60, 'filled', ...
        'MarkerFaceColor', [0 0 0]);
end

% Add SEM error bars
x = 1:numGroups;
errorbar(x, groupMeans_t50, groupSEM_t50, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Customize plot
set(gca, 'XTick', 1:numGroups, 'XTickLabel', {'Human', 'Chicken', 'Pig', 'Cow', 'Mouse', 'Neg control'});
ylim([0 100]);
yticks([0:10:100]);
xlabel('PFF species')
ylabel('T50 value (hours)');
title('T50 values by species');
box off;

% Overlay brackets for significant comparisons with asterisks and p-values
sigResults = results_t50(results_t50(:,6) < 0.05, :); % get significant pairs
yMax = max(t50_for_kw(:)); % highest data point
offset = 0.1 * yMax;       % vertical spacing between brackets

for i = 1:size(sigResults,1)
    g1 = sigResults(i,1);
    g2 = sigResults(i,2);
    pVal = sigResults(i,6);

    x1 = g1;
    x2 = g2;
    yBracket = yMax + i * offset;

    % Draw bracket
    plot([x1 x1 x2 x2], [yBracket yBracket+offset yBracket+offset yBracket], ...
        'k', 'LineWidth', 1.5);

    % Determine asterisk level
    if pVal < 0.001
        stars = '***';
    elseif pVal < 0.01
        stars = '**';
    else
        stars = '*';
    end

    % Add p-value and asterisks
    text(mean([x1 x2]), yBracket+offset+0.02*yMax, ...
        sprintf('%s (p = %.4f)', stars, pVal), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);
end

%lag time plot
groupMeans_lagtime = mean(lagtime_for_kw, 'omitnan');
groupSEM_lagtime = std(lagtime_for_kw) ./ sqrt(size(lagtime_for_kw, 1));


subplot(1,2,2)
b = bar(groupMeans_lagtime);
b.FaceColor = 'flat';
b.CData = bar_colors;
hold on;

numGroups = size(lagtime_for_kw, 2);
for i = 1:numGroups
    x = repmat(i, size(lagtime_for_kw, 1), 1);
    jitter = 0.1 * randn(size(x));
    scatter(x + jitter, lagtime_for_kw(:,i), 60, 'filled', ...
        'MarkerFaceColor', [0 0 0]);
end

% Add SEM error bars
x = 1:numGroups;
errorbar(x, groupMeans_lagtime, groupSEM_lagtime, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

% Customize plot
set(gca, 'XTick', 1:numGroups, 'XTickLabel', {'Human', 'Chicken', 'Pig', 'Cow', 'Mouse', 'Neg control'});
ylim([0 100]);
yticks([0:10:100]);
xlabel('PFF species');
ylabel('Lag time value (hours)');
title('Lag time values by species');
box off;

% Overlay brackets for significant comparisons with asterisks and p-values
sigResults = results_lagtime(results_lagtime(:,6) < 0.05, :); % get significant pairs
yMax = max(lagtime_for_kw(:)); % highest data point
offset = 0.1 * yMax;       % vertical spacing between brackets

for i = 1:size(sigResults,1)
    g1 = sigResults(i,1);
    g2 = sigResults(i,2);
    pVal = sigResults(i,6);

    x1 = g1;
    x2 = g2;
    yBracket = yMax + i * offset;

    % Draw bracket
    plot([x1 x1 x2 x2], [yBracket yBracket+offset yBracket+offset yBracket], ...
        'k', 'LineWidth', 1.5);

    % Determine asterisk level
    if pVal < 0.001
        stars = '***';
    elseif pVal < 0.01
        stars = '**';
    else
        stars = '*';
    end

    % Add p-value and asterisks
    text(mean([x1 x2]), yBracket+offset+0.02*yMax, ...
        sprintf('%s (p = %.4f)', stars, pVal), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);
end