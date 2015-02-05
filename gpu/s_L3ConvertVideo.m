
%% Init Parameters
nFrames = 1800;
ao = 0.0150; ag = 0.5639;

%% Convert raw data to format for GPU rendering
for fIndex = 0 : nFrames - 1
    % fName = sprintf('C:\\Users\\Haomiao\\Desktop\\L3-tmp\\L3-GPU\\L3-GPU\\video\\output_%07d.raw', fIndex);
    fName = sprintf('H:\\Film2\\output_%07d.raw', fIndex);
    sensor = fbRead(fName);
    volts = sensorGet(sensor, 'volts');
    volts = single(volts - ao / ag);
    
    % fName = sprintf('C:\\Users\\Haomiao\\Desktop\\L3-tmp\\L3-GPU\\L3-GPU\\video\\output_%07d.dat', fIndex);
    fName = sprintf('H:\\Film2_dat\\output_%07d.dat', fIndex);
    pf = fopen(fName, 'wb');
    fwrite(pf, single(volts), 'float');
    fclose(pf);
end

%% Convert GPU output format to Matlab image format
outputVideo = VideoWriter('L3_video_2.avi');
outputVideo.FrameRate = 24;
open(outputVideo);
for fIndex = 0 : nFrames - 1
    fprintf('Creating Frame %d in video\n', fIndex + 1);
    % fName = sprintf('C:\\Users\\Haomiao\\Desktop\\L3-tmp\\L3-GPU\\L3-GPU\\video_out\\frame%07d.dat', fIndex);
    fName = sprintf('H:\\Film2_out\\output_%07d.dat', fIndex);
    pf = fopen(fName, 'rb');
    I = fread(pf, 1280*720*3, 'float');
    I = reshape(I, [3 1280 720]);
    I = permute(I, [2 3 1]);
    fclose(pf);
    
    out_image=I;
    [~, lrgb] = xyz2srgb(out_image);

    %  scale and crop
    lrgb = lrgb / max(lrgb(:));
    srgb = lrgb2srgb(ieClip(lrgb,0,1));
    
    writeVideo(outputVideo, rot90(srgb, -1));
end
close(outputVideo);