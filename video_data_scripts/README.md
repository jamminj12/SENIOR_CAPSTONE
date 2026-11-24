# Video data scripts (Gina Kim's work)

These two MATLAB scripts were written by **Gina Kim**, a member of the 2022-2023 Acoustic Biomechanics capstone team. They are included here so the full capstone workflow lives in one place. I did not write them. Hardcoded file paths and file names in the scripts were replaced with placeholders; the logic is unchanged.

## What they do

The team recorded subjects' feet from the side with a Ninox 300C high-speed camera (knees down, against a black backdrop). A small flashlight was clipped to the shoelaces so the foot could be tracked as the brightest point in each frame.

| Script | Purpose |
|---|---|
| `Step1_Read_Avi.m` | Reads the `.avi`, skips ahead to the time after the audio-sync clap, and saves a set of frames as numbered `.jpg` images |
| `Step2_VideoData_Pos_Vel_Accel.m` | Loads the saved frames, lets you pick the region containing the feet, finds the brightest pixel in each frame, and computes x/y position, velocity and acceleration with 3-point differentiation. Plots all six |

## How to run

**Step 1: `Step1_Read_Avi.m`**
1. Set `workingDir` to the folder for the output and `vidfiln` to the `.avi` file.
2. Set `picfiln` to a name for the sub-folder where the frame images will be saved.
3. Watch the video and note the time (seconds) just after the clap is fully out of view. Put it in `start_time`.
4. Set `frames` to how many frames to save. More frames means longer processing. About 1000 frames of slow-motion video covers roughly three steps.
5. Run it.

**Step 2: `Step2_VideoData_Pos_Vel_Accel.m`**
1. Set `d_im`, the number of images to jump by. Use 1 for real-time speed; larger values skip frames.
2. Run it and pick any one of the saved images.
3. Figure 1 shows that image. At the command-line prompts, enter `ymin`, `ymax`, `xmin` and `xmax` so the box covers only the feet against the black background. The y axis increases downward in image coordinates.

## Known limitations (from the scripts' own notes)

- Positions are in **pixels** and time is in **frames**. Converting to inches and seconds was still on the to-do list, even though some plot labels already say inches and seconds.
- The y-position plot looks upside down because image y increases downward.
- The notes mention that every other saved image seemed to be a new movement, a quirk of how the slow-motion video was recorded.
- Brightest-point tracking is noisy because the flashlight is not a perfect point source. Averaging the brightest few points per frame was suggested as an improvement.

## Not included

The final project report also describes later versions of the video workflow (`VideoData_Full_Process_V2.m`, `Plot_Compare_Foot_Position_V2.m` and `finding_peaks_V3.m`). They are not in this repo.
