% The following script compares the L3 pipeline and a default for an
% RGBW camera.

% The results of the training process, such as filters, are shown.  The
% calculations required to perform the training are not described but can
% be viewed in L3Train.m.

% The following code is taken from s_L3render and the functions that are
% subsequently called.  There have been slight modifications as needed
% and the plotting code has been added.  Indentations correspond with which
% m files the code was taken from.

%% Train an L^3 camera
ieInit

%% Create and initialize L3 structure
L3 = L3Create;
L3 = L3Initialize(L3);  % use default parameters

%% Adjust patch size from 9 to 5 pixels for faster computation
blockSize = 5;               % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);

%% Perform training
L3 = L3Train(L3);

%% Setup L3 camera
camera = L3CameraCreate(L3);
cameraGet(camera,'ip name')
% camera = cameraSet(camera,'ip name','default');
% camera = cameraSet(camera,'ip name','L3');

%% Load scene to capture with camera
scene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
meanLuminance = 100;     % cd/m^2
fovScene      = 10;     % degrees in horizontal field of view
scene = sceneSet(scene,'hfov',fovScene);
scene = sceneAdjustLuminance(scene,meanLuminance);

% Adjust FOV of camera to match scene
camera = cameraSet(camera,'sensor fov',fovScene);

%% Let's loop on exposure times
nTimes = 3;
t = logspace(-2,-1,nTimes);
for ii=1:nTimes
    camera = cameraSet(camera,'sensor exptime',t(ii));
    if ii == 1
        camera = cameraCompute(camera,scene);
    else
        camera = cameraCompute(camera,'oi');
    end
    cameraWindow(camera,'ip');
end
%%
srgb = cameraGet(camera,'ip srgb');
vcNewGraphWin; imagescRGB(srgb);

%%
[camera,xyzIdeal] = cameraCompute(camera,scene,'ideal xyz');
xyzIdeal = xyzIdeal/max(xyzIdeal(:));   %scale to full display range

vcNewGraphWin;  image(xyzIdeal); axis image; axis off;
title('Ideal XYZ')

%Convert XYZ to lRGB and sRGB
srgbIdeal = xyz2srgb(xyzIdeal);
vcNewGraphWin; imagescRGB(srgbIdeal);

%% END