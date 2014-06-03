clear, clc, close all
s_initISET

%% Load data

scene = sceneFromFile('AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');

%% Specify luminance levels
lum = 80;

%% Render
for ii = [1, 3, 5]
    load(['L3camera_RGBN' num2str(ii) '.mat']); 
    rand('seed', 10);
    randn('seed', 10);
    [nIdeal, camera, srgbResult, srgbIdeal, raw] = cameraComputesrgb_RGBN(camera, scene, lum, sz);
    nResult = camera.vci.L3.L3n;
    MSE = sum(sum((nIdeal/max(nIdeal(:)) - nResult/max(nResult(:))).^2)) / length(nIdeal(:))
    PSNR = -10 * log10(MSE)
    [mssim, ssim_map] = ssim(nResult, nIdeal);
end
%%
