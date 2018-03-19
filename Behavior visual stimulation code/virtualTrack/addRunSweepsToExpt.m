function expt = addRunSweepsToExpt(expt)
%
%
%
%

% Created: SRO - 10/10/12


% Get 'daqRun' file for each .daq file


rdef = RigDefs;
sweepInd = 1;
for i = 1:length(expt.files.names)
    fname = expt.files.names{i};
    fname = fname(1:end-4);
    fname = [fname '_daqRun'];
    daqRun = loadvar([rdef.Dir.Data fname]);
    for n = 1:length(daqRun)
        expt.runSweeps.run_file{sweepInd} = daqRun(n).run_file;
        expt.runSweeps.trial_number(sweepInd) = str2double(daqRun(n).trial_number);
        expt.runSweeps.trial_start_time(sweepInd) = str2double(daqRun(n).trial_start_time);
        sweepInd = sweepInd + 1;
    end
end

a = 1;
