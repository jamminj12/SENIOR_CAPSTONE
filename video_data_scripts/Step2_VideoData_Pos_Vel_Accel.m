% Author: Gina Kim (2022-2023 capstone team). Not written by Jesse Greyshock.
% Part of the Acoustic Biomechanics senior capstone; see README.md in this folder.
% Hardcoded file paths and file names were replaced with placeholders.

clc
close all
clear all

% number of images to jump by (for real speed, d_im = 1, for slow motion can go higher)
d_im = 12;


% FILE LOCATION FOR VIDEO IMAGES
[rand_im, path] = uigetfile('*.jpg')

newpath = cd(path);

% FRAME OF VIEW TO SEARCH FOR BRIGHEST POINT
 RGB=imread(rand_im);
gray = rgb2gray(RGB);

image(RGB)
hold on
plot(0, 0)
axis([0 1600 0 848])
grid on
ax = gca;
ax.GridColorMode = 'manual';
ax.GridColor = 'white';
ax.GridAlpha = 0.75;
    
% INPUTS FOR FRAME BOUNDS
ymin = input('ymin = ');
ymax = input('ymax = ');
xmin = input('xmin = ');
xmax = input('xmax = ');

% finding the first and last images
listing = dir(path);
tot_im = size(dir(path), 1)-2;
c = struct2cell(listing);
filn_cell = c(1, :);

for i = 3:tot_im+2      %offset for 2 empty data cells at beginning
    this_file = char(filn_cell(i));
    just_num = erase(this_file, '.jpg');
    this_file_num(i-2) = str2num(just_num);
end

im_num_min = min(this_file_num);
im_num_max = max(this_file_num);


% re-indexing for image number and field number of cell
image_index = im_num_min:d_im:im_num_max;
d = im_num_min-3;
call_file_index = image_index-d;
t = 0;

for ii = 1:length(image_index)
    %calling each image to be processed
    curr_file = filn_cell{call_file_index(ii)};
    fn = char(curr_file);

    %code to open image and prepare it for processing
    RGB = imread([path fn]);%,'jpg');
    gray = rgb2gray(RGB); 
    I = double(gray);
    res=size(I);

    Ired = zeros(size(I));

    for i = 1:size(I, 1)
        for j = 1:size(I, 2)
            if i <= ymax && i >= ymin && j <= xmax && j >= xmin
                Ired(i, j) = I(i, j);
            end
        end
    end

    % FINDING BRIGHTEST POINT
    [Amaxs, idx] = max(Ired);
    [Amax, Aj] = max(Amaxs);
    Ai = idx(Aj);

    ybright = Ai;
    xbright = Aj;
    
% CHECKING BRIGHTEST POINT TRACKING
%     figure('units', 'normalized', 'outerposition', [0 0 1 1])
%     image(I)
% 
%     brightest point
%     hold on
%     plot(xbright, ybright, 'r*')
% 
%     title('Brightest Point')
%     colormap gray
%     axis equal
%     axis([xmin xmax ymin ymax])
%     
%     
%     w = waitforbuttonpress;
%     close all

Xbright(ii) = xbright;
Ybright(ii) = ybright;
t(ii) = ii;
    
end

% 3 point differentiation - DERIVATIVE
n = length(t);
N = n-1;
h = (t(n)-t(1))/N;

x = Xbright;
y = Ybright;

%VELOCITY
% equation for first x point
xp(1)=	1/(2*h) *(-3*x(1) + 4*x(2) - x(3));
yp(1)=	1/(2*h) *(-3*y(1) + 4*y(2) - y(3));

% equation for all interior points
for i = 2:N
   xp(i)=	(x(i+1) - x(i-1))/(2*h);
   yp(i)=	(y(i+1) - y(i-1))/(2*h);
end

% equation for final x point
xp(n)=	1/(2*h)*(x(n-2) - 4*x(n-1) + 3*x(n));
yp(n)=	1/(2*h)*(y(n-2) - 4*y(n-1) + 3*y(n));

%ACCELERATION
% equation for first x point
xpp(1)=	1/(2*h) *(-3*xp(1) + 4*xp(2) - xp(3));
ypp(1)=	1/(2*h) *(-3*yp(1) + 4*yp(2) - yp(3));

% equation for all interior points
for i = 2:N
   xpp(i)=	(xp(i+1) - xp(i-1))/(2*h);
   ypp(i)=	(yp(i+1) - yp(i-1))/(2*h);
end

% equation for final x point
xpp(n)=	1/(2*h)*(xp(n-2) - 4*xp(n-1) + 3*xp(n));
ypp(n)=	1/(2*h)*(yp(n-2) - 4*yp(n-1) + 3*yp(n));

figure()
subplot(3, 2, 1)
plot(t, x)
xlabel('Frame')
ylabel('X Position (pix)')
title('X Position vs Time')
grid on

subplot(3, 2, 3)
plot(t, xp)
xlabel('Frame')
ylabel('X Velocity (pix/time)')
title ('X Velocity vs Time')
grid on


subplot(3, 2, 5)
plot(t, xpp)
xlabel('Frame')
ylabel('X Acceleration (pix/time^2)')
title ('X Acceleration vs Time')
grid on

subplot(3, 2, 2)
plot(t, y)
xlabel('Time (s)')
ylabel('Y Position (in)')
title('Y Position vs Time')
grid on

subplot(3, 2, 4)
plot(t, yp) 
xlabel('Time (s)')
ylabel('Y Velocity (in/s)')
title ('Y Velocity vs Time')
grid on

subplot(3, 2, 6)
plot(t, ypp)
xlabel('Time (s)')
ylabel('Y Acceleration (in/s^2)')
title ('Y Acceleration vs Time')
grid on