function [camera,img] = cameraCompute_RGBN(camera,pType,mode,sensorResize)

% for idealXYZ mode, img has 4 channels, XYZ and N
% otherwise it outputs lrgb, but n image is in camera.vci.L3.L3n


% Compute an image of a scene using a camera model
%
%   [camera,img] = cameraCompute(camera,pType,mode,sensorResize)
%
% Start with a camera structure and compute from the scene to the oi to the
% sensor and ip.  The returned camera object has the updated objects.
%
% INPUTS:
%  camera: Camera object
%  pType:  Processing type indicates where to start.
%          If pType is a scene struct, then we begin from there
%          If pType is 'oi' or 'sensor' we begin with the data in those
%          slots of the camera structure.
%  mode:
%   'normal'    - Typical calculation
%   'idealxyz'  - Calculation if we replace the sensor with an ideal
%   (noise-free) sensor that has XYZ sensors.
%
%  sensorResize:  By default, we adjust the sensor size to match the scene
%                 field of view.
%
% The calculations for each of the objects are attached to the returned
% camera object.
%
% If requested the return argument 'img' contains the linear RGB display
% data (related to sRGB).
%
% ** idealxyz mode **
%  For some calculations, we are interested to know how this camera would
%  perform if we could eliminate all sources of noise and further if the
%  camera spectral QE is colorimetric (CIE XYZ filters).
%
%  In that case, you can append the argument 'idealXYZ'. This is a
%  calculation that is used only for certain special applications.
%
% It is possible to start the calculation beyond the scene, as per below in
% the Examples.
%
% See also: cameraCreate, cameraSet, cameraGet
%
% Examples:
%  There are various ways to run the camera calculation.  These are
%  included to permit some efficiencies in the calculation.
%
% To start from the beginning, say to start from a scene, you can call
%
%   scene = sceneCreate; camera = cameraCreate;
%   camera = cameraCompute(camera,scene);
%   cameraWindow(camera,'ip')
%
% By default, the camera sensor is set to match the scene.  If you do not
% want that, then you can set the 4th argument (sensorResize) to false.
%
%   scene = sceneSet(scene,'fov',2); camera = cameraCreate;
%   camera = cameraCompute(camera,scene,[],false);
%   cameraWindow(camera,'ip')
%
%   scene = sceneSet(scene,'fov',20);
%   camera = cameraCompute(camera,scene,[],false);
%   cameraWindow(camera,'ip')
%
% This will create the oi, sensor and ip objects for that scene.  The
% updated objects are returned in the camera structure.
%
% Suppose you then make a change to the sensor and you would like to
% recompute.  Rather than recompute the optical image, which takes some
% you can run starting with the oi
%
%   camera = cameraCompute(camera,'oi');    % Must have computed oi attached
%
% Finally, if you change the image processor, you can start with the sensor
%
%   camera = cameraCompute(camera,'sensor');  % Equivalent to default
%
% The default, when no second argument is specified, is to run the 'sensor'
% case
%
%   camera = cameraCompute(camera);
%
% which is equivalent to
%
%   camera = cameraCompute(camera,'sensor');
%
% If you want to scale result image to match mean value of 2nd lrgb image
%   camera = cameraCompute(camera,X,lrgbim);  %X is any of previous entries
%
% For all of these cases output variable 'img' is always in lrgb.
%       .............
%
% There is a special case for computing XYZ values at the corresponding
% sensor resolution. We add a 'ideal XYZ' flag.  This uses the same general
% camera parameters but eliminates the noise and changes the sensor
% spectral QE to be xyzQuanta.  If you don't understand this, don't try it.
%
%   [xyzcamera xyzImg] = cameraCompute(camera, scene,'idealxyz');
%   [xyzcamera xyzImg] = cameraCompute(camera,'oi','idealxyz');
%
% (c) Stanford VISTA Toolbox, 2012

% This was an early design for parsing the arguments that should get
% simplified.  The problem is that pType is sometimes used to bring in the
% scene rather than to specify the processing type.  So we trap the
% different conditions in this maze of conditions.

% by default do not scale output image
adjustScale = 0;

if ieNotDefined('camera'), error('Camera structure required.'); end
if ieNotDefined('pType'), pType = 'sensor';
elseif isstruct(pType)
    if strcmp(sceneGet(pType,'type'),'scene'), scene = pType; pType = 'scene';
    else                                       error('Bad input object %s\n',pType);
    end
end

if ieNotDefined('mode'),  mode  = 'normal'; end
if ~ischar(mode), lrgbScale = mode; mode = 'normal'; adjustScale = 1; end

if ieNotDefined('sensorResize'), sensorResize = true; end

mode  = ieParamFormat(mode);
pType = ieParamFormat(pType);

switch mode
    %% Normal camera operation (not ideal XYZ case)
    case 'normal'
        switch pType
            case 'scene'
                oi     = cameraGet(camera,'oi');
                sensor = cameraGet(camera,'sensor');
                vci    = cameraGet(camera,'vci');
                
                % Warn when FOV from scene and camera don't match
                fovScene     = sceneGet(scene,'fov');
                fovCamera    = sensorGet(sensor(1),'fov',scene,oi);
                if sensorResize
                    if abs((fovScene - fovCamera)/fovScene) > 0.01
                        % More than 1% off.  A little off because of
                        % requirements for the CFA is OK.
                        warning('ISET:Camera','Matching sensor and Scene FOV (%.1f)',fovScene);
                        N = length(sensor);
                        for ii=1:N
                            sensor(ii) = sensorSetSizeToFOV(sensor(ii),fovScene,scene,oi);
                        end
                    end
                end
                
                % Compute
                oi     = oiCompute(oi,scene);
                sensor = sensorCompute(sensor,oi);
                vci    = vcimageCompute(vci,sensor);
                
                camera = cameraSet(camera,'oi',oi);
                camera = cameraSet(camera,'sensor',sensor);
                
            case 'oi'
                
                % Load camera properties
                oi     = cameraGet(camera,'oi');
                sensor = cameraGet(camera,'sensor');
                vci    = cameraGet(camera,'vci');
                
                % Compute
                sensor = sensorCompute(sensor,oi);
                vci    = vcimageCompute_RGBN(vci,sensor);
                
                camera = cameraSet(camera,'sensor',sensor);
                
            case 'sensor'
                
                % Load camera properties
                sensor = cameraGet(camera,'sensor');
                % vcAddandSelectObject(sensor); sensorWindow('scale',1);
                vci = cameraGet(camera,'vci');
                % vci = imageSet(vci,'color balance method','gray world');
                % vcAddandSelectObject(vci); vcimageWindow;
                
                % Compute
                vci    = vcimageCompute(vci,sensor);
                
            otherwise
                error('Unknown pType conditions %s\n',pType);
        end
        
        % Adjust scale of rendered lrgb image to match mean of passed in
        % image.  Generally the rendered images need to be scaled for
        % display.  By scaling to match the mean of another image, the two
        % images will appear approximately equally bright.  This helps
        % remove the arbitrary scaling that may differ between cameras.
        if adjustScale
            lrgb = imageGet(vci, 'result');
            % Ignore pixels within 10 pixels of edges of image
            meanlrgb      = mean(mean(mean(lrgb(11:end-10,11:end-10,:))));
            meanlrgbScale = mean(mean(mean(lrgbScale(11:end-10,11:end-10,:))));
            lrgb = lrgb * meanlrgbScale / meanlrgb;
            vci = imageSet(vci, 'result', lrgb);
        end
        
        % Store vci into camera
        camera = cameraSet(camera,'vci',vci);
        
        if nargout > 1, img    = imageGet(vci,'result'); end
        
    case 'idealxyz'
        
        %% Use optics and sensor but compute with sensor XYZQuanta
        % The returned values are not mosaicked and there is no processing.
        % We just return the XYZ values at the same spatial/optical
        % resolution as the camera. This is useful for training and
        % testing.
        oi     = cameraGet(camera,'oi');
        sensor = cameraGet(camera,'sensor');
        sensor = sensorSet(sensor,'NoiseFlag',0);  % Turn off noise
        fovCamera    = sensorGet(sensor,'fov',scene,oi);
        fovScene     = sceneGet(scene,'fov');
        if abs((fovScene - fovCamera)/fovScene) > 0.01
            % More than 1% off.  A little off because of
            % requirements for the CFA is OK.
            warning('ISET:Camera','FOV for scene %.1f and camera %.1f do not match',fovScene,fovCamera)
        end
        
        wave = sceneGet(scene,'wave');
        % Load and interpolate filters
        transmissivities = ieReadSpectra('XYZQuanta',wave);
        %% QT
        load('N.mat');
        transmissivities = [transmissivities, N];
        %%
        sensor = sensorSet(sensor,'wave',wave);
        switch pType
            case 'scene'
                % Compute
                oi     = oiCompute(oi,scene);
                camera = cameraSet(camera,'oi',oi);
                
            case 'oi'
                % Compute
                
            otherwise
                error('Unknown pType conditions %s\n',pType);
        end
        img = sensorComputeFullArray(sensor,oi,transmissivities);
        
        %%
    otherwise
        error('Unknown mode conditions %s\n',mode);
end

end