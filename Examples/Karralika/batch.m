[r,m,q] = karralikaMain(0.04,30.0);
swSaveToAscii(r,m,q,'karralika0.dat');
clear
!gzip karralika0.dat
