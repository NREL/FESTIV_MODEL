if exist('multiplefilecheck')==1
    if multiplefilecheck == 0
        if autosavecheck==1
            print_final_results = outputname;
        else
            print_final_results = input('Please type a filename to save the final results. Otherwise press enter.\n             (NOTE: Only open figures will be saved)\n','s');
            outputname = print_final_results;
        end
    else
        print_final_results = outputname;       
    end
else
    print_final_results = input('Please type a filename to save the final results. Otherwise press enter.\n             (NOTE: Only open figures will be saved)\n','s');
    outputname = print_final_results;
end
%PRINT RESULTS TO SPREADSHEET

if isempty(print_final_results) == 1
else
    mkdir('OUTPUT', print_final_results);
    fprintf('\nSaving Output Files...');
    f=strcat('OUTPUT', filesep,print_final_results, filesep);
    currentdir=pwd;
    print_final_results1 = strcat('OUTPUT',filesep,print_final_results,filesep ,print_final_results,' Summary.xlsx');
    print_final_results2 = strcat('OUTPUT',filesep,print_final_results,filesep,print_final_results,' Details.xlsx');
    dir1=fullfile(currentdir,print_final_results1);
    dir2=fullfile(currentdir,print_final_results2);

    % create excel column indexing reference
    Alphabet=char('A'+(1:26)-1)';
    [I3,J3,K3]=ndgrid(1:26,1:26,1:26);
    X1=[Alphabet(I3(:)), Alphabet(J3(:))];
    X1=cellstr(X1);
    X1=sort(X1);
    X1=unique(X1);
    X2=[Alphabet(I3(:)),Alphabet(J3(:)),Alphabet(K3(:))];
    X2=cellstr(X2);
    X2=sort(X2);
    X2=unique(X2);
    X0=cellstr(Alphabet);
    masterabc=[X0;X1;X2(1:15682)];
    genrangeend=char(masterabc(size(GEN.uels,2)+1));
    busrangeend=char(masterabc(size(BUS.uels,2)+1));
    acerangeend=char(masterabc(size(ACE,2)));
    reserverangeend=char(masterabc(size(RTD_RESERVE_FIELD,2)-1));

    % create the summary results workbook
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks; 
    Workbook = invoke(ewb, 'Add');
    Sheets = e.ActiveWorkBook.Sheets;
    case_summary = get(Sheets, 'Item', 1);
    case_summary.Name = 'case_summary';
	if(str2double(e.Version)>=13);Sheets.Add([], Sheets.Item(Sheets.Count));end;
    results_summary = get(Sheets, 'Item',2);
    results_summary.Name = 'results_summary';
    if(str2double(e.Version)<13);invoke(get(Sheets,'Item',3),'Delete');end;

    % Write Results Summary Sheet
    invoke(results_summary, 'Activate');
    Activesheet = e.Activesheet;
    set(Activesheet.Range('A2'),'Value','Unadjusted Production Cost');
    set(Activesheet.Range('B2'),'Value',Cost_Result_Total);
    set(Activesheet.Range('A3'),'Value','Adjusted for Interchagne');
    set(Activesheet.Range('B3'),'Value',adjusted_cost);
    set(Activesheet.Range('A4'),'Value','Unadjusted Revenue (load payment)');
    set(Activesheet.Range('B4'),'Value',Revenue_Result_Total);
    set(Activesheet.Range('A5'),'Value','Profit');
    set(Activesheet.Range('B5'),'Value',Profit_Result_Total);
    if size(STORAGE_UNITS,1) > 0 && sum(GENVALUE.val(:,gen_type)==6) > 0
        set(Activesheet.Range('A6'),'Value','Adjusted for Storage Level');
        set(Activesheet.Range('B6'),'Value',adjusted_storage_cost);
    end
    set(Activesheet.Range('A7'),'Value','Generator Cycles');
    set(Activesheet.Range('B7'),'Value',generator_cycles);
    set(Activesheet.Range('A8'),'Value','CPS2_Violations');
    set(Activesheet.Range('B8'),'Value',CPS2_violations);
    set(Activesheet.Range('A9'),'Value','CPS2');
    set(Activesheet.Range('B9'),'Value',CPS2);
    set(Activesheet.Range('A10'),'Value','AACEE');
    set(Activesheet.Range('B10'),'Value',Total_MWH_Absolute_ACE);
    set(Activesheet.Range('A11'),'Value','Max Reg Limit Hit');
    set(Activesheet.Range('B11:C11'),'Value',Max_Reg_Limit_Hit);
    set(Activesheet.Range('A12'),'Value','Min Reg Limit Hit');
    set(Activesheet.Range('B12:C12'),'Value',Min_Reg_Limit_Hit);
    set(Activesheet.Range('A13'),'Value','sigma_ACE');
    set(Activesheet.Range('B13'),'Value',sigma_ACE);
    set(Activesheet.Range('A15'),'Value','Sum of ACE (Inadvertent Interchange)');
    set(Activesheet.Range('B15'),'Value',ACE(AGC_interval_index-1,integrated_ACE_index));
    set(Activesheet.Range('A18'),'Value','Total Generation By Unit');
    range=strcat('B17:',genrangeend,'17');
    set(Activesheet.Range(range),'Value',GEN.uels);
    range=strcat('B18:',genrangeend,'18');
    set(Activesheet.Range(range),'Value',sum(ACTUAL_GENERATION(:,2:end)).*t_AGC./60./60);
    set(Activesheet.Range('A23'),'Value','Solve Time (seconds)');
    set(Activesheet.Range('B23'),'Value',tEnd);
    Activesheet.Range('A2:A23').EntireColumn.AutoFit;
    try set(Activesheet.Range('B2:B6'),'NumberFormat','$#,##0.00');catch;end;
    try set(Activesheet.Range('B7'),'NumberFormat','* #,##0');catch;end;
    try set(Activesheet.Range('B11:C12'),'NumberFormat','* #,##0');catch;end;

    % Write Case Summary Sheet
    invoke(case_summary, 'Activate');
    Activesheet = e.Activesheet;
    set(Activesheet.Range('A2'),'Value','trtd');
    set(Activesheet.Range('B2'),'Value',tRTD);
    set(Activesheet.Range('A3'),'Value','Irtd');
    set(Activesheet.Range('B3'),'Value',IRTD);
    set(Activesheet.Range('A4'),'Value','Irtd-adv');
    set(Activesheet.Range('B4'),'Value',IRTDADV);
    set(Activesheet.Range('A5'),'Value','Hrtd');
    set(Activesheet.Range('B5'),'Value',HRTD);
    set(Activesheet.Range('A7'),'Value','trtc');
    set(Activesheet.Range('B7'),'Value',tRTC);
    set(Activesheet.Range('A8'),'Value','Irtc');
    set(Activesheet.Range('B8'),'Value',IRTC);
    set(Activesheet.Range('A9'),'Value','Hrtc');
    set(Activesheet.Range('B9'),'Value',HRTC);
    set(Activesheet.Range('A11'),'Value','tAGC');
    set(Activesheet.Range('B11'),'Value',t_AGC);
    set(Activesheet.Range('A13'),'Value','rtscuc_load_forecast_mode');
    set(Activesheet.Range('B13'),'Value',rtc_load_data_create);
    set(Activesheet.Range('A14'),'Value','rtscuc_vg_forecast_mode');
    set(Activesheet.Range('B14'),'Value',rtc_vg_data_create);
    set(Activesheet.Range('A15'),'Value','rtscuc_reserve_forecast_mode');
    set(Activesheet.Range('B15'),'Value',RTC_RESERVE_FORECAST_MODE_in);
    set(Activesheet.Range('A16'),'Value','rtsced_load_forecast_mode');
    set(Activesheet.Range('B16'),'Value',rtd_load_data_create);
    set(Activesheet.Range('A17'),'Value','rtsced_vg_forecast_mode');
    set(Activesheet.Range('B17'),'Value',rtd_vg_data_create);
    set(Activesheet.Range('A18'),'Value','rtsced_reserve_forecast_mode');
    set(Activesheet.Range('B18'),'Value',RTD_RESERVE_FORECAST_MODE_in);
    set(Activesheet.Range('A19'),'Value','trtc_start');
    set(Activesheet.Range('B19'),'Value',tRTCstart);
    set(Activesheet.Range('A21'),'Value','AGC_mode');
    set(Activesheet.Range('B21'),'Value',AGC_MODE);
    set(Activesheet.Range('A22'),'Value','ACE_Limit (L10)');
    set(Activesheet.Range('B22'),'Value',L10);
    set(Activesheet.Range('A23'),'Value','CPS2_interval');
    set(Activesheet.Range('B23'),'Value',CPS2_interval);
    set(Activesheet.Range('A25'),'Value','Integral Time');
    set(Activesheet.Range('B25'),'Value',Type3_integral);
    set(Activesheet.Range('A26'),'Value','K1');
    set(Activesheet.Range('B26'),'Value',K1);
    set(Activesheet.Range('A27'),'Value','K2');
    set(Activesheet.Range('B27'),'Value',K2);
    set(Activesheet.Range('A6'),'Value','PRTD');
    set(Activesheet.Range('B6'),'Value',PRTD_in);
    set(Activesheet.Range('A10'),'Value','PRTC');
    set(Activesheet.Range('B10'),'Value',PRTC_in);
    set(Activesheet.Range('A33'),'Value','Input File');
    set(Activesheet.Range('B33'),'Value',inputfilename);
    range=strcat('C2:C',num2str(daystosimulate)+1);
    set(Activesheet.Range('C1')','Value','Load Files');
    set(Activesheet.Range(range),'Value',actual_load_input_file);
    range=strcat('D2:D',num2str(daystosimulate)+1);
    set(Activesheet.Range('D1'),'Value','VG Files');
    try set(Activesheet.Range(range),'Value',actual_vg_input_file);catch;end;
    Activesheet.Range('A2:A33').EntireColumn.AutoFit;
    Activesheet.Range('C2:C33').EntireColumn.AutoFit;
    Activesheet.Range('D2:D33').EntireColumn.AutoFit;

    % save and close
    invoke(Workbook, 'SaveAs', dir1);
    invoke(e, 'Quit');
    delete(e);

    % create the detailed results workbook
    e = actxserver ('Excel.Application'); %# open Activex server
    ewb = e.Workbooks; 
    Workbook = invoke(ewb, 'Add');
    Sheets = e.ActiveWorkBook.Sheets;
    case_summary = get(Sheets,'Item',1);
    case_summary.Name = 'case_summary';
	if(str2double(e.Version)>=13);Sheets.Add([], Sheets.Item(Sheets.Count));end;
    results_summary = get(Sheets,'Item',2);
    results_summary.Name = 'results_summary';
	if(str2double(e.Version)>=13);Sheets.Add([], Sheets.Item(Sheets.Count));end;
    Area_Control_Error = get(Sheets,'Item',3);
    Area_Control_Error.Name = 'ACE';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    realized_generation=get(Sheets,'Item',4);
    realized_generation.Name = 'realized_generation';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    AGC_schedules=get(Sheets,'Item',5);
    AGC_schedules.Name = 'AGC_schedules';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    dascuc_schedules=get(Sheets,'Item',6);
    dascuc_schedules.Name = 'dascuc_schedules';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    rtscuc_schedules=get(Sheets,'Item',7);
    rtscuc_schedules.Name = 'rtscuc_schedules';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    rtsced_schedules=get(Sheets,'Item',8);
    rtsced_schedules.Name = 'rtsced_schedules';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    dascuc_lmps=get(Sheets,'Item',9);
    dascuc_lmps.Name = 'dascuc_lmps';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    rtsced_lmps=get(Sheets,'Item',10);
    rtsced_lmps.Name = 'rtsced_lmps';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    dascuc_reserve_prices=get(Sheets,'Item',11);
    dascuc_reserve_prices.Name = 'dascuc_reserve_prices';
    Sheets.Add([], Sheets.Item(Sheets.Count));
    rtsced_reserve_prices=get(Sheets,'Item',12);
    rtsced_reserve_prices.Name = 'rtsced_reserve_prices';
    reservehandles=[];
    for i=1:nreserve
        reservesheet=strcat(RESERVETYPE.uels{i},'_Schedule');
        Sheets.Add([], Sheets.Item(Sheets.Count));
        Hreservesheet=get(Sheets,'Item',i+12);
        Hreservesheet.Name = reservesheet;
        reservehandles=[reservehandles;Hreservesheet];
    end

    % write reserve sheets
    for r=1:nreserve
        reservesheet=strcat(RESERVETYPE.uels{r},'_Schedule');
        invoke(reservehandles(r), 'Activate');
        Activesheet = e.Activesheet;
        range=strcat('A2:',genrangeend,num2str(size(RTSCEDBINDINGRESERVE,1)+1));
        set(Activesheet.Range(range),'Value',RTSCEDBINDINGRESERVE(:,:,r));
        range=strcat('B1:',genrangeend,'1');
        set(Activesheet.Range(range),'Value',GEN.uels);
    end;  

    % write agc schedules
    invoke(AGC_schedules, 'Activate');
    Activesheet = e.Activesheet;
    set(Activesheet.Range(range),'Value',GEN.uels);
    range=strcat('A2:',genrangeend,num2str(size(AGC_SCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',AGC_SCHEDULE);
    
    % write rtsced reserve prices
    invoke(rtsced_reserve_prices, 'Activate');
    Activesheet = e.Activesheet;
    columnLabels={'TIME',RTD_RESERVE_FIELD{3:end}};
    range=strcat('A1:',reserverangeend,'1');
    set(Activesheet.Range(range),'Value',columnLabels);
    range=strcat('A2:',reserverangeend,num2str(size(RTSCEDBINDINGRESERVEPRICE,1)+1));
    set(Activesheet.Range(range),'Value',RTSCEDBINDINGRESERVEPRICE);
    Activesheet.Range('B2:Z500000').EntireColumn.AutoFit;

    % write dascuc reserve prices
    invoke(dascuc_reserve_prices, 'Activate');
    Activesheet = e.Activesheet;
    columnLabels={'TIME',DAC_RESERVE_FIELD{3:end}};
    range=strcat('A1:',reserverangeend,'1');
    set(Activesheet.Range(range),'Value',columnLabels);
    range=strcat('A2:',reserverangeend,num2str(size(DASCUCRESERVEPRICE,1)+1));
    set(Activesheet.Range(range),'Value',DASCUCRESERVEPRICE);
    Activesheet.Range('B2:Z500000').EntireColumn.AutoFit;
    
    % write LMPs
    if nbus <= 20000 % maximum number of columns in Excel is 16,384
        invoke(rtsced_lmps, 'Activate');
        Activesheet = e.Activesheet;
        range=strcat('A2:',busrangeend,num2str(size(RTSCEDBINDINGLMP,1)+1));
        set(Activesheet.Range(range),'Value',RTSCEDBINDINGLMP);
        range=strcat('B1:',busrangeend,'1');
        set(Activesheet.Range(range),'Value',BUS.uels);
        invoke(dascuc_lmps, 'Activate');
        Activesheet = e.Activesheet;
        set(Activesheet.Range(range),'Value',BUS.uels);
        range=strcat('A2:',busrangeend,num2str(size(DASCUCLMP,1)+1));
        set(Activesheet.Range(range),'Value',DASCUCLMP);
    else
        invoke(rtsced_lmps, 'Activate');
        Activesheet = e.Activesheet;
        range=strcat('A2:A',num2str(size(RTSCEDBINDINGLMP,1)+1));
        set(Activesheet.Range(range),'Value',RTSCEDBINDINGLMP(:,1));
        range=strcat('B2:B',num2str(size(RTSCEDBINDINGLMP,1)+1));
        set(Activesheet.Range(range),'Value',mean(RTSCEDBINDINGLMP(:,2:end)')');
        set(Activesheet.Range('B1'),'Value','AVERAGE LMP');
        invoke(dascuc_lmps, 'Activate');
        Activesheet = e.Activesheet;
        range=strcat('A2:A',num2str(size(DASCUCLMP,1)+1));
        set(Activesheet.Range(range),'Value',DASCUCLMP(:,1));
        range=strcat('B2:B',num2str(size(DASCUCLMP,1)+1));
        set(Activesheet.Range(range),'Value',mean(DASCUCLMP(:,2:end)')'); 
        set(Activesheet.Range('B1'),'Value','AVERAGE LMP');
    end;

    % write dascuc schedules
    invoke(dascuc_schedules, 'Activate');
    Activesheet = e.Activesheet;
    range=strcat('A2:A',num2str(size(DASCUCSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',DASCUCSCHEDULE(:,1));
    range=strcat('B2:',genrangeend,num2str(size(DASCUCSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',DASCUCSCHEDULE(:,2:ngen+1)-DASCUCPUMPSCHEDULE(:,2:ngen+1));
    range=strcat('B1:',genrangeend,'1');
    set(Activesheet.Range(range),'Value',GEN.uels);

    % write rtscuc schedules
    invoke(rtscuc_schedules, 'Activate');
    Activesheet = e.Activesheet;
    range=strcat('A2:A',num2str(size(RTSCUCBINDINGSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',RTSCUCBINDINGSCHEDULE(:,1));
    range=strcat('B2:',genrangeend,num2str(size(RTSCUCBINDINGSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',RTSCUCBINDINGSCHEDULE(:,2:ngen+1)-RTSCUCBINDINGPUMPSCHEDULE(:,2:ngen+1));
    range=strcat('B1:',genrangeend,'1');
    set(Activesheet.Range(range),'Value',GEN.uels);

    % write rtsced schedules
    invoke(rtsced_schedules, 'Activate');
    Activesheet = e.Activesheet;
    range=strcat('A2:A',num2str(size(RTSCEDBINDINGSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',RTSCEDBINDINGSCHEDULE(:,1));
    range=strcat('B2:',genrangeend,num2str(size(RTSCEDBINDINGSCHEDULE,1)+1));
    set(Activesheet.Range(range),'Value',RTSCEDBINDINGSCHEDULE(:,2:ngen+1)-RTSCEDBINDINGPUMPSCHEDULE(:,2:ngen+1));
    range=strcat('B1:',genrangeend,'1');
    set(Activesheet.Range(range),'Value',GEN.uels);

    % write realized generation
    invoke(realized_generation, 'Activate');
    Activesheet = e.Activesheet;
    range=strcat('A2:A',num2str(size(ACTUAL_GENERATION,1)+1));
    set(Activesheet.Range(range),'Value',ACTUAL_GENERATION(:,1));
    range=strcat('B2:',genrangeend,num2str(size(ACTUAL_GENERATION,1)+1));
    set(Activesheet.Range(range),'Value',ACTUAL_GENERATION(:,2:ngen+1)-ACTUAL_PUMP(:,2:ngen+1));
    range=strcat('B1:',genrangeend,'1');
    set(Activesheet.Range(range),'Value',GEN.uels);

    % write ACE sheet
    invoke(Area_Control_Error, 'Activate');
    Activesheet = e.Activesheet;
    columnLabels={'TIME','Raw ACE','Integrated ACE','CPS2 ACE','Smoothed ACE','AACEE'};
    range=strcat('A1:',acerangeend,'1');
    set(Activesheet.Range(range),'Value',columnLabels);
    range=strcat('A2:',acerangeend,num2str(size(ACE,1)+1));
    set(Activesheet.Range(range),'Value',ACE);
    
    % Write Results Summary Sheet
    invoke(results_summary, 'Activate');
    Activesheet = e.Activesheet;
    set(Activesheet.Range('A2'),'Value','Unadjusted Production Cost');
    set(Activesheet.Range('B2'),'Value',Cost_Result_Total);
    set(Activesheet.Range('A3'),'Value','Adjusted for Interchagne');
    set(Activesheet.Range('B3'),'Value',adjusted_cost);
    set(Activesheet.Range('A4'),'Value','Unadjusted Revenue (load payment)');
    set(Activesheet.Range('B4'),'Value',Revenue_Result_Total);
    set(Activesheet.Range('A5'),'Value','Profit');
    set(Activesheet.Range('B5'),'Value',Profit_Result_Total);
    if size(STORAGE_UNITS,1) > 0 && sum(GENVALUE.val(:,gen_type)==6) > 0
        set(Activesheet.Range('A6'),'Value','Adjusted for Storage Level');
        set(Activesheet.Range('B6'),'Value',adjusted_storage_cost);
    end
    set(Activesheet.Range('A7'),'Value','Generator Cycles');
    set(Activesheet.Range('B7'),'Value',generator_cycles);
    set(Activesheet.Range('A8'),'Value','CPS2_Violations');
    set(Activesheet.Range('B8'),'Value',CPS2_violations);
    set(Activesheet.Range('A9'),'Value','CPS2');
    set(Activesheet.Range('B9'),'Value',CPS2);
    set(Activesheet.Range('A10'),'Value','AACEE');
    set(Activesheet.Range('B10'),'Value',Total_MWH_Absolute_ACE);
    set(Activesheet.Range('A11'),'Value','Max Reg Limit Hit');
    set(Activesheet.Range('B11:C11'),'Value',Max_Reg_Limit_Hit);
    set(Activesheet.Range('A12'),'Value','Min Reg Limit Hit');
    set(Activesheet.Range('B12:C12'),'Value',Min_Reg_Limit_Hit);
    set(Activesheet.Range('A13'),'Value','sigma_ACE');
    set(Activesheet.Range('B13'),'Value',sigma_ACE);
    set(Activesheet.Range('A15'),'Value','Sum of ACE (Inadvertent Interchange)');
    set(Activesheet.Range('B15'),'Value',ACE(AGC_interval_index-1,integrated_ACE_index));
    set(Activesheet.Range('A18'),'Value','Total Generation By Unit');
    range=strcat('B17:',genrangeend,'17');
    set(Activesheet.Range(range),'Value',GEN.uels);
    range=strcat('B18:',genrangeend,'18');
    set(Activesheet.Range(range),'Value',sum(ACTUAL_GENERATION(:,2:end)).*t_AGC./60./60);
    set(Activesheet.Range('A23'),'Value','Solve Time (seconds)');
    set(Activesheet.Range('B23'),'Value',tEnd);
    Activesheet.Range('A2:A23').EntireColumn.AutoFit;
    try set(Activesheet.Range('B2:B6'),'NumberFormat','$#,##0.00');catch;end;
    try set(Activesheet.Range('B7'),'NumberFormat','* #,##0');catch;end;
    try set(Activesheet.Range('B11:C12'),'NumberFormat','* #,##0');catch;end;

    % Write Case Summary Sheet
    invoke(case_summary, 'Activate');
    Activesheet = e.Activesheet;
    set(Activesheet.Range('A2'),'Value','trtd');
    set(Activesheet.Range('B2'),'Value',tRTD);
    set(Activesheet.Range('A3'),'Value','Irtd');
    set(Activesheet.Range('B3'),'Value',IRTD);
    set(Activesheet.Range('A4'),'Value','Irtd-adv');
    set(Activesheet.Range('B4'),'Value',IRTDADV);
    set(Activesheet.Range('A5'),'Value','Hrtd');
    set(Activesheet.Range('B5'),'Value',HRTD);
    set(Activesheet.Range('A7'),'Value','trtc');
    set(Activesheet.Range('B7'),'Value',tRTC);
    set(Activesheet.Range('A8'),'Value','Irtc');
    set(Activesheet.Range('B8'),'Value',IRTC);
    set(Activesheet.Range('A9'),'Value','Hrtc');
    set(Activesheet.Range('B9'),'Value',HRTC);
    set(Activesheet.Range('A11'),'Value','tAGC');
    set(Activesheet.Range('B11'),'Value',t_AGC);
    set(Activesheet.Range('A13'),'Value','rtscuc_load_forecast_mode');
    set(Activesheet.Range('B13'),'Value',rtc_load_data_create);
    set(Activesheet.Range('A14'),'Value','rtscuc_vg_forecast_mode');
    set(Activesheet.Range('B14'),'Value',rtc_vg_data_create);
    set(Activesheet.Range('A15'),'Value','rtscuc_reserve_forecast_mode');
    set(Activesheet.Range('B15'),'Value',RTC_RESERVE_FORECAST_MODE_in);
    set(Activesheet.Range('A16'),'Value','rtsced_load_forecast_mode');
    set(Activesheet.Range('B16'),'Value',rtd_load_data_create);
    set(Activesheet.Range('A17'),'Value','rtsced_vg_forecast_mode');
    set(Activesheet.Range('B17'),'Value',rtd_vg_data_create);
    set(Activesheet.Range('A18'),'Value','rtsced_reserve_forecast_mode');
    set(Activesheet.Range('B18'),'Value',RTD_RESERVE_FORECAST_MODE_in);
    set(Activesheet.Range('A19'),'Value','trtc_start');
    set(Activesheet.Range('B19'),'Value',tRTCstart);
    set(Activesheet.Range('A21'),'Value','AGC_mode');
    set(Activesheet.Range('B21'),'Value',AGC_MODE);
    set(Activesheet.Range('A22'),'Value','ACE_Limit (L10)');
    set(Activesheet.Range('B22'),'Value',L10);
    set(Activesheet.Range('A23'),'Value','CPS2_interval');
    set(Activesheet.Range('B23'),'Value',CPS2_interval);
    set(Activesheet.Range('A25'),'Value','Integral Time');
    set(Activesheet.Range('B25'),'Value',Type3_integral);
    set(Activesheet.Range('A26'),'Value','K1');
    set(Activesheet.Range('B26'),'Value',K1);
    set(Activesheet.Range('A27'),'Value','K2');
    set(Activesheet.Range('B27'),'Value',K2);
    set(Activesheet.Range('A6'),'Value','PRTD');
    set(Activesheet.Range('B6'),'Value',PRTD_in);
    set(Activesheet.Range('A10'),'Value','PRTC');
    set(Activesheet.Range('B10'),'Value',PRTC_in);
    set(Activesheet.Range('A33'),'Value','Input File');
    set(Activesheet.Range('B33'),'Value',inputfilename);
    range=strcat('C2:C',num2str(daystosimulate)+1);
    set(Activesheet.Range('C1')','Value','Load Files');
    set(Activesheet.Range(range),'Value',actual_load_input_file);
    range=strcat('D2:D',num2str(daystosimulate)+1);
    set(Activesheet.Range('D1'),'Value','VG Files');
    try set(Activesheet.Range(range),'Value',actual_vg_input_file);catch;end;
    Activesheet.Range('A2:A33').EntireColumn.AutoFit;
    Activesheet.Range('C2:C33').EntireColumn.AutoFit;
    Activesheet.Range('D2:D33').EntireColumn.AutoFit;

    % save output file and close Excel
    invoke(Workbook, 'SaveAs', dir2);
    invoke(e, 'Quit');
    delete(e);

    % check for ALFEE
    if monitor_ALFEE == 1
        xlswrite(dir1,{'ALFEE'},'Results_summary','A19');
        xlswrite(dir1,BRANCH.uels,'Results_summary','B18');
        xlswrite(dir1,ALFEE,'Results_summary','B19');
        xlswrite(dir1,{'total line flow violations'},'Results_summary','A18');
        xlswrite(dir1,sum(LF_violation(:,2:nbranch+1)),'Results_summary','B18');
        xlswrite(dir1,{'percent intervals with line flow violations'},'Results_summary','A19');
        xlswrite(dir1,sum(LF_violation(:,2:nbranch+1))./(AGC_interval_index-1),'Results_summary','B19');
    end;

    % save figures
    f1=strcat(f,'Fig 1 - ACE Levels.fig');
    try saveas(fig1,f1);catch;end;
    f1=strcat(f,'Fig 2 - Actual Generation.fig');
    try saveas(fig2,f1);catch;end;
    f1=strcat(f,'Fig 3 - Day Ahead Prices.fig');
    try saveas(fig3,f1);catch;end;
    f1=strcat(f,'Fig 4 - Real Time Prices.fig');
    try saveas(fig4,f1);catch;end;
    f1=strcat(f,'Fig 5 - RTSCED Schedules.fig');
    try saveas(fig5,f1);catch;end;
    f1=strcat(f,'Fig 6 - DASCUC Schedules.fig');
    try saveas(fig6,f1);catch;end;
    f1=strcat(f,'Fig 7 - Generation and Load.fig');
    try saveas(fig7,f1);catch;end;

    % save workspace
    f1=strcat(f,'Workspace');
    save(f1);

    fprintf('Complete!\n')
end;