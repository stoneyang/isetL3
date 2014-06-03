function [mssim, ssim_map] = ssim(nResult, nIdeal)
nResult_norm = nResult / max(nResult(:));
nIdeal_norm = nIdeal / max(nIdeal(:));

nResult_uint8 = uint8(nResult_norm * 255);
nIdeal_uint8 = uint8(nIdeal_norm * 255);

K = [0.01 0.03]; % constants in the SSIM index formula
window = fspecial('gaussian', 11, 1.5); % local window for statistics
L = 255; % L: dynamic range of the images
[mssim, ssim_map] = ssim_index(nResult_uint8, nIdeal_uint8, K, window, L);

end

