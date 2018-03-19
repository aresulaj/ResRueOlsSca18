function lightsUp(duration)
%
%
%
% duration in minutes

if nargin < 1 || isempty(duration)
    duration = 10;
end

duration = 10*60;

sdef = screenDefs;
KbName('UnifyKeyNames')
Screen('Preference', 'VisualDebuglevel', 3);
[w,wRect] = Screen(sdef.screenNum,'OpenWindow',255);
[w2,wRect2] = Screen(sdef.screenNum2,'OpenWindow',255);

% Show gray screen
Screen('Flip',w);
Screen('Flip',w2);


t_start = tic;

while ~KbCheck && toc(t_start) < duration
    
    lights = 1;
    

end

Screen closeall
clear mex