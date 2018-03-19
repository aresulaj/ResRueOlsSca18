function mouse = vTrackSession(mouse,track_table,run_file)
%
%
%
%
%

% SRO - 6/5/12




flds = {'date','track_table','run_file'};

if ~isfield(mouse,'vtrack')
    mouse.vtrack = [];
end

if ~isfield(mouse.vtrack,'session');
    mouse.vtrack.session = [];
end

sessionInd = length(mouse.vtrack.session)+1;
for i = 1:length(flds)
    switch flds{i}
        
        case 'date'
            mouse.vtrack.session(sessionInd).(flds{i}) = datestr(now,0);
            
        case 'track_table'
            mouse.vtrack.session(sessionInd).(flds{i}) = track_table;
            
        case 'run_file'
            run_file = checkIfFileExists(run_file);
            mouse.vtrack.session(sessionInd).(flds{i}) = run_file;
            
        otherwise
            mouse.vtrack.session(sessionInd).(flds{i}) = '';
            
    end
end

mouse.vtrack.session_ind = sessionInd;