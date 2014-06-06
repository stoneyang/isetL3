function vSNR = cameraVSNR_rgbn(camera, meanLuminance)
% Analyze vSNR for a camera module
%
%   eAnalysis = cameraVSNR(camera)
%
% Visible SNR calculation for N band

if ieNotDefined('camera'), error('Camera required.'); end



dpi = 100; dist = 0.20;

oi     = cameraGet(camera,'oi');
sensor = cameraGet(camera,'sensor');
sDist  = 1000;       % distance of imager from scene (m)
fov    = sensorGet(sensor,'fov',sDist,oi);

scene  = sceneCreate('uniform d65',29);
scene = sceneSet(scene,'wave',400:10:680);
scene  = sceneSet(scene,'fov',fov);

    
scene  = sceneAdjustLuminance(scene,meanLuminance);

[nIdeal, camera] = cameraComputesrgb_RGBN(camera, scene, meanLuminance);
nResult = camera.vci.L3.L3n;
result = repmat(nResult,[1,1,3]);   % just copy the N channel to all 3 channels

% TODO: Check for saturation of one or more channels
rgbMeans = mean(RGB2XWFormat(result));
% if max(rgbMeans) > 0.99,     warning('High channel means %.3f',rgbMeans);
% elseif min(rgbMeans) < 0.01, warning('Low channel means %.3f',rgbMeans);
% end

% Rendering algorithm:
% Scale so the mean of a constant image is at the half way point of
% linear RGB.
result = result/mean(result(:))*.5;

% Clip
% result = ieClip(result, 0, 1);

% Store the newly transformed lRGB image into the vci.  The one 
vci = cameraGet(camera, 'vci');
vci = imageSet(vci, 'result', result);

% Set the rect for computing vSNR: Exclude edge regions (10 percent of each edge)
% rect = [colmin,rowmin,width,height]
sz   = size(result);
border   = round(sz(1:2)*0.1);   % Border
rect = [border(2), border(1), sz(2)-(2*border(2)), sz(1)-(2*border(1))];


% What are the units?  1 / Delta E, I think.
vSNR = vcimageVSNR(vci,dpi,dist,rect);

end