% Outage is either determined randomly or chosen before we go into the real time operations.
gen_outage_hour = inf.*ones(ngen,1);
gen_outage_minute = inf.*ones(ngen,1);
gen_outage_second = inf.*ones(ngen,1);
gen_outage_time = inf.*ones(ngen,1);
gen_repair_time = -inf.*ones(ngen,1);
rtc_gen_forced_out = zeros(ngen,1); %These all must be different since initialization times must be taken into account
rtd_gen_forced_out = zeros(ngen,1); %These all must be different since initialization times must be taken into account
actual_gen_forced_out = zeros(ngen,1);
ctgc_start = 0;
ctgc_start_time = inf;

if strcmp(SIMULATE_CONTINGENCIES,'YES') == 1
    if Contingency_input_check == 1
        gen_outage_time=gen_outage_time_in;
        gen_repair_time=gen_outage_time+GENVALUE_VAL(:,mttr);
        gen_repair_time(gen_repair_time==inf)=-inf;
    else
        for i=1:ngen
            full_outage = GENVALUE_VAL(i,forced_outage_rate)/GENVALUE_VAL(i,mttr);%full outage probability.
            h=1;
            while h<=floor(end_time)
                outage_random_number = rand();
                if(outage_random_number < full_outage)
                    gen_outage_hour(i,1) = h-1;
                    gen_outage_minute(i,1) = round(60*rand());
                    gen_outage_second(i,1) = t_AGC*round((60/t_AGC)*rand());
                    gen_outage_time(i,1) = gen_outage_hour(i,1) + gen_outage_minute(i,1)/60 + gen_outage_second(i,1)/(60*60);
                    gen_repair_time(i,1) = gen_outage_time(i,1) + GENVALUE_VAL(i,mttr);
                    %gen_repair_time(i,1) = gen_outage_time(i,1) + random('logn',log(GENVALUE_VAL(i,mttr)),0.5);
                    h=floor(end_time);
                end;
                h=h+1;
            end;
        end;
    end;
end;