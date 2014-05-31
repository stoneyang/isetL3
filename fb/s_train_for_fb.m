clear, clc, close all

%% Start ISET
s_initISET

%% Create and initialize L3 structure
L3 = L3Initialize_fb(); 

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);
