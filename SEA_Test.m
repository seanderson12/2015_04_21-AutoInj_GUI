fid = fopen('\\169.254.13.253\Anderson_Share\test\ss2.dat','r');
%testing for read data in float 32.
capacitor_info = fread(fid,'float32');
plot(capacitor_info);
set(gca,'YLim',[0,10e-11]);
capacitor_currentinfo1=capacitor_info(66061:66071);
%capacitor_currentinfo1=capacitor_info(66100:66110);
capacitor_currentinfo2=capacitor_info(66100:66110);
isnan(mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)) || mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)<0.9 || mean(capacitor_currentinfo1)/mean(capacitor_currentinfo2)>1.1