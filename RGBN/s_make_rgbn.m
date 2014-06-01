clear, clc, close all

%% Load Spectra
wavelength = [400:10:680]';

RGBN = ieReadColorFilter(wavelength, 'RGBN');

r = RGBN(:,1);
g = RGBN(:,2);
b = RGBN(:,3);
n = RGBN(:,4);

%% RGBN1
name = 'RGBN1';
comment = 'Bayer pattern with one G replaced with narrow band';
n = (wavelength == 420) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBN3
name = 'RGBN3';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 410) .* (wavelength <= 430)) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')

%% RGBN5
name = 'RGBN5';
comment = 'Bayer pattern with one G replaced with narrow band';
n = ((wavelength >= 400) .* (wavelength <= 440)) .* max(n);
data = [r, g, b, n];
filterNames = {'r', 'g', 'b', 'n'};
filterOrder = [1, 2;...
               4, 3];
save(name,'comment','data','filterNames','filterOrder','wavelength')
