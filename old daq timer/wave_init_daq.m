function [hwave,hdevice,CapacitorTextBox, capacitor, df]=wave_init(varargin)

capacitor=[];

hwave=figure();
set(hwave, 'MenuBar', 'none');
set(hwave, 'ToolBar', 'none');
set(hwave,'Position',[950 500 250 150]);
CapacitorTextBox= uicontrol('style','text');
set(CapacitorTextBox,'Position',[80 -135 100 150]);
set(CapacitorTextBox,'String','C is: ------');


%device initial
device=daq.getDevices;

%% Device
%create session
hdevice=daq.createSession('ni');
%add channel from 'myDAQ1'
%ai=analoginput

addAnalogInputChannel(hdevice,'myDAQ1', 0:1, 'Voltage');

%s.addAnalogInputChannel('myDAQ1', 'ai1', 'Voltage')


%%
% Will run for s.DurationInSeconds (0.1) second (2000 scans) 
% eg. at 20000 scans/second.
hdevice.Rate=40000;
hdevice.DurationInSeconds=0.004;
%s.Channels.Range=[-2 2];

%%
%configure channel property
tc=hdevice.Channels(1);

%setting the property
set(tc)
tc.Coupling = 'DC'; %'DC' or 'AC'
tc.TerminalConfig = 'Differential'; 

df=designfilt('lowpassfir','FilterOrder',70,'CutoffFrequency',1,'SampleRate', 40);

end
