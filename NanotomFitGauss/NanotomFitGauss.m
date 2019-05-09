% This script opens a Nanotom reconstructed volume and fits gaussians to the histogram.
% Requires the .pcr and % .vol files to be in the same directory
% Last modification: Willy Kuo 08.05.2018

clear all;

filelocation = '';
filenumber = 1; % Choose which file to process if there are multiple files in folder
filebyteorder = 'l'; % 'l' for Nanotom raw data, 'b' for Fiji .raw export

roiexclude = 600; % number of slices to exclude from top and bottom to remove cone beam artifact


%% Read X, Y and Z-dimensions from .pcr file
pcrfilelist = dir([filelocation '/*.pcr']);
pcrfileID = fopen([filelocation '/' pcrfilelist(filenumber).name],'r');
pcrfileContent = textscan(pcrfileID,'%s','Delimiter','\n');
ROI_SizeX = str2num(pcrfileContent{1}{7}([11:end]));
ROI_SizeY = str2num(pcrfileContent{1}{8}([11:end]));
ROI_SizeZ = str2num(pcrfileContent{1}{9}([11:end]));
fclose(pcrfileID);
clearvars pcrfilelist pcrfileID pcrfileContent;

%% Read .vol file
volfilelist = dir([filelocation '/*.vol']);
volfileID = fopen([filelocation '/' volfilelist(filenumber).name],'r',filebyteorder);
voldata = fread(volfileID,[1,ROI_SizeX*ROI_SizeY*ROI_SizeZ],'uint16=>uint16');% change 'uint16=uint16' if reading files with another bit depth
fclose(volfileID);
voldata = reshape(voldata,ROI_SizeX,ROI_SizeY,ROI_SizeZ);
clearvars volfilelist volfileID;

%% Declare ROI outside of cone beam artifact
roidata = voldata([1:ROI_SizeX],[1:ROI_SizeY],[roiexclude+1:ROI_SizeZ-roiexclude]);

% Reshape into 1D-array, for debugging
% roiarray = reshape(roidata,[1,ROI_SizeX*ROI_SizeY*(ROI_SizeZ-roiexclude*2)]);


%% Calculate and display histogram
[roicounts,roiedges] = histcounts(roidata,[0:65536]);
%plot(roiedges([1:end-1]),roicounts)

%% Fit a number of gaussians to find background noise characteristics

histwindowstart = 1; % truncate histogram from the left to avoid fitting features, starting at 1
histwindowend = 12500;

Xvalues=transpose(roiedges([histwindowstart:histwindowend]));
Yvalues=transpose(roicounts([histwindowstart:histwindowend]));

% Use moving average to denoise histogram
% Xvalues=movmean(Xvalues,5);
% Yvalues=movmean(Yvalues,5);


fitobject = fit(Xvalues,Yvalues,'gauss3');

gauss2coeff = coeffvalues(fitobject);

save([filelocation '/backgroundgausscoeff.mat'],'gauss2coeff')
save([filelocation '/backgroundgausscoeff.txt'],'gauss2coeff','-ascii')

gaussfunction1 = gauss2coeff(1)*exp(-((Xvalues-gauss2coeff(2))/gauss2coeff(3)).^2);
gaussfunction2 = gauss2coeff(4)*exp(-((Xvalues-gauss2coeff(5))/gauss2coeff(6)).^2);
gaussfunction3 = gauss2coeff(7)*exp(-((Xvalues-gauss2coeff(8))/gauss2coeff(9)).^2);
% gaussfunction4 = gauss2coeff(10)*exp(-((Xvalues-gauss2coeff(11))/gauss2coeff(12)).^2)
% gaussfunction5 = gauss2coeff(13)*exp(-((Xvalues-gauss2coeff(14))/gauss2coeff(15)).^2)

figure
plot(Xvalues,Yvalues,Xvalues,gaussfunction1,Xvalues,gaussfunction2,Xvalues,gaussfunction3)
% plot(Xvalues,Yvalues,Xvalues,gaussfunction1,Xvalues,gaussfunction2,Xvalues,gaussfunction3,Xvalues,gaussfunction4)
% plot(Xvalues,Yvalues,Xvalues,gaussfunction1,Xvalues,gaussfunction2,Xvalues,gaussfunction3,Xvalues,gaussfunction4,Xvalues,gaussfunction5)


%% Extract correct gaussian distribution, threshold backgound, replace with random numbers determined by distribution extracted

% gaussno=1; % Which Gauss function should be simulated for artificial background
% 
% M=voldata;
% thresh=10500;
% 
% bgmask=zeros(size(M),'uint16');
% bgmask(M < thresh) = 1;
% 
% % To do: hole filling and/or dilations here
% 
% bgnoise = uint16(normrnd(gauss2coeff((gaussno-1)*3+2), gauss2coeff((gaussno-1)*3+3)/sqrt(2), size(M)));
% bgmask = bgmask.*bgnoise;
% 
% imshow(bgmask(:,:,1000))
% 
% M(M < thresh) = 0;
% M=M+bgmask;
% 
% imshow(M(:,:,1000))
% 
% resultfileID = fopen([filelocation '/backgroundreplaced.raw'],'w');
% fwrite(resultfileID,M,'uint16');
% fclose(resultfileID);
% 
% 


