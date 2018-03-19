function run = makeTrkTextures(run)
%
%
%
%
%

% Created: SRO - 6/8/12


% Close previous textures
if isfield(run,'tx')
    Screen('Close',run.tx);
%         disp('Previous textures closed')
end

% Set trk struct for this trial
trk = run.trial(run.trial_number).trk;

% Make track matrix for this trial
trk_m = makeTrkMat(trk);
% trk_m = double(trk_m);  % PTB-3 requires double

% Make textures tiling entire track
for i = 1:trk.number_tiles
    start_pt = (i-1)*trk.tile_width+1;
    end_pt = start_pt+trk.tile_width-1;
    run.tx(i) = Screen('MakeTexture',run.w(1),double(trk_m(:,start_pt:end_pt)));
 end

% Make position matrix
p = 1:size(trk_m,2);
p(2,:) = floor(p(1,:)/trk.tile_width)+1;
p(3,:) = mod(p(2,:),trk.number_tiles)+1;
p(4,:) = mod(p(2,:)+1,trk.number_tiles)+1;
for i = 1:length(trk.obj)
    tmp = all([p(1,:) >= trk.obj(i).panel_left; p(1,:) <= trk.obj(i).panel_right]);
    p(5,tmp) = i;
end
tmp = p(5,:);
tmp(tmp==0) = max(tmp);
p(5,:) = tmp;
run.p_mat = p;



