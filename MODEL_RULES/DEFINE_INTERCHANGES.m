% If there is an interchange with a prespecified timeseries (gen type = 14)
% Then there must be at least a 'DAC_INTERCHANGE' tab in the main input
% file that lists the name of the interchange input files, similar to the
% 'DAC_VG_REF' tab.
% If you would like to specify interchanges for the RTC and RTD, then
% appropriate tabs need to be created ('RTC_INTERCHANGE' and
% 'RTD_INTERCHANGE'). Otherwise, their schedules will be taken from the DA.
% The actual interchange is interpolated from the RTD interchange schedule.

GENTYPES=GENVALUE_VAL(:,gen_type);
interchanges=GENTYPES==14;
ninterchange=sum(interchanges);
if ninterchange > 0
    % Get DASCUC Interchange Schedule
    if useHDF5 == 0
        [~,DACI_files] = xlsread(inputPath,'DAC_FIXED_REF','A2:A1000');
        DAC_INTERCHANGE_FULL=[];
        for d=1:daystosimulate
            path2read = [inputfilepath,filesep,'TIMESERIES\',cell2mat(DACI_files(d,1))];
            [DAC_INTERCHANGE_FULL_TMP,DAC_INTERCHANGE_FIELD] = xlsread(path2read,'Sheet1');
            DAC_INTERCHANGE_FULL = [DAC_INTERCHANGE_FULL; DAC_INTERCHANGE_FULL_TMP];
        end
    else
        x=h5read(fileName,'/Main Input File/DAC_FIXED_REF');
        DAC_INTERCHANGE_FULL=zeros(24*simulation_days,ninterchange+2);
        for d=1:simulation_days
            y=h5read(fileName,['/Time Series Data/DAC Interchange Data/',x.DataFiles{d}]);
            z=fieldnames(y);
            DAC_INTERCHANGE_FULL((d-1)*HDAC+1:(d-1)*HDAC+HDAC,1)=d;
            DAC_INTERCHANGE_FULL((d-1)*HDAC+1:(d-1)*HDAC+HDAC,2)=0:IDAC:HDAC-1;
            for nint=1:size(z,1)-2
                nameOfInterchange=['y.',z{nint+2}];
                DAC_INTERCHANGE_FULL((d-1)*HDAC+1:(d-1)*HDAC+HDAC,2+nint)=eval(nameOfInterchange);
            end
        end
        DAC_INTERCHANGE_FIELD=z';
    end
    actualInterchangeIndicies=zeros(ngen,1);
    for i=1:size(DAC_INTERCHANGE_FIELD,2)-2
        actualInterchangeIndicies=actualInterchangeIndicies+double(strcmp(GEN_VAL,DAC_INTERCHANGE_FIELD{i+2}));
    end
    % Check for outaged interchanges
    interchangesToKeep=interchanges(logical(actualInterchangeIndicies));
    DAC_INTERCHANGE_FULL=[DAC_INTERCHANGE_FULL(:,1:2),DAC_INTERCHANGE_FULL(:,find(interchangesToKeep)+2)];
    DAC_INTERCHANGE_FIELD={DAC_INTERCHANGE_FIELD{1:2},DAC_INTERCHANGE_FIELD{find(interchangesToKeep)+2}};
    % Get RTSCUC Interchange Schedule
    try
        if useHDF5 == 0
            [~,RTCI_files] = xlsread(inputPath,'RTC_FIXED_REF','A2:A1000');
            RTC_INTERCHANGE_FULL=[];
            for d=1:simulation_days
                path2read = [inputfilepath,filesep,'TIMESERIES\',cell2mat(RTCI_files(d,1))];
                [INTERCHANGE_FULL_TMP, INTERCHANGE_FIELD] = xlsread(path2read,'Sheet1');
                INTERCHANGE_multiplier_tmp = zeros(size(INTERCHANGE_FULL_TMP));
                INTERCHANGE_multiplier_tmp(:,1:2) = d-1;
                INTERCHANGE_FULL_TMP = INTERCHANGE_FULL_TMP + INTERCHANGE_multiplier_tmp;
                RTC_INTERCHANGE_FULL = [RTC_INTERCHANGE_FULL; INTERCHANGE_FULL_TMP];
            end
            RTC_INTERCHANGE_FIELD = INTERCHANGE_FIELD;
            RTC_INTERCHANGE_FULL=[RTC_INTERCHANGE_FULL(:,1:2),RTC_INTERCHANGE_FULL(:,find(interchangesToKeep)+2)];
            RTC_INTERCHANGE_FIELD={RTC_INTERCHANGE_FIELD{1:2},RTC_INTERCHANGE_FIELD{find(interchangesToKeep)+2}};
        else
            x=h5read(fileName,'/Main Input File/RTC_FIXED_REF');
            RTC_INTERCHANGE_FULL=zeros(60/tRTC*24*simulation_days*HRTC+HRTC,ninterchange+2);
            offset=1;
            for d=1:simulation_days
                y=h5read(fileName,['/Time Series Data/RTC Interchange Data/',x.DataFiles{d}]);
                z=fieldnames(y);
                timeStamps=['y.',z{1}];
                intervalStamps=['y.',z{2}];
                for nint=1:size(z,1)-2
%                     for col=1:size(z,1)
                        nameOfInterchange=['y.',z{nint+2}];
                        sizeOfData=size(eval(nameOfInterchange),1);
                        RTC_INTERCHANGE_FULL(offset:offset+sizeOfData-1,[1,2,nint+2])=[eval(timeStamps)+d-1,eval(intervalStamps)+d-1,eval(nameOfInterchange)];
%                     end
                    
                end
                offset=offset+sizeOfData;
            end
            RTC_INTERCHANGE_FIELD=z';
        end
    catch
        T=(0:tRTC/60:daystosimulate*24-tRTC/60)';
        tmp=zeros(size(T,1),ninterchange);
        for i = 1 : ninterchange
            tmp(:,i)=interpolateData(DAC_INTERCHANGE_FULL(:,i+2),daystosimulate,60*tRTC,IDAC*60);
        end   
        dac_fixed_ref=[T./24,tmp];
        RTC_INTERCHANGE_FULL=[];
        advisory_interval_length=IRTC;interval_update=tRTC;ninterval=HRTC;interval_length=IRTC;
        total_runs = 1+60/interval_update*24*daystosimulate;
        RTC_INTERCHANGE_FULL = zeros(ninterval*total_runs,size(ninterchange,1)+2);
        timechange = interval_update/(24*60);
        intervalchange = interval_length/(24*60);
        advisoryintervalchange = advisory_interval_length/(24*60);
        oneminute = 1/(24*60);
        eps = 0.0000001;
        row=1;
        time = 1-timechange;
        lookahead_interval = 0;
        RTC_INTERCHANGE_FULL(row,1) = time;
        RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
        row = row+1;
        if ninterval > 1
            lookahead_interval = lookahead_interval + oneminute;
            while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                    && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                lookahead_interval = lookahead_interval + oneminute;
            end;
            RTC_INTERCHANGE_FULL(row,1) = time;
            RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
            row = row + 1;
        end;
        if ninterval > 2
            for t1=3:ninterval
                lookahead_interval = lookahead_interval + advisoryintervalchange;
                RTC_INTERCHANGE_FULL(row,1) = time;
                RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
                row = row+1;
            end;
        end;
        time = 0;
        for t=2:total_runs
            lookahead_interval = time + intervalchange;
            RTC_INTERCHANGE_FULL(row,1) = time;
            RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
            row = row+1;
            if ninterval > 1
                lookahead_interval = lookahead_interval + oneminute;
                while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                        && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                    lookahead_interval = lookahead_interval + oneminute;
                end;
                RTC_INTERCHANGE_FULL(row,1) = time;
                RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
                row = row + 1;
            end;
            if ninterval > 2
                for t1=3:ninterval
                    lookahead_interval = lookahead_interval + advisoryintervalchange;
                    RTC_INTERCHANGE_FULL(row,1) = time;
                    RTC_INTERCHANGE_FULL(row,2) = lookahead_interval;
                    row = row+1;
                end;
            end;
            time = time + timechange;
        end;
        for t=1:size(RTC_INTERCHANGE_FULL,1)
%             lookahead_index = floor(24*RTC_INTERCHANGE_FULL(t,2)*(1/IDAC)+eps) + 1;      %Because hour 0 is index 1
            idx=find(abs(RTC_INTERCHANGE_FULL(t,2)-dac_fixed_ref(:,1))<eps);
%             RTC_INTERCHANGE_FULL(t,3:ninterchange+2) = DAC_INTERCHANGE_FULL(min(size(DAC_INTERCHANGE_FULL,1),lookahead_index),3:ninterchange+2);
            if isempty(idx)
                idx=size(dac_fixed_ref,1);
            end
            RTC_INTERCHANGE_FULL(t,3:end)=dac_fixed_ref(idx,2:end);
        end;
        RTC_INTERCHANGE_FIELD = DAC_INTERCHANGE_FIELD;
    end
    % Get RTSCED Interchange Schedule
    try
        if useHDF5 == 0
            [~,RTDI_files] = xlsread(inputPath,'RTD_FIXED_REF','A2:A1000');
            RTD_INTERCHANGE_FULL=[];
            for d=1:simulation_days
                path2read = [inputfilepath,filesep,'TIMESERIES\',cell2mat(RTDI_files(d,1))];
                [INTERCHANGE_FULL_TMP, INTERCHANGE_FIELD] = xlsread(path2read,'Sheet1');
                INTERCHANGE_multiplier_tmp = zeros(size(INTERCHANGE_FULL_TMP));
                INTERCHANGE_multiplier_tmp(:,1:2) = d-1;
                INTERCHANGE_FULL_TMP = INTERCHANGE_FULL_TMP + INTERCHANGE_multiplier_tmp;
                RTD_INTERCHANGE_FULL = [RTD_INTERCHANGE_FULL; INTERCHANGE_FULL_TMP];
            end
            RTD_INTERCHANGE_FIELD = INTERCHANGE_FIELD;
            RTD_INTERCHANGE_FULL=[RTD_INTERCHANGE_FULL(:,1:2),RTD_INTERCHANGE_FULL(:,find(interchangesToKeep)+2)];
            RTD_INTERCHANGE_FIELD={RTD_INTERCHANGE_FIELD{1:2},RTD_INTERCHANGE_FIELD{find(interchangesToKeep)+2}};
        else
            x=h5read(fileName,'/Main Input File/RTD_FIXED_REF');
            RTD_INTERCHANGE_FULL=zeros(60/tRTD*24*simulation_days*HRTD+HRTD,ninterchange+2);
            offset=1;
            for d=1:simulation_days
                y=h5read(fileName,['/Time Series Data/RTD Interchange Data/',x.DataFiles{d}]);
                z=fieldnames(y);
                timeStamps=['y.',z{1}];
                intervalStamps=['y.',z{2}];
                for nint=1:size(z,1)-2
%                     for col=1:size(z,1)
                        nameOfInterchange=['y.',z{nint+2}];
                        sizeOfData=size(eval(nameOfInterchange),1);
                        RTD_INTERCHANGE_FULL(offset:offset+sizeOfData-1,[1,2,nint+2])=[eval(timeStamps)+d-1,eval(intervalStamps)+d-1,eval(nameOfInterchange)];
%                     end
                    
                end
                offset=offset+sizeOfData;
            end
            RTD_INTERCHANGE_FIELD=z';
        end
    catch
        T=(0:tRTD/60:daystosimulate*24-tRTD/60)';
        tmp=zeros(size(T,1),ninterchange);
        for i = 1 : ninterchange
            tmp(:,i)=interpolateData(DAC_INTERCHANGE_FULL(:,i+2),daystosimulate,60*tRTD,IDAC*60);
        end   
        dac_fixed_ref=[T./24,tmp];
        RTD_INTERCHANGE_FULL=[];
        advisory_interval_length=IRTDADV;interval_update=tRTD;ninterval=HRTD;interval_length=IRTD;
        total_runs = 1+60/interval_update*24*daystosimulate;
        RTD_INTERCHANGE_FULL = zeros(ninterval*total_runs,size(ninterchange,1)+2);
        timechange = interval_update/(24*60);
        intervalchange = interval_length/(24*60);
        advisoryintervalchange = advisory_interval_length/(24*60);
        oneminute = 1/(24*60);
        eps = 0.0000001;
        row=1;
        time = 1-timechange;
        lookahead_interval = 0;
        RTD_INTERCHANGE_FULL(row,1) = time;
        RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
        row = row+1;
        if ninterval > 1
            lookahead_interval = lookahead_interval + oneminute;
            while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                    && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                lookahead_interval = lookahead_interval + oneminute;
            end;
            RTD_INTERCHANGE_FULL(row,1) = time;
            RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
            row = row + 1;
        end;
        if ninterval > 2
            for t1=3:ninterval
                lookahead_interval = lookahead_interval + advisoryintervalchange;
                RTD_INTERCHANGE_FULL(row,1) = time;
                RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
                row = row+1;
            end;
        end;
        time = 0;
        for t=2:total_runs
            lookahead_interval = time + intervalchange;
            RTD_INTERCHANGE_FULL(row,1) = time;
            RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
            row = row+1;
            if ninterval > 1
                lookahead_interval = lookahead_interval + oneminute;
                while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                        && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                    lookahead_interval = lookahead_interval + oneminute;
                end;
                RTD_INTERCHANGE_FULL(row,1) = time;
                RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
                row = row + 1;
            end;
            if ninterval > 2
                for t1=3:ninterval
                    lookahead_interval = lookahead_interval + advisoryintervalchange;
                    RTD_INTERCHANGE_FULL(row,1) = time;
                    RTD_INTERCHANGE_FULL(row,2) = lookahead_interval;
                    row = row+1;
                end;
            end;
            time = time + timechange;
        end;
        for t=1:size(RTD_INTERCHANGE_FULL,1)
%             lookahead_index = floor(24*RTD_INTERCHANGE_FULL(t,2)*(1/IDAC)+eps) + 1;      %Because hour 0 is index 1
%             RTD_INTERCHANGE_FULL(t,3:ninterchange+2) = DAC_INTERCHANGE_FULL(min(size(DAC_INTERCHANGE_FULL,1),lookahead_index),3:ninterchange+2);
            idx=find(abs(RTD_INTERCHANGE_FULL(t,2)-dac_fixed_ref(:,1))<eps);
            if isempty(idx)
                idx=size(dac_fixed_ref,1);
            end
            RTD_INTERCHANGE_FULL(t,3:end)=dac_fixed_ref(idx,2:end);
        end;
        RTD_INTERCHANGE_FIELD = DAC_INTERCHANGE_FIELD;
    end
    
    % Create actual interchange schedule by interpolating the RTD schedule
    NUMBER_OF_DAYS=simulation_days;
    AGC_RESOLUTION=t_AGC;
    INPUT_RESOLUTION=IRTD;
    ACTUAL_INTERCHANGE_FULL=zeros(size(ACTUAL_LOAD_FULL,1),ninterchange+1);
    ACTUAL_INTERCHANGE_FULL(:,1)=ACTUAL_LOAD_FULL(:,1);
    for num2conv=1:ninterchange
%         raw_load_data=RTD_INTERCHANGE_FULL((HRTD+1:HRTD:size(RTD_INTERCHANGE_FULL,1)-HRTD+1),2+num2conv);
        raw_load_data=RTD_INTERCHANGE_FULL((1:HRTD:size(RTD_INTERCHANGE_FULL,1)-HRTD),2+num2conv);
        % Linearize the load data
        number_of_raw_data_points_per_day=60*24/INPUT_RESOLUTION;
        number_of_agc_intervals_per_N_minutes=60/AGC_RESOLUTION*INPUT_RESOLUTION;
        total_number_of_agc_data_points=number_of_raw_data_points_per_day*number_of_agc_intervals_per_N_minutes*NUMBER_OF_DAYS;
        linearized_load_temp=zeros(total_number_of_agc_data_points,1);k=1;
        for i=1:number_of_raw_data_points_per_day*NUMBER_OF_DAYS-1
            agc_load_increment=(raw_load_data(i+1,1)-raw_load_data(i,1))/number_of_agc_intervals_per_N_minutes;
            for j=1:number_of_agc_intervals_per_N_minutes
                linearized_load_temp(k,1)=raw_load_data(i,1)+agc_load_increment*(j-1);
                k=k+1;
            end
        end
        for j=1:number_of_agc_intervals_per_N_minutes
            linearized_load_temp(k,1)=raw_load_data(end,1)+agc_load_increment*(j-1);
            k=k+1;
        end
        ACTUAL_INTERCHANGE_FULL(:,1+num2conv)=linearized_load_temp;
    end;
    ACTUAL_INTERCHANGE_FIELD={'TIME',DAC_INTERCHANGE_FIELD{3:end}};
else
    DAC_INTERCHANGE_FULL=zeros(24*simulation_days,3);
    RTC_INTERCHANGE_FULL=zeros(60/tRTC*HRTC*simulation_days*24+HRTC,3);
    RTD_INTERCHANGE_FULL=zeros(60/tRTD*HRTD*simulation_days*24+HRTD,3);
    ACTUAL_INTERCHANGE_FULL=zeros(60/t_AGC*60*24*simulation_days,2);
    DAC_INTERCHANGE_FIELD={'TIME','INTERVAL','NONE'};
    RTC_INTERCHANGE_FIELD=DAC_INTERCHANGE_FIELD;
    RTD_INTERCHANGE_FIELD=DAC_INTERCHANGE_FIELD;
    ACTUAL_INTERCHANGE_FIELD={'TIME',DAC_INTERCHANGE_FIELD{3:end}};
end


