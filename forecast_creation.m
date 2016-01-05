function[new_data] = forecast_creation(actual_data,n,interval_length,advisory_interval_length,interval_update,ninterval,AGC_seconds,model_time,days,error,data_max,...
    model_type,data_type)


actual_data_size = size(actual_data,1);
actual_minute_count = 60/AGC_seconds;
switch model_type
    case 'DA'
        total_runs = 60/interval_update*24*days;
    case 'RT'
        total_runs = 1+60/interval_update*24*days;
end;
new_data = zeros(ninterval*total_runs,2+n);
timechange = interval_update/(24*60);
intervalchange = interval_length/(24*60);
advisoryintervalchange = advisory_interval_length/(24*60);
oneminute = 1/(24*60);
eps = 0.000001;



row=1;
if data_type == 2
    time = 1-timechange;
    lookahead_interval = 0;
    switch model_type
        case 'DA'
            da_model_index = 1;
            new_data(row,1) = da_model_index;
            new_data(row,2) = lookahead_interval;
        case 'RT'
            new_data(row,1) = time;
            new_data(row,2) = lookahead_interval;
    end;
    for k = 1:n
        new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
                min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))),1+k));
    end;
    row = row+1;
    if ninterval >1
        lookahead_interval = lookahead_interval + oneminute;
        while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
            lookahead_interval = lookahead_interval + oneminute;
        end;
        switch model_type
            case 'DA'
                new_data(row,1) = da_model_index;
                new_data(row,2) = lookahead_interval;
            case 'RT'
                new_data(row,1) = time;
                new_data(row,2) = lookahead_interval;
        end;
        for k=1:n
            new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
                min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))+1),1+k));
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
        end;
        row = row + 1;
    end;
    if ninterval > 2
        for t1=3:ninterval
            lookahead_interval = lookahead_interval + advisoryintervalchange;
            switch model_type
                case 'DA'
                    new_data(row,1) = da_model_index;
                    new_data(row,2) = lookahead_interval;
                case 'RT'
                    new_data(row,1) = time;
                    new_data(row,2) = lookahead_interval;
            end;
            for k=1:n
                new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                    min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
            end;
            row = row+1;
        end;
    end;
    switch model_type
        case 'DA'
            time = time + timechange;
        case 'RT'
            time = 0;
    end;
    for t=2:total_runs
        switch model_type
            case 'DA'
                lookahead_interval = time ;
                da_model_index = da_model_index + 1;
                new_data(row,1) = da_model_index;
                new_data(row,2) = lookahead_interval;
            case 'RT'
                lookahead_interval = time + intervalchange;
                new_data(row,1) = time;
                new_data(row,2) = lookahead_interval;
        end;
        for k = 1:n
            new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
                min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))),1+k));
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
        end;
        row = row+1;
        if ninterval >1
            lookahead_interval = lookahead_interval + oneminute;
            while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                    && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                lookahead_interval = lookahead_interval + oneminute;
            end;
            switch model_type
                case 'DA'
                    new_data(row,1) = da_model_index;
                    new_data(row,2) = lookahead_interval;
                case 'RT'
                    new_data(row,1) = time;
                    new_data(row,2) = lookahead_interval;
            end;
            for k=1:n
                new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                    min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
            end;
            row = row + 1;
        end;
        if ninterval > 2
            for t1=3:ninterval
                lookahead_interval = lookahead_interval + advisoryintervalchange;
                switch model_type
                    case 'DA'
                        new_data(row,1) = da_model_index;
                        new_data(row,2) = lookahead_interval;
                    case 'RT'
                        new_data(row,1) = time;
                        new_data(row,2) = lookahead_interval;
                end;
                for k=1:n
                    new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                        min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                    if isnan(new_data(row,2+k)) == 1
                        new_data(row,2+k) = new_data(row-1,2+k);
                    end;
                end;
                row = row+1;
            end;
        end;

        time = time + timechange;
    end;
    
    
elseif data_type == 3
    %A note that DASCUC would not work correctly with persistence.
    time = 1-timechange;
    lookahead_interval = 0;
    new_data(row,1) = time;
    new_data(row,2) = lookahead_interval;
    for k = 1:n
        new_data(row,2+k) = actual_data(1,1+k);
    end;
    row = row+1;
    if ninterval >1
        lookahead_interval = lookahead_interval + oneminute;
        while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
            lookahead_interval = lookahead_interval + oneminute;
        end;
        new_data(row,1) = time;
        new_data(row,2) = lookahead_interval;
        for k=1:n
            new_data(row,2+k) = actual_data(1,1+k);
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
        end;
        row = row + 1;
    end;
    if ninterval > 2
        for t1=3:ninterval
            lookahead_interval = lookahead_interval + advisoryintervalchange;
            new_data(row,1) = time;
            new_data(row,2) = lookahead_interval;
            for k=1:n
                new_data(row,2+k) = actual_data(1,1+k);
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
            end;
            row = row+1;
        end;
    end;
    time = 0;
    for t=2:total_runs
        lookahead_interval = time + intervalchange;
        new_data(row,1) = time;
        new_data(row,2) = lookahead_interval;
        for k = 1:n
            new_data(row,2+k) = actual_data(min(actual_data_size,max(1,round(time*60*24*actual_minute_count -(model_time*actual_minute_count))+1)),1+k);
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
        end;
        row = row+1;
        if ninterval >1
            lookahead_interval = lookahead_interval + oneminute;
            while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                    && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                lookahead_interval = lookahead_interval + oneminute;
            end;
            new_data(row,1) = time;
            new_data(row,2) = lookahead_interval;
            for k=1:n
                new_data(row,2+k) = actual_data(min(actual_data_size,max(1,round(time*60*24*actual_minute_count -(model_time*actual_minute_count))+1)),1+k);
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
            end;
            row = row + 1;
        end;
        if ninterval > 2
            for t1=3:ninterval
                lookahead_interval = lookahead_interval + advisoryintervalchange;
                new_data(row,1) = time;
                new_data(row,2) = lookahead_interval;
                for k=1:n
                    new_data(row,2+k) = actual_data(min(actual_data_size,max(1,round(time*60*24*actual_minute_count -(model_time*actual_minute_count))+1)),1+k);
                    if isnan(new_data(row,2+k)) == 1
                        new_data(row,2+k) = new_data(row-1,2+k);
                    end;
                end;
                row = row+1;
            end;
        end;

        time = time + timechange;
    end;
    
elseif data_type == 4
    time = 1-timechange;
    lookahead_interval = 0;
    lookahead_index = 1;
    new_data(row,1) = time;
    new_data(row,2) = lookahead_interval;
    for k = 1:n
        new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
            min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))),1+k));
        new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
    end;
    row = row+1;
    lookahead_index = lookahead_index + 1;
    if ninterval >1
        lookahead_interval = lookahead_interval + oneminute;
        while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
            lookahead_interval = lookahead_interval + oneminute;
        end;
        new_data(row,1) = time;
        new_data(row,2) = lookahead_interval;
        for k=1:n
            new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
                min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))),1+k));
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
            new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
        end;
        lookahead_index = lookahead_index + 1;
        row = row + 1;
    end;
    if ninterval > 2
        for t1=3:ninterval
            lookahead_interval = lookahead_interval + advisoryintervalchange;
            new_data(row,1) = time;
            new_data(row,2) = lookahead_interval;
            for k=1:n
                new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                    min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
                new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
            end;
            lookahead_index = lookahead_index + 1;
            row = row+1;
        end;
    end;
    time = 0;
    for t=2:total_runs
        lookahead_interval = time + intervalchange;
        lookahead_index = 1;
        new_data(row,1) = time;
        new_data(row,2) = lookahead_interval;
        for k = 1:n
            new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(interval_length*actual_minute_count/2))+1):...
                min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(interval_length*actual_minute_count/2))),1+k));
            if isnan(new_data(row,2+k)) == 1
                new_data(row,2+k) = new_data(row-1,2+k);
            end;
            new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
        end;
        lookahead_index = lookahead_index + 1;
        row = row+1;
        if ninterval >1
            lookahead_interval = lookahead_interval + oneminute;
            while ( (mod(lookahead_interval*24*60,advisory_interval_length) - 0 > eps )...
                    && ( advisory_interval_length - mod(lookahead_interval*24*60,advisory_interval_length) > eps))
                lookahead_interval = lookahead_interval + oneminute;
            end;
            new_data(row,1) = time;
            new_data(row,2) = lookahead_interval;
            for k=1:n
                new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                    min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                if isnan(new_data(row,2+k)) == 1
                    new_data(row,2+k) = new_data(row-1,2+k);
                end;
                new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
            end;
            row = row + 1;
            lookahead_index = lookahead_index + 1;
        end;
        if ninterval > 2
            for t1=3:ninterval
                lookahead_interval = lookahead_interval + advisoryintervalchange;
                new_data(row,1) = time;
                new_data(row,2) = lookahead_interval;
                for k=1:n
                    new_data(row,2+k) = mean(actual_data(max(1,round(lookahead_interval*60*24*actual_minute_count -(advisory_interval_length*actual_minute_count/2))+1):...
                        min(actual_data_size,round(lookahead_interval*60*24*actual_minute_count +(advisory_interval_length*actual_minute_count/2))),1+k));
                    if isnan(new_data(row,2+k)) == 1
                        new_data(row,2+k) = new_data(row-1,2+k);
                    end;
                    new_data(row,2+k) = max(0,min(data_max(k,1),new_data(row,2+k) + randn()*new_data(row,2+k)*error(lookahead_index,1)));
                end;
                row = row+1;
                lookahead_index = lookahead_index + 1;
            end;
        end;

        time = time + timechange;
    end;
    
end;
    

new_data;














end
