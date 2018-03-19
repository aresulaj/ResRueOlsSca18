function expt = makeExptSRO(ExptTable,overwrite)
% expt = makeExptSRO(ExptTable)
%
% INPUT
%   ExptTable(optional): Table with details of experiment. This table is
%   used to fill in specific fields in the expt struct.
%
% OUTPUT
%   expt: Experiment struct

% Created:  3/25/10 - SRO
% Modified: 4/9/10 - SRO
% Modified: 5/22/10 - SRO
% Modified: 7/15/10 - SRO
% Modified: 10/2/14 - AR

if nargin < 2 || isempty(overwrite)
    overwrite = 0;
end

% Set rig defaults
rigdef = RigDefs;

% If experiment table is not supplied then use dialog to get one
if nargin < 1 || isempty(ExptTable)
    % Load experiment table
    [FileName,PathName] = uigetfile([rigdef.Dir.Data '*_ExptTable*']);
    if FileName ~= 0
        ExptTable = loadvar(fullfile(PathName,FileName));
    else
        return
    end
end

% Define fields
expt.name = [];         % Experiment name
expt.fname = [];        % File name
expt.info = [];         % Details about mouse and experiment
expt.probe = [];        % Probe configuration, channel order, etc.
expt.files = [];        % Information about each raw data file
expt.stimulus = [];     % Stimulus paramters for each file
expt.sweeps = [];       % Information about every sweep in experiment
expt.sort = [];         % Spike sorting
expt.analysis = [];     % Info for running analysis and storing results
expt.unit = [];         % Completed units

% Set experiment name
expt.name = getFromExptTable(ExptTable,'Experiment name');

% Set experiment file name
expt.fname = [rigdef.Dir.Expt expt.name '_expt'];

% % *** TEMP *** if expt is V1 of V1/LGN then make LED files
% makeV1LEDFiles(expt.name);

% Add .info struct
expt = addInfo(expt,ExptTable);

% Add .probe struct
expt = addProbe(expt,ExptTable);

% Add .files struct
expt = addFiles(expt);

% Add .stimulus struct or add .run struct
expt_type = getFromExptTable(ExptTable,'Experiment type');
%expt_type = 'vTrack';
if isempty(expt_type)
    expt = addStimParams(expt);
    expt.expt_type = '32 Channel';
elseif strcmp(expt_type,'vTrack')
    expt.expt_type = 'vTrack';
end

% Add .sweeps or .runSweeps struct
if ~isempty(expt.files.names)
    if ~strcmp(expt.expt_type,'vTrack')
        % Add .files.stimType
        expt = addStimType(expt);
        expt = addSweeps(expt);
        % Add stimulus conditions (expt.sweeps.stimcond)
        expt = addStimCond(expt);
        % Add LED conditions to sweeps struct (expt.sweeps.led)
        expt = addLEDCond(expt);
        % Add time to sweeps
        expt.sweeps = addTimeToSweeps(expt.sweeps,expt);
        % Add .analysis struct
        expt = addAnalysisSRO(expt);    % This function is in flux
    %elseif strcmp(expt_type,'vTrack')
        expt = addRunSweepsToExpt(expt);
        
%         %AR added this-----------------
%         expt = addSweeps(expt);
%         % Add stimulus conditions (expt.sweeps.stimcond)
%         expt = addStimCond(expt);
%         % Add LED conditions to sweeps struct (expt.sweeps.led)
%         expt = addLEDCond(expt);
%         % Add time to sweeps
%         expt.sweeps = addTimeToSweeps(expt.sweeps,expt);
    end
end

% Add .sort struct
expt = addSort(expt);
expt.sort.trode(8).channels=[5 4 3 2]
% Set file name for saving
FileName = [rigdef.Dir.Expt expt.name '_expt'];

% Prevent overwriting existing expt by accident
if isempty(dir([FileName '.*']))
    choice = 'Yes';
elseif overwrite
    choice = 'Yes';
else
    [f p] = getFilename(FileName);
    disp('Expt already exists:')
    disp([p f])
    qstring = 'Do you want to overwrite existing expt file?'; pause(0.05)
    choice = questdlg(qstring,'Overwrite?','Yes','No','No');
end

% Save expt struct
switch choice
    case 'Yes'
        save(FileName,'expt');
        % Assign in base workspace
        assignin('base','expt',expt);
    case {'No',''}
        disp('Expt was not saved')
end



% --- Subfunctions --- %

function expt = addStimType(expt)

for i = 1:length(expt.files.names)
    % Get stimType from .stimulus struct
    stimulus = expt.stimulus(i);
    if isfield(stimulus.params,'stimType')
        expt.files.stimType{i} = stimulus.params.stimType;
    elseif isfield(stimulus.params,'StimulusName')
        temp = stimulus.params.StimulusName;
        if strcmp(temp,'Drift Gratings')
            expt.files.stimType{i} = 'Drifting gratings';
        end
    end
end




