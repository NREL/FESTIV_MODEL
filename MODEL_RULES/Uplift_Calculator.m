
%{
USE:        After Cost Calculations
%}

uplift = 0;
daily_profit = zeros(simulation_days,ngen);
for i=1:ngen
    for d=1:simulation_days
        daily_profit(d,i) = sum(Profit_Result(round((24/IDAC)*(d-1)+1):round(d*(24/IDAC)),i));
        if daily_profit(d,i)<0
            uplift = uplift-daily_profit(d,i);
        end;
    end;
end;
        
    