%
%Convert UC parameters to IRTC
%After Data Initialization
%

current_su_time=GENVALUE_VAL(:,su_time).*60;
current_su_time_in_IRTC_intervals = current_su_time./IRTC;
new_su_time_in_IRTC_intervals = ceil(current_su_time_in_IRTC_intervals);
new_su_time=new_su_time_in_IRTC_intervals.*IRTC;
GENVALUE_VAL(:,su_time)=new_su_time./60;

current_sd_time=GENVALUE_VAL(:,sd_time).*60;
current_sd_time_in_IRTC_intervals = current_sd_time./IRTC;
new_sd_time_in_IRTC_intervals = ceil(current_sd_time_in_IRTC_intervals);
new_sd_time=new_sd_time_in_IRTC_intervals.*IRTC;
GENVALUE_VAL(:,sd_time)=new_sd_time./60;

current_mr_time=GENVALUE_VAL(:,mr_time).*60;
current_mr_time_in_IRTC_intervals = current_mr_time./IRTC;
new_mr_time_in_IRTC_intervals = ceil(current_mr_time_in_IRTC_intervals);
new_mr_time=new_mr_time_in_IRTC_intervals.*IRTC;
GENVALUE_VAL(:,mr_time)=new_mr_time./60;

current_md_time=GENVALUE_VAL(:,md_time).*60;
current_md_time_in_IRTC_intervals = current_md_time./IRTC;
new_md_time_in_IRTC_intervals = ceil(current_md_time_in_IRTC_intervals);
new_md_time=new_md_time_in_IRTC_intervals.*IRTC;
GENVALUE_VAL(:,md_time)=new_md_time./60;

GENVALUE.val = GENVALUE_VAL;
DEFAULT_DATA.GENVALUE=GENVALUE;