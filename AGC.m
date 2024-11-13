%{
AGC Sub-Model
%}

agc_time=time;
AGC_BASEPOINT(1,1) = time;
%To show the number of intervals where generators hit their max, rather
%than gen-intervals
max_interval_limit_hit = Max_Reg_Limit_Hit(1,2);
min_interval_limit_hit = Min_Reg_Limit_Hit(1,2);

if ~exist('ACE_Target_in','var')
    ACE_Target_in=zeros(size(GEN_AGC_MODES));
end
if ~exist('agc_deadband_in','var')
    agc_deadband_in=zeros(size(GEN_AGC_MODES));
end
if ~exist('agc_vg_curtailment','var')
    agc_vg_curtailment=zeros(ngen,1);
end
Time_Left_in_CPS2_interval = CPS2_interval - mod(agc_time*60,CPS2_interval);
Anticipated_CPS2 = ACE_CPS2 + ACE_raw*(Time_Left_in_CPS2_interval/CPS2_interval);
ACE_Target(GEN_AGC_MODES==1)=0;
ACE_Target(GEN_AGC_MODES==2)=ACE_raw;
ACE_Target(GEN_AGC_MODES==3)=SACE;
ACE_Target(GEN_AGC_MODES==4)=Anticipated_CPS2;
ACE_Target(GEN_AGC_MODES==6)=ACE_Target_in(GEN_AGC_MODES==6);
agc_deadband_Target(GEN_AGC_MODES==1)=agc_deadband;
agc_deadband_Target(GEN_AGC_MODES==2)=agc_deadband;
agc_deadband_Target(GEN_AGC_MODES==3)=agc_deadband;
agc_deadband_Target(GEN_AGC_MODES==4)=max(agc_deadband,L10);
agc_deadband_Target(GEN_AGC_MODES==6)=agc_deadband_in(GEN_AGC_MODES==6);

%%AGC Algorithm
REGULATION_UP(find(unit_pumpdown_agc+unit_pumpup_agc+unit_shutdown_agc+unit_startup_agc>0)+1)=0;
REGULATION_DOWN(find(unit_pumpdown_agc+unit_pumpup_agc+unit_shutdown_agc+unit_startup_agc>0)+1)=0;
AGC_energyup_available = sum(REGULATION_UP(1,2:ngen+1));
AGC_energydown_available = sum(REGULATION_DOWN(1,2:ngen+1));
max_reg=zeros(ngen,1);
min_reg=zeros(ngen,1);

agcIDX=unit_pumping_agc(:,1) == 1| unit_pumpdown_agc(:,1) == 1; agcIDX_ESR=agcIDX(storage_to_gen_index);
max_reg(agcIDX,1) = min(current_pump_agc(1,find(agcIDX)+1) -ramp_agc(find(agcIDX),1)'.*(t_AGC/60),-1*RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX_ESR)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_pump_RTD(1,find(agcIDX_ESR)+1)-RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX_ESR)+1)) - REGULATION_UP(1,find(agcIDX)+1));
min_reg(agcIDX,1) = max(current_pump_agc(1,find(agcIDX)+1) +ramp_agc(find(agcIDX),1)'.*(t_AGC/60),-1*RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX_ESR)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_pump_RTD(1,find(agcIDX_ESR)+1)-RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX_ESR)+1)) + REGULATION_DOWN(1,find(agcIDX)+1));
agcIDX=~agcIDX;
max_reg(agcIDX,1) = max(current_gen_agc(1,find(agcIDX)+1) - ramp_agc(find(agcIDX),1)'.*(t_AGC/60),RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) + REGULATION_UP(1,find(agcIDX)+1));
min_reg(agcIDX,1) = min(current_gen_agc(1,find(agcIDX)+1) + ramp_agc(find(agcIDX),1)'.*(t_AGC/60),RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) - REGULATION_DOWN(1,find(agcIDX)+1));

agctemp=REGULATION_UP(1,2:end);
AGC_rampup_available=sum(ramp_agc(agctemp>eps));
agctemp=REGULATION_DOWN(1,2:end);
AGC_rampdown_available=sum(ramp_agc(agctemp>eps));

for i=1:ngen
    if ( (ACE_Target(i) < -1*agc_deadband_Target(i) && REGULATION_UP(:,1+i) > eps) ...
            || ( ACE_Target(i) > agc_deadband_Target(i) && REGULATION_DOWN(:,1+i) > eps) )
            if ACE_Target(i) < -1*agc_deadband_Target(i)
                if reg_proportion == 1
                    AGC_ramp = max(-1*ramp_agc(i,1)*(t_AGC/60),(ramp_agc(i,1)/AGC_rampup_available)*ACE_Target(i));
                elseif reg_proportion == 2
                    AGC_ramp2 = max(-1*ramp_agc(i,1)*(t_AGC/60),(REGULATION_UP(1,1+i)/AGC_energyup_available)*ACE_Target(i));
                elseif reg_proportion == 3
                    AGC_ramp3 = max(-1*ramp_agc(i,1)*(t_AGC/60),AGC_Participation_Factor(i,1)*ACE_Target(i));  
                end;
            else
                if reg_proportion == 1
                    AGC_ramp = min(ramp_agc(i,1)*(t_AGC/60),(ramp_agc(i,1)/AGC_rampdown_available)*ACE_Target(i));
                elseif reg_proportion == 2
                    AGC_ramp2 = min(ramp_agc(i,1)*(t_AGC/60),(REGULATION_DOWN(1,1+i)/AGC_energydown_available)*ACE_Target(i));
                elseif reg_proportion == 3
                    AGC_ramp3 = min(ramp_agc(i,1)*(t_AGC/60),AGC_Participation_Factor(i,1)*ACE_Target(i));  
                end;
            end;
            if unit_pumping_agc(i,1) == 1 || unit_pumpdown_agc(i,1) == 1
                if reg_proportion == 1
                    AGC_BASEPOINT(1+i)= min(min_reg(i,1),max(max_reg(i,1),current_pump_agc(1,1+i) - AGC_ramp));
                elseif reg_proportion == 2
                    AGC_BASEPOINT(1+i)= min(min_reg(i,1),max(max_reg(i,1),current_pump_agc(1,1+i) - AGC_ramp2));
                elseif reg_proportion == 3
                    AGC_BASEPOINT(1+i)= min(min_reg(i,1),max(max_reg(i,1),current_pump_agc(1,1+i) - AGC_ramp3));                    
                end;
            else
                if reg_proportion == 1
                    AGC_BASEPOINT(1+i)= max(min_reg(i,1),min(max_reg(i,1),current_gen_agc(1,1+i) - AGC_ramp));
                elseif reg_proportion == 2
                    AGC_BASEPOINT(1+i)= max(min_reg(i,1),min(max_reg(i,1),current_gen_agc(1,1+i) - AGC_ramp2));
                elseif reg_proportion == 3
                    AGC_BASEPOINT(1+i)= max(min_reg(i,1),min(max_reg(i,1),current_gen_agc(1,1+i) - AGC_ramp3));                    
                end;
            end;
            if AGC_BASEPOINT(1+i) == max_reg(i,1)
                Max_Reg_Limit_Hit(1,1) = Max_Reg_Limit_Hit(1,1) + 1;
                Max_Reg_Limit_Hit(1,2) = max_interval_limit_hit + 1;
            end;
            if (GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == wind_gen_type_index)  && ((ACE_Target(i) < -1*agc_deadband_Target(i) && REGULATION_UP(:,1+i) > eps) ...
            || ( ACE_Target(i) > agc_deadband_Target(i) && REGULATION_DOWN(:,1+i) > eps)) 
                agc_vg_curtailment(i,1) = 1;
            else
                agc_vg_curtailment(i,1) = 0;
            end
    elseif  ((REGULATION_UP(:,1+i) < eps && REGULATION_DOWN(:,1+i) < eps) ...
            || ( ACE_Target(i) >= -1*agc_deadband_Target(i) && REGULATION_UP(:,1+i) > eps) ...
            || ( ACE_Target(i) <= agc_deadband_Target(i) && REGULATION_DOWN(:,1+i) > eps) )  
            if unit_pumping_agc(i,1) == 1 || unit_pumpdown_agc(i,1) == 1
               
                AGC_ramp = min(ramp_agc(i,1),max(-1*ramp_agc(i,1),(next_pump_RTD(1,1+find(storage_to_gen_index==i))-current_pump_agc(1,1+i))/(60*(next_pump_RTD(1,1) - agc_time))));
                AGC_BASEPOINT(1+i)= min(0,current_pump_agc(1,1+i) + AGC_ramp*(t_AGC/60));
            elseif unit_startup_agc(i,1) && current_gen_agc(1,1+i) <= GENVALUE_VAL(i,min_gen)
                AGC_ramp = ramp_agc(i,1);
                if GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index
                    AGC_BASEPOINT(1+i)= max(0,current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60));
                else
                    AGC_BASEPOINT(1+i)= current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60);
                end
            elseif unit_shutdown_agc(i,1)
                AGC_ramp = -1*ramp_agc(i,1);
                if GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index
                    AGC_BASEPOINT(1+i)= max(0,current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60));
                else
                    AGC_BASEPOINT(1+i)= current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60);
                end
            else
                AGC_ramp = min(ramp_agc(i,1),max(-1*ramp_agc(i,1),(next_RTD(1,1+i)-current_gen_agc(1,1+i))/(60*(next_RTD(1,1) - agc_time))));
                if GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index
                    AGC_BASEPOINT(1+i)= max(0,current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60));
                else
                    AGC_BASEPOINT(1+i)= current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60);
                end
            end;
    end;
            
end;
% Check for min/max SoC being reached
for e=1:nESR
    if ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) > STORAGEVALUE_VAL(e,storage_max)
       AGC_BASEPOINT(1+storage_to_gen_index(e)) = current_pump_agc(1+storage_to_gen_index(e)) - (ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) - STORAGEVALUE_VAL(e,storage_max))/(t_AGC/60/60)/STORAGEVALUE_VAL(e,efficiency);
    elseif ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) < 0
       AGC_BASEPOINT(1+storage_to_gen_index(e)) = current_gen_agc(1+storage_to_gen_index(e)) + ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e)/(t_AGC/60/60);
    end
end