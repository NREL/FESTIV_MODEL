%What is ACE?
if AGC_interval_index ==1
    previous_ACE_int = 0;
    previous_CPS2_ACE = 0;
    previous_SACE = 0;
    previous_ACE_ABS = 0;
else
    previous_ACE_int = ACE(AGC_interval_index - 1,integrated_ACE_index);
    if(mod(time*60,CPS2_interval)- 0 < eps || CPS2_interval - mod(time*60,CPS2_interval) < eps) %Note that some rounding can create some errors here
        previous_CPS2_ACE = 0;
    else
        previous_CPS2_ACE = ACE(AGC_interval_index - 1,CPS2_ACE_index);
    end;
    previous_SACE = ACE(max(1,round(AGC_interval_index - Type3_integral/t_AGC)):AGC_interval_index-1, raw_ACE_index);
    previous_ACE_ABS = ACE(AGC_interval_index - 1,AACEE_index);
end;
