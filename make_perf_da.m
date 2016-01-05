function dummy = make_perf_da(target_file)
% make SCUC and SCED files. Command line example:
%  use: make_perf_da()
%%definitions:
 local = 'Input\'; % local directory
  if strcmp(target_file,''); target_file='WWSIS_c_RT_CoreB_M07_APS_60MinFc_persisCS_perfDA'; end
   target_tab='VG_FORECAST';
    mo = 7;  month = 'July'; date1 = 24; days=7; % these are f-n inputs
     xl = '.xls'; % csv = '.csv';
      vg_prefx = 'APS_wind_SC2_'; % needs mo/date to build the file name
     
% read actual VG (one mins) for the whole week
for day = 1:days
 vg_file = [local, vg_prefx, num2str(mo),'_',num2str(date1-1+day), xl];
  [vg_num, ~,~] = xlsread(vg_file); %('Input\APS_wind_SC2_7_24.xls');
   if day==1; vg_all=vg_num; else vg_all=[vg_all; vg_num]; end % append vg data
end % day from 1 to 7

% from one-min data to hour-average:
 vg_hourly = zeros(24*days,size(vg_num,2)+1); hrs=24*days; mins=hrs*60;
  for hr=1:(24*days)
   vg_hourly(hr,1)= 1+floor((hr-1)/24); vg_hourly(hr,2)=mod(hr-1,24);
    for i_gen = 2:size(vg_all,2); c_m=60*(hr-1); 
     if hr>1&&hr<hrs; vg_hourly(hr,i_gen+1)=sum(vg_all((c_m-29):(c_m+30),i_gen))/60; end
      if hr==1; vg_hourly(hr,i_gen+1)=sum(vg_all(1:30,i_gen))/30; end
       if hr==hrs; vg_hourly(hr,i_gen+1)=sum(vg_all((mins-29):(mins),i_gen))/30; end
    end % each i_gen
  end % each hr
  
 dummy = xlswrite([local,target_file,xl],vg_hourly,target_tab,'A2');
