%% s_L3ClassLuminanceTexture
%
% Show the luminance and texture classes on the image from a camera that
% has an image and an L3 training structure.
%


%% Get a camera with an L3 trained structure
%% Texture image
L3 = cameraGet(camera,'vci L3');
clusterIdx = L3Get(L3,'cluster index');
vcNewGraphWin;  imagesc(clusterIdx); axis image; axis off;
colorbar
title('Flat/ Texture Classification Results')

%% Luminance image
L3 = cameraGet(camera,'vci L3');
lumIdx = L3Get(L3,'luminance index');
vcNewGraphWin;  imagesc(lumIdx); axis image; axis off;
colorbar
title('Luminance Value Used')


%% END
