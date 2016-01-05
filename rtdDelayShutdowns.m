function [delayed_shutdown,LAST_STATUSVAR_VAL,RTSCUCSCHEDULE,RTSCUCCOMMITMENT,STATUSVAR,SHUTTINGDOWN_VAL,STATUSVAR_VAL,PUMPINGUP_VAL,PUMPINGVAR_VAL,STATUSVAR2,RTSCUCCOMMITMENT2,RTSCUCSCHEDULE2] ... 
            =rtdDelayShutdowns(delayed_shutdown,actgennow,actSTATUSVARnow,lastgennow,lastSTATUSVARnow,SHUTTINGDOWN_VAL,INTERVAL_MINUTES_VAL,UNITVALUE,ramp_rate_index,PRTD,min_gen_index,IRTD,HRTD,IRTC,RTSCEDSCHEDULE,STATUSVAR_VAL,STATUSVAR,RTSCUC_binding_interval_index,HRTC,RTSCUCCOMMITMENT,RTSCUCSCHEDULE,LAST_STATUSVAR_VAL,STATUSVAR2,RTSCUCCOMMITMENT2,RTSCUCSCHEDULE2,PUMPINGUP_VAL,PUMPINGVAR_VAL,md_time_index,UNITVALUE2,mr_time_index,eps,gen_types,RTSCED_binding_interval_index)
try
    
for i=1:size(UNITVALUE.val,1)
    try
        numberofintervals(i,1)=find(SHUTTINGDOWN_VAL(i,:),1,'first');
    catch
        numberofintervals(i,1)=0;
    end
    totaltime(i,1)=sum(INTERVAL_MINUTES_VAL(1:max(1,numberofintervals(i,1)-1),1)); 
end
totalramp=UNITVALUE.val(:,ramp_rate_index).*totaltime;
totalramp2=UNITVALUE.val(:,ramp_rate_index).*(totaltime+PRTD);
minimumpossible=max(0,actgennow-(totalramp2.*actSTATUSVARnow));
lastminimumpossible=max(0,lastgennow-(totalramp.*lastSTATUSVARnow));
% number of additional RTD intervals required to SD
X1=max(0,ceil((minimumpossible-UNITVALUE.val(:,min_gen_index))./(UNITVALUE.val(:,ramp_rate_index)*IRTD)));
X2=max(0,ceil((lastminimumpossible-UNITVALUE.val(:,min_gen_index))./(UNITVALUE.val(:,ramp_rate_index)*IRTD)));
X3=max(X1,X2);X7=min(X3,HRTD);
X4=ceil(X3./(IRTC/IRTD));
for i=1:size(UNITVALUE.val,1)
    if md_time_index == 0
        min_down_time=0;
    else
        min_down_time=UNITVALUE.val(i,md_time_index);
    end  
    if RTSCED_binding_interval_index == 1
        delaycondition=(numberofintervals(i,1) >= 1 && (((minimumpossible(i,1) - UNITVALUE.val(i,min_gen_index) > eps) || ((lastminimumpossible(i,1) - UNITVALUE.val(i,min_gen_index) > eps))) && (RTSCEDSCHEDULE(RTSCED_binding_interval_index,i+1) > UNITVALUE.val(i,min_gen_index)))) && ( gen_types(i) ~= 7 && gen_types(i) ~= 10 && gen_types(i) ~= 17 );
    else
        delaycondition=(numberofintervals(i,1) >= 1 && (((minimumpossible(i,1) - UNITVALUE.val(i,min_gen_index) > eps) || ((lastminimumpossible(i,1) - UNITVALUE.val(i,min_gen_index) > eps))) || (((abs(RTSCEDSCHEDULE(max(RTSCED_binding_interval_index-2,1),i+1)-RTSCEDSCHEDULE(RTSCED_binding_interval_index-1,i+1))-IRTD*UNITVALUE.val(i,ramp_rate_index))) > eps) && (RTSCEDSCHEDULE(RTSCED_binding_interval_index-1,i+1) > UNITVALUE.val(i,min_gen_index)))) && ( gen_types(i) ~= 7 && gen_types(i) ~= 10 && gen_types(i) ~= 17 );
    end
    if delaycondition
        % shift appropriate shutdown variable for current model solve
        Y=circshift(SHUTTINGDOWN_VAL(i,:)',X7(i,1))';
        Y(1,1:X7(i,1))=0;
        SHUTTINGDOWN_VAL(i,:)=Y;
        Y=circshift(PUMPINGUP_VAL(i,:)',X7(i,1))';
        Y(1,1:X7(i,1))=0;
        PUMPINGUP_VAL(i,:)=Y;
        
        % shift appropriate startup variable for current model solve
        Y=circshift(STATUSVAR_VAL(i,:)',X7(i,1))';
        Y(1,1:X7(i,1))=1;
        STATUSVAR_VAL(i,:)=Y;
        Y=circshift(PUMPINGVAR_VAL(i,:)',X7(i,1))';
        Y(1,1:X7(i,1))=0;
        PUMPINGVAR_VAL(i,:)=Y;
        
        % update RTC STATUSVAR
        X5=STATUSVAR(RTSCUC_binding_interval_index-1:RTSCUC_binding_interval_index+HRTC-2,i);
        X6=find(X5,1,'last')+1; % start of offline
        sizetemp=RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1);
        STATUSVAR(RTSCUC_binding_interval_index-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)-1),i)=1;
        STATUSVAR(RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1),i)= X5(1:size(sizetemp,2),1);
        STATUSVAR(RTSCUC_binding_interval_index-1+X4(i,1)+X6-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1-1+X6+(min_down_time*60/IRTC)),i)=0;
        
        RTSCUCCOMMITMENT(RTSCUC_binding_interval_index-1:RTSCUC_binding_interval_index-1+X4(i,1)-1,i+1)=1;
        RTSCUCCOMMITMENT(RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1),i+1)=X5(1:size(sizetemp,2),1);
        RTSCUCCOMMITMENT(RTSCUC_binding_interval_index-1+X4(i,1)+X6-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1-1+X6+(min_down_time*60/IRTC)),i+1)=0;
        
        % update RTC schedules
        X5=RTSCUCSCHEDULE(RTSCUC_binding_interval_index-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index+HRTC-2),i+1);
        X6=find(X5,1,'last')+1; % start of offline
        beginint=RTSCUCSCHEDULE(RTSCUC_binding_interval_index-2,i+1);
        endint=X5(1,1);
        tempsch=zeros(X4(i,1),1);
        for tempschcount=1:X4(i,1)
            tempsch(tempschcount,1)=max(UNITVALUE.val(i,min_gen_index),beginint-(beginint-endint)/(X4(i,1)+1)*tempschcount);
        end
        sizetemp=RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1);
        RTSCUCSCHEDULE(RTSCUC_binding_interval_index-1:RTSCUC_binding_interval_index-1+X4(i,1)-1,i+1)=tempsch;
        RTSCUCSCHEDULE(RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1),i+1)=X5(1:size(sizetemp,2),1);
        RTSCUCSCHEDULE(RTSCUC_binding_interval_index-1+X4(i,1)+X6-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1-1+X6+(min_down_time*60/IRTC)),i+1)=0;
       
        % delay startup if necessary
        X9=RTSCUCSCHEDULE2(RTSCUC_binding_interval_index-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index+HRTC-2),i+1);
        X10=find(X9,1,'first')+1; % start of online
        beginint=RTSCUCSCHEDULE2(RTSCUC_binding_interval_index-2,i+1);
        endint=X9(1,1);
        tempsch=zeros(X4(i,1),1);
        for tempschcount=1:X4(i,1)
            tempsch(tempschcount,1)=0;
        end
        sizetemp=RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1);
        RTSCUCSCHEDULE2(RTSCUC_binding_interval_index-1:RTSCUC_binding_interval_index-1+X4(i,1)-1,i+1)=tempsch;
        RTSCUCSCHEDULE2(RTSCUC_binding_interval_index-1+X4(i,1):min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1+X4(i,1)+HRTC-1),i+1)=X9(1:size(sizetemp,2),1);
        RTSCUCSCHEDULE2(RTSCUC_binding_interval_index-1+X4(i,1)+X10-1:min(size(STATUSVAR,1),RTSCUC_binding_interval_index-1-1+X10+(UNITVALUE2.val(i,mr_time_index)*60/IRTC)),i+1)=X9(find(X9,1,'first'));
        STATUSVAR2(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+find((RTSCUCSCHEDULE2(RTSCUC_binding_interval_index:end,i+1)),1,'first')-2,i)=0; %pump
        RTSCUCCOMMITMENT2(1:size(STATUSVAR2,1),i+1)=STATUSVAR2(:,i);
        LAST_STATUSVAR_VAL(i,1)=any(lastgennow(i,1));
        delayed_shutdown(i,1)=1;
    end
end


catch
    s = lasterror; 
    Stack  = dbstack;
    stoppingpoint=Stack(1,1).line+4;
    stopcommand=sprintf('dbstop in rtdDelayShutdowns.m at %d',stoppingpoint);
    eval(stopcommand);
    s;
end

end %end function