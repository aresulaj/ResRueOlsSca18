%%% Water port calibration. AR on June 14, 2013

%generate lick_cal.volume values - check 3 times for fluctuations
lick_cal.open_time=[0.0100 0.0200 0.0400 0.0600 0.0800 0.1000];
repetitions = 50;

for k=1:size(lick_cal.open_time,2)
    disp(lick_cal.open_time(k))
    calibrateLickPort(lick_cal.open_time(k),repetitions)
pause
end

% lick_cal.volume=[0.00381 0.00566 0.00924 0.01323 0.01831 0.02440];

% Fit line to data, and update lick_cal with slope and intercept
lick_cal = setLickportCalibration(lick_cal)

%save lick_cal.mat lick_cal
    