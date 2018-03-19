function daqTrkTriggerFcn(obj,event,hDataViewer)
%
%
%
%
%

% Created: SRO - 6/11/12
% Modified AR - 10/2/14

% Get information about AIOBJ (aka obj)
Trigger = obj.TriggersExecuted;
TriggerRepeat = obj.TriggerRepeat;
LoggingMode = obj.LoggingMode;
LogFileName = obj.LogFileName;
SamplesPerTrigger = obj.SamplesPerTrigger;

% Print SaveName to command line
if strcmp(LoggingMode,'Disk&Memory') && Trigger == 1
    disp(['Save daq file: ' LogFileName(1:end-4)]);
end

% % Get stimulus information
% global DIOBJ
% % Reads digital ports and SAVES the result
% stimconds = readDigitalPorts(DIOBJ,Trigger,TriggerRepeat,LoggingMode,LogFileName);
% setappdata(hDataViewer, 'StimCondData', stimconds);
% 
% disp('stimulus condition = ')
% disp(stimconds(2,Trigger))
% 
% Get run file name and trial number
getRunFileName(Trigger,LoggingMode,LogFileName);


% --- Subfunctions --- %
 function getRunFileName(Trigger,LoggingMode,LogFileName)
% persistent daqRun
% 
% % Get name of RUN struct, trial number, and start time of trial
if strcmp(LoggingMode,'Disk&Memory')
    
    global UDP_OBJ_STIM_PC % UDP object connecting to stimulus PC
    try
        tmp = fscanf(UDP_OBJ_STIM_PC); % NOTE: timeout is set when declaring UDP object
        if  ~isempty(tmp)
            tmp = strread(tmp,'%s','delimiter','*'); % Stimulus filename, condition name, and number
        end
    catch
        tmp{1:3} = [];
    end
    if ~isempty(tmp) && (length(tmp)==3)
        daqRun(Trigger).run_file = tmp{1};
        daqRun(Trigger).trial_number = tmp{2};
        daqRun(Trigger).trial_start_time = tmp{3};
        
        fname = LogFileName(1:end-4);
        save([fname '_daqRun'],'daqRun');
        
        disp(['Track trial number: ' daqRun(Trigger).trial_number]);
        disp(['Run file: ' daqRun(Trigger).run_file]);
        disp(['Trial start time: ' daqRun(Trigger).trial_start_time]);
        
    else
        disp('Failed to get info from vTrack PC')
    end
    
end

