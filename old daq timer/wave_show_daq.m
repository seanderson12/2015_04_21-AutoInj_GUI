function [capacitor_o]=wave_show(hwave,hdevice,Cbox,capacitor_o,df)



[data, time, c] =startForeground(hdevice);

%% Data Recieve
Fs = hdevice.Rate;                     % Sampling frequency
T  = 1/Fs;                       % Sample time (dt between 2 samples)
L  = hdevice.Rate*hdevice.DurationInSeconds; % Length of signal
%t = (0:L-1)*T;                  % Time vector
y_origin_1 = data(:,1); %/10;        % Voltage
y_origin_2 = data(:,2)*100*(10^(-10));% Current (A)

%% FFT (Fast Fourier Transfer)
%remove bias
y1 = y_origin_1 - mean(y_origin_1);
y2 = y_origin_2 - mean(y_origin_2);
%number of points
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
%Fast Fourier Transfer
Y1 = fft(y1,NFFT);
Y2 = fft(y2,NFFT);

%% Spectrums
%NFFT/2+1 is theumber of unique points
Num_points=NFFT/2+1;
f = Fs/2*linspace(0,1,Num_points);

 %% find the maximum frequency
 [mag_y1, idx_y1]= max(abs(Y1));
 [mag_y2, idx_y2]= max(abs(Y2));
%  idx_y1=4;
%  idx_y2=4;
 mag_vol=abs(Y1(idx_y1))/(NFFT/64);
 mag_cur=abs(Y2(idx_y2))/(NFFT/64);
 %amplitude ratio
 mag_ratio=mag_vol/mag_cur;
 
 %phase difference
 phase_y1= angle (Y1(idx_y1));
 phase_y2= angle (Y2(idx_y2));
 phase_lag= phase_y1-phase_y2;
 phase_lag_corrected= 370/180*pi-mod(phase_lag,2*pi);
 
 %% add filter here
 try    
     phase_lag_processed=phase_lag_processed+0.1*(phase_lag_corrected-phase_lag_processed);
 catch
     phase_lag_processed=phase_lag_corrected;
 end
 
 %%
 C=1/(2*pi*mag_ratio*sin(phase_lag_corrected)*f(floor((idx_y1+idx_y2)/2)) );%negative

 
% fprintf('\n C is : %.2E \n \n',C)
 fprintf('channel 0: feq: %.2E Phase : %.2E \n',f(idx_y1),angle (Y1(idx_y1)))
 fprintf('channel 1: feq: %.2E Phase : %.2E \n',f(idx_y2),angle (Y2(idx_y2)))
% fprintf('V feq: %.2E rad ; I feq: %.2E rad ; feq diff : %.1f deg \n',phase_y1,phase_y2, 370-rad2deg(phase_lag))
% fprintf('Impedence: %.2E + %.2E \n', mag_ratio*cos(370/180*pi-phase_lag),mag_ratio*sin(370/180*pi-phase_lag))
% fprintf('Voltage magnitude: %.2E V \n', mag_vol/2)
% fprintf('Current magnitude: %.2E A \n', mag_cur/2)


%% update and plot capacitor
% number of points to save
Num=40;


if length(capacitor_o)>=Num
    capacitor=filter(df,capacitor_o);%+mean(capacitor_o);
else
    capacitor=capacitor_o;
end


if length(capacitor_o)<=Num
    capacitor_o=[capacitor_o C];
else
    capacitor_o=[capacitor_o(2:end) C];
end



 set(0, 'CurrentFigure', hwave);
 try
     plot(1:length(capacitor_o),capacitor_o)%[capacitor(1:length(capacitor)-1),C])
 catch
 end
 set(Cbox,'String',['C is: ', num2str(C)]);
end