function trk = makeTrkObj(trk,f_obj_trk)
%
%
%
%
%

% Created: SRO - 6/8/12

if nargin < 2 || isempty(f_obj_trk)
    f_obj_trk = 0;
end

leftIndex = 1;


sdef = screenDefs;
lum_max=sdef.a*(255^sdef.b);
lum_b= 100; %lum_max/2;%lum_b=10; %

background_pix_val=floor(exp(log(lum_b/sdef.a)/sdef.b));


if ~isfield(trk,'forage') || isempty(trk.forage)
    trk.forage = 0;
end
obj = [];
for i = 1:trk.number_of_objects
    if ~f_obj_trk
        switch trk.forage
            case 0
                obj(i).type = trk.code.params(i,2);
                obj(i).contrast = trk.code.params(i,1);
                obj(i).angle = 0;
                obj(i).pix_val = obj(i).contrast;    % Change this
                obj(i).target = trk.targets(i);
                obj(i).code = findObjCode(trk,obj(i));
            case 1 % ***Typical case for current version of vTrack***
                obj = makeForageObj(trk,obj,i);
        end
    elseif f_obj_trk
        fld = getTrkCodeFields(trk);
        for n = 1:length(fld)
            obj(i).(fld{n}) = trk.code.params(i,n);
        end
        obj(i).pix_val = 255*obj(i).contrast;    % Change this
        obj(i).code = i;
        obj(i).params = [];
        obj(i) = setObjParams(obj(i),trk,trk.code.params(i,:));
        
        % ** temporary ** Alter target parameter order to match code.order
        trk.targets = trk.targets(1,:);
        target_params = trk.targets(end:-1:1);
        if all(obj(i).params == target_params)
            obj(i).target = 1;
        else
            obj(i).target = 0;
        end
    end
    
    obj(i).size = trk.object_size;
    obj(i).spacing = trk.object_spacing;
    obj(i).target_zone_width = trk.target_zone_width;
    obj(i).background_pix_val = background_pix_val; 
    
    tmp_rect = CenterRect([0 0 obj(i).size obj(i).size],trk.screen_rect);
    if ~isempty(trk.vertical_offset)
        tmp_rect = tmp_rect + [0 trk.vertical_offset 0 trk.vertical_offset];
    end
    obj(i).top = tmp_rect(2);
    obj(i).bottom = tmp_rect(4);
    obj(i).buffer_left = obj(i).spacing;
    obj(i).buffer_right = obj(i).spacing;
    
    obj(i).panel_left = leftIndex;
    obj(i).panel_right = leftIndex + obj(i).buffer_left + obj(i).size + obj(i).buffer_right;
    objLeft = leftIndex+obj(i).buffer_left;
    objMat = [objLeft obj(i).top objLeft+obj(i).size obj(i).bottom];
    obj(i).rect = objMat;
    leftIndex = objMat(3)+obj(i).buffer_right;
    obj(i).screen_width = trk.screen_width_pix;
    obj(i).center = (obj(i).rect(3)-obj(i).rect(1))/2+obj(i).rect(1);
    obj(i).target_zone = [obj(i).center+obj(i).target_zone_width(1) obj(i).center-obj(i).target_zone_width(2)];
    
    obj(i).reward_available = 1;
    
    trk.obj_centers(i) = obj(i).center;
    trk.obj_list(i) = obj(i).code;
    
    % Add LED contingency
    % Determine whether LED will be paired with object
    
        obj(i).led_on = double(rand(1) < trk.led_probability); % Random LED
    
    %     obj(i).led_on = double(~mod(i,2)); % LED is on for even trials
%     if double(~mod(i,3))
%         obj(i).led_on = [1 0];
%     elseif double(~mod(i+1,3))
%         obj(i).led_on(2) = [0 1];
%     else
%         obj(i).led_on = [0 0];
%     end
    %     obj(i).led_on = double(~mod(i,3)); % every 3rd trial
    %     obj(i).led_on = double(~mod(i+1,3)); % every 3rd trial
    %         obj(i).led_on = double(~mod(i,4)); % every 4rd trial
    %                 obj(i).led_on = double(~mod(i,5)); % every 4rd trial
    
    obj(i).led_zone = obj(i).center + [obj(i).spacing -obj(i).spacing];
    
end

trk.obj = obj;


function obj = makeForageObj(trk,obj,i)
global person_ind;

flds = {'target','contrast','type','code','angle','params'};
for n = 1:length(flds)
    if ~isfield(obj,flds{n})
        obj.(flds{n}) = [];
    end
end

if ~isfield(trk,'object_angle') || isempty(trk.object_angle)
    trk.object_angle = 0;
end

% ** temporary ** Alter target parameter order to match code.order
target_params = trk.targets(end:-1:1);
target_params(1)=trk.code.params(1,1); %AR added this on 7/13/15

% KLUUUUUGGGEE!
if isfield(trk,'photo') && ~isempty(trk.photo)
    t_num = double(rand(1) < 0.5) + 1;
    target_params = trk.targets(t_num,:);
    target_params = target_params(end:-1:1);
    
else
    
end

% Determine whether object will be target
obj(i).target = double(rand(1) < trk.target_probability);

%AR added this
training_wheels=0;
if training_wheels
    
    if i>=3
        if  (all(([obj(i).target obj(i-1).target obj(i-2).target]==0))...
                || all([obj(i).target obj(i-1).target obj(i-2).target]))
            
            obj(i).target=obj(i).target==0;
            
        end
        
        
    end
end



if obj(i).target
    
    code_val = randi(size(trk.code.params,1));
    target_params(2)= trk.code.params(code_val,2);  %set contrast
    obj(i) = setObjParams(obj(i),trk,target_params);
    obj(i).code = findMatchingRow(trk.code.params,target_params);
  
else
    if trk.randomize
        % Draw random object from list. If target discard and repeat
        tmp = target_params;
        
        while (tmp(1) == target_params(1))
            code_val = randi(size(trk.code.params,1));
            tmp = trk.code.params(code_val,:) ;
        end
    elseif ~trk.randomize
        if isempty(person_ind)
            person_ind = 3;
        else
            person_ind = mod(person_ind,size(trk.code.params,1))+1;
        end
        if person_ind < 3
            person_ind = 3;
        end
        
        code_val = person_ind;
        tmp = trk.code.params(code_val,:) ;
        
    end
    
    obj(i).code = code_val;
    obj(i) = setObjParams(obj(i),trk,tmp);
end

obj(i).pix_val = obj(i).contrast;


function obj = setObjParams(obj,trk,code)

fld = trk.code.order;

for i = 1:length(fld)
    tmp = strfind(fld{i},'_');
    fld{i} = fld{i}(tmp+1:end);
end

for i = 1:length(fld)
    obj.(fld{i}) = code(i);
end

obj.params = code;
if ~isfield(obj,'angle') || isempty(obj.angle)
    obj.angle = 0;
end

a = 1;
