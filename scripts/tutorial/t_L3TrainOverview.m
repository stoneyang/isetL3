%% t_L3TrainOverview
%
% Demonstrate the L3 training process in overview
%
% Separate scripts t_L3Train<TAB> examine specific choices within the
% algorithm.
%
% Copyright VISTASOFT Team, 2015
%

%%
ieInit

%% Create and initialize L3 structure
L3 = L3Create;
L3 = L3Initialize(L3);  % use default parameters

blockSize = 5;               % Size of the solution patch used by L3
L3 = L3Set(L3,'block size', blockSize);


%%  The analysis here is an expansion of L3Train.m

% The scenes used for training are set by default in L3
% By default, there are 7 scenes.
nScenes = L3Get(L3,'n scene');
fprintf('Number of training scenes: %i\n',nScenes)

% Here is an example training scene
scene = L3Get(L3,'scene',1);
vcAddObject(scene); sceneWindow;

% To make this code run fast, we reduce the training scenes here to just
% two
scenes = L3Get(L3,'scenes');
scenes = scenes(1:2);
L3 = L3Set(L3,'scenes',scenes);

% In general, we should have a simple way to alter the scene selection
% here and re-attach the new scenes or modified scenes (e.g., by an
% illuminant change as per FG).

%%  Next we create examples of the sensor and ideal responses
%
% This code explores an overview of what happens in 

L3 = L3Set(L3,'sensor exptime',0.02); 
[desiredIm, inputIm] = L3SensorImageNoNoise(L3);
fprintf('Exposure time set %.1f ms\n',L3Get(L3,'sensor exptime','ms'))

% The camera that we are designing for design is stored in L3.sensor.design
% The default camera has 4 sensors (RGBW)
sensor = L3Get(L3,'design sensor');
plotSensor(sensor,'color filters');

% There are two cell arrays, one for each of the input scenes
fprintf('Number of scenes:  %i\n',size(inputIm,1))

% The input images are the sensor voltages from the scene.  In this case
% there are four color filters and thus four images.  
% Why is the white image saturated?
vcNewGraphWin([],'tall');
for ii=1:4
    subplot(2,2,ii), imagesc(inputIm{1}(:,:,ii)); colormap(gray); axis image
end

% vcNewGraphWin; tmp = inputIm{1}(:,:,4); hist(tmp(:),50)
% These are the XYZ images.  The scale drives me nuts (BW).
vcNewGraphWin([],'tall');
for ii=1:3
    subplot(3,1,ii), imagesc(desiredIm{1}(:,:,ii)); colormap(gray); axis image
end

%%  We should explore the L3Train code more ...

% The code is below and in the file.  But here we just do the training and
% then visualize the resulting L3 transforms.
L3 = L3Train(L3);
fname = ieTempfile('mat');
save(fname,'L3');

%% Assuming L3 has been saved
% /private/tmp/ie_tp8e52bbf4_644c_49c4_809d_075a10c8d3c7.mat
load(fname)
camera = L3CameraCreate(L3);
s = L3Get(L3,'scenes',1)
camera = cameraCompute(camera,s);

%% Visualize the filters and the clusters in various ways
%
% See L3RenderDemo for examples to use here.

%% Show CFA and RAW image
% The CFA pattern is visible in the RAW image.  Here the RAW image is
% drawn as a monochrome image although the measurement at each pixel
% has an associated color.
%
% The 2x2 RGBW CFA is used in this example.

% RAW sensor image
inputIm = cameraGet(camera,'sensor volts');

vcNewGraphWin; imagesc(inputIm/max(inputIm(:))); colormap(gray)
sz      = sensorGet(sensor,'size');
title('RAW sensor image')

% RGBW CFA
L3plot(L3,'cfa full');       title('RGBW CFA')

% Spectral sensitivities
wave = sensorGet(sensor,'wave');
sensitivities = sensorGet(sensor,'spectral QE');
figure;   hold on
plotcolors='rgbk';
for colornum=1:4
    plot(wave,sensitivities(:,colornum),plotcolors(colornum))
end
xlabel('Wavelength (nm)');  title('Spectral Sensitivities')




%%  The rest of L3Train ... to be simplified here

% numclusters    = L3Get(L3,'n clusters');
% lumList    = L3Get(L3,'luminance list');
% 
% %% Main loop
% 
% % Specify which type of 
% cfaPattern = sensorGet(L3Get(L3,'sensor design'),'cfa pattern');
% 
% % For each pixel in the cfa pattern, build a separate transform
% for rr=1:size(cfaPattern,1)
%     for cc=1:size(cfaPattern,2)
%         disp('**********Patch Type**********');
%         disp([rr,cc]);
%         
%         % The L3 structure is set this way to simplify various sets/gets
%         L3 = L3Set(L3,'patch type',[rr,cc]);   
% 
%         % The blockpattern tells you what color is measured at each pixel
%         % of the patch.  We should show the 
%         % blockpattern = L3Get(L3,'block pattern');
%         % vcNewGraphWin; imagesc(blockpattern); colormap(cool)
%         %
%         % sensorCheckArray(L3Get(L3,'sensor'))
%         
%         % Add no saturation case to saturation list
%         nfilters = L3Get(L3, 'n filters');
%         saturationcase = zeros(nfilters, 1);
%         L3 = L3addSaturationCase(L3, saturationcase);
% 
%         saturationtype = 0;
%         L3 = L3Set(L3, 'saturation type', saturationtype); % next work on 1st saturation case
%         
%         
%         while saturationtype < L3Get(L3, 'length saturation list')  % not done with all cases
% 
%             % move on to next saturation type
%             saturationtype = 1 + L3Get(L3, 'saturation type');
%             L3 = L3Set(L3, 'saturation type', saturationtype);
%             
%             saturationcase = L3Get(L3,'saturation list', saturationtype);
%             disp('****Saturation Type****');
%             disp(saturationcase);
%             
%             % Let's try to move this outside of the saturation loop.  That
%             % way we only will have to load once per patch type.
%             [sensorPatches, idealVec] = L3trainingPatches(L3, inputIm, desiredIm);
% 
%             % Store the answer.
%             L3 = L3Set(L3,'sensor patches',sensorPatches);
%             L3 = L3Set(L3,'ideal vector',idealVec);
% 
%             for ll=1:length(lumList)
%                 %Set current patch luminance index for training
%                 L3 = L3Set(L3,'luminance type',ll);
%                 disp(ll);
% 
%                 % Scale the light so that each patch has desired luminance
%                 L3 = L3AdjustPatchLuminance(L3);
%                 
%                 % Check and add to list any new saturation cases from data
%                 L3 = L3findnewsaturationcases(L3);
%                 
%                 % Find saturation indices  (which patches match the desired
%                 % saturation case)
%                 [saturationindices, L3] = L3Get(L3,'saturation indices');
%                 % Saturation indices should have been found and stored in
%                 % L3 structure by L3findnewsaturationcases.  If so, they
%                 % are just retrieved from memory.
%                 
%                 % Skip current luminance type if there are at least a
%                 % minimal number of patches for current saturation case.
%                 nsaturationpatches = sum(saturationindices);
%                 if nsaturationpatches > L3Get(L3,'n samples per patch')
%                     % Record how many patches will be used for training
%                     % this case
%                     L3 = L3Set(L3, 'n saturation patches', nsaturationpatches);
%                     
%                     %% Global pipeline
%                     % First find the globalpipelinefilter.
%                     %
%                     % This is a linear filter computed with the Wiener estimation process.
%                     % globalpipelinefilter is used to calculate the outputs in the case when we
%                     % do not separate the inputs into different categories of patches (e.g.,
%                     % flat/texture). This is an alternative to the L^3 algorithm, which
%                     % includes segmentation of the patch types.
% 
%                     %Variable oversample controls how the noise optimization is built into the
%                     %optimized filters
%                     % oversample=0 means optimize for the variance of the expected measurement
%                     %    noise and find Wiener filter
%                     % oversample=n (positive integer) means for each noise-free patch, generate
%                     %    n noisy copies of the patch and find pseudoinverse filter
%                     %    (total number of noisy patches is trainpatches*oversample)
%                     oversample = L3Get(L3,'n oversample');
%                     % oversample is used to distinguish the noise-free (no extra samples) and
%                     % noisy case (oversample extra samples).  When there are no extra samples,
%                     % we are computing the noise-free case.  We use the value of oversample to
%                     % create additional noise samples and compute in the noisy case.
%                     if oversample == 0
%                         % Wiener filter:  Don't add noise to patches. But when finding filter
%                         % in L3findfillters use Wiener filter so filter is robust to noise.
%                         noiseFlag = 2;
%                     else
%                         %Pseudoinverse filter:  Add noise to patches. Then when finding filter
%                         %just use the pseudoinverse.  Resultant filter is best for that
%                         %particular noisy sample.
%                         noiseFlag = 0;
% 
%                         % Upsample number of patches
%                         L3 = L3PatchesOversample(L3,oversample);
%                     end
%                     
%                     L3 = L3Set(L3, 'contrast type', 1);
%                     globalpipelinefilter = L3findfilters(L3,noiseFlag);
%                     L3 = L3Set(L3,'global filter',globalpipelinefilter);
% 
%                     % Visualization
%                     % L3showfilters('global',globalpipelinefilter,blockSize);
%                     % meansfilter = L3Get(L3,'means filter');
%                     % L3showfilters('means',meansfilter,blockSize);
% 
%                     %% Split patches into flat and texture
%                     %Determine which patches are flat or textured based on the contrast
%                     contrasts =  L3Get(L3,'sensor patch contrasts');
%                     sortedcontrasts = sort(contrasts);
% 
%                     %If oversample~=0, the flatthreshold value found here was
%                     %calculated assuming there is no noise.  It is used to ideally 
%                     %classify the training patches into flat and texture.  Later 
%                     %flaththreshold is calculated again to give apporixmately the same
%                     %classification when there is noise.  The value needs to be
%                     %increased in order to account for the increase in contrast that
%                     %noise causes.
%                     flatpercent = L3Get(L3,'flat percent');
%                     if flatpercent == 0,         flatthreshold = -1;
%                     elseif flatpercent == 1,     flatthreshold = inf;
%                     else
%                         flatthreshold = sortedcontrasts(round(length(contrasts)*flatpercent));
%                     end
%                     L3 = L3Set(L3,'flat threshold',flatthreshold);
% 
%                     % These indices identify which are the flat patches.
%                     % flatindices=(flatthreshold>=contrasts);
% 
%                     % sum(flatindices)/length(flatindices)
%                     % This should be flatpercent
% 
%                     %% Find filters for flat patches
%                     [flatindices, L3] = L3Get(L3,'flat indices');
%                     % This call stores flat indices in L3 structure so
%                     % that it won't need to be computed again.              
% 
%                     %enforce symmetry for flat filters
%                     symmetryflag = 1; 
%                     L3 = L3Set(L3, 'contrast type', 2);
%                     flatfilters = L3findfilters(L3,noiseFlag,flatindices,symmetryflag);
% 
%                     % This is set for a particular cfaPosition (could be the current default)
%                     L3 = L3Set(L3,'flat filters',flatfilters);
% 
%                     % Visualize
%                     % L3showfilters('flat',flatfilters,blockSize,meansfilter,blockpattern);
% 
%                     %% Adjust thresholds for noise
%                     % If thresholds were calculated on noise-free patches0 (oversample==0),
%                     % they need to be increased to work when there is noise.  So we run the
%                     % noise case to determine the threshold.
%                     if oversample == 0
%                         contrastsNoise = L3Get(L3,'sensor patch contrast noisy');
%                         contrastsNoise = sort(contrastsNoise);
% 
%                         %Adjust contrast thresholds
%                         if flatpercent==0,        noisyflatthreshold=-1;
%                         elseif flatpercent==1,    noisyflatthreshold=inf;
%                         else
%                             noisyflatthreshold = ...
%                                 contrastsNoise(round(length(contrastsNoise)*flatpercent));
%                         end
% 
%                     else
%                         %oversample is positive indicating noisy samples were trained on
%                         %and no adjustment needed
%                         noisyflatthreshold = flatthreshold;
%                     end
% 
%                     % This is the threshold we use in practice
%                     L3 = L3Set(L3,'flat threshold',noisyflatthreshold);
% 
% 
%                     %% Flip texture patches into canonical form
%                     L3 = L3flippatches(L3);
% 
%                     %% Perform clustering on texture patches
%                     L3 = L3findclusterstree(L3);
% 
%                     %% Create the texture filters
%                     texturefilters = cell(1,numclusters);
% 
%                     trainclustermembers = L3Get(L3,'cluster members');
%                     % vcNewGraphWin; hist(trainclustermembers(:))
% 
%                     % texturefreqs   = zeros(1,numclusters);
%                     %maxtreedepth determines the number of clusters of texture patches,
%                     %maxtreedepth-1 branching operations are required to determine the cluster for a patch
%                     %2^(maxtreedepth-1) is the number of clusters (leaves of the tree)
%                     %maxtreedepth of 1 gives only one texture cluster
%                     maxtreedepth = L3Get(L3,'max tree depth');
% 
%                     % Find the filter for each cluster
%                     L3 = L3Set(L3, 'contrast type', 3);
%                     for clusternum = 1:numclusters
%                         clusterindices = ...
%                             floor(trainclustermembers/2^(maxtreedepth-floor(log2(clusternum))-1))==clusternum;
% 
%                         % texturefreqs(clusternum)=sum(clusterindices)/nPatches;
% 
%                         %don't enforce symmetry for texture patches because they
%                         %are oriented
%                         symmetryflag=0; 
%                         texturefilters{clusternum} = ...
%                             L3findfilters(L3,noiseFlag,clusterindices,symmetryflag);
% 
%                     end
%                     L3 = L3Set(L3,'texture filters',texturefilters);
% 
%                 else   % if not enough patches for luminance value
%                     L3 = L3Set(L3,'empty filter',[]);  % place empty in filters structure
%                     
%                 end % end if statement that skips luminance values with not enough patches
%             end % end loop over luminance values            
%         end   % end while statement for all saturation cases
%         
%         % delete saturation cases with no trained filters
%         L3 = L3deletesaturationcases(L3);
%         
%     end  % end loop for patch type col
% end  % end loop for patch type row


