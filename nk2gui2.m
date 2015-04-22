%% GUI auto generation codes

function varargout = nk2gui2(varargin)
% NK2GUI2 MATLAB code for nk2gui2.fig

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nk2gui2_OpeningFcn, ...
                   'gui_OutputFcn',  @nk2gui2_OutputFcn, ...
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


% --- Executes just before nk2gui2 is made visible.
function nk2gui2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nk2gui2 (see VARARGIN)

% Choose default command line output for nk2gui2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nk2gui2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = nk2gui2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

clear global

serialInfo=instrhwinfo('serial');
serialInfo.AvailableSerialPorts

global Cam_image
global Ajust_method

if (isempty(Ajust_method))
    Ajust_method=1;
end

global com_no
if (isempty(com_no))
    com_no='4';
end

global FemtoJet
if (isempty(FemtoJet))
    FemtoJet='5';
    %my pc is 3
end

global um_ms
if (isempty(um_ms))
    um_ms=1;
end

global clean_n
if (isempty(clean_n))
    clean_n=0;
end

Cam_image=handles.Camera_image;

% Main Program:

%% Save current altitude
function zsave_Callback(hObject, eventdata, handles)
% hObject    handle to zsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global com_no

delete(instrfindall);
com_name = ['Com',com_no]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'C009');
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells
zloc=num2str(-str2double(info{2}));
set(handles.z_reference_ms,'String',zloc);
%set(handles.info_broad,'String','Saved');


delete(instrfindall);
com_name = ['Com',com_no]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'C010');
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells
zloc=num2str(-str2double(info{2}));
set(handles.z_reference_um,'String',zloc);
guidata(hObject, handles);

%% Injection Motion
function inject_Callback(hObject, eventdata, handles)
% hObject    handle to inject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global com_no
global FemtoJet 
global um_ms
if um_ms==1
    zrefer_um=str2double(get(handles.z_reference_um,'String'));
    z_inject_speed=str2double(get(handles.injuctspeed,'String'));
    move_speed=str2double(get(handles.move_speed,'String'));
    delay_time=str2double(get(handles.injuctdelay,'String'));
    relativeangle=str2double(get(handles.injectangle,'String'));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C004');

    tellinjucting='Injecting'; 
    set(handles.info_broad,'String',tellinjucting)
    pause(0.001); %to avoid the time delay on feedback for moving

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C010');
    infoo=fscanf(s);
    info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells

    zposition1=-str2double(info{2});
    yposition1=str2double(info{3});
    xposition1=-str2double(info{4});


    %% move back to get x space for injection.
    zrelative=zposition1-zrefer_um;
    xrelative=zrelative/tand(relativeangle);

    %if zrelative<0
    %   1; %set(handles.info_broad,'String','Warming: Z position is below Z reference')
    %else
    %   1;
    %end

    xposition2=xposition1-xrelative;
    yposition2=yposition1;
    zposition2=zposition1;

    outputp2_1=num2str(round(-zposition2));
    outputp2_2=num2str(round(yposition2));
    outputp2_3=num2str(round(-xposition2));

    x_v2=move_speed;
    y_v2=move_speed;
    z_v2=move_speed;

    outputv2_1=num2str(round(z_v2));
    outputv2_2=num2str(round(y_v2));
    outputv2_3=num2str(round(x_v2));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_2 = ['C007 ',outputp2_1,' ',outputp2_2,' ',outputp2_3,' ',outputv2_1,' ',outputv2_2,' ',outputv2_3];
    fprintf(s,actionmeter_2);

    while 1
        info_m_2=fscanf(s);
        if isempty(info_m_2)== 1
            pause(0.01);

        else
            info_m_2_cut=textscan(info_m_2, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_2_cut{1},'A007')  &&       strcmpi(info_m_2_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_2_cut{1},'A007')  &&       strcmpi(info_m_2_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_2_cut{1},'A007')  &&       strcmpi(info_m_2_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_2_cut{1},'A007')  &&  8>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_2_cut{1},'A007')  && 16>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_2_cut{1},'A007')  && 32>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_2_cut{1},'A007')  &&    str2double(info_m_2_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_2);

            end

            break
        end
    end

    %% injection

    xposition3=xposition1;
    yposition3=yposition1;
    zposition3=zrefer_um;

    outputp3_1=num2str(round(-zposition3));
    outputp3_2=num2str(round(yposition3));
    outputp3_3=num2str(round(-xposition3));

    x_v3=z_inject_speed/tand(relativeangle);
    y_v3=y_v2;
    z_v3=z_inject_speed;

    outputv3_1=num2str(round(z_v3));
    outputv3_2=num2str(round(y_v3));
    outputv3_3=num2str(round(x_v3));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_3 = ['C007 ',outputp3_1,' ',outputp3_2,' ',outputp3_3,' ',outputv3_1,' ',outputv3_2,' ',outputv3_3];
    fprintf(s,actionmeter_3);


    while 1
        info_m_3=fscanf(s);
        if isempty(info_m_3)== 1
            pause(0.01);

        else
            info_m_3_cut=textscan(info_m_3, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_3_cut{1},'A007')  &&       strcmpi(info_m_3_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_3_cut{1},'A007')  &&       strcmpi(info_m_3_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_3_cut{1},'A007')  &&       strcmpi(info_m_3_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_3_cut{1},'A007')  &&  8>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_3_cut{1},'A007')  && 16>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_3_cut{1},'A007')  && 32>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_3_cut{1},'A007')  &&    str2double(info_m_3_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_3);

            end

            break
        end
    end

    %% FemtoJet
    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    pause(delay_time);

    %stop time for pump injection (since cant get the feedback, so no way to check when it is already, therefore a preassigned time is given: 0.2s ？) 
    %delete(instrfindall);
    %com_name = ['Com', FemtoJet];
    %s=serial(com_name,'BaudRate',9600);
    %fopen(s);

    %% poll back

    xposition4=xposition2;
    yposition4=yposition2;
    zposition4=zposition2;

    outputp4_1=num2str(round(-zposition4));
    outputp4_2=num2str(round(yposition4));
    outputp4_3=num2str(round(-xposition4));

    x_v4=x_v3;
    y_v4=y_v3;
    z_v4=z_v3;

    outputv4_1=num2str(round(x_v4));
    outputv4_2=num2str(round(y_v4));
    outputv4_3=num2str(round(z_v4));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_4 = ['C007 ',outputp4_1,' ',outputp4_2,' ',outputp4_3,' ',outputv4_1,' ',outputv4_2,' ',outputv4_3];
    fprintf(s,actionmeter_4);

    while 1
        info_m_4=fscanf(s);
        if isempty(info_m_4)== 1
            pause(0.01);

        else
            info_m_4_cut=textscan(info_m_4, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_4_cut{1},'A007')  &&       strcmpi(info_m_4_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_4_cut{1},'A007')  &&       strcmpi(info_m_4_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_4_cut{1},'A007')  &&       strcmpi(info_m_4_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_4_cut{1},'A007')  &&  8>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_4_cut{1},'A007')  && 16>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_4_cut{1},'A007')  && 32>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_4_cut{1},'A007')  &&    str2double(info_m_4_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_4);

            end

            break
        end
    end

    %% move to original positon

    xposition5=xposition1;
    yposition5=yposition1;
    zposition5=zposition1;

    outputp5_1=num2str(round(-zposition5));
    outputp5_2=num2str(round(yposition5));
    outputp5_3=num2str(round(-xposition5));

    x_v5=x_v2;
    y_v5=y_v2;
    z_v5=z_v2;

    outputv5_1=num2str(round(x_v5));
    outputv5_2=num2str(round(y_v5));
    outputv5_3=num2str(round(z_v5));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_5 = ['C007 ',outputp5_1,' ',outputp5_2,' ',outputp5_3,' ',outputv5_1,' ',outputv5_2,' ',outputv5_3];
    fprintf(s,actionmeter_5);


    while 1
        info_m_5=fscanf(s);
        if isempty(info_m_5)== 1
            pause(0.01);

        else
            info_m_5_cut=textscan(info_m_5, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_5_cut{1},'A007')  &&       strcmpi(info_m_5_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_5_cut{1},'A007')  &&       strcmpi(info_m_5_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_5_cut{1},'A007')  &&       strcmpi(info_m_5_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_5_cut{1},'A007')  &&  8>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_5_cut{1},'A007')  && 16>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_5_cut{1},'A007')  && 32>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_5_cut{1},'A007')  &&    str2double(info_m_5_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_5);

            end

            break
        end
    end

    set(handles.info_broad,'string','Injection Finished');

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C005');

else

    zrefer_ms=str2double(get(handles.z_reference_ms,'String'));
    z_inject_speed=str2double(get(handles.injuctspeed,'String'))*25.6;
    move_speed=str2double(get(handles.move_speed,'String'))*25.6;
    delay_time=str2double(get(handles.injuctdelay,'String'));
    relativeangle=str2double(get(handles.injectangle,'String'));

    tellinjucting='Injecting 正在扎细胞'; 
    set(handles.info_broad,'String',tellinjucting)
    pause(0.001); %to avoid the time delay on feedback for moving

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C004');

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C009');
    infoo=fscanf(s);
    info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells

    xposition1=-str2double(info{4});
    yposition1=str2double(info{3});
    zposition1=-str2double(info{2});

    %% move back to get x space for injection.
    zrelative=zposition1-zrefer_ms;
    xrelative=zrelative/tand(relativeangle);

    xposition2=xposition1-xrelative;
    yposition2=yposition1;
    zposition2=zposition1;

    outputp2_1=num2str(round(-zposition2));
    outputp2_2=num2str(round(yposition2));
    outputp2_3=num2str(round(-xposition2));

    x_v2=move_speed;
    y_v2=move_speed;
    z_v2=move_speed;

    outputv2_1=num2str(round(z_v2));
    outputv2_2=num2str(round(y_v2));
    outputv2_3=num2str(round(x_v2));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_2 = ['C006 ',outputp2_1,' ',outputp2_2,' ',outputp2_3,' ',outputv2_1,' ',outputv2_2,' ',outputv2_3];
    fprintf(s,actionmeter_2);

    while 1
        info_m_2=fscanf(s);
        if isempty(info_m_2)== 1
            pause(0.01);

        else
            info_m_2_cut=textscan(info_m_2, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_2_cut{1},'A006')  &&       strcmpi(info_m_2_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_2_cut{1},'A006')  &&       strcmpi(info_m_2_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_2_cut{1},'A006')  &&       strcmpi(info_m_2_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_2_cut{1},'A006')  &&  8>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_2_cut{1},'A006')  && 16>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_2_cut{1},'A006')  && 32>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_2_cut{1},'A006')  &&    str2double(info_m_2_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_2);

            end

            break
        end
    end

    %% injection

    xposition3=xposition1;
    yposition3=yposition1;
    zposition3=zrefer_ms;

    outputp3_1=num2str(round(-zposition3));
    outputp3_2=num2str(round(yposition3));
    outputp3_3=num2str(round(-xposition3));

    x_v3=z_inject_speed/tand(relativeangle);
    y_v3=y_v2;
    z_v3=z_inject_speed;

    outputv3_1=num2str(round(z_v3));
    outputv3_2=num2str(round(y_v3));
    outputv3_3=num2str(round(x_v3));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_3 = ['C006 ',outputp3_1,' ',outputp3_2,' ',outputp3_3,' ',outputv3_1,' ',outputv3_2,' ',outputv3_3];
    fprintf(s,actionmeter_3);


    while 1
        info_m_3=fscanf(s);
        if isempty(info_m_3)== 1
            pause(0.01);

        else
            info_m_3_cut=textscan(info_m_3, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_3_cut{1},'A006')  &&       strcmpi(info_m_3_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_3_cut{1},'A006')  &&       strcmpi(info_m_3_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_3_cut{1},'A006')  &&       strcmpi(info_m_3_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_3_cut{1},'A006')  &&  8>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_3_cut{1},'A006')  && 16>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_3_cut{1},'A006')  && 32>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_3_cut{1},'A006')  &&    str2double(info_m_3_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_3);

            end

            break
        end
    end

    %% FemtoJet
    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    pause(delay_time);

    %% poll back

    xposition4=xposition2;
    yposition4=yposition2;
    zposition4=zposition2;

    outputp4_1=num2str(round(-zposition4));
    outputp4_2=num2str(round(yposition4));
    outputp4_3=num2str(round(-xposition4));

    x_v4=x_v3;
    y_v4=y_v3;
    z_v4=z_v3;

    outputv4_1=num2str(round(x_v4));
    outputv4_2=num2str(round(y_v4));
    outputv4_3=num2str(round(z_v4));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_4 = ['C006 ',outputp4_1,' ',outputp4_2,' ',outputp4_3,' ',outputv4_1,' ',outputv4_2,' ',outputv4_3];
    fprintf(s,actionmeter_4);

    while 1
        info_m_4=fscanf(s);
        if isempty(info_m_4)== 1
            pause(0.01);

        else
            info_m_4_cut=textscan(info_m_4, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_4_cut{1},'A006')  &&       strcmpi(info_m_4_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_4_cut{1},'A006')  &&       strcmpi(info_m_4_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_4_cut{1},'A006')  &&       strcmpi(info_m_4_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_4_cut{1},'A006')  &&  8>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_4_cut{1},'A006')  && 16>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_4_cut{1},'A006')  && 32>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_4_cut{1},'A006')  &&    str2double(info_m_4_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_4);

            end

            break
        end
    end

    %% move to original positon

    xposition5=xposition1;
    yposition5=yposition1;
    zposition5=zposition1;

    outputp5_1=num2str(round(-zposition5));
    outputp5_2=num2str(round(yposition5));
    outputp5_3=num2str(round(-xposition5));

    x_v5=x_v2;
    y_v5=y_v2;
    z_v5=z_v2;

    outputv5_1=num2str(round(x_v5));
    outputv5_2=num2str(round(y_v5));
    outputv5_3=num2str(round(z_v5));

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    actionmeter_5 = ['C006 ',outputp5_1,' ',outputp5_2,' ',outputp5_3,' ',outputv5_1,' ',outputv5_2,' ',outputv5_3];
    fprintf(s,actionmeter_5);


    while 1
        info_m_5=fscanf(s);
        if isempty(info_m_5)== 1
            pause(0.01);

        else
            info_m_5_cut=textscan(info_m_5, '%s %s'); %cut the info into cells
            if     strcmpi(info_m_5_cut{1},'A006')  &&       strcmpi(info_m_5_cut{2},'0') % compare the char, ignore case
                1;

            elseif strcmpi(info_m_5_cut{1},'A006')  &&       strcmpi(info_m_5_cut{2},'1')
                set(handles.info_broad,'string','STOPPED for hitting z upper limit ');

            elseif strcmpi(info_m_5_cut{1},'A006')  &&       strcmpi(info_m_5_cut{2},'2')
                set(handles.info_broad,'string','STOPPED for hitting z lower limit ');

            elseif strcmpi(info_m_5_cut{1},'A006')  &&  8>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=4
                set(handles.info_broad,'string','STOPPED for hitting y lower limit ');

            elseif strcmpi(info_m_5_cut{1},'A006')  && 16>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=8
                set(handles.info_broad,'string','STOPPED for hitting y upper limit ');   

            elseif strcmpi(info_m_5_cut{1},'A006')  && 32>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=16
                set(handles.info_broad,'string','STOPPED for hitting x upper limit '); 

            elseif strcmpi(info_m_5_cut{1},'A006')  &&    str2double(info_m_5_cut{2}) >= 32
                set(handles.info_broad,'string','STOPPED for hitting x lower limit ');

            else
                set(handles.info_broad,'string',info_m_5);

            end

            break
        end
    end

    set(handles.info_broad,'string','Injection Finished');

    delete(instrfindall);
    com_name = ['Com',com_no]; 
    s=serial(com_name,'BaudRate',19200);
    fopen(s);
    fprintf(s,'C005');
end
guidata(hObject, handles);

%% Injection Parameters
function z_reference_ms_Callback(hObject, eventdata, handles)
%it is z_reference_ms here
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为无效
if (isempty(input))

     set(hObject,'String','')
     %set(handles.info_broad,'String','Invilid input for Z reference')

end

z_reference_um=round(str2double(get(hObject,'String'))/25.6);
set(handles.z_reference_um,'String',num2str(z_reference_um));

guidata(hObject, handles);

function z_reference_ms_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function z_reference_um_Callback(hObject, eventdata, handles)
%it is z_reference_um here
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为无效
if (isempty(input))

     set(hObject,'String','')
     %set(handles.info_broad,'String','Invilid input for Z reference')

end

z_reference_ms=round(str2double(get(hObject,'String'))*25.6);
set(handles.z_reference_ms,'String',num2str(z_reference_ms));

guidata(hObject, handles);

function z_reference_um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_reference_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function injectangle_Callback(hObject, eventdata, handles)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为45度角
if (isempty(input))

     set(hObject,'String','45')
     
end


guidata(hObject, handles);

function injectangle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injectangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function injuctspeed_Callback(hObject, eventdata, handles)
% hObject    handle to injuctspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为45度角
if (isempty(input))

     set(hObject,'String','5')
     
end

function injuctspeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injuctspeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function injuctdelay_Callback(hObject, eventdata, handles)
% hObject    handle to injuctdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为45度角
if (isempty(input))

     set(hObject,'String','0.5')
     
end

function injuctdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to injuctdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function move_speed_Callback(hObject, eventdata, handles)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为0
if (isempty(input))
     set(hObject,'String','100')
end

function move_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to move_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Comera Control
function Camera_image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Camera_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'xTick',[]);
set(hObject,'ytick',[]);
set(hObject,'box','on');
% axis is a place to place single or live-time pictures. (camera)

function start_cam_Callback(hObject, eventdata, handles)
% hObject    handle to start_cam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
global Adjust_method
global t_I_ad

try 
    closepreview(vid);
    stop(vid);
    stop(t_I_ad);
    delete(t_I_ad);
catch
    1;
end

vid = videoinput('hamamatsu', 1, 'MONO16_1344x1024');
%vid = videoinput('winvideo', 1, 'MJPG_1280x720');
vidRes = get( vid, 'VideoResolution' );
nBands = get( vid, 'NumberOfBands' );
global srcObj1
srcObj1 = get(vid, 'Source');
%%
if Adjust_method==0
    triggerconfig(vid, 'manual');
    
    start(vid)
    
    t_I_ad = timer('StartDelay', 0, 'Period', 0.15, ...
          'ExecutionMode', 'fixedRate');
    t_I_ad.TimerFcn = 'image_ad';
    start(t_I_ad);
else
    set(srcObj1(1), 'ExposureTime', str2double(get(handles.ExposureTime, 'string')));
    set(srcObj1(1), 'Gain', get(handles.Gain, 'value'));
    set(srcObj1(1), 'Offset',get(handles.Offset,'value'));
    set(srcObj1(1), 'ContrastGain',get(handles.ContrastGain,'value'));
    set(srcObj1(1), 'ContrastOffset',get(handles.ContrastOffset,'value'));
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
    axes(handles.Camera_image);
    preview(vid,hImage);
end
guidata(hObject, handles);

function stop_cam_Callback(hObject, eventdata, handles)
% hObject    handle to stop_cam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
global t_I_ad

try
    closepreview(vid);
    stop(vid);
    stop(t_I_ad);
    delete(t_I_ad);
catch
    1;
end
guidata(hObject, handles);

function Im_Reset_Callback(hObject, eventdata, handles)
% hObject    handle to Im_Reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    closepreview(vid);
    stop(vid);
    stop(t_I_ad);
    delete(t_I_ad);
catch
    1;
end
imaqreset;
guidata(hObject, handles); 

function frame_save_Callback(hObject, eventdata, handles)
% hObject    handle to frame_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
frame=getsnapshot(vid);
stoppreview(vid);
[file,path] = uiputfile({'*.png';'*.tif';'*.*'},'Save image');
filename=fullfile(path,file);
imwrite(frame,filename);

guidata(hObject, handles);

function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile({'*.avi';'*.*'},'Save video');
vidoname=fullfile(path,file);
if isequal(vidoname,0)
    disp('File select cancelled')
else
    writerObj = VideoWriter( vidoname );
    Recordspeed=str2double(get(handles.Record_speed,'String'));
    writerObj.FrameRate = Recordspeed; %10 is the record rate of camera, which means the camera get 10 frame every sec, no matter what is in code.
    open(writerObj);
    Recordframe= Recordspeed*str2double(get(handles.Recordtime,'String'));

     %figure;
     for ii = 1: Recordframe

    (handles.Camera_image);
    i=getimage(gca);
    writeVideo(writerObj,i);
     end

    close(writerObj);
end
guidata(hObject, handles);

function Recordtime_Callback(hObject, eventdata, handles)
% hObject    handle to Recordtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为0
if (isempty(input))

     set(hObject,'String','30')

end
guidata(hObject, handles);

function Recordtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Recordtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Pic_save_Callback(hObject, eventdata, handles)
% hObject    handle to Pic_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile({'*.png';'*.tif';'*.*'},'Save image');
filename=fullfile(path,file);
(handles.Camera_image);
i=getimage(gca);
imwrite(i,filename);
guidata(hObject, handles)

function Raw_record_Callback(hObject, eventdata, handles)
% hObject    handle to Raw_record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid;
[file,path] = uiputfile({'*.avi';'*.*'},'Save video');
vidoname=fullfile(path,file);
writerObj = VideoWriter( vidoname );
Recordspeed=str2double(get(handles.Record_speed,'String'));
writerObj.FrameRate = Recordspeed; %10 is the record rate of camera, which means the camera get 10 frame every sec, no matter what is in code.
open(writerObj);
Recordframe= Recordspeed*str2double(get(handles.Recordtime,'String'));
 
 %figure;
 for ii = 1: Recordframe
     frame = getsnapshot(vid);
     %imshow(frame);
     %f.cdata = frame;
     %f.colormap = [];  
     img=im2double(frame);
     writeVideo(writerObj,img);
 end
 
 close(writerObj);
 infooutput='Recorded Done';
 set(handles.info_broad,'String',infooutput)
 guidata(hObject, handles);

function Record_speed_Callback(hObject, eventdata, handles)
% hObject    handle to Record_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Record_speed as text
%        str2double(get(hObject,'String')) returns contents of Record_speed as a double
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为0
if (isempty(input))

     set(hObject,'String','10')

end
guidata(hObject, handles);

function Record_speed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Record_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Graphical Injection - Sub Menu
function Ginject_Callback(hObject, eventdata, handles)

global com_no
global FemtoJet

move_speed=str2double(get(handles.move_speed,'String'));
inject_speed=str2double(get(handles.injuctspeed,'String'));
zrefer_um=str2double(get(handles.z_reference_um,'String'));
zrefer_ms=str2double(get(handles.z_reference_ms,'String'));
relativeangle=str2double(get(handles.injectangle,'String'));
if relativeangle<3
    relativeangle=3;
    set(handles.injectangle,'String','3');
end
delay_time=str2double(get(handles.injuctdelay,'String'));

delete(instrfindall);
com_name = ['Com',com_no]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c005');
fscanf(s);

Contine_1_Return_0=1;
while Contine_1_Return_0==1
% there is another slider m file without sub_m_file, but it just do not
% work when put into the GUI, it works seperately very well. no idea
[Contine_1_Return_0]=GenerateGraph(move_speed,inject_speed,zrefer_um,zrefer_ms,relativeangle,delay_time);
end
guidata(hObject, handles);

function D3Gaphic_Inject_Callback(hObject, eventdata, handles)

global com_no
global FemtoJet

move_speed=str2double(get(handles.move_speed,'String'));
inject_speed=str2double(get(handles.injuctspeed,'String'));
zrefer_um=str2double(get(handles.z_reference_um,'String'));
zrefer_ms=str2double(get(handles.z_reference_ms,'String'));
relativeangle=str2double(get(handles.injectangle,'String'));
delay_time=str2double(get(handles.injuctdelay,'String'));

delete(instrfindall);
com_name = ['Com',com_no]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c005');
fscanf(s);

Contine_1_Return_0=1;
while Contine_1_Return_0==1
% there is another slider m file without sub_m_file, but it just do not
% work when put into the GUI, it works seperately very well. no idea
[Contine_1_Return_0]=GenerateGraph_3point(move_speed,inject_speed,zrefer_um,zrefer_ms,relativeangle,delay_time);
end
guidata(hObject, handles);

%%  Camera Parameters
function ExposureTime_Callback(hObject, eventdata, handles)
% hObject    handle to ExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值
% 检验输入是否为空，是则将它置为0
if (isempty(input))
     set(hObject,'String','0.06')
end

global srcObj1
set(srcObj1(1), 'ExposureTime', str2double(get(hObject,'String')));
guidata(hObject, handles); 

function ExposureTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExposureTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Gain_Callback(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Gaintext,'string',['Gain ',num2str(round(get(handles.Gain,'value')))])
global srcObj1;
set(srcObj1(1), 'Gain', get(hObject,'value'));
guidata(hObject, handles);  

function Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function Offset_Callback(hObject, eventdata, handles)
% hObject    handle to Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.Offsettext,'string',['Offset ',num2str(round(get(handles.Offset,'value')))])
global srcObj1;
set(srcObj1(1), 'Offset', get(hObject,'value'));
guidata(hObject, handles); 

function Offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ContrastGain_Callback(hObject, eventdata, handles)
% hObject    handle to ContrastGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ContrastGaintext,'string',['Contrast Gain ',num2str(round(get(handles.ContrastGain,'value')))])
global srcObj1;
set(srcObj1(1), 'ContrastGain', get(hObject,'value'));
guidata(hObject, handles); 

function ContrastGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContrastGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ContrastOffset_Callback(hObject, eventdata, handles)
% hObject    handle to ContrastOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.ContrastOffsettext,'string',['Contrast Offset ',num2str(round(get(handles.ContrastOffset,'value')))])
global srcObj1;
set(srcObj1(1), 'ContrastOffset', get(hObject,'value'));
guidata(hObject, handles); 

function ContrastOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContrastOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ExposureTimetext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExposureTimetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function Gaintext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gaintext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function ContrastOffsettext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContrastOffsettext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function ContrastGaintext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContrastGaintext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function Offsettext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Offsettext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%% Sub-Menu
function Parameter_sub_Callback(hObject, eventdata, handles)
% hObject    handle to Parameter_sub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_parameter
guidata(hObject, handles); 

%% Infomation Display
function info_broad_Callback(hObject, eventdata, handles)
% hObject    handle to info_broad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function info_broad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_broad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Adjuest_Type_SelectionChangeFcn(hObject, eventdata, handles)
global Adjust_method
%0 is manual
%1 is auto
switch get(hObject,'Tag') 

    case 'Manual_cam'
        Adjust_method=1;

    case 'Auto_cam'
        Adjust_method=0;
end

function Um_Ms_Selection_SelectionChangeFcn(hObject, eventdata, handles)
global um_ms
%0 is ms
%1 is um
switch get(hObject,'Tag') 

    case 'ms'
        um_ms=0;

    case 'um'
        um_ms=1;
end

%% FemtoJet Setting
function Inject_t_Callback(hObject, eventdata, handles)
global FemtoJet
set(handles.text_t,'string',num2str(round(get(handles.Inject_t,'value'))));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C042=',num2str(round(get(hObject,'value')))]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)


guidata(hObject, handles); 

function Inject_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inject_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function text_t_Callback(hObject, eventdata, handles)
global FemtoJet
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

if (isempty(input))
     set(hObject,'String','2')
end

set(handles.Inject_t,'value',str2double(get(hObject,'String')));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C042=',get(hObject,'String')]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles); 

function text_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Inject_pi_Callback(hObject, eventdata, handles)
global FemtoJet
set(handles.h_pi,'string',num2str(round(get(hObject,'value'))));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C044=',num2str(round(get(hObject,'value')))]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles); 

function Inject_pi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inject_pi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function h_pi_Callback(hObject, eventdata, handles)
global FemtoJet
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

if (isempty(input))
     set(hObject,'String','100')
end

set(handles.Inject_pi,'value',str2double(get(hObject,'String')));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C044=',get(hObject,'String')]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles); 

function h_pi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_pi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Inject_pc_Callback(hObject, eventdata, handles)
global FemtoJet
set(handles.h_pc,'string',num2str(round(get(hObject,'value'))));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C043=',num2str(round(get(hObject,'value')))]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles);

function Inject_pc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Inject_pc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function h_pc_Callback(hObject, eventdata, handles)
global FemtoJet
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

if (isempty(input))
     set(hObject,'String','25')
end

set(handles.Inject_pc,'value',str2double(get(hObject,'String')));

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C043=',get(hObject,'String')]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles); 

function h_pc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to h_pc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clean_jet_Callback(hObject, eventdata, handles)
global FemtoJet
global clean_time

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)
js_com=['C013=',clean_time]
fprintf(js,js_com);
infoo=fscanf(js)
infoo=fscanf(js)

guidata(hObject, handles);

function update_j_Callback(hObject, eventdata, handles)
global FemtoJet

delete(instrfindall);
js = serial(['Com',FemtoJet]); 
set(js,'Baudrate',9600,'Parity','none','StopBits',2);
fopen(js);
pause(1);
fprintf(js,'AB');
infoo=fscanf(js)
infoo=fscanf(js)

js_com=['C152']; %time
fprintf(js,js_com);
infoo=fscanf(js)
infoo_t=fscanf(js)
time_feedback=textscan(infoo_t, '%s %s');
time_device=time_feedback{2};
%h_t and Inject_t
set(handles.Inject_t,'value',str2double(time_device));
set(handles.text_t,'string',time_device);



js_com=['C153']; %pc
fprintf(js,js_com);
infoo=fscanf(js)
infoo_pc=fscanf(js)
%h_t and Inject_t
pc_feedback=textscan(infoo_pc, '%s %s');
pc_device=pc_feedback{2};
set(handles.Inject_pc,'value',str2double(pc_device));
set(handles.h_pc,'string',pc_device);

js_com=['C154']; %pi
fprintf(js,js_com);
infoo=fscanf(js)
infoo_pi=fscanf(js)
%h_t and Inject_t
pi_feedback=textscan(infoo_pi, '%s %s');
pi_device=pi_feedback{2};
set(handles.Inject_pi,'value',str2double(pi_device));
set(handles.h_pi,'string',pi_device);

guidata(hObject, handles);

function cleantime_Callback(hObject, eventdata, handles)
global clean_time
input= (get(hObject,'String')); % string属性是字符串，所以必须转换成数值

if (isempty(input))
     set(hObject,'String','0.5')
end
clean_time=get(hObject,'String');
guidata(hObject, handles);

function cleantime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cleantime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
