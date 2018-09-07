function FESTIV_GUI
% This function creates the FESTIV user interface.

%% Create main figure 
mainFigure=figure('Visible','off','name','FESTIV','NumberTitle','off','units','pixels','position',[50 50 730 670],'menubar','none','color',[.9412 .9412 .9412]);
movegui(mainFigure,'center');

% create header
uicontrol('parent',mainFigure,'style','text','fontname','courier','string','Flexible Energy Scheduling Tool for Integrating Variable generation','units','normalized','position',[.02 .93 .96 .05],'fontunits','normalized','fontsize',0.45,'BackgroundColor',get(mainFigure,'color'));
uicontrol('parent',mainFigure,'style','text','fontname','courier','string','FESTIV','units','normalized','position',[.02 .83 .96 .12],'fontunits','normalized','fontsize',0.99,'BackgroundColor',get(mainFigure,'color'));

% create input file request
uicontrol('parent',mainFigure,'style','text','string','Input File:','units','normalized','position',[.02 .73 .1 .07],'fontunits','normalized','fontsize',0.3);
inputFileEditBox=uicontrol('parent',mainFigure,'style','edit','units','normalized','position',[.12 .76 .64 .05],'fontunits','normalized','fontsize',0.4,'backgroundcolor','white','horizontalalignment','left');
uicontrol('parent',mainFigure,'style','pushbutton','units','normalized','position',[.77 .76 .13 .05],'string','Browse','fontunits','normalized','fontsize',0.5,'callback',{@browseforfile});
autosavecheck_in=uicontrol('parent',mainFigure,'style','checkbox','unit','normalized','position',[.91 .735 .1 .1],'string','<html>auto<br>save</html>','callback',{@autosavecallback});
try
    inputPath = char(inifile(['Input',filesep,'FESTIV.inp'],'read',{'','','inputPath',''}));
    [~, name, ext] = fileparts(inputPath);
    displayname=strcat(name,ext);
    set(inputFileEditBox,'string',displayname);
    if strcmp(ext,'.h5')
        assignin('base','useHDF5',1);
    else
        assignin('base','useHDF5',0);
    end
catch
end

% create DASCUC information request
uipanel('parent',mainFigure,'Title','DASCUC','units','normalized','Position', [.03 .24 .30 .5],'fontunits','normalized','fontsize',0.040,'BackgroundColor',get(mainFigure,'color'));
uicontrol('style','text','string','t_DAC:','units','normalized','position',[.04 .65 .08 .05],'fontunits','normalized','fontsize',0.35,'horizontalalignment','left');
uicontrol('style','text','string','H_DAC:','units','normalized','position',[.04 .59 .08 .05],'fontunits','normalized','fontsize',0.35,'horizontalalignment','left');
uicontrol('style','text','string','I_DAC:','units','normalized','position',[.18 .65 .08 .05],'fontunits','normalized','fontsize',0.35,'horizontalalignment','left');
uicontrol('style','text','string','P_DAC:','units','normalized','position',[.18 .59 .08 .05],'fontunits','normalized','fontsize',0.35,'horizontalalignment','left');
uicontrol('style','text','string','G_DAC:','units','normalized','position',[.04 .53 .08 .05],'fontunits','normalized','fontsize',0.35,'horizontalalignment','left');
uicontrol('style','text','string','H_Type:','units','normalized','position',[.17 .538 .12 .043],'fontunits','normalized','fontsize',0.4,'horizontalalignment','left');
tDAC_in_edit=uicontrol('style','edit','string','24','units','normalized','position',[.115 .673 .05 .03],'backgroundcolor','white');
HDAC_in_edit=uicontrol('style','edit','string','24','units','normalized','position',[.115 .613 .05 .03],'backgroundcolor','white');
IDAC_in_edit=uicontrol('style','edit','string','1','units','normalized','position',[.25 .673 .05 .03],'backgroundcolor','white');
PDAC_in_edit=uicontrol('style','edit','string','1','units','normalized','position',[.25 .613 .05 .03],'backgroundcolor','white');
GDAC_in_edit=uicontrol('style','edit','string','12','units','normalized','position',[.115 .553 .05 .03],'backgroundcolor','white');
DAHORIZONTYPE_in_edit=uicontrol('style','popupmenu','units','normalized','position',[.24 .555 .08 .03],'string','Type 1|Type 2|Type 3|Type 4','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Load Forecast','units','normalized','position',[.11 .5 .12 .04],'fontunits','normalized','fontsize',0.45);
DASCUCLF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.06 .46 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','VG Forecast','units','normalized','position',[.11 .43 .12 .04],'fontunits','normalized','fontsize',0.45);
DASCUCVGF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.06 .39 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Reserve Levels','units','normalized','position',[.1 .36 .14 .04],'fontunits','normalized','fontsize',0.45);
DAC_RESERVE_FORECAST_MODE_in_GUI=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.06 .32 .22 .05],'string','1 - No reserve|2 - From Data File','backgroundcolor','white','value',1);
uicontrol('parent',mainFigure,'units','normalized','position',[.1 .27 .15 .05],'string','DASCUC Rules','fontunits','normalized','fontsize',0.4,'callback',{@dascuc_model_rules});

% create RTSCUC information request
uipanel('parent',mainFigure,'Title','RTSCUC','units','normalized','Position', [.35 .24 .30 .5],'fontunits','normalized','fontsize',0.040,'BackgroundColor',get(mainFigure,'color'));
uicontrol('parent',mainFigure,'style','text','string','t_RTC:','units','normalized','position',[.37 .65 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.34);
uicontrol('parent',mainFigure,'style','text','string','H_RTC:','units','normalized','position',[.37 .59 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
uicontrol('parent',mainFigure,'style','text','string','I_RTC:','units','normalized','position',[.51 .65 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.34);
uicontrol('parent',mainFigure,'style','text','string','P_RTC:','units','normalized','position',[.51 .59 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
uicontrol('parent',mainFigure,'style','text','string','t_RTCSTART:','units','normalized','position',[.41 .53 .105 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
tRTC_in_edit=uicontrol('parent',mainFigure,'style','edit','string','15','units','normalized','position',[.445 .673 .05 .03],'backgroundcolor','white');
HRTC_in_edit=uicontrol('parent',mainFigure,'style','edit','string','3','units','normalized','position',[.445 .613 .05 .03],'backgroundcolor','white');
IRTC_in_edit=uicontrol('parent',mainFigure,'style','edit','string','15','units','normalized','position',[.58 .673 .05 .03],'backgroundcolor','white');
PRTC_in_edit=uicontrol('parent',mainFigure,'style','edit','string','15','units','normalized','position',[.58 .613 .05 .03],'backgroundcolor','white');
tRTCSTART_in_edit=uicontrol('parent',mainFigure,'style','edit','string','1','units','normalized','position',[.525 .553 .055 .03],'backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Load Forecast','units','normalized','position',[.44 .5 .12 .04],'fontunits','normalized','fontsize',0.45);
RTSCUCLF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.39 .46 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','VG Forecast','units','normalized','position',[.44 .43 .12 .04],'fontunits','normalized','fontsize',0.45);
RTSCUCVGF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.39 .39 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Reserve Levels','units','normalized','position',[.43 .36 .14 .04],'fontunits','normalized','fontsize',0.45);
RTC_RESERVE_FORECAST_MODE_in_GUI=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.39 .32 .22 .05],'string','1 - From Day Ahead|2 - From Data File','backgroundcolor','white','value',1);
uicontrol('parent',mainFigure,'units','normalized','position',[.43 .27 .15 .05],'string','RTSCUC Rules','fontunits','normalized','fontsize',0.4,'callback',{@rtscuc_model_rules});

% create RTSCED information request
uipanel('parent',mainFigure,'Title','RTSCED','units','normalized','Position', [.67 .24 .30 .5],'fontunits','normalized','fontsize',0.040,'BackgroundColor',get(mainFigure,'color'));
uicontrol('parent',mainFigure,'style','text','string','t_RTD:','units','normalized','position',[.69 .65 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.34);
uicontrol('parent',mainFigure,'style','text','string','H_RTD:','units','normalized','position',[.69 .59 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
uicontrol('parent',mainFigure,'style','text','string','I_RTD:','units','normalized','position',[.83 .65 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.34);
uicontrol('parent',mainFigure,'style','text','string','P_RTD:','units','normalized','position',[.83 .59 .08 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
uicontrol('parent',mainFigure,'style','text','string','I_RTD_ADV:','units','normalized','position',[.74 .53 .105 .05],'horizontalalignment','left','fontunits','normalized','fontsize',0.35);
tRTD_in_edit=uicontrol('parent',mainFigure,'style','edit','string','5','units','normalized','position',[.76 .673 .05 .03],'backgroundcolor','white');
HRTD_in_edit=uicontrol('parent',mainFigure,'style','edit','string','2','units','normalized','position',[.76 .613 .05 .03],'backgroundcolor','white');
IRTD_in_edit=uicontrol('parent',mainFigure,'style','edit','string','5','units','normalized','position',[.9 .673 .05 .03],'backgroundcolor','white');
PRTD_in_edit=uicontrol('parent',mainFigure,'style','edit','string','5','units','normalized','position',[.9 .613 .05 .03],'backgroundcolor','white');
IRTDADV_in_edit=uicontrol('parent',mainFigure,'style','edit','string','15','units','normalized','position',[.845 .553 .055 .03],'backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Load Forecast','units','normalized','position',[.76 .5 .12 .04],'fontunits','normalized','fontsize',0.45);
RTSCEDLF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.71 .46 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','VG Forecast','units','normalized','position',[.76 .43 .12 .04],'fontunits','normalized','fontsize',0.45);
RTSCEDVGF=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.71 .39 .22 .05],'string','1 - From Data File|2 - Perfect Forecast|3 - Persistence Forecast|4 - Predefined with NDE','backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string','Reserve Levels','units','normalized','position',[.75 .36 .14 .04],'fontunits','normalized','fontsize',0.45);
RTD_RESERVE_FORECAST_MODE_in_GUI=uicontrol('parent',mainFigure','style','popupmenu','units','normalized','position',[.71 .32 .22 .05],'string','1 - From Day Ahead|2 - From Data File','backgroundcolor','white','value',1);
uicontrol('parent',mainFigure,'units','normalized','position',[.75 .27 .15 .05],'string','RTSCED Rules','fontunits','normalized','fontsize',0.4,'callback',{@rtsced_model_rules});

% create network check information request
network_button_group=uibuttongroup('parent',mainFigure,'title','Network Check','units','normalized','position',[.67 .135 .145 .09],'fontunits','normalized','fontsize',0.15);
radiobutton1=uicontrol('parent',network_button_group,'style','radiobutton','units','normalized','position',[.07 .35 .4 .45],'string','Yes','fontunits','normalized','fontsize',0.55);
radiobutton2=uicontrol('parent',network_button_group,'style','radiobutton','units','normalized','position',[.57 .35 .4 .45],'string','No','fontunits','normalized','fontsize',0.55);

% create contingency check information request
ctgc_button_group=uibuttongroup('parent',mainFigure,'title','CTGC Check','units','normalized','position',[.825 .135 .145 .09],'fontunits','normalized','fontsize',0.15);
radiobutton4=uicontrol('parent',ctgc_button_group,'style','radiobutton','units','normalized','position',[.07 .35 .4 .45],'string','Yes','fontunits','normalized','fontsize',0.55);
radiobutton3=uicontrol('parent',ctgc_button_group,'style','radiobutton','units','normalized','position',[.57 .35 .4 .45],'string','No','fontunits','normalized','fontsize',0.55);

% create AGC information request
uipanel('parent',mainFigure,'Title','AGC','units','normalized','Position', [.03 .13 .3 .1],'fontunits','normalized','fontsize',0.15,'BackgroundColor',get(mainFigure,'color'));
uicontrol('parent',mainFigure,'units','normalized','position',[.05 .15 .12 .05],'string','AGC Param','fontunits','normalized','fontsize',0.4,'callback',{@agc_input});
uicontrol('parent',mainFigure,'units','normalized','position',[.19 .15 .12 .05],'string','AGC Rules','fontunits','normalized','fontsize',0.4,'callback',{@agc_model_rules});

% create simulation time request
uipanel('parent',mainFigure,'Title','Simulation Time (D:H:M:S)','units','normalized','Position', [.35 .13 .3 .1],'fontunits','normalized','fontsize',0.15,'BackgroundColor',get(mainFigure,'color'));
days_to_simulate_edit=uicontrol('parent',mainFigure,'style','edit','string','1','units','normalized','position',[.37 .15 .05 .05],'backgroundcolor','white');
hours_to_simulate_edit=uicontrol('parent',mainFigure,'style','edit','string','0','units','normalized','position',[.44 .15 .05 .05],'backgroundcolor','white');
minutes_to_simulate_edit=uicontrol('parent',mainFigure,'style','edit','string','0','units','normalized','position',[.51 .15 .05 .05],'backgroundcolor','white');
seconds_to_simulate_edit=uicontrol('parent',mainFigure,'style','edit','string','0','units','normalized','position',[.58 .15 .05 .05],'backgroundcolor','white');
uicontrol('parent',mainFigure,'style','text','string',':','units','normalized','position',[.425 .142 .01 .05],'fontunits','normalized','fontsize',0.5);
uicontrol('parent',mainFigure,'style','text','string',':','units','normalized','position',[.495 .142 .01 .05],'fontunits','normalized','fontsize',0.5);
uicontrol('parent',mainFigure,'style','text','string',':','units','normalized','position',[.565 .142 .01 .05],'fontunits','normalized','fontsize',0.5);

% create extra options input request interfaces
options=uipanel('parent',mainFigure,'Title','Extra Options','units','normalized','Position', [.03 .03 .725 .09],'fontunits','normalized','fontsize',0.2,'BackgroundColor',get(mainFigure,'color'));
uicontrol('parent',options,'units','normalized','position',[.01 .15 .11 .8],'string','<html><center>RPU</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@rpu_callback});
uicontrol('parent',options,'units','normalized','position',[.135 .15 .11 .8],'string','<html><center>Multiple<br>Runs</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@MultipleRuns_callback});
uicontrol('parent',options,'units','normalized','position',[.260 .15 .11 .8],'string','<html><center>CTGC<br>Options</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@contingencies_callback});
uicontrol('parent',options,'units','normalized','position',[.385 .15 .11 .8],'string','<html><center>Debug</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@debugging_callback});
uicontrol('parent',options,'units','normalized','position',[.51 .15 .11 .8],'string','<html><center>Other<br>Rules</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@other_rules_callback});
uicontrol('parent',options,'units','normalized','position',[.635 .15 .11 .8],'string','<html><center>Save<br>Rules</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@save_rules_callback});
uicontrol('parent',options,'units','normalized','position',[.76 .15 .11 .8],'string','<html><center>Load<br>Rules</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@load_rules_callback});
uicontrol('parent',options,'units','normalized','position',[.885 .15 .11 .8],'string','<html><center>GAMS</center></html>','fontunits','normalized','fontsize',0.35,'callback',{@build_gams_models_callback});
uicontrol('Parent',mainFigure,'Style','pushbutton','String','<html><center>Cancel</center></html>','units','normalized','Position', [0.775 0.03 0.1 0.08],'fontunits','normalized','fontsize',0.35,'Callback', {@cancel_callback});
uicontrol('Parent',mainFigure,'Style','pushbutton','String','<html><center>Go!</center></html>','units','normalized','Position', [.885 .03 0.1 .08],'fontunits','normalized','fontsize',0.40,'Callback',{@runFESTIV}); 

% make main figure visible
set(mainFigure,'visible','on');



%% Initialize variables that come up in other figures
K1_in_edit=[];
try 
    K1_in=evalin('base','K1_in');
catch
    assignin('base','K1_in',1);
    K1_in=evalin('base','K1_in');
end
K2_in_edit=[];
try
    K2_in=evalin('base','K2_in');
catch
    assignin('base','K2_in',2);
    K2_in=evalin('base','K2_in');
end
Type3_integral_in_edit=[];
try
    Type3_integral_in=evalin('base','Type3_integral_in');
catch
    assignin('base','Type3_integral_in',180);
    Type3_integral_in=evalin('base','Type3_integral_in');
end
CPS2_interval_in_edit=[];
try
    CPS2_interval_in=evalin('base','CPS2_interval_in'); 
catch
    assignin('base','CPS2_interval_in',10);
    CPS2_interval_in=evalin('base','CPS2_interval_in'); 
end
L10_in_edit=[];
try
    L10_in=evalin('base','L10_in');
catch
    assignin('base','L10_in',50);
    L10_in=evalin('base','L10_in');
end
agc_deadband_in_edit=[];
try
    agc_deadband_in=evalin('base','agc_deadband_in');
catch
    assignin('base','agc_deadband_in',5);
    agc_deadband_in=evalin('base','agc_deadband_in');
end
agcmodes=[];
try
    agcmode=evalin('base','agcmode');
catch
    assignin('base','agcmode',3);
    agcmode=evalin('base','agcmode');
end
multiplerunscheck=[];
outputfilenames=[];
simulationQueue={};
multiplerunscheckvalue=0;
multipleRunsOutputText=[];
addruns=[];
numberoffiles=1;
multipleRunsInputText=[];
inputfilenamesformultiple=[];
browseformultiple=[];
assignin('base','MRcheck',0);
radiobutton5=[];
HRPU_in_edit=[];
try
    HRPU_in=evalin('base','HRPU_in');
catch
    assignin('base','HRPU_in',6);
    HRPU_in=evalin('base','HRPU_in');
end
IRPU_in_edit=[];
try
    IRPU_in=evalin('base','IRPU_in');
catch
    assignin('base','IRPU_in',10);
    IRPU_in=evalin('base','IRPU_in');
end
PRPU_in_edit=[];
try
    PRPU_in=evalin('base','PRPU_in');
catch
    assignin('base','PRPU_in',1);
    PRPU_in=evalin('base','PRPU_in');
end
ACE_RPU_THRESHOLD_MW_in_edit=[];
try
    ACE_RPU_THRESHOLD_MW_in=evalin('base','ACE_RPU_THRESHOLD_MW_in');
catch
    assignin('base','ACE_RPU_THRESHOLD_MW_in',1000);
    ACE_RPU_THRESHOLD_MW_in=evalin('base','ACE_RPU_THRESHOLD_MW_in');
end
ACE_RPU_THRESHOLD_T_in_edit=[];
try
    ACE_RPU_THRESHOLD_T_in=evalin('base','ACE_RPU_THRESHOLD_T_in');
catch
    assignin('base','ACE_RPU_THRESHOLD_T_in',2);
    ACE_RPU_THRESHOLD_T_in=evalin('base','ACE_RPU_THRESHOLD_T_in');
end
restrict_multiple_rpu_time_in_edit=[];
try
    restrict_multiple_rpu_time_in=evalin('base','restrict_multiple_rpu_time_in');
catch
    assignin('base','restrict_multiple_rpu_time_in',10);
    restrict_multiple_rpu_time_in=evalin('base','restrict_multiple_rpu_time_in');
end
assignin('base','ALLOW_RPU_in','NO');
ALLOW_RPU_in=evalin('base','ALLOW_RPU_in');   
ctgc_gen_in_edit=[];
ctgc_D_in_edit=[];
ctgc_H_in_edit=[];
ctgc_M_in_edit=[];
ctgc_S_in_edit=[];
outageQueue=[];
outagedgenindicies=[];
ngen=1;
radiobutton7=[];
radiobutton8=[];
radiobutton9=[];
Contingency_input_check_in=1;
assignin('base','gen_outage_time_in',0);
gen_outage_time_in=evalin('base','gen_outage_time_in');   
assignin('base','SIMULATE_CONTINGENCIES_in','NO');
SIMULATE_CONTINGENCIES_in=evalin('base','SIMULATE_CONTINGENCIES_in');   
evalin('base','ctgctabledata=[];');
radiobutton10=[];
radiobutton12=[];
radiobutton13=[];
radiobutton15=[];
timefordebugstop_in_edit=[];
assignin('base','USE_INTEGER_in','YES');
USE_INTEGER_in=evalin('base','USE_INTEGER_in');
try 
    suppress_plots_in=evalin('base','suppress_plots_in');
catch
    assignin('base','suppress_plots_in','NO');
    suppress_plots_in=evalin('base','suppress_plots_in');
end
assignin('base','debugcheck_in',0);
debugcheck_in=evalin('base','debugcheck_in');
assignin('base','timefordebugstop_in',999);
timefordebugstop_in=evalin('base','timefordebugstop_in');
assignin('base','Contingency_input_check_in',0);
Contingency_input_check_in=evalin('base','Contingency_input_check_in');
modelinputFileEditBox=[];
modelinputFile=[];
dascucpre_modelQueue=[];
dascucpost_modelQueue=[];
rtscucpre_modelQueue=[];
rtscucpost_modelQueue=[];
rtscedpre_modelQueue=[];
rtscedpost_modelQueue=[];
agcpre_modelQueue=[];
agcpost_modelQueue=[];
dascucmodel_pre_list=[];
dascucmodel_post_list=[];
rtscucmodel_pre_list=[];
rtscucmodel_post_list=[];
rtscedmodel_pre_list=[];
rtscedmodel_post_list=[];
agcmodel_pre_list=[];
agcmodel_post_list=[];
rpupre_modelQueue=[];
rpupost_modelQueue=[];
rpumodel_pre_list=[];
rpumodel_post_list=[];
otherpre_modelQueue=[];
otherpost_modelQueue=[];
othermodel_pre_list=[];
othermodel_post_list=[];
try
    DASCUC_RULES_PRE_in=evalin('base','DASCUC_RULES_PRE_in');
catch
    assignin('base','DASCUC_RULES_PRE_in',[]);
    DASCUC_RULES_PRE_in=evalin('base','DASCUC_RULES_PRE_in');
end
try
    DASCUC_RULES_POST_in=evalin('base','DASCUC_RULES_POST_in');
catch
    assignin('base','DASCUC_RULES_POST_in',[]);
    DASCUC_RULES_POST_in=evalin('base','DASCUC_RULES_POST_in');
end
try
    RTSCUC_RULES_PRE_in=evalin('base','RTSCUC_RULES_PRE_in');
catch
    assignin('base','RTSCUC_RULES_PRE_in',[]);
    RTSCUC_RULES_PRE_in=evalin('base','RTSCUC_RULES_PRE_in');
end
try
    RTSCUC_RULES_POST_in=evalin('base','RTSCUC_RULES_POST_in');
catch
    assignin('base','RTSCUC_RULES_POST_in',[]);
    RTSCUC_RULES_POST_in=evalin('base','RTSCUC_RULES_POST_in');
end
try
    RTSCED_RULES_PRE_in=evalin('base','RTSCED_RULES_PRE_in');
catch
    assignin('base','RTSCED_RULES_PRE_in',[]);
    RTSCED_RULES_PRE_in=evalin('base','RTSCED_RULES_PRE_in');
end
try
    RTSCED_RULES_POST_in=evalin('base','RTSCED_RULES_POST_in');
catch
    assignin('base','RTSCED_RULES_POST_in',[]);
    RTSCED_RULES_POST_in=evalin('base','RTSCED_RULES_POST_in');
end
try
    AGC_RULES_PRE_in=evalin('base','AGC_RULES_PRE_in');
catch
    assignin('base','AGC_RULES_PRE_in',[]);
    AGC_RULES_PRE_in=evalin('base','AGC_RULES_PRE_in');
end
try
    AGC_RULES_POST_in=evalin('base','AGC_RULES_POST_in');
catch
    assignin('base','AGC_RULES_POST_in',[]);
    AGC_RULES_POST_in=evalin('base','AGC_RULES_POST_in');
end
try
    RPU_RULES_PRE_in=evalin('base','RPU_RULES_PRE_in');
catch
    assignin('base','RPU_RULES_PRE_in',[]);
    RPU_RULES_PRE_in=evalin('base','RPU_RULES_PRE_in');
end
try
    RPU_RULES_POST_in=evalin('base','RPU_RULES_POST_in');
catch
    assignin('base','RPU_RULES_POST_in',[]);
    RPU_RULES_POST_in=evalin('base','RPU_RULES_POST_in');
end
try
    DATA_INITIALIZE_PRE_in=evalin('base','DATA_INITIALIZE_PRE_in');
catch
    assignin('base','DATA_INITIALIZE_PRE_in',[]);
    DATA_INITIALIZE_PRE_in=evalin('base','DATA_INITIALIZE_PRE_in');
end
try
    DATA_INITIALIZE_POST_in=evalin('base','DATA_INITIALIZE_POST_in');
catch
    assignin('base','DATA_INITIALIZE_POST_in',[]);
    DATA_INITIALIZE_POST_in=evalin('base','DATA_INITIALIZE_POST_in');
end
try
    FORECASTING_PRE_in=evalin('base','FORECASTING_PRE_in');
catch
    assignin('base','FORECASTING_PRE_in',[]);
    FORECASTING_PRE_in=evalin('base','FORECASTING_PRE_in');
end
try
    FORECASTING_POST_in=evalin('base','FORECASTING_POST_in');
catch
    assignin('base','FORECASTING_POST_in',[]);
    FORECASTING_POST_in=evalin('base','FORECASTING_POST_in');
end
try
    POST_PROCESSING_PRE_in=evalin('base','POST_PROCESSING_PRE_in');
catch
    assignin('base','POST_PROCESSING_PRE_in',[]);
    POST_PROCESSING_PRE_in=evalin('base','POST_PROCESSING_PRE_in');
end
try
    POST_PROCESSING_POST_in=evalin('base','POST_PROCESSING_POST_in');
catch
    assignin('base','POST_PROCESSING_POST_in',[]);
    POST_PROCESSING_POST_in=evalin('base','POST_PROCESSING_POST_in');
end
try
    RT_LOOP_PRE_in=evalin('base','RT_LOOP_PRE_in');
catch
    assignin('base','RT_LOOP_PRE_in',[]);
    RT_LOOP_PRE_in=evalin('base','RT_LOOP_PRE_in');
end
try
    RT_LOOP_POST_in=evalin('base','RT_LOOP_POST_in');
catch
    assignin('base','RT_LOOP_POST_in',[]);
    RT_LOOP_POST_in=evalin('base','RT_LOOP_POST_in');
end
try
    ACE_PRE_in=evalin('base','ACE_PRE_in');
catch
    assignin('base','ACE_PRE_in',[]);
    ACE_PRE_in=evalin('base','ACE_PRE_in');
end
try
    ACE_POST_in=evalin('base','ACE_POST_in');
catch
    assignin('base','ACE_POST_in',[]);
    ACE_POST_in=evalin('base','ACE_POST_in');
end
try
    FORCED_OUTAGE_PRE_in=evalin('base','FORCED_OUTAGE_PRE_in');
catch
    assignin('base','FORCED_OUTAGE_PRE_in',[]);
    FORCED_OUTAGE_PRE_in=evalin('base','FORCED_OUTAGE_PRE_in');
end
try
    FORCED_OUTAGE_POST_in=evalin('base','FORCED_OUTAGE_POST_in');
catch
    assignin('base','FORCED_OUTAGE_POST_in',[]);
    FORCED_OUTAGE_POST_in=evalin('base','FORCED_OUTAGE_POST_in');
end
try
    SHIFT_FACTOR_PRE_in=evalin('base','SHIFT_FACTOR_PRE_in');
catch
    assignin('base','SHIFT_FACTOR_PRE_in',[]);
    SHIFT_FACTOR_PRE_in=evalin('base','SHIFT_FACTOR_PRE_in');
end
try
    SHIFT_FACTOR_POST_in=evalin('base','SHIFT_FACTOR_POST_in');
catch
    assignin('base','SHIFT_FACTOR_POST_in',[]);
    SHIFT_FACTOR_POST_in=evalin('base','SHIFT_FACTOR_POST_in');
end
try
    ACTUAL_OUTPUT_PRE_in=evalin('base','ACTUAL_OUTPUT_PRE_in');
catch
    assignin('base','ACTUAL_OUTPUT_PRE_in',[]);
    ACTUAL_OUTPUT_PRE_in=evalin('base','ACTUAL_OUTPUT_PRE_in');
end
try
    ACTUAL_OUTPUT_POST_in=evalin('base','ACTUAL_OUTPUT_POST_in');
catch
    assignin('base','ACTUAL_OUTPUT_POST_in',[]);
    ACTUAL_OUTPUT_POST_in=evalin('base','ACTUAL_OUTPUT_POST_in');
end
try
    RELIABILITY_PRE_in=evalin('base','RELIABILITY_PRE_in');
catch
    assignin('base','RELIABILITY_PRE_in',[]);
    RELIABILITY_PRE_in=evalin('base','RELIABILITY_PRE_in');
end
try
    RELIABILITY_POST_in=evalin('base','RELIABILITY_POST_in');
catch
    assignin('base','RELIABILITY_POST_in',[]);
    RELIABILITY_POST_in=evalin('base','RELIABILITY_POST_in');
end
try
    COST_PRE_in=evalin('base','COST_PRE_in');
catch
    assignin('base','COST_PRE_in',[]);
    COST_PRE_in=evalin('base','COST_PRE_in');
end
try
    COST_POST_in=evalin('base','COST_POST_in');
catch
    assignin('base','COST_POST_in',[]);
    COST_POST_in=evalin('base','COST_POST_in');
end
try
    SAVING_PRE_in=evalin('base','SAVING_PRE_in');
catch
    assignin('base','SAVING_PRE_in',[]);
    SAVING_PRE_in=evalin('base','SAVING_PRE_in');
end
try
    SAVING_POST_in=evalin('base','SAVING_POST_in');
catch
    assignin('base','SAVING_POST_in',[]);
    SAVING_POST_in=evalin('base','SAVING_POST_in');
end
autoSaveName_edit=[];
dac_modelinputFolderEditBox=[];
dac_modelinputLocationListBox=[];
dac_list_of_gams_rules=[];
dac_list_of_selected_gams_rules=[];
gamsFilesPaths_DAC=[];assignin('base','gamsFilesPaths_DAC',gamsFilesPaths_DAC);
gamsFilesNames_DAC=[];assignin('base','gamsFilesNames_DAC',gamsFilesNames_DAC);
rtc_modelinputFolderEditBox=[];
rtc_modelinputLocationListBox=[];
rtc_list_of_gams_rules=[];
rtc_list_of_selected_gams_rules=[];
gamsFilesPaths_RTC=[];assignin('base','gamsFilesPaths_RTC',gamsFilesPaths_RTC);
gamsFilesNames_RTC=[];assignin('base','gamsFilesNames_RTC',gamsFilesNames_RTC);
rtd_modelinputFolderEditBox=[];
rtd_modelinputLocationListBox=[];
rtd_list_of_gams_rules=[];
rtd_list_of_selected_gams_rules=[];
gamsFilesPaths_RTD=[];assignin('base','gamsFilesPaths_RTD',gamsFilesPaths_RTD);
gamsFilesNames_RTD=[];assignin('base','gamsFilesNames_RTD',gamsFilesNames_RTD);

%% Set default values
set(DASCUCLF,'value',2);
set(RTSCUCLF,'value',2);
set(RTSCEDLF,'value',2);
set(DASCUCVGF,'value',2);
set(RTSCUCVGF,'value',3);
set(RTSCEDVGF,'value',3);
set(radiobutton2,'value',1);
set(radiobutton3,'value',1);
set(DAC_RESERVE_FORECAST_MODE_in_GUI,'value',1);
set(RTC_RESERVE_FORECAST_MODE_in_GUI,'value',1);
set(RTD_RESERVE_FORECAST_MODE_in_GUI,'value',1);
try 
    a=evalin('base','HDAC_in');
    set(HDAC_in_edit,'string',num2str(a));
catch
end
try
    a=evalin('base','IDAC_in');
    set(IDAC_in_edit,'string',num2str(a))
catch
end
try 
    a=evalin('base','tDAC_in');
    set(tDAC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','GDAC_in');
    set(GDAC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','PDAC_in');
    set(PDAC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','DAHORIZONTYPE_in');
    set(DAHORIZONTYPE_in_edit,'value',a);
catch
end
try 
    a=evalin('base','HRTC_in');
    set(HRTC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','IRTC_in');
    set(IRTC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','tRTC_in');
    set(tRTC_in_edit,'string',num2str(a));
catch
end
try a=evalin('base','HRTD_in');
    set(HRTD_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','IRTD_in');
    set(IRTD_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','tRTD_in');
    set(tRTD_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','daystosimulate');
    set(days_to_simulate_edit,'string',num2str(a));
catch
end


try 
    a=evalin('base','hours_to_simulate_in');
    set(hours_to_simulate_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','minutes_to_simulate_in');
    set(minutes_to_simulate_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','seconds_to_simulate_in');
    set(seconds_to_simulate_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','checkthenetwork');
    if strcmp(a,'YES')
    set(radiobutton1,'value',1)
    else
    set(radiobutton2,'value',1)
    end
catch
end
try 
    a=evalin('base','contingencycheck');
    if strcmp(a,'YES')
    set(radiobutton4,'value',1)
    else
    set(radiobutton3,'value',1)
    end
catch
end
try 
    a=evalin('base','PRTC_in');
    set(PRTC_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','tRTCSTART_in');
    set(tRTCSTART_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','PRTD_in');
    set(PRTD_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','IRTDADV_in');
    set(IRTDADV_in_edit,'string',num2str(a));
catch
end
try 
    a=evalin('base','DAC_load_forecast_data_create_in');
    set(DASCUCLF,'value',a);
catch
end
try 
    a=evalin('base','DAC_vg_forecast_data_create_in');
    set(DASCUCVGF,'value',a);
catch
end
try 
    a=evalin('base','RTC_load_forecast_data_create_in');
    set(RTSCUCLF,'value',a);
catch
end
try 
    a=evalin('base','RTC_vg_forecast_data_create_in');
    set(RTSCUCVGF,'value',a);
catch
end
try 
    a=evalin('base','RTD_load_forecast_data_create_in');
    set(RTSCEDLF,'value',a);
catch
end
try
    a=evalin('base','RTD_vg_forecast_data_create_in');
    set(RTSCEDVGF,'value',a);
catch
end
try
    a=evalin('base','DAC_RESERVE_FORECAST_MODE_in');
    set(DAC_RESERVE_FORECAST_MODE_in_GUI,'value',a);
catch
end
try 
    a=evalin('base','RTC_RESERVE_FORECAST_MODE_in');
    set(RTC_RESERVE_FORECAST_MODE_in_GUI,'value',a);
catch
end
try
    a=evalin('base','RTD_RESERVE_FORECAST_MODE_in');
    set(RTD_RESERVE_FORECAST_MODE_in_GUI,'value',a);
catch
end
set(autosavecheck_in,'value',0);
dac_default_checked();
rtc_default_checked();
rtd_default_checked();

%% ~~ CALLBACKS ~~ 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                     %%%
%%%                  C   A   L   L   B   A   C   K   S                  %%%    
%%%                                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Browse for input file callback
function browseforfile(~,~)
    [inputFile,inputDir] = uigetfile(['Input',filesep,'*.xlsx;*.h5'],'Select FESTIV Input File');
    if inputFile == 0
        inputPath = '';
    else
        inputPath = [inputDir,inputFile];
    end
    [~,temprem]=strtok(inputFile,'.');
    if strcmp(temprem,'.h5')
        assignin('base','useHDF5',1);
    else
        assignin('base','useHDF5',0);
    end
    set(inputFileEditBox, 'string', inputFile);
    inifile(['Input',filesep,'FESTIV.inp'],'write',{'','','inputPath',inputPath});
end

%% Create and open the L10 help dialog box
function L10help(~,~)
    l10help=figure('name','L10 Values','NumberTitle','off','units','pixels','position',[500 500 250 210],'menubar','none');
    movegui(l10help,'center');
    cnames={'Name','~Peak [MW]','L10 [MW]'};
    data={'       ISO-NE','      26,629','      122.23';'       NYISO','      33,696','      137.58';'        MISO','      95,105','      231.12';'         PJM','     153,741','      293.82';'       CAISO','      48,887','      117.66';'       BANC','       4,500','       35.70';'        BPA','       9,526','       68.09';'       PSCO','       7,988','       47.60'};
    uitable('Parent',l10help,'Data',data,'ColumnName',cnames,'RowName',[],'Position',[10 35 227 166]);
    uicontrol('Parent',l10help,'Style', 'pushbutton','String','Complete List','Position', [35 5 80 25],'Callback', @(hObject,eventData) web('http://www.nerc.com/docs/oc/rs/2013%20CPS2%20Bounds%20Report%20Final.pdf','-browser')); 
    uicontrol('Parent',l10help,'Style','pushbutton','String','Close','Position', [130 5 80 25],'Callback', @(hObject,eventData) close(gcf));
end

%% Create and open the multiple runs dialog box
function MultipleRuns_callback(~,~)
    multipleRuns_figure=figure('name','Multiple Runs Input Dialog','NumberTitle','off','position',[50 50 730 500],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(multipleRuns_figure,'center');
    multiplerunscheck=uicontrol('parent',multipleRuns_figure,'style','checkbox','string','Multiple Runs','units','normalized','position',[.02 .90 .15 .08],'fontunits','normalized','fontsize',0.35,'callback',{@multiplerunscheck_callback});
    multipleRunsOutputText=uicontrol('parent',multipleRuns_figure,'style','text','string','Output File Name:','units','normalized','position',[0.035 .78 .20 .05],'fontunits','normalized','fontsize',0.4);
    outputfilenames=uicontrol('parent',multipleRuns_figure,'style','edit','units','normalized','fontunits','normalized','position',[.215 .79 .615 .05],'fontsize',0.45,'backgroundcolor','white');
    multipleRunsInputText=uicontrol('parent',multipleRuns_figure,'style','text','string','Input File Name:','units','normalized','position',[0.035 .85 .20 .05],'fontunits','normalized','fontsize',0.4);
    inputfilenamesformultiple=uicontrol('parent',multipleRuns_figure,'style','edit','units','normalized','fontunits','normalized','position',[.215 .86 .615 .05],'fontsize',0.45,'string','test','backgroundcolor','white');
    addruns=uicontrol('parent',multipleRuns_figure,'style','pushbutton','units','normalized','fontunits','normalized','position',[.855 .79 .10 .05],'string','Add','fontsize',0.5,'callback',{@addruns_callback});
    simulationQueue=uitable('Parent',multipleRuns_figure,'units','normalized','position',[0.03 .12 .94 .65],'ColumnFormat',{'char','char'},'ColumnName',{'Input File Name', 'Output File Name'},'ColumnEditable',[false false],'ColumnWidth',{325 325},'CellSelectionCallback',@(src,evnt)set(src,'UserData',evnt.Indices));
    browseformultiple=uicontrol('parent',multipleRuns_figure,'units','normalized','position',[.855 .86 .10 .05],'string','Browse','style','pushbutton','fontunits','normalized','fontsize',0.4,'callback',{@browseformultiplefiles}); 
    uicontrol('parent',multipleRuns_figure,'units','normalized','position',[.87 .01 .10 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.3,'callback',{@donemultiplefiles}); 
    uicontrol('parent',multipleRuns_figure,'units','normalized','position',[.03 .01 .10 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.3,'callback',{@removemultiplefiles}); 
    try set(inputfilenamesformultiple,'string',get(inputFileEditBox,'string'));catch;end
    x=evalin('base','MRcheck');
    set(multiplerunscheck,'value',x)
    if get(multiplerunscheck,'value')==1
       set(multipleRunsOutputText,'Enable','ON');
       set(outputfilenames,'Enable','ON'); 
       set(simulationQueue,'Enable','ON');
       set(addruns,'Enable','ON');
       set(multipleRunsInputText,'enable','on');
       set(inputfilenamesformultiple,'enable','on');
       set(browseformultiple,'enable','on');
       multiplerunscheckvalue=get(multiplerunscheck,'value');
    else
       set(addruns,'Enable','OFF');
       set(multipleRunsOutputText,'Enable','OFF');
       set(outputfilenames,'Enable','OFF'); 
       set(simulationQueue,'Enable','OFF');
       set(multipleRunsInputText,'enable','off');
       set(inputfilenamesformultiple,'enable','off');
       set(browseformultiple,'enable','off');
    end
    try inputfiles=evalin('base','tabledata');catch;end
    try set(simulationQueue,'data',inputfiles);catch;end
end

%% Remove run from multiple runs dialog box
function removemultiplefiles(~,~)
    inputfiles=get(simulationQueue,'data');
    numberofinputfiles=size(inputfiles,1);
    remove_idx=get(simulationQueue,'UserData');
    remove_idx=remove_idx(1);
    if remove_idx < numberofinputfiles
        for i=remove_idx:numberofinputfiles-1
            movefile(sprintf('tempws%d.mat',i+1),sprintf('tempws%d.mat',i))
        end
    end
    inputfiles(remove_idx(1),:)=[];
    set(simulationQueue,'data',inputfiles);
    assignin('base','tabledata',inputfiles);
    numberoffiles=numberoffiles-1;
end

%% Browse for input file for multiple runs dialog box
function browseformultiplefiles(~,~)
    [inputFile,inputDir] = uigetfile(['Input',filesep,'*.xlsx;*.h5'],'Select FESTIV Input File');
    if inputFile == 0
        inputPath = '';
    else
        inputPath = [inputDir,inputFile];
    end
    set(inputfilenamesformultiple, 'string', inputFile);
    inifile(['Input',filesep,'FESTIV.inp'],'write',{'','','inputPath',inputPath});
end

%% Prepare input dialog for multiple run inputs
function multiplerunscheck_callback(~,~)
    if get(multiplerunscheck,'value')==1
       assignin('base','MRcheck',1);
       set(multipleRunsOutputText,'Enable','ON');
       set(outputfilenames,'Enable','ON'); 
       set(simulationQueue,'Enable','ON');
       set(addruns,'Enable','ON');
       set(multipleRunsInputText,'enable','on');
       set(inputfilenamesformultiple,'enable','on');
       set(browseformultiple,'enable','on');
       multiplerunscheckvalue=get(multiplerunscheck,'value');
    else
       assignin('base','MRcheck',0);
       set(addruns,'Enable','OFF');
       set(multipleRunsOutputText,'Enable','OFF');
       set(outputfilenames,'Enable','OFF'); 
       set(simulationQueue,'Enable','OFF');
       set(multipleRunsInputText,'enable','off');
       set(inputfilenamesformultiple,'enable','off');
       set(browseformultiple,'enable','off');
    end
end

%% Done adding multiple files
function donemultiplefiles(~,~)
    close(gcf);
end

%% Create the workspaces for the multiple runs
function addruns_callback(~,~)
    outputname=get(outputfilenames,'String');
    inputname=get(inputfilenamesformultiple,'string');
    inputfiles=get(simulationQueue,'data');
    if isempty(inputfiles) % for first file
        inputfiles={inputname,outputname};
    else
        inputfiles(end+1,:)={inputname,outputname};
    end
    [~,temprem]=strtok(inputname,'.');
    if strcmp(temprem,'.h5')
        assignin('base','useHDF5',1);
    else
        assignin('base','useHDF5',0);
    end
    set(simulationQueue,'data',inputfiles);
    assignin('base','tabledata',inputfiles);

    checkthenetwork=get(radiobutton1,'value');
    if checkthenetwork==1
        checkthenetwork='YES';
    else
        checkthenetwork='NO';
    end
    contingencycheck=get(radiobutton4,'value');
    if contingencycheck==0
        contingencycheck='NO';
    else
        contingencycheck='YES';
    end
    if strcmp(checkthenetwork,'NO')
        contingencycheck='NO';
        set(radiobutton3,'value',1)
    end
    HDAC_in=str2double(get(HDAC_in_edit,'string'));
    IDAC_in=str2double(get(IDAC_in_edit,'string'));
    tDAC_in=str2double(get(tDAC_in_edit,'string'));
    GDAC_in=str2double(get(GDAC_in_edit,'string'));
    PDAC_in=str2double(get(PDAC_in_edit,'string'));
    DAHORIZONTYPE_in=get(DAHORIZONTYPE_in_edit,'value');
    HRTC_in=str2double(get(HRTC_in_edit,'string'));
    IRTC_in=str2double(get(IRTC_in_edit,'string'));
    tRTC_in=str2double(get(tRTC_in_edit,'string'));
    PRTC_in=str2double(get(PRTC_in_edit,'string'));
    tRTCSTART_in=str2double(get(tRTCSTART_in_edit,'string'));
    HRTD_in=str2double(get(HRTD_in_edit,'string'));
    IRTD_in=str2double(get(IRTD_in_edit,'string'));
    tRTD_in=str2double(get(tRTD_in_edit,'string'));
    PRTD_in=str2double(get(PRTD_in_edit,'string'));
    IRTDADV_in=str2double(get(IRTDADV_in_edit,'string'));

    if IRTDADV_in < IRTD_in
        IRTDADV_in = IRTD_in;
    end

    daystosimulate=str2double(get(days_to_simulate_edit,'string'));
    hours_to_simulate_in   = str2double(get(hours_to_simulate_edit,'string'));
    minutes_to_simulate_in = str2double(get(minutes_to_simulate_edit,'string'));
    seconds_to_simulate_in = str2double(get(seconds_to_simulate_edit,'string'));
    
    if HRTD_in > HRTC_in
        HRTD_in=HRTC_in;
    end
    
    DAC_load_forecast_data_create_in=get(DASCUCLF,'value');
    DAC_vg_forecast_data_create_in=get(DASCUCVGF,'value');
    RTC_load_forecast_data_create_in=get(RTSCUCLF,'value');
    RTC_vg_forecast_data_create_in=get(RTSCUCVGF,'value');
    RTD_load_forecast_data_create_in=get(RTSCEDLF,'value');
    RTD_vg_forecast_data_create_in=get(RTSCEDVGF,'value');

    DAC_RESERVE_FORECAST_MODE_in = get(DAC_RESERVE_FORECAST_MODE_in_GUI,'value');
    RTC_RESERVE_FORECAST_MODE_in = get(RTC_RESERVE_FORECAST_MODE_in_GUI,'value');
    RTD_RESERVE_FORECAST_MODE_in = get(RTD_RESERVE_FORECAST_MODE_in_GUI,'value');

    Type3_integral_in=evalin('base','Type3_integral_in');
    K1_in=evalin('base','K1_in');
    K2_in=evalin('base','K2_in');
    CPS2_interval_in=evalin('base','CPS2_interval_in');
    L10_in=evalin('base','L10_in');
    agcmode=evalin('base','agcmode');
    agc_deadband_in=evalin('base','agc_deadband_in');
    SIMULATE_CONTINGENCIES_in=evalin('base','SIMULATE_CONTINGENCIES_in');
    gen_outage_time_in=evalin('base','gen_outage_time_in');
    
    USE_INTEGER_in=evalin('base','USE_INTEGER_in');
    timefordebugstop_in=evalin('base','timefordebugstop_in');
    debugcheck_in=evalin('base','debugcheck_in');
    suppress_plots_in=evalin('base','suppress_plots_in');

    assignin('base','HDAC_in',HDAC_in);
    assignin('base','HDACtest',HDAC_in);
    assignin('base','IDAC_in',IDAC_in);
    assignin('base','tDAC_in',tDAC_in);
    assignin('base','GDAC_in',GDAC_in);
    assignin('base','PDAC_in',PDAC_in);
    assignin('base','DAHORIZONTYPE_in',DAHORIZONTYPE_in);
    assignin('base','HRTC_in',HRTC_in);
    assignin('base','IRTC_in',IRTC_in);
    assignin('base','tRTC_in',tRTC_in);
    assignin('base','PRTC_in',PRTC_in);
    assignin('base','tRTCSTART_in',tRTCSTART_in);
    assignin('base','HRTD_in',HRTD_in);
    assignin('base','IRTD_in',IRTD_in);
    assignin('base','tRTD_in',tRTD_in);
    assignin('base','PRTD_in',PRTD_in);
    assignin('base','IRTDADV_in',IRTDADV_in);
    assignin('base','checkthenetwork',checkthenetwork);
    assignin('base','contingencycheck',contingencycheck);
    assignin('base','daystosimulate',daystosimulate);
    assignin('base','hours_to_simulate_in',hours_to_simulate_in);
    assignin('base','minutes_to_simulate_in',minutes_to_simulate_in);
    assignin('base','seconds_to_simulate_in',seconds_to_simulate_in);
    assignin('base','RTD_load_forecast_data_create_in',RTD_load_forecast_data_create_in);
    assignin('base','RTD_vg_forecast_data_create_in',RTD_vg_forecast_data_create_in);
    assignin('base','RTC_load_forecast_data_create_in',RTC_load_forecast_data_create_in);
    assignin('base','RTC_vg_forecast_data_create_in',RTC_vg_forecast_data_create_in);
    assignin('base','DAC_RESERVE_FORECAST_MODE_in',DAC_RESERVE_FORECAST_MODE_in);
    assignin('base','RTC_RESERVE_FORECAST_MODE_in',RTC_RESERVE_FORECAST_MODE_in);
    assignin('base','RTD_RESERVE_FORECAST_MODE_in',RTD_RESERVE_FORECAST_MODE_in);
    assignin('base','DAC_load_forecast_data_create_in',DAC_load_forecast_data_create_in);
    assignin('base','DAC_vg_forecast_data_create_in',DAC_vg_forecast_data_create_in);
    
    assignin('base','USE_INTEGER_in',USE_INTEGER_in);
    assignin('base','timefordebugstop_in',timefordebugstop_in);
    assignin('base','debugcheck_in',debugcheck_in);
    assignin('base','suppress_plots_in',suppress_plots_in);
    
    assignin('base','DASCUC_RULES_PRE_in',DASCUC_RULES_PRE_in);
    assignin('base','DASCUC_RULES_POST_in',DASCUC_RULES_POST_in);
    assignin('base','RTSCUC_RULES_PRE_in',RTSCUC_RULES_PRE_in);
    assignin('base','RTSCUC_RULES_POST_in',RTSCUC_RULES_POST_in);
    assignin('base','RTSCED_RULES_PRE_in',RTSCED_RULES_PRE_in);
    assignin('base','RTSCED_RULES_POST_in',RTSCED_RULES_POST_in);
    assignin('base','AGC_RULES_PRE_in',AGC_RULES_PRE_in);
    assignin('base','AGC_RULES_POST_in',AGC_RULES_POST_in);
    assignin('base','RPU_RULES_PRE_in',RPU_RULES_PRE_in);
    assignin('base','RPU_RULES_POST_in',RPU_RULES_POST_in);   
    assignin('base','DATA_INITIALIZE_PRE_in',DATA_INITIALIZE_PRE_in);
    assignin('base','DATA_INITIALIZE_POST_in',DATA_INITIALIZE_POST_in);
    assignin('base','FORECASTING_PRE_in',FORECASTING_PRE_in);
    assignin('base','FORECASTING_POST_in',FORECASTING_POST_in);
    assignin('base','RT_LOOP_PRE_in',RT_LOOP_PRE_in);
    assignin('base','RT_LOOP_POST_in',RT_LOOP_POST_in);
    assignin('base','POST_PROCESSING_PRE_in',POST_PROCESSING_PRE_in);
    assignin('base','POST_PROCESSING_POST_in',POST_PROCESSING_POST_in);
    assignin('base','ACE_PRE_in',ACE_PRE_in);
    assignin('base','ACE_POST_in',ACE_POST_in);
    
    assignin('base','cancel',0);
    inputPath = char(inifile(['Input',filesep,'FESTIV.inp'],'read',{'','','inputPath',''}));
    completeinputpathname=inputPath;
    assignin('base','completeinputpathname',completeinputpathname);
    useHDF5=evalin('base','useHDF5');

    % Get a list of all variables
    allvars = whos;

    % Identify the variables that ARE NOT graphics handles. This uses a regular
    % expression on the class of each variable to check if it's a graphics object
    tosave = cellfun(@isempty, regexp({allvars.class}, '^matlab\.(ui|graphics)\.'));

    save(strcat('tempws',num2str(numberoffiles)),allvars(tosave).name);
    numberoffiles=numberoffiles+1;
    assignin('base','SIMULATE_CONTINGENCIES_in','NO'); % reset contingencies after adding it
    assignin('base','gen_outage_time_in',0);
    evalin('base','ctgctabledata=[];');
    assignin('base','USE_INTEGER_in','YES');
    assignin('base','debugcheck_in',0);
    assignin('base','timefordebugstop_in',999);

end

%% Create the final workspace prior to exiting
function runFESTIV(~,~)
    if multiplerunscheckvalue==0
        checkthenetwork=get(radiobutton1,'value');
        if checkthenetwork==1
            checkthenetwork='YES';
        else
            checkthenetwork='NO';
        end
        contingencycheck=get(radiobutton4,'value');
        if contingencycheck==0
            contingencycheck='NO';
        else
            contingencycheck='YES';
        end
        if strcmp(checkthenetwork,'NO')
            contingencycheck='NO';
            set(radiobutton3,'value',1)
        end
        HDAC_in=str2double(get(HDAC_in_edit,'string'));
        IDAC_in=str2double(get(IDAC_in_edit,'string'));
        tDAC_in=str2double(get(tDAC_in_edit,'string'));
        GDAC_in=str2double(get(GDAC_in_edit,'string'));
        PDAC_in=str2double(get(PDAC_in_edit,'string'));
        DAHORIZONTYPE_in=get(DAHORIZONTYPE_in_edit,'value');
        HRTC_in=str2double(get(HRTC_in_edit,'string'));
        IRTC_in=str2double(get(IRTC_in_edit,'string'));
        tRTC_in=str2double(get(tRTC_in_edit,'string'));
        PRTC_in=str2double(get(PRTC_in_edit,'string'));
        tRTCSTART_in=str2double(get(tRTCSTART_in_edit,'string'));
        HRTD_in=str2double(get(HRTD_in_edit,'string'));
        IRTD_in=str2double(get(IRTD_in_edit,'string'));
        tRTD_in=str2double(get(tRTD_in_edit,'string'));
        PRTD_in=str2double(get(PRTD_in_edit,'string'));
        IRTDADV_in=str2double(get(IRTDADV_in_edit,'string'));

        if IRTDADV_in < IRTD_in
            IRTDADV_in = IRTD_in;
        end

        daystosimulate=str2double(get(days_to_simulate_edit,'string'));
        hours_to_simulate_in   = str2double(get(hours_to_simulate_edit,'string'));
        minutes_to_simulate_in = str2double(get(minutes_to_simulate_edit,'string'));
        seconds_to_simulate_in = str2double(get(seconds_to_simulate_edit,'string'));
    
        if HRTD_in > HRTC_in
            HRTD_in=HRTC_in;
        end

        DAC_load_forecast_data_create_in=get(DASCUCLF,'value');
        DAC_vg_forecast_data_create_in=get(DASCUCVGF,'value');
        RTC_load_forecast_data_create_in=get(RTSCUCLF,'value');
        RTC_vg_forecast_data_create_in=get(RTSCUCVGF,'value');
        RTD_load_forecast_data_create_in=get(RTSCEDLF,'value');
        RTD_vg_forecast_data_create_in=get(RTSCEDVGF,'value');

        DAC_RESERVE_FORECAST_MODE_in = get(DAC_RESERVE_FORECAST_MODE_in_GUI,'value');
        RTC_RESERVE_FORECAST_MODE_in = get(RTC_RESERVE_FORECAST_MODE_in_GUI,'value');
        RTD_RESERVE_FORECAST_MODE_in = get(RTD_RESERVE_FORECAST_MODE_in_GUI,'value');
        
        USE_INTEGER_in=evalin('base','USE_INTEGER_in');
        timefordebugstop_in=evalin('base','timefordebugstop_in');
        debugcheck_in=evalin('base','debugcheck_in');
        suppress_plots_in=evalin('base','suppress_plots_in');

        Type3_integral_in=evalin('base','Type3_integral_in');
        K1_in=evalin('base','K1_in');
        K2_in=evalin('base','K2_in');
        CPS2_interval_in=evalin('base','CPS2_interval_in');
        L10_in=evalin('base','L10_in');
        agcmode=evalin('base','agcmode');
        agc_deadband_in=evalin('base','agc_deadband_in');
        SIMULATE_CONTINGENCIES_in=evalin('base','SIMULATE_CONTINGENCIES_in');
        gen_outage_time_in=evalin('base','gen_outage_time_in');

        assignin('base','HDAC_in',HDAC_in);
        assignin('base','HDACtest',HDAC_in);
        assignin('base','IDAC_in',IDAC_in);
        assignin('base','GDAC_in',GDAC_in);
        assignin('base','PDAC_in',PDAC_in);
        assignin('base','DAHORIZONTYPE_in',DAHORIZONTYPE_in);
        assignin('base','tDAC_in',tDAC_in);
        assignin('base','HRTC_in',HRTC_in);
        assignin('base','IRTC_in',IRTC_in);
        assignin('base','tRTC_in',tRTC_in);
        assignin('base','PRTC_in',PRTC_in);
        assignin('base','tRTCSTART_in',tRTCSTART_in);
        assignin('base','HRTD_in',HRTD_in);
        assignin('base','IRTD_in',IRTD_in);
        assignin('base','tRTD_in',tRTD_in);
        assignin('base','PRTD_in',PRTD_in);
        assignin('base','IRTDADV_in',IRTDADV_in);
        assignin('base','checkthenetwork',checkthenetwork);
        assignin('base','contingencycheck',contingencycheck);
        assignin('base','daystosimulate',daystosimulate);
        assignin('base','hours_to_simulate_in',hours_to_simulate_in);
        assignin('base','minutes_to_simulate_in',minutes_to_simulate_in);
        assignin('base','seconds_to_simulate_in',seconds_to_simulate_in);
        assignin('base','RTD_load_forecast_data_create_in',RTD_load_forecast_data_create_in);
        assignin('base','RTD_vg_forecast_data_create_in',RTD_vg_forecast_data_create_in);
        assignin('base','RTC_load_forecast_data_create_in',RTC_load_forecast_data_create_in);
        assignin('base','RTC_vg_forecast_data_create_in',RTC_vg_forecast_data_create_in);
        assignin('base','DAC_load_forecast_data_create_in',DAC_load_forecast_data_create_in);
        assignin('base','DAC_vg_forecast_data_create_in',DAC_vg_forecast_data_create_in);
        assignin('base','DAC_RESERVE_FORECAST_MODE_in',DAC_RESERVE_FORECAST_MODE_in);
        assignin('base','RTC_RESERVE_FORECAST_MODE_in',RTC_RESERVE_FORECAST_MODE_in);
        assignin('base','RTD_RESERVE_FORECAST_MODE_in',RTD_RESERVE_FORECAST_MODE_in);
        assignin('base','DAC_load_forecast_data_create_in',DAC_load_forecast_data_create_in);
        assignin('base','DAC_vg_forecast_data_create_in',DAC_vg_forecast_data_create_in);
        autosavecheck=get(autosavecheck_in,'value');
        assignin('base','autosavecheck',autosavecheck);
        
        assignin('base','USE_INTEGER_in',USE_INTEGER_in);
        assignin('base','timefordebugstop_in',timefordebugstop_in);
        assignin('base','debugcheck_in',debugcheck_in);
        assignin('base','suppress_plots_in',suppress_plots_in);
        
        assignin('base','DASCUC_RULES_PRE_in',DASCUC_RULES_PRE_in);
        assignin('base','DASCUC_RULES_POST_in',DASCUC_RULES_POST_in);
        assignin('base','RTSCUC_RULES_PRE_in',RTSCUC_RULES_PRE_in);
        assignin('base','RTSCUC_RULES_POST_in',RTSCUC_RULES_POST_in);
        assignin('base','RTSCED_RULES_PRE_in',RTSCED_RULES_PRE_in);
        assignin('base','RTSCED_RULES_POST_in',RTSCED_RULES_POST_in);
        assignin('base','AGC_RULES_PRE_in',AGC_RULES_PRE_in);
        assignin('base','AGC_RULES_POST_in',AGC_RULES_POST_in);
        assignin('base','RPU_RULES_PRE_in',RPU_RULES_PRE_in);
        assignin('base','RPU_RULES_POST_in',RPU_RULES_POST_in); 
        assignin('base','DATA_INITIALIZE_PRE_in',DATA_INITIALIZE_PRE_in);
        assignin('base','DATA_INITIALIZE_POST_in',DATA_INITIALIZE_POST_in); 
        assignin('base','FORECASTING_PRE_in',FORECASTING_PRE_in);
        assignin('base','FORECASTING_POST_in',FORECASTING_POST_in);
        assignin('base','RT_LOOP_PRE_in',RT_LOOP_PRE_in);
        assignin('base','RT_LOOP_POST_in',RT_LOOP_POST_in);
        assignin('base','POST_PROCESSING_PRE_in',POST_PROCESSING_PRE_in);
        assignin('base','POST_PROCESSING_POST_in',POST_PROCESSING_POST_in);
        assignin('base','ACE_PRE_in',ACE_PRE_in);
        assignin('base','ACE_POST_in',ACE_POST_in);
       
        assignin('base','cancel',0)
        multiplefilecheck=multiplerunscheckvalue;
        assignin('base','multiplefilecheck',multiplefilecheck);
        useHDF5=evalin('base','useHDF5');
        close(gcf);
        save('tempws', '-regexp', '^((?!button).)*$'); %Save without any button objects
%BP not needed?        save('tempws1', '-regexp', '^((?!button).)*$'); %Save without any button objects
    else
        if numberoffiles-1 <= 1
            warndlg(sprintf('''Multiple Runs'' checked but there are less than two runs in the queue.\nPlease uncheck ''Multiple Runs'' or add more runs to the queue.'),'!! Warning !!')
        else
            temp=strcat('tempws',num2str(numberoffiles-1),'.mat');
            copyfile(temp,'tempws.mat')
            multiplefilecheck=evalin('base','MRcheck');
            assignin('base','multiplefilecheck',multiplefilecheck);
            useHDF5=evalin('base','useHDF5');
            close(gcf);
            save('tempws.mat','multiplefilecheck','-append');
            save('tempws1.mat','multiplefilecheck','-append');
            numofinputfiles=numberoffiles-1;
            save('tempws1.mat','numofinputfiles','numofinputfiles','-append');
        end
    end
end

%% Cancel FESTIV run
function cancel_callback(~,~)
   assignin('base','cancel',1)
   close(gcf); 
end

%% Create additional DASCUC Model Rules dialog box
function dascuc_model_rules(~,~)
    dascucmodelrules_figure=figure('name','DASCUC Model Rules','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(dascucmodelrules_figure,'center');
    uicontrol('parent',dascucmodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .88 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',dascucmodelrules_figure,'style','edit','units','normalized','position',[.25 .895 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',dascucmodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .89 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.07 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_dascuc_pre}); 
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.28 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_dascuc_pre}); 
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.55 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_dascuc_post}); 
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.75 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_dascuc_post}); 
    
    %set(dascucmodel_pre_list,'string',DASCUC_RULES_PRE_in);
    %set(dascucmodel_post_list,DASCUC_RULES_POST_in);
    dascucmodel_pre_list=uitable('Parent',dascucmodelrules_figure,'units','normalized','position',[0.025 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules Before DASCUC'},'ColumnEditable',false,'ColumnWidth',{170},'CellSelectionCallback',{@modelcaseselected_callback});
    dascucmodel_post_list=uitable('Parent',dascucmodelrules_figure,'units','normalized','position',[0.5 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules After DASCUC'},'ColumnEditable',false,'ColumnWidth',{170},'CellSelectionCallback',{@modelcaseselected_callback});
    
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_dascuc_rules}); 
    uicontrol('parent',dascucmodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(dascucmodelrules_figure)); 
    try
        temp1=evalin('base','DASCUC_RULES_PRE_in');
        set(dascucmodel_pre_list,'data',temp1);
    catch
    end
    try
        temp2=evalin('base','DASCUC_RULES_POST_in');
        set(dascucmodel_post_list,'data',temp2);
    catch
    end
    
    
end

%% Create additional RTSCUC Model Rules dialog box
function rtscuc_model_rules(~,~)
    rtscucmodelrules_figure=figure('name','RTSCUC Model Rules','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(rtscucmodelrules_figure,'center');
    uicontrol('parent',rtscucmodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .88 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',rtscucmodelrules_figure,'style','edit','units','normalized','position',[.25 .895 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',rtscucmodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .89 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.07 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rtscuc_pre}); 
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.28 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rtscuc_pre}); 
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.55 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rtscuc_post}); 
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.75 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rtscuc_post}); 
    try
        set(modelinputFileEditBox,'string',modelinputFile);
    catch
    end
    rtscucmodel_pre_list=uitable('Parent',rtscucmodelrules_figure,'units','normalized','position',[0.025 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules Before RTSCUC'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    rtscucmodel_post_list=uitable('Parent',rtscucmodelrules_figure,'units','normalized','position',[0.5 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules After RTSCUC'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_rtscuc_rules}); 
    uicontrol('parent',rtscucmodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(rtscucmodelrules_figure)); 
    try
        temp1=evalin('base','RTSCUC_RULES_PRE_in');
        set(rtscucmodel_pre_list,'data',temp1);
    catch
    end
    try
        temp2=evalin('base','RTSCUC_RULES_POST_in');
        set(rtscucmodel_post_list,'data',temp2);
    catch
    end
end

%% Create additional RTSCED Model Rules dialog box
function rtsced_model_rules(~,~)
    rtscedmodelrules_figure=figure('name','RTSCED Model Rules','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(rtscedmodelrules_figure,'center');
    uicontrol('parent',rtscedmodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .88 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',rtscedmodelrules_figure,'style','edit','units','normalized','position',[.25 .895 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',rtscedmodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .89 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.07 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rtsced_pre}); 
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.28 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rtsced_pre}); 
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.55 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rtsced_post}); 
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.75 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rtsced_post}); 
    try
        set(modelinputFileEditBox,'string',modelinputFile);
    catch
    end
    rtscedmodel_pre_list=uitable('Parent',rtscedmodelrules_figure,'units','normalized','position',[0.025 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules Before RTSCED'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    rtscedmodel_post_list=uitable('Parent',rtscedmodelrules_figure,'units','normalized','position',[0.5 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules After RTSCED'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_rtsced_rules}); 
    uicontrol('parent',rtscedmodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(rtscedmodelrules_figure)); 
    try
        temp1=evalin('base','RTSCED_RULES_PRE_in');
        set(rtscedmodel_pre_list,'data',temp1);
    catch
    end
    try
        temp2=evalin('base','RTSCED_RULES_POST_in');
        set(rtscedmodel_post_list,'data',temp2);
    catch
    end    
end

%% Create additional AGC Model Rules dialog box
function agc_model_rules(~,~)
    agcmodelrules_figure=figure('name','AGC Model Rules','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(agcmodelrules_figure,'center');
    uicontrol('parent',agcmodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .88 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',agcmodelrules_figure,'style','edit','units','normalized','position',[.25 .895 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',agcmodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .89 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.07 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_agc_pre}); 
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.28 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_agc_pre}); 
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.55 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_agc_post}); 
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.75 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_agc_post}); 
    try
        set(modelinputFileEditBox,'string',modelinputFile);
    catch
    end
    agcmodel_pre_list=uitable('Parent',agcmodelrules_figure,'units','normalized','position',[0.025 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules Before AGC'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    agcmodel_post_list=uitable('Parent',agcmodelrules_figure,'units','normalized','position',[0.5 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules After AGC'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_agc_rules}); 
    uicontrol('parent',agcmodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(agcmodelrules_figure)); 
    try
        temp1=evalin('base','AGC_RULES_PRE_in');
        set(agcmodel_pre_list,'data',temp1);
    catch
    end
    try
        temp2=evalin('base','AGC_RULES_POST_in');
        set(agcmodel_post_list,'data',temp2);
    catch
    end    
end

%% Create additional RPU Model Rules dialog box
function rpu_model_rules(~,~)
    rpumodelrules_figure=figure('name','RPU Model Rules','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(rpumodelrules_figure,'center');
    uicontrol('parent',rpumodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .88 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',rpumodelrules_figure,'style','edit','units','normalized','position',[.25 .895 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',rpumodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .89 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.07 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rpu_pre}); 
    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.28 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rpu_pre}); 
    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.55 .75 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_model_rule_rpu_post}); 
    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.75 .75 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_model_rule_rpu_post}); 
    try
        set(modelinputFileEditBox,'string',modelinputFile);
    catch
    end
    rpumodel_pre_list=uitable('Parent',rpumodelrules_figure,'units','normalized','position',[0.025 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules Before RPU'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    rpumodel_post_list=uitable('Parent',rpumodelrules_figure,'units','normalized','position',[0.5 .15 .45 .55],'ColumnFormat',{'char'},'ColumnName',{'Rules After RPU'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});

    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_rpu_rules}); 
    uicontrol('parent',rpumodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(rpumodelrules_figure)); 
    try
        temp1=evalin('base','RPU_RULES_PRE_in');
        set(rpumodel_pre_list,'data',temp1);
    catch
    end
    try
        temp2=evalin('base','RPU_RULES_POST_in');
        set(rpumodel_post_list,'data',temp2);
    catch
    end    
end

%% Create Other Rules dialog box
function other_rules_callback(~,~)
    othermodelrules_figure=figure('name','Other Model Rules','NumberTitle','off','position',[50 50 450 350],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(othermodelrules_figure,'center');
    uicontrol('parent',othermodelrules_figure,'style','text','string','Model Input File:','units','normalized','position',[.01 .79 .25 .08],'fontunits','normalized','fontsize',0.45);
    modelinputFileEditBox=uicontrol('parent',othermodelrules_figure,'style','edit','units','normalized','position',[.25 .805 .55 .08],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',othermodelrules_figure,'style','pushbutton','units','normalized','position',[.825 .805 .13 .08],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseformodelrules});
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.07 .68 .175 .075],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.4,'callback',{@add_model_rule_other_pre}); 
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.28 .68 .175 .075],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.4,'callback',{@remove_model_rule_other_pre}); 
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.55 .68 .175 .075],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.4,'callback',{@add_model_rule_other_post}); 
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.75 .68 .175 .075],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.4,'callback',{@remove_model_rule_other_post}); 
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.275 .90 .50  .075],'style','popupmenu','string','Choose where to add additional rules|Data Initialization|Forecast Creation|Real Time Loop|Post Processing|ACE Calculation|Forced Outage Defintions|Shift Factor Calculation|Actual Output Determination|Reliability Calculations|Cost Calculations|Saving of Results','fontunits','normalized','fontsize',0.4,'backgroundcolor','white','callback',{@otherruleselect});
    try
        set(modelinputFileEditBox,'string',modelinputFile);
    catch
    end
    othermodel_pre_list=uitable('Parent',othermodelrules_figure,'units','normalized','position',[0.025 .15 .45 .5],'ColumnFormat',{'char'},'ColumnName',{'---'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});
    othermodel_post_list=uitable('Parent',othermodelrules_figure,'units','normalized','position',[0.5 .15 .45 .5],'ColumnFormat',{'char'},'ColumnName',{'---'},'ColumnEditable',false,'ColumnWidth',{170 },'CellSelectionCallback',{@modelcaseselected_callback});

    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.58 .03 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_other_rules}); 
    uicontrol('parent',othermodelrules_figure,'units','normalized','position',[.78 .03 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(othermodelrules_figure)); 
%     try
%         temp1=evalin('base','OTHER_RULES_PRE_in');
%         set(othermodel_pre_list,'data',temp1);
%     catch
%     end
%     try
%         temp2=evalin('base','OTHER_RULES_POST_in');
%         set(othermodel_post_list,'data',temp2);
%     catch
%     end    
end

%% Determine which module to open for other rules dialog box
function otherruleselect(hObject,~)
    index_selected = get(hObject,'Value');
    assignin('base','other_model_index',index_selected);
    
    % save current model before switching to a new one
    current_model=get(othermodel_pre_list,'ColumnName');
    if strcmp(current_model,'Pre Data Initialization')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','DATA_INITIALIZE_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','DATA_INITIALIZE_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Data Forecasting')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','FORECASTING_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','FORECASTING_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Post Processing')    
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','POST_PROCESSING_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','POST_PROCESSING_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Real Time Loop')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','RT_LOOP_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','RT_LOOP_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre ACE Calculation')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','ACE_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','ACE_POST_in',otherpost_modelQueue);  
    elseif strcmp(current_model,'Pre Forced Outage')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','FORCED_OUTAGE_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','FORCED_OUTAGE_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre SF Calculations')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','SHIFT_FACTOR_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','SHIFT_FACT0R_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Actual Output')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','ACTUAL_OUTPUT_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','ACTUAL_OUTPUT_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Reliability Calculations')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','RELIABILITY_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','RELIABILITY_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Cost Calculations')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','COST_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','COST_POST_in',otherpost_modelQueue);
    elseif strcmp(current_model,'Pre Saving Data')
        otherpre_modelQueue=get(othermodel_pre_list,'data');
        assignin('base','SAVING_PRE_in',otherpre_modelQueue);
        otherpost_modelQueue=get(othermodel_post_list,'data');
        assignin('base','SAVING_POST_in',otherpost_modelQueue);
    end

    % load new table headers
    if index_selected == 2
        set(othermodel_pre_list,'ColumnName',{'Pre Data Initialization'})
        set(othermodel_post_list,'ColumnName',{'Post Data Initialization'})
    elseif index_selected == 3
        set(othermodel_pre_list,'ColumnName',{'Pre Data Forecasting'})
        set(othermodel_post_list,'ColumnName',{'Post Data Forecasting'})
    elseif index_selected == 4
        set(othermodel_pre_list,'ColumnName',{'Pre Real Time Loop'})
        set(othermodel_post_list,'ColumnName',{'End of Interval'})
    elseif index_selected == 5
        set(othermodel_pre_list,'ColumnName',{'Pre Post Processing'})
        set(othermodel_post_list,'ColumnName',{'Post Post Processing'})
    elseif index_selected == 6
        set(othermodel_pre_list,'ColumnName',{'Pre ACE Calculation'})
        set(othermodel_post_list,'ColumnName',{'Post ACE Calculation'})
    elseif index_selected == 7
        set(othermodel_pre_list,'ColumnName',{'Pre Forced Outage'})
        set(othermodel_post_list,'ColumnName',{'Post Forced Outage'})
    elseif index_selected == 8
        set(othermodel_pre_list,'ColumnName',{'Pre SF Calculations'})
        set(othermodel_post_list,'ColumnName',{'Post SF Calculations'})
    elseif index_selected == 9
        set(othermodel_pre_list,'ColumnName',{'Pre Actual Output'})
        set(othermodel_post_list,'ColumnName',{'Post Actual Output'})
    elseif index_selected == 10
        set(othermodel_pre_list,'ColumnName',{'Pre Reliability Calculations'})
        set(othermodel_post_list,'ColumnName',{'Post Reliability Calculations'})
    elseif index_selected == 11
        set(othermodel_pre_list,'ColumnName',{'Pre Cost Calculations'})
        set(othermodel_post_list,'ColumnName',{'Post Cost Calculations'})
    elseif index_selected == 12
        set(othermodel_pre_list,'ColumnName',{'Pre Saving Data'})
        set(othermodel_post_list,'ColumnName',{'Post Saving Data'})
    end
    
    % load default values
    if index_selected == 2
        try
            temp1=evalin('base','DATA_INITIALIZE_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','DATA_INITIALIZE_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end   
    elseif index_selected == 3
        try
            temp1=evalin('base','FORECASTING_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','FORECASTING_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 4
        try
            temp1=evalin('base','RT_LOOP_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','RT_LOOP_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 5
        try
            temp1=evalin('base','POST_PROCESSING_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','POST_PROCESSING_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 6
        try
            temp1=evalin('base','ACE_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','ACE_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end   
    elseif index_selected == 7
        try
            temp1=evalin('base','FORCED_OUTAGE_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','FORCED_OUTAGE_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 8
        try
            temp1=evalin('base','SHIFT_FACTOR_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','SHIFT_FACTOR_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 9
        try
            temp1=evalin('base','ACTUAL_OUTPUT_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','ACTUAL_OUTPUT_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 10
        try
            temp1=evalin('base','RELIABILITY_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','RELIABILITY_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 11
        try
            temp1=evalin('base','COST_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','COST_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    elseif index_selected == 12
        try
            temp1=evalin('base','SAVING_PRE_in');
            set(othermodel_pre_list,'data',temp1);
        catch
            set(othermodel_pre_list,'data',[]);
        end
        try
            temp2=evalin('base','SAVING_POST_in');
            set(othermodel_post_list,'data',temp2);
        catch
            set(othermodel_post_list,'data',[]);
        end 
    end
end

%% browse for model rules
function browseformodelrules(~,~)
    [modelinputFile,~] = uigetfile(['MODEL_RULES',filesep,'*.m'],'Select Model Rules File');
    set(modelinputFileEditBox,'string',modelinputFile);
end

%% Add DAC-PRE model rule 
function add_model_rule_dascuc_pre(~,~)
    model_rule_temp=modelinputFile;
    dascucpre_modelQueue=evalin('base','DASCUC_RULES_PRE_in');
    if isempty(dascucpre_modelQueue) % for first file
        dascucpre_modelQueue={model_rule_temp};
    else
        dascucpre_modelQueue(end+1,1)={model_rule_temp};
    end
    set(dascucmodel_pre_list,'data',dascucpre_modelQueue);
    assignin('base','DASCUC_RULES_PRE_in',dascucpre_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add DAC-POST model rule 
function add_model_rule_dascuc_post(~,~)
    model_rule_temp=modelinputFile;
    dascucpost_modelQueue=evalin('base','DASCUC_RULES_POST_in');
    if isempty(dascucpost_modelQueue) % for first file
        dascucpost_modelQueue={model_rule_temp};
    else
        dascucpost_modelQueue(end+1,1)={model_rule_temp};
    end
    set(dascucmodel_post_list,'data',dascucpost_modelQueue);
    assignin('base','DASCUC_RULES_POST_in',dascucpost_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RTC-PRE model rule 
function add_model_rule_rtscuc_pre(~,~)
    model_rule_temp=modelinputFile;
    rtscucpre_modelQueue=evalin('base','RTSCUC_RULES_PRE_in');
    if isempty(rtscucpre_modelQueue) % for first file
        rtscucpre_modelQueue={model_rule_temp};
    else
        rtscucpre_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rtscucmodel_pre_list,'data',rtscucpre_modelQueue);
    assignin('base','RTSCUC_RULES_PRE_in',rtscucpre_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RTC-POST model rule 
function add_model_rule_rtscuc_post(~,~)
    model_rule_temp=modelinputFile;
    rtscucpost_modelQueue=evalin('base','RTSCUC_RULES_POST_in');
    if isempty(rtscucpost_modelQueue) % for first file
        rtscucpost_modelQueue={model_rule_temp};
    else
        rtscucpost_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rtscucmodel_post_list,'data',rtscucpost_modelQueue);
    assignin('base','RTSCUC_RULES_POST_in',rtscucpost_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RTD-PRE model rule 
function add_model_rule_rtsced_pre(~,~)
    model_rule_temp=modelinputFile;
    rtscedpre_modelQueue=evalin('base','RTSCED_RULES_PRE_in');
    if isempty(rtscedpre_modelQueue) % for first file
        rtscedpre_modelQueue={model_rule_temp};
    else
        rtscedpre_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rtscedmodel_pre_list,'data',rtscedpre_modelQueue);
    assignin('base','RTSCED_RULES_PRE_in',rtscedpre_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RTD-POST model rule 
function add_model_rule_rtsced_post(~,~)
    model_rule_temp=modelinputFile;
    rtscedpost_modelQueue=evalin('base','RTSCED_RULES_POST_in');
    if isempty(rtscedpost_modelQueue) % for first file
        rtscedpost_modelQueue={model_rule_temp};
    else
        rtscedpost_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rtscedmodel_post_list,'data',rtscedpost_modelQueue);
    assignin('base','RTSCED_RULES_POST_in',rtscedpost_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add AGC-PRE model rule 
function add_model_rule_agc_pre(~,~)
    model_rule_temp=modelinputFile;
    agcpre_modelQueue=evalin('base','AGC_RULES_PRE_in');
    if isempty(agcpre_modelQueue) % for first file
        agcpre_modelQueue={model_rule_temp};
    else
        agcpre_modelQueue(end+1,1)={model_rule_temp};
    end
    set(agcmodel_pre_list,'data',agcpre_modelQueue);
    assignin('base','AGC_RULES_PRE_in',agcpre_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add AGC-POST model rule 
function add_model_rule_agc_post(~,~)
    model_rule_temp=modelinputFile;
    agcpost_modelQueue=evalin('base','AGC_RULES_POST_in');
    if isempty(agcpost_modelQueue) % for first file
        agcpost_modelQueue={model_rule_temp};
    else
        agcpost_modelQueue(end+1,1)={model_rule_temp};
    end
    set(agcmodel_post_list,'data',agcpost_modelQueue);
    assignin('base','AGC_RULES_POST_in',agcpost_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RPU-PRE model rule 
function add_model_rule_rpu_pre(~,~)
    model_rule_temp=modelinputFile;
    rpupre_modelQueue=evalin('base','RPU_RULES_PRE_in');
    if isempty(rpupre_modelQueue) % for first file
        rpupre_modelQueue={model_rule_temp};
    else
        rpupre_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rpumodel_pre_list,'data',rpupre_modelQueue);
    assignin('base','RPU_RULES_PRE_in',rpupre_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add RPU-POST model rule 
function add_model_rule_rpu_post(~,~)
    model_rule_temp=modelinputFile;
    rpupost_modelQueue=evalin('base','RPU_RULES_POST_in');
    if isempty(rpupost_modelQueue) % for first file
        rpupost_modelQueue={model_rule_temp};
    else
        rpupost_modelQueue(end+1,1)={model_rule_temp};
    end
    set(rpumodel_post_list,'data',rpupost_modelQueue);
    assignin('base','RPU_RULES_POST_in',rpupost_modelQueue);
    set(modelinputFileEditBox,'string','');
    modelinputFile='';
end

%% Add OTHER-PRE model rule 
function add_model_rule_other_pre(~,~)
    index_selected=evalin('base','other_model_index');
    model_rule_temp=modelinputFile;
    if index_selected == 2
        otherpre_modelQueue=evalin('base','DATA_INITIALIZE_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','DATA_INITIALIZE_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 3
        otherpre_modelQueue=evalin('base','FORECASTING_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','FORECASTING_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 4
        otherpre_modelQueue=evalin('base','RT_LOOP_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','RT_LOOP_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 5
        otherpre_modelQueue=evalin('base','POST_PROCESSING_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','POST_PROCESSING_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 6
        otherpre_modelQueue=evalin('base','ACE_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','ACE_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
    elseif index_selected == 7
        otherpre_modelQueue=evalin('base','FORCED_OUTAGE_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','FORCED_OUTAGE_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 8
        otherpre_modelQueue=evalin('base','SHIFT_FACTOR_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','SHIFT_FACTOR_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 9
        otherpre_modelQueue=evalin('base','ACTUAL_OUTPUT_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','ACTUAL_OUTPUT_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 10
        otherpre_modelQueue=evalin('base','RELIABILITY_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','RELIABILITY_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 11
        otherpre_modelQueue=evalin('base','COST_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','COST_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 12
        otherpre_modelQueue=evalin('base','SAVING_PRE_in');
        if isempty(otherpre_modelQueue) % for first file
            otherpre_modelQueue={model_rule_temp};
        else
            otherpre_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_pre_list,'data',otherpre_modelQueue);
        assignin('base','SAVING_PRE_in',otherpre_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    end
end

%% Add OTHER-POST model rule 
function add_model_rule_other_post(~,~)
    index_selected=evalin('base','other_model_index');
    model_rule_temp=modelinputFile;
    if index_selected == 2
        otherpost_modelQueue=evalin('base','DATA_INITIALIZE_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','DATA_INITIALIZE_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';
    elseif index_selected == 3
        otherpost_modelQueue=evalin('base','FORECASTING_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','FORECASTING_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';  
    elseif index_selected == 4
        otherpost_modelQueue=evalin('base','RT_LOOP_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','RT_LOOP_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';  
    elseif index_selected == 5
        otherpost_modelQueue=evalin('base','POST_PROCESSING_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','POST_PROCESSING_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';  
     elseif index_selected == 6
        otherpost_modelQueue=evalin('base','ACE_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','ACE_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile='';  
        
     elseif index_selected == 7
        otherpost_modelQueue=evalin('base','FORCED_OUTAGE_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','FORCED_OUTAGE_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
     elseif index_selected == 8
        otherpost_modelQueue=evalin('base','SHIFT_FACTOR_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','SHIFT_FACTOR_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
     elseif index_selected == 9
        otherpost_modelQueue=evalin('base','ACTUAL_OUTPUT_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','ACTUAL_OUTPUT_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
     elseif index_selected == 10
        otherpost_modelQueue=evalin('base','RELIABILITY_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','RELIABILITY_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
     elseif index_selected == 11
        otherpost_modelQueue=evalin('base','COST_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','COST_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
     elseif index_selected == 12
        otherpost_modelQueue=evalin('base','SAVING_POST_in');
        if isempty(otherpost_modelQueue) % for first file
            otherpost_modelQueue={model_rule_temp};
        else
            otherpost_modelQueue(end+1,1)={model_rule_temp};
        end
        set(othermodel_post_list,'data',otherpost_modelQueue);
        assignin('base','SAVING_POST_in',otherpost_modelQueue);
        set(modelinputFileEditBox,'string','');
        modelinputFile=''; 
   end
end

%% Row selected to remove model file
function modelcaseselected_callback(~,eventdata)
    if isempty(eventdata.Indices)
    else
        modelrow=eventdata.Indices(1,1);
        assignin('base','model_rule_removerow',modelrow);
    end
end

%% Remove selected DAC-PRE model rule
function remove_model_rule_dascuc_pre(~,~)
    row=evalin('base','model_rule_removerow');
    DASCUC_RULES_PRE_in=evalin('base','DASCUC_RULES_PRE_in');
    DASCUC_RULES_PRE_in(row,:)=[];
    assignin('base','DASCUC_RULES_PRE_in',DASCUC_RULES_PRE_in);
    set(dascucmodel_pre_list,'data',DASCUC_RULES_PRE_in);
end

%% Remove selected DAC-POST model rule
function remove_model_rule_dascuc_post(~,~)
    row=evalin('base','model_rule_removerow');
    DASCUC_RULES_POST_in=evalin('base','DASCUC_RULES_POST_in');
    DASCUC_RULES_POST_in(row,:)=[];
    assignin('base','DASCUC_RULES_POST_in',DASCUC_RULES_POST_in);
    set(dascucmodel_post_list,'data',DASCUC_RULES_POST_in);
end

%% Remove selected RTC-PRE model rule
function remove_model_rule_rtscuc_pre(~,~)
    row=evalin('base','model_rule_removerow');
    RTSCUC_RULES_PRE_in=evalin('base','RTSCUC_RULES_PRE_in');
    RTSCUC_RULES_PRE_in(row,:)=[];
    assignin('base','RTSCUC_RULES_PRE_in',RTSCUC_RULES_PRE_in);
    set(rtscucmodel_pre_list,'data',RTSCUC_RULES_PRE_in);
end

%% Remove selected RTC-POST model rule
function remove_model_rule_rtscuc_post(~,~)
    row=evalin('base','model_rule_removerow');
    RTSCUC_RULES_POST_in=evalin('base','RTSCUC_RULES_POST_in');
    RTSCUC_RULES_POST_in(row,:)=[];
    assignin('base','RTSCUC_RULES_POST_in',RTSCUC_RULES_POST_in);
    set(rtscucmodel_post_list,'data',RTSCUC_RULES_POST_in);
end

%% Remove selected RTD-PRE model rule
function remove_model_rule_rtsced_pre(~,~)
    row=evalin('base','model_rule_removerow');
    RTSCED_RULES_PRE_in=evalin('base','RTSCED_RULES_PRE_in');
    RTSCED_RULES_PRE_in(row,:)=[];
    assignin('base','RTSCED_RULES_PRE_in',RTSCED_RULES_PRE_in);
    set(rtscedmodel_pre_list,'data',RTSCED_RULES_PRE_in);
end

%% Remove selected RTD-POST model rule
function remove_model_rule_rtsced_post(~,~)
    row=evalin('base','model_rule_removerow');
    RTSCED_RULES_POST_in=evalin('base','RTSCED_RULES_POST_in');
    RTSCED_RULES_POST_in(row,:)=[];
    assignin('base','RTSCED_RULES_POST_in',RTSCED_RULES_POST_in);
    set(rtscedmodel_post_list,'data',RTSCED_RULES_POST_in);
end

%% Remove selected AGC-PRE model rule
function remove_model_rule_agc_pre(~,~)
    row=evalin('base','model_rule_removerow');
    AGC_RULES_PRE_in=evalin('base','AGC_RULES_PRE_in');
    AGC_RULES_PRE_in(row,:)=[];
    assignin('base','AGC_RULES_PRE_in',AGC_RULES_PRE_in);
    set(agcmodel_pre_list,'data',AGC_RULES_PRE_in);
end

%% Remove selected AGC-POST model rule
function remove_model_rule_agc_post(~,~)
    row=evalin('base','model_rule_removerow');
    AGC_RULES_POST_in=evalin('base','AGC_RULES_POST_in');
    AGC_RULES_POST_in(row,:)=[];
    assignin('base','AGC_RULES_POST_in',AGC_RULES_POST_in);
    set(agcmodel_post_list,'data',AGC_RULES_POST_in);
end

%% Remove selected RPU-PRE model rule
function remove_model_rule_rpu_pre(~,~)
    row=evalin('base','model_rule_removerow');
    RPU_RULES_PRE_in=evalin('base','RPU_RULES_PRE_in');
    RPU_RULES_PRE_in(row,:)=[];
    assignin('base','RPU_RULES_PRE_in',RPU_RULES_PRE_in);
    set(rpumodel_pre_list,'data',RPU_RULES_PRE_in);
end

%% Remove selected RPU-POST model rule
function remove_model_rule_rpu_post(~,~)
    row=evalin('base','model_rule_removerow');
    RPU_RULES_POST_in=evalin('base','RPU_RULES_POST_in');
    RPU_RULES_POST_in(row,:)=[];
    assignin('base','RPU_RULES_POST_in',RPU_RULES_POST_in);
    set(rpumodel_post_list,'data',RPU_RULES_POST_in);
end

%% Remove selected OTHER-PRE model rule
function remove_model_rule_other_pre(~,~)
    index_selected=evalin('base','other_model_index');
    if index_selected == 2
        row=evalin('base','model_rule_removerow');
        DATA_INITIALIZE_PRE_in=evalin('base','DATA_INITIALIZE_PRE_in');
        DATA_INITIALIZE_PRE_in(row,:)=[];
        assignin('base','DATA_INITIALIZE_PRE_in',DATA_INITIALIZE_PRE_in);
        set(othermodel_pre_list,'data',DATA_INITIALIZE_PRE_in);
    elseif index_selected == 3
        row=evalin('base','model_rule_removerow');
        FORECASTING_PRE_in=evalin('base','FORECASTING_PRE_in');
        FORECASTING_PRE_in(row,:)=[];
        assignin('base','FORECASTING_PRE_in',FORECASTING_PRE_in);
        set(othermodel_pre_list,'data',FORECASTING_PRE_in);
    elseif index_selected == 4
        row=evalin('base','model_rule_removerow');
        RT_LOOP_PRE_in=evalin('base','RT_LOOP_PRE_in');
        RT_LOOP_PRE_in(row,:)=[];
        assignin('base','RT_LOOP_PRE_in',RT_LOOP_PRE_in);
        set(othermodel_pre_list,'data',RT_LOOP_PRE_in);
    elseif index_selected == 5
        row=evalin('base','model_rule_removerow');
        POST_PROCESSING_PRE_in=evalin('base','POST_PROCESSING_PRE_in');
        POST_PROCESSING_PRE_in(row,:)=[];
        assignin('base','POST_PROCESSING_PRE_in',POST_PROCESSING_PRE_in);
        set(othermodel_pre_list,'data',POST_PROCESSING_PRE_in);
    elseif index_selected == 6
        row=evalin('base','model_rule_removerow');
        ACE_PRE_in=evalin('base','ACE_PRE_in');
        ACE_PRE_in(row,:)=[];
        assignin('base','ACE_PRE_in',ACE_PRE_in);
        set(othermodel_pre_list,'data',ACE_PRE_in); 
    elseif index_selected == 7
        row=evalin('base','model_rule_removerow');
        FORCED_OUTAGE_PRE_in=evalin('base','FORCED_OUTAGE_PRE_in');
        FORCED_OUTAGE_PRE_in(row,:)=[];
        assignin('base','FORCED_OUTAGE_PRE_in',FORCED_OUTAGE_PRE_in);
        set(othermodel_pre_list,'data',FORCED_OUTAGE_PRE_in);
    elseif index_selected == 8
        row=evalin('base','model_rule_removerow');
        SHIFT_FACTOR_PRE_in=evalin('base','SHIFT_FACTOR_PRE_in');
        SHIFT_FACTOR_PRE_in(row,:)=[];
        assignin('base','SHIFT_FACTOR_PRE_in',SHIFT_FACTOR_PRE_in);
        set(othermodel_pre_list,'data',SHIFT_FACTOR_PRE_in);
    elseif index_selected == 9
        row=evalin('base','model_rule_removerow');
        ACTUAL_OUTPUT_PRE_in=evalin('base','ACTUAL_OUTPUT_PRE_in');
        ACTUAL_OUTPUT_PRE_in(row,:)=[];
        assignin('base','ACTUAL_OUTPUT_PRE_in',ACTUAL_OUTPUT_PRE_in);
        set(othermodel_pre_list,'data',ACTUAL_OUTPUT_PRE_in);
    elseif index_selected == 10
        row=evalin('base','model_rule_removerow');
        RELIABILITY_PRE_in=evalin('base','RELIABILITY_PRE_in');
        RELIABILITY_PRE_in(row,:)=[];
        assignin('base','RELIABILITY_PRE_in',RELIABILITY_PRE_in);
        set(othermodel_pre_list,'data',RELIABILITY_PRE_in);
    elseif index_selected == 11
        row=evalin('base','model_rule_removerow');
        COST_PRE_in=evalin('base','COST_PRE_in');
        COST_PRE_in(row,:)=[];
        assignin('base','COST_PRE_in',COST_PRE_in);
        set(othermodel_pre_list,'data',COST_PRE_in);
    elseif index_selected == 12
        row=evalin('base','model_rule_removerow');
        SAVING_PRE_in=evalin('base','SAVING_PRE_in');
        SAVING_PRE_in(row,:)=[];
        assignin('base','SAVING_PRE_in',SAVING_PRE_in);
        set(othermodel_pre_list,'data',SAVING_PRE_in);
    end
end

%% Remove selected OTHER-POST model rule
function remove_model_rule_other_post(~,~)
    index_selected=evalin('base','other_model_index');
    if index_selected ==2
        row=evalin('base','model_rule_removerow');
        DATA_INITIALIZE_POST_in=evalin('base','DATA_INITIALIZE_POST_in');
        DATA_INITIALIZE_POST_in(row,:)=[];
        assignin('base','DATA_INITIALIZE_POST_in',DATA_INITIALIZE_POST_in);
        set(othermodel_post_list,'data',DATA_INITIALIZE_POST_in);
    elseif index_selected == 3
        row=evalin('base','model_rule_removerow');
        FORECASTING_POST_in=evalin('base','FORECASTING_POST_in');
        FORECASTING_POST_in(row,:)=[];
        assignin('base','FORECASTING_POST_in',FORECASTING_POST_in);
        set(othermodel_post_list,'data',FORECASTING_POST_in);
    elseif index_selected == 4
        row=evalin('base','model_rule_removerow');
        RT_LOOP_POST_in=evalin('base','RT_LOOP_POST_in');
        RT_LOOP_POST_in(row,:)=[];
        assignin('base','RT_LOOP_POST_in',RT_LOOP_POST_in);
        set(othermodel_post_list,'data',RT_LOOP_POST_in);
    elseif index_selected == 5
        row=evalin('base','model_rule_removerow');
        POST_PROCESSING_POST_in=evalin('base','POST_PROCESSING_POST_in');
        POST_PROCESSING_POST_in(row,:)=[];
        assignin('base','POST_PROCESSING_POST_in',POST_PROCESSING_POST_in);
        set(othermodel_post_list,'data',POST_PROCESSING_POST_in);
    elseif index_selected == 6
        row=evalin('base','model_rule_removerow');
        ACE_POST_in=evalin('base','ACE_POST_in');
        ACE_POST_in(row,:)=[];
        assignin('base','ACE_POST_in',ACE_POST_in);
        set(othermodel_post_list,'data',ACE_POST_in);
    elseif index_selected == 7
        row=evalin('base','model_rule_removerow');
        FORCED_OUTAGE_POST_in=evalin('base','FORCED_OUTAGE_POST_in');
        FORCED_OUTAGE_POST_in(row,:)=[];
        assignin('base','FORCED_OUTAGE_POST_in',FORCED_OUTAGE_POST_in);
        set(othermodel_post_list,'data',FORCED_OUTAGE_POST_in);
    elseif index_selected == 8
        row=evalin('base','model_rule_removerow');
        SHIFT_FACTOR_POST_in=evalin('base','SHIFT_FACTOR_POST_in');
        SHIFT_FACTOR_POST_in(row,:)=[];
        assignin('base','SHIFT_FACTOR_POST_in',SHIFT_FACTOR_POST_in);
        set(othermodel_post_list,'data',SHIFT_FACTOR_POST_in);
    elseif index_selected == 9
        row=evalin('base','model_rule_removerow');
        ACTUAL_OUTPUT_POST_in=evalin('base','ACTUAL_OUTPUT_POST_in');
        ACTUAL_OUTPUT_POST_in(row,:)=[];
        assignin('base','ACTUAL_OUTPUT_POST_in',ACTUAL_OUTPUT_POST_in);
        set(othermodel_post_list,'data',ACTUAL_OUTPUT_POST_in);
    elseif index_selected == 10
        row=evalin('base','model_rule_removerow');
        RELIABILITY_POST_in=evalin('base','RELIABILITY_POST_in');
        RELIABILITY_POST_in(row,:)=[];
        assignin('base','RELIABILITY_POST_in',RELIABILITY_POST_in);
        set(othermodel_post_list,'data',RELIABILITY_POST_in);
    elseif index_selected == 11
        row=evalin('base','model_rule_removerow');
        COST_POST_in=evalin('base','COST_POST_in');
        COST_POST_in(row,:)=[];
        assignin('base','COST_POST_in',COST_POST_in);
        set(othermodel_post_list,'data',COST_POST_in);
    elseif index_selected == 12
        row=evalin('base','model_rule_removerow');
        SAVING_POST_in=evalin('base','SAVING_POST_in');
        SAVING_POST_in(row,:)=[];
        assignin('base','SAVING_POST_in',SAVING_POST_in);
        set(othermodel_post_list,'data',SAVING_POST_in);
    end
end

%% Gather the DASCUC Model Rules
function get_dascuc_rules(~,~)
    DASCUC_RULES_PRE_in=evalin('base','DASCUC_RULES_PRE_in');
    DASCUC_RULES_POST_in=evalin('base','DASCUC_RULES_POST_in');
    assignin('base','DASCUC_RULES_PRE_in',DASCUC_RULES_PRE_in);
    assignin('base','DASCUC_RULES_POST_in',DASCUC_RULES_POST_in);
    close(gcf);
end

%% Gather the RTSCUC Model Rules
function get_rtscuc_rules(~,~)
    RTSCUC_RULES_PRE_in=evalin('base','RTSCUC_RULES_PRE_in');
    RTSCUC_RULES_POST_in=evalin('base','RTSCUC_RULES_POST_in');
    assignin('base','RTSCUC_RULES_PRE_in',RTSCUC_RULES_PRE_in);
    assignin('base','RTSCUC_RULES_POST_in',RTSCUC_RULES_POST_in);
    close(gcf);
end

%% Gather the RTSCED Model Rules
function get_rtsced_rules(~,~)
    RTSCED_RULES_PRE_in=evalin('base','RTSCED_RULES_PRE_in');
    RTSCED_RULES_POST_in=evalin('base','RTSCED_RULES_POST_in');
    assignin('base','RTSCED_RULES_PRE_in',RTSCED_RULES_PRE_in);
    assignin('base','RTSCED_RULES_POST_in',RTSCED_RULES_POST_in);
    close(gcf);
end

%% Gather the AGC Model Rules
function get_agc_rules(~,~)
    AGC_RULES_PRE_in=evalin('base','AGC_RULES_PRE_in');
    AGC_RULES_POST_in=evalin('base','AGC_RULES_POST_in');
    assignin('base','AGC_RULES_PRE_in',AGC_RULES_PRE_in);
    assignin('base','AGC_RULES_POST_in',AGC_RULES_POST_in);
    close(gcf);
end

%% Gather the RPU Model Rules
function get_rpu_rules(~,~)
    RPU_RULES_PRE_in=evalin('base','RPU_RULES_PRE_in');
    RPU_RULES_POST_in=evalin('base','RPU_RULES_POST_in');
    assignin('base','RPU_RULES_PRE_in',RPU_RULES_PRE_in);
    assignin('base','RPU_RULES_POST_in',RPU_RULES_POST_in);
    close(gcf);
end

%% Gather Other Model Rules
function get_other_rules(~,~)
    DATA_INITIALIZE_PRE_in=evalin('base','DATA_INITIALIZE_PRE_in');
    DATA_INITIALIZE_POST_in=evalin('base','DATA_INITIALIZE_POST_in');
    assignin('base','DATA_INITIALIZE_PRE_in',DATA_INITIALIZE_PRE_in);
    assignin('base','DATA_INITIALIZE_POST_in',DATA_INITIALIZE_POST_in);
    
    FORECASTING_PRE_in=evalin('base','FORECASTING_PRE_in');
    FORECASTING_POST_in=evalin('base','FORECASTING_POST_in');
    assignin('base','FORECASTING_PRE_in',FORECASTING_PRE_in);
    assignin('base','FORECASTING_POST_in',FORECASTING_POST_in);
    
    RT_LOOP_PRE_in=evalin('base','RT_LOOP_PRE_in');
    RT_LOOP_POST_in=evalin('base','RT_LOOP_POST_in');
    assignin('base','RT_LOOP_PRE_in',RT_LOOP_PRE_in);
    assignin('base','RT_LOOP_POST_in',RT_LOOP_POST_in);
    
    POST_PROCESSING_PRE_in=evalin('base','POST_PROCESSING_PRE_in');
    POST_PROCESSING_POST_in=evalin('base','POST_PROCESSING_POST_in');
    assignin('base','POST_PROCESSING_PRE_in',POST_PROCESSING_PRE_in);
    assignin('base','POST_PROCESSING_POST_in',POST_PROCESSING_POST_in);
    
    ACE_PRE_in=evalin('base','ACE_PRE_in');
    ACE_POST_in=evalin('base','ACE_POST_in');
    assignin('base','ACE_PRE_in',ACE_PRE_in);
    assignin('base','ACE_POST_in',ACE_POST_in);
    
    FORCED_OUTAGE_PRE_in=evalin('base','FORCED_OUTAGE_PRE_in');
    FORCED_OUTAGE_POST_in=evalin('base','FORCED_OUTAGE_POST_in');
    assignin('base','FORCED_OUTAGE_PRE_in',FORCED_OUTAGE_PRE_in);
    assignin('base','FORCED_OUTAGE_POST_in',FORCED_OUTAGE_POST_in);
    
    SHIFT_FACTOR_PRE_in=evalin('base','SHIFT_FACTOR_PRE_in');
    SHIFT_FACTOR_POST_in=evalin('base','SHIFT_FACTOR_POST_in');
    assignin('base','SHIFT_FACTOR_PRE_in',SHIFT_FACTOR_PRE_in);
    assignin('base','SHIFT_FACTOR_POST_in',SHIFT_FACTOR_POST_in);
    
    ACTUAL_OUTPUT_PRE_in=evalin('base','ACTUAL_OUTPUT_PRE_in');
    ACTUAL_OUTPUT_POST_in=evalin('base','ACTUAL_OUTPUT_POST_in');
    assignin('base','ACTUAL_OUTPUT_PRE_in',ACTUAL_OUTPUT_PRE_in);
    assignin('base','ACTUAL_OUTPUT_POST_in',ACTUAL_OUTPUT_POST_in);
    
    RELIABILITY_PRE_in=evalin('base','RELIABILITY_PRE_in');
    RELIABILITY_POST_in=evalin('base','RELIABILITY_POST_in');
    assignin('base','RELIABILITY_PRE_in',RELIABILITY_PRE_in);
    assignin('base','RELIABILITY_POST_in',RELIABILITY_POST_in);
    
    COST_PRE_in=evalin('base','COST_PRE_in');
    COST_POST_in=evalin('base','COST_POST_in');
    assignin('base','COST_PRE_in',COST_PRE_in);
    assignin('base','COST_POST_in',COST_POST_in);
    
    SAVING_PRE_in=evalin('base','SAVING_PRE_in');
    SAVING_POST_in=evalin('base','SAVING_POST_in');
    assignin('base','SAVING_PRE_in',SAVING_PRE_in);
    assignin('base','SAVING_POST_in',SAVING_POST_in);
    close(gcf);
end

%% Create additional AGC inputs dialog box
function agc_input(~,~)
    agcOptions_figure=figure('name','AGC Input Options','NumberTitle','off','position',[50 50 450 300],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(agcOptions_figure,'center');
    uicontrol('parent',agcOptions_figure,'units','normalized','position',[.58 .04 .175 .15],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_agc_options}); 
    uicontrol('parent',agcOptions_figure,'units','normalized','position',[.78 .04 .175 .15],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(agcOptions_figure)); 
    
    cps2panel=uipanel('parent',agcOptions_figure,'units','normalized','position',[.05 .45 .425 .50],'title','CPS2 Options');
    sacepanel=uipanel('parent',agcOptions_figure,'units','normalized','position',[.525 .25 .425 .7],'title','Smoothed ACE Options');
    agcpanel=uipanel('parent',agcOptions_figure,'units','normalized','position',[.05 .025 .5 .2],'title','AGC Modes');
    agcdeadbandpanel=uipanel('parent',agcOptions_figure,'units','normalized','position',[.05 .25 .425 .18],'title','AGC Deadband');
    
    uicontrol('parent',cps2panel,'units','normalized','position',[.05 .7 .55 .15],'style','text','string','Interval Length:','fontunits','normalized','fontsize',0.5);
    uicontrol('parent',cps2panel,'units','normalized','position',[.1 .4 .4 .15],'style','text','string','L10:','fontunits','normalized','fontsize',0.6);
    CPS2_interval_in_edit=uicontrol('parent',cps2panel,'units','normalized','position',[.60 .72 .30 .15],'style','edit','string','10','fontunits','normalized','fontsize',0.6,'backgroundcolor','white');
    L10_in_edit=uicontrol('parent',cps2panel,'units','normalized','position',[.55 .42 .30 .15],'style','edit','string','50','fontunits','normalized','fontsize',0.6,'backgroundcolor','white');
    uicontrol('parent',cps2panel,'units','normalized','position',[.1 .1 .75 .15],'style','pushbutton','string','Other L10 Values','fontunits','normalized','fontsize',0.6,'callback',{@L10help});

    uicontrol('parent',sacepanel,'units','normalized','position',[.05 .7 .55 .15],'style','text','string','Integral Length:','fontunits','normalized','fontsize',0.5);
    uicontrol('parent',sacepanel,'units','normalized','position',[.1 .41 .40 .15],'style','text','string','K1:','fontunits','normalized','fontsize',0.6);
    uicontrol('parent',sacepanel,'units','normalized','position',[.1 .1 .40 .15],'style','text','string','K2:','fontunits','normalized','fontsize',0.6);
    Type3_integral_in_edit=uicontrol('parent',sacepanel,'units','normalized','position',[.65 .72 .30 .15],'style','edit','string','180','fontunits','normalized','fontsize',0.6,'backgroundcolor','white');
    K1_in_edit=uicontrol('parent',sacepanel,'units','normalized','position',[.55 .42 .30 .15],'style','edit','string','0.5','fontunits','normalized','fontsize',0.6,'backgroundcolor','white');
    K2_in_edit=uicontrol('parent',sacepanel,'units','normalized','position',[.55 .12 .30 .15],'style','edit','string','0.5','fontunits','normalized','fontsize',0.6,'backgroundcolor','white');
    
    uicontrol('parent',agcpanel,'style','text','units','normalized','position',[.05 .4 .3 .33],'string','AGC Mode:','fontunits','normalized','fontsize',0.9);
    agcmodes=uicontrol('parent',agcpanel,'style','popupmenu','string','1 - Blind Mode|2 - Fast Mode|3 - Smooth Mode|4 - Lazy Mode|5 - Individual Modes|6 - Other','units','normalized','position',[.38 .75 .58 .04],'backgroundcolor','white');
    
    uicontrol('parent',agcdeadbandpanel,'style','text','units','normalized','position',[.05 .05 .60 .70],'string','Deadband [MW]:','fontunits','normalized','fontsize',0.5);
    agc_deadband_in_edit=uicontrol('parent',agcdeadbandpanel,'style','edit','units','normalized','position',[0.67 .25 .2 .6],'fontunits','normalized','fontsize',0.5,'string','5','backgroundcolor','white');
    
    % load last used values if possible
    try 
        a=evalin('base','CPS2_interval_in');
    	set(CPS2_interval_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','L10_in');
    	set(L10_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','Type3_integral_in');
    	set(Type3_integral_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','K1_in');
    	set(K1_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','K2_in');
    	set(K2_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','agcmode');
    	set(agcmodes,'value',a);
    catch
    end
    try
        a=evalin('base','agc_deadband_in');
        set(agc_deadband_in_edit,'string',num2str(a));
    catch
    end
end

%% Gather the AGC parameters
function get_agc_options(~,~)
    CPS2_interval_in=str2double(get(CPS2_interval_in_edit,'string'));
    L10_in=str2double(get(L10_in_edit,'string'));
    assignin('base','CPS2_interval_in',CPS2_interval_in);
    assignin('base','L10_in',L10_in);
    
    Type3_integral_in=str2double(get(Type3_integral_in_edit,'string'));
    K1_in=str2double(get(K1_in_edit,'string'));
    K2_in=str2double(get(K2_in_edit,'string'));
    assignin('base','Type3_integral_in',Type3_integral_in);
    assignin('base','K1_in',K1_in);
    assignin('base','K2_in',K2_in);
    
    agcmode=get(agcmodes,'value');
    assignin('base','agcmode',agcmode);
    
    agc_deadband_in=str2double(get(agc_deadband_in_edit,'string'));
    assignin('base','agc_deadband_in',agc_deadband_in);
    
    close(gcf);
end

%% Create RPU input dialog box
function rpu_callback(~,~)
    % create RPU options figure
    RPU_figure=figure('name','Reserve Pick Up Parameters Input Dialog','NumberTitle','off','position',[50 50 400 250],'menubar','none','color',[.9412 .9412 .9412]);
    movegui(RPU_figure,'center');

    % create panels
    allowrpubuttongroup=uibuttongroup('parent',RPU_figure,'title','Main Setting','units','normalized','position',[.05 .78 .90 .19],'fontunits','normalized','fontsize',0.25);
    rputimingpanel=uipanel('parent',RPU_figure,'units','normalized','position',[.05 .50 .90 .25],'title','RPU Timing Parameters');    
    rpuotherpanel=uipanel('parent',RPU_figure,'units','normalized','position',[.05 .17 .90 .3],'title','RPU Operating Parameters');

    % create RPU button group
    uicontrol('parent',allowrpubuttongroup,'style','text','string','Should a Reserve Pick Up be allowed?','units','normalized','fontunits','normalized','position',[.03 .05 .60 .8],'fontsize',.48,'horizontalalignment','left');
    radiobutton5=uicontrol('parent',allowrpubuttongroup,'style','radiobutton','units','normalized','position',[.68 .25 .20 .80],'string','Yes','fontunits','normalized','fontsize',0.55,'value',0);
    uicontrol('parent',allowrpubuttongroup,'style','radiobutton','units','normalized','position',[.85 .25 .15 .80],'string','No','fontunits','normalized','fontsize',0.55,'value',1);

    % create RPU timing parameters
    uicontrol('parent',rputimingpanel,'style','text','string','HRPU:','units','normalized','position',[.03 .05 .12 .70],'fontunits','normalized','fontsize',0.4,'horizontalalignment','left');    
    HRPU_in_edit=uicontrol('parent',rputimingpanel,'style','edit','string','6','units','normalized','position',[.17 .275 .1  .55],'fontunits','normalized','fontsize',0.6,'backgroundcolor','white');    
    uicontrol('parent',rputimingpanel,'style','text','string','IRPU:','units','normalized','position',[.40 .05 .12 .70],'fontunits','normalized','fontsize',0.4,'horizontalalignment','left');    
    IRPU_in_edit=uicontrol('parent',rputimingpanel,'style','edit','string','10','units','normalized','position',[.52 .275 .1  .55],'fontunits','normalized','fontsize',0.6,'backgroundcolor','white');    
    uicontrol('parent',rputimingpanel,'style','text','string','PRPU:','units','normalized','position',[.73 .05 .12 .70],'fontunits','normalized','fontsize',0.4,'horizontalalignment','left');    
    PRPU_in_edit=uicontrol('parent',rputimingpanel,'style','edit','string','1','units','normalized','position',[.85 .275 .1  .55],'fontunits','normalized','fontsize',0.6,'backgroundcolor','white');    

    % create other RPU parameters
    uicontrol('parent',rpuotherpanel,'style','text','string','ACE Threshold in MW:','units','normalized','position',[.025 .45 .4 .45],'fontunits','normalized','fontsize',0.45,'horizontalalignment','left');    
    ACE_RPU_THRESHOLD_MW_in_edit=uicontrol('parent',rpuotherpanel,'style','edit','string','1000','units','normalized','position',[.38 .6 .1 .35],'fontunits','normalized','fontsize',0.5,'backgroundcolor','white');
    uicontrol('parent',rpuotherpanel,'style','text','string','ACE Threshold in AGC intervals:','units','normalized','position',[.1925 0 .55 .43],'fontunits','normalized','fontsize',0.5,'horizontalalignment','left');    
    ACE_RPU_THRESHOLD_T_in_edit=uicontrol('parent',rpuotherpanel,'style','edit','string','2','units','normalized','position',[.705 .105 .1 .35],'fontunits','normalized','fontsize',0.5,'backgroundcolor','white');    
    uicontrol('parent',rpuotherpanel,'style','text','string','Time Restriction [min]:','units','normalized','position',[.52 .45 .4 .45],'fontunits','normalized','fontsize',0.45,'horizontalalignment','left');    
    restrict_multiple_rpu_time_in_edit=uicontrol('parent',rpuotherpanel,'style','edit','string','10','units','normalized','position',[.875 .58 .1 .35],'fontunits','normalized','fontsize',0.5,'backgroundcolor','white');    

    % create other buttons
    uicontrol('parent',RPU_figure,'units','normalized','position',[.05 .025 .20 .1],'string','RPU Rules','style','pushbutton','fontunits','normalized','fontsize',0.45,'callback',{@rpu_model_rules}); 
    uicontrol('parent',RPU_figure,'units','normalized','position',[.57 .025 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.45,'callback',{@get_rpu_options}); 
    uicontrol('parent',RPU_figure,'units','normalized','position',[.77 .025 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.45,'callback',@(hObject,eventData) close(RPU_figure)); 

    % load last used values if possible
    try 
        a=evalin('base','HRPU_in');
        set(HRPU_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','IRPU_in');
    	set(IRPU_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','PRPU_in');
    	set(PRPU_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','ACE_RPU_THRESHOLD_MW_in');
    	set(ACE_RPU_THRESHOLD_MW_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','ACE_RPU_THRESHOLD_T_in');
    	set(ACE_RPU_THRESHOLD_T_in_edit,'string',num2str(a));
    catch
    end
    try 
        a=evalin('base','restrict_multiple_rpu_time_in');
    	set(restrict_multiple_rpu_time_in_edit,'string',num2str(a));
    catch
    end
    try
        if strcmp(evalin('base','ALLOW_RPU_in'),'YES')
            set(radiobutton5,'value',1)
        end
    catch
    end
end

%% Gather the RPU parameters
function get_rpu_options(~,~)
    HRPU_in=str2double(get(HRPU_in_edit,'string'));
    IRPU_in=str2double(get(IRPU_in_edit,'string'));
    PRPU_in=str2double(get(PRPU_in_edit,'string'));
    ACE_RPU_THRESHOLD_MW_in=str2double(get(ACE_RPU_THRESHOLD_MW_in_edit,'string'));
    ACE_RPU_THRESHOLD_T_in=str2double(get(ACE_RPU_THRESHOLD_T_in_edit,'string'));
    restrict_multiple_rpu_time_in=str2double(get(restrict_multiple_rpu_time_in_edit,'string'));
    ALLOW_RPU_in=get(radiobutton5,'value');
    
    if ALLOW_RPU_in == 1
        ALLOW_RPU_in='YES';
    else
        ALLOW_RPU_in='NO';
    end
    
    assignin('base','HRPU_in',HRPU_in);
    assignin('base','IRPU_in',IRPU_in);
    assignin('base','PRPU_in',PRPU_in);
    assignin('base','ACE_RPU_THRESHOLD_MW_in',ACE_RPU_THRESHOLD_MW_in);
    assignin('base','ACE_RPU_THRESHOLD_T_in',ACE_RPU_THRESHOLD_T_in);
    assignin('base','restrict_multiple_rpu_time_in',restrict_multiple_rpu_time_in);
    assignin('base','ALLOW_RPU_in',ALLOW_RPU_in);
    
    close(gcf);
end

%% Create contingnecy input dialog box
function contingencies_callback(~,~)
    % create contingency options figure
    ctgc_figure=figure('name','Contingency Parameters Input Dialog','NumberTitle','off','position',[50 50 400 350],'menubar','none','color',[.9412 .9412 .9412],'visible','off');
    movegui(ctgc_figure,'center');

    % determine list of generators
    inputPath = char(inifile(['Input',filesep,'FESTIV.inp'],'read',{'','','inputPath',''}));
    [~,~,c1]=fileparts(inputPath);
    if strcmp(c1,'.h5')
        x=h5read(inputPath,'/Main Input File/GEN');
        GENS=x.Generator;
    else
        [~,GENS] = xlsread(inputPath,'GEN','A2:A1000');
    end
    ngen = size(GENS,1);
    gennames=[];
    for i=1:size(GENS,1)
        gennames=strcat(gennames,strcat(GENS(i,1),'|'));
    end
    gennames=cell2mat(gennames);
    gennames=gennames(1:end-1);

    % create panels
    ctgctypepanel=uibuttongroup('parent',ctgc_figure,'title','How will contingencies be simulated?','units','normalized','position',[.025 .84 .95 .15],'fontunits','normalized','fontsize',0.22,'SelectionChangeFcn',{@selection_change});
    ctgcpanel=uipanel('parent',ctgc_figure,'units','normalized','position',[.025 .6 .95 .23],'title','Contingency Parameters');

    % determine how to simulate contingencies
    radiobutton7=uicontrol('parent',ctgctypepanel,'style','radiobutton','units','normalized','position',[.30 .40 .54 .45],'string','Prespecified by the user','fontunits','normalized','fontsize',0.8,'value',0);
    radiobutton8=uicontrol('parent',ctgctypepanel,'style','radiobutton','units','normalized','position',[.77 .40 .22 .45],'string','Randomly','fontunits','normalized','fontsize',0.8,'value',0);
    radiobutton9=uicontrol('parent',ctgctypepanel,'style','radiobutton','units','normalized','position',[.02 .40 .25 .45],'string','None at all','fontunits','normalized','fontsize',0.8,'value',1);

    % create contingency options inputs
    uicontrol('parent',ctgcpanel,'style','text','units','normalized','position',[.025 .45 .4 .45],'string','Unit to Outage:','fontunits','normalized','fontsize',0.45);
    ctgc_gen_in_edit=uicontrol('parent',ctgcpanel,'style','popupmenu','units','normalized','position',[.025 .5 .4 .04],'string',gennames,'backgroundcolor','white','enable','off');
    uicontrol('parent',ctgcpanel,'style','text','units','normalized','position',[.55 .45 .4 .45],'string','Time of Outage:','fontunits','normalized','fontsize',0.45);
    ctgc_D_in_edit=uicontrol('parent',ctgcpanel,'style','edit','units','normalized','position',[.50 .19 .10 .35],'string','D','fontunits','normalized','fontsize',0.55,'backgroundcolor','white','enable','off');
    ctgc_H_in_edit=uicontrol('parent',ctgcpanel,'style','edit','units','normalized','position',[.625 .19 .10 .35],'string','H','fontunits','normalized','fontsize',0.55,'backgroundcolor','white','enable','off');
    ctgc_M_in_edit=uicontrol('parent',ctgcpanel,'style','edit','units','normalized','position',[.75 .19 .10 .35],'string','M','fontunits','normalized','fontsize',0.55,'backgroundcolor','white','enable','off');
    ctgc_S_in_edit=uicontrol('parent',ctgcpanel,'style','edit','units','normalized','position',[.875 .19 .10 .35],'string','S','fontunits','normalized','fontsize',0.55,'backgroundcolor','white','enable','off');
    uicontrol('parent',ctgcpanel,'style','text','units','normalized','position',[.6075 .15 .01 .35],'string',':','fontunits','normalized','fontsize',0.55);
    uicontrol('parent',ctgcpanel,'style','text','units','normalized','position',[.7325 .15 .01 .35],'string',':','fontunits','normalized','fontsize',0.55);
    uicontrol('parent',ctgcpanel,'style','text','units','normalized','position',[.8575 .15 .01 .35],'string',':','fontunits','normalized','fontsize',0.55);

    % create a table to show added contingencies
    outageQueue=uitable('Parent',ctgc_figure,'units','normalized','position',[0.025 .15 .95 .41],'ColumnFormat',{'char','char'},'ColumnName',{'Generator Name','Time of Outage [hr]'},'ColumnEditable',[false false],'ColumnWidth',{170 170},'CellSelectionCallback',{@caseselected_callback});

    % create figure buttons to close and proceed
    uicontrol('parent',ctgc_figure,'units','normalized','position',[.60 .025 .175 .1],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@get_ctgc_options}); 
    uicontrol('parent',ctgc_figure,'units','normalized','position',[.80 .025 .175 .1],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(ctgc_figure)); 
    uicontrol('parent',ctgc_figure,'units','normalized','position',[.025 .025 .175 .1],'string','Add','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_ctgc_case}); 
    uicontrol('parent',ctgc_figure,'units','normalized','position',[.225 .025 .175 .1],'string','Remove','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_ctgc_case}); 

    set(ctgc_figure,'visible','on');
    outagedgenindicies=[];
    
    % load last used values if applicable
    try
        temp=evalin('base','ctgctabledata');
        set(outageQueue,'data',temp);
        temp=evalin('base','buttonvalues');
        if temp(1,1)==1
            set(radiobutton9,'value',1);
        elseif temp(1,2)==1
            set(radiobutton7,'value',1);
        else
            set(radiobutton8,'value',1);
        end
        if get(radiobutton7,'value')
            set(ctgc_gen_in_edit,'enable','on');
            set(ctgc_D_in_edit,'enable','on');
            set(ctgc_H_in_edit,'enable','on');
            set(ctgc_M_in_edit,'enable','on');
            set(ctgc_S_in_edit,'enable','on');
            set(outageQueue,'enable','on');
            assignin('base','SIMULATE_CONTINGENCIES_in','YES');
            assignin('base','Contingency_input_check_in',1);
        end
    catch
    end
end

%% Add a unit outage to list of contingencies
function add_ctgc_case(~,~)
    ctgc_gen_value=get(ctgc_gen_in_edit,'value');
    ctgc_temp=get(ctgc_gen_in_edit,'string');
    ctgc_gen_name=ctgc_temp(ctgc_gen_value,1:end);
    ctgc_D=str2double(get(ctgc_D_in_edit,'string'));
    ctgc_H=str2double(get(ctgc_H_in_edit,'string'));
    ctgc_M=str2double(get(ctgc_M_in_edit,'string'));
    ctgc_S=str2double(get(ctgc_S_in_edit,'string'));
    ctgc_time=ctgc_D*24 + ctgc_H + (ctgc_M/60) + (ctgc_S/3600);
    contingencyQueue=get(outageQueue,'data');
    outagedgenindicies=[outagedgenindicies;ctgc_gen_value];
    if isempty(contingencyQueue) % for first file
        contingencyQueue={ctgc_gen_name,ctgc_time};
    else
        contingencyQueue(end+1,:)={ctgc_gen_name,ctgc_time};
    end
    set(outageQueue,'data',contingencyQueue);
    assignin('base','ctgctabledata',contingencyQueue);
    assignin('base','outagedgenindicies',outagedgenindicies);
end

%% Gather contingency data
function get_ctgc_options(~,~)
    Contingency_input_check_in=evalin('base','Contingency_input_check_in');
    temp=get(radiobutton9,'value');
    if temp==1
        close(gcf);
    else
        if Contingency_input_check_in==1
            ctgc_indicies=evalin('base','outagedgenindicies');
            ctgc_times_in_hrs=evalin('base','cell2mat(ctgctabledata(:,2))');
            gen_outage_time_in=inf*ones(ngen,1);
            gen_outage_time_in(ctgc_indicies,1)=ctgc_times_in_hrs;
            assignin('base','gen_outage_time_in',gen_outage_time_in);
            close(gcf);
        else
            close(gcf);
        end
    end
end

%% Determine how to simulate contingencies
function selection_change(~,~)
    buttonvalues=[get(radiobutton9,'value'),get(radiobutton7,'value'),get(radiobutton8,'value')];
    if buttonvalues(1,2) % user specified case
        set(ctgc_gen_in_edit,'enable','on');
        set(ctgc_D_in_edit,'enable','on');
        set(ctgc_H_in_edit,'enable','on');
        set(ctgc_M_in_edit,'enable','on');
        set(ctgc_S_in_edit,'enable','on');
        set(outageQueue,'enable','on');
        assignin('base','SIMULATE_CONTINGENCIES_in','YES');
        assignin('base','Contingency_input_check_in',1);
    elseif buttonvalues(1,3) % random case
        set(ctgc_gen_in_edit,'enable','off');
        set(ctgc_D_in_edit,'enable','off');
        set(ctgc_H_in_edit,'enable','off');
        set(ctgc_M_in_edit,'enable','off');
        set(ctgc_S_in_edit,'enable','off');
        set(outageQueue,'enable','off');
        assignin('base','SIMULATE_CONTINGENCIES_in','YES');
        assignin('base','gen_outage_time',0);
        assignin('base','Contingency_input_check_in',0);
    else % no contingencies
        set(ctgc_gen_in_edit,'enable','off');
        set(ctgc_D_in_edit,'enable','off');
        set(ctgc_H_in_edit,'enable','off');
        set(ctgc_M_in_edit,'enable','off');
        set(ctgc_S_in_edit,'enable','off');
        set(outageQueue,'enable','off');
        assignin('base','SIMULATE_CONTINGENCIES_in','NO');
        assignin('base','gen_outage_time',0);
    end
    assignin('base','buttonvalues',buttonvalues);
end

%% Determine if a contingency case has been selected for removal
function caseselected_callback(~,eventdata)
    if isempty(eventdata.Indices)
    else
        row=eventdata.Indices(1,1);
        assignin('base','ctgcremoverow',row);
    end
end

%% Remove selected contingency case
function remove_ctgc_case(~,~)
    row=evalin('base','ctgcremoverow');
    ctgctabledata=evalin('base','ctgctabledata');
    ctgctabledata(row,:)=[];
    assignin('base','ctgctabledata',ctgctabledata);
    set(outageQueue,'data',ctgctabledata);
    outagedgenindicies=evalin('base','outagedgenindicies');
    outagedgenindicies(row,:)=[];
    assignin('base','outagedgenindicies',outagedgenindicies);
end

%% Create debugging input dialog box
function debugging_callback(~,~)
    debug_figure=figure('name','Debugging Parameters Input Dialog','NumberTitle','off','position',[50 50 350 250],'menubar','none','color',[.9412 .9412 .9412],'visible','off');
    movegui(debug_figure,'center');

    % create panels
    useintpanel=uibuttongroup('parent',debug_figure,'title','Solver Options','units','normalized','position',[.025 .57 .95 .200],'fontunits','normalized','fontsize',0.185);
    dbstoppanel=uibuttongroup('parent',debug_figure,'units','normalized','position',[.025 .195 .95 .350],'title','Execution Options','selectionchangefcn',{@debugtimestop_callback});
    supressfigurespanel=uibuttongroup('parent',debug_figure,'title','Suppress Outputs','units','normalized','position',[.025 .79 .95 .200],'fontunits','normalized','fontsize',0.185);

    % determine how to solve UC
    uicontrol('parent',useintpanel,'style','text','string','Should integers be used?','units','normalized','position',[.025 .2225 .60 .60],'fontunits','normalized','fontsize',0.55,'horizontalalignment','left');
    radiobutton10=uicontrol('parent',useintpanel,'style','radiobutton','units','normalized','position',[.65 .40 .15 .45],'string','Yes','fontunits','normalized','fontsize',0.8,'value',1);
    uicontrol('parent',useintpanel,'style','radiobutton','units','normalized','position',[.82 .40 .15 .45],'string','No','fontunits','normalized','fontsize',0.8,'value',0);
    
    % determine if output plots should be suppressed
    uicontrol('parent',supressfigurespanel,'style','text','string','Suppress output plots?','units','normalized','position',[.025 .2225 .60 .60],'fontunits','normalized','fontsize',0.55,'horizontalalignment','left');
    radiobutton15=uicontrol('parent',supressfigurespanel,'style','radiobutton','units','normalized','position',[.65 .40 .15 .45],'string','Yes','fontunits','normalized','fontsize',0.8,'value',0);
    uicontrol('parent',supressfigurespanel,'style','radiobutton','units','normalized','position',[.82 .40 .15 .45],'string','No','fontunits','normalized','fontsize',0.8,'value',1);
    try
        suppress_plots_in=evalin('base','suppress_plots_in');
        if strcmp(suppress_plots_in,'YES')
            set(radiobutton15,'value',1);
        else
            set(radiobutton15,'value',0);
        end
    catch
    end
    
    % determine if execution should be stopped at a certain time
    uicontrol('parent',dbstoppanel,'style','text','string','Stop execution at a certain time?','units','normalized','position',[0.025 .75 .60 .20],'fontunits','normalized','fontsize',0.9,'horizontalalignment','left');
    radiobutton12=uicontrol('parent',dbstoppanel,'style','radiobutton','units','normalized','position',[.65 .75 .15 .25],'string','Yes','fontunits','normalized','fontsize',0.9,'value',0);
    radiobutton13=uicontrol('parent',dbstoppanel,'style','radiobutton','units','normalized','position',[.82 .75 .15 .25],'string','No','fontunits','normalized','fontsize',0.9,'value',1);
    uicontrol('parent',dbstoppanel,'style','text','string','Time to stop [hr] :','units','normalized','position',[.025 0.25 .60 .20],'fontunits','normalized','fontsize',0.9,'horizontalalignment','left');
    timefordebugstop_in_edit=uicontrol('parent',dbstoppanel,'style','edit','units','normalized','position',[0.65 .175 .30 .35],'fontunits','normalized','fontsize',0.65,'backgroundcolor','white','enable','off');

    % creat done button
    uicontrol('parent',debug_figure,'units','normalized','position',[.775 .025 .20 .15],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.40,'callback',{@get_debug_options}); 

    set(debug_figure,'visible','on')
    try
        temp=evalin('base','timefordebugstop_in');
        set(timefordebugstop_in_edit,'string',temp);
    catch
    end
    try
        temp=evalin('base','debugcheck_in');
        if temp == 1
            set(radiobutton12,'value',1);
            set(timefordebugstop_in_edit,'enable','on');            
        else
            set(radiobutton13,'value',1);
        end
    catch
    end
end

%% Determine if a debug stop is necessary
function debugtimestop_callback(~,~)
    debugstopbuttonvalues=[get(radiobutton12,'value'),get(radiobutton13,'value')];
    if debugstopbuttonvalues(1,1)==1
        set(timefordebugstop_in_edit,'enable','on');
    else
        set(timefordebugstop_in_edit,'enable','off');
    end
end

%% Gather the debugging options
function get_debug_options(~,~)
    temp=get(radiobutton10,'value');
    if temp == 1
        USE_INTEGER_in='YES';
    else
        USE_INTEGER_in='NO';
    end
    temp=get(radiobutton12,'value');
    if temp == 1
        debugcheck_in=1;
        timefordebugstop_in=str2double(get(timefordebugstop_in_edit,'string'));
        if isnan(timefordebugstop_in)
            timefordebugstop_in=0;
        end
    else
        debugcheck_in=0;
        timefordebugstop_in=999;
    end
    temp=get(radiobutton15,'value');
    if temp == 1
        suppress_plots_in='YES';
    else
        suppress_plots_in='NO';
    end
    assignin('base','USE_INTEGER_in',USE_INTEGER_in);
    assignin('base','timefordebugstop_in',timefordebugstop_in);
    assignin('base','debugcheck_in',debugcheck_in);
    assignin('base','suppress_plots_in',suppress_plots_in);
    close(gcf);
end

%% Autosave
function autosavecallback(~,~)
    c=get(autosavecheck_in,'value');
    if c==1
        autoSaveFigure=figure('visible','off','name','Output Name','NumberTitle','off','units','pixels','position',[50 50 400 100],'menubar','none','color',[.9412 .9412 .9412]);
        movegui(autoSaveFigure,'center');
        set(autoSaveFigure,'visible','on');
        uicontrol('Parent',autoSaveFigure,'Style','pushbutton','String','Cancel','units','normalized','Position', [0.825 0.06 0.145 0.29],'fontunits','normalized','fontsize',0.30,'Callback', @(hObject,eventData) close(autoSaveFigure));
        uicontrol('Parent',autoSaveFigure,'Style','pushbutton','String','Done','units','normalized','Position', [0.65 0.06 0.145 0.29],'fontunits','normalized','fontsize',0.30,'Callback', {@saveAutoSaveNameCallback});
        autoSaveName_edit=uicontrol('parent',autoSaveFigure,'style','edit','string','Output Name','units','normalized','position',[0.1 0.5 0.8 0.33],'fontunits','normalized','fontsize',0.4,'backgroundcolor','white');
    end
end

function saveAutoSaveNameCallback(~,~)
    assignin('base','outputname',get(autoSaveName_edit,'string'));
    close(gcf);
end

%% Build GAMS models
function build_gams_models_callback(~,~)
    warning('off','MATLAB:uitabgroup:OldVersion');
    warning('off','MATLAB:warn_r14_stucture_assignment');
    gams_model_figure = figure('name','Create GAMS Models','NumberTitle','off','menubar','none','color','white','position',[50 50 900 700]);
    assignin('base','gams_model_figure',gams_model_figure);
    tgroup = uitabgroup('Parent', gams_model_figure);
    [matversion, matverdatestr] = version;
    matverdate=str2num(matverdatestr(end-4:end));
    if matverdate < 2014
    set(tgroup,'SelectionChangeFcn',{@tab_changed_fcn});
    else
    set(tgroup,'SelectionChange',{@tab_changed_fcn});
    end
    assignin('base','tgroup',tgroup);
    tab1 = uitab('Parent', tgroup, 'Title', 'DASCUC');
    tab2 = uitab('Parent', tgroup, 'Title', 'RTSCUC');
    tab3 = uitab('Parent', tgroup, 'Title', 'RTSCED');
    movegui(gams_model_figure,'center');

    % DASCUC Tab
    uicontrol('parent',tab1,'style','text','string','Select Folder:','units','normalized','position',[.01 .93 .25 .05],'fontunits','normalized','fontsize',0.45);
    dac_modelinputFolderEditBox=uicontrol('parent',tab1,'style','edit','units','normalized','position',[.20 .94 .60 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',tab1,'style','pushbutton','units','normalized','position',[.82 .9405 .13 .05],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseforgamsfolder});
    uicontrol('parent',tab1,'style','text','string','Select Location:','units','normalized','position',[.01 .86 .25 .05],'fontunits','normalized','fontsize',0.45);
    dac_modelinputLocationListBox=uicontrol('parent',tab1,'style','popupmenu','units','normalized','position',[.20 .87 .75 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left','string','Header|User_Defined_1|Load_Inputs|User_Defined_2|Define_Inputs|User_Defined_3|Manipulate_Inputs|User_Defined_4|Declare_Variables|User_Defined_5|Declare_Equations|User_Defined_6|Define_Constraints|User_Defined_7|Model_Definition|User_Defined_8|Solver_Options|User_Defined_9|Solve_Statement|User_Defined_10|Post_Processing|User_Defined_11|Footer','callback',{@dacSectionChange});
    uicontrol('parent',tab1,'units','normalized','position',[.59 .53 .05 .05],'string','>','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_dac_gams_rule}); 
    uicontrol('parent',tab1,'units','normalized','position',[.59 .47 .05 .05],'string','<','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_dac_gams_rule}); 
    dac_list_of_gams_rules=uicontrol('Parent',tab1,'Style','listbox','Max',10,'units','normalized','Position',[0.28 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    dac_list_of_selected_gams_rules=uicontrol('Parent',tab1,'Style','listbox','Max',10,'units','normalized','Position',[0.65 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    uicontrol('parent',tab1,'units','normalized','position',[.58 .03 .175 .075],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@create_gams_rules}); 
    uicontrol('parent',tab1,'units','normalized','position',[.78 .03 .175 .075],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(gams_model_figure)); 
    uicontrol('parent',tab1,'units','normalized','position',[.10 .35 .15 .07],'string','Summary','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@display_summary}); 
    uicontrol('parent',tab1,'style','pushbutton','unit','normalized','position',[.10 .75 .15 .07],'string','<html><center>Default<br>DASCUC</center></html>','fontunits','normalized','fontsize',0.25,'callback',{@dac_default_checked});
    uicontrol('parent',tab1,'units','normalized','position',[.10 .45 .15 .07],'string','Load','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@load_gams_setup}); 
    uicontrol('parent',tab1,'units','normalized','position',[.10 .55 .15 .07],'string','Save','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@save_gams_setup}); 
    uicontrol('parent',tab1,'units','normalized','position',[.10 .65 .15 .07],'string','<html><center>Clear<br>DASCUC</center></html>','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@clear_dac_gams}); 
    uicontrol('parent',tab1,'units','normalized','position',[.07 .025 .40 .08],'string','Warning: Changing the GAMS code may result in an infeasible model.','style','text','fontunits','normalized','fontsize',0.4);
    dacSectionChange();
    
    % RTSCUC Tab
    uicontrol('parent',tab2,'style','text','string','Select Folder:','units','normalized','position',[.01 .93 .25 .05],'fontunits','normalized','fontsize',0.45);
    rtc_modelinputFolderEditBox=uicontrol('parent',tab2,'style','edit','units','normalized','position',[.20 .94 .60 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',tab2,'style','pushbutton','units','normalized','position',[.82 .9405 .13 .05],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseforgamsfolder});
    uicontrol('parent',tab2,'style','text','string','Select Location:','units','normalized','position',[.01 .86 .25 .05],'fontunits','normalized','fontsize',0.45);
    rtc_modelinputLocationListBox=uicontrol('parent',tab2,'style','popupmenu','units','normalized','position',[.20 .87 .75 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left','string','Header|User_Defined_1|Load_Inputs|User_Defined_2|Define_Inputs|User_Defined_3|Manipulate_Inputs|User_Defined_4|Declare_Variables|User_Defined_5|Declare_Equations|User_Defined_6|Define_Constraints|User_Defined_7|Model_Definition|User_Defined_8|Solver_Options|User_Defined_9|Solve_Statement|User_Defined_10|Post_Processing|User_Defined_11|Footer','callback',{@rtcSectionChange});
    uicontrol('parent',tab2,'units','normalized','position',[.59 .53 .05 .05],'string','>','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_rtc_gams_rule}); 
    uicontrol('parent',tab2,'units','normalized','position',[.59 .47 .05 .05],'string','<','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_rtc_gams_rule}); 
    rtc_list_of_gams_rules=uicontrol('Parent',tab2,'Style','listbox','Max',10,'units','normalized','Position',[0.28 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    rtc_list_of_selected_gams_rules=uicontrol('Parent',tab2,'Style','listbox','Max',10,'units','normalized','Position',[0.65 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    uicontrol('parent',tab2,'units','normalized','position',[.58 .03 .175 .075],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@create_gams_rules}); 
    uicontrol('parent',tab2,'units','normalized','position',[.78 .03 .175 .075],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(gams_model_figure)); 
    uicontrol('parent',tab2,'units','normalized','position',[.10 .35 .15 .07],'string','Summary','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@display_summary}); 
    uicontrol('parent',tab2,'style','pushbutton','unit','normalized','position',[.10 .75 .15 .07],'string','<html><center>Default<br>RTSCUC</center></html>','fontunits','normalized','fontsize',0.25,'callback',{@rtc_default_checked});
    uicontrol('parent',tab2,'units','normalized','position',[.10 .45 .15 .07],'string','Load','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@load_gams_setup}); 
    uicontrol('parent',tab2,'units','normalized','position',[.10 .55 .15 .07],'string','Save','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@save_gams_setup}); 
    uicontrol('parent',tab2,'units','normalized','position',[.10 .65 .15 .07],'string','<html><center>Clear<br>RTSCUC</center></html>','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@clear_rtc_gams}); 
    uicontrol('parent',tab2,'units','normalized','position',[.07 .025 .40 .08],'string','Warning: Changing the GAMS code may result in an infeasible model.','style','text','fontunits','normalized','fontsize',0.4);
    
    % RTSCED Tab
    uicontrol('parent',tab3,'style','text','string','Select Folder:','units','normalized','position',[.01 .93 .25 .05],'fontunits','normalized','fontsize',0.45);
    rtd_modelinputFolderEditBox=uicontrol('parent',tab3,'style','edit','units','normalized','position',[.20 .94 .60 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left');
    uicontrol('parent',tab3,'style','pushbutton','units','normalized','position',[.82 .9405 .13 .05],'string','Browse','fontunits','normalized','fontsize',.45,'callback',{@browseforgamsfolder});
    uicontrol('parent',tab3,'style','text','string','Select Location:','units','normalized','position',[.01 .86 .25 .05],'fontunits','normalized','fontsize',0.45);
    rtd_modelinputLocationListBox=uicontrol('parent',tab3,'style','popupmenu','units','normalized','position',[.20 .87 .75 .05],'fontunits','normalized','fontsize',0.45,'backgroundcolor','white','horizontalalignment','left','string','Header|User_Defined_1|Load_Inputs|User_Defined_2|Define_Inputs|User_Defined_3|Manipulate_Inputs|User_Defined_4|Declare_Variables|User_Defined_5|Declare_Equations|User_Defined_6|Define_Constraints|User_Defined_7|Model_Definition|User_Defined_8|Solver_Options|User_Defined_9|Solve_Statement|User_Defined_10|Post_Processing|User_Defined_11|Footer','callback',{@rtdSectionChange});
    uicontrol('parent',tab3,'units','normalized','position',[.59 .53 .05 .05],'string','>','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@add_rtd_gams_rule}); 
    uicontrol('parent',tab3,'units','normalized','position',[.59 .47 .05 .05],'string','<','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@remove_rtd_gams_rule}); 
    rtd_list_of_gams_rules=uicontrol('Parent',tab3,'Style','listbox','Max',10,'units','normalized','Position',[0.28 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    rtd_list_of_selected_gams_rules=uicontrol('Parent',tab3,'Style','listbox','Max',10,'units','normalized','Position',[0.65 .13 .30 .71],'FontName','Courier','String','','Max',10,'value',[]);
    uicontrol('parent',tab3,'units','normalized','position',[.58 .03 .175 .075],'string','Done','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',{@create_gams_rules}); 
    uicontrol('parent',tab3,'units','normalized','position',[.78 .03 .175 .075],'string','Cancel','style','pushbutton','fontunits','normalized','fontsize',0.35,'callback',@(hObject,eventData) close(gams_model_figure)); 
    uicontrol('parent',tab3,'units','normalized','position',[.10 .35 .15 .07],'string','Summary','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@display_summary}); 
    uicontrol('parent',tab3,'style','pushbutton','unit','normalized','position',[.10 .75 .15 .07],'string','<html><center>Default<br>RTSCED</center></html>','fontunits','normalized','fontsize',0.25,'callback',{@rtd_default_checked});
    uicontrol('parent',tab3,'units','normalized','position',[.10 .45 .15 .07],'string','Load','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@load_gams_setup}); 
    uicontrol('parent',tab3,'units','normalized','position',[.10 .55 .15 .07],'string','Save','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@save_gams_setup}); 
    uicontrol('parent',tab3,'units','normalized','position',[.10 .65 .15 .07],'string','<html><center>Clear<br>RTSCED</center></html>','style','pushbutton','fontunits','normalized','fontsize',0.25,'callback',{@clear_rtd_gams}); 
    uicontrol('parent',tab3,'units','normalized','position',[.07 .025 .40 .08],'string','Warning: Changing the GAMS code may result in an infeasible model.','style','text','fontunits','normalized','fontsize',0.4);
end

function tab_changed_fcn(~,eventdata)
    if eventdata.OldValue ~= 0
        if eventdata.NewValue==1
            try
                sectionName1=get(dac_modelinputLocationListBox,'value');
                sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
                temp3=sectionName2(sectionName1);
                gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
                tempNames=gamsFilesNames_DAC.(sprintf('%s',temp3{:}))(:);
                set(dac_list_of_selected_gams_rules,'string',tempNames);
                set(dac_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
            catch
                set(dac_list_of_selected_gams_rules,'string','');
            end
        elseif eventdata.NewValue==2
            try
                sectionName1=get(rtc_modelinputLocationListBox,'value');
                sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
                temp3=sectionName2(sectionName1);
                gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
                tempNames=gamsFilesNames_RTC.(sprintf('%s',temp3{:}))(:);
                set(rtc_list_of_selected_gams_rules,'string',tempNames);
                set(rtc_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
            catch
                set(rtc_list_of_selected_gams_rules,'string','');
            end
        else
            try
                sectionName1=get(rtd_modelinputLocationListBox,'value');
                sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
                temp3=sectionName2(sectionName1);
                gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
                tempNames=gamsFilesNames_RTD.(sprintf('%s',temp3{:}))(:);
                set(rtd_list_of_selected_gams_rules,'string',tempNames);
                set(rtd_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
            catch
                set(rtd_list_of_selected_gams_rules,'string','');
            end
        end
    end
end

function display_summary(~,~)
    names=evalin('base','gamsFilesNames_DAC');
    empty=0;
    if ~isempty(names)
        names_fields=fieldnames(names);
        open_Option='w+';
        for i=1:size(names_fields,1)
            if ~isempty(names.(sprintf('%s',names_fields{i})))
                fid=fopen(['TEMP',filesep,'GAMS_Summary_Temp.txt'],open_Option);
                if strcmp(open_Option,'w+')
                    fprintf(fid,'=========================================\r\n\r\n             DASCUC SUMMARY\r\n\r\n=========================================\r\n\r\n');
                end
                fprintf(fid,names_fields{i});
                fprintf(fid,'\r\n-----------------------------------------\r\n');
                for j=1:size(names.(sprintf('%s',names_fields{i})),1)
                    fprintf(fid,names.(sprintf('%s',names_fields{i})){j,:});
                    fprintf(fid,'\r\n');
                end
                fprintf(fid,'\r\n\r\n');
                fclose(fid);
                open_Option='a+';
            end
        end
    else
        empty=empty+1;
    end
    names=evalin('base','gamsFilesNames_RTC');
    if ~isempty(names)
        names_fields=fieldnames(names);
        open_Option='a+';first_Write=1;
        for i=1:size(names_fields,1)
            if ~isempty(names.(sprintf('%s',names_fields{i})))
                fid=fopen(['TEMP',filesep,'GAMS_Summary_Temp.txt'],open_Option);
                if first_Write
                    fprintf(fid,'=========================================\r\n\r\n             RTSCUC SUMMARY\r\n\r\n=========================================\r\n\r\n');
                end
                fprintf(fid,names_fields{i});
                fprintf(fid,'\r\n-----------------------------------------\r\n');
                for j=1:size(names.(sprintf('%s',names_fields{i})),1)
                    fprintf(fid,names.(sprintf('%s',names_fields{i})){j,:});
                    fprintf(fid,'\r\n');
                end
                fprintf(fid,'\r\n\r\n');
                fclose(fid);
                open_Option='a+';
                first_Write=0;
            end
        end
    else
        empty=empty+1;
    end
    names=evalin('base','gamsFilesNames_RTD');
    if ~isempty(names)
        names_fields=fieldnames(names);
        open_Option='a+';first_Write=1;
        for i=1:size(names_fields,1)
            if ~isempty(names.(sprintf('%s',names_fields{i})))
                fid=fopen(['TEMP',filesep,'GAMS_Summary_Temp.txt'],open_Option);
                if first_Write
                    fprintf(fid,'=========================================\r\n\r\n             RTSCED SUMMARY\r\n\r\n=========================================\r\n\r\n');
                end
                fprintf(fid,names_fields{i});
                fprintf(fid,'\r\n-----------------------------------------\r\n');
                for j=1:size(names.(sprintf('%s',names_fields{i})),1)
                    fprintf(fid,names.(sprintf('%s',names_fields{i})){j,:});
                    fprintf(fid,'\r\n');
                end
                fprintf(fid,'\r\n\r\n');
                fclose(fid);
                open_Option='a+';
                first_Write=0;
            end
        end
    else
        empty=empty+1;
    end
    if empty == 3
        warndlg('All models are empty!');
    else
        system(['start ',pwd,filesep,'TEMP',filesep,'GAMS_Summary_Temp.txt']);
    end
end

function load_gams_setup(~,~)
    [GamsFileName,GamsPathName,~] = uigetfile(['TEMP',filesep,'*.mat']);
    load_command=[GamsPathName,GamsFileName];
    evalin('base',['load(''',load_command,''')']);
    tgroup=evalin('base','tgroup');
    active_tab=get(tgroup,'SelectedTab');
    active_tab_name=active_tab.Title;
    if strcmp(active_tab_name,'DASCUC')
        try
            sectionName1=get(dac_modelinputLocationListBox,'value');
            sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
            temp3=sectionName2(sectionName1);
            gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
            tempNames=gamsFilesNames_DAC.(sprintf('%s',temp3{:}))(:);
            set(dac_list_of_selected_gams_rules,'string',tempNames);
            set(dac_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
        catch
            set(dac_list_of_selected_gams_rules,'string','');
        end
    elseif strcmp(active_tab_name,'RTSCUC')
        try
            sectionName1=get(rtc_modelinputLocationListBox,'value');
            sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
            temp3=sectionName2(sectionName1);
            gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
            tempNames=gamsFilesNames_RTC.(sprintf('%s',temp3{:}))(:);
            set(rtc_list_of_selected_gams_rules,'string',tempNames);
            set(rtc_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
        catch
            set(rtc_list_of_selected_gams_rules,'string','');
        end
    else
        try
            sectionName1=get(rtd_modelinputLocationListBox,'value');
            sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
            temp3=sectionName2(sectionName1);
            gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
            tempNames=gamsFilesNames_RTD.(sprintf('%s',temp3{:}))(:);
            set(rtd_list_of_selected_gams_rules,'string',tempNames);
            set(rtd_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
        catch
            set(rtd_list_of_selected_gams_rules,'string','');
        end
    end
end

function save_gams_setup(~,~)
    gamsFilesPaths_DAC=evalin('base','gamsFilesPaths_DAC');
    gamsFilesPaths_RTC=evalin('base','gamsFilesPaths_RTC');
    gamsFilesPaths_RTD=evalin('base','gamsFilesPaths_RTD');
    gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
    gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
    gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
    saveName=inputdlg('Input file name:','Save GAMS Setup');
    if ~isempty(saveName)
        save(['TEMP',filesep,cell2mat(saveName)],'gamsFilesPaths_DAC','gamsFilesPaths_RTC','gamsFilesPaths_RTD','gamsFilesNames_DAC','gamsFilesNames_RTC','gamsFilesNames_RTD');
    end
end

function browseforgamsfolder(~,~)
    dname = uigetdir(['MODEL_RULES',filesep]);
    assignin('base','gamsdname',dname);
    dtemp=dir([dname,filesep,'*.txt']);
    listOfFiles=cell(size(dtemp,1),1);
    for i=1:size(dtemp,1)
        listOfFiles{i}=dtemp(i,1).name;
    end
    set(dac_modelinputFolderEditBox,'string',dname);
    set(rtc_modelinputFolderEditBox,'string',dname);
    set(rtd_modelinputFolderEditBox,'string',dname);
    set(dac_list_of_gams_rules,'string',listOfFiles);
    set(rtc_list_of_gams_rules,'string',listOfFiles);
    set(rtd_list_of_gams_rules,'string',listOfFiles);
end

function add_dac_gams_rule(~,~)
    temp=get(dac_list_of_gams_rules,'value');
    temp2=get(dac_list_of_gams_rules,'string');
    dname=evalin('base','gamsdname');
    datatemp=get(dac_list_of_selected_gams_rules,'string');
    datatemp=[datatemp;temp2(temp,:)];
    set(dac_list_of_selected_gams_rules,'string',datatemp);
    fullpaths=strcat(repmat(dname,size(temp2,2),1),filesep,temp2(temp,:));
    sectionName1=get(dac_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    fullpaths_temp=gamsFilesPaths_DAC.(sprintf('%s',temp3{:}));
    fullpaths=[fullpaths_temp;fullpaths];
    gamsFilesPaths_DAC.(sprintf('%s',temp3{:}))=fullpaths;
    assignin('base','gamsFilesPaths_DAC',gamsFilesPaths_DAC);
    gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
    gamsFilesNames_DAC.(sprintf('%s',temp3{:}))=datatemp;
    assignin('base','gamsFilesNames_DAC',gamsFilesNames_DAC);
end

function remove_dac_gams_rule(~,~)
    temp=get(dac_list_of_selected_gams_rules,'value');
    temp2=get(dac_list_of_selected_gams_rules,'string');
    temp2(temp,:)=[];
    set(dac_list_of_selected_gams_rules,'string',temp2);
    sectionName1=get(dac_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    gamsFilesPaths_DAC=evalin('base','gamsFilesPaths_DAC');
    gamsFilesPaths_DAC.(sprintf('%s',temp3{:}))(temp,:)=[];
    assignin('base','gamsFilesPaths_DAC',gamsFilesPaths_DAC); 
    gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
    gamsFilesNames_DAC.(sprintf('%s',temp3{:}))=temp2;
    assignin('base','gamsFilesNames_DAC',gamsFilesNames_DAC);
    set(dac_list_of_selected_gams_rules,'value',max(1,temp-1));
end

function dacSectionChange(~,~)
    try
        sectionName1=get(dac_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
        tempNames=gamsFilesNames_DAC.(sprintf('%s',temp3{:}))(:);
        set(dac_list_of_selected_gams_rules,'string',tempNames);
        set(dac_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
        set(dac_list_of_selected_gams_rules,'string','');
    end
end

function dac_default_checked(~,~)
    gamsFilesNames_DAC.Header={'Base_DAC_Header.txt'};
    gamsFilesNames_DAC.User_Defined_1={};
    gamsFilesNames_DAC.Load_Inputs={'Base_DAC_Scalar_Declarations.txt';'Base_DAC_Set_Declarations.txt';'Base_DAC_Parameter_Declarations.txt';'Base_DAC_Table_Declarations.txt'};
    gamsFilesNames_DAC.User_Defined_2={};
    gamsFilesNames_DAC.Define_Inputs={'Base_DAC_Set_Definitions.txt';'Base_DAC_Parameter_Definitions.txt';'Base_DAC_Table_Definitions.txt'};
    gamsFilesNames_DAC.User_Defined_3={};
    gamsFilesNames_DAC.Manipulate_Inputs={'Base_DAC_Convert_To_PU.txt'};
    gamsFilesNames_DAC.User_Defined_4={};
    gamsFilesNames_DAC.Declare_Variables={'Base_DAC_Variable_Declarations.txt';'Base_DAC_Variable_Definitions.txt'};
    gamsFilesNames_DAC.User_Defined_5={};
    gamsFilesNames_DAC.Declare_Equations={'Base_DAC_Equation_Declarations.txt';'Base_DAC_Storage_Equation_Declarations.txt'};
    gamsFilesNames_DAC.User_Defined_6={};
    gamsFilesNames_DAC.Define_Constraints={'Base_DAC_Contingency_Equations.txt';
                                           'Base_DAC_Objective_Function.txt';
                                           'Base_DAC_Gen_Reserve_Capabilities_Equations.txt';
                                           'Base_DAC_Generator_Commitment_Equations.txt';
                                           'Base_DAC_Load_Flow_Equations.txt';
                                           'Base_DAC_Normal_Generator_Limits_Equations.txt';
                                           'Base_DAC_Phase_Shifter_Equations.txt';
                                           'Base_DAC_Storage_Commitment_Equations.txt';
                                           'Base_DAC_Storage_Efficiency_Equations.txt';
                                           'Base_DAC_Storage_Equations.txt';
                                           'Base_DAC_System_Equations.txt';
                                           'Base_DAC_Unconventional_Storage_Equations.txt';
                                           'Base_DAC_Variable_Startup_Equations.txt'};
    gamsFilesNames_DAC.User_Defined_7={};
    gamsFilesNames_DAC.Model_Definition={'Base_DAC_Model_Definition.txt'};
    gamsFilesNames_DAC.User_Defined_8={};
    gamsFilesNames_DAC.Solver_Options={'Base_DAC_Solver_Options.txt'};
    gamsFilesNames_DAC.User_Defined_9={};
    gamsFilesNames_DAC.Solve_Statement={'Base_DAC_Solve_Statement.txt'};
    gamsFilesNames_DAC.User_Defined_10={};
    gamsFilesNames_DAC.Post_Processing={'Base_DAC_Post_Processing.txt';'Base_DAC_Storage_Post_Processing.txt'};
    gamsFilesNames_DAC.User_Defined_11={};
    gamsFilesNames_DAC.Footer={'Base_DAC_Footer.txt'};

    gamsFilesPaths_DAC.Header={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Header.txt']};
    gamsFilesPaths_DAC.User_Defined_1={};
    gamsFilesPaths_DAC.Load_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Scalar_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Set_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Parameter_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Table_Declarations.txt']};
    gamsFilesPaths_DAC.User_Defined_2={};
    gamsFilesPaths_DAC.Define_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Set_Definitions.txt'];
                                      ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Parameter_Definitions.txt'];
                                      ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Table_Definitions.txt']};
    gamsFilesPaths_DAC.User_Defined_3={};
    gamsFilesPaths_DAC.Manipulate_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Convert_To_PU.txt']};
    gamsFilesPaths_DAC.User_Defined_4={};
    gamsFilesPaths_DAC.Declare_Variables={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Variable_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Variable_Definitions.txt']};
    gamsFilesPaths_DAC.User_Defined_5={};
    gamsFilesPaths_DAC.Declare_Equations={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Equation_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Storage_Equation_Declarations.txt']};
    gamsFilesPaths_DAC.User_Defined_6={};
    gamsFilesPaths_DAC.Define_Constraints={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Contingency_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Objective_Function.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Gen_Reserve_Capabilities_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Generator_Commitment_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Load_Flow_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Normal_Generator_Limits_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Phase_Shifter_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Storage_Commitment_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Storage_Efficiency_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Storage_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_System_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Unconventional_Storage_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Variable_Startup_Equations.txt']};
    gamsFilesPaths_DAC.User_Defined_7={};
    gamsFilesPaths_DAC.Model_Definition={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Model_Definition.txt']};
    gamsFilesPaths_DAC.User_Defined_8={};
    gamsFilesPaths_DAC.Solver_Options={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Solver_Options.txt']};
    gamsFilesPaths_DAC.User_Defined_9={};
    gamsFilesPaths_DAC.Solve_Statement={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Solve_Statement.txt']};
    gamsFilesPaths_DAC.User_Defined_10={};
    gamsFilesPaths_DAC.Post_Processing={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Post_Processing.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Storage_Post_Processing.txt']};
    gamsFilesPaths_DAC.User_Defined_11={};
    gamsFilesPaths_DAC.Footer={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_DAC_Files',filesep,'Base_DAC_Footer.txt']};
    assignin('base','gamsFilesNames_DAC',gamsFilesNames_DAC);
    assignin('base','gamsFilesPaths_DAC',gamsFilesPaths_DAC);
    try
        sectionName1=get(dac_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(dac_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
        tempNames=gamsFilesNames_DAC.(sprintf('%s',temp3{:}))(:);
        set(dac_list_of_selected_gams_rules,'string',tempNames);
        set(dac_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
    end
end

function rtc_default_checked(~,~)
    gamsFilesNames_RTC.Header={'Base_RTC_Header.txt'};
    gamsFilesNames_RTC.User_Defined_1={};
    gamsFilesNames_RTC.Load_Inputs={'Base_RTC_Scalar_Declarations.txt';'Base_RTC_Set_Declarations.txt';'Base_RTC_Parameter_Declarations.txt'};
    gamsFilesNames_RTC.User_Defined_2={};
    gamsFilesNames_RTC.Define_Inputs={'Base_RTC_Set_Definitions.txt';'Base_RTC_Parameter_Definitions.txt'};
    gamsFilesNames_RTC.User_Defined_3={};
    gamsFilesNames_RTC.Manipulate_Inputs={'Base_RTC_Convert_To_PU.txt'};
    gamsFilesNames_RTC.User_Defined_4={};
    gamsFilesNames_RTC.Declare_Variables={'Base_RTC_Variable_Declarations.txt';'Base_RTC_Variable_Definitions.txt'};
    gamsFilesNames_RTC.User_Defined_5={};
    gamsFilesNames_RTC.Declare_Equations={'Base_RTC_Equation_Declarations.txt';'Base_RTC_Storage_Equation_Declarations.txt'};
    gamsFilesNames_RTC.User_Defined_6={};
    gamsFilesNames_RTC.Define_Constraints={'Base_RTC_Contingency_Equations.txt';
                                           'Base_RTC_Objective_Function.txt';
                                           'Base_RTC_Gen_Reserve_Capabilities_Equations.txt';
                                           'Base_RTC_Generator_Commitment_Equations.txt';
                                           'Base_RTC_Load_Flow_Equations.txt';
                                           'Base_RTC_Normal_Generator_Limits_Equations.txt';
                                           'Base_RTC_Phase_Shifter_Equations.txt';
                                           'Base_RTC_Storage_Commitment_Equations.txt';
                                           'Base_RTC_Storage_Efficiency_Equations.txt';
                                           'Base_RTC_Storage_Equations.txt';
                                           'Base_RTC_System_Equations.txt';
                                           'Base_RTC_Interval_1_Equations.txt';
                                           'Base_RTC_SUSD_Trajectory_Equations.txt'};
    gamsFilesNames_RTC.User_Defined_7={};
    gamsFilesNames_RTC.Model_Definition={'Base_RTC_Model_Definition.txt'};
    gamsFilesNames_RTC.User_Defined_8={};
    gamsFilesNames_RTC.Solver_Options={'Base_RTC_Solver_Options.txt'};
    gamsFilesNames_RTC.User_Defined_9={};
    gamsFilesNames_RTC.Solve_Statement={'Base_RTC_Solve_Statement.txt'};
    gamsFilesNames_RTC.User_Defined_10={};
    gamsFilesNames_RTC.Post_Processing={'Base_RTC_Post_Processing.txt';'Base_RTC_Storage_Post_Processing.txt'};
    gamsFilesNames_RTC.User_Defined_11={};
    gamsFilesNames_RTC.Footer={'Base_RTC_Footer.txt'};

    gamsFilesPaths_RTC.Header={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Header.txt']};
    gamsFilesPaths_RTC.User_Defined_1={};
    gamsFilesPaths_RTC.Load_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Scalar_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Set_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Parameter_Declarations.txt']};
    gamsFilesPaths_RTC.User_Defined_2={};
    gamsFilesPaths_RTC.Define_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Set_Definitions.txt'];
                                      ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Parameter_Definitions.txt']};
    gamsFilesPaths_RTC.User_Defined_3={};
    gamsFilesPaths_RTC.Manipulate_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Convert_To_PU.txt']};
    gamsFilesPaths_RTC.User_Defined_4={};
    gamsFilesPaths_RTC.Declare_Variables={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Variable_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Variable_Definitions.txt']};
    gamsFilesPaths_RTC.User_Defined_5={};
    gamsFilesPaths_RTC.Declare_Equations={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Equation_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Storage_Equation_Declarations.txt']};
    gamsFilesPaths_RTC.User_Defined_6={};
    gamsFilesPaths_RTC.Define_Constraints={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Contingency_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Objective_Function.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Gen_Reserve_Capabilities_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Generator_Commitment_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Load_Flow_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Normal_Generator_Limits_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Phase_Shifter_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Storage_Commitment_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Storage_Efficiency_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Storage_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_System_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Interval_1_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_SUSD_Trajectory_Equations.txt']};
    gamsFilesPaths_RTC.User_Defined_7={};
    gamsFilesPaths_RTC.Model_Definition={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Model_Definition.txt']};
    gamsFilesPaths_RTC.User_Defined_8={};
    gamsFilesPaths_RTC.Solver_Options={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Solver_Options.txt']};
    gamsFilesPaths_RTC.User_Defined_9={};
    gamsFilesPaths_RTC.Solve_Statement={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Solve_Statement.txt']};
    gamsFilesPaths_RTC.User_Defined_10={};
    gamsFilesPaths_RTC.Post_Processing={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Post_Processing.txt']};
    gamsFilesPaths_RTC.User_Defined_11={};
    gamsFilesPaths_RTC.Footer={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTC_Files',filesep,'Base_RTC_Footer.txt']};
    assignin('base','gamsFilesNames_RTC',gamsFilesNames_RTC);
    assignin('base','gamsFilesPaths_RTC',gamsFilesPaths_RTC);
    try
        sectionName1=get(rtc_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
        tempNames=gamsFilesNames_RTC.(sprintf('%s',temp3{:}))(:);
        set(rtc_list_of_selected_gams_rules,'string',tempNames);
        set(rtc_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
    end
end

function add_rtc_gams_rule(~,~)
    temp=get(rtc_list_of_gams_rules,'value');
    temp2=get(rtc_list_of_gams_rules,'string');
    dname=evalin('base','gamsdname');
    datatemp=get(rtc_list_of_selected_gams_rules,'string');
    datatemp=[datatemp;temp2(temp,:)];
    set(rtc_list_of_selected_gams_rules,'string',datatemp);
    fullpaths=strcat(repmat(dname,size(temp2,2),1),filesep,temp2(temp,:));
    sectionName1=get(rtc_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    fullpaths_temp=gamsFilesPaths_RTC.(sprintf('%s',temp3{:}));
    fullpaths=[fullpaths_temp;fullpaths];
    gamsFilesPaths_RTC.(sprintf('%s',temp3{:}))=fullpaths;
    assignin('base','gamsFilesPaths_RTC',gamsFilesPaths_RTC);
    gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
    gamsFilesNames_RTC.(sprintf('%s',temp3{:}))=datatemp;
    assignin('base','gamsFilesNames_RTC',gamsFilesNames_RTC);
end

function remove_rtc_gams_rule(~,~)
    temp=get(rtc_list_of_selected_gams_rules,'value');
    temp2=get(rtc_list_of_selected_gams_rules,'string');
    temp2(temp,:)=[];
    set(rtc_list_of_selected_gams_rules,'string',temp2);
    sectionName1=get(rtc_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    gamsFilesPaths_RTC=evalin('base','gamsFilesPaths_RTC');
    gamsFilesPaths_RTC.(sprintf('%s',temp3{:}))(temp,:)=[];
    assignin('base','gamsFilesPaths_RTC',gamsFilesPaths_RTC); 
    gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
    gamsFilesNames_RTC.(sprintf('%s',temp3{:}))=temp2;
    assignin('base','gamsFilesNames_RTC',gamsFilesNames_RTC);
    set(rtc_list_of_selected_gams_rules,'value',max(1,temp-1));
end

function rtcSectionChange(~,~)
    try
        sectionName1=get(rtc_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(rtc_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
        tempNames=gamsFilesNames_RTC.(sprintf('%s',temp3{:}))(:);
        set(rtc_list_of_selected_gams_rules,'string',tempNames);
        set(rtc_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
        set(rtc_list_of_selected_gams_rules,'string','');
    end
end


function rtd_default_checked(~,~)
    gamsFilesNames_RTD.Header={'Base_RTD_Header.txt'};
    gamsFilesNames_RTD.User_Defined_1={};
    gamsFilesNames_RTD.Load_Inputs={'Base_RTD_Scalar_Declarations.txt';'Base_RTD_Set_Declarations.txt';'Base_RTD_Parameter_Declarations.txt'};
    gamsFilesNames_RTD.User_Defined_2={};
    gamsFilesNames_RTD.Define_Inputs={'Base_RTD_Set_Definitions.txt';'Base_RTD_Parameter_Definitions.txt'};
    gamsFilesNames_RTD.User_Defined_3={};
    gamsFilesNames_RTD.Manipulate_Inputs={'Base_RTD_Convert_To_PU.txt'};
    gamsFilesNames_RTD.User_Defined_4={};
    gamsFilesNames_RTD.Declare_Variables={'Base_RTD_Variable_Declarations.txt';'Base_RTD_Variable_Definitions.txt'};
    gamsFilesNames_RTD.User_Defined_5={};
    gamsFilesNames_RTD.Declare_Equations={'Base_RTD_Equation_Declarations.txt';'Base_RTD_Storage_Equation_Declarations.txt'};
    gamsFilesNames_RTD.User_Defined_6={};
    gamsFilesNames_RTD.Define_Constraints={'Base_RTD_Contingency_Equations.txt';
                                           'Base_RTD_Objective_Function.txt';
                                           'Base_RTD_Gen_Reserve_Capabilities_Equations.txt';
                                           'Base_RTD_Load_Flow_Equations.txt';
                                           'Base_RTD_Normal_Generator_Limits_Equations.txt';
                                           'Base_RTD_Phase_Shifter_Equations.txt';
                                           'Base_RTD_Storage_Equations.txt';
                                           'Base_RTD_System_Equations.txt';
                                           'Base_RTD_Interval_1_Equations.txt'};
    gamsFilesNames_RTD.User_Defined_7={};
    gamsFilesNames_RTD.Model_Definition={'Base_RTD_Model_Definition.txt'};
    gamsFilesNames_RTD.User_Defined_8={};
    gamsFilesNames_RTD.Solver_Options={'Base_RTD_Solver_Options.txt'};
    gamsFilesNames_RTD.User_Defined_9={};
    gamsFilesNames_RTD.Solve_Statement={'Base_RTD_Solve_Statement.txt'};
    gamsFilesNames_RTD.User_Defined_10={};
    gamsFilesNames_RTD.Post_Processing={'Base_RTD_Post_Processing.txt';'Base_RTD_Storage_Post_Processing.txt'};
    gamsFilesNames_RTD.User_Defined_11={};
    gamsFilesNames_RTD.Footer={'Base_RTD_Footer.txt'};

    gamsFilesPaths_RTD.Header={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Header.txt']};
    gamsFilesPaths_RTD.User_Defined_1={};
    gamsFilesPaths_RTD.Load_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Scalar_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Set_Declarations.txt'];
                                    ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Parameter_Declarations.txt']};
    gamsFilesPaths_RTD.User_Defined_2={};
    gamsFilesPaths_RTD.Define_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Set_Definitions.txt'];
                                      ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Parameter_Definitions.txt']};
    gamsFilesPaths_RTD.User_Defined_3={};
    gamsFilesPaths_RTD.Manipulate_Inputs={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Convert_To_PU.txt']};
    gamsFilesPaths_RTD.User_Defined_4={};
    gamsFilesPaths_RTD.Declare_Variables={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Variable_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Variable_Definitions.txt']};
    gamsFilesPaths_RTD.User_Defined_5={};
    gamsFilesPaths_RTD.Declare_Equations={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Equation_Declarations.txt'];['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Storage_Equation_Declarations.txt']};
    gamsFilesPaths_RTD.User_Defined_6={};
    gamsFilesPaths_RTD.Define_Constraints={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Contingency_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Objective_Function.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Generator_Reserve_Capabilities_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Load_Flow_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Normal_Generator_Limits_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Phase_Shifter_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Storage_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_System_Equations.txt'];
                                           ['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Interval_1_Equations.txt']};
    gamsFilesPaths_RTD.User_Defined_7={};
    gamsFilesPaths_RTD.Model_Definition={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Model_Definition.txt']};
    gamsFilesPaths_RTD.User_Defined_8={};
    gamsFilesPaths_RTD.Solver_Options={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Solver_Options.txt']};
    gamsFilesPaths_RTD.User_Defined_9={};
    gamsFilesPaths_RTD.Solve_Statement={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Solve_Statement.txt']};
    gamsFilesPaths_RTD.User_Defined_10={};
    gamsFilesPaths_RTD.Post_Processing={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Post_Processing.txt']};
    gamsFilesPaths_RTD.User_Defined_11={};
    gamsFilesPaths_RTD.Footer={['MODEL_RULES',filesep,'GAMS_Model_Files',filesep,'Base_RTD_Files',filesep,'Base_RTD_Footer.txt']};
    assignin('base','gamsFilesNames_RTD',gamsFilesNames_RTD);
    assignin('base','gamsFilesPaths_RTD',gamsFilesPaths_RTD);
    try
        sectionName1=get(rtd_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
        tempNames=gamsFilesNames_RTD.(sprintf('%s',temp3{:}))(:);
        set(rtd_list_of_selected_gams_rules,'string',tempNames);
        set(rtd_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
    end
end

function add_rtd_gams_rule(~,~)
    temp=get(rtd_list_of_gams_rules,'value');
    temp2=get(rtd_list_of_gams_rules,'string');
    dname=evalin('base','gamsdname');
    datatemp=get(rtd_list_of_selected_gams_rules,'string');
    datatemp=[datatemp;temp2(temp,:)];
    set(rtd_list_of_selected_gams_rules,'string',datatemp);
    fullpaths=strcat(repmat(dname,size(temp2,2),1),filesep,temp2(temp,:));
    sectionName1=get(rtd_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    fullpaths_temp=gamsFilesPaths_RTD.(sprintf('%s',temp3{:}));
    fullpaths=[fullpaths_temp;fullpaths];
    gamsFilesPaths_RTD.(sprintf('%s',temp3{:}))=fullpaths;
    assignin('base','gamsFilesPaths_RTD',gamsFilesPaths_RTD);
    gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
    gamsFilesNames_RTD.(sprintf('%s',temp3{:}))=datatemp;
    assignin('base','gamsFilesNames_RTD',gamsFilesNames_RTD);
end

function remove_rtd_gams_rule(~,~)
    temp=get(rtd_list_of_selected_gams_rules,'value');
    temp2=get(rtd_list_of_selected_gams_rules,'string');
    temp2(temp,:)=[];
    set(rtd_list_of_selected_gams_rules,'string',temp2);
    sectionName1=get(rtd_modelinputLocationListBox,'value');
    sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
    temp3=sectionName2(sectionName1);
    gamsFilesPaths_RTD=evalin('base','gamsFilesPaths_RTD');
    gamsFilesPaths_RTD.(sprintf('%s',temp3{:}))(temp,:)=[];
    assignin('base','gamsFilesPaths_RTD',gamsFilesPaths_RTD); 
    gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
    gamsFilesNames_RTD.(sprintf('%s',temp3{:}))=temp2;
    assignin('base','gamsFilesNames_RTD',gamsFilesNames_RTD);
    set(rtd_list_of_selected_gams_rules,'value',max(1,temp-1));
end

function rtdSectionChange(~,~)
    try
        sectionName1=get(rtd_modelinputLocationListBox,'value');
        sectionName2=cellstr(get(rtd_modelinputLocationListBox,'string'));
        temp3=sectionName2(sectionName1);
        gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
        tempNames=gamsFilesNames_RTD.(sprintf('%s',temp3{:}))(:);
        set(rtd_list_of_selected_gams_rules,'string',tempNames);
        set(rtd_list_of_selected_gams_rules,'value',max(1,size(tempNames,1)));
    catch
        set(rtd_list_of_selected_gams_rules,'string','');
    end
end

function clear_dac_gams(~,~)
    gamsFilesNames_DAC=evalin('base','gamsFilesNames_DAC');
    gamsFilesNames_DAC.Header={};gamsFilesNames_DAC.User_Defined_1={};
    gamsFilesNames_DAC.Load_Inputs={};gamsFilesNames_DAC.User_Defined_2={};
    gamsFilesNames_DAC.Define_Inputs={};gamsFilesNames_DAC.User_Defined_3={};
    gamsFilesNames_DAC.Manipulate_Inputs={};gamsFilesNames_DAC.User_Defined_4={};
    gamsFilesNames_DAC.Declare_Variables={};gamsFilesNames_DAC.User_Defined_5={};
    gamsFilesNames_DAC.Declare_Equations={};gamsFilesNames_DAC.User_Defined_6={};
    gamsFilesNames_DAC.Define_Constraints={};gamsFilesNames_DAC.User_Defined_7={};
    gamsFilesNames_DAC.Model_Definition={};gamsFilesNames_DAC.User_Defined_8={};
    gamsFilesNames_DAC.Solver_Options={};gamsFilesNames_DAC.User_Defined_9={};
    gamsFilesNames_DAC.Solve_Statement={};gamsFilesNames_DAC.User_Defined_10={};
    gamsFilesNames_DAC.Post_Processing={};gamsFilesNames_DAC.User_Defined_11={};
    gamsFilesNames_DAC.Footer={};
    gamsFilesPaths_DAC.Header={};gamsFilesPaths_DAC.User_Defined_1={};
    gamsFilesPaths_DAC.Load_Inputs={};gamsFilesPaths_DAC.User_Defined_2={};
    gamsFilesPaths_DAC.Define_Inputs={};gamsFilesPaths_DAC.User_Defined_3={};
    gamsFilesPaths_DAC.Manipulate_Inputs={};gamsFilesPaths_DAC.User_Defined_4={};
    gamsFilesPaths_DAC.Declare_Variables={};gamsFilesPaths_DAC.User_Defined_5={};
    gamsFilesPaths_DAC.Declare_Equations={};gamsFilesPaths_DAC.User_Defined_6={};
    gamsFilesPaths_DAC.Define_Constraints={};gamsFilesPaths_DAC.User_Defined_7={};
    gamsFilesPaths_DAC.Model_Definition={};gamsFilesPaths_DAC.User_Defined_8={};
    gamsFilesPaths_DAC.Solver_Options={};gamsFilesPaths_DAC.User_Defined_9={};
    gamsFilesPaths_DAC.Solve_Statement={};gamsFilesPaths_DAC.User_Defined_10={};
    gamsFilesPaths_DAC.Post_Processing={};gamsFilesPaths_DAC.User_Defined_11={};
    gamsFilesPaths_DAC.Footer={};
    assignin('base','gamsFilesNames_DAC',gamsFilesNames_DAC);
    dacSectionChange();
end

function clear_rtc_gams(~,~)
    gamsFilesNames_RTC=evalin('base','gamsFilesNames_RTC');
    gamsFilesNames_RTC.Header={};gamsFilesNames_RTC.User_Defined_1={};
    gamsFilesNames_RTC.Load_Inputs={};gamsFilesNames_RTC.User_Defined_2={};
    gamsFilesNames_RTC.Define_Inputs={};gamsFilesNames_RTC.User_Defined_3={};
    gamsFilesNames_RTC.Manipulate_Inputs={};gamsFilesNames_RTC.User_Defined_4={};
    gamsFilesNames_RTC.Declare_Variables={};gamsFilesNames_RTC.User_Defined_5={};
    gamsFilesNames_RTC.Declare_Equations={};gamsFilesNames_RTC.User_Defined_6={};
    gamsFilesNames_RTC.Define_Constraints={};gamsFilesNames_RTC.User_Defined_7={};
    gamsFilesNames_RTC.Model_Definition={};gamsFilesNames_RTC.User_Defined_8={};
    gamsFilesNames_RTC.Solver_Options={};gamsFilesNames_RTC.User_Defined_9={};
    gamsFilesNames_RTC.Solve_Statement={};gamsFilesNames_RTC.User_Defined_10={};
    gamsFilesNames_RTC.Post_Processing={};gamsFilesNames_RTC.User_Defined_11={};
    gamsFilesNames_RTC.Footer={};
    gamsFilesPaths_RTC.Header={};gamsFilesPaths_RTC.User_Defined_1={};
    gamsFilesPaths_RTC.Load_Inputs={};gamsFilesPaths_RTC.User_Defined_2={};
    gamsFilesPaths_RTC.Define_Inputs={};gamsFilesPaths_RTC.User_Defined_3={};
    gamsFilesPaths_RTC.Manipulate_Inputs={};gamsFilesPaths_RTC.User_Defined_4={};
    gamsFilesPaths_RTC.Declare_Variables={};gamsFilesPaths_RTC.User_Defined_5={};
    gamsFilesPaths_RTC.Declare_Equations={};gamsFilesPaths_RTC.User_Defined_6={};
    gamsFilesPaths_RTC.Define_Constraints={};gamsFilesPaths_RTC.User_Defined_7={};
    gamsFilesPaths_RTC.Model_Definition={};gamsFilesPaths_RTC.User_Defined_8={};
    gamsFilesPaths_RTC.Solver_Options={};gamsFilesPaths_RTC.User_Defined_9={};
    gamsFilesPaths_RTC.Solve_Statement={};gamsFilesPaths_RTC.User_Defined_10={};
    gamsFilesPaths_RTC.Post_Processing={};gamsFilesPaths_RTC.User_Defined_11={};
    gamsFilesPaths_RTC.Footer={};
    assignin('base','gamsFilesNames_RTC',gamsFilesNames_RTC);
    rtcSectionChange();
end

function clear_rtd_gams(~,~)
    gamsFilesNames_RTD=evalin('base','gamsFilesNames_RTD');
    gamsFilesNames_RTD.Header={};gamsFilesNames_RTD.User_Defined_1={};
    gamsFilesNames_RTD.Load_Inputs={};gamsFilesNames_RTD.User_Defined_2={};
    gamsFilesNames_RTD.Define_Inputs={};gamsFilesNames_RTD.User_Defined_3={};
    gamsFilesNames_RTD.Manipulate_Inputs={};gamsFilesNames_RTD.User_Defined_4={};
    gamsFilesNames_RTD.Declare_Variables={};gamsFilesNames_RTD.User_Defined_5={};
    gamsFilesNames_RTD.Declare_Equations={};gamsFilesNames_RTD.User_Defined_6={};
    gamsFilesNames_RTD.Define_Constraints={};gamsFilesNames_RTD.User_Defined_7={};
    gamsFilesNames_RTD.Model_Definition={};gamsFilesNames_RTD.User_Defined_8={};
    gamsFilesNames_RTD.Solver_Options={};gamsFilesNames_RTD.User_Defined_9={};
    gamsFilesNames_RTD.Solve_Statement={};gamsFilesNames_RTD.User_Defined_10={};
    gamsFilesNames_RTD.Post_Processing={};gamsFilesNames_RTD.User_Defined_11={};
    gamsFilesNames_RTD.Footer={};
    gamsFilesPaths_RTD.Header={};gamsFilesPaths_RTD.User_Defined_1={};
    gamsFilesPaths_RTD.Load_Inputs={};gamsFilesPaths_RTD.User_Defined_2={};
    gamsFilesPaths_RTD.Define_Inputs={};gamsFilesPaths_RTD.User_Defined_3={};
    gamsFilesPaths_RTD.Manipulate_Inputs={};gamsFilesPaths_RTD.User_Defined_4={};
    gamsFilesPaths_RTD.Declare_Variables={};gamsFilesPaths_RTD.User_Defined_5={};
    gamsFilesPaths_RTD.Declare_Equations={};gamsFilesPaths_RTD.User_Defined_6={};
    gamsFilesPaths_RTD.Define_Constraints={};gamsFilesPaths_RTD.User_Defined_7={};
    gamsFilesPaths_RTD.Model_Definition={};gamsFilesPaths_RTD.User_Defined_8={};
    gamsFilesPaths_RTD.Solver_Options={};gamsFilesPaths_RTD.User_Defined_9={};
    gamsFilesPaths_RTD.Solve_Statement={};gamsFilesPaths_RTD.User_Defined_10={};
    gamsFilesPaths_RTD.Post_Processing={};gamsFilesPaths_RTD.User_Defined_11={};
    gamsFilesPaths_RTD.Footer={};
    assignin('base','gamsFilesNames_RTD',gamsFilesNames_RTD);
    rtdSectionChange();
end

function save_rules_callback(~,~)
    RPU_RULES_PRE_in=evalin('base','RPU_RULES_PRE_in');
    RPU_RULES_POST_in=evalin('base','RPU_RULES_POST_in');
    AGC_RULES_PRE_in=evalin('base','AGC_RULES_PRE_in');
    AGC_RULES_POST_in=evalin('base','AGC_RULES_POST_in');
    RTSCED_RULES_PRE_in=evalin('base','RTSCED_RULES_PRE_in');
    RTSCED_RULES_POST_in=evalin('base','RTSCED_RULES_POST_in');
    RTSCUC_RULES_PRE_in=evalin('base','RTSCUC_RULES_PRE_in');
    RTSCUC_RULES_POST_in=evalin('base','RTSCUC_RULES_POST_in');
    DASCUC_RULES_PRE_in=evalin('base','DASCUC_RULES_PRE_in');
    DASCUC_RULES_POST_in=evalin('base','DASCUC_RULES_POST_in');
    DATA_INITIALIZE_PRE_in=evalin('base','DATA_INITIALIZE_PRE_in');
    DATA_INITIALIZE_POST_in=evalin('base','DATA_INITIALIZE_POST_in');
    FORECASTING_PRE_in=evalin('base','FORECASTING_PRE_in');
    FORECASTING_POST_in=evalin('base','FORECASTING_POST_in');
    RT_LOOP_PRE_in=evalin('base','RT_LOOP_PRE_in');
    RT_LOOP_POST_in=evalin('base','RT_LOOP_POST_in');
    POST_PROCESSING_PRE_in=evalin('base','POST_PROCESSING_PRE_in');
    POST_PROCESSING_POST_in=evalin('base','POST_PROCESSING_POST_in');
    ACE_PRE_in=evalin('base','ACE_PRE_in');
    ACE_POST_in=evalin('base','ACE_POST_in');
    FORCED_OUTAGE_PRE_in=evalin('base','FORCED_OUTAGE_PRE_in');
    FORCED_OUTAGE_POST_in=evalin('base','FORCED_OUTAGE_POST_in');
    SHIFT_FACTOR_PRE_in=evalin('base','SHIFT_FACTOR_PRE_in');
    SHIFT_FACTOR_POST_in=evalin('base','SHIFT_FACTOR_POST_in');
    ACTUAL_OUTPUT_PRE_in=evalin('base','ACTUAL_OUTPUT_PRE_in');
    ACTUAL_OUTPUT_POST_in=evalin('base','ACTUAL_OUTPUT_POST_in');
    RELIABILITY_PRE_in=evalin('base','RELIABILITY_PRE_in');
    RELIABILITY_POST_in=evalin('base','RELIABILITY_POST_in');
    COST_PRE_in=evalin('base','COST_PRE_in');
    COST_POST_in=evalin('base','COST_POST_in');
    SAVING_PRE_in=evalin('base','SAVING_PRE_in');
    SAVING_POST_in=evalin('base','SAVING_POST_in');
    answer = inputdlg('Save name:');
    save(cell2mat(['TEMP',filesep,answer]),...        
    'RPU_RULES_PRE_in','RPU_RULES_POST_in','AGC_RULES_PRE_in','AGC_RULES_POST_in',...
    'RTSCED_RULES_PRE_in','RTSCED_RULES_POST_in','RTSCUC_RULES_PRE_in','RTSCUC_RULES_POST_in',...
    'DASCUC_RULES_PRE_in','DASCUC_RULES_POST_in','DATA_INITIALIZE_PRE_in','DATA_INITIALIZE_POST_in',...
    'FORECASTING_PRE_in','FORECASTING_POST_in','RT_LOOP_PRE_in','RT_LOOP_POST_in','POST_PROCESSING_PRE_in',...
    'POST_PROCESSING_POST_in','ACE_PRE_in','ACE_POST_in','FORCED_OUTAGE_PRE_in','FORCED_OUTAGE_POST_in',...
    'SHIFT_FACTOR_PRE_in','SHIFT_FACTOR_POST_in','ACTUAL_OUTPUT_PRE_in','ACTUAL_OUTPUT_POST_in',...
    'RELIABILITY_PRE_in','RELIABILITY_POST_in','COST_PRE_in','COST_POST_in','SAVING_PRE_in','SAVING_POST_in');
end

function load_rules_callback(~,~)
    RPU_RULES_PRE_in=[];RPU_RULES_POST_in=[];AGC_RULES_PRE_in=[];AGC_RULES_POST_in=[];
    RTSCED_RULES_PRE_in=[];RTSCED_RULES_POST_in=[];RTSCUC_RULES_PRE_in=[];RTSCUC_RULES_POST_in=[];
    DASCUC_RULES_PRE_in=[];DASCUC_RULES_POST_in=[];DATA_INITIALIZE_PRE_in=[];DATA_INITIALIZE_POST_in=[];
    FORECASTING_PRE_in=[];FORECASTING_POST_in=[];RT_LOOP_PRE_in=[];RT_LOOP_POST_in=[];
    POST_PROCESSING_PRE_in=[];POST_PROCESSING_POST_in=[];ACE_PRE_in=[];ACE_POST_in=[];
    FORCED_OUTAGE_PRE_in=[];FORCED_OUTAGE_POST_in=[];SHIFT_FACTOR_PRE_in=[];SHIFT_FACTOR_POST_in=[];
    ACTUAL_OUTPUT_PRE_in=[];ACTUAL_OUTPUT_POST_in=[];RELIABILITY_PRE_in=[];RELIABILITY_POST_in=[];
    COST_PRE_in=[];COST_POST_in=[];SAVING_PRE_in=[];SAVING_POST_in=[];
    [RulesFileName,RulesPathName,~] = uigetfile(['TEMP',filesep,'*.mat']);
    load_command=[RulesPathName,RulesFileName];
    temp=load(load_command,...        
    'RPU_RULES_PRE_in','RPU_RULES_POST_in','AGC_RULES_PRE_in','AGC_RULES_POST_in',...
    'RTSCED_RULES_PRE_in','RTSCED_RULES_POST_in','RTSCUC_RULES_PRE_in','RTSCUC_RULES_POST_in',...
    'DASCUC_RULES_PRE_in','DASCUC_RULES_POST_in','DATA_INITIALIZE_PRE_in','DATA_INITIALIZE_POST_in',...
    'FORECASTING_PRE_in','FORECASTING_POST_in','RT_LOOP_PRE_in','RT_LOOP_POST_in','POST_PROCESSING_PRE_in',...
    'POST_PROCESSING_POST_in','ACE_PRE_in','ACE_POST_in','FORCED_OUTAGE_PRE_in','FORCED_OUTAGE_POST_in',...
    'SHIFT_FACTOR_PRE_in','SHIFT_FACTOR_POST_in','ACTUAL_OUTPUT_PRE_in','ACTUAL_OUTPUT_POST_in',...
    'RELIABILITY_PRE_in','RELIABILITY_POST_in','COST_PRE_in','COST_POST_in','SAVING_PRE_in','SAVING_POST_in');
    x=fieldnames(temp);
    for i=1:size(x,1)
        if ~isempty(temp.(sprintf('%s',x{i,1})))
            eval_command_1=sprintf('%s=evalin(''base'',''%s'');',x{i,1},x{i,1});
            eval_command_2=sprintf('%s=[%s;temp.%s];',x{i,1},x{i,1},x{i,1});
            eval_command_3=sprintf('%s=unique(%s);',x{i,1},x{i,1});
            eval(eval_command_1);eval(eval_command_2);eval(eval_command_3);
        end
    end
    assignin('base','RPU_RULES_PRE_in',RPU_RULES_PRE_in);
    assignin('base','RPU_RULES_POST_in',RPU_RULES_POST_in);
    assignin('base','AGC_RULES_PRE_in',AGC_RULES_PRE_in);
    assignin('base','AGC_RULES_POST_in',AGC_RULES_POST_in);
    assignin('base','RTSCED_RULES_PRE_in',RTSCED_RULES_PRE_in);
    assignin('base','RTSCED_RULES_POST_in',RTSCED_RULES_POST_in);
    assignin('base','RTSCUC_RULES_PRE_in',RTSCUC_RULES_PRE_in);
    assignin('base','RTSCUC_RULES_POST_in',RTSCUC_RULES_POST_in);
    assignin('base','DASCUC_RULES_PRE_in',DASCUC_RULES_PRE_in);
    assignin('base','DASCUC_RULES_POST_in',DASCUC_RULES_POST_in);
    assignin('base','DATA_INITIALIZE_PRE_in',DATA_INITIALIZE_PRE_in);
    assignin('base','DATA_INITIALIZE_POST_in',DATA_INITIALIZE_POST_in);
    assignin('base','FORECASTING_PRE_in',FORECASTING_PRE_in);
    assignin('base','FORECASTING_POST_in',FORECASTING_POST_in);
    assignin('base','RT_LOOP_PRE_in',RT_LOOP_PRE_in);
    assignin('base','RT_LOOP_POST_in',RT_LOOP_POST_in);
    assignin('base','POST_PROCESSING_PRE_in',POST_PROCESSING_PRE_in);
    assignin('base','POST_PROCESSING_POST_in',POST_PROCESSING_POST_in);
    assignin('base','ACE_PRE_in',ACE_PRE_in);
    assignin('base','ACE_POST_in',ACE_POST_in);
    assignin('base','FORCED_OUTAGE_PRE_in',FORCED_OUTAGE_PRE_in);
    assignin('base','FORCED_OUTAGE_POST_in',FORCED_OUTAGE_POST_in);
    assignin('base','SHIFT_FACTOR_PRE_in',SHIFT_FACTOR_PRE_in);
    assignin('base','SHIFT_FACTOR_POST_in',SHIFT_FACTOR_POST_in);
    assignin('base','ACTUAL_OUTPUT_PRE_in',ACTUAL_OUTPUT_PRE_in);
    assignin('base','ACTUAL_OUTPUT_POST_in',ACTUAL_OUTPUT_POST_in);
    assignin('base','RELIABILITY_PRE_in',RELIABILITY_PRE_in);
    assignin('base','RELIABILITY_POST_in',RELIABILITY_POST_in);
    assignin('base','COST_PRE_in',COST_PRE_in);
    assignin('base','COST_POST_in',COST_POST_in);
    assignin('base','SAVING_PRE_in',SAVING_PRE_in);
    assignin('base','SAVING_POST_in',SAVING_POST_in);
end


end
