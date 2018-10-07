pshbid_gdx.name = 'PSHBID';
pshbid_gdx.form = 'full';
pshbid_gdx.uels = GEN.uels;
PSHBIDCOST=rgdx('TEMP/TOTAL_DASCUCOUTPUT',pshbid_gdx);
PSHBIDCOST_VAL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,:) = ones(HDAC,1)*PSHBIDCOST.val';
