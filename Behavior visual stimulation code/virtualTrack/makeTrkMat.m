function trk_m = makeTrkMat(trk)
%
%
%
%
%
%

% Created: SRO - 6/8/12




% Define obj struct
obj = trk.obj;

% Allocate track matrix
trk_m = single(ones(trk.height,trk.length));

% Make track background
trk_m = trk_m*trk.background_pix_value;

% Add objects to track
for i = 1:length(obj)
    trk_m = addObjectToTrack(trk_m,obj(i));
end

% trk_m = single(trk_m);








