function [meanbias, PSNR, mssim, vSNR] = metricsCamera_rgbn(camera)

%% Change optics
camera.oi.optics.offaxis = 'skip';
camera.oi.optics.model = 'skip';

%% Specify luminance levels
lum = 80;

%% Full Reference
scene = sceneFromFile('AsianWoman_1.mat', 'multispectral');
sz = sceneGet(scene, 'size');

rand('seed', 10);   randn('seed', 10);
[nIdeal, camera, srgbResult, srgbIdeal, raw] = cameraComputesrgb_RGBN(camera, scene, lum, sz, [], [], 0);
nResult = camera.vci.L3.L3n;
nResult = nResult / mean(nResult(:)) * mean(nIdeal(:));


MSE = sum(sum((nIdeal/max(nIdeal(:)) - nResult/max(nIdeal(:))).^2)) / length(nIdeal(:));    
PSNR = - 10 * log10(MSE);
mssim = ssim(nResult, nIdeal);

figure, imagesc(nResult), axis image, title('Estimate'), colormap(gray)
figure, imagesc(nIdeal), axis image, title('Ideal'), colormap(gray)

%% Mean bias and vSNR
rand('seed', 10);   randn('seed', 10);
meanbias = cameraBias_rgbn(camera, lum);
vSNR = cameraVSNR_rgbn(camera, lum);

