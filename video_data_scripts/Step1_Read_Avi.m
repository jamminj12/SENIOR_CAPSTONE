% Author: Gina Kim (2022-2023 capstone team). Not written by Jesse Greyshock.
% Part of the Acoustic Biomechanics senior capstone; see README.md in this folder.
% Hardcoded file paths and file names were replaced with placeholders.

clc
clear all

% INPUTS
% [vidfiln workingDir] = uigetfile('*.avi')
workingDir = 'C:\path\to\output_folder';   % folder where the frame images are saved
vidfiln = 'your_video.avi';   % name of the .avi file (high-speed camera export)
picfiln = 'images2';                     %file name for frame image location

start_time = 26;                        % time of video after clap
frames = 45;                             %number of frames to save



%CALCULATIONS - DO NOT EDIT
mkdir(workingDir)
mkdir(workingDir,picfiln)

% read the avi
mov=VideoReader(vidfiln);

fr = mov.FrameRate;

fstart = start_time*fr;
fend = fstart+frames;

ii = 1;

while hasFrame(mov)
    
    if ii > fstart
       img = readFrame(mov);
       filename = [sprintf('%03d',ii) '.jpg'];
       fullname = fullfile(workingDir,picfiln,filename);
       imwrite(img,fullname)    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
       ii = ii+1;
    else
         ii = ii+1;
    end
   
   if ii > fend
       break
   end
   
end