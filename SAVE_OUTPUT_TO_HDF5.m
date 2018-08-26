if exist('multiplefilecheck')==1
    if multiplefilecheck == 0
        if autosavecheck==1
            print_final_results = outputname;
        else
            if festiv.use_gui
                print_final_results = input('Please type a filename to save the final results. Otherwise press enter.\n             (NOTE: Only open figures will be saved)\n','s');
                outputname = print_final_results;
            else
                c=clock;
                print_final_results = sprintf('%s_%d_%d_%d_at_%02d_%02d',inputfilename,c(2),c(3),c(1),c(4),c(5));
                outputname = print_final_results;
            end
        end
    else
        print_final_results = outputname;       
    end
else
    print_final_results = input('Please type a filename to save the final results. Otherwise press enter.\n             (NOTE: Only open figures will be saved)\n','s');
    outputname = print_final_results;
end

if isempty(print_final_results) == 1
else
    mkdir('OUTPUT', print_final_results);
    fprintf('\nSaving Output Files...');
    f=strcat('OUTPUT', filesep,print_final_results, filesep);
    currentdir=pwd;
    print_final_results1 = strcat('OUTPUT',filesep,print_final_results,filesep ,print_final_results,' Summary.h5');
    fileName=fullfile(currentdir,print_final_results1);
    
    % Case Summary tab/Input Data
    clear offset memtype wdata filetype space dset
    DATASET  = 'Input Data';

    data=[tRTD;IRTD;IRTDADV;HRTD;PRTD;...
          tRTC;IRTC;HRTC;PRTC;t_AGC;...
          rtc_load_data_create;rtc_vg_data_create;RTC_RESERVE_FORECAST_MODE_in;...
          rtd_load_data_create;rtd_vg_data_create;RTD_RESERVE_FORECAST_MODE_in;...
          tRTCstart;AGC_MODE;L10;CPS2_interval;Type3_integral;K1;K2];
    strings={'tRTD';'IRTD';'IRTDADV';'HRTD';'PRTD';...
             'tRTC';'IRTC';'HRTC';'PRTC';'tAGC';...
             'RTC Load Forecast Mode';'RTC VG Forecast Mode';'RTC Reserve Forecast Mode';...
             'RTD Load Forecast Mode';'RTD VG Forecast Mode';'RTD Reserve Forecast Mode';...
             't_RTCstart';'AGC Mode';'L10';'CPS2 Interval';'Integral Time';'K1';'K2'};
    colHeaders={'Parameter';'Value'};
    clear wdata
    wdata.propterties = strings(1:end,1);
    wdata.data        = data(:,1);

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.create (fileName, 'H5F_ACC_TRUNC','H5P_DEFAULT', 'H5P_DEFAULT');
    mainif = H5G.create(file, '/01 Summary Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(2)=H5T.get_size(doubleType);    

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Parameter',offset(1), strType);
    H5T.insert (memtype,colHeaders{2},offset(2), doubleType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Parameter', offset(1), strType);
    H5T.insert (filetype,colHeaders{2},offset(2), doubleType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

    % Write input file as metadata
    fileattrib(fileName,'+w');
    h5writeatt(fileName,'/','Input File',inputfilename);

    % Case Summary tab/Actual Load Data
    clear offset memtype wdata filetype space dset
    DATASET = 'Load Files';

    strings=cellstr(actual_load_input_file);
    if ~isempty(strings)
        colHeaders={'Load Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/01 Summary Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Load Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Load Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/01 Summary Data', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end

    % Case Summary tab/Actual VG Data
    clear offset memtype wdata filetype space dset
    DATASET = 'VG Files';
    
    try
        strings=cellstr(actual_vg_input_file);
    catch
        strings=[];
    end
    if ~isempty(strings)
        colHeaders={'VG Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/01 Summary Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'VG Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'VG Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/01 Summary Data', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end

    % Case Summary tab/Results
    clear offset memtype wdata filetype space dset
    DATASET = 'Results';

    data=[Cost_Result_Total;adjusted_cost;Revenue_Result_Total;Profit_Result_Total;...
          generator_cycles;CPS2_violations;CPS2;Total_MWH_Absolute_ACE;...
          Max_Reg_Limit_Hit(1);Max_Reg_Limit_Hit(2);Min_Reg_Limit_Hit(1);Min_Reg_Limit_Hit(2);...
          sigma_ACE;ACE(AGC_interval_index-1,integrated_ACE_index);tEnd/60];
    colHeaders={'Parameter';'Value'};
    wdata.parameter  = {'Unadjusted Production Cost';'Adjusted for Interchange';...
                        'Unadjusted Revenue';'Profit';'Generator Cycles';'CPS2 Violations';...
                        'CPS2 Score';'Absolute ACE in Energy';'Upper Max Reg Limit Hit';'Lower Max Reg Limit Hit';...
                        'Upper Min Reg Limit Hit';'Lower Min Reg Limit Hit';'Sigma ACE';...
                        'Inadvertent Interchange';'Solution Time [min]'};
    wdata.numbers = data;

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/01 Summary Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1)-1
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Parameter',offset(1), strType);
    for i=1:size(colHeaders,1)-1 
        H5T.insert (memtype,colHeaders{i+1},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Parameter', offset(1), strType);
    for i=1:size(colHeaders,1)-1
        H5T.insert (filetype,colHeaders{i+1},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

    % Case Summary tab/Total Generation
    clear offset memtype wdata filetype space dset
    DATASET = 'Total Generation';

    data=sum(ACTUAL_GENERATION(:,2:end)).*t_AGC./60./60;
    colHeaders=GEN_VAL;
    wdata.string={'Total Generation By Unit'};
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/01 Summary Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1) 
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Parameter',offset(1), strType);
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Parameter', offset(1), strType);
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

    % ACE
    clear offset memtype wdata filetype space dset
    DATASET  = '02 ACE';

    data=ACE;
    colHeaders={'Time';'Raw ACE';'Integrated ACE';'CPS2 ACE';'Smoothed ACE';'AACEE'};
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % Realized Generation
    clear offset memtype wdata filetype space dset
    DATASET  = '03 Realized Generation';

    data=ACTUAL_GENERATION-ACTUAL_PUMP;
    data(:,1)=ACTUAL_GENERATION(:,1);
    colHeaders={'Time',GEN_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,1);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % AGC Schedule
    clear offset memtype wdata filetype space dset
    DATASET  = '04 AGC Schedule';

    data=AGC_SCHEDULE;
    colHeaders={'Time',GEN_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,1);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % DASCUC Schedule
    clear offset memtype wdata filetype space dset
    DATASET  = '05 DASCUC Schedule';

    data=DASCUCSCHEDULE-DASCUCPUMPSCHEDULE;
    data(:,1)=DASCUCSCHEDULE(:,1);
    colHeaders={'Time',GEN_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % RTSCUC Schedule
    clear offset memtype wdata filetype space dset
    DATASET  = '06 RTSCUC Schedule';

    data=RTSCUCBINDINGSCHEDULE-RTSCUCBINDINGPUMPSCHEDULE;
    data(:,1)=RTSCUCBINDINGSCHEDULE(:,1);
    colHeaders={'Time',GEN_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % RTSCED Schedule
    clear offset memtype wdata filetype space dset
    DATASET  = '07 RTSCED Schedule';

    data=RTSCEDBINDINGSCHEDULE-RTSCEDBINDINGPUMPSCHEDULE;
    data(:,1)=RTSCEDBINDINGSCHEDULE(:,1);
    colHeaders={'Time',GEN_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % DASCUC LMPs
    clear offset memtype wdata filetype space dset
    DATASET  = '08 DA LMPs';

    data=DASCUCLMP;
    colHeaders={'Time',BUS_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % RTSCED LMPs
    clear offset memtype wdata filetype space dset
    DATASET  = '09 RTD LMPs';

    data=RTSCEDBINDINGLMP;
    colHeaders={'Time',BUS_VAL{:,1}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

    % RTSCED Reserve Schedules
    clear offset memtype wdata filetype space dset
    for r=1:nreserve
        DATASET  = [num2str(9+r),' ',RTD_RESERVE_FIELD{r+2},' Schedule'];

        data=RTSCEDBINDINGRESERVE(:,:,r);
        colHeaders={'Time',GEN_VAL{:,1}}';
        clear wdata
        for i=1:size(data,2)
            wdata.(sprintf('data%d',i))=data(:,i);
        end

        ylen=size(data,1);
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

        sz=zeros(1,size(colHeaders,1)); 
        for i=1:size(colHeaders,1)
            doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
            sz(i)=H5T.get_size(doubleType);    
        end

        offset(1)=0;
        offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        for i=1:size(colHeaders,1) 
            H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
        end

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        for i=1:size(colHeaders,1)
            H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
        end

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (file, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);
    end
    
    % DASCUC reserve prices
    clear offset memtype wdata filetype space dset
    DATASET  = [num2str(9+r+1),' DASCUC Reserve Prices'];

    data=DASCUCRESERVEPRICE;
    colHeaders={'TIME',DAC_RESERVE_FIELD{1,3:end}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,1);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);
    
    % RTSCED reserve prices
    clear offset memtype wdata filetype space dset
    DATASET  = [num2str(9+r+2),' RTSCED Reserve Prices'];

    data=RTSCEDBINDINGRESERVEPRICE;
    colHeaders={'TIME',RTD_RESERVE_FIELD{1,3:end}}';
    clear wdata
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');

    sz=zeros(1,size(colHeaders,1)); 
    for i=1:size(colHeaders,1)
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,1);
    dset = H5D.create (file, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);

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
end
