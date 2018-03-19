function mouse = virtualTrackNew(table_track,mouse,save_run)
%
%
%
%

% Created: SRO - 3/31/12
% Modified: SRO - 5/23/12 - 6/8/12
% Modified: AR - 7/24/13 - Changed assessLED(run,obj)



if nargin < 1 || isempty(table_track)
    % Choose track struct
end

if nargin < 2 || isempty(mouse)
    % Choose mouse
    mouse.mouse_code = 'test';
end

if nargin < 3 || isempty(save_run)
    save_run = 1;
end


% --- Make 'run' and 'track' structs
run = makeRunStruct(table_track,mouse);
run.save_run = save_run;
run.session_start_time = datestr(now);

% --- Setup screen
sdef = screenDefs;
screenNum = sdef.screenNum;
workRes = NearestResolution(sdef.screenNum,sdef.width,sdef.height,sdef.frameRate);
Screen('Preference', 'VisualDebuglevel', 1);
Screen('Preference', 'SkipSyncTests', 2 );
Screen('Preference', 'Verbosity', 0);
SetResolution(screenNum,workRes);
a = sdef.a;
b = sdef.b;
white_luminance = 50;
black_luminance = 0;

% --- Initialize visual stimulation
clear mex
InitializeMatlabOpenGL;

% --- Setup analog input
ai = aiSetup();

% --- Setup analog output (LED, auditory stimulus, etc)
% ao = aoSetup();

% --- Setup digital output to lickport
run.lick_port = lickPortSetup();

% --- Setup digital output to LED
if run.use_led
    run.led = ledSetup(run);
end

% --- Define parallel port trigger
%run = parallelPortSetup(run); %kluuuge, disabled parallelport and sending TTL through dio  
if run.parallel_port_trigger && (~isfield(run,{'p_port'}))
    run.daqTrig=ephysTriggerSetup(run);
end

% --- If aquiring data
run = udpSetup(run);

% --- Set up keys
KbName('UnifyKeyNames')

% --- Session active flag
session_active = 1;

putvar(run);


try
    %HideCursor
    while session_active
        
        % Turn on dark background
        run = displayBlankTrack(run);  % default environment
        
        % Set tic times
        tic_iti_start = tic;
        run.tic_session_start = tic;
       
        % Start data acquisition from rotation encoder
        start(ai);
        
        session_active = keyCheck(session_active);
        
        % --- PRE-TRIAL BEGINS --- %
        while session_active && (run.trial_number-1 < run.number_of_trials)
            
            % Terminate session is reward limit has been reached
            if run.n_rewards >= run.reward_limit
                session_active = 0;
            end
            
            % --- Make Track
            run = makeTrkTextures(run);
            
            % Set solenoid open time
            run = computeSolenoidOpenTime(run);
            
            % --- Set trial specific parameters
            trial_duration = run.trial(run.trial_number).trial_duration;
            iti = run.trial(run.trial_number).iti;
            
            % --- Wait until inter-trial interval has elapsed
            while session_active && toc(tic_iti_start) < iti
                session_active = keyCheck(session_active);
                WaitSecs(0.05);
            end
            
            % Trial "start time"
            run.trial(run.trial_number).start_time = toc(run.tic_session_start);
            
            
            %--- Display gray screen
            Screen('FillRect',run.w(1),run.trial(run.trial_number).background_pix_val);
            Screen('Flip',run.w(1));
            
            % Gray for t seconds before cue
            WaitSecs(run.wait_time_after_trigger);
            
            %reset stimulus freeze state
            run.freeze_state=0;
            
            
            %--- Display Cue --- %
            
            % Clear data from ai device
            clearDaq(ai,run);
            
            %reset time for photodiode and led trigger 
            run.tled=nan;
            run.diode=nan;
            run.pdiode=[];
            run.pled=[];
            run.pt=[];

            
            % Keyboard check
            session_active = keyCheck(session_active);
            
            % --- TRIAL BEGINS --- %
            run.tic_trial_start = tic;
            run.tic_hold_time = tic;
            
            disp(['trials = ' num2str(run.trial_number)])
            run.update_index = 1;
            
            displayTrack(run);
            
            while session_active && toc(run.tic_trial_start) < trial_duration
                
                run.tic_update = tic;
                
                % Compute new position and distance travelled
                run = computePosition(ai,run);
                
                % Send pulse for syncing daq
                if run.parallel_port_trigger 
                    run = syncDaqPulse(run); %AR
                end
                
                % Display track
                displayTrack(run);
                
                % Store time and position
                run.position_data(run.update_index,run.trial_number,1) = toc(run.tic_trial_start);
                run.position_data(run.update_index,run.trial_number,2) = run.p;
                run.position_data_raw(run.update_index,run.trial_number,1) = run.p_raw;
                               
                %Store led trigger and photodiode data
                run.diode_data(1:run.n,run.update_index,1) = run.d_data;
                run.diode_data(1:run.n,run.update_index,2) = run.l_data;
                run.diode_data(1:run.n,run.update_index,3)=run.t;
                run.diode_data(1:run.n,run.update_index,4)=run.trig;
                
                %Store led trigger and photodiode data - AR added this
                c_obj_ind = run.p_mat(5,run.p);
                if ~any(run.trial(run.trial_number).tled==run.tled) && isnan(run.trial(run.trial_number).tled(c_obj_ind))
                   run.trial(run.trial_number).tled(c_obj_ind)= run.tled;
                end

                if ~any(run.trial(run.trial_number).tdiode==run.diode) && isnan(run.trial(run.trial_number).tdiode(c_obj_ind))
                   run.trial(run.trial_number).tdiode(c_obj_ind)= run.diode;
                end

               
                % Update track refresh index
                run.update_index = run.update_index + 1;
                
                % Compute and execute reward and output contingencies
                run = computeContingencies(run,ai);
                run.tic_hold_time = tic;
                %                  toc(run.tic_update)
                
                % Wait for update interval
                waitForUpdateInterval(run);
                
                % Keyboard check
                session_active = keyCheck(session_active);
                
            end  % Trial ends
           
            % --- FINISH TRIAL --- %
            run = displayBlankTrack(run);
            if run.use_led
                run.led_state = [0 0];
                putvalue(run.led(1).parentuddobj,0,2); 
                putvalue(run.led(2).parentuddobj,0,2); 

            end
            
            % Set starting position for next trial
            run.p = 1;
            run.p_raw=1;
          
            % Begin inter-trial interval
            tic_iti_start = tic;
            
            %set up eyetracker udp communication %AR
            if run.eyetracker_flag && (run.trial_number < run.number_of_trials)
                %% Writing UDP
                pnet(udp,'write','startOneTrial');
                pnet(udp,'writepacket');
                display('Sent to eyetracker: startOneTrial');
            end

            % Save data from last trial
            saveRunData(run,mouse);
            
            % Save diode data %AR
            diode_data=run.diode_data;
            if run.save_diode==1
                [junk fname] = fileparts(mouse.vtrack.session(mouse.vtrack.session_ind).run_file);
                f_name=sprintf('%s%s%d',fname,'diode',run.trial_number);
                save(f_name, 'diode_data')
            end
            % Reset diode matrix
            run.diode_data=NaN(70,1000,4);
            run.diode_data=single(run.diode_data);
    
            % Update trial number
            run.trial_number = run.trial_number + 1;
            
            % Keyboard check
            session_active = keyCheck(session_active);
            
        end  % Session ends
        
        session_active = 0;
        
    end  % Abort
    
catch
    % --- End of session --- %
    mouse = endTrack(ai,run,mouse,psychlasterror);
end
% --- End of session --- %
mouse = endTrack(ai,run,mouse,[]);


% --- SUBFUNCTIONS --- %
function ai = aiSetup()
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    ai = analoginput('nidaq','Dev3');
    set(ai,'SampleRate',10000,'TriggerType','Immediate','InputType','Differential');
    %set(ai,'SampleRate',1000,'TriggerType','Immediate','InputType','SingleEnded');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    ai = analoginput('mcc',0);
    set(ai,'SampleRate',1000,'TriggerType','Immediate');
else
    error('No daq device installed')
end
ch = addchannel(ai,[0 1 2 3]);  % chn0 = position encoder; chn1 = lickometer
set(ch(1),'InputRange',[-10 10]);
set(ch(1),'SensorRange',[0 5]);
set(ch(1),'UnitsRange',[0 1]);
set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire

function lick_port = lickPortSetup()
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    dio = digitalio('nidaq','Dev3');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    dio = digitalio('mcc','0');
end
hwlines = addline(dio,0,'out','lickLine');
parent = get(dio.lickLine, 'Parent');
parentuddobj = daqgetfield(parent,'uddobject');
lick_port.parentuddobj = parentuddobj;
lick_port.dio = dio;

function led = ledSetup(run)
hwlines = addline(run.lick_port.dio,1,'out','ledLine');
parent = get(run.lick_port.dio.ledLine, 'Parent');
parentuddobj = daqgetfield(parent,'uddobject');
led.parentuddobj = parentuddobj;
led.dio = run.lick_port.dio;

hwlines(2) = addline(run.lick_port.dio,2,'out','ledLine');
led(2).parentuddobj = parentuddobj;
led(2).dio = run.lick_port.dio;

function daqTrig=ephysTriggerSetup(run)
hwlines = addline(run.lick_port.dio,3,'out','ephysLine');
parent = get(run.lick_port.dio.ephysLine, 'Parent');
parentuddobj = daqgetfield(parent,'uddobject');
daqTrig.parentuddobj = parentuddobj;
daqTrig.dio = run.lick_port.dio;




function run = parallelPortSetup(run)
if run.parallel_port_trigger
    p_port = digitalio('parallel','LPT1');
    hwline = addline(p_port,0:1,2,'out','triggerLine');    % pins 1,14
    addline(p_port,0:7,'out');     % pins 2-9 %AR
    
    parent = get(p_port.triggerLine, 'Parent');
    parentuddobj = daqgetfield(parent{1},'uddobject');
    triggerLine = 1:2;
    condLine = 3:10;
    bitOn = 0;
    bitOff = 1;
    putvalue(parentuddobj,[bitOff bitOff],triggerLine);
    putvalue(parentuddobj,0,condLine);
    
    run.p_port.dio = p_port;
    run.p_port.parentuddobj = parentuddobj;
    run.p_port.triggerLine = triggerLine;
    run.p_port.condLine = condLine;
    run.p_port.bitOn = 0;
    run.p_port.bitOff = 1;
end

function run = displayBlankTrack(run)
if ~isfield(run,'w')
    Screen('Preference', 'VisualDebuglevel', 1);
    Screen('Preference', 'SkipSyncTests', 2 );
    Screen('Preference', 'Verbosity', 0);
    [run.w(1),wRect] = Screen(run.sdef.screenNum,'OpenWindow',run.trial(run.trial_number).background_pix_val);
    Screen('Preference', 'VisualDebuglevel', 1);
    Screen('Preference', 'SkipSyncTests', 2 );
    Screen('Preference', 'Verbosity', 0);
    priorityLevel = MaxPriority(run.w(1));
    Priority(priorityLevel);
end

Screen('FillRect',run.w(1),run.trial(run.trial_number).background_pix_val);
Screen('Flip',run.w(1));

function displayTrack(run)
p_mat = run.p_mat;
p = mod(run.p-run.display_offset,run.trial(run.trial_number).trk.length);
p(p==0) = 1;
tile_ind = p_mat(2:4,p);
tmp = run.trial(run.trial_number).trk;
c = computeCoordinates(p,p_mat,run.sdef.width,tmp.tile_width,tmp.height);
for i = 1:3
    Screen('DrawTexture',run.w(1),run.tx(tile_ind(i)),c{i,1},c{i,2});
end
Screen('Flip',run.w(1));

function run = computePosition(ai,run)

% Set threshold discontinuity
discontinuity_thresh = 0.1;

% Noise threshold
noise_threshold = 3;

% Gain
gain = run.trial(run.trial_number).track_gain;

% Get data from daq engine
n = 0;
while n == 0
    n = get(ai,'SamplesAvailable');
end
[d,t] = getdata(ai,n);
run.d_data=d(:,2);
run.l_data=d(:,3);
run.trig=d(:,4);
run.n=n;
run.t=t;

d = d(:,1);  %  Chn0/Ind1 is absolute position encoder

% Compute distance traveled in pixels
d = diff(d);
d(abs(d) > discontinuity_thresh) = NaN;
d = nansum(d);
d = d*run.cm_per_volt*run.pixels_per_cm*gain;

%run.p_raw is raw position, while run.p controls stimulus. These are
%different if stimulus freezes
p = run.p;
p_raw=run.p_raw;

if abs(d) > noise_threshold
    % Compute new position
    p = fix(p - d);
    p = mod(p,run.trial(run.trial_number).trk.length);
    
    p_raw = fix(p_raw - d);
    p_raw = mod(p_raw,run.trial(run.trial_number).trk.length);

else
    d = 0;
end
    
if run.freeze_state>0
    if abs(d) > noise_threshold
        % Compute new position
        run.pfreeze = fix(run.pfreeze - d);
        run.pfreeze = mod(run.pfreeze,run.trial(run.trial_number).trk.length);
        d=0;
    else
        d = 0;
    end
end

p(p==0) = 1;

if run.freeze_state==0
    run.p = p;
end

run.p_raw=p_raw;

run.distance = run.distance + d;

% check photodiode if a new stimulus appeared
diode=[run.pdiode; run.d_data];
tt=[run.pt; run.t];

c_obj_ind = run.p_mat(5,run.p);
if isnan(run.trial(run.trial_number).tdiode(c_obj_ind))
    td=find(diode>0.25,1,'first'); %0.15
    if ~isempty(td)
        run.diode=tt(td);
    end
end


led=[run.pled; run.l_data];
tl=find(diff(led)>1,1);
if ~isempty(tl)
    run.tled=tt(tl);
end

%update stored variables
run.pdiode=run.d_data;
run.pled=run.l_data;
run.pt=run.t;
     
function clearDaq(ai,run)
run = computePosition(ai,run);

function velocity = computeVelocity(ai,run)
clearDaq(ai,run);
for i = 1:3
    run = computePosition(ai,run);
    d(i) = run.distance;
    
    if i < 3
        WaitSecs(trk.track_update_interval);
    end
end

d = diff(d)/2/run.track_update_interval;  % pixels/s
velocity = d*run.cm_per_pixel;

function run = computeContingencies(run,ai)

c_obj_ind = run.p_mat(5,run.p);
obj = run.trial(run.trial_number).trk.obj(c_obj_ind);

% Determine LED status
if run.use_led && ~run.freeze_state;
    run = assessLED(run,obj);
end

%Determine if need to freeze stimulus
if run.freeze_flag
    if isnan(run.trial(run.trial_number).p1(c_obj_ind))||isnan(run.trial(run.trial_number).p2(c_obj_ind))
        run = freezeStimulus(run,obj,c_obj_ind);
    end
end

if run.distance-run.distance_last_reward > 0.7*run.trial(run.trial_number).trk.length
    obj.reward_available = 1;
    run.trial(run.trial_number).trk.obj(c_obj_ind) = obj;
end

if obj.target && obj.reward_available && run.p <= obj.target_zone(1) && run.p >= obj.target_zone(2)
    run.time_in_reward_zone = run.time_in_reward_zone + toc(run.tic_hold_time);
else
    run.time_in_reward_zone = 0;
end


time_hold = run.trial(run.trial_number).time_hold_for_reward;
    
if obj.target && obj.reward_available && run.time_in_reward_zone > time_hold
 
    putvalue(run.lick_port.parentuddobj,1,1);
    WaitSecs(run.trial(run.trial_number).solenoid_open_time);
    putvalue(run.lick_port.parentuddobj,0,1);
    
    run.distance_last_reward = run.distance;
    obj.reward_available = 0;
    
    run.n_rewards = run.n_rewards + 1;
    disp(['rewards = ' num2str(run.n_rewards)])
    run.reward_data(run.n_rewards).time_in_session = toc(run.tic_session_start);
    run.reward_data(run.n_rewards).time_in_trial = toc(run.tic_trial_start);
    run.reward_data(run.n_rewards).trial_number = run.trial_number;
    run.reward_data(run.n_rewards).position = run.p;
    run.reward_data(run.n_rewards).target_object = c_obj_ind;
    run.reward_data(run.n_rewards).hold_time = run.time_in_reward_zone;
    
    run.trial(run.trial_number).trk.obj(c_obj_ind) = obj;
    
    run.time_in_reward_zone = 0;
    clearDaq(ai,run);
end

function run = assessLED(run,obj)

for i = 1:length(obj.led_on)
    if obj.led_on(i) && run.p <= (obj.center+1300) && run.p >= (obj.led_zone(2)-100) %&& obj.target 
        if ~run.led_state(i)
            run.led_state(i) = 1;
            % Turn on LED
            putvalue(run.led(obj.led_on(i)).parentuddobj,1,i+1);
        end
    elseif run.led_state(i)
        % Turn off LED
        run.led_state(i) = 0;
        putvalue(run.led(i).parentuddobj,0,2);
    end
end


function run = freezeStimulus(run,obj,i)
    if isnan(run.trial(run.trial_number).p1(i)) && run.p <= (obj.center+1300)&& run.p>1  %1100
        run.trial(run.trial_number).p1(i)=run.p;
        run.pfreeze=run.p;
        run.p=obj.center+610;
        run.freeze_state=tic;
    elseif isnan(run.trial(run.trial_number).p2(i)) && ~isnan(run.trial(run.trial_number).p1(i))
        if toc(run.freeze_state)>0.35 % 0 for just flash & no freeze
            run.freeze_state=0;
            run.trial(run.trial_number).p2(i)=run.pfreeze;
        elseif toc(run.freeze_state)>0.3 && run.use_led
             run = assessLED(run,obj);
        end
    end


function waitForUpdateInterval(run)
if toc(run.tic_update) < run.track_update_interval
    WaitSecs(run.track_update_interval-toc(run.tic_update));
end

function trigger_time = triggerDaq(run)

if run.parallel_port_trigger && (isfield(run,{'p_port'}))
    p_port = run.p_port;
    if run.parallel_port_trigger
        trigger_time = toc(run.tic_session_start);
        putvalue(p_port.parentuddobj,[p_port.bitOn p_port.bitOff],p_port.triggerLine)
        WaitSecs(0.0002);%WaitSecs(0.0001); %AR
        putvalue(p_port.parentuddobj,[p_port.bitOff p_port.bitOff],p_port.triggerLine)
    end
elseif isfield(run,'daqTrig')
    trigger_time = toc(run.tic_session_start);
    if run.use_led
        ind=4;
    else
        ind=2; 
    end
    putvalue(run.daqTrig.parentuddobj,1,ind);
    WaitSecs(0.0002);
    putvalue(run.daqTrig.parentuddobj,0,ind);
end

function [session_active tic_keyCheck] = keyCheck(session_active)
tic_keyCheck = tic;
[key_pressed, junk, key] = KbCheck;
if key_pressed && find(key) == 8
    session_active = 0;
end

function  c = computeCoordinates(p,p_mat,sw,tile_w,trk_h)
% p:
% p_mat:
% sw: screen_width
% tile_w: tile_width
% trk_h: track height

% Coordinates of tile 1
t1_left = mod(p-1,tile_w);
t1_right = tile_w;
t1_w = t1_right - t1_left;
c{1,1} = [t1_left 0 t1_right trk_h];
c{1,2} = [0 0 t1_w trk_h];

% Coordinates of tile 2
t2_left = 0;
t2_right = sw-t1_w;
t2_right(t2_right>tile_w) = tile_w;
t2_w = t2_right - t2_left;
c{2,1} = [t2_left 0 t2_right trk_h];
c{2,2} = [t1_w 0 t1_w+t2_w trk_h];

% Coordinates of tile 3
t3_left = 0;
t3_right = sw-t1_w-t2_w;
t3_right(t3_right>tile_w) = tile_w;
t3_w = t3_right - t3_left;
c{3,1} = [t3_left 0 t3_right trk_h];
c{3,2} = [t1_w+t2_w 0 t1_w+t2_w+t3_w trk_h];

function saveRunData(run,mouse)
if run.save_run
    run = rmfield(run,{'p_mat','lick_port'});
    if run.parallel_port_trigger && (isfield(run,{'p_port'}))
        run = rmfield(run,{'p_port'});
    end
    if run.use_led
        run = rmfield(run,{'led'});
    end
    if isfield(run,'daqTrig')
        run = rmfield(run,{'daqTrig'});
    end
    save(mouse.vtrack.session(mouse.vtrack.session_ind).run_file,'run')
end

function mouse = finalSave(run,mouse)
if run.save_run
    rdef = RigDefs;
    run = rmfield(run,{'p_mat','lick_port'});
    if run.parallel_port_trigger && (isfield(run,{'p_port'}))
        run = rmfield(run,{'p_port'});
    end
    if run.use_led
        run = rmfield(run,{'led'});
    end
    if isfield(run,'daqTrig')
        run = rmfield(run,{'daqTrig'}); 
    end
    
    % Save run file on analysis PC
    [junk fname] = fileparts(mouse.vtrack.session(mouse.vtrack.session_ind).run_file);
    fname = [rdef.Dir.vTrackData fname];
    fname = checkIfFileExists(fname);
    run.file = fname;
    saveRun(run);
    
    % Set new run file in mouse struct and save
    mouse.vtrack.session(mouse.vtrack.session_ind).run_file = run.file;
    saveMouse(mouse);
end

function mouse = endTrack(ai,run,mouse,psychlasterror)

% Session ends now
run.session_end_time = datestr(now);

% Could deal with this in another way
run.trial_number = run.trial_number - 1;

% Delete ai
stop(ai)
delete(ai);

% Delete udp object
if isfield(run,'u');
    pnet('closeall');
    run = rmfield(run,'u');
end

% Delete parallel port dio
if run.parallel_port_trigger && (isfield(run,{'p_port'}))
    delete(run.p_port.dio);
end


% Delete LED dio
if run.use_led
    for i = 1:length(run.led)
        putvalue(run.led(i).parentuddobj,0,i+1);
    end
end

if isfield(run,'daqTrig')
    putvalue(run.daqTrig.parentuddobj,0,1)
end

% Delete lickport dio
delete(run.lick_port.dio);

% Error?
if ~isempty(psychlasterror)
    psychrethrow(psychlasterror);
end

% Screen clean-up
Priority(0);
ShowCursor
Screen('CloseAll');
if isfield(run,'tx')
    Screen('Close',run.tx);
end
clear mex

putvar(run)

% Save
saveRunData(run,mouse)
mouse = finalSave(run,mouse);

function value = getFromTable(table,field)

iRow = strcmp(table(:,1),field);

if any(iRow)
    value = table(iRow,2);
    if iscell(value)
        value = value{1};
    end
else
    value = '';
end

function displayCue


function run = udpSetup(run)

if run.parallel_port_trigger;
    rdef = RigDefs;
    if ~isempty(rdef.DAQPC_IP)
        % Look for valid udp
        bnewudp = 0;
        props = {'Tag','Type'};
        vals = {'udp_conditions','udp'};
        u = instrfindall(props,vals);
        delete(u);
        if ~isempty(u)
            if ~isvalid(u);
                delete(u);
                bnewudp = 1;
            end
        else
            bnewudp = 1;
        end
        
        % If valid upd doesn't exist create it
        if bnewudp
            
            u=pnet('udpsocket',9092); %Port 9093 on the local (VS) computer
            if u<0 % reinitiate udp
                pnet(u,'close');
                u=pnet('udpsocket',9092);
            end
            
            pnet(u,'udpconnect','169.230.189.210',9093); % Remote IP and port
            pnet(u, 'setreadtimeout', 0.1); %read time out in sec
           
        end
    end
    
    run.u = u;
    
    if run.eyetracker_flag
        %% Writing UDP
        pnet(udp,'write','startOneTrial');
        pnet(udp,'writepacket');
        display('Sent to eyetracker: startOneTrial');
        WaitSecs(2);
    end

end


function run = syncDaqPulse(run)

pulse_period = 200; %1 AR
i = size(run.sync_daq,1)+1;

udp=run.u;
if mod(run.update_index,pulse_period) == 1%1 AR
    
    if run.eyetracker_flag 
               
        
        %% Reading/waiting for UDP
        tt=tic;
        while toc(tt)<10 % Keep checking for UDP
            s=pnet(udp,'readpacket');
            if s>0
                vstype=pnet(udp,'read',s,'char');
                disp(['Eye tracker communication: ' vstype]);
                break;
            else
                WaitSecs(0.3);
            end
        end
        if toc(tt)>10
           disp('Warning: missed Eye tracker communication'); 
        end
    end
run.sync_daq(i,1) = run.trial_number; %run.update_index; %AR
run.sync_daq(i,2) = triggerDaq(run);
run.sync_daq(i,3) = run.p;

end





