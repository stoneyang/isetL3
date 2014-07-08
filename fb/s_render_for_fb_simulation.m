clear, clc, close all

%%
s_initISET

%% Load scene
scene = sceneFromFile('AsianWoman_1.mat','multispectral');

%% Render images
sz = sceneGet(scene, 'size');

%% Load camera
load('L3camera_fb_nooffset.mat');

%% Specify luminance levels
luminances = [1, 80];

for lum = luminances
    srgbResult = cameraComputesrgb(camera, scene, lum, sz, [], [], 1);
    imwrite(srgbResult, ['srgb_fb_lum_' num2str(lum) '_nooffset.png']);
end