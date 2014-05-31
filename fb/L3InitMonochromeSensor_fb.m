function L3 = L3InitMonochromeSensor_fb(L3)
% Initialize L3 monochrome sensor with default parameters.
%
%  L3 = L3InitMonochromeSensor(L3)
%
% The default settings for the optics are
%   Exposure time is set to 0.1s
%   Voltage swing is set to 1.8v
%
% More defaults are found below
%
% (c) Stanford VISTA Team 2013

%% Load from L3 structure
sensorD = L3Get(L3, 'designsensor');
sensorM = sensorMonochrome(sensorD, 'Monochrome');

%% Store in L3 structure
L3 = L3Set(L3, 'monochrome sensor', sensorM);
return;

function sensor = sensorMonochrome(sensor,filterFile)
%
%   Create a default monochrome image sensor array structure.
%

sensor = sensorSet(sensor,'name',sprintf('monochrome-%.0f', vcCountObjects('sensor')));

[filterSpectra,filterNames] = sensorReadColorFilters(sensor,filterFile);
sensor = sensorSet(sensor,'filterSpectra',filterSpectra);
sensor = sensorSet(sensor,'filterNames',filterNames);

sensor = sensorSet(sensor,'cfaPattern',1);      % 'bayer','monochromatic','triangle'

return;
