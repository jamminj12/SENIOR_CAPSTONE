% MLForceChopLeft.m
% Step 2 after MLForcePlotterV1_Chopped.m (same workspace): cuts the left load-cell signal into one segment per left-foot contact, using the F-Scan strike/lift indices,
% then plots each segment on a normalized time axis, one at a time (press return for the next, 1 to stop).
%
% ---- original file below ----
% Made by Jesse Greyshock 4/25/23
% RUN MLForcePlotterV1_Chopped first! You must also run it again if you are swtiching between MLForceChopRight and MLForceChopLeft
LenInd=length(StrkIndL);   % both left and right indice vectors have the same length; see above
%create the left foot cutouts
if StrkIndL(1)<LiftIndL(1)   %the left starts with a strike, use lift and strike pairs

    for ic = 1:LenInd
        cutA=round(StrkIndL(ic)/400*(1/avg_sampling_freq));
        cutB=round(LiftIndL(ic+1)/400*(1/avg_sampling_freq));        %intialize the vector to a common lenght, 1.2 x the first one
        if(ic==1); dimMax=round(cutB-cutA); 
        chopOutLML=zeros(dimMax,LenInd);
        end
        Lencut=cutB-cutA + 1 ; % you have to add one to get lenght OK
        chopOutLML(1:Lencut,ic)=force_left(cutA:cutB,1);   % the second dimension of 1 is added for clarity, not really needed
        FtConLenLML(ic)=cutB-cutA;   % define the length of velocity contact- for use later
    end

else
    for ic=1:LenInd-1  %the left starts with a lift; use the first strike+second lift pairs
        cutA=round(StrkIndL(ic)/400*(1/avg_sampling_freq));
        cutB=round(LiftIndL(ic+1)/400*(1/avg_sampling_freq));
          %intialize the vector to a common lenght, 1.2 x the first one
            if(ic==1); dimMax=round(cutB-cutA); 
            chopOutLML=zeros(dimMax,LenInd);
            end
            Lencut=cutB-cutA+1;
            chopOutLML(1:Lencut,ic)=force_left(cutA:cutB,1)+1;
            FtConLenLML(ic)=cutB-cutA;   % define the length of this contact for use later
    end
end
countext=text(0.6,0.45 , 'starter');% this line needed just for place holding
for i = 1:LenInd-1
    xcoor=1:FtConLenLML(i);  % we start at index 1; we do not keep zero so last place is exactly 1
   delete (countext);
   plot(xcoor/FtConLenLML(i),(chopOutLML(1:FtConLenLML(i),i)))
   hold on
   stepIndexstr=num2str(i);   
   countext= text(0.8,0.9 , stepIndexstr);
ContVar = input('return to continue, 1 to stop');
    if ContVar == 1 break
        clf
    end
end
title('ML Force Chopped - Left', 'Interpreter','none', 'FontSize', 10)
ylabel(['Force (lbf' ...
    ')']);
