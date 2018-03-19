function trk = makeTrkStruct(trk_table,f_obj_trk)
%
%
%
%
%
%

% Created: SRO - 6/8/12


if nargin < 2 || isempty(f_obj_trk)
   f_obj_trk = 0; 
end

sdef = screenDefs;

table_flds = {'Track file','Objects','Target objects','Object contrast',...
    'Object size','Object spacing','Target zone width','Background luminance',...
    'Randomize objects','Forage','Target probability','Number of objects',...
    'Object angle','LED probability','LED zone','Vertical offset','Photo'};
flds = {'track_file','object_type','targets','object_contrast',...
    'object_size','object_spacing','target_zone_width','background_luminance',...
    'randomize','forage','target_probability','number_of_objects',...
    'object_angle','led_probability','led_zone','vertical_offset','photo'};


for i = 1:length(flds)
    trk.(flds{i}) = readTrkTable(trk_table,table_flds{i});
end

lum_max=sdef.a*(255^sdef.b);
lum_b= 100; %lum_max/2;
background_pix_val=floor(exp(log(lum_b/sdef.a)/sdef.b));

trk.background_pix_value = background_pix_val;

if ~isfield(trk,'number_of_objects') || isempty(trk.number_of_objects)
    trk.number_of_objects = length(trk.object_type{1});
end

trk.screen_width_pix = sdef.width;
trk.screen_height_pix = sdef.height;
trk.screen_cm_per_pix = 2.54*sdef.width_inches/sdef.width;
trk.screen_rect = [0 0 sdef.width sdef.height];

trk = makeObjCodeMat(trk);
if f_obj_trk
    trk.number_of_objects = size(trk.code.params,1);
end
trk = makeTrkObj(trk,f_obj_trk);

% Compute track length
tl = 0;
for i = 1:length(trk.obj)
    tl = tl+trk.obj(i).size+trk.obj(i).buffer_left+trk.obj(i).buffer_right;
end

% Adjust track length for display using equal sized tiles
number_tiles = ceil(tl/trk.screen_width_pix);
tile_width = ceil(tl/number_tiles);
tl = number_tiles*tile_width;
trk.tile_width = tile_width;
trk.number_tiles = number_tiles;
trk.length = tl;
trk.height = sdef.height;

% putvar(trk);


function val = readTrkTable(trk_table,fld)

switch fld
    case {'Objects','Object contrast','Object angle'}
        val = getFromTable(trk_table,fld);
        i_l = strfind(val,'{');
        i_r = strfind(val,'}');
        
        if ~isempty(i_l)
            for i = 1:length(i_l)
                tmp{i} = cell2mat(eval(val(i_l(i):i_r(i))));
            end
            val = tmp;
            
        else
            val = {str2num(val)};
        end
    otherwise
        val = str2num(getFromTable(trk_table,fld));
end

