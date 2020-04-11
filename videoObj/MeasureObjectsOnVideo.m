%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   PROGRAM BY: Clive Fox, 26 Jan 2017                                  %
%   FILE NAME: MeasureObjectsOnVideo                                    %
%   VER: 2.8                                                            %
%   DESCRIPTION: Allows viewer to review video and then use the         %
%   imdistance tool to measure objects on the video.                    %
%                                                                       %
%   Video files which can be read in are .mp4 or .avi                   %         
%                                                                       %
%   Measurements on objects are straight lines only in this version.    %
%   User can select to save measurements tagged into 6 classes.         %
%   One can use 6 classes to record different types of objects or       %
%   different measurements on the same object e.g. length and width.    %
%                                                                       %
%   Measurements are recorded in pixels so you need to have calibrated  %
%   the video to real world distances in order to convert the data to   %
%   real world distances.                                               %
%                                                                       %
%                                                                       %
%   NOTES                                                               % 
%   This is a GUI driven program - ensure file                          %                   
%   MeasureObjectsOnVideo.fig is in same directory as this .m file      %
%   This program uses 'read videoObject' which Matlab advise is         % 
%   deprecated so code may need adjusting to work in versions of        %
%   Matlab beyond 2016b                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Begin initialization code - DO NOT EDIT
function varargout=MeasureObjectsOnVideo(varargin)

gui_Singleton=1;
gui_State=struct('gui_Name',         mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MeasureObjectsOnVideo_OpeningFcn, ...
                   'gui_OutputFcn',  @MeasureObjectsOnVideo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback=str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}]=gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes during object creation, after setting all properties.
function txtVideoFile_CreateFcn(hObject, eventdata, handles)
% Sets color of text box for file selection
if ispc && isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'));
    set(hObject,'BackgroundColor','white');
end


% --- Executes just before MeasureObjectsOnVideo is made visible.
function MeasureObjectsOnVideo_OpeningFcn...
    (hObject, eventdata, handles, varargin)
% Choose default command line output for MeasureObjectsOnVideo
handles.output=hObject;

% Set a flag that data have not been saved
handles.DataSaved=0;

% Set flag for video run status
set(handles.pushStop,'UserData','Stop');

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout=MeasureObjectsOnVideo_OutputFcn ...
    (hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1}=handles.output;

% % --- Executes during object creation, after setting all properties.
function sldSpeed_CreateFcn(hObject, eventdata, handles)
% 
% end

% END OF DO NOT EDIT ABOVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in pushSelectFile.
function pushSelectFile_Callback(hObject, eventdata, handles)
if(isempty(get(handles.txtVideoFile,'String')));
    % This is a new program instance so continue    
else
    % User has already loaded a file and is requesting to load a new one
    promptMessage=sprintf ...
        ('Loading a new video will mean any unsaved data will be lost');
    % Last option is the default
    button=questdlg ...
        (promptMessage, 'Warning', 'Continue', 'Cancel', 'Cancel');
      if strcmpi(button, 'Cancel')
          return; % Or break or continue
      else
      end
end
% Initialise the video
[ videoFileName,videoFilePath ]=uigetfile ...
    ({'*.mp4;*.avi'},'Select a video file');
    if(videoFilePath == 0)
        return;
    end
% Save filename and path of the video within the handles
inputVideoFile=[videoFilePath,videoFileName];
set(handles.txtVideoFile,'String',inputVideoFile);

% Acquire video
set(handles.figure1, 'pointer', 'watch');
drawnow;

videoObject=VideoReader(inputVideoFile);
% Display first frame
set(handles.txtVideoBox, 'Visible','off');
% NOTE read videoObject is deprecated and code may not work in versions of
% Matlab beyond 2016b
frameFirst=read(videoObject,1);
axes(handles.axes1);
imshow(frameFirst);

ok=0;
while ok == 0;
    startTime=inputdlg ...
    ('Please enter video start date and 24 h time as dd/MM/yyyy HH:mm:ss', ...
    'Start time',1);
    if isempty(startTime);
        % Leave ok as zero
    else
        try
            % Check valid time entered       
            datetime(startTime,'InputFormat','dd/MM/yyyy HH:mm:ss');
            ok=1;
        catch            
            % Invalid datetime format - leave ok as zero         
        end 
    end
end

% Convert to serial and save in handles collection
startTime=datetime(startTime,'InputFormat','dd/MM/yyyy HH:mm:ss');
handles.startTime=startTime;

% Display Frame Number and set action boxes on or off
set(handles.lblFrameCounter,'Enable','on');
set(handles.txtCurrentFrame,'Enable','on','String','1');
set(handles.txtNumberOfFrames,'Enable','on','String', ...
    ['  /  ',num2str(videoObject.NumberOfFrames)]);

% Update handles so other functions can access the videoObject and
% frameCounter and array to hold measured data
handles.videoObject=videoObject;
handles.frameCounter=1;
handles.videoSpeed=1;

% Preallocate array for measurements as
% Pixel distance of object; Whole, part or top of object; 
% Framenumber; Video Time; Time Obs recorded
% Times are serial
n=10000; % Preallocate memory - Unlikely we would ever manually 
% measure > this many objects
handles.Measurements=struct('Pixels',zeros(1,n),'Class',zeros(1,n), ...
    'Frame',zeros(1,n),'TimeObs',zeros(1,n),'TimeRecorded',zeros(1,n));
% Preallocate space for comments - needs separate structure because
% a comment may not be associated with a measured object
handles.TotComments=0;
handles.Comments=struct('Frame',zeros(1,n),'TimeObs',zeros(1,n)),'Comment';cell(1,n);

set(handles.figure1, 'pointer', 'arrow');
drawnow;

% Turn on and off button options
set(handles.lblPlaybackSpeed,'Enable','on');
set(handles.sldSpeed,'Enable','on');
set(handles.lblSpeed,'Enable','on');

set(handles.pushFwd,'Enable','on');
set(handles.sldSpeed,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');
set(handles.pushDelete,'Enable','off');
set(handles.pushComment,'Enable','on');

set(handles.pushSaveData,'Enable','off');
set(handles.pushSelectFile,'Enable','off');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on slider movement.
function sldSpeed_Callback(hObject, eventdata, handles)
Sp=round(get(handles.sldSpeed,'Value'),0);
set(handles.lblSpeed,'String', num2str(Sp,'%.0f')); 
  
% --- Executes on button press in pushFwd.
function pushFwd_Callback(hObject, eventdata, handles)

% Close figure 2 if it exists
if isfield(handles, 'figure2');
    % Must use delete here otherwise it calls the modified
    % CloseRequestFcn function
    delete(handles.figure2);
    handles=rmfield(handles, 'figure2');    
end

%Set flag to video running
set(handles.pushStop,'UserData','Run');

% Reset speed
handles.Speed=round(get(handles.sldSpeed,'Value'),0);

set(handles.lblPlaybackSpeed,'Enable','off');
set(handles.sldSpeed,'Enable','off');
set(handles.lblSpeed,'Enable','off');

set(handles.pushFwd,'Enable','off');
set(handles.pushStop,'Enable','on');
set(handles.pushBk,'Enable','off');
set(handles.sldSpeed,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');
set(handles.pushDelete,'Enable','off');
set(handles.pushComment,'Enable','off');

set(handles.pushSaveData,'Enable','off');
set(handles.pushSelectFile,'Enable','off');
set(handles.pushExit,'Enable','off');

% Save updates to guidata
guidata(hObject,handles);

videoObject=handles.videoObject;
axes(handles.axes1);

% Vector as start: step: stop
for frameCounter=handles.frameCounter: handles.Speed: ... 
        videoObject.NumberOfFrames
    if strcmp(get(handles.pushStop,'UserData'),'Run')
        % Update frame count 
        set(handles.txtCurrentFrame,'String',num2str(frameCounter));
        % Read video frame
        frame=read(videoObject,frameCounter);
        imshow(frame);
        drawnow; 
        % Add the current frame to the handles so we can pass to other 
        % functions to allow measurement using imtools   
        handles.frameCounter=frameCounter;
        handles.frame=frame;
        guidata(hObject,handles);
    else
        % Reset button status
        handles.fastFwd=1;
        handles.fastBk=1;

        % Set labels etc
        set(handles.lblPlaybackSpeed,'Enable','on');
        set(handles.sldSpeed,'Enable','on');
        set(handles.lblSpeed,'Enable','on');

        % Waits for measurements to be taken or other actions
        set(handles.pushFwd,'Enable','on');
        set(handles.pushStop,'Enable','off');
        set(handles.pushBk,'Enable','on');
        set(handles.sldSpeed,'Enable','on');

        set(handles.pushMeas,'Enable','on');
        set(handles.pushRecordClass1,'Enable','off');
        set(handles.txtClass1ObjectsCount,'Enable','on');
        set(handles.pushRecordClass2,'Enable','off');
        set(handles.txtClass2ObjectsCount,'Enable','on');
        set(handles.pushRecordClass3,'Enable','off');        
        set(handles.txtClass3ObjectsCount,'Enable','on');
        set(handles.pushRecordClass4,'Enable','off');
        set(handles.txtClass4ObjectsCount,'Enable','on');
        set(handles.pushRecordClass5,'Enable','off');
        set(handles.txtClass5ObjectsCount,'Enable','on');
        set(handles.pushRecordClass6,'Enable','off');        
        set(handles.txtClass6ObjectsCount,'Enable','on');           
        set(handles.lblTotalObjectsCount,'Enable','on');
        set(handles.txtTotalObjectsCount,'Enable','on');
        % handles.pushDelete,'Enable' state set after 1st data recorded
        set(handles.pushComment,'Enable','on');

        % handles.pushSaveData,'Enable' state set after 1st data recorded and Stop
        % video pushed
        TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));
        if TotObjs>0 
            set(handles.pushDelete,'Enable','on');
            set(handles.pushSaveData,'Enable','on');
        end

        set(handles.pushSelectFile,'Enable','on');
        set(handles.pushExit,'Enable','on');

        % Save updates to guidata
        guidata(hObject,handles);

        return;
    end
end

% Reached end of file
set(handles.pushFwd,'Enable','off');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');

set(handles.lblPlaybackSpeed,'Enable','on');
set(handles.sldSpeed,'Enable','on');
set(handles.lblSpeed,'Enable','on');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');

set(handles.pushComment,'Enable','off');

TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));
if TotObjs>0 
    set(handles.pushDelete,'Enable','on');
    set(handles.pushSaveData,'Enable','on');
end

set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushBk.
% Playback is slow - could be sped up by reading whole video
% as an array and we could then index each frame more quickly
% than using read video object directly - I guess this is why
% Matlab says read(videoObject) is deprecated.
function pushBk_Callback(hObject, eventdata, handles)
% Play video backwards

% Close figure 2 if it exists
if isfield(handles, 'figure2');
    % Must use delete here otherwise it calls the modified
    % CloseRequestFcn function
    delete(handles.figure2);
    handles=rmfield(handles, 'figure2');
end

%Set flag to video running
set(handles.pushStop,'UserData','Run');

% Reset speed 
handles.Speed=-1 * round(get(handles.sldSpeed,'Value'),0);

set(handles.lblPlaybackSpeed,'Enable','off');
set(handles.sldSpeed,'Enable','off');
set(handles.lblSpeed,'Enable','off');

set(handles.pushFwd,'Enable','off');
set(handles.pushStop,'Enable','on');
set(handles.pushBk,'Enable','off');
set(handles.sldSpeed,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');

set(handles.pushDelete,'Enable','off');
set(handles.pushComment,'Enable','off');
set(handles.pushSaveData,'Enable','off');
set(handles.pushSelectFile,'Enable','off');
set(handles.pushExit,'Enable','off');

% Save updates to guidata
guidata(hObject,handles);
    
videoObject=handles.videoObject;
axes(handles.axes1);

% Vector as start: step: stop - remember this is to run video backwards
for frameCounter=handles.frameCounter:handles.Speed:1;
    if strcmp(get(handles.pushStop,'UserData'),'Run')
        % Update frame count 
        set(handles.txtCurrentFrame,'String',num2str(frameCounter));
        % Read video frame
        frame=read(videoObject,frameCounter);
        imshow(frame);
        drawnow; 
        % Add the current frame to the handles so we can pass to other 
        % functions to allow measurement using imtools   
        handles.frameCounter=frameCounter;
        handles.frame=frame;
        guidata(hObject,handles);
    else
        % Reset button status
        handles.fastFwd=1;
        handles.fastBk=1;

        % Set labels etc
        set(handles.lblPlaybackSpeed,'Enable','on');
        set(handles.sldSpeed,'Enable','on');
        set(handles.lblSpeed,'Enable','on');

        % Waits for measurements to be taken or other actions
        set(handles.pushFwd,'Enable','on');
        set(handles.pushStop,'Enable','off');
        set(handles.pushBk,'Enable','on');
        set(handles.sldSpeed,'Enable','on');

        set(handles.pushMeas,'Enable','on');
        set(handles.pushRecordClass1,'Enable','off');        
        set(handles.txtClass1ObjectsCount,'Enable','on');
        set(handles.pushRecordClass2,'Enable','off');
        set(handles.txtClass2ObjectsCount,'Enable','on');
        set(handles.pushRecordClass3,'Enable','off');
        set(handles.txtClass3ObjectsCount,'Enable','on');
        set(handles.pushRecordClass4,'Enable','off');
        set(handles.txtClass4ObjectsCount,'Enable','on');
        set(handles.pushRecordClass5,'Enable','off');
        set(handles.txtClass5ObjectsCount,'Enable','on');
        set(handles.pushRecordClass6,'Enable','off');
        set(handles.txtClass6ObjectsCount,'Enable','on');
        set(handles.lblTotalObjectsCount,'Enable','on');
        set(handles.txtTotalObjectsCount,'Enable','on');
        % handles.pushDelete,'Enable' state set after 1st data recorded
        set(handles.pushComment,'Enable','on');

        % handles.pushSaveData,'Enable' state set after 1st data recorded and Stop
        % video pushed
        TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));
        if TotObjs>0 
            set(handles.pushDelete,'Enable','on');
            set(handles.pushSaveData,'Enable','on');
        end

        set(handles.pushSelectFile,'Enable','on');
        set(handles.pushExit,'Enable','on');

        % Save updates to guidata
        guidata(hObject,handles);

        return;
    end;
end;

% Reached start of file

set(handles.lblPlaybackSpeed,'Enable','on');
set(handles.sldSpeed,'Enable','on');
set(handles.lblSpeed,'Enable','on');

set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');
set(handles.pushComment,'Enable','off');

TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));
if TotObjs>0 
    set(handles.pushDelete,'Enable','on');
    set(handles.pushSaveData,'Enable','on');
end

set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);


% --- Executes on button press in pushStop.
function pushStop_Callback(hObject, eventdata, handles)

% This is the only approach which seems to work - putting a flag
% for video stop start in the handles is not picked up
% in the run video fwd and bwd routines but polling the stop
% button UserData works

set(handles.pushStop,'UserData','Stop');
% Save updates to guidata
guidata(hObject,handles);

  
% --- Executes on button press in pushMeas.
function pushMeas_Callback(hObject, eventdata, handles)
% This freezes the video preview and opens a 
% figure window showing the current image frame
% where object sizes can be measured
  
% Check if figure 2 already exists
if isfield(handles, 'figure2');
    % Do not create a new figure but change existing dist line color    
else
    % Create a new figure showing the current frame
    pos = get(0,'MonitorPositions');
    % If single monitor return 1x4, if twin 2x4
    % as left bottom width height in pixels
    sz = size(pos);
    % Check if dual or single monitor setup
    if (sz(1) > 1) % twin
        figure2 = figure('OuterPosition',pos(1,:), ...
            'CloseRequestFcn',@(fig, event) my_closereq(fig));
    else           % single
        figure2 = figure('OuterPosition',pos(2,:), ...
            'CloseRequestFcn',@(fig, event) my_closereq(fig));
    end
    set(figure2,'NumberTitle','off','Name','Measure object');
    set(figure2,'MenuBar','none','Toolbar','figure');
    % Turn of some of the tools to prevent later errors
    a=findall(figure2);
    b=findall(a,'ToolTipString','New Figure');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Open File');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Edit Plot');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Rotate 3D');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Data Cursor');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Brush/Select Data');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Link Plot');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Insert Colorbar');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Insert Legend');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Hide Plot Tools');
    set(b,'Visible','off');
    b=findall(a,'ToolTipString','Show Plot Tools and Dock Figure');
    set(b,'Visible','off');
    
    % Save in handles to allow checking if this fig exists later on
    handles.figure2=figure2;       
    % The figure is maximised but we can still zoom in using the toolbar
    imshow(handles.frame, 'Border','tight','InitialMagnification','fit');
    % It would be good to disable some of the tools which can 
    % cause errors later on if used by user
    % I can do this in a clean new figure but cannot work out how
    % to get it to work in a figure created programatically
end
% 
% Make sure figure 2 has focus
figure(handles.figure2);
% Add distance line
dist=imdistline;
handles.dist=dist;
% Distance label is nice but obscures small measurements
api=iptgetapi(dist);
api.setLabelVisible(false);  

set(handles.pushFwd,'Enable','off');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','off');
set(handles.sldSpeed,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','on');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','on');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','on');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','on');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','on');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','on');
set(handles.txtClass6ObjectsCount,'Enable','on');
set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');
% handles.pushDelete,'Enable' state set after 1st data recorded
set(handles.pushComment,'Enable','off');
% handles.pushSaveData,'Enable' state set after 1st data recorded
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushRecordClass1 Object
function pushRecordClass1_Callback(hObject, eventdata, handles)
% Records the current line distance as a whole object
% along with the current framenumber and video time

% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
% Increment class 1 objs count
TotClass1Objs=TotClass1Objs + 1;
set(handles.txtClass1ObjectsCount,'String', num2str(TotClass1Objs)); 
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));
% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=1;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','1');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);


% --- Executes on button press in pushRecordClass2.
function pushRecordClass2_Callback(hObject, eventdata, handles)
% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
% Increment class 2 objs count
TotClass2Objs=TotClass2Objs + 1;
set(handles.txtClass2ObjectsCount,'String', num2str(TotClass2Objs)); 
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=2;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','2');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushRecordClass3.
function pushRecordClass3_Callback(hObject, eventdata, handles)
% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));

% Increment class 3 objs count
TotClass3Objs=TotClass3Objs + 1;
set(handles.txtClass3ObjectsCount,'String', num2str(TotClass3Objs));
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=3;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','3');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushRecordClass4.
function pushRecordClass4_Callback(hObject, eventdata, handles)
% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
% Increment class 4 objs count
TotClass4Objs=TotClass4Objs + 1;
set(handles.txtClass4ObjectsCount,'String', num2str(TotClass4Objs));
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=4;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','4');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushRecordClass5.
function pushRecordClass5_Callback(hObject, eventdata, handles)
% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
% Increment class 3 objs count
TotClass5Objs=TotClass5Objs + 1;
set(handles.txtClass5ObjectsCount,'String', num2str(TotClass5Objs));
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=5;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','5');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushRecordClass6.
function pushRecordClass6_Callback(hObject, eventdata, handles)
% Change distance line color to indicate it has been logged and extract
% distance in pixels
api=iptgetapi(handles.dist);
api.setColor('y');
pixelLength=api.getDistance;
% Read the existing number of objects recorded    
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
% Increment class 3 objs count
TotClass6Objs=TotClass6Objs + 1;
set(handles.txtClass6ObjectsCount,'String', num2str(TotClass6Objs));
% Compute total number of objects counted so far
TotObjs=TotClass1Objs + TotClass2Objs + TotClass3Objs + ...
    TotClass4Objs + TotClass5Objs + TotClass6Objs;
set(handles.txtTotalObjectsCount,'String', num2str(TotObjs));

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=pixelLength;
handles.Measurements.Class(TotObjs)=6;
handles.Measurements.Frame(TotObjs)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Measurements.TimeObs(TotObjs)=obsTime;    
handles.Measurements.TimeRecorded(TotObjs)=now;

% Update the last measurement boxes
set(handles.txtLastDist,'String',num2str(pixelLength));
set(handles.txtLastClass,'String','6');

%Set flag to indicate new data in memory
handles.DataSaved=0;

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');

set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushDelete,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSaveData,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushDelete.
function pushDelete_Callback(hObject, eventdata, handles)

% Check there is at least one data line to delete

% Read the existing number of objects recorded    
TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));

if TotObjs < 1;
    warndlg('There are no data to delete') ;
else
    
% Read the existing number of objects recorded by class
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
    
%Update the counter boxes
if strcmp(get(handles.txtLastClass,'String'),'1');
    TotClass1Objs=TotClass1Objs-1;
    set(handles.txtClass1ObjectsCount,'String',TotClass1Objs);
elseif strcmp(get(handles.txtLastClass,'String'),'2');
    TotClass2Objs=TotClass2Objs-1;
    set(handles.txtClass2ObjectsCount,'String',TotClass2Objs);
elseif strcmp(get(handles.txtLastClass,'String'),'3');
    TotClass3Objs=TotClass3Objs-1;
    set(handles.txtClass3ObjectsCount,'String',TotClass3Objs);
elseif strcmp(get(handles.txtLastClass,'String'),'4');
    TotClass4Objs=TotClass4Objs-1;
    set(handles.txtClass4ObjectsCount,'String',TotClass4Objs);
elseif strcmp(get(handles.txtLastClass,'String'),'5');
    TotClass5Objs=TotClass5Objs-1;
    set(handles.txtClass5ObjectsCount,'String',TotClass5Objs);
elseif strcmp(get(handles.txtLastClass,'String'),'6');
    TotClass6Objs=TotClass6Objs-1;
    set(handles.txtClass6ObjectsCount,'String',TotClass6Objs);
end

% Update the measurements array
handles.Measurements.Pixels(TotObjs)=0;
handles.Measurements.Class(TotObjs)=0;
handles.Measurements.Frame(TotObjs)=0;
handles.Measurements.TimeObs(TotObjs)=0;
handles.Measurements.TimeRecorded(TotObjs)=0;

% Save updates to guidata
guidata(hObject,handles);   

% Update the pointer in the data array
TotObjs=TotObjs -1;
set(handles.txtTotalObjectsCount,'String', TotObjs);

% Trap for 0 index because Measurements array begins at 1
if TotObjs == 0
    set(handles.txtLastDist,'String','0');
    set(handles.txtLastClass,'String','0');
    set(handles.pushDelete,'Enable','off');
    set(handles.pushSaveData,'Enable','off');
    return;
else
    % Update the measurement boxes to value before one just deleted
    set(handles.txtLastDist,'String', ...
        num2str(handles.Measurements.Pixels(TotObjs)));
    set(handles.txtLastClass,'String', ...
        num2str(handles.Measurements.Class(TotObjs)));
    set(handles.pushDelete,'Enable','on');
end

% Turn options on/off
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','off');
set(handles.lblTotalObjectsCount,'Enable','off');
set(handles.txtTotalObjectsCount,'Enable','off');

set(handles.lblLastDist,'Enable','on');
set(handles.txtLastDist,'Enable','on');
set(handles.lblLastClass,'Enable','on');
set(handles.txtLastClass,'Enable','on');
set(handles.pushComment,'Enable','on');
set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');
    
% Save updates to guidata
guidata(hObject,handles);
end

% --- Executes on button press in pushComment.
function pushComment_Callback(hObject, eventdata, handles)
% hObject    handle to pushComment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Turn options on/off
set(handles.pushFwd,'Enable','off');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','off');
set(handles.sldSpeed,'Enable','off');

set(handles.pushMeas,'Enable','off');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','off');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','off');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','off');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','off');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','off');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','off');

set(handles.lblTotalObjectsCount,'Enable','off');
set(handles.txtTotalObjectsCount,'Enable','off');

set(handles.lblLastDist,'Enable','off');
set(handles.txtLastDist,'Enable','off');
set(handles.lblLastClass,'Enable','off');
set(handles.txtLastClass,'Enable','off');
set(handles.pushDelete,'Enable','off');
set(handles.pushComment,'Enable','off');
set(handles.pushSaveData,'Enable','off');
set(handles.pushSelectFile,'Enable','off');
set(handles.pushExit,'Enable','off');

prompt = ('Enter comment which will be saved with frame and timestamp.');
dlg_title = 'Input comment';
str = inputdlg(prompt,dlg_title);

set(handles.figure1, 'pointer', 'watch');
    drawnow;
    
if isempty(str)
    %Do nothing
else
    
    handles.TotComments=handles.TotComments+1;
    handles.Comments.Comment(handles.TotComments)=str;
    
end

handles.Comments.Frame(handles.TotComments)=handles.frameCounter;
% Tried to use datetime functions but cannot get to work so use serial
% where time elapsed is fraction of a day - 86400 s per day
elapsedTime=handles.frameCounter/(handles.videoObject.framerate*86400);
obsTime=datenum(handles.startTime)+elapsedTime;
handles.Comments.TimeObs(handles.TotComments)=obsTime;    

% Waits for measurements to be taken or other actions
set(handles.pushFwd,'Enable','on');
set(handles.pushStop,'Enable','off');
set(handles.pushBk,'Enable','on');
set(handles.sldSpeed,'Enable','on');

set(handles.pushMeas,'Enable','on');
set(handles.pushRecordClass1,'Enable','off');
set(handles.txtClass1ObjectsCount,'Enable','on');
set(handles.pushRecordClass2,'Enable','off');
set(handles.txtClass2ObjectsCount,'Enable','on');
set(handles.pushRecordClass3,'Enable','off');
set(handles.txtClass3ObjectsCount,'Enable','on');
set(handles.pushRecordClass4,'Enable','off');
set(handles.txtClass4ObjectsCount,'Enable','on');
set(handles.pushRecordClass5,'Enable','off');
set(handles.txtClass5ObjectsCount,'Enable','on');
set(handles.pushRecordClass6,'Enable','off');
set(handles.txtClass6ObjectsCount,'Enable','on');
set(handles.lblTotalObjectsCount,'Enable','on');
set(handles.txtTotalObjectsCount,'Enable','on');
set(handles.pushComment,'Enable','on');

TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));
if TotObjs>0 
    set(handles.pushDelete,'Enable','on');
    set(handles.pushSaveData,'Enable','on');
end

set(handles.pushSelectFile,'Enable','on');
set(handles.pushExit,'Enable','on');

set(handles.figure1, 'pointer', 'arrow');
    drawnow;

% Save updates to guidata
guidata(hObject,handles);


% --- Executes on button press in pushSaveData.
function pushSaveData_Callback(hObject, eventdata, handles)

[saveFileName,saveFilePath]=uiputfile({'*.txt'},'Select a file to save');

if(saveFilePath == 0)
   return;
end

set(handles.figure1, 'pointer', 'watch');
drawnow;

saveFile=[saveFilePath,saveFileName];

% Read video file name
videoFile=get(handles.txtVideoFile,'String');
% Read when measurements recorded - start
measureStart=datestr(handles.Measurements.TimeRecorded(1));

fid=fopen(saveFile, 'wt') ;

% \t=tab   \n new line %s string
fprintf(fid, '%s \t%s\n', 'Comments on video file ', ...
    videoFile);

fprintf(fid, '%s \t%s \t\t\t%s\n','Video','Video','Comment');
fprintf(fid, '%s \t%s \n','frame','time');

for counter=1:handles.TotComments   
    fprintf(fid, '%i \t%s \t%s\n', ...
    handles.Comments.Frame(counter), ...
    datestr(handles.Comments.TimeObs(counter)), ...    
    handles.Comments.Comment{counter}); % Have to use curly brackets for 
                                        % cell array
end

% Read the existing number of objects recorded by class
TotClass1Objs=str2num(get(handles.txtClass1ObjectsCount,'String'));
TotClass2Objs=str2num(get(handles.txtClass2ObjectsCount,'String'));
TotClass3Objs=str2num(get(handles.txtClass3ObjectsCount,'String'));
TotClass4Objs=str2num(get(handles.txtClass4ObjectsCount,'String'));
TotClass5Objs=str2num(get(handles.txtClass5ObjectsCount,'String'));
TotClass6Objs=str2num(get(handles.txtClass6ObjectsCount,'String'));
TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));

fprintf(fid,'\n');
fprintf(fid, '%s\n', 'Object measurements');
fprintf(fid, '%s \t%s\n\n', 'Measurements recorded on', measureStart);
fprintf(fid, '%s \t\t%i\n','Count class 1 objects',TotClass1Objs);
fprintf(fid, '%s \t\t%i\n','Count class 2 objects',TotClass2Objs);
fprintf(fid, '%s \t\t%i\n','Count class 3 objects',TotClass3Objs);
fprintf(fid, '%s \t\t%i\n','Count class 4 objects',TotClass4Objs);
fprintf(fid, '%s \t\t%i\n','Count class 5 objects',TotClass5Objs);
fprintf(fid, '%s \t\t%i\n','Count class 6 objects',TotClass6Objs);
fprintf(fid, '%s \t\t\t%i\n\n','Count objects',TotObjs);
fprintf(fid, '%s \t\t%s \t\t\t%s \t%s\n','Video','Video','Dist','Class');
fprintf(fid, '%s \t\t%s \t\t\t%s \t%s\n','frame','time','pix','');

for counter=1:TotObjs;    
    dist = round(handles.Measurements.Pixels(counter),0);
    fprintf(fid, '%i \t\t%s \t%i \t%i \n', ...
    handles.Measurements.Frame(counter), ...
    datestr(handles.Measurements.TimeObs(counter)), ...  
    dist, ...
    handles.Measurements.Class(counter));
          
end
fclose(fid);

% Set a flag to indicate data saved at least once
handles.DataSaved=1;

set(handles.figure1, 'pointer', 'arrow');
drawnow;

% Save updates to guidata
guidata(hObject,handles);

% --- Executes on button press in pushExit.
function pushExit_Callback(hObject, eventdata, handles)

% Read the existing number of objects recorded    
TotObjs=str2num(get(handles.txtTotalObjectsCount,'String'));

if (TotObjs > 0) && (handles.DataSaved==0)
    % There is some new data in memory which has not been saved
    promptMessage=sprintf('There are unsaved data which will be lost');
    % Last option is the default
    button=questdlg(promptMessage, 'Warning', 'Exit', 'Cancel', 'Cancel');
      if strcmpi(button, 'Cancel')
        return;
      end
end

% Check that Figure 2 is not still open
if isfield(handles, 'figure2');
    % Must use delete here otherwise it calls the modified
    % CloseRequestFcn function
    delete(handles.figure2);
    handles=rmfield(handles, 'figure2');
end

% Close gui
delete(handles.figure1)

%% Prevent user closing figures with top right cross - if they do
%% causes errors with program
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
% delete(hObject);

% This handles if the user tries to shut the measure objects window
% using the top right icon (which will cause an error) but this also
% gets called when we try and close the figure
function my_closereq(fig)
    msgbox(['This button is deliberately disabled. Close the Measure ' ...
    'Objects window by pressing Fwd or Bkd on the video play controls.' ...
    ' If these are greyed out, you probably need to save a measurement first.'],...
    'Warning', 'warning');

            
