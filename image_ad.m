function []=image_ad()
global vid
global Cam_image
frame = getsnapshot(vid);
I_ad=imadjust(frame);
I_fi=filter2(fspecial('average',4),I_ad)/5e4;
imshow(I_fi);
end