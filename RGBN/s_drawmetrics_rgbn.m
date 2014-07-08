
widths = [1,3,5];

%% Load all metrics
meanbias = zeros(2, 4, length(widths));
PSNR = zeros(2, 4, length(widths));
mssim = zeros(2, 4, length(widths));
vSNR = zeros(2, 4, length(widths));
legendstrs = cell(1,4);

for ii = 1 : length(widths)
    width = widths(ii);
    for cameratypenum = 1:2
        switch camertypenum
            case 1
                cameratype = 'L3';
            case 2
                cameratype = 'basic';
        end
        
        for method = 1:4
            switch method
                case 1
                    legendstrs{method} = 'RGBN';
                    camerafile = [cameratype,'camera_RGBN' num2str(width) '.mat'];
                case 2
                    legendstrs{method} = 'RGBN low';
                    camerafile = [cameratype,'camera_RGBN' num2str(width) '_low.mat'];
                case 3
                    legendstrs{method} = 'XXXN';
                    camerafile = [cameratype,'camera_KKKN' num2str(width) '.mat'];
                case 4
                    legendstrs{method} = 'XXXN low';
                    camerafile = [cameratype,'camera_KKKN' num2str(width) '_low.mat'];
            end

            tmp = load(camerafile);
            meanbias(cameratypenum,method,ii) = tmp.meanbias;
            PSNR(cameratypenum,method,ii) = tmp.PSNR;
            mssim(cameratypenum,method,ii) = tmp.mssim;
            vSNR(cameratypenum,method,ii) = tmp.vSNR;
        end
    end
end


%% Make Plot
figure
plot(widths, meanbias, 'LineWidth',2)
title('Mean Bias')
legend(legendstrs,'Location','NorthEast')
grid on

figure
plot(widths, vSNR, 'LineWidth',2)
title('vSNR')
legend(legendstrs,'Location','SouthEast')
grid on

figure
plot(widths, PSNR, 'LineWidth',2)
title('PSNR')
legend(legendstrs,'Location','SouthEast')
grid on

figure
plot(widths, mssim, 'LineWidth',2)
title('mssim')
legend(legendstrs,'Location','SouthEast')
grid on

