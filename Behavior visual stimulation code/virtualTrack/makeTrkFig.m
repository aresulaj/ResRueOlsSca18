function h = makeTrkFig(trk,hfig,hax,scale_im)
%
%
%
%
%

% Created: SRO - 6/7/12


if nargin < 2 || isempty(hfig)
    hfig = [];
end

if nargin < 3 || isempty(hax)
    hax = [];
end

if nargin < 4 || isempty(scale_im)
    scale_im = 0.1;
end

% Rig defs
rdef = RigDefs;
sdef = screenDefs;

% Make track matrix
trk_m = makeTrkMat(trk);

% Scale image
trk_m = imresize(trk_m,scale_im);
trk_m = flipdim(trk_m,1);
x = 1:size(trk_m,2);
y = 1:size(trk_m,1);

% Convert pixels to cm
x = x*trk.screen_cm_per_pix*1/scale_im;
y = y*trk.screen_cm_per_pix*1/scale_im;

% Make figure
if isempty(hfig)
    h.fig = landscapeFigSetup;
    set(h.fig,'Position',[497 641 1316 318])
else
    h.fig = hfig;
end

% Make Axes
if isempty(hax)
    h.ax = axes('Parent',h.fig);
else
    h.ax = hax;
end
defaultAxes(h.ax);
colormap(h.ax,'gray');

% Set axes limits
xL = [0 max(x)];
yL = [0 max(y)*1.25];
set(h.ax,'XLim',xL,'YLim',yL);
set(h.ax,'YTick',[]);

% Set axes aspect ratio
aspect_ratio = [max(x)/max(x) max(y)*1.2/max(x) 1];
set(h.ax,'PlotBoxAspectRatioMode','manual','PlotBoxAspectRatio',aspect_ratio)

% Display image
clims = [0 255];
h.im = imagesc('Parent',h.ax,'CData',trk_m,'XData',x,'YData',y,clims);

% Add target and screen bars
%AR added this on 1/15/2018
for ii=1:26
    trk.obj(ii).target=double(trk.obj(ii).target);
end

i_target = cell2mat({trk.obj.target});
targets = trk.obj(logical(i_target));
for i = 1:length(targets)
    if i == 1
        zone = targets(i).center*trk.screen_cm_per_pix;
        tmp = trk.screen_width_pix*trk.screen_cm_per_pix*0.5;
        zone = [zone-tmp zone+tmp];
        addStimulusBar(h.ax,[zone max(y)*1.2],'',[0.1 0.1 0.1],3);
    end
    zone = targets(i).target_zone*trk.screen_cm_per_pix;
    addStimulusBar(h.ax,[zone max(y)*1.2],'',[0.8 0.8 0.8],3);
end

set(h.ax,'XDir','reverse')

