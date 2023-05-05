% MLForce_Right_Left_Difference.m
% Bar chart of right-minus-left average peak mediolateral force for each test condition (Norm, L40, L20, R40, R20) for one subject. Paste in the values reported by ML_Force_Analysis.m.
% The values in the file are placeholders (all zero).
%
% ---- original file below ----
% This code is used to compare the difference in medioalteral force across all cases. 
% Written by Jesse Greyshock
% Once MLForcePlotterV1 has been run for each case for a particular subject, please include the avg_peak_force_left and avg_peak_force_right values in the vectors below. The data values should be enterd in this fashion:
% sensor_values = ["Norm" "L40" "L20" "R40" "R20"]
% Make sure to change the name of the plot!
clear all
clc

% Define the right and left sensor values. -> ["Norm" "L40" "L20" "R40" "R20"]

left_sensor_values = [0 0 0 0 0];    % EXAMPLE VALUES: avg_peak_force_left for each condition, in the order above
right_sensor_values = [0 0 0 0 0];   % EXAMPLE VALUES: avg_peak_force_right for each condition, in the order above



% Define column headers. Calculate the difference between the right and left sensor readings for each case.
column_headers = ["Norm" "L40" "L20" "R40" "R20"];
diff_RL = flipud(right_sensor_values - left_sensor_values);

% Determine the direction of the bar and color based on the difference.
dir = sign(diff_RL);
colors = zeros(5,3);
colors(dir==-1,:) = repmat([1 0.5 0], nnz(dir==-1), 1); % left is greater
colors(dir==1,:) = repmat([0 0.8 1], nnz(dir==1), 1); % right is greater

% Create the bar chart
figure;
hold on;
for i = 1:numel(diff_RL)
    col = colors(i,:);
    if dir(i) == -1 % left is greater
        x1 = 0;
        y1 = i-0.4;
        x2 = abs(diff_RL(i))*dir(i);
        y2 = i+0.4;
    else % right is greater
        x1 = 0;
        y1 = i-0.4;
        x2 = abs(diff_RL(i));
        y2 = i+0.4;
    end
    patch([x1 x2 x2 x1], [y1 y1 y2 y2], col);
    
    if dir(i) == -1 % left is greater
        text(x2-0.6, y1+0.4, sprintf('%.2f', abs(diff_RL(i))), 'Color', 'k','FontWeight', 'bold');
    else % right is greater
        text(x2+0.6, y1+0.4, sprintf('%.2f', abs(diff_RL(i))), 'Color', 'k','FontWeight', 'bold');
    end
end
yticks(1:numel(diff_RL));
yticklabels({'Norm', 'L40', 'L20', 'R40', 'R20'});
xlim([-(max(abs(diff_RL))+1) max(abs(diff_RL))+1]);
set(gca,'box','off');
title('SUBJECT_ID')   % EXAMPLE: put the subject code here
xlabel('\DeltaForce (lbf)');
xline(0, '--');
hold off
