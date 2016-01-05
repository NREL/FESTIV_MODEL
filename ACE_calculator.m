function[ACE_raw,ACE_int,ACE_ABS,ACE_CPS2,SACE] =ACE_calculator(previous_ACE_int,previous_CPS2_ACE,previous_SACE,previous_ACE_ABS,...
    current_gen,current_load,current_pump,...
    CPS2_interval,K1,K2,t_agc,ngen,losses)

%instantaneous ACE. In MW
ACE_raw = sum(current_gen(2:1+ngen)) - current_load(1,2) - sum(current_pump(2:1+ngen)) - losses;

%Total ACE summed (integrated) for up to that time. In MWH
ACE_int = ACE_raw*(t_agc/(60*60)) + previous_ACE_int;

%Smoothed ACE. Integrated over Tn and proportional value for instantaneous. In MW.  
SACE = K1*ACE_raw + K2*mean(previous_SACE);

%absolute value of ACE summed (integrated). AACEE, absolute ACE in Energy,
%primary metric. In MWH
ACE_ABS = abs(ACE_raw*(t_agc/3600)) + previous_ACE_ABS;

%ACE summed up until CPS2 interval ends. For use in CPS2 violation. In
%MWH/(CPS2interval/60). e.g., for 10 min cps 2 interval, units would be
%MW-10min, if cps2 interval was 60 minutes, would be in MWH.
ACE_CPS2 = ACE_raw*(t_agc/(CPS2_interval*60)) + previous_CPS2_ACE;

