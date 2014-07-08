clear, clc, close all
s_initISET

%% Render
for ii = [1, 3, 5]
    for cameratypenum = 1:2
    switch cameratypenum
        case 1
            cameratype = 'L3';
        case 2
            cameratype = 'basic';
    end
        % RGBNx
        camerafile = [cameratype,'camera_RGBN' num2str(ii) '.mat'];
        disp(['------------   ',camerafile,'  ---------------------'])
        load(camerafile)        
        [meanbias, PSNR, mssim, vSNR] = metricsCamera_rgbn(camera);
        save(camerafile,'camera','meanbias','PSNR','mssim','vSNR')

        % RGBNx_low
        camerafile = [cameratype,'camera_RGBN' num2str(ii) '_low.mat'];
        disp(['------------   ',camerafile,'  ---------------------'])
        load(camerafile)        
        [meanbias, PSNR, mssim, vSNR] = metricsCamera_rgbn(camera);
        save(camerafile,'camera','meanbias','PSNR','mssim','vSNR')

        % KKKNx
        camerafile = [cameratype,'camera_KKKN' num2str(ii) '.mat'];
        disp(['------------   ',camerafile,'  ---------------------'])
        load(camerafile)        
        [meanbias, PSNR, mssim, vSNR] = metricsCamera_rgbn(camera);
        save(camerafile,'camera','meanbias','PSNR','mssim','vSNR')

        % KKKNx_low
        camerafile = [cameratype,'camera_KKKN' num2str(ii) '_low.mat'];
        disp(['------------   ',camerafile,'  ---------------------'])
        load(camerafile)        
        [meanbias, PSNR, mssim, vSNR] = metricsCamera_rgbn(camera);
        save(camerafile,'camera','meanbias','PSNR','mssim','vSNR')
    end
    
end


