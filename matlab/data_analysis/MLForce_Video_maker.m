% MLForce_Video_maker.m
% Renders one trial (.xlsx: time, A-D in lbf) as an animated plot of the four load cells with a 10-second moving window and writes it to an .avi file.
% It writes one frame per sample with a 0.2 s pause each, so it is slow to run. The original file has no author line.
%
% ---- original file below ----
clear all
clc

% Specify the name of the Excel file and the sheet to read from
filename = 'S23XX_Norm.xlsx'; % Make sure it is a .xlsx file. Convert if it is not.

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
back_left = table2array(back_left);% Create a video file

% Create a video file
v = VideoWriter('S23XX_Norm_video.avi');
open(v);

% Create a new figure
figure;

% Set the initial x and y limits of the plot
xlim([1 11]);
ylim([0 10]);

% Initialize the counter
count = 0;

% Loop over each time step in the data
for i = 1:length(time)

    % Update the x-axis limits to create a 10-second moving window
    if time(i) > 10
        xlim([time(i)-10 time(i)]);
    end

    % Clear the previous plot
    clf;

    % Plot the force data for each load cell
    plot(time(1:i), front_left(1:i), 'b', 'LineWidth', 2);
    hold on;
    plot(time(1:i), front_right(1:i), 'r', 'LineWidth', 2);
    plot(time(1:i), back_right(1:i), 'g', 'LineWidth', 2);
    plot(time(1:i), back_left(1:i), 'm', 'LineWidth', 2);

    % Add labels and a legend
    xlabel('Time (s)');
    ylabel('Force (lbf)');
    title('Force Sensor Data');
    legend('Front Left', 'Front Right', 'Back Right', 'Back Left');
    
    % Update the x-axis limits to create a 10-second moving window
    if time(i) > 10
        xlim([time(i)-10 time(i)]);
    end


    % Increment the counter
    count = count + 1;

    % Display the counter
    disp(['Frame ' num2str(count) ' of ' num2str(length(time))]);

    % Capture the current plot as a frame
    frame = getframe(gcf);

    % Write the frame to the video file
    writeVideo(v, frame);

    % Pause for a short time to simulate real-time plotting
    pause(0.2);
end

% Close the video file
close(v);


