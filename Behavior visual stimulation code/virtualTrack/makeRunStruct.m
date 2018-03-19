function run = makeRunStruct(vtrack_table,mouse)
%
%
%
%
%

% Created: SRO - 6/8/12



% Screen defaults
sdef = screenDefs;

% Variables for controlling track
[junk run_name] = fileparts(mouse.vtrack.session(mouse.vtrack.session_ind).run_file);
run.name = run_name;
run.rig = getFromTable(vtrack_table,'Rig');
run.date = datestr(now,0);
run.sdef = sdef;
run.mouse_code = mouse.mouse_code;
run.mouse_file = mouse.file;
run.session_ind = mouse.vtrack.session_ind;
run.screen_rect = [0 0 sdef.width sdef.height];
run.n_rewards = 0;
run.time_in_reward_zone = 0;
run.p = 1;
run.p_raw=1;
run.distance = 0;
run.trial_number = 1;
run.reward_limit = str2num(getFromTable(vtrack_table,'Reward limit'));
run.number_of_trials = str2num(getFromTable(vtrack_table,'Number of trials'));
run.parallel_port_trigger = str2num(getFromTable(vtrack_table,'Parallel port trigger'));
run.distance_last_reward = 0;
run.wait_time_after_trigger = str2num(getFromTable(vtrack_table,'Wait time after trigger'));
run.threshold_initiation_speed = str2num(getFromTable(vtrack_table,'Threshold initiation speed'));
run.track_update_frequency = str2num(getFromTable(vtrack_table,'Track update frequency'));
run.track_update_interval = 1/run.track_update_frequency;
run.pixels_per_cm = sdef.width/sdef.width_inches/2.54;  % Convert inches to cm
run.cm_per_volt = pi*6*2.54/1;   % disk circumference*conversion/encoder voltage range
run.display_offset = round(sdef.width/2-100);
run.track_file = getFromTable(vtrack_table,'Track file');
run.sync_daq = [];
run.track_table = vtrack_table;
run.led_state = [0 0];
run.use_led = str2num(getFromTable(vtrack_table,'LED'));

%AR added this
run.freeze_flag=1;
run.freeze_state=0;
run.pfreeze=0;
run.eyetracker_flag=str2num(getFromTable(vtrack_table,'Eye tracker'));
if isempty(run.eyetracker_flag)
    run.eyetracker_flag=0;
end

%AR added this
run.pdiode=[];
run.pled=[];
run.pt=[];
run.tled=nan;
run.diode=nan;
run.save_diode=str2num(getFromTable(vtrack_table,'Save Diode'));

num_objects=str2num(getFromTable(vtrack_table,'Number of objects'));

switch run.rig
    case 'SRO1'
        run.lick_port_cal = loadvar('C:\Users\Arbora\Documents\MATLAB\lick_cal.mat');
    case 'SRO2'
        run.lick_port_cal = loadvar('C:\Users\Arbora\Documents\MATLAB\lick_cal.mat');
end

lum_max=sdef.a*(255^sdef.b);
lum_b= 100; %lum_max/2;
background_pix_val=floor(exp(log(lum_b/sdef.a)/sdef.b));


for i = 1:run.number_of_trials
    
    % Gain between movement of disk and object movement on screen
    run.trial(i).track_gain = str2num(getFromTable(vtrack_table,'Track gain'));
    
    % Trial timing parameters
    run.trial(i).trial_duration = str2num(getFromTable(vtrack_table,'Trial duration'));
    run.trial(i).iti = str2num(getFromTable(vtrack_table,'Inter-trial interval'));
    
    % Reward parameters
    run.trial(i).reward_volume = str2num(getFromTable(vtrack_table,'Reward volume')); 
    run.trial(i).time_hold_for_reward = str2num(getFromTable(vtrack_table,'Hold for reward'));
    
    % LED paramters
    run.trial(i).led = getFromTable(vtrack_table,'LED');
    
    % Backgorund parameters
    run.trial(i).background_luminance = str2num(getFromTable(vtrack_table,'Background luminance'));
    run.trial(i).background_pix_val = background_pix_val; 
    % Cue parameters
    run.trial(i).cue_location = str2num(getFromTable(vtrack_table,'Cue location'));
    run.trial(i).cue_type = '';
    
    % Make track
    run.trial(i).trk = makeTrkStruct(vtrack_table);
    
    run.trial(i).p1= NaN(1,num_objects); %AR added this
    run.trial(i).p2= NaN(1,num_objects); %AR added this
    
    %Timing for stimulus and led
    run.trial(i).tled= NaN(1,num_objects); %AR added this
    run.trial(i).tdiode= NaN(1,num_objects); %AR added this

end

% --- Set up matrix for storing position and times
run.samples_per_trial = run.trial(1).trial_duration*run.track_update_frequency;  % Make more flexible
run.position_data = NaN(run.samples_per_trial,run.number_of_trials,2);
run.position_data = single(run.position_data);

run.position_data_raw = NaN(run.samples_per_trial,run.number_of_trials,1);
run.position_data_raw = single(run.position_data_raw);

run.diode_data=NaN(70,1000,4);
run.diode_data=single(run.diode_data);
    

% --- Set up struct for storing reward times

fld = {'time_in_session','time_in_trial','trial_number','position','target_object','hold_time'};
for i = 1:length(fld)
    run.reward_data.(fld{i}) = single(NaN(run.reward_limit,1));
end



