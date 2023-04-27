% MLForcePlotterV1_Chopped.m
% The mediolateral force analysis from ML_Force_Analysis.m (developed as MLForcePlotterV1), plus foot strike/lift detection from the F-Scan COF-velocity ("VT") export of each foot.
% Leaves StrkIndL/R, LiftIndL/R and avg_sampling_freq in the workspace so MLForceChopLeft.m / MLForceChopRight.m can cut the load-cell data into one segment per footstep.
% Before running: set filename, filelocationR, filelocationL and subjectWt (placeholders below). Needs the Signal Processing Toolbox. See README.md in this folder.
%
% ---- original file below ----
% This code was developed to serve as an analysis tool for the mediolateral force sensor data taken from the system designed by the 2022/2023 capstone team.
% This code was written by Jesse Greyshock.
% Comments:
% Trials are taken for 90 seconds, but aren't always stopped at the same time as the rest of the tests. Therefore, the code cuts any values that are after the 90 second mark. 
% The "findpeaks" function uses a 'MinPeakDistance' value of 10. This number was found through trial and error as it finds the peak values. Not all peaks are always found, but majority shown. Since average values are taken, the data will not be skewed by a large amount
% Make sure that no black quiver arrows find a peak where there one shouldn't be. 
% Check the threshold value and edit accordingly if there is a data point of concern. Otherwise, the data will remain unchanged if there is no data point to worry about. 
clear all
clc

% Specify the name of the Excel file and the sheet to read from
filename = 'S23XX_Norm.xlsx'; % Make sure it is a .xlsx file. Convert if it is not.

% input .xls files that have VT as a suffix
filelocationR = 'SUBJECT_R_VT.xls';
filelocationL = 'SUBJECT_L_VT.xls';
FdataHz = 400;      % the forced data (Fscan ) frequency

% Specify the subject weight
subjectWt = 150;   % in lbs. EXAMPLE VALUE: set this per subject

lb2N = 4.44822; % conversion for pounds to newtons (journals like SI units)

% Read in the data from the Excel file
data = readtable(filename);

% Find rows where the timestamp is greater than 90 seconds
rows_to_remove = data{:, 1} > 90;

% Remove those rows
data(rows_to_remove, :) = [];

% Extract the force data from each load cell
front_left = data(:,2);
front_right = data(:,3);
back_right = data(:,4);
back_left = data(:,5);

% Extract the timestamp data
time = data(:, 1);

% sampling time of the script not perfect. so this makes a difference of
% all the sampling times. It needs a vector format to work so that is the
% reason for the extra "time_vec" variable below
time_vec = data{:, 1};
time_diff = diff(time_vec);

avg_sampling_freq = mean(time_diff);
disp(['Average sampling frequency for this test: ' num2str(avg_sampling_freq) ' seconds']);

% Convert the time and force data to numeric arrays
time = table2array(time);
front_left = table2array(front_left);
front_right = table2array(front_right);
back_right = table2array(back_right);
back_left = table2array(back_left);

% The section below is used to eliminate rogue data points that the load cells sometimes outputs. 
% Set upper and lower thresholds for rogue data values
upper_threshold = 25;
lower_threshold = 0;

% Find rows where the force exceeds the upper threshold for front_left
bad_rows = find(front_left > upper_threshold | front_left < lower_threshold);

% Loop through each bad row
for i = 1:length(bad_rows)
    % Remove the bad row and replace it with the average of the previous
    % and next points if the next point is below the upper threshold and above the lower threshold
    if front_left(bad_rows(i)) > upper_threshold && (bad_rows(i) == length(front_left) || (front_left(bad_rows(i)+1) <= upper_threshold && front_left(bad_rows(i)+1) >= lower_threshold))
        front_left(bad_rows(i)) = (front_left(bad_rows(i)-1) + front_left(bad_rows(i)+1))/2;
        % Replace the bad row with the previous point if the previous point is above the lower threshold
    elseif bad_rows(i) > 1 && front_left(bad_rows(i)-1) >= lower_threshold
        front_left(bad_rows(i)) = front_left(bad_rows(i)-1);
        % Otherwise, skip over consecutive bad rows and use the point before the first bad row as the replacement value
    else
        j = bad_rows(i);
        while j < length(front_left) && (front_left(j) > upper_threshold || front_left(j) < lower_threshold) && (front_left(j+1) > upper_threshold || front_left(j+1) < lower_threshold)
            j = j + 1;
        end
        front_left(bad_rows(i):j) = front_left(bad_rows(i)-1);
    end
    % Display information about the bad data points for front_left
    if i == 1
        disp('Bad data points found for front_left sensor:');
    end
    if i == length(bad_rows) || bad_rows(i+1) - bad_rows(i) > 1
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(front_left(bad_rows(i))) 'lbf']);
    else
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(front_left(bad_rows(i))) 'lbf (and consecutive)']);
    end
end


% Find rows where the force exceeds the upper threshold for front_right
bad_rows = find(front_right > upper_threshold | front_right < lower_threshold);

% Loop through each bad row
for i = 1:length(bad_rows)
    % Remove the bad row and replace it with the average of the previous
    % and next points if the next point is below the upper threshold and above the lower threshold
    if front_right(bad_rows(i)) > upper_threshold && (bad_rows(i) == length(front_right) || (front_right(bad_rows(i)+1) <= upper_threshold && front_right(bad_rows(i)+1) >= lower_threshold))
        front_right(bad_rows(i)) = (front_right(bad_rows(i)-1) + front_right(bad_rows(i)+1))/2;
    % Replace the bad row with the previous point if the previous point is above the lower threshold
    elseif bad_rows(i) > 1 && front_right(bad_rows(i)-1) >= lower_threshold
        front_right(bad_rows(i)) = front_right(bad_rows(i)-1);
    % Otherwise, skip over consecutive bad rows and use the point before the first bad row as the replacement value
    else
        j = bad_rows(i);
        while j < length(front_right) && (front_right(j) > upper_threshold || front_right(j) < lower_threshold) && (front_right(j+1) > upper_threshold || front_right(j+1) < lower_threshold)
            j = j + 1;
        end
        front_right(bad_rows(i):j) = front_right(bad_rows(i)-1);
    end
    % Display information about the bad data points for front_right
    if i == 1
        disp('Bad data points found for front_right sensor:');
    end
    if i == length(bad_rows) || bad_rows(i+1) - bad_rows(i) > 1
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(front_right(bad_rows(i))) 'lbf']);
    else
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(front_right(bad_rows(i))) 'lbf (and consecutive)']);
    end
end

% Find rows where the force exceeds the upper threshold for back_left
bad_rows = find(back_left > upper_threshold);

% Loop through each bad row
for i = 1:length(bad_rows)
    % Remove the bad row and replace it with the average of the previous
    % and next points if the next point is below the upper threshold and above the lower threshold
    if back_left(bad_rows(i)) > upper_threshold && (bad_rows(i) == length(back_left) || (back_left(bad_rows(i)+1) <= upper_threshold && back_left(bad_rows(i)+1) >= lower_threshold))
        back_left(bad_rows(i)) = (back_left(bad_rows(i)-1) + back_left(bad_rows(i)+1))/2;
        % Replace the bad row with the previous point if the previous point is above the lower threshold
    elseif bad_rows(i) > 1 && back_left(bad_rows(i)-1) >= lower_threshold
        back_left(bad_rows(i)) = back_left(bad_rows(i)-1);
        % Otherwise, skip over consecutive bad rows and use the point before the first bad row as the replacement value
    else
        j = bad_rows(i);
        while j < length(back_left) && back_left(j) > upper_threshold && back_left(j+1) > upper_threshold
            j = j + 1;
        end
        back_left(bad_rows(i):j) = back_left(bad_rows(i)-1);
    end
    % Display information about the bad data points for back_left
    if i == 1
        disp('Bad data points found for back_left sensor:');
    end
    if i == length(bad_rows) || bad_rows(i+1) - bad_rows(i) > 1
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(back_left(bad_rows(i))) 'lbf']);
    else
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(back_left(bad_rows(i))) 'lbf (and consecutive)']);
    end
end

% Find rows where the force exceeds the upper threshold for back_right
bad_rows = find(back_right > upper_threshold);

% Loop through each bad row
for i = 1:length(bad_rows)
    % Remove the bad row and replace it with the average of the previous
    % and next points if the next point is below the upper threshold and above the lower threshold
    if back_right(bad_rows(i)) > upper_threshold && (bad_rows(i) == length(back_right) || (back_right(bad_rows(i)+1) <= upper_threshold && back_right(bad_rows(i)+1) >= lower_threshold))
        back_right(bad_rows(i)) = (back_right(bad_rows(i)-1) + back_right(bad_rows(i)+1))/2;
    % Replace the bad row with the previous point if the previous point is above the lower threshold
    elseif bad_rows(i) > 1 && back_right(bad_rows(i)-1) >= lower_threshold
        back_right(bad_rows(i)) = back_right(bad_rows(i)-1);
    % Otherwise, skip over consecutive bad rows and use the point before the first bad row as the replacement value
    else
        j = bad_rows(i);
        while j < length(back_right) && back_right(j) > upper_threshold && back_right(j+1) > upper_threshold
            j = j + 1;
        end
        back_right(bad_rows(i):j) = back_right(bad_rows(i)-1);
    end
    % Display information about the bad data points for back_right
    if i == 1
        disp('Bad data points found for back_right sensor:');
    end
    if i == length(bad_rows) || bad_rows(i+1) - bad_rows(i) > 1
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(back_right(bad_rows(i))) 'lbf']);
    else
        disp(['Time: ' num2str(time(bad_rows(i))) 's, Value: ' num2str(back_right(bad_rows(i))) 'lbf (and consecutive)']);
    end
end
% Now, let's plot the data of the test. 
% Plot the force data from each load cell as a function of time
plot(time, front_left, 'b')
hold on
plot(time, front_right, 'r')
plot(time, back_right, 'g')
plot(time, back_left, 'm')

% Add a legend and title to the plot
legend('Front Left', 'Front Right', 'Back Right', 'Back Left');
title(strrep(filename, '_', ' '), 'Interpreter', 'none'); % replace underscores with spaces
xlabel('Time (seconds)');
ylabel('Force (lbf)');
hold off
% Now, I'm going to plot each load cell individually, and then pull out the peak force from each cell. Starting with the Front Left.  
% Find the peaks in the force data for the front left sensor
[peak_valuesFL, peak_locsFL] = findpeaks(front_left,'MinPeakDistance',10);

% Calculate the average peak force
avg_peak_forceFL = mean(peak_valuesFL);

% Calculate the std of peak force
std_peak_forceFL = std(peak_valuesFL);

% Plot the force data with arrows at each peak
plot(data{:,1}, front_left,'b');
hold on;
quiver(data{peak_locsFL,1}, peak_valuesFL, zeros(size(peak_locsFL)), 5*ones(size(peak_locsFL)), 'k', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
title({'Peak ML Forces for Each Step:' 'Front Left Sensor'});
xlabel('Time (seconds)');
ylabel('Force (lbf)');
hold off;

% Display the average peak force
disp(['Average peak force for Front Left: ' num2str(avg_peak_forceFL) ' lbf']);
disp(['Standard Deviation of Peak Values: ' num2str(std_peak_forceFL)]);
% Now, Front Right
% Find the peaks in the force data for the front right sensor
[peak_valuesFR, peak_locsFR] = findpeaks(front_right,'MinPeakDistance',10);

% Calculate the average peak force
avg_peak_forceFR = mean(peak_valuesFR);

% Calculate the std of peak force
std_peak_forceFR = std(peak_valuesFR);

% Plot the force data with arrows at each peak
plot(data{:,1}, front_right,'r');
hold on;
quiver(data{peak_locsFR,1}, peak_valuesFR, zeros(size(peak_locsFR)), 5*ones(size(peak_locsFR)), 'k', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
title({'Peak ML Forces for Each Step:' 'Front Right Sensor'});
xlabel('Time (seconds)');
ylabel('Force (lbf)');
hold off;

% Display the average peak force
disp(['Average peak force for Front Right: ' num2str(avg_peak_forceFR) ' lbf']);
disp(['Standard Deviation of Peak Values: ' num2str(std_peak_forceFR)]);
% Now, Back Right.
% Find the peaks in the force data for the back right sensor
[peak_valuesBR, peak_locsBR] = findpeaks(back_right,'MinPeakDistance',10);

% Calculate the average peak force
avg_peak_forceBR = mean(peak_valuesBR);

% Calculate the std of peak force
std_peak_forceBR = std(peak_valuesBR);

% Plot the force data with arrows at each peak
plot(data{:,1}, back_right,'g');
hold on;
quiver(data{peak_locsBR,1}, peak_valuesBR, zeros(size(peak_locsBR)), 5*ones(size(peak_locsBR)), 'k', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
title({'Peak ML Forces for Each Step:' 'Back Right Sensor'});
xlabel('Time (seconds)');
ylabel('Force (lbf)');
hold off;

% Display the average peak force
disp(['Average peak force for Back Right: ' num2str(avg_peak_forceBR) ' lbf']);
disp(['Standard Deviation of Peak Values: ' num2str(std_peak_forceBR)]);
% Finally, Back Left.
% Find the peaks in the force data for the back left sensor
[peak_valuesBL, peak_locsBL] = findpeaks(back_left,'MinPeakDistance',10);

% Calculate the average peak force
avg_peak_forceBL = mean(peak_valuesBL);

% Calculate the std of peak force
std_peak_forceBL = std(peak_valuesBL);

% Plot the force data with arrows at each peak
plot(data{:,1}, back_left,'m');
hold on;
quiver(data{peak_locsBL,1}, peak_valuesBL, zeros(size(peak_locsBL)), 5*ones(size(peak_locsBL)), 'k', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
title({'Peak ML Forces for Each Step:' 'Back Left Sensor'});
xlabel('Time (seconds)');
ylabel('Force (lbf)');
hold off;

% Display the average peak force
disp(['Average peak force for Back Left: ' num2str(avg_peak_forceBL) ' lbf']);
disp(['Standard Deviation of Peak Values: ' num2str(std_peak_forceBL)]);
% I'm gonna plot the peak values with each other now.
% Convert peak locations to seconds
peak_timesFL = data{peak_locsFL,1} - data{1,1};
peak_timesFR = data{peak_locsFR,1} - data{1,1};
peak_timesBR = data{peak_locsBR,1} - data{1,1};
peak_timesBL = data{peak_locsBL,1} - data{1,1};

% Plot the force data from each load cell as a function of time
plot(peak_timesFL, peak_valuesFL, 'b')
hold on
plot(peak_timesFR, peak_valuesFR, 'r')
plot(peak_timesBL, peak_valuesBL, 'm')
plot(peak_timesBR, peak_valuesBR, 'g')
title({'Peak ML Forces for Each Step:' 'All Peaks'});
xlabel('Time (seconds)');
ylabel('Force (lbf)');

% Add dotted line and label for each average peak force
plot([peak_timesFL(1) peak_timesFL(end)], [avg_peak_forceFL avg_peak_forceFL], '--b')
plot([peak_timesFR(1) peak_timesFR(end)], [avg_peak_forceFR avg_peak_forceFR], '--r')
plot([peak_timesBR(1) peak_timesBR(end)], [avg_peak_forceBL avg_peak_forceBL], '--m')
plot([peak_timesBL(1) peak_timesBL(end)], [avg_peak_forceBR avg_peak_forceBR], '--g')

% Create a legend with the sensor values
lgd1 = legend(sprintf('FL: %.1f lbf', avg_peak_forceFL), ...
    sprintf('FR: %.1f lbf', avg_peak_forceFR), ...
    sprintf('BL: %.1f lbf', avg_peak_forceBL), ...
    sprintf('BR: %.1f lbf', avg_peak_forceBR));
set(lgd1, 'Location', 'southoutside', 'Interpreter', 'none','Orientation', 'horizontal', 'NumColumns', 2);
hold off
disp(['Average of the Total Peak Mediolateral Force as %BW:  ' num2str(((((avg_peak_forceFL+avg_peak_forceFR)+(avg_peak_forceBR+avg_peak_forceBL))/2)/subjectWt)*100) '%']);
% Now, I'm going to merge the right and left sides to see if we can find a change!
% Merging the both right and left sensors together.
% Taking an average of the same side assumes the subject was roughly in
% the center of the treadmill for the entire test.

force_right = front_right+back_right;
force_left = front_left+back_left;

%Do the same peak finding as before, these peaks are now just realative
%values.
[peak_values_right, peak_locs_right] = findpeaks(force_right,'MinPeakDistance',10);
[peak_values_left, peak_locs_left] = findpeaks(force_left,'MinPeakDistance',10);

% Calculate the average peak force
avg_peak_force_right = mean(peak_values_right);
avg_peak_force_left = mean(peak_values_left);

% Calculate the std of peak force
std_peak_force_right = std(peak_values_right);
std_peak_force_left = std(peak_values_left);

plot(time, force_left, 'Color' ,[1 0.5 0])
hold on
plot(time, force_right, 'c')
% uncomment the two lines below if you would like to verify the peaks for the new data set.
% quiver(data{peak_locs_right,1}, peak_values_right, zeros(size(peak_locs_right)), 5*ones(size(peak_locs_right)), 'r', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
% quiver(data{peak_locs_left,1}, peak_values_left, zeros(size(peak_locs_left)), 5*ones(size(peak_locs_left)), 'b', 'LineWidth', 1, 'MaxHeadSize', 0.5,'AutoScaleFactor',0.2);
legend('Left','Right');
title('ML Force for Each Side of the Treadmill');
xlabel('Time (seconds)');
ylabel('Force (N)');

% Create a legend with the averaged sensor values
lgd2 = legend(sprintf('Left: %.2f lbf', avg_peak_force_left), ...
    sprintf('Right: %.2f lbf', avg_peak_force_right));
set(lgd2, 'Location', 'southoutside', 'Interpreter', 'none','Orientation', 'horizontal', 'NumColumns', 2);
hold off

% what side has the greater mediolateral force?
if avg_peak_force_right > avg_peak_force_left
    diff_force = avg_peak_force_right - avg_peak_force_left;
    disp(['The average peak force for the <strong>right side</strong> is greater by <strong>' num2str(diff_force) ' lbf</strong>']);
elseif avg_peak_force_left > avg_peak_force_right
    diff_force = avg_peak_force_left - avg_peak_force_right;
    disp(['The average peak force for the <strong>left side</strong> is greater by <strong>' num2str(diff_force) ' lbf</strong>']);
else
    disp('The average peak force is the same for <strong>both sides</strong>');
end

disp(['Average peak force for Right side: ' num2str(avg_peak_force_right) ' lbf']);
disp(['Average peak force for Left side: ' num2str(avg_peak_force_left) ' lbf']);

disp(['Standard Deviation of Right: ' num2str(std_peak_force_right)]);
disp(['Standard Deviation of Left: ' num2str(std_peak_force_left)]);

disp(['Average of the Total Peak Mediolateral Force as %BW:  ' num2str((((avg_peak_force_right + avg_peak_force_left)/2)/subjectWt)*100) '%']);

% ~~~~~~~~ Chopping time ~~~~~~~~~~
% Now, we will attempt to chop the mediolateral force signals using the Velocity Total from FScan and plot them overtop of each other.
% THE CODE STARTS BY COMPLETE THE RIGHT FOOT, AND THEN REPEATS WITH THE LEFT FOOT

RawFScanR = readtable(filelocationR, 'Range', 'E31:E36030', 'ReadVariableNames', false);
NumericalDataR = table2array(RawFScanR);
indTimMaxR=length(NumericalDataR);


MinSignal=min(NumericalDataR);
CutLine=MinSignal+0.001; % very small threshold for most accurate step indicator - virtually zero.
% very small, should be usable for both total velocity and force data.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   Where we look at 10 steps to make sure we really have a rising
%        footstrike.   If so, point i is a footstrike
% We first smoothe the data with a moving average filter
sNumericalDataR=smooth(NumericalDataR,10);
StrkIndR=[];
LiftIndR=[];
for indTim=1:indTimMaxR-20
    if(sNumericalDataR(indTim)<= CutLine & sNumericalDataR(indTim+1:indTim+20)>CutLine)
         StrkIndR=[StrkIndR indTim];    % This line appends the indTime of every strike to create a vector
    end
    if(sNumericalDataR(indTim)>= CutLine & sNumericalDataR(indTim+1:indTim+20)<CutLine)
        LiftIndR=[LiftIndR indTim];
    end
end
plot(time,force_right,'c');
hold on

plot(StrkIndR/400,5,'v','MarkerEdgeColor','red');
plot(LiftIndR/400, 5, '^','MarkerEdgeColor','blue');
NumStrkR=length(StrkIndR);
StrikDiffR=diff(StrkIndR);
avgStrikDiffR = mean(StrikDiffR/400);
stds_StrikDffR=std(StrikDiffR/400);
title({'ML Force for Right Side of the Treadmill','with strike/lift indicators'});
xlabel('Time (seconds)');
ylabel('Force (N)');
hold off
% We now repeat for the left foot:
RawFScanL = readtable(filelocationL, 'Range', 'E31:E36030', 'ReadVariableNames', false);
NumericalDataL = table2array(RawFScanL);
indTimMaxL=length(NumericalDataL);


MinSignal=min(NumericalDataL);
CutLine=MinSignal+0.0001; % very small threshold for most accurate step indicator - virtually zero.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   Where we look at 10 steps to make sure we really have a rising
%        footstrike.   If so, point i is a footstrike
% We first smoothe the data with a moving average filter
sNumericalDataL=smooth(NumericalDataL,10); %%%%%
StrkIndL=[];
LiftIndL=[];
for indTim=1:indTimMaxL-20
    if(sNumericalDataL(indTim)<= CutLine & sNumericalDataL(indTim+1:indTim+20)>CutLine)
         StrkIndL=[StrkIndL indTim];    % This line appends the indTime of every strike to create a vector
    end
    if(sNumericalDataL(indTim)>= CutLine & sNumericalDataL(indTim+1:indTim+20)<CutLine)
        LiftIndL=[LiftIndL indTim];
    end
end

plot(time,force_left,'Color' ,[1 0.5 0]);
hold on

plot(StrkIndL/400,5,'v','MarkerEdgeColor','red');
plot(LiftIndL/400, 5, '^','MarkerEdgeColor','blue');
NumStrkL=length(StrkIndL);
StrikDiffL=diff(StrkIndL);
avgStrikDiffL = mean(StrikDiffL/400);
stds_StrikDffL=std(StrikDiffL/400);
title({'ML Force for Left Side of the Treadmill','with strike/lift indicators'});
xlabel('Time (seconds)');
ylabel('Force (N)');
hold off
% We are now ready to place the strike indexes in a table.  Tables need to have the same length vectors.   It is possible the both left and right have the same number of strikes, or differ by 1.   If they differ, we will simply drop the last element in the longer vector.  Thus the approach is to find the strike that hits first (left or right) and then if that vector is longer, throw away the last step in that vector.
if (length(StrkIndR) ~= length(StrkIndL))  % the following lines are executed only if the two vectors are not equal length

    if(StrkIndL(1)<StrkIndR(1))    % the first step is left, so there must be more left than right
        StrkIndL(length(StrkIndL))=[];   %remove the last left step
    else
        StrkIndR(length(StrkIndR))=[];  % the first step is right, so remove the last right step
        % We need to check futher that the last step is acutally finsihed
        
    end
end

% At this point, we have vectors of equal length relative to the number of stikes for each foot.   But if the last step is not completed by a lift, we need to remove one more from both vectors.   Rather than complicate the algorithm, we just remove the last step from both:
StrkIndL(length(StrkIndL))=[];
  StrkIndR(length(StrkIndR))=[];


% We now trim the lift vector to the same length as the strike vectors
  LiftIndL=LiftIndL(1:length(StrkIndL));
  LiftIndR=LiftIndR(1:length(StrkIndR));
% We are going to arrange the step contact indices in a table, and then sort the table based on the time.    The table is the first contact for a given index, then a horizontal sequence (i.e., row vector) of all subsequent contact indices of that type.
  ContactType = {'StrkIndL';'LiftIndL';'StrkIndR';'LiftIndR'};
  TimInd=[StrkIndL;LiftIndL; StrkIndR; LiftIndR];
   StepIndTable=table(ContactType,TimInd); 
   SST=sortrows(StepIndTable,'TimInd');% SST = Sorted step table. Notice need to tell it to sort on TimInd
% We now have a table of sorted contact indices.  The left column of the table is the type of contact, in order, running down, 1 to 4.    Thus, you read the table down a column, then go back to the top of the next column to follow the contacts.   Below, we will convert this into a sequence of contacts as a column vector (column 1), and then a numeric value for the type of contact in column 2.  We define the contact types numerically (contact type numeric descriptor):
% 1= Strike Left, 2 = Lift Left, 3=Strike Right, 4 = Lift Right
ACI=table2array(SST(:,2));%this converts the numeric entires to array contact Idices
   SSC=[]; % WE define a vector SSC which will be the sequence of step contacts
   
   for ic=1:length(StrkIndR) % all the contact indices are same lenght; use one here
      SSC=cat(1, SSC,ACI(1:4,ic));  %this concatentates the indices
   end
% produce the contact type numeric descriptor (CTND)
% First step is to create an ordered cell array of the contact descriptors from the
% sorted step table (SST):
OrdCellArray=SST.ContactType;
% You need to convert the elements to strings.  Matlab will do the
% conversion using the following, but must have same lenght string (we do,
% have equal lenght names):
OrdConType=cell2mat(OrdCellArray);
for k=1:4   % k is a counting index; we compare each element
            % note you must use string comparision, strcmp:
    if strcmp(OrdConType(k,:), 'StrkIndL')  CTND(k)=1; end
    if strcmp(OrdConType(k,:), 'LiftIndL')  CTND(k)=2; end
    if strcmp(OrdConType(k,:), 'StrkIndR')  CTND(k)=3; end
    if strcmp(OrdConType(k,:), 'LiftIndR')  CTND(k)=4; end
end
% We wil create a second dimension to the Sequence of Step Indices (SSC) so the second column tells the type of indice.  Start by adding a column of zeros to the SSC, the assign the contact type numeric descriptor
LenSSC=length(SSC);
AdCol=zeros(LenSSC,1);
SSC=[SSC AdCol];

ik=1;    % counter indext for numeric descriptor
for ic = 1:LenSSC
    if(ik>4)ik=1; end
    SSC(ic,2)=CTND(ik);
    ik=ik+1;
end
