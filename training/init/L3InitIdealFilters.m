function L3 = L3InitIdealFilters(L3)
% Initialize ideal filters  with default parameters.
%
%  L3 = L3InitIdealFilters(L3)
%
% The default settings for the ideal sensor are
%
%   Ideal filters are set to 'XYZQuanta'.
%
% (c) Stanford VISTA Team 2013

%% Set parameters for ideal filters

idealFilters.name = 'XYZQuanta';  %name of file containing spectral curves
idealFilters.filterNames = {'rX', 'gY', 'bZ'};  %name for filters, only used to color plots

% We used to use the scene wavelength. 
% scenes = L3Get(L3,'scene'); wave = sceneGet(scenes{1}, 'wave');   

% But I think we should use the wavelength from the design sensor (BW).
wave = sensorGet(L3.sensor.design,'wave');
idealFilters.wave = wave;
idealFilters.transmissivities = vcReadSpectra(idealFilters.name, wave);   %load and interpolate filters

%% Store
L3 = L3Set(L3, 'ideal filters', idealFilters);

end