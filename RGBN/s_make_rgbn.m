clear, clc, close all

%% Load Spectra
wavelength = [400:10:680]';

RGBN = ieReadColorFilter(wavelength, 'RGBN');

r = RGBN(:,1);
g = RGBN(:,2);
b = RGBN(:,3);
n = RGBN(:,4);
n = n / max(n) * max(g) * 0.4;
k = r - r;

%% RGBN1
name = 'RGBN1_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = (wavelength == 420) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBN3
name = 'RGBN3_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 410) .* (wavelength <= 430)) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBN5
name = 'RGBN5_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 400) .* (wavelength <= 440)) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% KKKN1
name = 'KKKN1_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = (wavelength == 420) .* max(n);
data = [k, n];
filterNames = {'k', 'n'};
filterOrder = [1, 1;...
               2, 1];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% KKKN3
name = 'KKKN3_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 410) .* (wavelength <= 430)) .* max(n);
data = [k, n];
filterNames = {'k', 'n'};
filterOrder = [1, 1;...
               2, 1];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% KKKN5
name = 'KKKN5_low';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 400) .* (wavelength <= 440)) .* max(n);
data = [k, n];
filterNames = {'k', 'n'};
filterOrder = [1, 1;...
               2, 1];
save(name,'comment','data','filterNames','filterOrder','wavelength')
