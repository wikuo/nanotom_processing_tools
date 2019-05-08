%% Saves middle slices of a group of .vol files in processfolder
% .pcr and .vol files of each dataset need to be in a subfolder in
% processfolder. Skript only processes the first .vol file in a dataset
% folder, so make sure each dataset is in its own folder
% 
% processfolder
% 	-> Dataset_1_folder
% 		->Dataset_1.pcr
% 		->Dataset_1.vol
% 	-> Dataset_2_folder
% 		->Dataset_2.pcr
% 		->Dataset_2.vol
% etc.
% 
% 
% Last modification: Willy Kuo 19.03.2019

processfolder = '';

filelist = dir(processfolder);
filelistsize = size(filelist);
iter=filelistsize(1);

for N=3:iter %needs to be 3:iter for production
    filelocation = [processfolder '/' filelist(N).name];
        
    NanotomSaveXYMiddleSlice(filelocation);
    NanotomSaveXZMiddleSlice(filelocation);
    NanotomSaveYZMiddleSlice(filelocation);
    
end