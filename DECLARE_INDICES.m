% SYSTEM TAB INDICES

global slack_bus mva_pu voll inertia_load dfmax load_damping db_max frequency first_stage_startup;
if useHDF5 == 0
    [~,headers]=xlsread(inputPath,'SYSTEM','A1:A20');
else
    fullinputfilepath=evalin('caller','inputPath');
    [inputfilepath,inputfilename,inputfileextension]=fileparts(fullinputfilepath);
    fileName = [inputfilepath,filesep,inputfilename,'.h5'];
    x=h5read(fileName,'/Main Input File/SYSTEM');
    headers=x.Property;
end
slack_bus               = find(strcmp(headers,'SLACK_BUS'));
mva_pu                  = find(strcmp(headers,'MVA_PERUNIT'));
voll                    = find(strcmp(headers,'VOLL'));
try; inertia_load            = find(strcmp(headers,'INERTIALOAD'));catch;end;
try; dfmax                   = find(strcmp(headers,'DFMAX'));catch;end;
try; load_damping            = find(strcmp(headers,'LOAD_DAMPING'));catch;end;
try; db_max                  = find(strcmp(headers,'DBMAX'));catch;end;
try; frequency               = find(strcmp(headers,'FREQUENCY'));catch;end;
try; first_stage_startup     = find(strcmp(headers,'FIRST_STAGE_STARTUP'));catch;end;

% GEN TAB INDICES
global capacity noload_cost su_cost mr_time md_time ramp_rate min_gen gen_type su_time sd_time agc_qualified gov_beta gov_tg...
    max_starts initial_status initial_hour initial_MW forced_outage_rate mttr variable_start behavior_rate inertia droop gov_db gen_agc_mode q_max q_min pucost;
if useHDF5 == 0
    [~,headers]=xlsread(inputPath,'GEN','B1:AZ1');
else
    x=h5read(fileName,'/Main Input File/GEN');
    headers=fieldnames(x);
    headers=headers(2:end);
end
capacity                = find(strcmp(headers,'CAPACITY'));
noload_cost             = find(strcmp(headers,'NO_LOAD_COST'));
su_cost                 = find(strcmp(headers,'STARTUP_COST'));
mr_time                 = find(strcmp(headers,'MIN_RUN_TIME'));
md_time                 = find(strcmp(headers,'MIN_DOWN_TIME'));
ramp_rate               = find(strcmp(headers,'RAMP_RATE'));
min_gen                 = find(strcmp(headers,'MIN_GEN'));
gen_type                = find(strcmp(headers,'GEN_TYPE'));
su_time                 = find(strcmp(headers,'STARTUP_TIME'));
sd_time                 = find(strcmp(headers,'SHUTDOWN_TIME'));
agc_qualified           = find(strcmp(headers,'AGC_QUALIFIED'));
max_starts              = find(strcmp(headers,'MAX_STARTS'));
initial_status          = find(strcmp(headers,'INITIAL_STATUS'));
initial_hour            = find(strcmp(headers,'INITIAL_HOUR'));
initial_MW              = find(strcmp(headers,'INITIAL_MW'));
forced_outage_rate      = find(strcmp(headers,'FORCED_OUTAGE_RATE'));
mttr                    = find(strcmp(headers,'MTTR'));
variable_start          = find(strcmp(headers,'VARIABLE_STARTUP'));
behavior_rate           = find(strcmp(headers,'BEHAVIOR_RATE'));
inertia                 = find(strcmp(headers,'INERTIA'));
droop                   = find(strcmp(headers,'DROOP'));
gov_db                  = find(strcmp(headers,'GOV_DB'));
gov_beta                = find(strcmp(headers,'GOV_BETA'));
gov_tg                  = find(strcmp(headers,'GOV_TG'));
gen_agc_mode            = find(strcmp(headers,'GEN_AGC_MODE'));
q_max                   = find(strcmp(headers,'Q_MAX'));
q_min                   = find(strcmp(headers,'Q_MIN'));
pucost                  = find(strcmp(headers,'PERUNIT_COST'));

% STORAGE TAB INDICES
global max_pump min_pump min_pump_time pump_su_time pump_sd_time pump_ramp_rate initial_storage final_storage storage_max ...
    efficiency reservoir_value initial_pump_status initial_pump_mw initial_pump_hour variable_efficiency enforce_final_storage;
try
if useHDF5 == 0
    [~,headers]=xlsread(inputPath,'STORAGE','B1:AZ1');
else
    x=h5read(fileName,'/Main Input File/STORAGE');
    headers=fieldnames(x);
    headers=headers(2:end);
end
max_pump                = find(strcmp(headers,'MAX_PUMP'));
min_pump                = find(strcmp(headers,'MIN_PUMP'));
min_pump_time           = find(strcmp(headers,'MIN_PUMP_TIME'));
pump_su_time            = find(strcmp(headers,'PUMP_STARTUP_TIME'));
pump_sd_time            = find(strcmp(headers,'PUMP_SHUTDOWN_TIME'));
pump_ramp_rate          = find(strcmp(headers,'PUMP_RAMP_RATE'));
initial_storage         = find(strcmp(headers,'INITIAL_STORAGE'));
final_storage           = find(strcmp(headers,'FINAL_STORAGE'));
storage_max             = find(strcmp(headers,'STORAGE_MAX'));
efficiency              = find(strcmp(headers,'EFFICIENCY'));
reservoir_value         = find(strcmp(headers,'RESERVOIR_VALUE'));
initial_pump_status     = find(strcmp(headers,'INITIAL_PUMP_STATUS'));
initial_pump_mw         = find(strcmp(headers,'INITIAL_PUMP_MW'));
initial_pump_hour       = find(strcmp(headers,'INITIAL_PUMP_HOUR'));
variable_efficiency     = find(strcmp(headers,'VARIABLE_EFFICIENCY'));
enforce_final_storage   = find(strcmp(headers,'ENFORCE_FINAL_STORAGE'));
catch
end

% RESERVE TAB INDICES
global res_on res_time res_dir res_agc res_gov res_vg res_voir res_inertia res_inclusive;
try
if useHDF5 == 0
    [~,headers]=xlsread(inputPath,'RESERVEPARAM','B1:AZ1');
else
    x=h5read(fileName,'/Main Input File/RESERVEPARAM');
    headers=fieldnames(x);
    headers=headers(2:end);
end
res_on                  = find(strcmp(headers,'RESERVE_ON'));
res_time                = find(strcmp(headers,'RESERVE_TIME'));
res_dir                 = find(strcmp(headers,'RESERVE_DIR'));
res_agc                 = find(strcmp(headers,'RESERVE_AGC'));
res_gov                 = find(strcmp(headers,'RESERVE_GOV'));
res_inertia             = find(strcmp(headers,'RESERVE_INERTIA'));
res_inclusive           = find(strcmp(headers,'RESERVE_INCLUSIVE'));
res_vg                  = find(strcmp(headers,'RESERVE_VG'));
res_voir                = find(strcmp(headers,'VOIR'));
catch
end

% BRANCH TAB INDICES
global reactance line_rating ste_rating par_low par_hi ctgc_monitor branch_type resistance susceptance;
try
if useHDF5 == 0
    [~,headers]=xlsread(inputPath,'BRANCHDATA','B1:AZ1');
else
    x=h5read(fileName,'/Main Input File/BRANCHDATA');
    headers=fieldnames(x);
end
reactance               = find(strcmp(headers,'REACTANCE'));
resistance              = find(strcmp(headers,'RESISTANCE'));
line_rating             = find(strcmp(headers,'LINE_RATING'));
ste_rating              = find(strcmp(headers,'STE_RATING'));
par_low                 = find(strcmp(headers,'PHASE_SHIFTER_ANGLE_LOW'));
par_hi                  = find(strcmp(headers,'PHASE_SHIFTER_ANGLE_HIGH'));
ctgc_monitor            = find(strcmp(headers,'CTGC_MONITOR'));
branch_type             = find(strcmp(headers,'BRANCH_TYPE'));
susceptance             = find(strcmp(headers,'SUSCEPTANCE'));
indcaltemp=[reactance,resistance,line_rating,ste_rating,par_low,par_hi,ctgc_monitor,branch_type,susceptance];
firstcol=min(indcaltemp);
offset=1-firstcol;
reactance = reactance + offset;
resistance = resistance + offset;
line_rating = line_rating + offset;
ste_rating = ste_rating + offset;
par_low = par_low + offset;
par_hi = par_hi + offset;
ctgc_monitor = ctgc_monitor + offset;
branch_type = branch_type + offset;
susceptance = susceptance + offset;
catch
end

% ACE INDICES
global ACE_time_index raw_ACE_index integrated_ACE_index CPS2_ACE_index SACE_index AACEE_index;
ACE_time_index = 1;%time
raw_ACE_index = 2;%the raw instantaneous ACE
integrated_ACE_index = 3;%total integrated ACE in MWh (like AACEE but not absolute values, i.e. inadvertent interchange)
CPS2_ACE_index = 4; %The ACE that can trigger the CPS2 violations. Based on the CPS2interval (compliance interval)
SACE_index = 5;%Smoothed ACE SACE based on proportional and integral terms.
AACEE_index = 6; %The current Absolute ACE in Energy (AACEE).

%Types
global steam_gen_type_index CT_gen_type_index combined_cycle_gen_type_index hydro_gen_type_index nuclear_gen_type_index pumped_storage_gen_type_index wind_gen_type_index ESR_gen_type_index LESR_gen_type_index PV_gen_type_index ...
    CSP_gen_type_index demandresponse_gen_type_index virtual_gen_type_index interface_gen_type_index outage_gen_type_index variable_dispatch_gen_type_index;

steam_gen_type_index = 1; 
CT_gen_type_index = 2;
combined_cycle_gen_type_index = 3;
hydro_gen_type_index = 4;
nuclear_gen_type_index = 5;
pumped_storage_gen_type_index = 6;
wind_gen_type_index = 7;
ESR_gen_type_index = 8;
LESR_gen_type_index = 9;
PV_gen_type_index = 10;
CSP_gen_type_index  = 11;
demandresponse_gen_type_index = 12;
virtual_gen_type_index = 13;
interface_gen_type_index = 14;
outage_gen_type_index = 15;
variable_dispatch_gen_type_index = 16;

global transmission_line_branch_type_index fixed_par_branch_type_index adj_par_branch_type_index HVDC_branch_type_index;

transmission_line_branch_type_index = 1; 
fixed_par_branch_type_index = 2;
adj_par_branch_type_index = 3;
HVDC_branch_type_index = 4;