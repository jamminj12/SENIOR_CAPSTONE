% step_detection_velocity_vs_force.m (developed as StepChopperComparison_JesseCode.mlx)
% Compares foot strike/lift detection from the F-Scan COF-velocity export against detection from the F-Scan force export, and plots both
% on the same axes (velocity markers at rows -5/-10, force markers at rows -20/-25). Standalone: it does not need the other scripts.
%
% ---- original header below ----
%  CREATED BY JESSE GREYSHOCK 4-16-2022
% This code compares the results when chopping the steps using the COF velocity data and the force data. 
% ONLY DIFFERENCE: the velocity uses an extremely small cutline (0.00000001) because it always returns to zero. The force data uses a cutline of 2.5 because of the volatility in the data.
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
    % input .xls files
    filelocationR = 'SUBJECT_R_VT.xls';   % EXAMPLE NAME: F-Scan COF velocity export, RIGHT foot
    filelocationL = 'SUBJECT_L_VT.xls';   % EXAMPLE NAME: F-Scan COF velocity export, LEFT foot
    filelocationR2 = 'SUBJECT_R_F.xls';   % EXAMPLE NAME: F-Scan force export, RIGHT foot
    filelocationL2 = 'SUBJECT_L_F.xls';   % EXAMPLE NAME: F-Scan force export, LEFT foot
    subjectWt = 150      % the subject weight in pounds. EXAMPLE VALUE: set this per subject
    FdataHz = 400       % the forced data (Fscan ) frequency
    %% Read Audio File
       audiofile = 'SUBJECT_TRIAL_F.wav';   % [INPUT] EXAMPLE NAME: audio file for the same trial
% THE CODE STARTS BY COMPLETE THE RIGHT FOOT, AND THEN REPEATS WITH THE LEFT FOOT
RawFScanR = readtable(filelocationR, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataR = table2array(RawFScanR);
indTimMaxR=length(NumericalDataR);


MinSignal=min(NumericalDataR);
CutLine=MinSignal+0.00000001; % very small threshold for most accurate step indicator - virtually zero.
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
xaxis=[1:indTimMaxR];
% Now for Left:
RawFScanL = readtable(filelocationL, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataL = table2array(RawFScanL);
indTimMaxL=length(NumericalDataL);

MinSignal=min(NumericalDataL);
CutLine=MinSignal+2.5; % very small threshold for most accurate step indicator - virtually zero.

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
xaxis=[1:indTimMaxL];
% Now for the force data, similar process:
RawFScanR2 = readtable(filelocationR2, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataR2 = table2array(RawFScanR2);
indTimMaxR2=length(NumericalDataR2);


MinSignal2=min(NumericalDataR2);
CutLine2=MinSignal2+5; % larger threshold for force data
% very small, should be usable for both total velocity and force data.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   Where we look at 10 steps to make sure we really have a rising
%        footstrike.   If so, point i is a footstrike
% We first smoothe the data with a moving average filter
sNumericalDataR2=smooth(NumericalDataR2,10);
StrkIndR2=[];
LiftIndR2=[];
for indTim2=1:indTimMaxR2-20
    if(sNumericalDataR2(indTim2)<= CutLine2 & sNumericalDataR2(indTim2+1:indTim2+20)>CutLine2)
         StrkIndR2=[StrkIndR2 indTim2];    % This line appends the indTime of every strike to create a vector
    end
    if(sNumericalDataR2(indTim2)>= CutLine2 & sNumericalDataR2(indTim2+1:indTim2+20)<CutLine2)
        LiftIndR2=[LiftIndR2 indTim2];
    end
end
RawFScanL2 = readtable(filelocationL2, 'Range', 'E31:E24030', 'ReadVariableNames', false);
NumericalDataL2 = table2array(RawFScanL2);
indTimMaxL2=length(NumericalDataL2);

MinSignal2=min(NumericalDataL2);
CutLine2=MinSignal2+2.5; % very small threshold for most accurate step indicator - virtually zero.

% we want to find the times where the foot strikes, and then leaves. The
% criterion for striking are:

%    NumericalData (i)< CutLine and NumericalDat(i+1:i+10)>Cutline   Where we look at 10 steps to make sure we really have a rising
%        footstrike.   If so, point i is a footstrike
% We first smoothe the data with a moving average filter
sNumericalDataL2=smooth(NumericalDataL2,10); %%%%%
StrkIndL2=[];
LiftIndL2=[];
for indTim2=1:indTimMaxL2-20
    if(sNumericalDataL2(indTim2)<= CutLine2 & sNumericalDataL2(indTim2+1:indTim2+20)>CutLine2)
         StrkIndL2=[StrkIndL2 indTim2];    % This line appends the indTime of every strike to create a vector
    end
    if(sNumericalDataL2(indTim2)>= CutLine2 & sNumericalDataL2(indTim2+1:indTim2+20)<CutLine2)
        LiftIndL2=[LiftIndL2 indTim2];
    end
end
% We are now ready to place the strike indexes in a table.  Tables need to have the same length vectors.   It is possible the both left and right have the same number of strikes, or differ by 1.   If they differ, we will simply drop the last element in the longer vector.  Thus the approach is to find the strike that hits first (left or right) and then if that vector is longer, throw away the last step in that vector.
if (length(StrkIndR) ~= length(StrkIndL))  % the following lines are executed only if the two vectors are not equal length

    if(StrkIndL(1)<StrkIndR(1))    % the first step is left, so there must be more left than right
        StrkIndL(length(StrkIndL))=[];   %remove the last left step
    else
        StrkIndR(length(StrkIndR))=[];  % the first step is right, so remove the last right step
        % We need to check futher that the last step is acutally finsihed
        
    end
end
if (length(StrkIndR2) ~= length(StrkIndL2))  % the following lines are executed only if the two vectors are not equal length

    if(StrkIndL2(1)<StrkIndR2(1))    % the first step is left, so there must be more left than right
        StrkIndL2(length(StrkIndL2))=[];   %remove the last left step
    else
        StrkIndR(length(StrkIndR2))=[];  % the first step is right, so remove the last right step
        % We need to check futher that the last step is acutally finsihed
        
    end
end
% At this point, we have vectors of equal length relative to the number of stikes for each foot.   But if the last step is not completed by a lift, we need to remove one more from both vectors.   Rather than complicate the algorithm, we just remove the last step from both:
StrkIndL(length(StrkIndL))=[];
  StrkIndR(length(StrkIndR))=[];
StrkIndL2(length(StrkIndL2))=[];
  StrkIndR2(length(StrkIndR2))=[];
% We now trim the lift vector to the same length as the strike vectors
  LiftIndL=LiftIndL(1:length(StrkIndL));
  LiftIndR=LiftIndR(1:length(StrkIndR));
  LiftIndL2=LiftIndL2(1:length(StrkIndL2));
  LiftIndR2=LiftIndR2(1:length(StrkIndR2));
% We are going to arrange the step contact indices in a table, and then sort the table based on the time.    The table is the first contact for a given index, then a horizontal sequence (i.e., row vector) of all subsequent contact indices of that type.
  ContactType = {'StrkIndL';'LiftIndL';'StrkIndR';'LiftIndR'};
  TimInd=[StrkIndL;LiftIndL; StrkIndR; LiftIndR];
   StepIndTable=table(ContactType,TimInd); 
   SST=sortrows(StepIndTable,'TimInd');% SST = Sorted step table. Notice need to tell it to sort on TimInd
  ContactType2 = {'StrkIndL2';'LiftIndL2';'StrkIndR2';'LiftIndR2'};
  TimInd2=[StrkIndL2;LiftIndL2; StrkIndR2; LiftIndR2];
   StepIndTable2=table(ContactType2,TimInd2); 
   SST2=sortrows(StepIndTable2,'TimInd2');% SST2 = Sorted step table. Notice need to tell it to sort on TimInd2
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
ACI2=table2array(SST2(:,2));%this converts the numeric entires to array contact Idices
   SSC2=[]; % WE define a vector SSC which will be the sequence of step contacts
   
   for ic2=1:length(StrkIndR2) % all the contact indices are same lenght; use one here
      SSC2=cat(1, SSC2,ACI2(1:4,ic2));  %this concatentates the indices
   end
% produce the contact type numeric descriptor (CTND2)
% First step is to create an ordered cell array of the contact descriptors from the
% sorted step table (SST2):
OrdCellArray2=SST2.ContactType2;
% You need to convert the elements to strings.  Matlab will do the
% conversion using the following, but must have same lenght string (we do,
% have equal lenght names):
OrdConType2=cell2mat(OrdCellArray2);
for k2=1:4   % k2 is a counting index; we compare each element
            % note you must use string comparision, strcmp:
    if strcmp(OrdConType2(k2,:), 'StrkIndL2')  CTND2(k2)=1; end
    if strcmp(OrdConType2(k2,:), 'LiftIndL2')  CTND2(k2)=2; end
    if strcmp(OrdConType2(k2,:), 'StrkIndR2')  CTND2(k2)=3; end
    if strcmp(OrdConType2(k2,:), 'LiftIndR2')  CTND2(k2)=4; end
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
LenSSC2=length(SSC2);
AdCol2=zeros(LenSSC2,1);
SSC2=[SSC2 AdCol2];

ik2=1;    % counter indext for numeric descriptor
for ic2 = 1:LenSSC2
    if(ik2>4)ik2=1; end
    SSC2(ic2,2)=CTND2(ik2);
    ik2=ik2+1;
end
% We are ready to plot the the force time series, and the contact indices 
% VELOCITY DATA (indicators located in rows -5 and -10)
%     left is green, right is red
% FORCE DATA (indicators located in rows -20 and -25)
%     left is green-yellow, right is dark red
xaxis=[1:indTimMaxR];
plot(xaxis,sNumericalDataR, 'Color','red','LineWidth',1.0);
hold on
plot(xaxis,sNumericalDataL, 'Color',[0.46 0.67 0.10],'LineWidth',1.0);
hold on
plot(xaxis,(sNumericalDataR2/4), 'Color',[0.7 0 0],'LineWidth',1.0);
hold on
plot(xaxis,(sNumericalDataL2/4), 'Color',[0.86 0.67 0.10],'LineWidth',1.0); 
%the divide by 4 is used as a scaling factor to make the velocity and force
%values appear better on the graph. It does not change the actual chopping
%of the data.

% create another counter to add the contact types
axis([0 24000 -30 150])
for ic = 1:LenSSC
    X=SSC(ic,1);
    if(SSC(ic,2)==1) plot(X,-5,'v','MarkerFaceColor',[0.46 0.67 0.10]);end
    if(SSC(ic,2)==2) plot(X,-5,'^','MarkerFaceColor',[0.46 0.67 0.10]);end
    if(SSC(ic,2)==3) plot(X,-10,'v','MarkerFaceColor','red');end
    if(SSC(ic,2)==4) plot(X,-10,'^','MarkerFaceColor','red');end
end
hold on
for ic2 = 1:LenSSC2
    X2=SSC2(ic2,1);
    if(SSC2(ic2,2)==1) plot(X2,-20,'v','MarkerFaceColor',[0.86 0.67 0.10]);end
    if(SSC2(ic2,2)==2) plot(X2,-20,'^','MarkerFaceColor',[0.86 0.67 0.10]);end
    if(SSC2(ic2,2)==3) plot(X2,-25,'v','MarkerFaceColor',[0.7 0 0]);end
    if(SSC2(ic2,2)==4) plot(X2,-25,'^','MarkerFaceColor',[0.7 0 0]);end
end
hold off
