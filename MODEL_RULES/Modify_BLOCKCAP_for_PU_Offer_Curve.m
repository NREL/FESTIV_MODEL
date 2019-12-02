%This modifies the offer segments for units that use a offer curve based 

puidx=GENVALUE_VAL(:,pucost);
if sum(puidx) > 0
    BLOCK_CAP_VAL(find(puidx),:)=BLOCK_CAP_VAL(find(puidx),:).*repmat(GENVALUE_VAL(find(puidx),capacity),1,4);
end
