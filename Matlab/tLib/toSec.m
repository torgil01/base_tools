function stime=toSec(dtime)
% Convert time hhmmss.ms to seconds
% $Id: toSec.m,v 1.1.1.1 2004/04/15 15:02:59 ToVan Exp $
hour=floor(dtime/10000);
minute=floor((dtime-10000*hour)/100);
sec=floor(dtime-10000*hour - 100*minute);
msec=dtime-floor(dtime);
stime=msec + sec + 60*minute + 3600*hour;
return
