function track_table = load_track(mouse)
%
%
%
%
%

% Created: SRO - 6/5/12


def_track = 1;

% Find most recent virtual track session
if isfield(mouse,'vtrack')
    
    if isfield(mouse.vtrack,'session')
        s_ind = length(mouse.vtrack.session);
        if s_ind ~= 0
            track_table = mouse.vtrack.session(s_ind).track_table;
            if ~isempty(track_table)
                def_track = 0;
            end
        end
    end
    
end

if def_track
    rdef = RigDefs;
    
    % Set track table
    tmp = loadvar([rdef.Dir.vTrackSettings 'default_track']);
    track_table = tmp;
    
    disp('*** LOADED DEFAULT TRACK ***')
end