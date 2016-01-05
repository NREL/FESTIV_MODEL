HRTD=evalin('base','HRTD');
HRTC=evalin('base','HRTC');
numday=evalin('base','daystosimulate');
actual_load_input_file=cell(numday,1);
fullinputfilepath=evalin('base','inputPath');
[inputfilepath,inputfilename,inputfileextension]=fileparts(fullinputfilepath);
fileName = [inputfilepath,filesep,inputfilename,'.h5'];
nametouse=fileName;
x=h5info(nametouse);
actual_vg_input_file=cell(numday,1);
dac_load_input_file=cell(numday,1);dac_vg_input_file=cell(numday,1);dac_reserve_input_file=cell(numday,1);
rtc_load_input_file=cell(numday,1);rtc_vg_input_file=cell(numday,1);rtc_reserve_input_file=cell(numday,1);
rtd_load_input_file=cell(numday,1);rtd_vg_input_file=cell(numday,1);rtd_reserve_input_file=cell(numday,1);
for i=1:size(x.Groups(2,1).Groups,1)
    groupname=x.Groups(2,1).Groups(i,1).Name(1,2:end);
    [a,b]=strtok(groupname,'/');
    if strcmp('Actual Load Data',b(1,2:end))
        if numday==1
            actual_load_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                actual_load_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/Actual Load Data/',actual_load_input_file]);
            fields=fieldnames(y);
            actual_load_tmp2=[y.(fields{1}) y.(fields{2})];
        else
            y=h5read(nametouse,['/Time Series Data/Actual Load Data/',actual_load_input_file{1,1}]);
            fields=fieldnames(y);
            actual_load_tmp2=zeros(size(y.(fields{1})*numday,1),2);
            actual_load_tmp2(1:size(y.(fields{1}),1),1:2)=[y.(fields{1}) y.(fields{2})];
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/Actual Load Data/',actual_load_input_file{d,1}]);
                fields=fieldnames(y);
                actual_load_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),1:2)=[y.(fields{1})+d-1 y.(fields{2})];
            end
        end
        assignin('base','ACTUAL_LOAD_FULL',actual_load_tmp2);
    elseif strcmp('Actual VG Data',b(1,2:end))
        if numday==1
            actual_vg_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                actual_vg_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/Actual VG Data/',actual_vg_input_file]);
            fields=fieldnames(y);
            actual_vg_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                actual_vg_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/Actual VG Data/',actual_vg_input_file{1,1}]);
            fields=fieldnames(y);
            actual_vg_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                actual_vg_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/Actual VG Data/',actual_vg_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                    if f==1
                        actual_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),f)=y.(fields{f})+d-1;
                    else
                        actual_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),f)=y.(fields{f});
                    end
                end;   
            end
        end
        assignin('base','ACTUAL_VG_FULL',actual_vg_tmp2);
        assignin('base','ACTUAL_VG_FIELD',fields');
    elseif strcmp('DA Load Data',b(1,2:end))
        if numday==1
            dac_load_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                dac_load_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/DA Load Data/',dac_load_input_file]);
            fields=fieldnames(y);
            da_load_tmp2=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
        else
            y=h5read(nametouse,['/Time Series Data/DA Load Data/',dac_load_input_file{1,1}]);
            fields=fieldnames(y);
            da_load_tmp2=zeros(size(y.(fields{1})*numday,1),3);
            da_load_tmp2(1:size(y.(fields{1}),1),1:3)=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/DA Load Data/',dac_load_input_file{d,1}]);
                fields=fieldnames(y);
                da_load_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),1:3)=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
            end
        end
        assignin('base','DAC_LOAD_FULL',da_load_tmp2);
    elseif strcmp('DA VG Data',b(1,2:end))
        if numday==1
            dac_vg_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                dac_vg_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/DA VG Data/',dac_vg_input_file]);
            fields=fieldnames(y);
            dac_vg_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                dac_vg_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/DA VG Data/',dac_vg_input_file{1,1}]);
            fields=fieldnames(y);
            dac_vg_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                dac_vg_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/DA VG Data/',dac_vg_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                	dac_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),f)=y.(fields{f});
                end;   
            end
        end
        for f=1:size(fields,1) % Take out this loop after SMUD project
            if fields{f,1}(2) == '0' || fields{f,1}(2) == '1' || fields{f,1}(2) == '2' || fields{f,1}(2) == '3' || fields{f,1}(2) == '4' || fields{f,1}(2) == '5' || fields{f,1}(2) == '6' || fields{f,1}(2) == '7' || fields{f,1}(2) == '8' || fields{f,1}(2) == '9'
                fields{f,1}=fields{f,1}(2:end);
            end
        end;
        assignin('base','DAC_VG_FIELD',fields');
        assignin('base','DAC_VG_FULL',dac_vg_tmp2);
    elseif strcmp('DA Reserve Data',b(1,2:end))
        if numday==1
            dac_reserve_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                dac_reserve_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/DA Reserve Data/',dac_reserve_input_file]);
            fields=fieldnames(y);
            dac_reserve_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                dac_reserve_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/DA Reserve Data/',dac_reserve_input_file{1,1}]);
            fields=fieldnames(y);
            dac_reserve_tmp2=zeros(size(y.(fields{1}),1)*numday,size(fields,1));
            for f=1:size(fields,1)
                dac_reserve_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/DA Reserve Data/',dac_reserve_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                	dac_reserve_tmp2(size(y.(fields{1}),1)*(d-1)+1:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1),f)=y.(fields{f});
                end;   
            end
        end
        assignin('base','DAC_RESERVE_FULL',dac_reserve_tmp2);
    elseif strcmp('RTC Load Data',b(1,2:end))
        if numday==1
            rtc_load_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtc_load_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTC Load Data/',rtc_load_input_file]);
            fields=fieldnames(y);
            rtc_load_tmp2=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
        else
            y=h5read(nametouse,['/Time Series Data/RTC Load Data/',rtc_load_input_file{1,1}]);
            fields=fieldnames(y);
            rtc_load_tmp2=zeros((size(y.(fields{1}),1)-HRTC)*numday,3);
            rtc_load_tmp2(1:size(y.(fields{1}),1),1:3)=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTC Load Data/',rtc_load_input_file{d,1}]);
                fields=fieldnames(y);
                rtc_load_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTC:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTC,1:3)=[y.(fields{1})+d-1 y.(fields{2})+d-1 y.(fields{3})];
            end
        end
        assignin('base','RTC_LOAD_FULL',rtc_load_tmp2);
    elseif strcmp('RTC VG Data',b(1,2:end))
        if numday==1
            rtc_vg_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtc_vg_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTC VG Data/',rtc_vg_input_file]);
            fields=fieldnames(y);
            rtc_vg_tmp2=zeros((size(y.(fields{1}),1)-0)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtc_vg_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/RTC VG Data/',rtc_vg_input_file{1,1}]);
            fields=fieldnames(y);
            rtc_vg_tmp2=zeros((size(y.(fields{1}),1)-HRTC)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtc_vg_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTC VG Data/',rtc_vg_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                    if f==1 || f==2
                        rtc_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTC:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTC,f)=y.(fields{f})+d-1;
                    else
                        rtc_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTC:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTC,f)=y.(fields{f});
                    end
                end;   
            end
        end
        for f=1:size(fields,1) % Take out this loop after SMUD project
            if fields{f,1}(2) == '0' || fields{f,1}(2) == '1' || fields{f,1}(2) == '2' || fields{f,1}(2) == '3' || fields{f,1}(2) == '4' || fields{f,1}(2) == '5' || fields{f,1}(2) == '6' || fields{f,1}(2) == '7' || fields{f,1}(2) == '8' || fields{f,1}(2) == '9'
                fields{f,1}=fields{f,1}(2:end);
            end
        end;
        assignin('base','RTC_VG_FULL',rtc_vg_tmp2);
        assignin('base','RTC_VG_FIELD',fields');
    elseif strcmp('RTC Reserve Data',b(1,2:end))
        if numday==1
            rtc_reserve_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtc_reserve_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTC Reserve Data/',rtc_reserve_input_file]);
            fields=fieldnames(y);
            rtc_reserve_tmp2=zeros((size(y.(fields{1}),1)-0)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtc_reserve_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/RTC Reserve Data/',rtc_reserve_input_file{1,1}]);
            fields=fieldnames(y);
            rtc_reserve_tmp2=zeros((size(y.(fields{1}),1)-HRTC)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtc_reserve_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTC Reserve Data/',rtc_reserve_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                    if f==1 || f==2
                        rtc_reserve_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTC:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTC,f)=y.(fields{f})+d-1;
                    else
                        rtc_reserve_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTC:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTC,f)=y.(fields{f});
                    end
                end;   
            end
        end
        assignin('base','RTC_RESERVE_FULL',rtc_reserve_tmp2);
    elseif strcmp('RTD Load Data',b(1,2:end))
        if numday==1
            rtd_load_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtd_load_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTD Load Data/',rtd_load_input_file]);
            fields=fieldnames(y);
            rtd_load_tmp2=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
        else
            y=h5read(nametouse,['/Time Series Data/RTD Load Data/',rtd_load_input_file{1,1}]);
            fields=fieldnames(y);
            rtd_load_tmp2=zeros((size(y.(fields{1}),1)-HRTD)*numday,3);
            rtd_load_tmp2(1:size(y.(fields{1}),1),1:3)=[y.(fields{1}) y.(fields{2}) y.(fields{3})];
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTD Load Data/',rtd_load_input_file{d,1}]);
                fields=fieldnames(y);
                rtd_load_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTD:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTD,1:3)=[y.(fields{1})+d-1 y.(fields{2})+d-1 y.(fields{3})];
            end
        end
        assignin('base','RTD_LOAD_FULL',rtd_load_tmp2);
    elseif strcmp('RTD VG Data',b(1,2:end))
        if numday==1
            rtd_vg_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtd_vg_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTD VG Data/',rtd_vg_input_file]);
            fields=fieldnames(y);
            rtd_vg_tmp2=zeros((size(y.(fields{1}),1)-0)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtd_vg_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/RTD VG Data/',rtd_vg_input_file{1,1}]);
            fields=fieldnames(y);
            rtd_vg_tmp2=zeros((size(y.(fields{1}),1)-HRTD)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtd_vg_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTD VG Data/',rtd_vg_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                    if f==1 || f==2
                        rtd_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTD:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTD,f)=y.(fields{f})+d-1;
                    else
                        rtd_vg_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTD:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTD,f)=y.(fields{f});
                    end
                end;   
            end
        end
        for f=1:size(fields,1) % Take out this loop after SMUD project
            if fields{f,1}(2) == '0' || fields{f,1}(2) == '1' || fields{f,1}(2) == '2' || fields{f,1}(2) == '3' || fields{f,1}(2) == '4' || fields{f,1}(2) == '5' || fields{f,1}(2) == '6' || fields{f,1}(2) == '7' || fields{f,1}(2) == '8' || fields{f,1}(2) == '9'
                fields{f,1}=fields{f,1}(2:end);
            end
        end;
        assignin('base','RTD_VG_FULL',rtd_vg_tmp2);
        assignin('base','RTD_VG_FIELD',fields');
    elseif strcmp('RTD Reserve Data',b(1,2:end))
        if numday==1
            rtd_reserve_input_file=x.Groups(2,1).Groups(i,1).Datasets.Name;
        else
            for d=1:numday
                rtd_reserve_input_file{d,1}=x.Groups(2,1).Groups(i,1).Datasets(d,1).Name;
            end
        end
        if numday==1
            y=h5read(nametouse,['/Time Series Data/RTD Reserve Data/',rtd_reserve_input_file]);
            fields=fieldnames(y);
            rtd_reserve_tmp2=zeros((size(y.(fields{1}),1)-0)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtd_reserve_tmp2(:,f)=y.(fields{f});
            end;
        else
            y=h5read(nametouse,['/Time Series Data/RTD Reserve Data/',rtd_reserve_input_file{1,1}]);
            fields=fieldnames(y);
            rtd_reserve_tmp2=zeros((size(y.(fields{1}),1)-HRTD)*numday,size(fields,1));
            for f=1:size(fields,1)
                rtd_reserve_tmp2(size(y.(fields{1}),1)*(1-1)+1:size(y.(fields{1}),1)*(1-1)+size(y.(fields{1}),1),f)=y.(fields{f});
            end;
            for d=2:numday
                y=h5read(nametouse,['/Time Series Data/RTD Reserve Data/',rtd_reserve_input_file{d,1}]);
                fields=fieldnames(y);
                for f=1:size(fields,1)
                    if f==1 || f==2
                        rtd_reserve_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTD:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTD,f)=y.(fields{f})+d-1;
                    else
                        rtd_reserve_tmp2(size(y.(fields{1}),1)*(d-1)+1+HRTD:size(y.(fields{1}),1)*(d-1)+size(y.(fields{1}),1)+HRTD,f)=y.(fields{f});
                    end
                end;   
            end
        end
        assignin('base','RTD_RESERVE_FULL',rtd_reserve_tmp2);
    end
end