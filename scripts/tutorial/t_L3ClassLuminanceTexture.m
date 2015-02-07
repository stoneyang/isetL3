%% s_L3ClassLuminanceTexture
%
% Show the luminance and texture classes on the image from a camera that
% has an image and an L3 training structure.
%

%% 
ieInit

%% Get a camera with an L3 trained structure

load('L3defaultcamera');

%% Load a scene
% [scene, fname] = sceneFromFile;
% fname = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
% scene = sceneAdjustIlluminant(scene,'D65.mat');

% fname = fullfile(isetRootPath,'data','images','multispectral','CaucasianMale.mat');
% scene = sceneFromFile(fname,'multispectral');
% scene = sceneAdjustIlluminant(scene,'D65.mat');

fname = fullfile(isetRootPath,'data','images','rgb','FruitMCC_6500.tif');
scene = sceneFromFile(fname,'rgb');
scene = sceneAdjustLuminance(scene,100);


%%
% camera = cameraSet(camera,'sensor autoexposure',false);

camera = cameraSet(camera,'sensor exptime',0.15);
camera = cameraSet(camera,'ip gamma display',0.5);
camera = cameraSet(camera,'ip scale display',1);

camera = cameraCompute(camera,scene);
cameraWindow(camera,'ip');
% cameraWindow(camera,'sensor');

%% Texture image
L3 = cameraGet(camera,'vci L3');
clusterIdx = L3Get(L3,'cluster index');
vcNewGraphWin;  imagesc(clusterIdx); axis image; axis off;

colormap([1 1 1; 0 0 0])
cb = colorbar;
set(cb,'YTick',[0.2 0.8],'YTickLabel',{'Uniform','Texture'})

title('Pattern class')

% We should label red and blue as flat and textured.  Maybe we should use a
% different color

%% Luminance image
L3 = cameraGet(camera,'vci L3');

% Luminance levels for the sensor
lum = L3Get(L3,'luminance list');
nLum = length(lum);

% These are the luminance indices for this particular picture
lumIdx = L3Get(L3,'luminance index');
vcNewGraphWin;  imagesc(lumIdx); axis image; axis off;

colormap(hot)
cb = colorbar;
set(cb,'YTick',1:nLum)

% p = cameraGet(camera,'pixel voltage swing');
% set(cb,'YTick',lum/p)

title(sprintf('Level',nLum))

% We should set the color map labels to the fraction of the well at the
% luminance level.

%% END

% c = camera;
% camera = cameraClearData(camera);
% save('RGBW_D65','camera')