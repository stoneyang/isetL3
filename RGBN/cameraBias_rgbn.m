function meanbias = cameraBias_rgbn(camera, lum)

% Modeled after s_imageReflectanceChart

%% Change optics
camera.oi.optics.offaxis = 'skip';
camera.oi.optics.model = 'skip';


%% Make a reflectance chart

% The XYZ values of the chart are in the scene.chartP structure
scene = sceneCreate('reflectance chart');
scene = sceneSet(scene,'wave',400:10:680);




%% Put N channel image in 3 channels for result
sz = sceneGet(scene, 'size');
[nIdeal, camera] = cameraComputesrgb_RGBN(camera, scene, lum, sz, [], [], 0);
nIdeal = nIdeal/max(nIdeal(:));
nResult = camera.vci.L3.L3n;
nResult = nResult / mean(nResult(:)) * mean(nIdeal(:));

ip = cameraGet(camera,'ip');
ip = imageSet(ip,'Result',repmat(nResult,[1,1,3]));

%%
figure
imagesc(nIdeal)
axis image
title('Ideal')

figure
imagesc(nIdeal)
axis image
title('Estimated')


%% Collect up the chart ip data and the original XYZ

% Use this to select by hand, say the chart is embedded in another image
% cp = chartCornerpoints(ip);   % Corner points are (x,y) format

% If the chart occupies the entire image, then cp can be the whole image
%
sz = imageGet(ip,'size');
cp(1,1) = 1; cp(1,2) = sz(1);
cp(2,1) = sz(2); cp(2,2) = sz(1);
cp(3,1) = sz(2); cp(3,2) = sz(1);
cp(4,1) = 1; cp(4,2) = 1;

% Number of rows/cols in the patch array
r = scene.chartP.rowcol(1);
c = scene.chartP.rowcol(2);

[mLocs,pSize] = chartRectangles(cp,r,c);

% These are down the first column, starting at the upper left.
delta = round(min(pSize)/2);   % Central portion of the patch



%%

mRGB  = chartPatchData(ip,mLocs,delta);
ip = imageSet(ip,'Result',repmat(nIdeal,[1,1,3]));
mRGBideal  = chartPatchData(ip,mLocs,delta);

% Extract n channel from identical 3 bands
mRGB = mRGB(:,1);  
mRGBideal = mRGBideal(:,1);

%%
meanbias = mean(abs(mRGB - mRGBideal));


