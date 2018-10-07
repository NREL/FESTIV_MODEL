function [LOAD_VAL]=Gather_LOAD_Input_for_Scheduling_Process(LOAD_FULL,interval_index,H)


LOAD_VAL=LOAD_FULL(H*(interval_index-1)+1:H*(interval_index-1)+H,3);

