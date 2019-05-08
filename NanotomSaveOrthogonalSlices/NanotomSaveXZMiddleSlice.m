%% % This script loads the middle slice in XZ of a .vol file and stores it as a .tif
% Requires .pcr and .vol file to be in the same directory, only processes
% first .vol file.

% Date of last modification
% % Willy Kuo 19.03.2019

function void = NanotomSaveMiddleSlice(file_location)
file_number = 1;
file_byte_order = 'l'; % 'l' for Nanotom raw data, 'b' for Fiji .raw export

default_slice = true; % Set to false if you wish to specifiy input_slice_nr manually
    input_slice_nr = 1000; % Will be overwritten if above is set to true. Use slice numbers starting from 0, not 1.

%% Read dimensions from .pcr file
pcr_file_list = dir([file_location '/*.pcr']);
pcr_FID = fopen([file_location '/' pcr_file_list(file_number).name],'r');
pcr_file_content = textscan(pcr_FID,'%s', 'Delimiter', '\n');

fname = pcr_file_list(file_number).name;
fname = fname([1:end-4]);

ROI_SizeX = str2num(pcr_file_content{1}{7}([11:end]));
ROI_SizeY = str2num(pcr_file_content{1}{8}([11:end]));
ROI_SizeZ = str2num(pcr_file_content{1}{9}([11:end]));

fclose(pcr_FID);
clearvars pcr_file_list pcr_FID pcr_file_content;

%% Read the middle slice initially
if default_slice
    input_slice_nr = floor(ROI_SizeY/2); % uses middle slice by default
end
fname = [fname '_XZslice_' num2str(input_slice_nr) '.tif'];

vol_file_list = dir([file_location '/*.vol']);
vol_FID = fopen( [file_location '/' vol_file_list(file_number).name], 'r', file_byte_order);

%Note: fseek returns 0 if successful, otherwise -1, bof == beginning of file
if fseek(vol_FID, ROI_SizeX * input_slice_nr * 2, 'bof') == -1 % would need to change this if using datasets with different bit depths
    error('fseek had an error');
    return;
end

disp(['Saving slice: ' fname]);

loaded_slices = fread(vol_FID, [ROI_SizeX, ROI_SizeZ], [num2str(ROI_SizeX) '*uint16=>uint16'], ROI_SizeX*(ROI_SizeY-1)*2); % would need to change this if using datasets with different bit depths
fclose(vol_FID);
clearvars vol_file_list vol_FID;

loaded_slices = rot90(loaded_slices,-1);
%loaded_slices = transpose(loaded_slices);

imwrite(loaded_slices,[file_location '/' fname]);

disp('DONE');


end