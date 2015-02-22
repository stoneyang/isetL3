function L3 = L3InitTrainingScenes(L3)
% Initialize training scenes for an L3 structure
%
%   L3 = L3InitTrainingScenes(L3,sType);
%
% The sType are the scene types
%
% Usually, we set a bunch of scenes in a folder.  We have sType be the name
% of the folder.
%
% The default training scenes are the scenes in the folder
%         L3rootpath\Data\Scenes
%
% We will build up more sType options over time.
%
% (c) Stanford VISTA Team 2013

if ieNotDefined('sType'), sType = 'default'; end

%% Load scenes
sType = ieParamFormat(sType);
switch sType
    case 'default'
        sceneFolder = fullfile(L3rootpath,'data','scenes');
        hfov = 10; % hfov is horizontal field of view in degrees, default is 10
        scenes = L3LoadTrainingScenes(sceneFolder, hfov);
    otherwise
        error('Unknown sType: %s\n',sType);
end

%% Store in L3 structure
L3 = L3Set(L3,'scene', scenes);

end