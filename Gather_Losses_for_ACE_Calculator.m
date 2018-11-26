% transmission losses = flow^2 * R
load_injection=-1*fullLoadDist*ACTUAL_LOAD_FULL(AGC_interval_index,2);
if ~exist('losses_temp','var')
    geninjection_temp=zeros(nbus,ngen);temp2=sortrows(GENBUS_CALCS_VAL,1);
    for i=1:ngen
        geninjection_temp(temp2(find(temp2(:,1)==i),2),i)=temp2(find(temp2(:,1)==i),3);
    end
end
bus_injection=geninjection_temp*ACTUAL_GENERATION(AGC_interval_index,2:end)' + load_injection;
ACTUAL_LF = PTDF_VAL*bus_injection;
losses=sum(ACTUAL_LF(:,1).*ACTUAL_LF(:,1).*BRANCHDATA_VAL(:,resistance)/SYSTEMVALUE_VAL(mva_pu,1));
storelosses(AGC_interval_index,1)=losses;
