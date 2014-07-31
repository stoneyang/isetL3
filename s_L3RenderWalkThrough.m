%% Trying to rewrite L3 process with colfilt
%
%    This could help understand how L3 render works
%    The comments in this script are the understanding of HJ and thus, they
%    could be wrong.
%    
% (HJ) ISETBIO TEAM, 2014

%% Init
s_initISET

% Load camera
% L3 structure is in camera.vci.L3
% L3 filters are stored as 4D cell-array in L3.filters
% Dimensions for L3.filter are 
%   {patch_type(1), patch_type(2), luminance_index, saturate_index}
% Inside each cell array, there are filters for different texture_index
%
% For any patch centered as (x,y), patchType can be computed as
%   mod(x, cfa_size(2)), mod(y, cfa_size(1))
% 
% luminance_index is the bin index of L3Get(L3, 'luminance list')
% luminace of the patch can be computed by mean of all measured channels:
%   L3Get(L3, 'sensor patch luminance')
%
% saturate_index is computed by comparing saturate pattern of new patch to
% training patch, this is done by
%   L3Get(L3, 'sensor patch saturation')
%
% texture_index indicates the texture type of the patch. If the patch is
% flat, texture_index is 0. Otherwise, it's one of the positive numbers
% indicating which texture filter to be used.
%


% This part is the code used to generate L3_GPU.mat
% This part interpolate for L3 missing training luminance levels
%
% load('L3camera_fb.mat');
% L3 = camera.vci.L3;
%
% Interpolate L3 filters for missing luminance
% Ugly interpolation code goes here
% for ii = 1 : 4 % cfa_size = [4 4]
%     for jj = 1 : 4
%         for kk = 1 : 10 % sat_range = 1:10
%             for ss = 1 : 20
%                 if ~isempty(L3.clusters{ii,jj,ss,kk})
%                     cur_cluster = L3.clusters{ii,jj,ss,kk};
%                     cur_filters = L3.filters{ii,jj,ss,kk};
%                     break;
%                 end
%             end
%             for ss = 1 : 20
%                 if ~isempty(L3.clusters{ii,jj,ss,kk})
%                     cur_cluster = L3.clusters{ii,jj,ss,kk};
%                     cur_filters = L3.filters{ii,jj,ss,kk};
%                 else
%                     L3.clusters{ii,jj,ss,kk} = cur_cluster;
%                     L3.filters{ii,jj,ss,kk} = cur_filters;
%                 end
%             end
%         end
%     end
% end
%
% save L3_GPU.mat L3

% Load L3 structure for data file
load('L3_GPU.mat', 'L3');

% Read five-band raw images
fName = fullfile(fbRootPath, 'data', 'images', ... 
                'sunny', '001_Sunny_f16.0.RAW');
sensor = fbRead(fName);
volts = sensorGet(sensor, 'volts');

% Set parameters for five-band
ao = 0.0150; ag = 0.5639;
volts = volts - ao / ag; % remove analog offset
image_size = size(volts);

%% Compute parameters: patch type, luminance / saturation, texture index
%  Get cfa size, patch size and border size
cfa = sensorGet(sensor, 'cfa pattern');
cfa_size = size(cfa);

patch_size = L3Get(L3, 'block size');

border_size = round((patch_size - 1) / 2);

%  Transform image to columns
%  Each patch will be in a column
volts = im2col(volts, patch_size, 'sliding');

%  Compute patch_type for each column (patch)
[Y, X] = meshgrid(border_size(2)+1:image_size(2)-border_size(2), ...
                  border_size(1)+1:image_size(1)-border_size(1));
X = mod(X-1, cfa_size(1)) + 1; Y = mod(Y-1, cfa_size(2))+1;
patch_type = [X(:) Y(:)]';

%  Compute luminance and saturation type of each column (patch)
%  assuming that cfa_size is not large, the following for-loop should not
%  be too slow
cfa_type   = unique(cfa(:));
num_filter = length(cfa_type);
sat_encode = 2.^(0:num_filter-1);

voltage_max = L3Get(L3, 'voltage max');
is_saturate = volts > voltage_max;

patch_lum = nan(1, size(volts, 2)); % init to nan instead of zeros
patch_sat = nan(1, size(volts, 2));
patch_contrast = nan(1, size(volts, 2));

for ii = 1 : cfa_size(1)
    for jj = 1 : cfa_size(2)
        % now patch is of center cfa(ii, jj)
        r_index = ii-border_size(1):ii+border_size(1);
        r_index = mod(r_index - 1, cfa_size(1)) + 1;
        c_index = jj-border_size(2):jj+border_size(2);
        c_index = mod(c_index - 1, cfa_size(2)) + 1;
        
        cfa_index = cfa(r_index, c_index); cfa_index = cfa_index(:);
        cfa_count = hist(categorical(cfa_index));
        
        % assume that cfa_index are from 1 to N, we compute weights for
        % each channel as
        weights = zeros(num_filter, length(cfa_index));
        index = (0 : length(cfa_index) - 1) * num_filter + cfa_index';
        weights(index) = 1./cfa_count(cfa_index);
        % weights = 1./cfa_count(cfa_index)/length(cfa_count);
        
        % compute luminance as weigthed sum
        index = patch_type(1, :) == ii & patch_type(2, :) == jj;
        patch_mean = weights * volts(:, index);
        patch_lum(:, index)  = mean(patch_mean);
        
        % compute contrast for each patch
        patch_contrast(:, index) = ...
                mean(abs(volts(:, index) - patch_mean(cfa_index, :)));
        
        % compute saturation type
        saturate_func = @(x) any(is_saturate(cfa_index == x, index));
        patch_sat(index) = sat_encode * cell2mat(arrayfun(saturate_func,...
                                    cfa_type, 'UniformOutput', 0)) + 1;
                                        
        % convert saturation type to saturation index
        sat_list = sat_encode * L3.training.saturationList{ii, jj} + 1;
        sat_lookup = zeros(2^num_filter, 1);
        sat_lookup(sat_list) = 1 : length(sat_list);
        patch_sat(index) = sat_lookup(patch_sat(index));
        
        % deal with missing saturation index (sat_lookup == 0)
        % the idea here is move those missing saturation index to the
        % existing ones with smallest mean change
        sat_not_found = (patch_sat == 0);
        if ~any(sat_not_found), continue; end % all index found
        d = patch_mean(:, patch_sat(index) == 0) - voltage_max;
        d = reshape(d, [num_filter 1 size(d, 2)]);
        [~, replace_index] = min(sum(max(bsxfun(@times, d, ...
                        1 - 2 * L3.training.saturationList{ii, jj}), 0)));
        patch_sat(sat_not_found) = replace_index;
    end
end

% clear local variable to avoid further usage
clear patch_mean r_index c_index cfa_index cfa_count sat_list index
clear d replace_index X Y weights sat_lookup sat_not_found sat_encode

% convert luminance to luminance index
lum_list = L3Get(L3, 'luminance list'); % luminance list from training
[~, patch_lum] = min(abs(bsxfun(@minus, lum_list(:), patch_lum)));

% convert contrast to flat / texture index
% assume that L3 structure has been interpolated for missing training
% luminance
flat_threshold = cellfun(@(x) x.flat, L3.clusters);
index = sub2ind(size(L3.clusters), patch_type(1, :), patch_type(2, :), ...
                                   patch_lum, patch_sat);
is_flat = patch_contrast < flat_threshold(index);


%% Render
%  At this point, we have patch_type, patch_lum and patch_sat and we could
%  lookup filters and apply to each patch
out_image = zeros(3, size(volts, 2));

% define transition indices
low  = L3Get(L3, 'transition contrast low');
high = L3Get(L3, 'transition contrast high');
is_transition = (patch_contrast > flat_threshold(index) * low) & ...
                (patch_contrast < flat_threshold(index) * high);

% define transition weights
weights = zeros(1, size(volts, 2));
% weights(is_flat) = 1;
weights(is_transition) = (patch_contrast(is_transition) ./ ...
                flat_threshold(index(is_transition)) - low) / (high - low);

% apply filter to patches - flat
is_flat = is_flat & ~is_transition;
filter_index = unique(index(is_flat));
for ii = filter_index
    filter = L3.filters{ii}.flat;
    cur_patch = (index == ii) & is_flat;
    out_image(:, cur_patch) = filter * volts(:, cur_patch);
end

% apply filter to patches - texture
is_texture = ~(is_flat | is_transition);
filter_index = unique(index(is_texture));
for ii = filter_index
    filter = L3.filters{ii}.texture{1};
    cur_patch = (index == ii) & is_texture;
    out_image(:, cur_patch) = filter * volts(:, cur_patch);
end

% apply filter to patches - transition
filter_index = unique(index(is_transition));
for ii = filter_index
    filter_flat = L3.filters{ii}.flat;
    filter_texture = L3.filters{ii}.texture{1};
    cur_patch = (index == ii) & is_transition;
    out_image(:, cur_patch) = ...
      bsxfun(@times, filter_flat * volts(:, cur_patch), ...
                weights(cur_patch)) + ...
      bsxfun(@times, filter_texture * volts(:, cur_patch), ...
                1 - weights(cur_patch));
end

%% Generate RGB image
%  reshape xyz to height x width x 3
out_image = reshape(out_image', [image_size - 2 * border_size, 3]);

%  xyz to srgb
[~, lrgb] = xyz2srgb(out_image);

%  scale and crop
lrgb = lrgb / max(lrgb(:));
srgb = lrgb2srgb(ieClip(lrgb,0,1));

% show image
vcNewGraphWin; imshow(rot90(srgb, -1));