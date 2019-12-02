%Change DASCUC Horizon

%
%After Time loop
%

%currently specific to dascuc but can alter to others
if dascuc_update + eps >= tDAC
        %{
        DAHORIZON: 
        (1)Fixed Horizon, variable endpoint, variable startpoint 
        (2)Fixed Endpoint, fixed startpoint, this will always start at hour 0
        (3)Fixed endpoint, variable startpoint horizon greater than or equal, 
        (4)Fixed endpoint, variable startpoint, horizon less than or equal.
        %}
        HDAC=HDAC_old;
        
        if DAHORIZONTYPE == 1
            dascuc_start_horizon = time + (24-GDAC);
            dascuc_end_horizon = dascuc_start_horizon + IDAC*HDAC;
        elseif DAHORIZONTYPE == 2
            dascuc_end_horizon  = floor((time+eps)/24)+IDAC*HDAC;
            dascuc_start_horizon = dascuc_end_horizon - HDAC;
        elseif DAHORIZONTYPE == 3
            dascuc_end_horizon = IDAC*HDAC*(1+ceil((time+(24-GDAC)-eps)/24));
            dascuc_start_horizon = time + (24-GDAC);
        elseif DAHORIZONTYPE == 4
            dascuc_end_horizon = IDAC*HDAC*(1+floor((time+(24-GDAC)+eps)/24));
            dascuc_start_horizon = time + (24-GDAC);
        else
            dascuc_start_horizon = 0;dascuc_end_horizon = 0;
        end;
        
        HDAC_old = HDAC;
        HDAC = floor(dascuc_end_horizon-dascuc_start_horizon);

end;