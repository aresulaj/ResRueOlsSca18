function daqTrkTimerFcn(obj, event, hDataViewer)
%
%
%
%
%

% Created: SRO - 6/11/12


% Get all plot vectors (stored in the struct, dv)
dv = dvCallbackHelper(hDataViewer);

dv.MaxPoints = 20000;
dv.Fs = obj.SampleRate;
Fs = dv.Fs;

% Get data
% WB - 8/6/10 - if n > 1 triggers elapsed before this callback ran, we must
% loop through them (fixing our TriggerNum index each time) since online analysis functions (e.g. PSTH) expect to
% be run every trigger

TriggerNum = obj.TriggersExecuted;
if(obj.SamplesAvailable > obj.SamplesPerTrigger)
    triggersMissed = ceil(obj.SamplesAvailable / obj.SamplesPerTrigger) - 1;
    TriggerNum = TriggerNum - triggersMissed;
end

if ~(obj.SamplesAvailable == 0)
    sizeData = min(obj.SamplesPerTrigger, obj.SamplesAvailable);
    data = getdata(obj,sizeData);
    
    % Convert raw input voltage to real signal in uV
    tmp = obj.UserData;
    data = rawInput2uV(data,tmp.gain);
    
    % Process and display data
    spiketimes = dvProcessDisplay(dv,data,hDataViewer); % spiketimes is a cell array    
    
    % Now update GUI
    drawnow
    
    % --- End online analysis --- %
    
    % Update GUI objects
    hTriggerNum = getappdata(hDataViewer,'hTriggerNum');
    TriggerNum = obj.TriggersExecuted-1;
    set(hTriggerNum,'String',TriggerNum);
    drawnow
end
