function varargout = PlaybackGUI(varargin)
% PLAYBACKGUI MATLAB code for PlaybackGUI.fig
%      PLAYBACKGUI, by itself, creates a new PLAYBACKGUI or raises the existing
%      singleton*.
%
%      H = PLAYBACKGUI returns the handle to a new PLAYBACKGUI or the handle to
%      the existing singleton*.
%
%      PLAYBACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAYBACKGUI.M with the given input arguments.
%
%      PLAYBACKGUI('Property','Value',...) creates a new PLAYBACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlaybackGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlaybackGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlaybackGUI

% Last Modified by GUIDE v2.5 30-Sep-2012 11:40:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlaybackGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PlaybackGUI_OutputFcn, ...
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


% --- Executes just before PlaybackGUI is made visible.
function PlaybackGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlaybackGUI (see VARARGIN)

% Choose default command line output for PlaybackGUI
handles.output = hObject;

% Joint information.
handles.namesJoints = {'WST' 'LHY' 'LHR' 'LHP' 'LKN' 'LAP' 'LAR' 'RHY' 'RHR' 'RHP' 'RKN' 'RAP' 'RAR' 'LSP' 'LSR' 'LSY' 'LEB' 'RSP' 'RSR' 'RSY' 'REB'};
handles.arenaJoints.all    = [ 1, 2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
handles.openRaveJoints.all = [ 5, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,  9, 10, 11, 12, 16, 17, 18, 19];
handles.arenaJoints.WST = 1;  handles.openRaveJoints.WST = 5;
handles.arenaJoints.LHY = 2;  handles.openRaveJoints.LHY = 23;
handles.arenaJoints.LHR = 3;  handles.openRaveJoints.LHR = 24;
handles.arenaJoints.LHP = 4;  handles.openRaveJoints.LHP = 25;
handles.arenaJoints.LKN = 5;  handles.openRaveJoints.LKN = 26;
handles.arenaJoints.LAP = 6;  handles.openRaveJoints.LAP = 27;
handles.arenaJoints.LAR = 7;  handles.openRaveJoints.LAR = 28;
handles.arenaJoints.RHY = 8;  handles.openRaveJoints.RHY = 29;
handles.arenaJoints.RHR = 9;  handles.openRaveJoints.RHR = 30;
handles.arenaJoints.RHP = 10; handles.openRaveJoints.RHP = 31;
handles.arenaJoints.RKN = 11; handles.openRaveJoints.RKN = 32;
handles.arenaJoints.RAP = 12; handles.openRaveJoints.RAP = 33;
handles.arenaJoints.RAR = 13; handles.openRaveJoints.RAR = 34;
handles.arenaJoints.LSP = 14; handles.openRaveJoints.LSP = 9;
handles.arenaJoints.LSR = 15; handles.openRaveJoints.LSR = 10;
handles.arenaJoints.LSY = 16; handles.openRaveJoints.LSY = 11;
handles.arenaJoints.LEB = 17; handles.openRaveJoints.LEB = 12;
handles.arenaJoints.RSP = 18; handles.openRaveJoints.RSP = 16;
handles.arenaJoints.RSR = 19; handles.openRaveJoints.RSR = 17;
handles.arenaJoints.RSY = 20; handles.openRaveJoints.RSY = 18;
handles.arenaJoints.REB = 21; handles.openRaveJoints.REB = 19;

% Load robotid and data if possible
if evalin('base','exist(''robotID'',''var'')')
    handles.robotID = evalin('base','robotID');
end

if evalin('base','exist(''majorFrames'',''var'')')
    handles.majorFrames = evalin('base','majorFrames');
    handles = generateMinorFrames(handles);
end

handles.playing = 0;
handles.currentFrame = 1;

% Creat animation timer.
handles.timer1 = timer('TimerFcn', {@timer_Callback,hObject}, ...
            'ExecutionMode', 'fixedSpacing', ...
            'Period', .01);

% Update handles structure
guidata(hObject, handles);

start(handles.timer1);

% UIWAIT makes PlaybackGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PlaybackGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%
% --- Executes on button press in LoadRobot.
function LoadRobot_Callback(hObject, eventdata, handles)
% hObject    handle to LoadRobot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if evalin('base','exist(''robotID'',''var'')')
    evalin('base','orBodyDestroy(robotID)')
end
robot_file = get(handles.RobotFile,'String');
handles.robotID = orEnvCreateRobot('Hubo',robot_file);
assignin('base','robotID',handles.robotID)
% Curl fingers
curl_angle = 0.8;
for i=[35:46 50:61]
    orBodySetJointValues(handles.robotID,curl_angle,i)
end
for i=[47:49 62:64]
    orBodySetJointValues(handles.robotID,-curl_angle,i)
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function RobotFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RobotFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
% --- Executes on button press in LoadDance.
function LoadDance_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dance_file = get(handles.DanceFile, 'String');
handles.majorFrames = load(dance_file);
% Save to workspace
assignin('base','majorFrames',handles.majorFrames)
handles = generateMinorFrames(handles);
guidata(hObject,handles);

function [handles] = generateMinorFrames(handles)
% Smooth data
temp = handles.majorFrames;
for i=1:numel(handles.openRaveJoints.all)
    temp(:,i) = smooth(temp(:,i));
end
% Upsample from 10Hz to 100Hz.
handles.minorFrames = interp1(temp,1:0.1:size(temp,1));
% Save upsampled data
dlmwrite('3_Upsampled.txt',handles.minorFrames,'delimiter','\t');
% Convert to Hubo form and save.
ConvertJaemiToHuboPlus('3_Upsampled.txt');


% --- Executes during object creation, after setting all properties.
function DanceFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DanceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
% --- The function that makes the animation
function timer_Callback(obj, event, hObject)
%disp(handles)
% Load global values.
handles = guidata(hObject);
% Return if dance has not bee loaded yet.
if ~hasfield(handles,'minorFrames')
    return
end
% Play movie
if handles.playing
    gotoFrame(hObject, handles.currentFrame + 1);
    handles = guidata(hObject);
    % Stop movie if it reaches the end.
    if handles.currentFrame == size(handles.minorFrames, 1)
        handles.playing = 0;
    end
end
guidata(hObject, handles);

% --- The function that calls the function makes the animation
function gotoFrame(hObject, frameNumber)
handles = guidata(hObject);
if frameNumber < 1
    frameNumber = 1;
elseif frameNumber > size(handles.minorFrames, 1)
    frameNumber = size(handles.minorFrames, 1);
end
handles.currentFrame = frameNumber;
% Update frame text display
set(handles.MinorFrame,'String',num2str(handles.currentFrame));
set(handles.MajorFrame,'String',num2str(MinorToMajorFrame(handles.currentFrame)));


% Array :  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21
% Joints: WST LHY LHR LHP LKN LAP LAR RHY RHR RHP RKN RAP RAR LSP LSR LSY LEB RSP RSR RSY REB
handles.openRaveJoints.all = [ 5, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,  9, 10, 11, 12, 16, 17, 18, 19];

% Display joint angles
% TODO: Waist
%set(handles.LSPA,'String',num2str(handles.MinorFrames(frameNumber,19);
% Left arm
set(handles.LSPA,'String',num2str(handles.minorFrames(frameNumber,14)));
set(handles.LSRA,'String',num2str(handles.minorFrames(frameNumber,15)));
set(handles.LSYA,'String',num2str(handles.minorFrames(frameNumber,16)));
set(handles.LEBA,'String',num2str(handles.minorFrames(frameNumber,17)));
% Right arm
set(handles.RSPA,'String',num2str(handles.minorFrames(frameNumber,18)));
set(handles.RSRA,'String',num2str(handles.minorFrames(frameNumber,19)));
set(handles.RSYA,'String',num2str(handles.minorFrames(frameNumber,20)));
set(handles.REBA,'String',num2str(handles.minorFrames(frameNumber,21)));
guidata(hObject, handles);
updateOpenRAVE(hObject);

% --- The function that makes the animation
function [handles] = updateOpenRAVE(hObject)
handles = guidata(hObject);
% Update OpenRAVE model
angles = handles.minorFrames(handles.currentFrame,:).*pi/180;
orBodySetJointValues(handles.robotID,angles,handles.openRaveJoints.all);
guidata(hObject, handles);

%%
% --- Executes on button press in GoTo.
function GoTo_Callback(hObject, eventdata, handles)
% hObject    handle to GoTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
frame = str2num(get(handles.MajorFrame,'String'));
if numel(frame) == 0
    msgbox('Not recognized as a number.')
    guidata(hObject,handles);
    return
end
gotoFrame(hObject,MajorToMinorFrame(frame))


function MajorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to MajorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MajorFrame as text
%        str2double(get(hObject,'String')) returns contents of MajorFrame as a double


% --- Executes during object creation, after setting all properties.
function MajorFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MajorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to MinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinorFrame as text
%        str2double(get(hObject,'String')) returns contents of MinorFrame as a double


% --- Executes during object creation, after setting all properties.
function MinorFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




%%

% --- Executes on button press in PrevMajorFrame.
function PrevMajorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to PrevMajorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gotoFrame(hObject, MajorToMinorFrame(MinorToMajorFrame(handles.currentFrame)-1));

% --- Executes on button press in PrevMinorFrame.
function PrevMinorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to PrevMinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gotoFrame(hObject, handles.currentFrame - 1);

% --- Executes on button press in PlayPause.
function PlayPause_Callback(hObject, eventdata, handles)
% hObject    handle to PlayPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.playing = ~handles.playing;
guidata(hObject,handles);

% --- Executes on button press in NextMinorFrame.
function NextMinorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NextMinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gotoFrame(hObject, handles.currentFrame + 1);

% --- Executes on button press in NextMajorFrame.
function NextMajorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NextMajorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gotoFrame(hObject, MajorToMinorFrame(MinorToMajorFrame(handles.currentFrame) + 1));



%%
function FrameA_Callback(hObject, eventdata, handles)
% hObject    handle to FrameA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameA as text
%        str2double(get(hObject,'String')) returns contents of FrameA as a double


% --- Executes during object creation, after setting all properties.
function FrameA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FrameB_Callback(hObject, eventdata, handles)
% hObject    handle to FrameB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameB as text
%        str2double(get(hObject,'String')) returns contents of FrameB as a double


% --- Executes during object creation, after setting all properties.
function FrameB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%


% --- Executes on button press in CheckLSPA.
function CheckLSPA_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLSPA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckLSPA



%%

function LSP_Callback(hObject, eventdata, handles)
% hObject    handle to LSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSP as text
%        str2double(get(hObject,'String')) returns contents of LSP as a double


% --- Executes during object creation, after setting all properties.
function LSP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LSR_Callback(hObject, eventdata, handles)
% hObject    handle to LSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSR as text
%        str2double(get(hObject,'String')) returns contents of LSR as a double


% --- Executes during object creation, after setting all properties.
function LSR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LSY_Callback(hObject, eventdata, handles)
% hObject    handle to LSY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSY as text
%        str2double(get(hObject,'String')) returns contents of LSY as a double


% --- Executes during object creation, after setting all properties.
function LSY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LEB_Callback(hObject, eventdata, handles)
% hObject    handle to LEB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEB as text
%        str2double(get(hObject,'String')) returns contents of LEB as a double


% --- Executes during object creation, after setting all properties.
function LEB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function LSPA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSPA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LSRA_Callback(hObject, eventdata, handles)
% hObject    handle to LSRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSRA as text
%        str2double(get(hObject,'String')) returns contents of LSRA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.LSR);


% --- Executes during object creation, after setting all properties.
function LSRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LSYA_Callback(hObject, eventdata, handles)
% hObject    handle to LSYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSYA as text
%        str2double(get(hObject,'String')) returns contents of LSYA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.LSY);


% --- Executes during object creation, after setting all properties.
function LSYA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LEBA_Callback(hObject, eventdata, handles)
% hObject    handle to LEBA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEBA as text
%        str2double(get(hObject,'String')) returns contents of LEBA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.LEB);

% --- Executes during object creation, after setting all properties.
function LEBA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEBA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function RSPA_Callback(hObject, eventdata, handles)
% hObject    handle to RSPA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSPA as text
%        str2double(get(hObject,'String')) returns contents of RSPA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.RSP);

% --- Executes during object creation, after setting all properties.
function RSPA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSPA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RSRA_Callback(hObject, eventdata, handles)
% hObject    handle to RSRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSRA as text
%        str2double(get(hObject,'String')) returns contents of RSRA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.RSR);

% --- Executes during object creation, after setting all properties.
function RSRA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSRA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RSYA_Callback(hObject, eventdata, handles)
% hObject    handle to RSYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSYA as text
%        str2double(get(hObject,'String')) returns contents of RSYA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.RSY);

% --- Executes during object creation, after setting all properties.
function RSYA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSYA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function REBA_Callback(hObject, eventdata, handles)
% hObject    handle to REBA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REBA as text
%        str2double(get(hObject,'String')) returns contents of REBA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.REB);

% --- Executes during object creation, after setting all properties.
function REBA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REBA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckLSPB.
function CheckLSPB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckLSPB



function LSPB_Callback(hObject, eventdata, handles)
% hObject    handle to LSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSPB as text
%        str2double(get(hObject,'String')) returns contents of LSPB as a double


% --- Executes during object creation, after setting all properties.
function LSPB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckLSRB.
function CheckLSRB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckLSRB



function LSRB_Callback(hObject, eventdata, handles)
% hObject    handle to LSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSRB as text
%        str2double(get(hObject,'String')) returns contents of LSRB as a double


% --- Executes during object creation, after setting all properties.
function LSRB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckLSYB.
function CheckLSYB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckLSYB



function LSYB_Callback(hObject, eventdata, handles)
% hObject    handle to LSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSYB as text
%        str2double(get(hObject,'String')) returns contents of LSYB as a double


% --- Executes during object creation, after setting all properties.
function LSYB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckLEBB.
function CheckLEBB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckLEBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckLEBB



function LEBB_Callback(hObject, eventdata, handles)
% hObject    handle to LEBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LEBB as text
%        str2double(get(hObject,'String')) returns contents of LEBB as a double


% --- Executes during object creation, after setting all properties.
function LEBB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LEBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in CheckRSPB.
function CheckRSPB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckRSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckRSPB



function RSPB_Callback(hObject, eventdata, handles)
% hObject    handle to RSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSPB as text
%        str2double(get(hObject,'String')) returns contents of RSPB as a double


% --- Executes during object creation, after setting all properties.
function RSPB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSPB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckRSRB.
function CheckRSRB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckRSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckRSRB



function RSRB_Callback(hObject, eventdata, handles)
% hObject    handle to RSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSRB as text
%        str2double(get(hObject,'String')) returns contents of RSRB as a double


% --- Executes during object creation, after setting all properties.
function RSRB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSRB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckRSYB.
function CheckRSYB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckRSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckRSYB



function RSYB_Callback(hObject, eventdata, handles)
% hObject    handle to RSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RSYB as text
%        str2double(get(hObject,'String')) returns contents of RSYB as a double


% --- Executes during object creation, after setting all properties.
function RSYB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RSYB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CheckREBB.
function CheckREBB_Callback(hObject, eventdata, handles)
% hObject    handle to CheckREBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CheckREBB



function REBB_Callback(hObject, eventdata, handles)
% hObject    handle to REBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of REBB as text
%        str2double(get(hObject,'String')) returns contents of REBB as a double


% --- Executes during object creation, after setting all properties.
function REBB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to REBB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in apply_a.
function apply_a_Callback(hObject, eventdata, handles)
% hObject    handle to apply_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Interpolate.
function Interpolate_Callback(hObject, eventdata, handles)
% hObject    handle to Interpolate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(timerfindall());
% Hint: delete(hObject) closes the figure
delete(hObject);



function LSPA_Callback(hObject, eventdata, handles)
% hObject    handle to LSPA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LSPA as text
%        str2double(get(hObject,'String')) returns contents of LSPA as a double
angle = str2double(get(hObject,'String'));
angle = angle.*pi/180;
orBodySetJointValues(handles.robotID,angle,handles.openRaveJoints.LSP);

