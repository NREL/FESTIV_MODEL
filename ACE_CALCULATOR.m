%instantaneous ACE. In MW
ACE_raw = sum(current_gen_agc(2:1+ngen)) - current_load_agc(1,2) + sum(current_pump_agc(2:end)) - losses;

%Total ACE summed (integrated) for up to that time. In MWH
ACE_int = ACE_raw*(t_AGC/(60*60)) + previous_ACE_int;

%Smoothed ACE. Integrated over Tn and proportional value for instantaneous. In MW.  
SACE = K1*ACE_raw + K2*mean(previous_SACE);

%absolute value of ACE summed (integrated). AACEE, absolute ACE in Energy,
%primary metric. In MWH
AACEE = abs(ACE_raw*(t_AGC/3600)) + previous_ACE_ABS;

%ACE summed up until CPS2 interval ends. For use in CPS2 violation. In
%MWH/(CPS2interval/60). e.g., for 10 min cps 2 interval, units would be
%MW-10min, if cps2 interval was 60 minutes, would be in MWH.
ACE_CPS2 = ACE_raw*(t_AGC/(CPS2_interval*60)) + previous_CPS2_ACE;

