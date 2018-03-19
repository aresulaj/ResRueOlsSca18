function expt = loadExpt(expt_name)
%
%
%
%

% Created: SRO - 10/4/11

rdef = RigDefs;
expt = loadvar([rdef.Dir.Expt expt_name '_expt.mat']);