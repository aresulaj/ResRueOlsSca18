function mouse = makeMouseTable_vTrack(mouse)
%
%
%
%


%




if ~isfield(mouse,'vtrack')
    mouse.vtrack = [];
end
if ~isfield(mouse.vtrack,'mouse_table')
    mouse.vtrack.mouse_table = new_table(mouse);
    
end

a = 1;



function n_table = new_table(mouse)

flds = {'mouse_code','genotype','expression','age','sex','cage_code',...
    'behavior'};

ind = 0;
for i = 1:length(flds)
    if isfield(mouse,flds{i})
        ind = ind+1;
        tmp{ind,1} = flds{i};
        tmp{ind,2} = mouse.(flds{i});
    end
end

for i = length(flds)+1:100
    tmp{i,1} = '';
    tmp{i,2} = '';
end

n_table = tmp;