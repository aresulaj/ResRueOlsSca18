function calibrateLickPort(openTime,repetitions)
%
%
%

% Created: SRO - 4/12

if nargin < 1 || isempty(openTime)
    sdef = screenDefs;
    openTime = sdef.solenoidOpenTime;
end

if nargin < 2 || isempty(repetitions)
   repetitions = 50;
end

if nargin < 3 || isempty(iti)
   %iti = 0.1;
   iti = 0.5;
end

daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    dio = digitalio('nidaq','Dev3');
    hwlines = addline(dio,0,'out');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    dio = digitalio('mcc','0');
    hwlines = addline(dio,0,'out');
end

for i = 1:repetitions
    putvalue(dio,1);
    WaitSecs(openTime);
    putvalue(dio,0);
    WaitSecs(iti);
end

disp(['open time = ' num2str(openTime)])
disp(['repetitions = ' num2str(repetitions)])


delete(dio)