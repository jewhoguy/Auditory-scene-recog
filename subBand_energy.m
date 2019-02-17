function x = subBand_energy(y)
% Input x, one hamming/hanning window sample
% Output y, sub-band energy vector
N = 1024; %number of DFT Bins
N2 = N/2; %"L/2"
fftx = fft(y,N);
f = abs(fftx(1:N2));

% Jos näytteenottotaajuus 8kHz
%Sub-bandien ranget:[[0-0.5],[0.5-1],[1-2],[2-4]]kHz
b1 = (1:(N2/8));
b2 = ((N2/8)+1):(N2/4);
b3 = ((N2/4)+1):(N2/2);
b4 = (N2/2+1):(N2);
total = sum(f.^2);
% Sub-band energiat
x(1,1) = sum(f(b1).^2)/total;
x(2,1) = sum(f(b2).^2)/total;
x(3,1) = sum(f(b3).^2)/total;
x(4,1) = sum(f(b4).^2)/total;