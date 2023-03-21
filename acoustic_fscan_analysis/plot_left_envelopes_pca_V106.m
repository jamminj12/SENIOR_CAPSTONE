% plot_left_envelopes_pca_V106.m (developed as LPlotterwLineV106.mlx)
% Step 2 of 2 (left foot). Runs on the workspace left by a chopping script: overlays the stance envelopes, trims them to the shortest stance,
% saves them to filenameOUTPUT, standardizes them (z-score), and runs PCA (pca) with score and percent-explained plots.
% Run the left plotter first; the right plotter appends to the same .mat file. See README.md.
%
% ---- original header and revision history below ----
%Version 106 includes a step to shorten the stances to the shortest
% 
Xpl=[.33 .66]; Ypl=[0 0];
countext=text(0.6,0.45 , 'starter');
 XLenv=zeros(LenInd-1,dimMax);
 YLenvup=zeros(LenInd-1,dimMax);
 YLenvlo=zeros(LenInd-1,dimMax);
 Nskip = 6 %skip first few
for i = Nskip:LenInd-1 
xcoor=1:FtConLenL(i);
delete (countext);
   plot(xcoor/FtConLenL(i),chopOutLup(1:FtConLenL(i),i))
   axis([0 1 0 0.5])
   hold on
   %plot(xcoor/FtConLenL(i),chopOutLlo(1:FtConLenL(i),i))
  XLenv(i,1:FtConLenL(i))=xcoor;
  YLenvup(i,1:FtConLenL(i))=(chopOutLup(1:FtConLenL(i),i))';
  YLenvlo(i,1:FtConLenL(i))=(chopOutLlo(1:FtConLenL(i),i))';

   plot(Xpl, Ypl, 'g', 'LineWidth',2)
   stepIndexstr=num2str(i);   
   countext= text(0.6,0.45 , stepIndexstr);
%ContVar = input('return to continue, 1 to stop');
   % if ContVar == 1  break
       % clf
   % end
end
strLegend=append(audiofile, ' Left envelopes');
title(strLegend, 'Interpreter','none', 'FontSize', 10)
hold off
% NOTICE WE ARE ALREADY USING EXTENDED STANCES; THESE ARE SENT OVER FROM THE CHOPPING PROGRAM
% Now we are going to find the shortest extended stance, call it MinLenL, and then go back and make all the extended stances that same length.   We will effectively find the center of each extended stance, and then add 1/2 of MinLenL data points in front and behind the midpoint
minLenL=min(FtConLenL(2:LenInd-1)); % exclude stance 1, it is zero, and exclude last stance since
                                    % last stance may not be complete

half = round(minLenL/2)-1;  % I shorten by one data point in case minLenL is odd

truncLen=2*half % This is the truncated length of all the extended stances
                   
YLenvupT=zeros(LenInd-1,truncLen);
XLenvT = zeros(LenInd-1,truncLen);

Fs = 44100 % the acoustic sampling frequency

for j = 1:truncLen
    XLenvT(:,j)=(j-1)/Fs;
end

figure

for i = Nskip:LenInd -1
    M=round(FtConLenL(i)/2);
    A=M-half;
    B=M+half; 
    
    YLenvupT(i,1:truncLen)=YLenvup(i,A:B-1);  % the T at the end of the variable is "truncated"
    plot(XLenvT(i,:),YLenvupT(i,:))
    hold on
end

x2pl=[truncLen/3/Fs truncLen*2/3/Fs];
y2pl = [0 0];
plot(x2pl, y2pl, 'g', 'LineWidth',2)
strLegend=append(audiofile, ' Left envelopes');
title(strLegend, 'Interpreter','none', 'FontSize', 10)
xlabel('Time (s)')
ylabel('Scaled acoustic envelope magnitude')
hold off
if ~exist('filenameOUTPUT','var'); filenameOUTPUT = 'TRIAL_OUTPUT.mat'; end   % output .mat file name (set by the chopping script)
Xsto_L= XLenvT';
Ysto_L = YLenvupT';
save(filenameOUTPUT, 'Xsto_L','Ysto_L')
% I am now adding the PCA analysis.  Note to use in PCA I transpose to column vectors.   I also need to remove the columns that are skipped:
XPCA=XLenvT';
YPCA=YLenvupT';


%remove any skipped stances
XPCA=XPCA(:,Nskip+1:LenInd-1);
YPCA=YPCA(:,Nskip+1:LenInd-1);
% I will use the standarized variables for the PCA so I need to standardize the Y variable as a Z score.   Note the matlab functions:
Meanall =mean(YPCA,'all');
stdall=std(YPCA,1,'all');
YPCAs=(YPCA-Meanall)/stdall;   % the s at the end means standardized
figure
subplot(3,2,1)
plot(XPCA,YPCAs)
axis([0 2.5 -4 10])
hold on
plot(x2pl, [-3.95 -3.95], 'g', 'LineWidth',2)
legend(filelocationL, 'Interpreter','none')
title('Normalized Envelopes')
xlabel('seconds')

subplot(3,2,3)

[coeff,score,latent,tsquared,explained,mu] = pca(YPCAs);
Z=score*coeff'+mu;
plot(XPCA, score(:,1),'b')
title('Score 1')
axis([0 2.5 -30 30])
xlabel('seconds')
hold on
plot([0,2.5],[0,0],'k','LineWidth',0.1)
plot(x2pl, [-30 -30], 'g', 'LineWidth',2)

subplot(3,2,5)
plot(XPCA,score(:,2),'b')
title('Score 2')
axis([0 2.5 -30 30])
xlabel('seconds')
hold on
plot([0,2.5],[0,0],'k','LineWidth',0.1)
plot(x2pl, [-30 -30], 'g', 'LineWidth',2)

subplot(3,2,2)
plot(XPCA,score(:,3),'b')
title('Score 3')
axis([0 2.5 -30 30])
xlabel('seconds')
hold on
plot([0,2.5],[0,0],'k','LineWidth',0.1)
plot(x2pl, [-30 -30], 'g', 'LineWidth',2)

subplot(3,2,4)
plot(XPCA,score(:,4),'b')
title('Score 4')
axis([0 2.5 -30 30])
xlabel('seconds')
hold on
plot([0,2.5],[0,0],'k','LineWidth',0.1)
plot(x2pl, [-30 -30], 'g', 'LineWidth',2)

subplot(3,2,6)
NumOfStepV=size(explained);
NumStps=NumOfStepV(1,1); 
xAxisExp=1:NumStps; xAxisExp=xAxisExp/NumStps;
plot([1:20],explained(1:20),'-o')
axis([0 20 0 100])
title('Percent Explained')
xlabel('Principal Component Number')
grid on

run("RPlotterwLineV106.mlx")


