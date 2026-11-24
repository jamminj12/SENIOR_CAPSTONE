# Data analysis: mediolateral force scripts

Scripts for analyzing the trials recorded by [`ML_Force_GUI.m`](../data_acquisition). The workflow overview is in the [top-level README](../../README.md).

**Input for all of them:** one trial as `.xlsx` (convert the GUI's CSV), with columns time (s), A, B, C, D, where A is front left, B front right, C back right and D back left. Trials are 90 seconds. Needs MATLAB with the Signal Processing Toolbox.

| Script | What it does |
|---|---|
| `ML_Force_Analysis.m` | Main analysis of one trial: trims to 90 s, removes rogue spikes, finds each step's peak force per sensor, sums front and back sensors per side, and reports the average peak force of each side and as a percentage of body weight. (Developed as `MLForcePlotterV1`.) |
| `MLForcePlotterV1_Chopped.m` | The same analysis plus foot strike/lift detection from the F-Scan COF-velocity ("VT") export of each foot, drawn on the force plots. Leaves the strike/lift indices in the workspace. Needs the F-Scan exports for the same trial (see [`../../acoustic_fscan_analysis`](../../acoustic_fscan_analysis)). |
| `MLForceChopLeft.m`, `MLForceChopRight.m` | Run after `MLForcePlotterV1_Chopped.m`, in the same workspace. Cut the left or right load-cell signal into one segment per foot contact and plot the segments one at a time on a normalized time axis. Rerun `MLForcePlotterV1_Chopped.m` before switching between the left and right script. |
| `MLForce_Right_Left_Difference.m` | Bar chart of right minus left average peak force for each condition (Norm, L40, L20, R40, R20) for one subject. You paste in the average peak left and right values from `ML_Force_Analysis.m`. |
| `AVERAGED_MLForce_Difference.m` | The group version: averages one value per subject for each condition and draws the same style of chart, then a version normalized to the Norm condition. |
| `MLForce_Video_maker.m` | Renders a trial as an animated plot of the four sensors (10-second moving window) and writes an `.avi`. It writes one frame per sample with a 0.2 s pause, so it is slow. The original file has no author line. |

The original authors' headers are kept at the top of each script, below a short description added for this repo.

## What was changed from the originals

- Live scripts exported to `.m` (the `.mlx` files embed their plots).
- Subject-linked values replaced with placeholders: trial and F-Scan file names, subject weight, the plot title in `MLForce_Right_Left_Difference.m`, and the output video name.
- `MLForce_Right_Left_Difference.m` and `AVERAGED_MLForce_Difference.m` had individual subjects' results typed into them. Those are replaced with zeros, and `AVERAGED_MLForce_Difference.m` now uses `mean([...])` in place of dividing by a hardcoded 11. With the zeros, the charts run but are empty.
- No other code changes.

## Known quirks

- `MLForcePlotterV1_Chopped.m` labels the force axis "Force (N)" on three plots (the left/right sum and the two strike/lift plots), while its other plots, and `ML_Force_Analysis.m`'s version of the left/right plot, say lbf. The data is in pounds-force throughout.
- Strike and lift times from the F-Scan are converted to load-cell sample indices assuming a 400 Hz F-Scan rate and the trial's average sampling interval.
- Peak finding uses `MinPeakDistance` = 10 samples, tuned by hand, and does not catch every step. Check the plots.
- Plot titles and some axis limits are hardcoded.
