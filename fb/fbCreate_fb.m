function [sensor, optics] = fbCreate_fb(wave)
%Create a model of the five band sensor
%
%    [sensor, optics] = fbCreate(wave);
%
% Example
%   wave = 400:5:700; sensor = fbCreate(wave);
%
% Copyright VISTALAB, 2014

%%
sensor = sensorCreate;

if ieNotDefined('wave'), wave = sensorGet(sensor,'wave');
else sensor = sensorSet(sensor,'wave',wave);
end
sensor = sensorSet(sensor,'wave',wave);


%% These are from Olympus
% fName = fullfile('fbOlympus');
% filterSpectra = vcReadSpectra(fName,wave);
% % Filter color order: r,g,b,o,c
% 
% fName = fullfile('ir-fbOlympus');
% irFilter = vcReadSpectra(fName,wave);
% 
% sensor = sensorSet(sensor,'filter spectra',filterSpectra);
% sensor = sensorSet(sensor,'ir filter',irFilter);

%% These are HB's measurements
% These measurements already incorporate the IR filter.
fName = fullfile('responsivityData');
filterSpectra = vcReadSpectra(fName,wave);
filterSpectra = filterSpectra./max(filterSpectra(:));
filterSpectra = filterSpectra(:,[5 3 1 4 2]);
sensor = sensorSet(sensor,'filter spectra',filterSpectra);

% Other parameters of the sensor
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'sizesamefillfactor',[5e-6 5e-6]);
% We know that the well capacity is 24000 e but I can't find the sensor
% voltage....

vSwing = 1;
sensor = sensorSet(sensor,'analogOffset',0.0273*vSwing);

sensor = sensorSet(sensor,'pixel',pixel);
sensor = pixelCenterFillPD(sensor,0.5); % This is just a random fill factor guess.

%%  The color filters

cfa = ...
    [ 3 2 5 2;
    2 4 2 1;
    5 2 3 2;
    2 1 2 4];

%   
%   cfa = [2  4  2  3;
%       5  2  1  2;
%       2  3  2  4;
%       1  2  5  2];  % translated using desired color order

sensor = sensorSet(sensor,'pattern and size',cfa);
sensor = sensorSet(sensor,'filter names',{'r','g','b','o','c'});
sensor = sensorSet(sensor,'exp time',0.02);

%% Optics
optics = opticsCreate;
optics = opticsSet(optics,'fNumber',16);

end