
disp(['Unadjusted Production Cost: ',convert2currency(Cost_Result_Total)])
disp(['Unadjusted Revenue (load payment): ',convert2currency(Revenue_Result_Total)])
disp(['Profit: ',convert2currency(Profit_Result_Total)])
disp(['Adjusted for Inadvertent Interchange:   ',convert2currency(adjusted_cost)]);
try disp(['Adjusted for Storage Level: ',convert2currency(adjusted_storage_cost)]);catch;end;
try disp(['Start-Up Costs: ',convert2currency(Total_SU_Costs)]);catch;end;

try disp(['ALFEE: ',num2str(ALFEE)]);catch;end;
disp(['Generator Cycles: ',num2str(generator_cycles)])
disp(['CPS2 Violations: ',num2str(CPS2_violations)])
disp(['CPS2: ',sprintf('%.02f %%',CPS2*100)])
disp(['Absolute ACE in Energy (AACEE): ',num2str(Total_MWH_Absolute_ACE)])
disp(['Max Reg Limit Hit: ',num2str(Max_Reg_Limit_Hit)])
disp(['Min Reg Limit Hit: ',num2str(Min_Reg_Limit_Hit)])
disp(['ACE Standard Deviation: ',num2str(sigma_ACE)])
disp(['Mean-Absolute ACE: ',num2str(mean(abs(ACE(:,raw_ACE_index))))])
disp(['Inadvertent Interchange: ',num2str(inadvertent_interchange)]);
disp(' ')