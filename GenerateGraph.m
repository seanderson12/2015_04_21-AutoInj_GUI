%% on testing !!!! (line 219 -254)

function [Return_back]=GenerateGraph(move_speed_um,inject_speed_um,zrefer_um,zrefer_ms,relativeangle,delay_time)
global vid 
global srcObj1
global com_no
%global FemtoJet
global t_I_ad
%vid = videoinput('hamamatsu', 1, 'MONO16_1344x1024');
Return_back=0;

try 
    closepreview(vid);
    stop(vid);
    stop(t_I_ad);
    delete(t_I_ad);
catch
    1;
end

move_speed_ms=move_speed_um*25.6;
inject_speed_ms=inject_speed_um*25.6;


vidRes = get( vid, 'VideoResolution' );
nBands = get( vid, 'NumberOfBands' );

MainFigure=figure('menubar','none','numbertitle','off','name','Sub-GUI Window');

uicontrol('Style', 'popup',...
           'String', 'gray|hsv|jet|hot|cool',...
           'Position', [10 369 50 50],...
           'Callback', @setmap);
       
close_ui=uicontrol('String', 'Close','Position', [70 398 50 20], 'Callback', {@close_ui_callback,MainFigure}) ;

    function close_ui_callback(hObject,event,MainFigure)
        close(MainFigure);
        Return_back=0;
    end
    % return_back=0 need to stop ginput


Calabration=uicontrol('String', 'Calabration','Position', [140 398 80 20], 'Callback', {@ui_calabration,move_speed_ms, MainFigure}) ;

    function ui_calabration(hObject,event,move_speed_ms, MainFigure )
        global L_I_to_P_um L_I_to_P_ms
        global R_I_to_P_um R_I_to_P_ms
        global I_to_P_con_um I_to_P_con_ms
        global z_safe_um z_safe_ms

        zv = move_speed_ms;
        yv = move_speed_ms;
        xv = move_speed_ms;        
        
        [sizex sizey]=size(getsnapshot(vid)); 
        % if the image is not in '.tif', change to be "[sizex sizey zzz]=size(Imagee)"
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        set(ax2,'color','none')  
        axis([0 sizey 0 sizex ]);   
        
        move1_msg=msgbox({'Please move the cnp tip to top-right corner', 'Adjust the tip to an altitude above all cells','And select location'},'First Step');
        % �޸�����
        ah1 = get(move1_msg, 'CurrentAxes' );
        ch1 = get( ah1, 'Children' );
        set( ch1, 'FontSize', 7);
        % �ı�����
        th1 = findall(0, 'Tag','MessageBox' );
        boxPosition = get(move1_msg,'position');
        textPosition = get(th1, 'position'); 
        set(th1, 'position', [boxPosition(3).*0.5 textPosition(2) textPosition(3)]);
        set(th1, 'HorizontalAlignment', 'center');
        set(move1_msg,'Position',[100 150 180 60]);% ʹ������������޸�msgbox��λ�úʹ�С
        
        figure(MainFigure);

        [Ix_1,Iy_1]=ginputc(1);
        I1=[Ix_1,Iy_1];
        %right up corner
        [P1_um,P1_ms] = getposition(com_no);

        z_safe_um = P1_um (3);
%        setappdata(nk2gui2,'z_safe_um',z_safe_um);
        z_safe_ms = P1_ms (3);
        
        close(move1_msg);
        
        move2_msg=msgbox({'Please move the cnp tip to the botton-left corner','And select location'},'Second Step');
        ah2 = get(move2_msg, 'CurrentAxes' );
        ch2 = get( ah2, 'Children' );
        set( ch2, 'FontSize', 7);
        th2 = findall(0, 'Tag','MessageBox' );
        boxPosition = get(move2_msg,'position');
        textPosition = get(th2, 'position'); 
        set(th2, 'position', [boxPosition(3).*0.5 textPosition(2) textPosition(3)]);
        set(th2, 'HorizontalAlignment', 'center');
        set(move2_msg,'Position',[100 150 180 60]);% ʹ������������޸�msgbox��λ�úʹ�С

      
        figure(MainFigure);
        
        %move to the same z
        [P2_o_um,P2_o_ms] = getposition(com_no);
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c004');
        fscanf(s);
        
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        x_2_o_ms= P2_o_ms(1);
        y_2_o_ms= P2_o_ms(2);
        z_2_ms  = z_safe_ms;
        zp = -x_2_o_ms;
        yp = y_2_o_ms;
        xp = -z_2_ms;

        zp_final = num2str(zp);
        yp_final = num2str(yp);
        xp_final = num2str(xp);
        zv_final = num2str(zv);
        yv_final = num2str(yv);
        xv_final = num2str(xv);
        actionmeter_zback= ['C006 ',xp_final,' ',yp_final,' ',zp_final,' ',xv_final,' ',yv_final,' ',zv_final];
        fprintf(s,actionmeter_zback);
        while 1
            info_z_back=fscanf(s);
            if isempty(info_z_back)== 1
                pause(0.01);
            else
                break
            end
        end

        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c005');
        fscanf(s);

        [Ix_2,Iy_2]=ginputc(1);
        I2=[Ix_2,Iy_2];
        %left down corner or inverse
        [P2_um,P2_ms] = getposition(com_no);


        %%
        %length calibration factor
        L_I_to_P_um=norm(P2_um(1,1:2)-P1_um(1,1:2))/norm(I2-I1);
        L_I_to_P_ms=norm(P2_ms(1,1:2)-P1_ms(1,1:2))/norm(I2-I1);
        
      % make sure the angle is in pi to -pi
        if (I2(1)-I1(1))>0
            angle_I=atan((I2(2)-I1(2))/(I2(1)-I1(1)));
        else
            angle_I=atan((I2(2)-I1(2))/(I2(1)-I1(1)))+pi;
        end
        
        if (P2_um(1)-P1_um(1))>0
            angle_P_um=atan((P2_um(2)-P1_um(2))/(P2_um(1)-P1_um(1)));
        else
            angle_P_um=atan((P2_um(2)-P1_um(2))/(P2_um(1)-P1_um(1)))+pi;
        end
        
        if (P2_ms(1)-P1_ms(1))>0
            angle_P_ms=atan((P2_ms(2)-P1_ms(2))/(P2_ms(1)-P1_ms(1)));
        else
            angle_P_ms=atan((P2_ms(2)-P1_ms(2))/(P2_ms(1)-P1_ms(1)))+pi;
        end
        
       %phi, the angel between internal frame B and frame A
        phi_I_p_um=angle_I-angle_P_um;
        phi_I_p_ms=angle_I-angle_P_ms;
        %phi_I_p_um=atan((I2(2)-I1(2))/(I2(1)-I1(1)))-atan((P2_um(2)-P1_um(2))/(P2_um(1)-P1_um(1)));%��1344����1024
        %phi_I_p_ms=atan((I2(2)-I1(2))/(I2(1)-I1(1)))-atan((P2_ms(2)-P1_ms(2))/(P2_ms(1)-P1_ms(1)));%��1344����1024

        %Rotation calibration factor
        R_I_to_P_um=[cos(phi_I_p_um),-sin(phi_I_p_um);sin(phi_I_p_um),cos(phi_I_p_um)];
        R_I_to_P_ms=[cos(phi_I_p_ms),-sin(phi_I_p_ms);sin(phi_I_p_ms),cos(phi_I_p_ms)];

        % P=P1+(I-I1)*Lip*Rip=I*Lip*Rip+(P1-I1*Lip*Rip)
        %(P1-I1*Lip*Rip)
        I_to_P_con_um=P1_um(1,1:2)-I1*R_I_to_P_um*L_I_to_P_um;
        I_to_P_con_ms=P1_ms(1,1:2)-I1*R_I_to_P_ms*L_I_to_P_ms;
        
        axis off
        close(move2_msg);
    end

S_inject_um=uicontrol('String', 'Inject(um) Select HK','Position', [230 398 100 20], 'Callback', {@Inject_S_um,move_speed_um,inject_speed_um ,zrefer_um,relativeangle,delay_time,MainFigure}) ;

    function Inject_S_um(hObject,event,move_speed_um,inject_speed_um ,zrefer_um,relativeangle,delay_time,MainFigure)
        
        Return_back = 1;
        
        global L_I_to_P_um L_I_to_P_ms
        global R_I_to_P_um R_I_to_P_ms
        global I_to_P_con_um I_to_P_con_ms
        global z_safe_um z_safe_ms
        global clean_n
        global FemtoJet
        global clean_time

        
        [sizex sizey]=size(getsnapshot(vid)); 
        % if the image is not in '.tif', change to be "[sizex sizey zzz]=size(Imagee)"
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        set(ax2,'color','none')  
        axis([0 sizey 0 sizex ]);
        
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c004');
        fscanf(s);
 %%     
        number=1;
        while 1
            [x_input, y_input, inputflag]=ginputc(1);
            
            if isempty(inputflag)
                break
            elseif inputflag ~= 1 
                break
            end
            x(number)=x_input;
            y(number)=y_input;
            hold on 
            plot(x(number),y(number),'r*')
            number = number+1;
        end
        close(MainFigure);
        xy=[x',y']; 
        n=length(x); 
        
        if n >= 10
            
            popSize = 60; 
            numIter = n^2; 
            showProg = 0; 
            showResult = 0; 
            a = meshgrid(1:n); 
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),n,n); 

            % solved TPS by 'Copyright (c) 2007, Joseph Kirk'
            [optRoute,minDist] = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult);
            %[optRoute,minDist] = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult);
        else
            
            [Present_um,Present_ms] = getposition(com_no);
            Image_present=(Present_um(1,1:2)-I_to_P_con_um)*(R_I_to_P_um)^(-1)*(L_I_to_P_um)^(-1);
            xy_present=[Image_present;xy];
            [optRoute]=Path_qi(xy_present);
        end

        % for calculation speed consideration, build matrix and put in loop.
        optpath_x=zeros(1,length(x));
        optpath_y=zeros(1,length(x));

        for path_order=1:length(x)
            optpath_x(path_order)=xy(optRoute(path_order),1);
            optpath_y(path_order)=xy(optRoute(path_order),2);
            optpath_last_x=xy(optRoute(1),1);
            optpath_last_y=xy(optRoute(1),2); 
        end
%%

        optpath=[optpath_x.',optpath_y.'];
        optpath_show=[optpath_x.',optpath_y.'; optpath_last_x, optpath_last_y]; 
        % "; optpath_last_x optpath_last_y "] can be deleted cause it is just used
        % to make it move back to original point

        % remake a figure to show the motion in the orginial picture.
        

        hinspect=figure('Name', 'Inspect Window');
        uicontrol('Style', 'popup',...
                   'String', 'gray|hsv|jet|hot|cool',...
                   'Position', [10 369 50 50],...
                   'Callback', @setmap); 
        uicontrol('String', 'Close','Position', [70 398 50 20], 'Callback', 'close(gcf)')

        vidRes = get( vid, 'VideoResolution' );
        nBands = get( vid, 'NumberOfBands' );
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
        figure(hinspect)
        preview(vid,hImage);
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        plot(optpath_show(:,1),optpath_show(:,2),'*-r')
        % �ӱ�ע˳�� mark the motion order
        
%% wave input by daq method
%         Wave_timer= timer('Name','ButtonTimer','StartDelay', 0,'Period', 0.30 ,...
%                    'ExecutionMode','fixedRate',...
%                    'StartFcn','[hwave,hdevice,Cbox,capacitor,df]=wave_init_daq();',...
%                    'StopFcn','wave_stop_daq(hwave,hdevice);',...
%                    'TimerFcn','[capacitor]=wave_show_daq(hwave,hdevice,Cbox,capacitor,df);'); 
%%
        for note_order=1:length(x)
            text(optpath(note_order,1),optpath(note_order,2),num2str(note_order),'FontSize',12)
        end

        set(ax2,'color','none')
        axis([0 sizey 0 sizex ]);
        
        um_size=size(optpath);
        I_um_ones=ones(um_size(1),1);
        ms_size=size(optpath);
        I_ms_ones=ones(ms_size(1),1);
        
        um_path_rotated = optpath*L_I_to_P_um*R_I_to_P_um+I_um_ones*I_to_P_con_um;
        ms_path_rotated = optpath*L_I_to_P_ms*R_I_to_P_ms+I_ms_ones*I_to_P_con_ms;
        
        No_points=size(um_path_rotated);        
%
%       start(Wave_timer); %daq method

        global h_fid
        default_path='\\169.254.13.253\Anderson_Share\test\';
        [file,path] = uigetfile({'*.dat';'*.*'},'Load Dat File',default_path);
        %make path for data file
        h_fid=fullfile(path,file);
        if isequal(h_fid,0)
            disp('File select cancelled')
        end
        
        
        for umpath_order=1:No_points(1)
            clean_n=clean_n+1;
            
            if clean_n>=10
                delete(instrfindall);
                js = serial(['Com',FemtoJet]); 
                set(js,'Baudrate',9600,'Parity','none','StopBits',2);
                set(js, 'TimeOut', 0.02);
                fopen(js);
                pause(1);
                fprintf(js,'AB');
                infoo=fscanf(js)
                infoo=fscanf(js)
                js_com=['C013=',clean_time]
                fprintf(js,js_com);
                infoo=fscanf(js)
                infoo=fscanf(js)
                clean_n=0;
                pause(1);
            else
                1;
            end
            
            um_position=um_path_rotated(umpath_order,:);
            angle_injection_um_HEKA (um_position, z_safe_um, zrefer_um, relativeangle,com_no,FemtoJet,move_speed_um,inject_speed_um,delay_time);
        % angle_injection_um (um_position, z_safe_um, zrefer_um, relativeangle);
        end

        
        inj_msg=msgbox({'All points injected','Press to refresh'},'Msg');
        uiwait(inj_msg);
        
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c005');
        fscanf(s);

%%
%       stop(Wave_timer); %daq method
        
        close(hinspect);
    end  

S_inject_ms=uicontrol('String', 'Inject(ms) Selection','Position', [340 398 100 20], 'Callback', {@Inject_S_ms,move_speed_ms,inject_speed_ms ,zrefer_ms,relativeangle,delay_time,MainFigure}) ;

    function Inject_S_ms(hObject,event,move_speed_ms,inject_speed_ms ,zrefer_ms,relativeangle,delay_time,MainFigure)
        


        Return_back = 1;
        
        global L_I_to_P_um L_I_to_P_ms
        global R_I_to_P_um R_I_to_P_ms
        global I_to_P_con_um I_to_P_con_ms
        global z_safe_um z_safe_ms
        global clean_n
        global FemtoJet
        global clean_time
    
        [sizex sizey]=size(getsnapshot(vid)); 
        % if the image is not in '.tif', change to be "[sizex sizey zzz]=size(Imagee)"
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        set(ax2,'color','none')  
        axis([0 sizey 0 sizex ]);
        
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c004');
        fscanf(s);
        number=1;
        while 1
            [x_input, y_input, inputflag]=ginputc(1);
            
            if isempty(inputflag)
                break
            elseif inputflag ~= 1 
                break
            end
            x(number)=x_input;
            y(number)=y_input;
            hold on 
            plot(x(number),y(number),'r*')
            number = number+1;
        end
        close(MainFigure);
        xy=[x',y']; 
        n=length(x); 
        
        if n >= 10
            
            popSize = 60; 
            numIter = n^2; 
            showProg = 0; 
            showResult = 0; 
            a = meshgrid(1:n); 
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),n,n); 

            % solved TPS by 'Copyright (c) 2007, Joseph Kirk'
            [optRoute,minDist] = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult);
            %[optRoute,minDist] = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult);
        else
            
            [Present_um,Present_ms] = getposition(com_no);
            Image_present=(Present_ms(1,1:2)-I_to_P_con_ms)*(R_I_to_P_ms)^(-1)*(L_I_to_P_ms)^(-1);
            xy_present=[Image_present;xy];
            [optRoute]=Path_qi(xy_present);
        end

        % for calculation speed consideration, build matrix and put in loop.
        optpath_x=zeros(1,length(x));
        optpath_y=zeros(1,length(x));

        for path_order=1:length(x)
            optpath_x(path_order)=xy(optRoute(path_order),1);
            optpath_y(path_order)=xy(optRoute(path_order),2);
            optpath_last_x=xy(optRoute(1),1);
            optpath_last_y=xy(optRoute(1),2); 
        end


        optpath=[optpath_x.',optpath_y.'];
        optpath_show=[optpath_x.',optpath_y.'; optpath_last_x, optpath_last_y]; 
        % "; optpath_last_x optpath_last_y "] can be deleted cause it is just used
        % to make it move back to original point

        % remake a figure to show the motion in the orginial picture.
        

        hinspect=figure('Name', 'Inspect Window');
        uicontrol('Style', 'popup',...
                   'String', 'gray|hsv|jet|hot|cool',...
                   'Position', [10 369 50 50],...
                   'Callback', @setmap); 
        uicontrol('String', 'Close','Position', [70 398 50 20], 'Callback', 'close(gcf)')

        vidRes = get( vid, 'VideoResolution' );
        nBands = get( vid, 'NumberOfBands' );
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
        preview(vid,hImage);
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        plot(optpath_show(:,1),optpath_show(:,2),'*-r')
        % �ӱ�ע˳�� mark the motion order

        for note_order=1:length(x)
            text(optpath(note_order,1),optpath(note_order,2),num2str(note_order),'FontSize',12)
        end

        set(ax2,'color','none')
        axis([0 sizey 0 sizex ]);
        
        um_size=size(optpath);
        I_um_ones=ones(um_size(1),1);
        ms_size=size(optpath);
        I_ms_ones=ones(ms_size(1),1);
        um_path_rotated = optpath*L_I_to_P_um*R_I_to_P_um+I_um_ones*I_to_P_con_um;
        ms_path_rotated = optpath*L_I_to_P_ms*R_I_to_P_ms+I_ms_ones*I_to_P_con_ms;
        
        No_points=size(ms_path_rotated);
        
        for mspath_order=1:No_points(1)
            ms_position=ms_path_rotated(mspath_order,:);
            angle_injection_ms (ms_position, z_safe_ms, zrefer_ms, relativeangle,com_no,FemtoJet,move_speed_ms,inject_speed_ms,delay_time);
        % angle_injection_um (um_position, z_safe_um, zrefer_um, relativeangle);
        end
        
        inj_msg=msgbox({'All points injected','Press to refresh'},'Msg');
        uiwait(inj_msg);
        
        delete(instrfindall);
        com_name = ['Com',com_no]; 
        s=serial(com_name,'BaudRate',19200);
        fopen(s);
        fprintf(s,'c005');
        fscanf(s);
        close(hinspect);
    end     



M_inject=uicontrol('String', 'Mouse Injection','Position', [450 398 100 20], 'Callback', {@Inject_M_ms ,move_speed_ms,inject_speed_ms,zrefer_ms,relativeangle}) ;

    function Inject_M_ms(hObject,event , move_speed_ms,inject_speed_ms,zrefer_ms,relativeangle)
        global L_I_to_P_um L_I_to_P_ms
        global R_I_to_P_um R_I_to_P_ms
        global I_to_P_con_um I_to_P_con_ms
        global z_safe_um z_safe_ms
        
        default_zrefer=zrefer_ms;
        default_z_safe=z_safe_ms;
        default_speed_xyz=move_speed_ms;
        default_speed_inject=inject_speed_ms;
        
        while 1
            
        [sizex sizey]=size(getsnapshot(vid)); 
        % if the image is not in '.tif', change to be "[sizex sizey zzz]=size(Image)"
        axis off
        ax2=axes('position',[0.13,0.11,0.775,0.815]);
        set(ax2,'color','none')  
        axis([0 sizey 0 sizex ]);
       
        
        [T_x,T_y,bottom]=ginput(1);

        % zspeed=str2double(get(handles.injuctspeed,'String'));
        % control the default speed


        if bottom == 1
        
            delete(instrfindall);
            com_name = ['Com',com_no]; 
            s=serial(com_name,'BaudRate',19200);
            fopen(s);
            fprintf(s,'c004');
            fscanf(s);
        
            Target=[T_x,T_y];
            
%%
            um_path_rotated = Target*L_I_to_P_um*R_I_to_P_um+I_to_P_con_um;
            ms_path_rotated = Target*L_I_to_P_ms*R_I_to_P_ms+I_to_P_con_ms;
        

            uicontrol('Style','text',...
                    'Position',[460 385 30 15],...
                    'String','Info��');

            hFeedback=uicontrol('Style','text',...
                    'Position',[490 385 60 15],...
                    'String','- -');
            %   um_position = [x, y]
            
            default_targetpostion=ms_path_rotated; %   ms_position = [x, y]

            % move to a place to that wants angle injection ƽ��ָ��λ��
           
            xposition0 = round(default_targetpostion (1));
            yposition0 = round(default_targetpostion (2));
%           zposition0 = round(default_z_safe);
            zposition0 = round(default_zrefer);

            outputp0_1=num2str(-zposition0);
            outputp0_2=num2str(yposition0);
            outputp0_3=num2str(-xposition0);


            x_v0=default_speed_xyz;
            y_v0=default_speed_xyz;
            z_v0=default_speed_xyz;

            outputv0_1=num2str(round(z_v0));
            outputv0_2=num2str(round(y_v0));
            outputv0_3=num2str(round(x_v0));
            
            
            delete(instrfindall);
            com_name = ['Com',com_no]; 
            s=serial(com_name,'BaudRate',19200);
            fopen(s);
            set(s, 'TimeOut', 0.02);
            actionmeter_0 = ['C006 ',outputp0_1,' ',outputp0_2,' ',outputp0_3,' ',outputv0_1,' ',outputv0_2,' ',outputv0_3];
            fprintf(s,actionmeter_0);


            while 1 
                drawnow

                info_m_0=fscanf(s);
                if isempty(info_m_0)== 1
                     drawnow
                else
                    info_m_0_cut=textscan(info_m_0, '%s %s'); %cut the info into cells
                    if     strcmpi(info_m_0_cut{1},'A006')  &&       strcmpi(info_m_0_cut{2},'0') % compare the char, ignore case
                        1;

                    elseif strcmpi(info_m_0_cut{1},'A006')  &&       strcmpi(info_m_0_cut{2},'1')
                        set(hFeedback,'string','STOPPED for hitting z upper limit ');

                    elseif strcmpi(info_m_0_cut{1},'A006')  &&       strcmpi(info_m_0_cut{2},'2')
                        set(hFeedback,'string','STOPPED for hitting z lower limit ');

                    elseif strcmpi(info_m_0_cut{1},'A006')  &&  8>str2double(info_m_0_cut{2}) && str2double(info_m_0_cut{2}) >=4
                        set(hFeedback,'string','STOPPED for hitting y lower limit ');

                    elseif strcmpi(info_m_0_cut{1},'A006')  && 16>str2double(info_m_0_cut{2}) && str2double(info_m_0_cut{2}) >=8
                        set(hFeedback,'string','STOPPED for hitting y upper limit ');   

                    elseif strcmpi(info_m_0_cut{1},'A006')  && 32>str2double(info_m_0_cut{2}) && str2double(info_m_0_cut{2}) >=16
                        set(hFeedback,'string','STOPPED for hitting x upper limit '); 

                    elseif strcmpi(info_m_0_cut{1},'A006')  &&    str2double(info_m_0_cut{2}) >= 32
                        set(hFeedback,'string','STOPPED for hitting x lower limit ');

                    else
                        set(hFeedback,'string',info_m_0);

                    end

                    break
                end
            end
            
            % Manual control
            
            delete(instrfindall);
            com_name = ['Com',com_no]; 
            s=serial(com_name,'BaudRate',19200);
            fopen(s);
            fprintf(s,'c005');
            fscanf(s);
            
%         elseif bottom ==2
%            
%            axis off
%            break; % 0 = to break
% 
%         else
            
% Pc control
            delete(instrfindall);
            com_name = ['Com',com_no]; 
            s=serial(com_name,'BaudRate',19200);
            fopen(s);
            fprintf(s,'C004');
            fscanf(s);
            
% obtain current location
            [~,Pcurrent_ms] = getposition(com_no);            
            xposition1=Pcurrent_ms(1);
            yposition1=Pcurrent_ms(2);
            zposition1=Pcurrent_ms(3);
            
% move back to get x space for injection.
            zrelative=zposition1-default_zrefer;
            xrelative=zrelative/tand(relativeangle);

            xposition2=xposition1-xrelative;
            yposition2=yposition1;
            zposition2=zposition1;

            outputp2_1=num2str(round(-zposition2));
            outputp2_2=num2str(round(yposition2));
            outputp2_3=num2str(round(-xposition2));

            x_v2=move_speed_ms;
            y_v2=move_speed_ms;
            z_v2=move_speed_ms;

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
                        set(hFeedback,'string','STOPPED for hitting z upper limit ');

                    elseif strcmpi(info_m_2_cut{1},'A006')  &&       strcmpi(info_m_2_cut{2},'2')
                        set(hFeedback,'string','STOPPED for hitting z lower limit ');

                    elseif strcmpi(info_m_2_cut{1},'A006')  &&  8>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=4
                        set(hFeedback,'string','STOPPED for hitting y lower limit ');

                    elseif strcmpi(info_m_2_cut{1},'A006')  && 16>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=8
                        set(hFeedback,'string','STOPPED for hitting y upper limit ');   

                    elseif strcmpi(info_m_2_cut{1},'A006')  && 32>str2double(info_m_2_cut{2}) && str2double(info_m_2_cut{2}) >=16
                        set(hFeedback,'string','STOPPED for hitting x upper limit '); 

                    elseif strcmpi(info_m_2_cut{1},'A006')  &&    str2double(info_m_2_cut{2}) >= 32
                        set(hFeedback,'string','STOPPED for hitting x lower limit ');

                    else
                        set(hFeedback,'string',info_m_2);

                    end

                    break
                end
            end
% injection

            xposition3=xposition1;
            yposition3=yposition1;
            zposition3=zrefer_ms;

            outputp3_1=num2str(round(-zposition3));
            outputp3_2=num2str(round(yposition3));
            outputp3_3=num2str(round(-xposition3));

            x_v3=inject_speed_ms/tand(relativeangle);
            y_v3=y_v2;
            z_v3=inject_speed_ms;

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
                        set(hFeedback,'string','STOPPED for hitting z upper limit ');

                    elseif strcmpi(info_m_3_cut{1},'A006')  &&       strcmpi(info_m_3_cut{2},'2')
                        set(hFeedback,'string','STOPPED for hitting z lower limit ');

                    elseif strcmpi(info_m_3_cut{1},'A006')  &&  8>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=4
                        set(hFeedback,'string','STOPPED for hitting y lower limit ');

                    elseif strcmpi(info_m_3_cut{1},'A006')  && 16>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=8
                        set(hFeedback,'string','STOPPED for hitting y upper limit ');   

                    elseif strcmpi(info_m_3_cut{1},'A006')  && 32>str2double(info_m_3_cut{2}) && str2double(info_m_3_cut{2}) >=16
                        set(hFeedback,'string','STOPPED for hitting x upper limit '); 

                    elseif strcmpi(info_m_3_cut{1},'A006')  &&    str2double(info_m_3_cut{2}) >= 32
                        set(hFeedback,'string','STOPPED for hitting x lower limit ');

                    else
                        set(hFeedback,'string',info_m_3);

                    end

                    break
                end
            end
% FemtoJet
            pause(delay_time);

% poll back

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
                        set(hFeedback,'string','STOPPED for hitting z upper limit ');

                    elseif strcmpi(info_m_4_cut{1},'A006')  &&       strcmpi(info_m_4_cut{2},'2')
                        set(hFeedback,'string','STOPPED for hitting z lower limit ');

                    elseif strcmpi(info_m_4_cut{1},'A006')  &&  8>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=4
                        set(hFeedback,'string','STOPPED for hitting y lower limit ');

                    elseif strcmpi(info_m_4_cut{1},'A006')  && 16>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=8
                        set(hFeedback,'string','STOPPED for hitting y upper limit ');   

                    elseif strcmpi(info_m_4_cut{1},'A006')  && 32>str2double(info_m_4_cut{2}) && str2double(info_m_4_cut{2}) >=16
                        set(hFeedback,'string','STOPPED for hitting x upper limit '); 

                    elseif strcmpi(info_m_4_cut{1},'A006')  &&    str2double(info_m_4_cut{2}) >= 32
                        set(hFeedback,'string','STOPPED for hitting x lower limit ');

                    else
                        set(hFeedback,'string',info_m_4);

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
                        set(hFeedback,'string','STOPPED for hitting z upper limit ');

                    elseif strcmpi(info_m_5_cut{1},'A006')  &&       strcmpi(info_m_5_cut{2},'2')
                        set(hFeedback,'string','STOPPED for hitting z lower limit ');

                    elseif strcmpi(info_m_5_cut{1},'A006')  &&  8>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=4
                        set(hFeedback,'string','STOPPED for hitting y lower limit ');

                    elseif strcmpi(info_m_5_cut{1},'A006')  && 16>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=8
                        set(hFeedback,'string','STOPPED for hitting y upper limit ');   

                    elseif strcmpi(info_m_5_cut{1},'A006')  && 32>str2double(info_m_5_cut{2}) && str2double(info_m_5_cut{2}) >=16
                        set(hFeedback,'string','STOPPED for hitting x upper limit '); 

                    elseif strcmpi(info_m_5_cut{1},'A006')  &&    str2double(info_m_5_cut{2}) >= 32
                        set(hFeedback,'string','STOPPED for hitting x lower limit ');

                    else
                        set(hFeedback,'string',info_m_5);

                    end

                    break
                end
            end

            delete(instrfindall);
            com_name = ['Com',com_no]; 
            s=serial(com_name,'BaudRate',19200);
            fopen(s);
            fprintf(s,'C005');
            fscanf(s);
            %%
                elseif bottom ==2
           
           axis off
           break; % 0 = to break

        else
            1;
%%
        end
        end
    end
%%

ExposureTime=uicontrol('Style', 'edit',...
        'String',0.06,...
        'Position', [5 20 100 20],...
       'callback',@ExposureTime_callback);
   
   function ExposureTime_callback(hObject,event)
        set(srcObj1(1),'ExposureTime',str2double(get(hObject,'string')));
   end

    %'Callback', ['set(srcObj1(1),''ExposureTime'',get(handles.ExposureTime,''value''));set(hExposureTime,''string'',[''ExposureTime '',num2str(round(get(handles.ExposureTime,''value'')*1000)/1000)])']);

    % 1  'Callback','set(hExposureTime,''string'',get(ExposureTime,''value''))')
    % 2  'Callback', ['set(srcObj1(1),''ExposureTime'',get(ExposureTime,''value''));set(hExposureTime,''string'',[''ExposureTime'',get(ExposureTime,''value''))'])
    % 3  'Callback', [{@setExposureTime,srcObj1(1)})
   
    Gain=uicontrol('Style', 'slider',...
        'Min',0,'Max',255,'Value',50,...
        'Position', [115 20 100 20],...
         'Callback', @Gain_callback);
     
    function Gain_callback(hObject,event)
        set(srcObj1(1),'Gain',get(hObject,'value'));
        set(hGain,'string',['Gain ',num2str(round(get(hObject,'value')))])
    end  

    Offset=uicontrol('Style', 'slider',...
        'Min',0,'Max',255,'Value',125,...
        'Position', [225 20 100 20],...
        'callback',@Offset_callback);
    
    function Offset_callback(hObject,event)
        set(srcObj1(1),'Offset',get(hObject,'value'));
        set(hOffset,'string',['Offset ',num2str(round(get(hObject,'value')))])
    end   
   
    ContrastGain=uicontrol('Style', 'slider',...
        'Min',1,'Max',255,'Value',255,...
        'Position', [335 20 100 20],...
        'callback',@ContrastGain_callback);
    
    function ContrastGain_callback(hObject,event)
        set(srcObj1(1),'ContrastGain',get(hObject,'value'));
        set(hContrastGain,'string',['Contrast Gain ',num2str(round(get(hObject,'value')))])
    end  
     
    ContrastOffset=uicontrol('Style', 'slider',...
        'Min',0,'Max',255,'Value',130,...
        'Position', [445 20 100 20],...
        'callback',@ContrastOffset_callback);
    
    function ContrastOffset_callback(hObject,event)
        set(srcObj1(1),'ContrastOffset',get(hObject,'value'));
        set(hContrastOffset,'string',['Contrast Offset ',num2str(round(get(hObject,'value')))])
    end  

    %%
    hExposureTime=uicontrol('Style','text',...
        'Position',[5 5 101 15],...
        'String',['ExposureTime ']);
    
    hGain=uicontrol('Style','text',...
        'Position',[115 5 100 15],...
        'String',['Gain ',num2str(get(Gain,'Value'))]);
    
    hOffset=uicontrol('Style','text',...
        'Position',[225 5 100 15],...
        'String',['Offset ',num2str(get(Offset,'Value'))]);
    
    hContrastGain=uicontrol('Style','text',...
        'Position',[335 5 100 15],...
        'String',['Contrast Gain ',num2str(get(ContrastGain,'Value'))]);
    
    hContrastOffset=uicontrol('Style','text',...
        'Position',[445 5 100 15],...
        'String',['Contrast Offset ',num2str(get(ContrastOffset,'Value'))]);
    

%%
try 
    hImage = image(zeros(vidRes(2), vidRes(1), nBands) );
catch
    vid = videoinput('hamamatsu', 1, 'MONO16_1344x1024');
    vidRes = get( vid, 'VideoResolution' );
    nBands = get( vid, 'NumberOfBands' );
    srcObj1 = get(vid, 'Source');
    hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
end

p_figure=get(gcf,'position');
set(gcf,'position',[230 240 p_figure(3) p_figure(4)]);
preview(vid,hImage);
uiwait;
end 