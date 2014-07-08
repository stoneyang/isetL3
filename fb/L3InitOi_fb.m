function L3 = L3InitOi_fb(L3)

% Initialize oi (optics) with default parameters.
%
%   L3 = L3InitOi(L3)
%
% The default settings for the optics are
%   
%   F number is set to 4 
%   Focal length is set to 3e-3 (3mm)
%
% (c) Stanford VISTA Team 2013


%% Create oi and set defaults
oi = oiCreate;

scenes = L3Get(L3,'scene');
wave = sceneGet(scenes{1},'wave');

[sensor, optics] = fbCreate(wave);

oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','fb optics');

%% Store in L3 structure
L3 = L3Set(L3,'oi',oi);
