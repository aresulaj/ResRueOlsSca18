function handles = PlotChooserHelper(handles)
%
%
%
%   Created: 4/5/10 - SRO

% % Insert channel information into table
% nActiveChannels = handles.nActiveChannels;
% % if nActiveChannels < 32
% %     BlankEntries = {'' '' ''};
% %     BlankEntries = repmat(BlankEntries,(24-nActiveChannels),1);
% %     handles.ChannelInfo = [handles.ChannelInfo; BlankEntries];
% % end
% set(handles.DaqTable1,'Data',handles.ChannelInfo(1:17,:));
% % set(handles.DaqTable2,'Data',handles.ChannelInfo(17:32,:));
% 
% % Make vector of all toggle handles
% for i = 1:17
%     s = ['handles.hTglPlotAll(' num2str(i) ') = handles.TglPlot' num2str(i) ';'];
%     eval(s);
% end
% handles.hTglPlotAll(1)  = handles.TglPlot1;
% set(handles.hTglPlotAll,'BackgroundColor',[0.8 0.8 0.8]);
% 
% % Make toggles for low-pass, high-pass, and threshold
% for i = 1:17
%     hTglLP(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
%     hTglHP(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
%     hTglThr(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
%     if i < 17
%         set(hTglLP(i),'Position',[30 (302-(i-1)*16) 11 11]);
%         set(hTglHP(i),'Position',[49 (302-(i-1)*16) 11 11]);
%         set(hTglThr(i),'Position',[69 (302-(i-1)*16) 11 11]);
%     else
%         set(hTglLP(i),'Position',[235 (302-(i-17)*16) 11 11]);
%         set(hTglHP(i),'Position',[254 (302-(i-17)*16) 11 11]);
%         set(hTglThr(i),'Position',[274 (302-(i-17)*16) 11 11]);
%     end 
% end
% 
% handles.hTglLP = hTglLP;
% handles.hTglHP = hTglHP;
% handles.hTglThr = hTglThr;
% set(hTglLP,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@LPCallback,handles});
% set(hTglHP,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@HPCallback,handles});
% set(hTglThr,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@ThreshCallback,handles});
% 
% % Disable toggles for inactive channels
% hInactiveToggle = handles.hTglPlotAll(nActiveChannels+1:end);
% set(hInactiveToggle,'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
% set(hTglLP(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
% set(hTglHP(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
% set(hTglThr(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
% 
% % Initialize toggles for active channels
% dvplot = getappdata(handles.hDataViewer,'dvplot');
% hActiveToggle = handles.hTglPlotAll(dvplot.pvOn);
% set(hActiveToggle,'Value',1,'BackgroundColor',[0.3 0.3 1]);        
% 
% % Set appdata in DataViewer for filter cutoffs
% setappdata(handles.hDataViewer,'LPCutoff',str2num(get(handles.LPedit,'String')));
% setappdata(handles.hDataViewer,'HPCutoff',str2num(get(handles.HPedit,'String')));


% Insert channel information into table
nActiveChannels = handles.nActiveChannels;
if nActiveChannels < 32
    BlankEntries = {'' '' ''};
    BlankEntries = repmat(BlankEntries,(24-nActiveChannels),1);
    handles.ChannelInfo = [handles.ChannelInfo; BlankEntries];
end
set(handles.DaqTable1,'Data',handles.ChannelInfo(1:16,:));
set(handles.DaqTable2,'Data',handles.ChannelInfo(17:32,:));

% Make vector of all toggle handles
for i = 1:32
    s = ['handles.hTglPlotAll(' num2str(i) ') = handles.TglPlot' num2str(i) ';'];
    eval(s);
end
handles.hTglPlotAll(1)  = handles.TglPlot1;
set(handles.hTglPlotAll,'BackgroundColor',[0.8 0.8 0.8]);

% Make toggles for low-pass, high-pass, and threshold
for i = 1:32
    hTglLP(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
    hTglHP(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
    hTglThr(i) = uicontrol(handles.MainPanel,'Style','togglebutton');
    if i < 17
        set(hTglLP(i),'Position',[30 (302-(i-1)*16) 11 11]);
        set(hTglHP(i),'Position',[49 (302-(i-1)*16) 11 11]);
        set(hTglThr(i),'Position',[69 (302-(i-1)*16) 11 11]);
    else
        set(hTglLP(i),'Position',[235 (302-(i-17)*16) 11 11]);
        set(hTglHP(i),'Position',[254 (302-(i-17)*16) 11 11]);
        set(hTglThr(i),'Position',[274 (302-(i-17)*16) 11 11]);
    end 
end

handles.hTglLP = hTglLP;
handles.hTglHP = hTglHP;
handles.hTglThr = hTglThr;
set(hTglLP,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@LPCallback,handles});
set(hTglHP,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@HPCallback,handles});
set(hTglThr,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@ThreshCallback,handles});

% Disable toggles for inactive channels
hInactiveToggle = handles.hTglPlotAll(nActiveChannels+1:end);
set(hInactiveToggle,'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
set(hTglLP(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
set(hTglHP(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);
set(hTglThr(nActiveChannels+1:end),'Enable','off','BackgroundColor',[0.925 0.914 0.847]);

% Initialize toggles for active channels
dvplot = getappdata(handles.hDataViewer,'dvplot');
hActiveToggle = handles.hTglPlotAll(dvplot.pvOn);
set(hActiveToggle,'Value',1,'BackgroundColor',[0.3 0.3 1]);        

% Set appdata in DataViewer for filter cutoffs
setappdata(handles.hDataViewer,'LPCutoff',str2num(get(handles.LPedit,'String')));
setappdata(handles.hDataViewer,'HPCutoff',str2num(get(handles.HPedit,'String')));