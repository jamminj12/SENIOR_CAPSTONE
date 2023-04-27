% AVERAGED_MLForce_Difference.m
% Group version of MLForce_Right_Left_Difference.m: averages one value per subject for each condition (Norm, L40, L20, R40, R20) and draws the same style of bar chart, then a version normalized to the Norm condition.
% The per-subject values that were typed into the original have been replaced with zeros; paste in your own. The original averaged 11 subjects (hence the vectors of 11 values); mean() now handles any number.
%
% ---- original file below ----
% This code is used to compare the difference in medioalteral force across all cases. 
% Written by Jesse Greyshock
% Once MLForcePlotterV1 has been run for each case for a particular subject, please include the avg_peak_force_left and avg_peak_force_right values in the vectors below. The data values should be enterd in this fashion:
% sensor_values = ["Norm" "L40" "L20" "R40" "R20"]
% Make sure to change the name of the plot!
clear all
clc

Norm = mean([0 0 0 0 0 0 0 0 0 0 0])   % EXAMPLE VALUES: one value per subject for this condition
L40 = mean([0 0 0 0 0 0 0 0 0 0 0])   % EXAMPLE VALUES: one value per subject for this condition
L20 = mean([0 0 0 0 0 0 0 0 0 0 0])   % EXAMPLE VALUES: one value per subject for this condition
R40 = mean([0 0 0 0 0 0 0 0 0 0 0])   % EXAMPLE VALUES: one value per subject for this condition
R20 = mean([0 0 0 0 0 0 0 0 0 0 0])   % EXAMPLE VALUES: one value per subject for this condition

sensor_values = [Norm L40 L20 R40 R20];

% Define column headers. Calculate the absolute sensor reading for each case.
column_headers = ["Norm" "L40" "L20" "R40" "R20"];
abs_values = abs(sensor_values);

% Determine the direction of the bar and color based on the sign of the sensor value.
dir = sign(sensor_values);
colors = zeros(5,3);
colors(dir==-1,:) = repmat([1 0.5 0], nnz(dir==-1), 1); % negative values are orange
colors(dir==1,:) = repmat([0 0.8 1], nnz(dir==1), 1); % positive values are blue

% Create the bar chart
figure;
hold on;
for i = 1:numel(abs_values)
    col = colors(i,:);
    if dir(i) == -1 % negative value, bar goes left
        x1 = 0;
        y1 = i-0.4;
        x2 = -abs_values(i);
        y2 = i+0.4;
    else % positive value, bar goes right
        x1 = 0;
        y1 = i-0.4;
        x2 = abs_values(i);
        y2 = i+0.4;
    end
    patch([x1 x2 x2 x1], [y1 y1 y2 y2], col);
    
    if dir(i) == -1 % negative value, label goes to left of bar
        text(x2-0.6, y1+0.4, sprintf('%.2f', abs_values(i)), 'Color', 'k','FontWeight', 'bold');
    else % positive value, label goes to right of bar
        text(x2+0.6, y1+0.4, sprintf('%.2f', abs_values(i)), 'Color', 'k','FontWeight', 'bold');
    end
end
yticks(1:numel(abs_values));
yticklabels({'Norm', 'L40', 'L20', 'R40', 'R20'});
xlim([-max(abs_values)-1 max(abs_values)+1]);
set(gca,'box','off');
title('Peak ML Force Difference - ALL SUBJECTS')
xlabel('Force (lbf)');
xline(0, '--');
hold off
% Now, I'm going to make a normalized version. 
% NOTE: it's worth noting that some degree of asymmetry in mediolateral forces is normal and expected in most people due to differences in leg length, foot shape, and other factors. 
NormN = 0
L40N = L40-Norm
L20N = L20-Norm
R40N = R40-Norm
R20N = R20-Norm

sensor_values = [NormN L40N L20N R40N R20N];

% Define column headers. Calculate the absolute sensor reading for each case.
column_headers = ["Norm" "L40" "L20" "R40" "R20"];
abs_valuesN = abs(sensor_values);

% Determine the direction of the bar and color based on the sign of the sensor value.
dir = sign(sensor_values);
colors = zeros(5,3);
colors(dir==-1,:) = repmat([1 0.5 0], nnz(dir==-1), 1); % negative values are orange
colors(dir==1,:) = repmat([0 0.8 1], nnz(dir==1), 1); % positive values are blue

% Create the bar chart
figure;
hold on;
for i = 1:numel(abs_valuesN)
    col = colors(i,:);
    if dir(i) == -1 % negative value, bar goes left
        x1 = 0;
        y1 = i-0.4;
        x2 = -abs_valuesN(i);
        y2 = i+0.4;
    else % positive value, bar goes right
        x1 = 0;
        y1 = i-0.4;
        x2 = abs_valuesN(i);
        y2 = i+0.4;
    end
    patch([x1 x2 x2 x1], [y1 y1 y2 y2], col);
    
    if dir(i) == -1 % negative value, label goes to left of bar
        text(x2-0.6, y1+0.4, sprintf('%.2f', abs_valuesN(i)), 'Color', 'k','FontWeight', 'bold');
    else % positive value, label goes to right of bar
        text(x2+0.6, y1+0.4, sprintf('%.2f', abs_valuesN(i)), 'Color', 'k','FontWeight', 'bold');
    end
end
yticks(1:numel(abs_valuesN));
yticklabels({'Norm', 'L40', 'L20', 'R40', 'R20'});
xlim([-max(abs_valuesN)-1 max(abs_valuesN)+1]);
set(gca,'box','off');
title('NORMALIZED: Peak ML Force Difference - ALL SUBJECTS')
xlabel('Force (lbf)');
xline(0, '--');
hold off

