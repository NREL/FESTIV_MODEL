function [INTERCHANGE_VAL]=Gather_INTERCHANGE_Input_for_Scheduling_Process(INTERCHANGE_FULL,interval_index,H)

INTERCHANGE_VAL(:,:)=INTERCHANGE_FULL(H*(interval_index-1)+1:H*(interval_index-1)+H,3:end);



