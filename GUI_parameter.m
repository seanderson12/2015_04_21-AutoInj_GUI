function varargout = GUI_parameter(varargin)
% GUI_PARAMETER MATLAB code for GUI_parameter.fig
%      GUI_PARAMETER, by itself, creates a new GUI_PARAMETER or raises the existing
%      singleton*.
%
%      H = GUI_PARAMETER returns the handle to a new GUI_PARAMETER or the handle to
%      the existing singleton*.
%
%      GUI_PARAMETER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PARAMETER.M with the given input arguments.
%
%      GUI_PARAMETER('Property','Value',...) creates a new GUI_PARAMETER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_parameter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_parameter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_parameter

% Last Modified by GUIDE v2.5 20-Jun-2014 11:43:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_parameter_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_parameter_OutputFcn, ...
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


% --- Executes just before GUI_parameter is made visible.
function GUI_parameter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_parameter (see VARARGIN)

% Choose default command line output for GUI_parameter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_parameter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_parameter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in positionstep.
function positionstep_Callback(hObject, eventdata, handles)
delete(instrfindall);
com_name = ['Com',get(handles.com_no,'String')]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c009');
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells
%%
if (isempty(infoo))

    set(handles.infoboard,'String','N/A')
    
elseif  strcmpi(info{1},'A009') % compare the char, ignore case
    zloc=num2str(-str2double(info{2}));
    yloc=num2str(str2double(info{3}));
    xloc=num2str(-str2double(info{4}));
    infooutput=strcat('current loctaion in step: x:',xloc,' y:',yloc,' z:',zloc,' in micometer');%use strcat(,) to place the char horizontally
    set(handles.infoboard,'String',infooutput)

else 
    set(handles.infoboard,'String',infoo);

end

guidata(hObject, handles);


% --- Executes on button press in positionmeter.
function positionmeter_Callback(hObject, eventdata, handles)
delete(instrfindall);
com_name = ['Com',get(handles.com_no,'String')]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'C010');
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells

%%
if (isempty(infoo))

    set(handles.infoboard,'String','N/A')
    
elseif  strcmpi(info{1},'A010') % compare the char, ignore case
    zloc=num2str(-str2double(info{2}));
% can only use str2double for cell, str2num wouldn’t work
    yloc=num2str(str2double(info{3}));
    xloc=num2str(-str2double(info{4}));
    infooutput=strcat('current loctaion in step: x:',xloc,' y:',yloc,' z:',zloc,' in micometer');%use strcat(,) to place the char horizontally
    set(handles.infoboard,'String',infooutput)

else 
    set(handles.infoboard,'String',infoo);

end

guidata(hObject, handles);


% --- Executes on button press in Manualmode.
function Manualmode_Callback(hObject, eventdata, handles)
delete(instrfindall);
com_name = ['Com',get(handles.com_no,'String')]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c005');
info=fscanf(s);
%contain a formact char ' ', so cant compare use a function to delete it;
info=strtrim(info);% can also use isspace() to detect and deblank() is to cut the end

if (isempty(info))

    set(handles.infoboard,'String','N/A')
    
elseif  strcmpi(info,'A005') % compare the char, ignore case
    
    set(handles.infoboard,'String','Changed to manual mode')

else
    set(handles.infoboard,'String',info);

end

guidata(hObject, handles);


% --- Executes on button press in pcmode.
function pcmode_Callback(hObject, eventdata, handles)
delete(instrfindall);
com_name = ['Com',get(handles.com_no,'String')]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c004');
info=fscanf(s);

%feedbacks contain a formact char ' ', so can’t directly be compared, there used a function to delete it;

info=strtrim(info);

% delete the format char at the need, can also use isspace() to detect and deblank() is to cut the end
% there another way was used in get postion fuction that used textscan()


if (isempty(info))

    set(handles.infoboard,'String','N/A')
    
elseif  strcmpi(info,'A004') % compare the char, ignore case
    
    set(handles.infoboard,'String','Changed to pc contral mode')

else
    set(handles.infoboard,'String',info);

end

guidata(hObject, handles);


function FemtoJet_Callback(hObject, eventdata, handles)


global FemtoJet


input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

% 检验输入是否为空，是则将它置为接口4
if (isempty(input))

     set(hObject,'String',FemtoJet)

end

FemtoJet=get(handles.FemtoJet,'String');

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function FemtoJet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FemtoJet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function com_no_Callback(hObject, eventdata, handles)

global com_no

input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

% 检验输入是否为空，是则将它置为接口4
if (isempty(input))

     set(hObject,'String',com_no)

end

com_no=(get(hObject,'String'));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function com_no_CreateFcn(hObject, eventdata, handles)
% hObject    handle to com_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% info boarding 公告版
% --- Executes during object creation, after setting all properties.
function infoboard_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
