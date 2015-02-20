function camera = L3CameraCreate(L3)
% Create a camera object from an L3 structure
%
% camera = L3CameraCreate(L3)
%
% Copyright Vistasoft Team, 2012

% Always create with this name for the IP, and type for a camera
camera.name   = 'L3';
camera.type   = 'camera';

L3small = L3ClearData(L3);

% The camera has a copy of the oi and sensor, initialized without any data
camera.oi     = L3Get(L3small,'oi');
camera.sensor = L3Get(L3small,'design sensor');

ip = ipCreate('L3');
ip = ipSet(ip,'L3',L3small);
camera = cameraSet(camera,'ip',ip);

end