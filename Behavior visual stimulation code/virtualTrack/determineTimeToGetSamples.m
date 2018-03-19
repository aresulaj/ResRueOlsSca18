

function determineTimeToGetSamples()





    ai = analoginput('mcc',0);
    set(ai,'SampleRate',10000,'TriggerType','Immediate');
ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
set(ch(1),'InputRange',[-10 10]);
set(ch(1),'SensorRange',[0 5]);
set(ch(1),'UnitsRange',[0 1]);
set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire

pause(1)

start(ai);

for i = 1:4000
    n = 0;
    tic
    while n == 0
        n = get(ai,'SamplesAvailable');
    end
    times(i) = toc;
    d = getdata(ai,n);
end

figure; hist(times,100)
delete(ai)