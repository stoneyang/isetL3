%% s_L3Render_GPU
%
%   This script illustrates how to use cuda GPU for L3 rendering
%
% See also:
%   s_L3RenderWalkThrough
%
%  (HJ) ISETBIO TEAM, 2014

%% Load data and init
%  Load L3 and sensor structure
load('L3_GPU.mat', 'L3');
fName = fullfile(fbRootPath, 'data', 'images', ...
                 'sunny', '001_Sunny_f16.0.RAW');
sensor = fbRead(fName);


%% Prepare input data for GPU computing
% Get volts from sensor
volts = sensorGet(sensor, 'volts');
image_size = size(volts);

ao = 0.0150; ag = 0.5639;
volts = single(volts - ao / ag); % remove analog offset

% Get CFA from sensor
cfa = sensorGet(sensor, 'cfa pattern');
cfa = uint16(cfa - 1); % make cfa 0-indexed

% Get Luminace list from L3
lum_list = single(L3Get(L3, 'luminance list'));

% Get sat_list
cfa_type   = unique(cfa(:));
cfa_size   = size(cfa);
num_filter = length(cfa_type);
sat_encode = 2.^(0:num_filter-1);

sat_list = zeros(2^num_filter, cfa_size(1), cfa_size(2));
for ii = 1 : cfa_size(1)
    for jj = 1 : cfa_size(2)
        cur_sat_list = sat_encode * L3.training.saturationList{ii, jj} + 1;
        sat_list(cur_sat_list, ii, jj) = 1 : length(cur_sat_list);
    end
end
sat_list = single(sat_list); % sat_list is 1-indexed

% Get flat threshold
flat_threshold = cellfun(@(x) x.flat, L3.clusters);
flat_threshold = single(flat_threshold(:));

% Get flat filters
flat_filters = cellfun(@(x) x.flat, L3.filters, 'UniformOutput', false);
flat_filters = reshape(flat_filters, [1 1 numel(flat_filters)]);
flat_filters = cell2mat(flat_filters);
flat_filters = single(flat_filters);

% Get texture filters
text_filters = cellfun(@(x) x.texture{1}, L3.filters, ...
                       'UniformOutput', false);
text_filters = reshape(text_filters, [1 1 numel(text_filters)]);
text_filters = cell2mat(text_filters);
text_filters = single(text_filters);

% pre-allocate output image
out_image = zeros([image_size 3], 'single', 'gpuArray');

%% Render on GPU
tic;
kernel = parallel.gpu.CUDAKernel('L3Render.ptx', 'L3Render.cu');
kernel.GridSize = [image_size(1) 1 1];
kernel.ThreadBlockSize = [image_size(2) 1 1];
volts = gpuArray(volts);
cfa = gpuArray(cfa);
lum_list = gpuArray(lum_list);
sat_list = gpuArray(sat_list);
flat_filters = gpuArray(flat_filters);
text_filters = gpuArray(text_filters);
flat_threshold = gpuArray(flat_threshold);

out_image = feval(kernel, out_image, volts, cfa, lum_list, sat_list, ...
                  flat_filters, text_filters, flat_threshold);

out_image = gather(out_image);
toc;

%  xyz to srgb
[~, lrgb] = xyz2srgb(out_image);

%  scale and crop
lrgb = lrgb / max(lrgb(:));
srgb = lrgb2srgb(ieClip(lrgb,0,1));

% show image
vcNewGraphWin; imshow(rot90(srgb, -1));