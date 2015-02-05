%% s_camera2L3GPU
%
% This part is the code used to generate L3_GPU.mat, the structure used in
% L3 GPU rendering
% 
% This part will interpolate for L3 missing training luminance levels
%
% (HJ) ISETBIO TEAM, 2015

%% Init
ieInit;

%% Load camera and L3 parameters
load('L3camera_fb.mat');
L3 = camera.vci.L3;

%% Interpolate L3 filters for missing luminance
% Ugly interpolation code goes here
for ii = 1 : 4 % cfa_size = [4 4]
    for jj = 1 : 4 % cfa
        for kk = 1 : 19 % sat_range = 1:10
            for ss = 1 : 20 % luminance levels
                if ~isempty(L3.clusters{ii,jj,ss,kk})
                    cur_cluster = L3.clusters{ii,jj,ss,kk};
                    cur_filters = L3.filters{ii,jj,ss,kk};
                    break;
                end
            end
            if isempty(cur_cluster), error('cluster not found'); end
            for ss = 1 : 20
                if ~isempty(L3.clusters{ii,jj,ss,kk})
                    cur_cluster = L3.clusters{ii,jj,ss,kk};
                    cur_filters = L3.filters{ii,jj,ss,kk};
                else
                    L3.clusters{ii,jj,ss,kk} = cur_cluster;
                    L3.filters{ii,jj,ss,kk} = cur_filters;
                end
            end
        end
    end
end

%% Save structure
save L3_GPU.mat L3