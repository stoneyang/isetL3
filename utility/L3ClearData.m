function L3small = L3ClearData(L3)
% Clear the L3 data
%
%    L3small = L3ClearData(L3)
%
% Make a minimal version of the L3 structure by eliminating the training
% data, the oi, the sensor.  This is primarily used to store the L3
% structure in a camera.
%
% Vistasoft Team, 2014

% This is the small one.  It has nothing
L3small = L3Create;

% We copy in various fields to the small one
L3small = L3Set(L3small,'name',L3Get(L3,'name'));
L3small = L3Set(L3small,'type',L3Get(L3,'type'));

L3small = L3Set(L3small,'scenes',[]);  % Empty the training scenes
L3small = L3Set(L3small,'design sensor',sensorClearData(L3Get(L3,'design sensor')));
L3small = L3Set(L3small,'oi',oiClearData(L3Get(L3,'oi')));

L3small = L3Set(L3small,'filters',L3Get(L3,'filters'));
L3small = L3Set(L3small,'training',L3Get(L3,'training'));
L3small = L3Set(L3small,'rendering',L3Get(L3,'rendering'));

% Copy the structure of the clusters, but remove the data stored in the
% clusters.
L3small = L3Set(L3small,'clusters',L3Get(L3,'clusters'));
for patchnum = 1:numel(L3small.clusters)
    if isfield(L3small.clusters{patchnum},'members')
        L3small.clusters{patchnum} = rmfield(L3small.clusters{patchnum},'members');
    end
end

% Clear flat and saturation indices from L3 structure
L3small = L3ClearIndicesData(L3small);

end
