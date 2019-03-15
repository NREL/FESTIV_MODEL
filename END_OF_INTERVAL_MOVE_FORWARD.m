AGC_interval_index = AGC_interval_index + 1;
second = second + t_AGC; 
if(second >= 60)
    minute = minute + floor((second+eps)/60);
    second = floor(mod(second+eps,60));
end;
if(minute >= 60)
    hour = hour + floor(minute/60);
    minute = floor(mod((minute+eps),60));
end;
if(hour >= 24)
    hour = 0;
    day = day+1;
end;

time = day*24 + hour + minute/60 + second/(60*60);
rtscuc_update = rtscuc_update + t_AGC/60;
rtsced_update = rtsced_update + t_AGC/60;
dascuc_update = dascuc_update + t_AGC/(60*60);
