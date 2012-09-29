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

% Last Modified by GUIDE v2.5 28-Sep-2012 22:52:53

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

% Array :  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21
% Joints: WST LHY LHR LHP LKN LAP LAR RHY RHR RHP RKN RAP RAR LSP LSR LSY LEB RSP RSR RSY REB
handles.joints = [ 5, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,  9, 10, 11, 12, 16, 17, 18, 19];

% Load robotid and data if possible
if evalin('base','exist(''RobotId'',''var'')')
    handles.RobotId = evalin('base','RobotId');
end

if evalin('base','exist(''MajorFrames'',''var'')')
    handles.MajorFrames = evalin('base','MajorFrames');
end

% Update handles structure
guidata(hObject, handles);

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
if evalin('base','exist(''robotid'',''var'')')
    evalin('base','orBodyDestroy(robotid)')
end
robot_file = get(handles.RobotFile,'String');
handles.robotid = orEnvCreateRobot('Hubo',robot_file);
assignin('base','robotid',handles.robotid)
% Curl fingers
curl_angle = 0.8;
for i=[35:46 50:61]
    orBodySetJointValues(handles.robotid,curl_angle,i)
end
for i=[47:49 62:64]
    orBodySetJointValues(handles.robotid,-curl_angle,i)
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
handles.MajorFrames = load(dance_file);
% Save to workspace
assignin('base','MajorFrames',handles.MajorFrames)
% Smooth data
temp = handles.MajorFrames;
for i=1:numel(handles.joints)
    temp(:,i) = smooth(temp(:,i));
end
% Upsample from 10Hz to 100Hz.
handles.MinorFrames = interp1(temp,1:0.1:size(temp,1));
% Save upsampled data
dlmwrite('3_Upsampled.txt',handles.MinorFrames,'delimiter','\t');
% Convert to Hubo form and save.
ConvertJaemiToHuboPlus('3_Upsampled.txt');
guidata(hObject,handles);


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
% --- Executes on button press in GoTo.
function GoTo_Callback(hObject, eventdata, handles)
% hObject    handle to GoTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

% --- Executes on button press in PrevMinorFrame.
function PrevMinorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to PrevMinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in PlayPause.
function PlayPause_Callback(hObject, eventdata, handles)
% hObject    handle to PlayPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in NextMinorFrame.
function NextMinorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NextMinorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in NextMajorFrame.
function NextMajorFrame_Callback(hObject, eventdata, handles)
% hObject    handle to NextMajorFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
