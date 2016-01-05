stop = 0;
% if mod(time,6) == 0 && time > 0 || time == 106
% 	save 'debugws.mat' -regexp ^(?!(BRANCHBUS2|GENBUS2|PARTICIPATION_FACTORS)$).
% end
%{
try
    if ITRP > 0 && rtsced_update == 0
        stop = 1;
    end
    %{
    for i=1:ngen
        if abs(RTDRAMP_UP_DUAL.val(i,2)) > 0 && abs(RTDRAMP_UP_DUAL.val(i,1)) == 0 && rtsced_update == 0
            stop = 1;
        end;
    end
    if exist('old_lmp_2','var') ~=1
        old_lmp_2=0;
    end;
    if RTDLMP.val(1,1) < old_lmp_2 - .01 && rtsced_update == 0
        stop = 1;
    end;
    %}
    old_lmp_2=RTDLMP.val(1,2);
    if any(any(RTDLMP.val(:,:) > 3000)) && rtsced_update == 0
        stop = 1;
    end;
    
catch;end;
%}