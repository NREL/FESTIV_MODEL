%
%Post RTSCED
%

if strcmp(MODEL,'RTSCED')
    DEVIATION_HELP_rgdx.name='DEVIATION_HELP';
    DEVIATION_HELP_rgdx.form='full';
    DEVIATION_HELP_rgdx.uels={GEN.uels};
    DEVIATION_HELP=rgdx(input1,DEVIATION_HELP_rgdx);
    RTDPRODCOST.val(6,1) = RTDPRODCOST.val(6,1) - (sum(DEVIATION_HELP.val)*0.05*SYSTEMVALUE_VAL(mva_pu)*ILMP/60);
    RTDPRODCOST.val(7,1) = RTDPRODCOST.val(7,1) - (sum(DEVIATION_HELP.val)*0.05*SYSTEMVALUE_VAL(mva_pu)*ILMP/60);
end

