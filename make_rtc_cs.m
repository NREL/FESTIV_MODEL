function [rtc_num, rtc_text] = make_rtc_cs(mo,month,date1, irtc, prtc)
% make SCUC and SCED files. Command line example:
%  for date=24:30 ; [~,~]=make_rtc_cs(7,'July',date, 60, 15) ; end
%%definitions:
 local = 'Input\'; % local directory
  remote = 'Y:\6A20\Public\RELM\FESTIV\solar_APS\clear_sky_APS_60min\';
   %mo = 7;  month = 'July'; date1 = 24; % these are f-n inputs
    xl = '.xls'; csv = '.csv';
     vg_prefx = 'APS_wind_SC2_'; % needs mo/date to build the file name
      rtc_prefx = 'RTC_APS_VG_forecast_'; rtc_suffx = '_at60min'; % needs mo/date...
       cs_prefx = 'CLEAR_Bus_'; cs_suffx = '_PV_60Min_SC1_2006_2020'; % needs BUS#... 
        %irtc=60; prtc=15; %hrtc=3;  hrtc and irtc are not needed (the left 2 columns of the file determine these parameters)
     
% read actual VG (one mins)
 vg_file = [local, vg_prefx, num2str(mo),'_',num2str(date1), xl];
  [vg_num, ~,~] = xlsread(vg_file); %('Input\APS_wind_SC2_7_24.xls');
    % select vg data
     nvg=size(vg_num,1); hours = vg_num(1:irtc:nvg,1); % hourly, from 1-min data
      vg_hourly = vg_num(1:irtc:nvg,:);
       vg_hourly(2:size(vg_hourly,1),:)=vg_num((irtc-prtc):irtc:(nvg-irtc),:);

% read forecast file (for output format, reference)
 rtc_file = [local, rtc_prefx, month,num2str(date1),rtc_suffx,xl];
  [rtc_num, rtc_text,~] = xlsread(rtc_file);%('Input\RTC_APS_VG_forecast_July24_at60min.xls');
% scan rtc file by columns (generators) and set the forecast:
 for j=3:size(rtc_num,2)
  gen_name = rtc_text(j); % analyze the generator name (this line & next 2)
   vg_type=regexprep(gen_name,'_SC2_APS_\d+','');
    bus_ = regexprep(gen_name, '\w+_SC2_APS_', ''); bus = bus_{1};
     %a=[num2str(j) gen_name{1} vg_type bus]; a
     if strcmp('PV',vg_type) % read clear sky index
      cs_file = [remote, cs_prefx, bus, cs_suffx, csv]; %cs_file
       [cs_num, ~,~] = xlsread(cs_file);%('Y:\6A20\Public\RELM\FESTIV\solar_APS\clear_sky_APS_60min\CLEAR_Bus_14000_PV_60Min_SC1_2006_2020.csv');
        row = 0; rows = size(cs_num,1); condition = (1==0);
         % find the relevant row in the clear sky matrix:
          while row<rows && ~condition; row=row+1; condition=(cs_num(row,2)==mo && cs_num(row,3)==date1); end; 
           today_cs_ = cs_num(row,4:size(cs_num,2)); % the whole row of data for the day
            n_cs=size(today_cs_,2); ncs_per_hr= n_cs/24; ncs_per_i=ncs_per_hr*60/irtc;
             today_cs = cs_num(row,4:ncs_per_i:size(cs_num,2)); % just the required data
              %if max(today_cs)<max(vg_hourly(:,j-1)); today_cs=today_cs*(max(vg_hourly(:,j-1))/max(today_cs)); end
               ncs=size(today_cs,2); today_cs(3:ncs)=today_cs(1:(ncs-2)); % shift CS index by 2 hrs
     end % if PV
   for i=1:size(rtc_num,1) % scan rtc column by row
    time_from = rtc_num(i,1); time_to = rtc_num(i,2);
     i0=0;c=(1==0);while i0<size(hours,1)&&~c;i0=i0+1;c=(hours(i0)==time_from);end
      i1=0;c=(1==0);while i1<size(hours,1)&&~c;i1=i1+1;c=(hours(i1)==time_to);end
       perf = vg_hourly(i1, j-1); persis = vg_hourly(i0, j-1);
        if time_to>time_from
         rtc_num(i,j) = persis; % default forecast: persistent
          if strcmp('CSP',vg_type); rtc_num(i,j)=perf; end % perfect forecast for CSP
           if strcmp('PV',vg_type) % include clear sky index forecast for PV
            cs_now = today_cs(i0); cs_then = today_cs(i1);
             if cs_now>persis; c_s_i= persis/cs_now; else c_s_i=1; end
              rtc_num(i,j)=persis +c_s_i*(cs_then-cs_now);% *cs_then/(cs_now+0.05);% 
               if rtc_num(i,j)<0; rtc_num(i,j)= 0; end
           end % PV
        end % skip forecast from yesterday onto today
   end % scanning column of rtc by row
 end % scanning rtc by columns
 
% save modified forecast file:
 new_file = [local, rtc_prefx, month,num2str(date1),rtc_suffx,'_mod',xl];
  %headers_range = ['A1:A',num2str(size(rtc_num,2))]; cols=size(rtc_num,2);
   %if cols>26; col=[char(64+floor(cols/26)),char(64+mod(cols+1,26+1))]; else col=[char(64+mod(cols+1,26+1))]; end
    %numbers_range = ['A2:',col,num2str(size(rtc_num,1)+1)];
     xlswrite(new_file,rtc_text);
      xlswrite(new_file,rtc_num,'Sheet1','A2');
  
  