clear, clc, close all
s_initISET

%% Create L3 structure
L3 = L3Initialize(); 

%% Change CFA pattern to Bayer
name = 'RGBN5';
cfaFile = [name '.mat'];
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

sensorD = L3Get(L3,'design sensor');
cfaData = load(cfaFile);
sensorD = sensorSet(sensorD,'filterspectra',vcReadSpectra(cfaFile,wave));
sensorD = sensorSet(sensorD,'filter names',cfaData.filterNames);
sensorD = sensorSet(sensorD,'cfa pattern',cfaData.filterOrder);
L3 = L3Set(L3,'design sensor', sensorD);
sensorM = L3Get(L3,'monochrome sensor');
sz = sensorGet(sensorD, 'sensor size');
sensorM = sensorSet(sensorM, 'sensor size', sz);
L3 = L3Set(L3,'monochrome sensor', sensorM);

%% Change block size
blockSize = 5;              
L3 = L3Set(L3,'block size', blockSize);

%% Turn off bias and variance weighting
L3.training.weightBiasVariance.global = [1, 1, 1];
L3.training.weightBiasVariance.flat = [1, 1, 1];
L3.training.weightBiasVariance.texture = [1, 1, 1];

%% Add narrowband to ideal filter
wave = L3.sensor.idealFilters.wave;
XYZ = vcReadSpectra(L3.sensor.idealFilters.name, wave);   %load and interpolate filters
N = (wave == 550) * max(XYZ(:));
save('N.mat', 'N');
XYZm = [XYZ, N]; 

L3.sensor.idealFilters.transmissivities = [XYZm];
L3.sensor.idealFilters.filterNames = {'rX', 'gY', 'bZ', 'nN'};

%% Train and create camera
L3 = L3Train(L3);
camera = L3CameraCreate(L3);
save(['L3camera_' name '.mat'], 'camera');
