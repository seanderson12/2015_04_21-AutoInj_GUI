function [um_position, ms_position] = getposition(com_no_1)
%% um
delete(instrfindall);
com_name = ['Com',com_no_1];  
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c010')
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells
%%
    zloc=-str2double(info{2});
    yloc=str2double(info{3});
    xloc=-str2double(info{4});
um_position= [xloc yloc zloc];

%% ms
   delete(instrfindall);
% com_name = ['Com',get(handles.com_no,'String')]; 
s=serial(com_name,'BaudRate',19200);
fopen(s);
fprintf(s,'c009')
infoo=fscanf(s);
info=textscan(infoo, '%s %s %s %s %s'); %cut the info into cells
%%
    zloc=-str2double(info{2});
    yloc=str2double(info{3});
    xloc=-str2double(info{4});
ms_position = [xloc yloc zloc];
