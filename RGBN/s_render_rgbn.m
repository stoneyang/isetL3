clear, clc, close all
s_initISET

%% Load data

scene = sceneFromFile('AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');

%% Specify luminance levels
lum = 1;

%% Render
for ii = [1, 3, 5]
    load(['L3camera_RGBN' num2str(ii) '.mat']); 
    [nIdeal, camera] = cameraComputesrgb_RGBN(camera, scene, lum, sz);
    nResult = camera.vci.L3.L3n;
    nRMSE = sum(sum((nIdeal - nResult).^2))
end