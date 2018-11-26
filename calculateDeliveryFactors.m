function [BUS_DELIVERY_FACTORS_VAL,GEN_DELIVERY_FACTORS_VAL,LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(H,nbus,ngen,GEN_NAME,BRANCHBUS_CALC_VAL,PTDF_VAL,LINEFLOWS,systemMVA,branch_resistances,PARTICIPATION_FACTOR_NAMES,GENBUS_VALS,BUS_VAL,PARTICIPATION_FACTORS_VAL,LOAD_VAL,LOAD_STRING)

PARTICIPATION_FACTOR_BUS_NAMES = PARTICIPATION_FACTOR_NAMES{1,1};
PARTICIPATION_FACTOR_GEN_NAMES = PARTICIPATION_FACTOR_NAMES{1,2};
% BUS DELIVERY FACTORS
BUS_DELIVERY_FACTORS_VAL=zeros(nbus,H);
for t=1:H
    for b=1:nbus
       x1=BRANCHBUS_CALC_VAL(:,2); 
       x2=BRANCHBUS_CALC_VAL(:,3);
       y1=x1==b;
       y2=x2==b;
       x=y1+y2;
       temp=1-2*sum(PTDF_VAL(logical(x),b).*LINEFLOWS(logical(x),t)/systemMVA.*branch_resistances(logical(x),1)) ;
       %temp=1-2*sum(PTDF_VAL(:,b).*LINEFLOWS(:,t)/systemMVA.*branch_resistances(:,1)) ;
       BUS_DELIVERY_FACTORS_VAL(b,t)=temp;
    end
end

% GEN DELIVERY FACTORS
GEN_DELIVERY_FACTORS_VAL=zeros(ngen,H);
for t=1:H
    for i=1:ngen
        i2=1;
        while i2<=ngen
            if strcmp(PARTICIPATION_FACTOR_GEN_NAMES(1,i),GEN_NAME(i2,1))
                gen_indice = i2;
                i2=ngen;
            end;
            i2=i2+1;
        end;
        busnames=PARTICIPATION_FACTOR_BUS_NAMES(logical(GENBUS_VALS(:,i)));
        busindicies=zeros(size(busnames));
        for j=1:size(busnames,2)
            for b=1:nbus
                if strcmp(busnames{1,j},BUS_VAL(b,1))
                    busindicies(1,j)=b;
                end
            end
        end
        GEN_DELIVERY_FACTORS_VAL(gen_indice,t)=sum(BUS_DELIVERY_FACTORS_VAL(busindicies,t).*PARTICIPATION_FACTORS_VAL(PARTICIPATION_FACTORS_VAL(:,i)>0,i));
    end
end

% LOAD DELIVERY FACTORS
LOAD_DELIVERY_FACTORS_VAL=zeros(size(LOAD_VAL,1),H);
for t=1:H
    for i=1:size(LOAD_VAL,1)
        for b=1:nbus
            if strcmp(LOAD_STRING(i,1),BUS_VAL(b,1))
                LOAD_DELIVERY_FACTORS_VAL(i,t)=BUS_DELIVERY_FACTORS_VAL(b,t);
            end
        end
    end
end

end