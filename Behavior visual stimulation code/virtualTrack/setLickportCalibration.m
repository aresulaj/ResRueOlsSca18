function lick_cal = setLickportCalibration(lick_cal)
%
%
%
%
%

% Created: SRO - 6/12/12




% h.fig = portraitFigSetup;
h.fig = figure;

%addSaveFigTool(h.fig);
h.ax = axes('Parent',h.fig,'Position',[ 0.2575    0.5620    0.4438    0.3500]);
axis square;
h.data = line('XData',lick_cal.open_time,'YData',lick_cal.volume,...
    'LineStyle','none','Marker','o');
defaultAxes(h.ax);
xlabel('Open time (s)'); ylabel('Volume (uL)');
title(['Lickport calibration: ' lick_cal.rig]);


% Make fittype object
x = lick_cal.open_time;
y = lick_cal.volume;
f = fittype('a*x+b');
options = fitoptions(f);
set(options,'StartPoint',[200; 1]);

% Make fit
[cfun gof] = fit(x,y,f,options);

% Get values from fit
coeffval = coeffvalues(cfun);
lick_cal.m = coeffval(1);
lick_cal.b = coeffval(2);

xx = linspace(0,max(lick_cal.open_time)*1.1,10);
yy = feval(cfun,xx);
h.fit = line('XData',xx,'YData',yy);
str = [lick_cal.rig ': ' 'y = ' num2str(lick_cal.m,3) '*x+' num2str(lick_cal.b,2)];
title(str,'Interpreter','none');




