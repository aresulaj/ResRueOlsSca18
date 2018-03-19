function orientationFig(expt,unitTag,fileInd,b,saveTag)
% function orientationFig(expt,unitTag,fileInd,b,saveTag)
%
% INPUT
%   expt: Experiment struct
%   unitTag: Tag of the form 'trode_assign', e.g 'T2_15'
%   fileInd: Vector of file indices to be included in analysis.
%   b: Flag structure with field b.save, b.print, b.pause, b.close

% Created: 5/13/10 - SRO
% Modified: 5/16/10 - SRO
% Modified 5/5/14 - AR

if nargin < 4
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
    saveTag = '';
end

% Rig defaults
rigdef = RigDefs;

% Set cond struct
cond = expt.analysis.orientation.cond;
cond.type='all'; %AR added this

% Set time window struct
w = expt.analysis.orientation.windows;
w.stim(2)=min(expt.files.duration);  %AR added this

% Temporary color
if isempty(cond.color)
    cond.color = {[0.1 0.1 0.1],[1 0.25 0.25],[0 0 1],[1 0.5 0],[1 0 1],[0.3 0.3 0.3],[0.7 0.7 0.7]};
end
gray = [0.6 0.6 0.6];
green = [0 1 0];
blue = [0 120/255 200/255];
red = [1 0.25 0.25];

% Figure layout
h.fig = landscapeFigSetup;
set(h.fig,'Visible','on','Position',[792 399 1056 724]) %'off' %AR

% Set save name suffix (saveTag)
if isempty(saveTag)
    saveTag = [unitTag '_Ori'];
else
    saveTag = [unitTag '_' saveTag];
end

% Set expt struct as appdata
setappdata(h.fig,'expt',expt);
setappdata(h.fig,'figText',saveTag);

% Add save figure button
addSaveFigTool(h.fig);

% Get tetrode number and unit index from unit tag
[trodeNum unitInd] = readUnitTag(unitTag);

% Get unit label
label = getUnitLabel(expt,trodeNum,unitInd);

% Get spikes from trode number and unit index
spikes = loadvar(fullfile(rigdef.Dir.Spikes,expt.sort.trode(trodeNum).spikesfile));

% Extract spikes for unit and files
spikes = filtspikes(spikes,0,'assigns',unitInd,'fileInd',fileInd);

if ~isempty(spikes.spiketimes)
    % Set NaNs = 0
    spikes.led(isnan(spikes.led)) = 0;
    spikes.sweeps.led(isnan(spikes.sweeps.led)) = 0;
    
    % Get stimulus parameters
    varparam = expt.stimulus(fileInd(1)).varparam(1);
    stim.type = varparam.Name;
    if isfield(expt.stimulus(fileInd(1)).params,'oriValues')
        stim.values = expt.stimulus(fileInd(1)).params.oriValues;
    else
        stim.values = varparam.Values;
    end
    %
    for i = 1:length(stim.values)
        stim.code{i} = i;
    end
    
    % If using all trials
    if strcmp(cond.type,'all')
        spikes.all = ones(size(spikes.spiketimes));
        cond.values = {1};
    end
    
    
    % Make spikes substruct for each stimulus value and condition value
    for m = 1:length(stim.values)
        for n = 1:length(cond.values)
            if strcmp(cond.type,'led')
                spikes = makeTempField(spikes,'led',cond.values{n});
                cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},'temp',1);
            else
                %cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m},cond.type,cond.values{n});
                cspikes(m,n) = filtspikes(spikes,0,'stimcond',stim.code{m}); %AR added this
            end
        end
    end
    
    % --- Make raster plot for each cspikes substruct
    for m = 1:size(cspikes,1)       % m is number of stimulus values
        h.r.ax(m) = axes;
        defaultAxes(h.r.ax(m));
        for n = 1:size(cspikes,2)   % n is number of conditions
            switch label
                
                case {'multi-unit','FS multi-unit','axon multi-unit'}
                    h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
                otherwise
                    % Make last arg = 1 to plot bursts
                    h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
            end
        end
    end
    h.r.ax = h.r.ax';
    set(h.r.ax,'Box','on')
    
%     
    % Set axes properties
    hTemp = reshape(h.r.ax,numel(h.r.ax),1);
    ymax = setSameYmax(hTemp);
    removeAxesLabels(hTemp)
    defaultAxes(hTemp)
    gray = [0.85 0.85 0.85];
    set(hTemp,'YColor',gray,'XColor',gray,'XTick',[],'YTick',[]);
    
    % Set stimulus condition as title
    for i = 1:length(stim.values)
        temp{i} = round(stim.values(i));
    end
    set(cell2mat(get(h.r.ax,'Title')),{'String'},temp','Position',[1 0 1]);  %'Position',[1.4983 0 1]
    
    
    % --- Make PSTH for each cspikes substruct
    for m = 1:size(cspikes,1)       % m is number of stimulus values
        h.psth.ax(m) = axes;
        for n = 1:size(cspikes,2)   % n is number of conditions
            [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),50);
%                         [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),100);

            h.psth.n(m,:,n) = n_avg;
            [h.psth.l(m,n) h.psth.sem(m,n)] = plotPsth2sem(n_avg,n_sem,centers,h.psth.ax(m));
            %             [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
        end
        h.psth.ax = h.psth.ax';
    end
    
    % Set axes properties
    setRasterPSTHpos(h)
    hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
    ymax = setSameYmax(hTemp,15);
    for i = 1:length(h.psth.ax)
        addStimulusBar(h.psth.ax(i),[w.stim ymax],'',cond.color{1});
        if strcmp(cond.type,'led')
            addStimulusBar(h.psth.ax(i),[w.ledon ymax*0.97],'',red,1.5);
        end
    end
    removeInd = 1:length(hTemp);
    keepInd = ceil(length(hTemp)/2) + 1;
    removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
    defaultAxes(hTemp,0.25,0.15)
    
    % --- Compute average response as a function oriention
    [allfr nallfr allfr_sem] = computeResponseVsStimulus(spikes,stim,cond,w);
    
    % --- Make orientation tuning plots
    h.ori.ax = axes('Parent',h.fig); ylabel('spikes/s','FontSize',8)
    %h.nori.ax = axes('Parent',h.fig);
    theta = stim.values';
    h.ori.l = plotOrientTuning(allfr.on,theta,h.ori.ax);
    for i = 1:size(h.ori.l,2)
         addErrBar(theta,allfr.on(:,i),allfr_sem.on(:,i),'y',h.ori.ax,h.ori.l(:,i));
    end
    %h.nori.l = plotOrientTuning(nallfr.on,theta,h.nori.ax);
    defaultAxes(h.ori.ax,0.2,0.14);
    xlabel('orientation','FontSize',8)
    setTitle(h.ori.ax,'on window',8);
    set(h.ori.ax,'Position',[0.377 0.22 0.128 0.1])
    %setTitle(h.nori.ax,'normalized',8);
    
    % --- Make polar plots
    polplots = {'stim','on'};
    for i = 1:length(polplots)
        win = polplots{i};
        temp = allfr.(win);
        temp(temp<0) = 0;
        [h.pol.(win).l, h.pol.(win).ax] = polarOrientTuning(temp,theta);
        set(get(gca,'Title'),'String',win,'Visible','on');
    end
    set(h.pol.stim.ax,'Position',[0.52 0.2 0.06 0.12])
    set(h.pol.on.ax,'Position',[0.61 0.2 0.06 0.12])
 
    % --- Plot firing rate vs time
    h.frvt.ax = axes;
    h.frvt.l(1) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.stim);
    h.frvt.l(2) = plotSpikesPerTrial(spikes,h.frvt.ax,0,w.spont);
    defaultAxes(h.frvt.ax,0.22,0.14);
    xlabel('minutes','FontSize',8); ylabel('spikes/s','FontSize',8);
    set(h.frvt.l,'LineStyle','none','Marker','o','MarkerSize',4);
    set(h.frvt.l(2),'Color',[0 0 0],'MarkerFaceColor',[0 0 0]);
    set(h.frvt.l(1),'Color',[1 0 0],'MarkerFaceColor',[1 0 0]);
    set(h.frvt.ax,'Position',[0.213 0.22 0.128 0.1])
    
    % --- Plot average PSTH across all stimulus conditions
    h.allp.ax = axes;
    [h.allp.l h.allp.ax] = allStimPSTH(h.psth.n,centers,w,h.allp.ax);
    ymax = setSameYmax(h.allp.ax,15);
    addStimulusBar(h.allp.ax,[w.stim ymax]);
    if strcmp(cond.type,'led')
        addStimulusBar(h.allp.ax,[w.ledon ymax*0.97],'',red,1.5);
    end
    defaultAxes(h.allp.ax,0.22,0.14);
    set(h.allp.ax,'Position',[0.213 0.07 0.128 0.1])
    
      % --- Compute average firing rate (spontaneous, evoked, on-transient, off)
    for i = 1:length(cond.values)
        if strcmp(cond.type,'led')
            spikes.tempfield = spikes.led;
            spikes.tempfield = compareDouble(spikes.tempfield,cond.values{i});
            spikes.sweeps.tempfield = spikes.sweeps.led;
            spikes.sweeps.tempfield = compareDouble(spikes.sweeps.tempfield,cond.values{i});
            tempspikes = filtspikes(spikes,0,'tempfield',1);
            wnames = fieldnames(w);
        else
            %AR added this
            if isfield(spikes,'cond')
                tempspikes = filtspikes(spikes,0,cond.type,cond.values{i});
            else
                tempspikes=spikes;
            end
            wnames = fieldnames(w);
        end
        for n = 1:length(wnames)
            temp = wnames{n};
            [fr.(temp)(i,1) fr.(temp)(i,2)] = computeFR(tempspikes,w.(temp));  % average and SEM
        end
    end
    clear tempspikes
    
    % Make category plot for each time window
    wnames={'spont','stim','on'};
    for i = 1:length(wnames)
        temp = wnames{i};
        [h.avgfr.(temp).l junk h.avgfr.(temp).ax] = plotCategories(fr.(temp)(:,1),cond.tags,fr.(temp)(:,2),'',[],0);
        setTitle(gca,temp,7);
    end
    defaultAxes(h.avgfr.spont.ax,0.1,0.48);
    set(h.avgfr.spont.ax,'Position',[0.7 0.215 0.053 0.105])
    set(h.avgfr.stim.ax,'Position',[0.783 0.215 0.053 0.105])
    set(h.avgfr.on.ax,'Position',[0.867 0.215 0.053 0.105])
    
    % Make category plot for blank stimulus
    params = expt.stimulus(fileInd(1)).params;
    if isfield(params,'addBlank')
        addBlank = params.addBlank;
    else
        addBlank = 0;
    end
    
    if addBlank
        bFR = computeBlankResponse(spikes,params,cond,expt);
        [h.blank.l h.blank.ax] = plotCategories(bFR(:,1),cond.tags,bFR(:,2),'',[],0);
        setTitle(gca,'blank',7);
        set(gca,'Position',[.609 .059 .054 .104]);
    end
    

    % Add expt name
    %h.Ann = addExptNameToFig(h.fig,expt);
    
    % Make figure visible
    set(h.fig,'Visible','on')
      
end


% --- Subfunctions --- %

function setRasterPSTHpos(h)

nstim = length(h.r.ax);
ncol = ceil(nstim/2);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.02 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.37 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;
s2 = 0.035;
s3 = 0.02;

% Compute heights
rowheight = (matpos(4) - matpos(3))/2;
pheight = (rowheight-s1-s2)*prelsize;
rheight = (rowheight-s1-s2)*rrelsize;

% Compute width
width = (matpos(2)-matpos(1)-(ncol-1)*s3)/ncol;

% Row positions
p1bottom = matpos(3) + rowheight;
p2bottom = matpos(3);
r1bottom = p1bottom + pheight + s1;
r2bottom = p2bottom + pheight + s1;

% Compute complete positions
for i = 1:nstim
    if i <= ncol
        col = matpos(1)+(width+s3)*(i-1);
        p{i} = [col p1bottom width pheight];
        r{i} = [col r1bottom width rheight];
    elseif i > ncol
        col = matpos(1)+(width+s3)*(i-1-ncol);
        p{i} = [col p2bottom width pheight];
        r{i} = [col r2bottom width rheight];
    end
end

% Set positions
set([h.psth.ax; h.r.ax],'Units','normalized')
set(h.psth.ax,{'Position'},p')
set(h.r.ax,{'Position'},r')






