clear, clc, close all

%%
s_initISET

%% Load camera
load('L3camera_fb.mat');

%% Read fb raw images
fName = fullfile(fbRootPath,'data', 'images', 'sunny', '001_Sunny_f16.0.RAW');
fbSensor = fbRead(fName);
camera.sensor = fbSensor;

%%
[camera,img] = cameraCompute(camera, 'sensor');