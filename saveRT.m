function saveRT(model,binding_interval_index,P,hour,minute,sPRODCOST,sGENSCHEDULE,sLMP,sUNITSTATUS,sLINEFLOW,sRESERVETYPE,nreserve,sGENRESERVESCHEDULE,sRCP,nbranch,sBRANCHDATA,sBRANCH,H,sLINEFLOWCTGC)

if binding_interval_index <= 2
    minute_initial = minute - P;
    if minute_initial < 0
        minute_initial = 60 + minute_initial;
        hour_initial = hour - 1;
    else
        hour_initial = hour;
    end;
    if hour_initial < 0
        hour_initial = 24 - 1;
        yesterday=1;
    else
        yesterday=0;
    end;
    
    if (hour_initial < 10)
        hstring = [num2str(0),num2str(hour_initial)];
    else
        hstring = num2str(hour_initial);
    end;
    if(minute_initial<10)
        mstring = [num2str(0),num2str(minute_initial)];
    else
        mstring = num2str(minute_initial);
    end;
    if yesterday ==1
        outputfile = [model,'OUTPUT', filesep,model,'_OUTPUT',hstring,mstring,'YESTERDAY','.xls'];
    else
        outputfile = [model,'OUTPUT', filesep,model,'_OUTPUT',hstring,mstring,'.xls'];
    end;
else
    if (hour < 10)
        hstring = [num2str(0),num2str(hour)];
    else
        hstring = num2str(hour);
    end;
    if(minute<10)
        mstring = [num2str(0),num2str(minute)];
    else
        mstring = num2str(minute);
    end;
    outputfile = [model,'OUTPUT', filesep,model,'_OUTPUT',hstring,mstring,'.xls'];
end

if (exist(outputfile,'file') == 2)
    delete (outputfile);
end;
xlswrite(outputfile,sPRODCOST,'prodcost') ;
xlswrite(outputfile,sGENSCHEDULE,'genschedule')  ;
xlswrite(outputfile,sLMP,'lmp price')  ;
xlswrite(outputfile,sUNITSTATUS,'unit status')  ;
xlswrite(outputfile,sLINEFLOW,'line flow') ;
r =1;
while(r<=nreserve)
    reservesheet = cell2mat([sRESERVETYPE(1,r),'_reserve_schedule']);
    xlswrite(outputfile,sGENRESERVESCHEDULE(:,:,r),reservesheet)  ;
    r=r+1;
end;
xlswrite(outputfile,sRCP,'RCP')  ;
b = 1;
while(b<=nbranch)
    if(sBRANCHDATA(b,ctgc_monitor) == 1)
        ctgclineflowsheet = cell2mat([sBRANCH(1,b),'contingency line flow']);
        RTCLINEFLOWCTGC_TMP(1:nbranch,1:H) = sLINEFLOWCTGC(b,:,:);
        xlswrite(outputfile,RTCLINEFLOWCTGC_TMP,ctgclineflowsheet)  ;
    end;
    b=b+1;
end;

end % end function