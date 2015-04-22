function wave_show(hwave,Cbox)
global h_fid
global stop_flag
global capacitor_out
duration=1;
critical_percentage=0.025;

%% location of the dat
fid = fopen(h_fid,'r');
%testing for read data in float 32.
capacitor_info = fread(fid,'float32');
% want the last 3 points 
capacitor_currentinfo1=capacitor_info(end-duration*10000-3:end-duration*10000);
capacitor_currentinfo2=capacitor_info(end-duration*10000-3:end-duration*10000);

while ( isnan(mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)) || mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)<0.9 || mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)>1.1)
fclose(fid);
fid = fopen(h_fid,'r');
%testing for read data in float 32.
capacitor_info = fread(fid,'float32');
% want the last 3 points 
capacitor_currentinfo1=capacitor_info(end-duration*10000-3:end-duration*10000);
capacitor_currentinfo2=capacitor_info(end-duration*10000-3:end-duration*10000);
end

capacitor_current=mean(capacitor_currentinfo1);
fclose(fid);

%% Show
set(0, 'CurrentFigure', hwave);

if (1+critical_percentage) >(capacitor_current/capacitor_out) && (capacitor_current/capacitor_out) > (1-critical_percentage) 
    hold off
    plot([0,1],[capacitor_out,capacitor_out]);
    hold on
    plot(0.5, capacitor_current,'r*')
    stop_flag=0;
    set(gca,'YLim',[0,1.3*capacitor_current])
else
    plot([0,1],[0,1.3*capacitor_current]);
    hold on
    plot([0,1],[1.3*capacitor_current,0]);
    stop_flag=1;
end
set(Cbox,'String',['C is: ', num2str(capacitor_current)]);

end