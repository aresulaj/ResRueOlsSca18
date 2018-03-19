function varargout = vTrackGui(varargin)
% VTRACKGUI M-file for vTrackGui.fig
%      VTRACKGUI, by itself, creates a new VTRACKGUI or raises the existing
%      singleton*.
%
%      H = VTRACKGUI returns the handle to a new VTRACKGUI or the handle to
%      the existing singleton*.
%
%      VTRACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VTRACKGUI.M with the given input arguments.
%
%      VTRACKGUI('Property','Value',...) creates a new VTRACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vTrackGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vTrackGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vTrackGui

% Last Modified by GUIDE v2.5 16-Jun-2012 20:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @vTrackGui_OpeningFcn, ...
    'gui_OutputFcn',  @vTrackGui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function vTrackGui_OpeningFcn(hObject, eventdata, handles, varargin)

% Set rig defaults
rdef = RigDefs;
handles.rdef = rdef;

% Set position of GUI
tmp = get(handles.hfig,'Position');
set(handles.hfig,'Position',[9.4 24.3 tmp(3) tmp(4)]);

% Load mouse
handles = vTrack_loadMouse(handles,[]);

% Update handles structure
guidata(hObject, handles);

putvar(handles);


function pb_run_track_Callback(hObject, eventdata, handles)

rdef = RigDefs;

% Get mouse, track table, and run filename
track_table = get(handles.table_track,'Data');
mouse = handles.mouse;
run_file = [rdef.Dir.vTrackDataLocal get(handles.tx_run_file,'String') '.mat'];
run_file = checkIfFileExists(run_file);
[junk fname] = fileparts(run_file);
set(handles.tx_run_file,'String',fname);
pause(0.05);

% Determine whether to save run data
save_run = get(handles.chk_save,'Value');

% Make new run session
if save_run
    mouse = vTrackSession(mouse,track_table,run_file);
end

% Save guidata
guidata(hObject,handles);

% Run track
mouse = virtualTrackNew(track_table,mouse,save_run);

% Update GUI
if save_run
    handles = vTrack_loadMouse(handles,mouse);
    putvar(handles)
end


function pb_load_track_Callback(hObject, eventdata, handles)
rdefs = RigDefs;
load_path = rdefs.Dir.vTrackSettings;
cd(load_path);
% table_track_file = uigetfile('.*mat');
table_track_file = uigetfile;
if ~table_track_file == 0
    table_track = loadvar(table_track_file);
    set(handles.table_track,'Data',table_track);
end

pb_display_track_Callback(handles.pb_display_track, [], handles)

function pb_save_track_Callback(hObject, eventdata, handles)
rdefs = RigDefs;
save_path = rdefs.Dir.vTrackSettings;
table_track = get(handles.table_track,'Data');
cd(save_path);
uisave('table_track');

function pb_load_mouse_Callback(hObject, eventdata, handles)
handles = vTrack_loadMouse(handles,[]);
tx_run_file_Callback(handles.tx_run_file, eventdata, handles)

function pb_save_mouse_Callback(hObject, eventdata, handles)

function handles = vTrack_loadMouse(handles,mouse)
rdef = handles.rdef;

% Load current mouse and display mouse table
if isempty(mouse)
    mouse = load_mouse();
end

% Set mouse code
set(handles.txt_mouse_code,'String',mouse.mouse_code);

% Set most recent track parameters for chosen mouse
track_table = load_track(mouse);
set(handles.table_track,'Data',track_table);

% Set local run file location
fname = [rdef.SaveNamePrefix '_' datestr(now,29) ...
    '_' mouse.mouse_code '_RUN' '_1'];
fname = checkIfFileExists(fname);
set(handles.tx_run_file,'String',fname);

% Display track
trk = makeTrkStruct(track_table);
cla(handles.ax_trk,'reset');
makeTrkFig(trk,handles.hfig,handles.ax_trk);
axis off

handles.mouse = mouse;
guidata(handles.hfig,handles);
putvar(handles)
putvar(mouse)


function varargout = vTrackGui_OutputFcn(hObject, eventdata, handles)

function chk_physiology_Callback(hObject, eventdata, handles)

function tx_run_file_Callback(hObject, eventdata, handles)
rdef = RigDefs;
run_file = [rdef.Dir.vTrackDataLocal get(handles.tx_run_file,'String') '.mat'];
run_file = checkIfFileExists(run_file);
[junk fname] = fileparts(run_file);
set(handles.tx_run_file,'String',fname);


function tx_run_file_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pb_lightsUp_Callback(hObject, eventdata, handles)
lightsUp;


function chk_save_Callback(hObject, eventdata, handles)

if get(hObject,'Value')
    set(handles.pb_run_track,'ForegroundColor',[0 0 1]);
    set(handles.txt_mouse_code,'ForegroundColor',[0 0 1]);
elseif ~get(hObject,'Value')
    set(handles.pb_run_track,'ForegroundColor',[1 0 0]);
    set(handles.txt_mouse_code,'ForegroundColor',[1 0 0]);
end


% --- Executes on button press in pb_calibrate.
function pb_calibrate_Callback(hObject, eventdata, handles)
% hObject    handle to pb_calibrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function pb_clear_line_Callback(hObject, eventdata, handles)
calibrateLickPort(60,1)



function pb_display_track_Callback(hObject, eventdata, handles)
track_table = get(handles.table_track,'Data');
trk = makeTrkStruct(track_table);
cla(handles.ax_trk,'reset');
makeTrkFig(trk,handles.hfig,handles.ax_trk);
axis off

putvar(trk)


% --- Executes on button press in pb_fwd_trk.
function pb_fwd_trk_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fwd_trk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_back_trk.
function pb_back_trk_Callback(hObject, eventdata, handles)
% hObject    handle to pb_back_trk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
