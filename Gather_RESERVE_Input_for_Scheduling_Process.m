function [RESERVELEVEL_VAL]=Gather_RESERVE_Input_for_Scheduling_Process(RESERVE_FULL,interval_index,H)


RESERVELEVEL_VAL = RESERVE_FULL(H*(interval_index-1)+1:H*(interval_index-1)+H,3:end);
