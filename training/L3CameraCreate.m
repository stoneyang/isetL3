function camera = L3CameraCreate(L3)
% Create a camera object from an L3 structure
%
% camera = L3CameraCreate(L3)
%
% Copyright Vistasoft Team, 2012

%% Should be just
L3 = L3Create;
camera1 = cameraCreate('L3',L3);

%% 
camera.name   = 'L3';
camera.type   = 'camera';
camera.oi = oiClearData(L3Get(L3,'oi'));
camera.sensor = L3Get(L3,'design sensor');

L3small = L3ClearData(L3);

vci = ipCreate('L3');
vci = ipSet(vci,'L3',L3small);
camera.vci = vci;

end