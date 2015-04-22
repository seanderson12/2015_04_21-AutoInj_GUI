% 
% wave_timer_HEKA= timer('Name','ButtonTimer','StartDelay', 0,'Period', 0.2 ,...
%                    'ExecutionMode','fixedRate',...
%                    'StartFcn','[hwave,Cbox]=wave_init();',...
%                    'StopFcn','wave_stop(hwave);',...
%                    'TimerFcn','wave_show(hwave,Cbox);');
% 

function [hwave,CapacitorTextBox]=wave_init()
global stop_flag
global h_fid
global capacitor_out
duration=1;

stop_flag=0;

%% location of the dat
fid = fopen(h_fid,'r');
%testing for read data in float 32.
capacitor_info = fread(fid,'float32');
% target piont set 
capacitor_target=capacitor_info(end-duration*10000-10:end-duration*10000);
% boarder piont set
capacitor_boarder=capacitor_info(end-duration*10000-30:end-duration*10000-10);

if( (isnan(capacitor_target/capacitor_boarder)) || (capacitor_target/capacitor_boarder<0.9) ||  (capacitor_target/capacitor_boarder> 1.1)  )
    capacitor_out = meam(capacitor_info(end-duration*10000-40:end-duration*10000-30));
else
    capacitor_out=mean(capacitor_target);
end


%% Figure
hwave=figure();
set(hwave, 'MenuBar', 'none');
set(hwave, 'ToolBar', 'none');
set(hwave,'Position',[950 500 250 150]);
CapacitorTextBox= uicontrol('style','text');
set(CapacitorTextBox,'Position',[80 -135 100 150]);
set(CapacitorTextBox,'String','C is: ------');

end
