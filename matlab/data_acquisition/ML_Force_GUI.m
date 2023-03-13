%Written by Jesse Greyshock, 3/1/23
% Mediolateral force measurement GUI for the treadmill load cell system (originally BIOMECHblue.m).
% Live-plots the four load cells and logs each trial to a CSV: time (s), A (front left), B (front right), C (back right), D (back left), in pounds.
% Needs: MATLAB R2019b or newer (serialport) and arduino/Treadmill_Load_Cells running on the Arduino. Change the COM port below to match yours.
% See the top-level README.md for the full workflow.

clear all; 
clc;
close all;

global device
device = serialport("COM4",9600) % map to Arduino port

prompt = 'Enter Subject Identifier and Type of Test: (Example: S23AA_L40)';
%if you do not know the naming convention, refer to the master sheet
dlgtitle = 'Naming CSV file';
dims = [1 50];
definput = ".csv";
Name_of_trial = inputdlg(prompt,dlgtitle,dims,definput);


figure(1);
uicontrol('Style','Text',...
    'String','Welcome to the Mediolateral Force Measurement System.',...
    'FontSize',18,...
    'Position', [75 150 400 200]);
uicontrol('Style','Text',...
    'String','This was developed by the 2022-2023 Happy Feet Team!',...
    'FontSize',18,...
    'Position', [75 75 400 200]);
ButtonSTART = uicontrol('Style', 'PushButton', ...
                         'String', 'START',...
                         'Callback', 'uiresume(gcbf);close(gcbf)',...
                         'Position', [300 50 150 40],...
                         'BackgroundColor',[144 238 144]./255);
ButtonTARE = uicontrol('Style', 'PushButton',...
                        'String', 'TARE',...
                        'Callback',@CalmTheScales,...
                         'Position', [100 50 150 40],...
                         'BackgroundColor',[173 216 230]./255);
disp('Press to start collecting data');

%Send START message to device, scales are reset
uiwait(gcf);
disp('Starting')
writeline(device,"START");

%Start Timer
tic

%Set Up Graph
figure(2);
uicontrol('Style','Text',...
    'String','The "STOP" button will end the test and automatically save file.',...
    'FontSize',18,...
    'Position', [0 0 550 400]); %this size bc of weird glitch with graph. 
uicontrol('Style','Text',...
    'String','BE QUIET DURING THE TEST!!!',...
    'FontSize',18,...
    'Position', [0 0 550 300]);
uicontrol('Style','Text',...
    'String','DO NOT TOUCH TREADMILL WHILE RECORDING!!!',...
    'FontSize',18,...
    'Position', [0 0 550 250]);
ButtonEND = uicontrol('Style', 'PushButton', ...
                         'String', 'STOP',...
                         'Callback', 'delete(gcbf)',...
                         'Position', [20 20 150 40],...
                         'BackgroundColor',[255 204 203]./255);
% ButtonTARE = uicontrol('Style', 'PushButton',...
%                         'String', 'TARE',...
%                         'Callback',@CalmTheScales,...
%                          'Position', [200 20 150 40],...
%                          'BackgroundColor',[173 216 230]./255);


figure('name',Name_of_trial{1,1});
% Sensors labeled with the corresponding letters. 
h1 = animatedline("Color",'b'); %sensor A (Front Left)
h2 = animatedline("Color",'r'); %sensor B (Front Right)
h3 = animatedline("Color",'g'); %sensor C (Back Right)
h4 = animatedline("Color",'m'); %sensor D (Back Left)
ax = gca;
ax.YGrid = 'on';
stop = false;
startTime = now;

str = readline(device)
% str = readline(device)
% str = readline(device)

while ~stop
    
    str = readline(device);
    tmr = toc;
    numStrs = split(str,',');
    GtoP = 1/453.592; % input from force sensors is calibrated to grams. Conversion puts this into pounds.
    A = [tmr,str2num(numStrs(1))*GtoP,str2num(numStrs(2))*GtoP,str2num(numStrs(3))*GtoP,str2num(numStrs(4))*GtoP];
    SensorA_FL= str2num(numStrs(1))*GtoP
    SensorB_FR= str2num(numStrs(2))*GtoP
    SensorC_BR= str2num(numStrs(3))*GtoP
    SensorD_BL= str2num(numStrs(4))*GtoP
    Time = tmr

    dlmwrite(Name_of_trial{1,1},A,'delimiter',',','-append');


    % Add points to live animation
    addpoints(h1,tmr,A(2))
    addpoints(h2,tmr,A(3))
    addpoints(h3,tmr,A(4))
    addpoints(h4,tmr,A(5))
    % Update axes automatically with data
    ax.XLim = [tmr-15 tmr];
    ax.YLim = [-5 20]; % guess since ML force is ~10% BW, ylim in lbs.
    drawnow
    grid on
%     legend('Sensor A (FL)','Sensor B(FR)','Sensor C(BR)','Sensor D(BL)')
%     this legend was making graph run slow.
    
    %BUTTON
    if ~ishandle(ButtonEND)
        disp('Loop stopped by user');
        break;
    end

end

%Send END message to device
writeline(device,"END");

close all

function CalmTheScales(ButtonTARE,eventdata)
    global device
    disp('Please wait a couple seconds for tare cycle to complete. Thank you for your patience!')
    writeline(device,"TARE")
    pause(5)
    disp('All done! Ready to test!')
    
    %these are used to chop out the first couple lines of unreadable data.
    %(error mitigation)
    blank1 = readline(device);
    blank2 = readline(device);
    blank3 = readline(device);
    blank4 = readline(device);
end
