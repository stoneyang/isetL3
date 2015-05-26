function [desiredIm, inputIm] = L3SensorImageNoNoise(L3)
% Compute sensor volts for the L3 monochrome sensor
%
%   [desiredIm, inputIm] = L3SensorImageNoNoise(L3)
%
% Compute the monochrome sensor pixel voltages for a series of filters in
% the monochrome sensor.
%
% Inputs:
%   L3:    L3 structure
%
% Outputs:
%   [desiredIm, inputIm]:  cell arrays, one for each scene, of the voltages
%   at each pixel for each of the filters from the filterList.  desiredIm
%   is for the perfectly calibrated, e.g. XYZ values.  inputIm is from the
%   design sensor.
%
%  No noise is added.
%
% (c) Stanford VISTA Team


%% Get parameters from L3
nScenes   = L3Get(L3,'n scenes');
sensorM   = L3Get(L3,'monochrome sensor');
oi        = L3Get(L3,'oi');
desiredIm = cell(nScenes,1);
inputIm   = cell(nScenes,1);

trainingillum = L3Get(L3, 'training illuminant');
renderingillum = L3Get(L3, 'rendering illuminant');

for ii=1:nScenes
    thisScene = L3Get(L3,'scene',ii);

    %% Compute input images    
    % Perhaps we could check whether the scenes come in with the right
    % training illuminant,
    thisScene = sceneAdjustIlluminant(thisScene, trainingillum);
    oi = oiCompute(oi,thisScene);
    % Debug
    vcAddObject(oi); oiWindow;

    % Turn off noise, keep analog-gain/offset, clipping, quantization    
    sensorM = sensorSet(sensorM, 'NoiseFlag',0);  
    cFilters = L3Get(L3,'design filter transmissivities');
    
    % There is a way to compute the full three mosaics using
    % sensorComputeFullArray, rather than this monoCompute() method. We
    % should use that. I think this could just be
    %    sensorComputeFullArray(sensorM,oi,cFilters)
    % and we should check.  The one issue is that this produces a cell
    % array, while the function produces a 3D matrix. (BW) 
    inputIm{ii} = monoCompute(sensorM,oi,cFilters);
    % vcNewGraphWin;  imagescRGB(inputIm{ii}); title('Input'); pause(0.5);

    %% Compute ideal images
    % We need to recompute the oi if the rendering illuminant differs
    % from the training illuminant.  But not otherwise
    if ~strcmpi(trainingillum,renderingillum)
        thisScene = sceneAdjustIlluminant(thisScene, renderingillum);
        oi = oiCompute(oi,thisScene);
    end

    % Turn off all sensor noise, analog-gain/offset, clipping, quantization
    sensorM  = sensorSet(sensorM,'NoiseFlag',-1);
    wave     = sensorGet(sensorM,'wave');
    cFilters = L3Get(L3,'ideal filter transmissivities',wave);
    desiredIm{ii} = monoCompute(sensorM,oi,cFilters);
    % vcNewGraphWin; imagescRGB(xyz2srgb(desiredIm{ii}));  title('Desired'), pause(0.5);

end

end


% Image with individual monochrome sensor
function im = monoCompute(sensorM,oi,cFilters)
%
% This is basically the same as sensorComputeFullArray.
sz = sensorGet(sensorM,'size');
% vcAddObject(oi); oiWindow;

numChannels=size(cFilters,2);
im = zeros(sz(1),sz(2),numChannels);
for kk=1:numChannels
    
    s = sensorSet(sensorM,'filterspectra',cFilters(:,kk));
    s = sensorSet(s,'Name',sprintf('Channel-%.0f',kk));
    s = sensorCompute(s,oi,0);     % No show bar
    % vcAddAndSelectObject(s); sensorWindow; pause(0.5)
    
    im(:,:,kk) = sensorGet(s,'volts');
end

end

