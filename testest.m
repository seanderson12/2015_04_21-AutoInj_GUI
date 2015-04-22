capacitor_out=1.2287*10^-12
stop_flag=1;
while 1
    

        default_path='\\169.254.13.253\Anderson_Share\test\';
        [file,path] = uigetfile({'*.dat';'*.*'},'Load Dat File',default_path);
        %make path for data file
        h_fid=fullfile(path,file)
        if isequal(h_fid,0)
            disp('File select cancelled')
        end
        
fid = fopen(h_fid,'r');
%testing for read data in float 32.
capacitor_info = fread(fid,'float32');
% want the last 50-20 points 
duration=0.1;
capacitor_info=capacitor_info(end-duration*10000-3:end-duration*10000);
capacitor_current=mean(capacitor_info)
plot(capacitor_info);
fclose(fid);
critical_percentage=0.025;
if (1+critical_percentage) >(capacitor_current/capacitor_out) && (capacitor_current/capacitor_out) > (1-critical_percentage) 

    stop_flag=0
end
%tb.TimerFcn = @(x,y)preview(vid,hImage);
end