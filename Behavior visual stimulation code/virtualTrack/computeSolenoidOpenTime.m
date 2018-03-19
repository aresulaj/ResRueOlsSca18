function run = computeSolenoidOpenTime(run)
%
%
%
%
%

% Created: SRO - 5/25/12





volume = run.trial(run.trial_number).reward_volume;
run.trial(run.trial_number).solenoid_open_time = ...
    roundn( (volume - run.lick_port_cal.b)/run.lick_port_cal.m, -3);


