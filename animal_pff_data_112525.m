%% importing the data into MATLAB as individual sheets per dilution and species
cd('/Users/johannab/Documents/Penn 2nd year/Luk Lab/Projects/Food project/Second round SAA w dilution series PFF/11-25-25 (sixth try, 6x replicates)')
% modify the directory above and/or the sheets created below as needed;
% make sure to replace sheet names later in code if modified!! and modify
% sheet numbers if not starting from 1st sheet!!
% Also: change rep #s if using something other than 3 replicates

huPFF_1e2 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 2);
huPFF_1e3 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 3);
huPFF_1e4 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 4);
huPFF = {huPFF_1e2, huPFF_1e3, huPFF_1e4};


chPFF_1e2 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 5);
chPFF_1e3 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 6);
chPFF_1e4 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 7);
chPFF = {chPFF_1e2, chPFF_1e3, chPFF_1e4};

pgPFF_1e2 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 8);
pgPFF_1e3 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 9);
pgPFF_1e4 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 10);
pgPFF = {pgPFF_1e2, pgPFF_1e3, pgPFF_1e4};

cwPFF_1e2 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 11);
cwPFF_1e3 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 12);
cwPFF_1e4 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 13);
cwPFF = {cwPFF_1e2, cwPFF_1e3, cwPFF_1e4};

msPFF_1e2 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 14);
msPFF_1e3 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 15);
msPFF_1e4 = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 16);
msPFF = {msPFF_1e2, msPFF_1e3, msPFF_1e4};

negcntrl = readtable('SAA_Hu_Ch_Cw_Pg_Ms_PFFs_dilutionseries_JB_11-25-25.xlsx', 'Sheet', 17);

PFF_names = {'(0.01 mg/mL)', '(10x dilution)', '(100x dilution)'};

%% graphing huPFF at different dilutions

for i = 1:length(huPFF)
    currentData = huPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Human PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;
end

%% calculating lag times for huPFF

for array_index = 1:3
    for rep = 2:7
        % Extract data
        y = table2array(huPFF{array_index}(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first')
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        hu_PFF_lagtime(array_index, rep - 1) = lagtime;
    end
end

%% graphing chPFF at different dilutions

for i = 1:length(chPFF)
    currentData = chPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Chicken PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;
end

%% calculating lag times for chPFF

for array_index = 1:3
    for rep = 2:7
        % Extract data
        y = table2array(chPFF{array_index}(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first');
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        ch_PFF_lagtime(array_index, rep - 1) = lagtime;
    end
end

%% graphing pgPFF at different dilutions

for i = 1:length(pgPFF)
    currentData = pgPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Pig PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;
end

%% calculating lag times for pgPFF

for array_index = 1:3
    for rep = 2:7
        % Extract data
        y = table2array(pgPFF{array_index}(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first');
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        pg_PFF_lagtime(array_index, rep - 1) = lagtime;
    end
end

%% graphing cwPFF at different dilutions

for i = 1:length(cwPFF)
    currentData = cwPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Cow PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;
end

%% calculating lag times for cwPFF

for array_index = 1:3
    for rep = 2:7
        % Extract data
        y = table2array(cwPFF{array_index}(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first');
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        cw_PFF_lagtime(array_index, rep - 1) = lagtime;
    end
end

%% graphing msPFF at different dilutions

for i = 1:length(msPFF)
    currentData = msPFF{i};
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Mouse PFF ', PFF_names{i}]);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;
end

%% calculating lag times for msPFF

for array_index = 1:3
    for rep = 2:7
        % Extract data
        y = table2array(msPFF{array_index}(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first');
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        ms_PFF_lagtime(array_index, rep - 1) = lagtime;
    end
end


%% graphing neg cntrl

    currentData = negcntrl;
        time = currentData.Time_hours;
        rep1 = currentData.rep1;
        rep2 = currentData.rep2;
        rep3 = currentData.rep3;
        rep4 = currentData.rep4;
        rep5 = currentData.rep5;
        rep6 = currentData.rep6;

    figure;
    hold on;
    scatter(time, rep1, 36,[0,0,0], 'filled', 'DisplayName', 'Replicate 1');
    scatter(time, rep2, 36,[0.392,0.561,1], 'filled', 'DisplayName', 'Replicate 2');
    scatter(time, rep3, 36,[0.471,0.369,0.941], 'filled', 'DisplayName', 'Replicate 3');
    scatter(time, rep4, 36,[0.863,0.149,0.498], 'filled', 'DisplayName', 'Replicate 4');
    scatter(time, rep5, 36,[0.996,0.380,0], 'filled', 'DisplayName', 'Replicate 5');
    scatter(time, rep6, 36,[1,0.690,0], 'filled', 'DisplayName', 'Replicate 6');
    hold off;

    line(xlim, [260000 260000], 'Color', 'black', 'LineStyle', '--', 'LineWidth', 1.5);
    xlim([0 100]);
    xticks(0:10:100);
    ylim([0 100000]);
    yticks(0:20000:100000);
    xlabel('Time (hours)');
    ylabel('ThT fluorescence (au)');
    title(['Negative control']);
    legend('Replicate 1', 'Replicate 2', 'Replicate 3','Replicate 4','Replicate 5','Replicate 6','Location', 'northwest')
    grid on;

%% calculating lag times for neg cntrl

    for rep = 2:7
        % Extract data
        y = table2array(negcntrl(:, rep));   % response values
        x = (0:0.5:120).'; % corresponding time vector

        % --- Threshold for lagtime ---
        baseline = y(1:20); % first 10 hours
        mu = mean(baseline);
        sigma = std(baseline);
        threshold = mu + 4*sigma; % define lag threshold

        % --- Find lagtime crossing directly ---
        idx_lag = find(y > threshold, 1, 'first');
        if isempty(idx_lag) || idx_lag == 1
            lagtime = NaN;
        else
            % Linear interpolation between points
            t1 = x(idx_lag-1); t2 = x(idx_lag);
            y1 = y(idx_lag-1); y2 = y(idx_lag);
            lagtime = t1 + (t2 - t1) * (threshold - y1) / (y2 - y1);
        end

        % --- Store results ---
        neg_cntrl_lagtime(rep - 1) = lagtime;
    end


%% plot lag time values
figure;
categories = {'1x','10x','100x'};
x = 1:length(categories);
bar_colors = [
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
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

b6 = bar(x, mean(neg_cntrl_lagtime, 2, 'omitnan'));
b6.FaceColor = 'flat';
b6.CData = bar_colors;
hold on;

y = neg_cntrl_lagtime(1, :);
y = y(~isnan(y));
scatter(repmat(x, size(y)), y, 50, 'k', 'filled', 'jitter','on', 'jitterAmount',0.15);

set(gca, 'XTick', x, 'XTickLabel', categories);
ylim([0 100]);
yticks(0:10:100);
errorbar(x, mean(neg_cntrl_lagtime, 2, 'omitnan'), (std(neg_cntrl_lagtime, 0, 2) / sqrt(size(neg_cntrl_lagtime, 2))), 'k', 'linestyle', 'none', 'LineWidth', 1.5);
ylabel('Lag time (hours)');
title('Negative control (no PFF)');
subtitle('Time to reach 10% max fluorescence (lag time)');
hold off;


%% plot histograms of 1E-2 T50 and lag time values to check for normality
figure;
histogram([hu_PFF_lagtime(1,:);ch_PFF_lagtime(1,:);pg_PFF_lagtime(1,:);cw_PFF_lagtime(1,:);ms_PFF_lagtime(1,:);neg_cntrl_lagtime(1,:)],'BinWidth', 10);
xlim([0 100]);
xticks(0:10:100);
ylim([0 9]);
yticks(0:1:9);
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


%% Perform Kruskal-Wallis test for lag time

lagtime_for_kw = [hu_PFF_lagtime(1,:)', ch_PFF_lagtime(1,:)', pg_PFF_lagtime(1,:)', cw_PFF_lagtime(1,:)', ms_PFF_lagtime(1,:)', neg_cntrl_lagtime(1,:)'];

[p_lagtime, tbl_lagtime, stats_lagtime] = kruskalwallis(lagtime_for_kw);

H_lagtime = tbl_lagtime{2, 5};
N_lagtime = size(lagtime_for_kw,1)*size(lagtime_for_kw,2);
cohens_h_lagtime = H_lagtime / (N_lagtime - 1);

fprintf('Kruskal-Wallis H statistic: %.4f\n', H_lagtime);
fprintf('Cohen''s h: %.4f\n', cohens_h_lagtime);

disp(['p-value: ', num2str(p_lagtime)]);
disp('ANOVA table:');
disp(tbl_lagtime);

%% Perform Wilcoxon testing for lag time values

lagtime_for_wilcoxon = {hu_PFF_lagtime(1,:)', ch_PFF_lagtime(1,:)', pg_PFF_lagtime(1,:)', cw_PFF_lagtime(1,:)', ms_PFF_lagtime(1,:)', neg_cntrl_lagtime(1,:)'};

%Dunn's post-hoc test using multcompare
results_lagtime = multcompare(stats_lagtime, 'CType', 'dunn-sidak', 'Display', 'off');

%Display results
fprintf('Dunn Test Pairwise Comparisons (Dunn-Sidak corrected):\n');
for i = 1:size(results_lagtime,1)
    g1 = results_lagtime(i,1);
    g2 = results_lagtime(i,2);
    p_adj = results_lagtime(i,6); % column 6 = adjusted p-value
    fprintf('%s vs %s: adjusted p = %.4f\n', groupNames{1,g1}, groupNames{1,g2}, p_adj);
end
hold off;

%% Plotting lag time values with significant p-values shown

bar_colors = [
    0.392 0.561 1;
    0.471 0.369 0.941;
    0.863 0.149 0.498;
    0.996 0.380 0;
    1 0.690 0;
    0.5 0.5 0.5;
];

%lag time plot
groupMeans_lagtime = mean(lagtime_for_kw, 'omitnan');
groupSEM_lagtime = std(lagtime_for_kw) ./ sqrt(size(lagtime_for_kw, 1));


figure;
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

% Overlay brackets for comparisons with p-values < 0.06
filteredResults = results_lagtime(results_lagtime(:,6) < 0.06, :); 
yMax = max(lagtime_for_kw(:)); % highest data point
offset = 0.1 * yMax;           % vertical spacing between brackets

for i = 1:size(filteredResults,1)
    g1 = filteredResults(i,1);
    g2 = filteredResults(i,2);
    pVal = filteredResults(i,6);

    x1 = g1;
    x2 = g2;
    yBracket = yMax + i * offset;

    % Draw bracket
    plot([x1 x1 x2 x2], [yBracket yBracket+offset yBracket+offset yBracket], ...
        'k', 'LineWidth', 1.5);

    % Determine asterisk level (only if p < 0.05)
    if pVal < 0.001
        stars = '***';
    elseif pVal < 0.01
        stars = '**';
    elseif pVal < 0.05
        stars = '*';
    else
        stars = ''; % no stars if 0.05 <= p < 0.06
    end

    % Add p-value (always shown for < 0.06) and asterisks (if any)
    text(mean([x1 x2]), yBracket+offset+0.02*yMax, ...
        sprintf('%s (p = %.4f)', stars, pVal), ...
        'HorizontalAlignment', 'center', 'FontSize', 12);
end
