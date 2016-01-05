%{
AGC Sub-Model
%}

agc_time=time;
AGC_BASEPOINT(1,1) = time;
%To show the number of intervals where generators hit their max, rather
%than gen-intervals
max_interval_limit_hit = Max_Reg_Limit_Hit(1,2);
min_interval_limit_hit = Min_Reg_Limit_Hit(1,2);

reg_proportion = 2; %1 by ramp rate, 2 by reg schedule
%if Max_Reg_Limit_Hit(1,1) == Max_Reg_Limit_Hit(1,2)

% %AGC Mode
% for i=1:ngen
%     switch GEN_AGC_MODES(i)
%         case 1
%             ACE_Target(i) = 0;
%             agc_deadband_Target(i) = agc_deadband;
%         case 2
%             ACE_Target(i) = ACE_raw;
%             agc_deadband_Target(i) = agc_deadband;
%         case 3
%             ACE_Target(i) = SACE;
%             agc_deadband_Target(i) = agc_deadband;
%         case 4
%             Time_Left_in_CPS2_interval = CPS2_interval - mod(agc_time*60,CPS2_interval);
%             Anticipated_CPS2 = ACE_CPS2 + ACE_raw*(Time_Left_in_CPS2_interval/CPS2_interval);
%             ACE_Target(i) = Anticipated_CPS2;
%             agc_deadband_Target(i) = max(agc_deadband,L10);
%         case 6
%             ACE_Target(i) = ACE_Target_in(i);
%             agc_deadband_Target(i) = agc_deadband_in(i);
%     end;
% end;
if ~exist('ACE_Target_in','var')
    ACE_Target_in=zeros(size(GEN_AGC_MODES));
end
if ~exist('agc_deadband_in','var')
    agc_deadband_in=zeros(size(GEN_AGC_MODES));
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
AGC_energyup_available = sum(REGULATION_UP(1,2:ngen+1));
AGC_energydown_available = sum(REGULATION_DOWN(1,2:ngen+1));
max_reg=zeros(ngen,1);
min_reg=zeros(ngen,1);

% for j=1:ngen
%     if unit_pumping_agc(j,1) == 1 || unit_pumpdown_agc(j,1) == 1
% %         max_reg(j,1) = next_pump_RTD(1,j+1) - REGULATION_UP(1,j+1);
% %         min_reg(j,1) = next_pump_RTD(1,j+1) + REGULATION_DOWN(1,j+1);
% %         max_reg(j,1) = current_pump_agc(1,1+j) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*next_pump_RTD(1,j+1) - REGULATION_UP(1,j+1);
% %         min_reg(j,1) = current_pump_agc(1,1+j) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*next_pump_RTD(1,j+1) + REGULATION_DOWN(1,j+1);
%         max_reg(j,1) = RTSCEDBINDINGPUMPSCHEDULE(end-1,1+j) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*(next_pump_RTD(1,j+1)-RTSCEDBINDINGPUMPSCHEDULE(end-1,1+j)) - REGULATION_UP(1,j+1);
%         min_reg(j,1) = RTSCEDBINDINGPUMPSCHEDULE(end-1,1+j) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*(next_pump_RTD(1,j+1)-RTSCEDBINDINGPUMPSCHEDULE(end-1,1+j)) + REGULATION_DOWN(1,j+1);
%     else
% %         max_reg(j,1) = next_RTD(1,j+1) + REGULATION_UP(1,j+1);
% %         min_reg(j,1) = next_RTD(1,j+1) - REGULATION_DOWN(1,j+1);
% %         max_reg(j,1) = current_gen_agc(1,1+j) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*next_RTD(1,j+1) + REGULATION_UP(1,j+1);
% %         min_reg(j,1) = current_gen_agc(1,1+j) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*next_RTD(1,j+1) - REGULATION_DOWN(1,j+1);
%         max_reg(j,1) = RTSCEDBINDINGSCHEDULE(end-1,1+j) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*(next_RTD(1,j+1)-RTSCEDBINDINGSCHEDULE(end-1,1+j)) + REGULATION_UP(1,j+1);
%         min_reg(j,1) = RTSCEDBINDINGSCHEDULE(end-1,1+j) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD))*(next_RTD(1,j+1)-RTSCEDBINDINGSCHEDULE(end-1,1+j)) - REGULATION_DOWN(1,j+1);
%     end;
% end;
agcIDX=unit_pumping_agc(:,1) == 1| unit_pumpdown_agc(:,1) == 1;
max_reg(agcIDX,1) = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_pump_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) - REGULATION_UP(1,find(agcIDX)+1);
min_reg(agcIDX,1) = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_pump_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) + REGULATION_DOWN(1,find(agcIDX)+1);
agcIDX=~agcIDX;
max_reg(agcIDX,1) = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) + (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) + REGULATION_UP(1,find(agcIDX)+1);
min_reg(agcIDX,1) = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1) - (mod(AGC_interval_index,60/t_AGC*tRTD)/(60/t_AGC*tRTD)).*(next_RTD(1,find(agcIDX)+1)-RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1-1,find(agcIDX)+1)) - REGULATION_DOWN(1,find(agcIDX)+1);

% AGC_rampup_available = 0;
% AGC_rampdown_available = 0;
% for j=1:ngen
%     if REGULATION_UP(:,1+j) > eps
%         AGC_rampup_available = AGC_rampup_available + ramp_agc(j,1);
%     end;
%     if REGULATION_DOWN(:,1+j) > eps
%         AGC_rampdown_available = AGC_rampdown_available + ramp_agc(j,1);
%     end;
% end;
agctemp=REGULATION_UP(1,2:end);
AGC_rampup_available=sum(ramp_agc(agctemp>eps));
agctemp=REGULATION_DOWN(1,2:end);
AGC_rampdown_available=sum(ramp_agc(agctemp>eps));

for i=1:ngen
    if ( (ACE_Target(i) < -1*agc_deadband_Target(i) && REGULATION_UP(:,1+i) > eps) ...
            || ( ACE_Target(i) > agc_deadband_Target(i) && REGULATION_DOWN(:,1+i) > eps) )
            if ACE_Target(i) < -1*agc_deadband_Target(i)
                AGC_ramp = max(-1*ramp_agc(i,1)*(t_AGC/60),(ramp_agc(i,1)/AGC_rampup_available)*ACE_Target(i));
                AGC_ramp2 = max(-1*ramp_agc(i,1)*(t_AGC/60),(REGULATION_UP(1,1+i)/AGC_energyup_available)*ACE_Target(i));
            else
                AGC_ramp = min(ramp_agc(i,1)*(t_AGC/60),(ramp_agc(i,1)/AGC_rampdown_available)*ACE_Target(i));
                AGC_ramp2 = min(ramp_agc(i,1)*(t_AGC/60),(REGULATION_DOWN(1,1+i)/AGC_energydown_available)*ACE_Target(i));
            end;
            if unit_pumping_agc(i,1) == 1 || unit_pumpdown_agc(i,1) == 1
                if reg_proportion == 1
                    AGC_BASEPOINT(1+i)= min(min_reg(i,1),max(max_reg(i,1),current_pump_agc(1,1+i) + AGC_ramp));
                elseif reg_proportion == 2
                    AGC_BASEPOINT(1+i)= min(min_reg(i,1),max(max_reg(i,1),current_pump_agc(1,1+i) + AGC_ramp2));
                end;
            else
                if reg_proportion == 1
                    AGC_BASEPOINT(1+i)= max(min_reg(i,1),min(max_reg(i,1),current_gen_agc(1,1+i) - AGC_ramp));
                elseif reg_proportion == 2
                    AGC_BASEPOINT(1+i)= max(min_reg(i,1),min(max_reg(i,1),current_gen_agc(1,1+i) - AGC_ramp2));
                else
                end;
            end;
            if AGC_BASEPOINT(1+i) == max_reg(i,1)
                Max_Reg_Limit_Hit(1,1) = Max_Reg_Limit_Hit(1,1) + 1;
                Max_Reg_Limit_Hit(1,2) = max_interval_limit_hit + 1;
            end;
    elseif  ((REGULATION_UP(:,1+i) < eps && REGULATION_DOWN(:,1+i) < eps) ...
            || ( ACE_Target(i) >= -1*agc_deadband_Target(i) && REGULATION_UP(:,1+i) > eps) ...
            || ( ACE_Target(i) <= agc_deadband_Target(i) && REGULATION_DOWN(:,1+i) > eps) )  
            if unit_pumping_agc(i,1) == 1 || unit_pumpdown_agc(i,1) == 1
                AGC_ramp = min(ramp_agc(i,1),max(-1*ramp_agc(i,1),(next_pump_RTD(1,1+i)-current_pump_agc(1,1+i))/(60*(next_pump_RTD(1,1) - agc_time))));
                AGC_BASEPOINT(1+i)= max(0,current_pump_agc(1,1+i) + AGC_ramp*(t_AGC/60));
            else
                AGC_ramp = min(ramp_agc(i,1),max(-1*ramp_agc(i,1),(next_RTD(1,1+i)-current_gen_agc(1,1+i))/(60*(next_RTD(1,1) - agc_time))));
                if GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16
                    AGC_BASEPOINT(1+i)= max(0,current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60));
                else
                    AGC_BASEPOINT(1+i)= current_gen_agc(1,1+i) + AGC_ramp*(t_AGC/60);
                end
            end;
    end;
            
end;

AGC_SCHEDULE(AGC_interval_index,:)=AGC_BASEPOINT;


