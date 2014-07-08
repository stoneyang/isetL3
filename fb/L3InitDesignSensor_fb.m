function L3 = L3InitDesignSensor_fb(L3)

% Initialize design sensor with default parameters
%
% L3 = L3InitDesignSensor(L3)
%
% Design filters are set to 'RGBW'. 
% CFA pattern is set to [1, 2; 3, 4].
%
% (c) Stanford VISTA Team 2013

%% Load from L3 structure
scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1}, 'wave');   %use the wavelength samples from the first scene

sensorD = fbCreate(wave);

% Build design sensor
sensorD = sensorSet(sensorD, 'name', 'Design sensor');
sensorD = sensorSet(sensorD, 'wave', wave);

%% Store in L3 structure
L3 = L3Set(L3,'design sensor', sensorD);
