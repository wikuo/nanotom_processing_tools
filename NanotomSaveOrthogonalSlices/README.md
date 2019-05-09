 # NanotomSaveOrthogonalSlices.m
Saves middle orthogonal slices of a group of .vol files in processfolder

.pcr and .vol files of each dataset need to be in a subfolder in processfolder. Skript only processes the first .vol file in a dataset folder, so make sure each dataset is in its own folder.
 
- processfolder
  - Dataset_1_folder
    - Dataset_1.pcr
    - Dataset_1.vol
  - Dataset_2_folder
  	- Dataset_2.pcr
  	- Dataset_2.vol
  - etc.
 
 
Note that XY requires only a single sequential read, while XZ needs to skip one frame for every line and YZ needs to skip one line for every pixel.

Runtime per orthogonal slice (average of 45 datasets, from a regular hard drive):

XY: 0.15 s

XZ:  24 s

YZ: 100 s
