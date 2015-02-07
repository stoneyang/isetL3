%% Script that trains L3 structures for different cameras
%
%  The new L3 structure should contain the scene data or a set of strings
%  that point to the location of the training scenes.
%  The L3 oi and sensor should not have any data, just the training
%  parameters of those objects.
%
%  We should be able to train on a camera, in which case the L3 oi and
%  sensor should be the camera oi and sensor.
%
%  Imageval Consulting, Copyright 2015

%%
ieInit

cDir = fullfile(L3rootpath,'cameras');
chdir(cDir);

%%
s_L3TrainCamera
camera = cameraClearData(camera);
save('L3defaultcamera','camera');

%% Create and initialize L3 structure - I think this is the same as above
L3 = L3Create;
L3 = L3Initialize(L3);  % use default parameters

blockSize = 5;               % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);
L3 = L3Train(L3);

save(fullfile(cDir,'RGBW_D65.mat'),'L3');

%% ISET default sensor
L3 = L3Create;
L3 = L3Initialize(L3);  % use default parameters

blockSize = 5;               % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);

sensor = sensorCreate;
L3 = L3Set(L3,'design sensor',sensor);
L3 = L3Train(L3);

save(fullfile(cDir,'isetRGB_D65.mat'),'L3');

%%