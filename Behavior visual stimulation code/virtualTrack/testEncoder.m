function testEncoder(type)


if nargin < 1 || isempty(type)
    type = 1;
end

% --- Setup analog input
ai = aiSetup();

% Distance values
sdef = screenDefs;
pixels_per_cm = sdef.width/sdef.width_inches/2.54;  % Convert inches to cm
cm_per_volt = pi*6*2.54/1;   % disk circumference*conversion/encoder voltage range
update_interval = 1/40;

% --- Set up keys
KbName('UnifyKeyNames')

% Figure
hfig = figure;
set(hfig,'Position',[198 510 1250 448]);
hax = axes('Parent',hfig);
defaultAxes(hax);
hl = line('Parent',gca);
drawnow
WaitSecs(0.05);

start(ai)
p = 1;
dd = [];

switch type
    case 1
        while ~KbCheck
            WaitSecs(2);
            % Get data from daq engine
            n = 0;
            while n == 0
                n = get(ai,'SamplesAvailable');
            end
            d = getdata(ai,n);
            d = d(:,1);  %  Chn0/Ind1 is absolute position encoder
            set(hl,'XData',1:length(d),'YData',d);
            drawnow
            WaitSecs(0.05);
        end
        
    case 2
        gain = 1;
        while ~KbCheck
            WaitSecs(update_interval);
            % Get data from daq engine
            n = 0;
            while n == 0
                n = get(ai,'SamplesAvailable');
            end
            d = getdata(ai,n);
            d = d(:,1);  %  Chn0/Ind1 is absolute position encoder
            d = diff(d);
            d(abs(d) > 0.3) = NaN;
            d = nansum(d);
            d = d*cm_per_volt*pixels_per_cm*gain;
            dd(end+1) = d;
            p(end+1) = p(end)-d;
            
        end
end

stop(ai);
delete(ai);

if type == 2
    figure; hist(dd,100)
    figure; hist(p,100);
    putvar(dd)
    putvar(p);
end


function ai = aiSetup()

daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    ai = analoginput('nidaq','Dev1');
    set(ai,'SampleRate',1000,'TriggerType','Immediate','InputType','SingleEnded');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    ai = analoginput('mcc',0);
    set(ai,'SampleRate',1000,'TriggerType','Immediate');
else
    error('No daq device installed')
end
ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
set(ch(1),'InputRange',[-10 10]);
set(ch(1),'SensorRange',[0 5]);
set(ch(1),'UnitsRange',[0 1]);
set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire
