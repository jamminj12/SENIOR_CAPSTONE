% chop_envelopes_V104_60s_peak.m (developed as VTCutPlusMin_Feb25_V104.mlx)
% Step 1 of 2. Cuts the acoustic envelope into one extended stance per footstep, using foot strike/lift times from the F-Scan COF-velocity export.
% Set for 60 s F-Scan trials (reads 24,000 samples at 400 Hz) and a 400-sample 'peak' envelope.
% Run this first, then run the two plotter scripts in the same MATLAB workspace. See README.md.
%
% ---- original header and revision history below ----
% VTCutPlusMin_Feb25_V104.m
% feb 25 2023 mods by Geo Richards
% This code was modifed from V103 to include a file name for the exported envelopes, and the automatically runs the left and right plotter codes.   The output data file will have the upper envelopes for both left and right feet with a name like this:
% <speed>_<subject>_<condition>_OUTPUT.mat
% The variables in the file are the upper envelopes for the number of steps recorded.   The Xsto_L is the left x-axis in time (seconds) and Ysto_L is the left envelope.
% Prior mods listed below:
% 8-13-22, mods by Geo Richards
% This version is to produce chopouts for the center of force velocity.  The only changes from baseline are in what goes into the chop
% This is a revision of code developed by Aaron Hammer-Huber 2-25-2022.
%  Modifications especially showing comments on each line.   Modified by Geo Richards.
% Modified by Jesse Greyshock 3-28-2022 to be usable to for COF Velocity total data.
% Comments added:  
% How to set the range for import?   The Tekscan files are currently recorded at 400 Hz for 60 seconds, meaning we have 24,000 data points in the time series.  The ASCII exported file has 30 rows on top to report various data sets, meaning the actual data starts at row 31, and then counts an additional 24,000 rows.    This seems to be missing one data point, unless Fscan starts the recording after one clock cycle?  (i.e., 0+0.0025 sec) is the end of the first clock cycle at 400Hz.   You can inspect the file and see the data ends at 24,300, with one more line after for an @@ symbol located in cell A24031
% Notice that the the time stamp in absolute time is included...down to the millisecond; this would solve our synch problems if we could get the same from audacity?     Also note the the time recored by F-scan is "off" due to rounding.
% Also, notice that the export sends out just one foot at a time; you need to export left and right in two steps.   Click on the left or right foot image to pick one or the other.  IT TAKES A LONG TIME TO EXPORT; expect 10 minutes or more for each foot.
% Below is information about the matlab function that reads the CSV file.  
% to get csv out of fscan:
% get to main fscan screen (don't need to open a patient)
% go to file -> open then select the movie you want to export
% don't add either foot's recording to the database, its not needed
% click the "show panes" button (looks like a blue/red square divided into
% 4 parts)
% select "create a new graph"
% you should see a panel pop up with a force vs time graph
% click the "objects" button (looks like a red open box, just right of "show
% panes")
% select the "panes" object from the list, then choose "save ascii"
% choose the top checkbox, hit ok, and choose where to save it
% choose "force" in the top left menu and "time" in the bottom left menu
% hit ok, and it should save. make sure to change the file location below
% to where your file is saved

clc


clearvars
% ENSURE THAT THE .xls FILE AND THE .wav FILE MATCH FOR THE DESIRED THE DATE AND RUNNING TRIAL. CHECK NAMING NOMENCLATURE AT    the project's shared "Reduced Data" folder   AS WELL AS THE MASTER SCHEDULE.
  
     subjectWt = 150      % the subject weight in pounds. EXAMPLE VALUE: set this per subject
    FdataHz = 400       % the forced data (Fscan ) frequency
  % input .xls files that have VT as a suffix
    % BE SURE RIGHT AND LEFT ASSIGNED CORRECT HERE!

    filelocationR = 'SUBJECT_R_VT.xls';   % EXAMPLE NAME: F-Scan export (COF velocity total) for the RIGHT foot
    filelocationL = 'SUBJECT_L_VT.xls';   % EXAMPLE NAME: F-Scan export (COF velocity total) for the LEFT foot
    filenameOUTPUT = 'TRIAL_OUTPUT.mat'   % EXAMPLE NAME: output file for the envelopes (used by the L/R plotter scripts)
    %% Read Audio File
       audiofile = 'SUBJECT_TRIAL_F.wav';   % [INPUT] EXAMPLE NAME: filtered audio file for the same trial, in form 'filename.wav'

    [w,Fs] = audioread(audiofile);          % Reads audio file and outputs instantaneous frequency (w) and sample rate (Fs)

w = w(:,1);

audioTime = timetable(seconds((0:length(w)-1)'/Fs),w); % Convert to Time table for signal analyzer
   
% THE CODE STARTS BY COMPLETE THE RIGHT FOOT, AND THEN REPEATS WITH THE LEFT FOOT

RawFScanR = readtable(filelocationR, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataR = table2array(RawFScanR);
indTimMaxR=length(NumericalDataR);


MinSignal=min(NumericalDataR);
CutLine=MinSignal+0.00000001; % very small threshold for most accurate step indicator - virtually zero.
% very small, should be usable for both total velocity and force data.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   Where we look at 10 steps to 
%       make sure we really have a rising value.   If so, point i is a footstrike
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
xaxis=[1:indTimMaxR];
plot(xaxis,sNumericalDataR);
hold on

plot(StrkIndR,1,'v','MarkerEdgeColor','red');
plot(LiftIndR, 1, '^','MarkerEdgeColor','blue');
legend(filelocationR, 'Interpreter','none')
title('Data from ',audiofile, 'Interpreter','none');
ylabel('COF Velocity Magnitude (cm/s)')
xlabel('Data Point Indice')
%
%Y = diff(X) calculates differences between adjacent elements of X along the 
% first array dimension 
% whose size does not equal 1:If X is a vector of length m, 
% then Y = diff(X) returns a vector of length m-1. 
% The elements of Y are the differences between adjacent elements of X.
%
StrikDiffR=diff(StrkIndR);
% the line above computes the differnece between strike indices expressed
% as the number of data points; i.e., if the strike difference is 1, then
%  the  real time in seconds between strikes is 1/FdataHz 
% where FdataHz is the Fscan sampling freq.
%   

avgStrikDiffR = mean(StrikDiffR/FdataHz);
stds_StrikDffR=std(StrikDiffR/FdataHz);

hold off
plot(StrikDiffR/FdataHz,'o')
axis([0 100 .5 1])
ylabel('Current-previous strike time (sec)')
xlabel('Strike Number')
meantxt=num2str(avgStrikDiffR);
stdtext=num2str(stds_StrikDffR);
legend(filelocationR, 'Interpreter','none')
stringpl={'mean =' meantxt};
text(10,.55,stringpl )
stringpl={'stds =' stdtext};
text(50,.55,stringpl )
% We now repeat for the left foot:
RawFScanL = readtable(filelocationL, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataL = table2array(RawFScanL);
indTimMaxL=length(NumericalDataL);


MinSignal=min(NumericalDataL);
CutLine=MinSignal+0.00001; % very small threshold for most accurate step 
% indicator - virtually zero.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   
% Where we look at 10 steps to make sure we really have a rising
%        footstrike.   If so, point i is a footstrike
% We first smoothe the data with a moving average filter
sNumericalDataL=smooth(NumericalDataL,10); %%%%%
StrkIndL=[];
LiftIndL=[];
for indTim=1:indTimMaxL-20
    if(sNumericalDataL(indTim)<= CutLine & sNumericalDataL(indTim+1:indTim+20)>CutLine)
         StrkIndL=[StrkIndL indTim];    % This line appends the indTime of every strike 
                                        % to create a vector
    end
    if(sNumericalDataL(indTim)>= CutLine & sNumericalDataL(indTim+1:indTim+20)<CutLine)
        LiftIndL=[LiftIndL indTim];
    end
end
xaxis=[1:indTimMaxL];
plot(xaxis,sNumericalDataL);
hold on

plot(StrkIndL,1,'v','MarkerEdgeColor','red');
plot(LiftIndL, 1, '^','MarkerEdgeColor','blue');
legend(filelocationL, 'Interpreter','none');
title('Data from ',audiofile, 'Interpreter','none');
ylabel('COF Velocity Magnitude (cm/s)')
xlabel('Data Point Indice')

NumStrkL=length(StrkIndL);
StrikDiffL=diff(StrkIndL);
avgStrikDiffL = mean(StrikDiffL/FdataHz);
stds_StrikDffL=std(StrikDiffL/FdataHz);

hold off
plot(StrikDiffL/FdataHz,'o')
axis([0 100 .5 1])
ylabel('Current-previous strike time (sec)')
xlabel('Strike Number')
meantxt=num2str(avgStrikDiffL);
stdtext=num2str(stds_StrikDffL);
legend(filelocationL, 'Interpreter','none')
stringpl={'mean =' meantxt};
text(10,.55,stringpl )
stringpl={'stds =' stdtext};
text(50,.55,stringpl )
hold off
% We are now ready to place the strike indexes in a table.  Tables need to have the same length vectors.   It is possible the both left and right have the same number of strikes, or differ by 1.   If they differ, we will simply drop the last element in the longer vector.  Thus the approach is to find the strike that hits first (left or right) and then if that vector is longer, throw away the last step in that vector.
if (length(StrkIndR) ~= length(StrkIndL))  % the following lines are executed only if 
                                           % the two vectors are not equal length

    if(StrkIndL(1)<StrkIndR(1))    % the first step is left, so there must be more 
                                   % left than right

        StrkIndL(length(StrkIndL))=[];   %remove the last left step
    else
        StrkIndR(length(StrkIndR))=[];  % the first step is right, so remove 
                                        % the last right step
        % We need to check futher that the last step is acutally finsihed
        
    end
end

% At this point, we have vectors of equal length relative to the number of stikes for each foot.   But if the last step is not completed by a lift, we need to remove one more from both vectors.   Rather than complicate the algorithm, we just remove the last step from both:
StrkIndL(length(StrkIndL))=[];
  StrkIndR(length(StrkIndR))=[];


% We now trim the lift vector to the same length as the strike vectors
  LiftIndL=LiftIndL(1:length(StrkIndL));
  LiftIndR=LiftIndR(1:length(StrkIndR));
% We are going to arrange the step contact indices in a table, and then sort the table based on the time.    The table is the first contact for a given index, then a horizontal sequence (i.e., row vector) of all subsequent contact indices of that type.  For use below the sortrows function is used:
% B = sortrows(A) sorts the rows of a matrix in ascending order based on the elements in the first column. When the first column contains repeated elements, sortrows sorts according to the values in the next column and repeats this behavior for succeeding equal values.
  ContactType = {'StrkIndL';'LiftIndL';'StrkIndR';'LiftIndR'};
  TimInd=[StrkIndL;LiftIndL; StrkIndR; LiftIndR];
   StepIndTable=table(ContactType,TimInd); 
   SST=sortrows(StepIndTable,'TimInd');% SST = Sorted step table. Notice need to tell 
                                       % it to sort on TimInd
% We now have a table of sorted contact indices.  The left column of the table is the type of contact, in order, running down, 1 to 4.    Thus, you read the table down a column, then go back to the top of the next column to follow the contacts.   Below, we will convert this into a sequence of contacts as a column vector (column 1), and then a numeric value for the type of contact in column 2.  We define the contact types numerically (contact type numeric descriptor):
% 1= Strike Left, 2 = Lift Left, 3=Strike Right, 4 = Lift Right
% Also for use below:    C = cat(dim,A,B) concatenates B to the end of A along dimension dim when A and B have compatible sizes (the lengths of the dimensions match except for the operating dimension dim).
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
% We are ready to plot the the force time series, and the contact indices (left is green, right is red)
xaxis=[1:indTimMaxR];
rtimF=(xaxis-1)/FdataHz;
plot(rtimF,sNumericalDataR, 'Color','red','LineWidth',1.0);
hold on
plot(rtimF,sNumericalDataL, 'Color',[0.46 0.67 0.10],'LineWidth',1.0);
% create another counter to add the contact types
axis([0 60 -20 200])
for ic = 1:LenSSC
    X=(SSC(ic,1)-1)/FdataHz;
    if(SSC(ic,2)==1) plot(X,-5,'v','MarkerFaceColor',[0.46 0.67 0.10]);end
    if(SSC(ic,2)==2) plot(X,-5,'^','MarkerFaceColor',[0.46 0.67 0.10]);end
    if(SSC(ic,2)==3) plot(X,-15,'v','MarkerFaceColor','red');end
    if(SSC(ic,2)==4) plot(X,-15,'^','MarkerFaceColor','red');end
end
ylabel('COF Velocity Magnitude (cm/s)')
xlabel('Time (seconds)')
hold off
% Now we want to plot the audio signal along with the step signal.    To do that, we need to normalize both signals so they can show approximately the same magnitudes.   We will normalize as follows:
% COF velocity signals - normalize by the 100 cm/s
% Acoustic signals:  All multiplied by 10x (based on past data sets/experience
%%%%%%  The lines below have been moved up to the  top %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[w,Fs] = audioread(audiofile);          % Reads audio file and outputs instantaneous frequency (w) and sample rate (Fs)

%w = w(:,1);

%audioTime = timetable(seconds((0:length(w)-1)'/Fs),w); % Convert to Time table for signal analyzer

% soundsc(w,Fs)                         % USE to listen to audio file
%%%%%%%%%%%%%%%%%%%%%%%%%%   END OF MOVED SECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Parameters

 % The size to display in seconds
sizeSamp = length(w);                   % Returns number of samples in audio duration
rtim=0:1/Fs:(sizeSamp-1)/Fs;
rtim=rtim';
plot(rtim,w)
% How to we get the Fscan data into real time?  We will refer to itimF as the index time for Fscan signals. All the Fscan data is collected at FdataHz, so that each indice is at  real Fscan time = rftim = (itimF-1)/FdataHz
COFVnorm = 200 % normalization factor for COF velocity
xaxis=[1:indTimMaxR];
plot((xaxis-1)/FdataHz,sNumericalDataR/COFVnorm, 'Color','red','LineWidth',1.0);
hold on
plot((xaxis-1)/FdataHz,sNumericalDataL/COFVnorm, 'Color',[0.46 0.67 0.10],'LineWidth',1.0);
% create another counter to add the contact types
% dividing by subjectWt is used to normalize the graph for viewing with the
% acoustic signal. Not actually needed for COF Velocity calculations. 
axis([0 65 -2 2])
for ic = 1:LenSSC
    X=SSC(ic,1);
    if(SSC(ic,2)==1) plot((X-1)/FdataHz,-0.08,'v','MarkerFaceColor',[0.46 0.67 0.10], 'MarkerSize',10);end
    if(SSC(ic,2)==2) plot((X-1)/FdataHz,-0.08,'^','MarkerFaceColor',[0.46 0.67 0.10],'MarkerSize',10);end
    if(SSC(ic,2)==3) plot((X-1)/FdataHz,-0.15,'v','MarkerFaceColor','red','MarkerSize',10);end
    if(SSC(ic,2)==4) plot((X-1)/FdataHz,-0.15,'^','MarkerFaceColor','red','MarkerSize',10);end
end
modSig=w*5-1;
plot(rtim,modSig,'b');
[up lo]=envelope(modSig,400,'peak');
plot(rtim,up,'c','LineWidth',2.0);
plot(rtim,lo,'c','LineWidth',2.0);
title('Data from ',audiofile, 'Interpreter','none');
xlabel('Time (seconds)')
ylabel('Normalized/scaled signals')

% We are going to create arrays for the left and right foot envelope, chopping based on the strike indices, left and right.   Notice we have already trimmed these indices so they are the same length for strikes and lifts on each foot.   However, we don't know if the first event is a lift or strike, so we need to consider two cases:   if the strike is first in the sequence, we can proceed.   If the lift is first in the sequence, we need connect the first strike with the second lift, and skip the last strike (it has no lift to pair with).
% For use below, the conversion from itimF to itim is round(itimF/FdataHz)*Fs = itim
LenInd=length(StrkIndL);   % both left and right indice vectors have the same length; see above
midftframeL=zeros(LenInd,1); %this will define the middle of LEFT foot contant in Fscan frame indices
midftframeR=zeros(LenInd,1); %this will define the middle of RIGHT foot contant in Fscan frame indices
%create the left foot cutouts
if StrkIndL(1)<LiftIndL(1)   %the left starts with a strike, use strike and lift pairs

    for ic = 2:LenInd %skip the first one, since we are graphing back to before
        cutA=round(StrkIndL(ic)/FdataHz*Fs);  % this is the itim value for A
        cutB=round(LiftIndL(ic)/FdataHz*Fs);  % this is the itim value for B
       
        % this is where we modify the length of the chop to extend beyond the foot
% strike&lift pair.   We calculate the time the foot is on the ground, and
% then add that much time to the front and back of the strike&lift pair
        deltBA= cutB-cutA;
        cutB = cutB+deltBA;
        cutA = cutA-deltBA;
        
        %intialize the vector to a common lenght, 1.2 x the first one
        if(ic==2); dimMax=round(1.2*(cutB-cutA)); 
        chopOutLup=zeros(dimMax,LenInd);
        chopOutLlo=zeros(dimMax,LenInd);
       
        end
        Lencut=cutB-cutA + 1 ; % you have to add one to get length OK; e.g., subtracting does not 
            % include end point
            % we will add 1 to the envelope (up/lo) to  simplify graphing in the cutouts below   
        chopOutLup(1:Lencut,ic)=up(cutA:cutB,1)+1;   % the second dimension of 1 is added 
                                                            % for clarity, not really needed
        chopOutLlo(1:Lencut,ic)=lo(cutA:cutB,1)+1;
       
        FtConLenL(ic)=cutB-cutA;   % define the length of this contact for use later
        
        rtimA=(cutA-1)/Fs; % find real time of cut A
        rtimB=(cutB-1)/Fs; % find real time of cut B
        midftframeL(ic)=round((rtimA+rtimB)/2*FdataHz);
        if mod(ic,2); plot([rtimA rtimB], [-0.3 -0.3],'g','LineWidth',2);
            else plot([rtimA rtimB], [-0.33 -0.33],'g','LineWidth',2); end
    end

else
    for ic=2:LenInd-1  %the left starts with a lift; use the first strike+second lift pairs
        cutA=round(StrkIndL(ic)/FdataHz*Fs);
        cutB=round(LiftIndL(ic+1)/FdataHz*Fs);

        % this is where we modify the length of the chop to extend beyond the foot
% strike&lift pair.   We calculate the time the foot is on the ground, and
% then add that much time to the front and back of the strike&lift pair
        deltBA= cutB-cutA;
        cutB = cutB+deltBA;
        cutA = cutA-deltBA;

          %intialize the vector to a common lenght, 1.2 x the first one
            if(ic==2); dimMax=round(1.2*(cutB-cutA)); 
            chopOutLup=zeros(dimMax,LenInd-1);
            chopOutLlo=zeros(dimMax,LenInd-1);
           
            end
            Lencut=cutB-cutA+1;
            chopOutLup(1:Lencut,ic)=up(cutA:cutB,1)+1;
            chopOutLlo(1:Lencut,ic)=lo(cutA:cutB,1)+1;
           
            FtConLenL(ic)=cutB-cutA;   % define the length of this contact for use later

            rtimA=(cutA-1)/Fs; % find real time of cut A
            rtimB=(cutB-1)/Fs; % find real time of cut B
            midftframeL(ic)=round((rtimA+rtimB)/2*FdataHz);
            if mod(ic,2); plot([rtimA rtimB], [-0.3 -0.3],'g','LineWidth',2);
            else plot([rtimA rtimB], [-0.33 -0.33],'g','LineWidth',2); end

    end
end
% Repeat the same approach for the right foot
if StrkIndR(1)<LiftIndR(1)   %the right starts with a strike, use lift and strike pairs

    for ic = 2:LenInd
        cutA=round(StrkIndR(ic)/FdataHz*Fs);
        cutB=round(LiftIndR(ic)/FdataHz*Fs);
% this is where we modify the length of the chop to extend beyond the foot
% strike&lift pair.   We calculate the time the foot is on the ground, and
% then add that much time to the front and back of the strike&lift pair
        deltBA= cutB-cutA;
        cutB = cutB+deltBA;
        cutA = cutA-deltBA;

        %intialize the vector to a common lenght, 1.2 x the first one
        if(ic==2); dimMax=round(1.2*(cutB-cutA)); 
        chopOutRup=zeros(dimMax,LenInd);
        chopOutRlo=zeros(dimMax,LenInd);

        end
        Lencut=cutB-cutA + 1 ; % you have to add one to get lenght OK
        chopOutRup(1:Lencut,ic)=up(cutA:cutB,1)+1;   % the second dimension of 1 is added for clarity, not really needed
        chopOutRlo(1:Lencut,ic)=lo(cutA:cutB,1)+1;
       
        FtConLenR(ic)=cutB-cutA;   % define the length of this contact for use later

         rtimA=(cutA-1)/Fs; % find real time of cut A
         rtimB=(cutB-1)/Fs; % find real time of cut B
         midftframeR(ic)=round((rtimA+rtimB)/2*FdataHz);
         if mod(ic,2); plot([rtimA rtimB], [-0.4 -0.4],'r','LineWidth',2);
         else plot([rtimA rtimB], [-0.43 -0.43],'r','LineWidth',2); end
    end

else
    for ic=2:LenInd-1  %the left starts with a lift; use the first strike+second lift pairs
        cutA=round(StrkIndR(ic)/FdataHz*Fs);
        cutB=round(LiftIndR(ic+1)/FdataHz*Fs);
% this is where we modify the length of the chop to extend beyond the foot
% strike&lift pair.   We calculate the time the foot is on the ground, and
% then add that much time to the front and back of the strike&lift pair
        deltBA= cutB-cutA;
        cutB = cutB+deltBA;
        cutA = cutA-deltBA;

          %intialize the vector to a common lenght, 1.2 x the first one
            if(ic==2); dimMax=round(1.2*(cutB-cutA)); 
            chopOutRup=zeros(dimMax,LenInd-1);
            chopOutRlo=zeros(dimMax,LenInd-1);
          
            end
            Lencut=cutB-cutA+1;
            chopOutRup(1:Lencut,ic)=up(cutA:cutB,1)+1;
            chopOutRlo(1:Lencut,ic)=lo(cutA:cutB,1)+1;
            
            FtConLenR(ic)=cutB-cutA;   % define the length of this contact for use later

         rtimA=(cutA-1)/Fs; % find real time of cut A
         rtimB=(cutB-1)/Fs; % find real time of cut B
         midftframeR(ic)=round((rtimA+rtimB)/2*FdataHz);
         if mod(ic,2); plot([rtimA rtimB], [-0.4 -0.4],'r','LineWidth',2);
         else plot([rtimA rtimB], [-0.43 -0.43],'r','LineWidth',2); end

    end
end
% The chopOutABC vector uses nomenclature A = Left or Right (R,L),    BC = up or lo for the upper or lower.
