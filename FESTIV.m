%% FESTIV
%
% Flexible Energy Scheduling Tool for Integration of Variable generation
% 
% FESTIV is a steady-state power system operations tool that covers 
% temporal horizons in the scheduling process starting from the day-ahead
% unit commitment all the way through automatic generation control to
% correct the actual area control error occuring every few seconds.
%
% The FESTIV GUI will open and ask for necessary input files and input
% parameters. You can add FESTIV Model Rules using Matlab scripts and add
% them to various points throughout FESTIV by selecting the scripts in the
% GUI for appropriate spots (either scheduling processes or "Other Rules").
% Or you can load a whole set of models that were previously saved to
% represent a certain operational procedure in its entirety.
% Formulations can be modified by adding new .txt files, making sure sets,
% parameters, variables, and equations are declared and defined, and the
% model definition is updated. Create the .txt files and then press 'Opt.
% Model' on the GUI to make sure the FESTIV simulation uses them correctly
% for the appropriate scheduling model.
%
% For more information, see <a href="matlab: 
% web('http://www.nrel.gov/electricity/transmission/festiv.html')">the FESTIV homepage</a>.
% or review the FESTIV user manual.
%
% To get started, just type 'FESTIV' in command window.
% To start from the middle of a previous execution that did not finish,
% type 'Start_FESTIV_From_Previous_Execution'.



%% midexecution
%start_execution is a rarely used feature to continue a FESTIV run from
%where it has just previously stopped. Users would run
%'Start_FESTIV_From_Previous_Execution.m' rather than 'FESTIV.m'

tmp_string = dbstack;
starting_execution_script = tmp_string(end).name;
if exist('execution_from_previous','var')==0 || strcmp(starting_execution_script,'FESTIV')
    execution_from_previous=0;
end;
if execution_from_previous 
    if (mod(time*60,tRTC) - 0 < eps) || (tRTC - mod(time*60,tRTC) < eps)
        RTSCUC_binding_interval_index = RTSCUC_binding_interval_index - 1;
    end;
else
    
clear;
execution_from_previous=0;

%% Detect Hardware 

DETECT_HARDWARE_OPTIONS;

%% Input Prompt
%if system allows, run GUI for user input. If not, user would have already
%loaded information into tempws workspace.
try load tempws;catch;end;
if feature('ShowFigureWindows') && use_gui
cancel=1;
FESTIV_GUI 
uiwait(gcf)
pause on
pause(0.1)
pause off
else
cancel=0;
end

finishedrunningFESTIV=0;
numberofFESTIVrun=1;
end;

while(finishedrunningFESTIV ~= 1)
if cancel==0 
if execution_from_previous==0 || time==start_time    
    
    tStart = tic;
    festivBanner; 
    
%% Data and Initialization

    %Load in data for new FESTIV run if using multiple runs.
    qq=strcat('tempws',num2str(numberofFESTIVrun));
    if exist('multiplefilecheck')==1
        if multiplefilecheck == 0
        else
            load(qq);
            inputPath=completeinputpathname;      
        end
    end
    
    %Make sure gams path is added for gams to work in calls.
    gamspath=getgamspath();
    if not(isempty(gamspath))
        addpath(gamspath); 
    end

    for x=1:size(DATA_INITIALIZE_PRE_in,1)
        try run(DATA_INITIALIZE_PRE_in{x,1});catch;end; 
    end;

    %Gather in the information provided as part of the GUI inputs
    INITIALIZE_VARIABLES_FROM_GUI_INPUTS
    
    %Set indices based on how user input file is listed
    DECLARE_INDICES
    
    %Gather inputs from main input file
    READ_IN_SYSTEM_DATA_FROM_EXCEL
    
    %Validate across input tabs for several places to make sure data is complete.
    INPUT_FILE_VALIDATION

    for x=1:size(DATA_INITIALIZE_POST_in,1)
        try run(DATA_INITIALIZE_POST_in{x,1});catch;end; 
    end;
    
    for x=1:size(FORECASTING_PRE_in,1)
        try run(FORECASTING_PRE_in{x,1});catch;end; 
    end;

    READ_IN_TIMESERIES_DATA;
    
    for x=1:size(FORECASTING_POST_in,1)
        try run(FORECASTING_POST_in{x,1});catch;end; 
    end;
    
    FORECAST_DATA_SIZE;
    
    for x=1:size(SHIFT_FACTOR_PRE_in,1)
        try run(SHIFT_FACTOR_PRE_in{x,1});catch;end;
    end;

    CREATE_SHIFT_FACTORS

    for x=1:size(SHIFT_FACTOR_POST_in,1)
        try run(SHIFT_FACTOR_POST_in{x,1});catch;end;
    end;
    
    %Whether to use the default GAMS models or something else. Users can modify this file.
    FESTIV_Addl_Scheduling_Options
    
    %Initialize variables with zeros and others that need initialization before simulations start
    INITIALIZE_VARIABLES_FOR_RT

    Solving_Initial_Models = 1;


    %% Initial Day-Ahead SCUC

    tNow = toc(tStart);
    fprintf('Complete! (%02.0f min, %05.2f s)\n',floor(tNow/60),rem(tNow,60));
    fprintf('Modeling Initial Day-Ahead Unit Commitment...')

    dascuc_running = 1;
    
    %Gather in Default data before starting
    Gather_DEFAULT_DATA
    
    %TIMESTAMP
    DAC_LOOKAHEAD_INTERVAL_VAL = DAC_LOAD_FULL(1:HDAC,2)*24; %time must be converted to hours instead of days

    %Gather LOAD Forecasts
    LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(DAC_LOAD_FULL,DASCUC_binding_interval_index,HDAC);
    
    %Gather VG Forecasts
    VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(DAC_VG_FULL,DAC_VG_FIELD,DASCUC_binding_interval_index,HDAC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(DAC_RESERVE_FULL,DASCUC_binding_interval_index,HDAC);

    %Gather INTERCHANGE schedules
    INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(DAC_INTERCHANGE_FULL,DASCUC_binding_interval_index,HDAC);
    
    %Enforce commitments on or off in still in min run time or min down
    %time at start of horizon
    Gather_UC_Enforcement_Input_for_DASCUC;
    
    %Gather startup and shutdown period parameters
    Gather_SU_Parameters_Input_for_DASCUC;
    
    %initialize delivery factors from initial schedules and loss bias
    Gather_Initial_DELIVERY_FACTORS_Input_for_DASCUC;
    Gather_LOSS_BIAS_Input_for_DASCUC;
    
    %QSC for offline reserve
    Gather_QSC_Input_for_DASCUC;
    
    %whether unit forced off
    Gather_GEN_FORCED_OUT_Input_for_DASCUC;

    for x=1:size(DASCUC_RULES_PRE_in,1)
        try run(DASCUC_RULES_PRE_in{x,1});catch;end;
    end;

    if strcmp(use_Default_DASCUC,'YES')

        RUN_DASCUC;
        
    end

    try
    DAModelSolutionStatus=[];
    DAModelSolutionStatus=[0 modelSolveStatus numberOfInfes solverStatus relativeGap];
    catch
    end;
    for x=1:size(DASCUC_RULES_POST_in,1)
        try run(DASCUC_RULES_POST_in{x,1});catch;end;
    end;

    marginalLoss=(sum(SCUCGENSCHEDULE.val)'-sum(SCUCPUMPSCHEDULE.val)'-LOAD_VAL+SCUCLOSSLOAD.val-LOSS_BIAS.val.*ones(HDAC,1))./SYSTEMVALUE_VAL(mva_pu);
    
    Save_Needed_DASCUC_Results
    
    Assign_DASCUC_Commitment_to_STATUS

    dascuc_running = 0;
    DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;


    %% Initial Real-Time SCUC
    %{
    RTC for the very first interval
    This interval is used just to set up the intiial conditions.
    %}

    tNow = toc(tStart);
    fprintf('Complete!\n');
    fprintf('Modeling Initial Real-Time Unit Commitment...')

    rtscuc_running = 1;
    
    %Gather in Default data before starting
    Gather_DEFAULT_DATA

    %TIMESTAMP
    RTC_LOOKAHEAD_INTERVAL_VAL = RTC_LOAD_FULL(1:HRTC,2)*24; %time must be converted to hours instead of days

    %Gather LOAD Forecasts
    LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(RTC_LOAD_FULL,RTSCUC_binding_interval_index,HRTC);

    %Gather VG Forecasts
    VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(RTC_VG_FULL,RTC_VG_FIELD,RTSCUC_binding_interval_index,HRTC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(RTC_RESERVE_FULL,RTSCUC_binding_interval_index,HRTC);

    %Gather INTERCHANGE schedules
    INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(RTC_INTERCHANGE_FULL,RTSCUC_binding_interval_index,HRTC);

    rtscucinterval_index = round(time*rtscuc_I_perhour) + 1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!

    %Setting up the hard commitment constraints for nonquickstarts and other units.
    RTSCUCSTART_MODE = RTSCUCSTART_MODE_RTC;
    RTSCUCSTART;
    Gather_STATUS_ENFORCED_for_RTSCUCSTART_units;

    %Get ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE
    Gather_ACTUALS_and_LAST_GEN_SCHEDULE_for_RTSCUC;
    
    %For su and sd trajectories
    Gather_SU_Parameters_Input_for_RTSCUC;
    
    % Initialize delivery factors based on initial conditions
    Gather_Initial_DELIVERY_FACTORS_Input_for_RTSCUC;
    
    for x=1:size(RTSCUC_RULES_PRE_in,1)
        try run(RTSCUC_RULES_PRE_in{x,1});catch;end;
    end
    
    if strcmp(use_Default_RTSCUC,'YES')
        
        RUN_RTSCUC;
        
    end
    for x=1:size(RTSCUC_RULES_POST_in,1)
        try run(RTSCUC_RULES_POST_in{x,1});catch;end;
    end;

    Save_Needed_RTSCUC_Results
    
    rtscuc_running = 0;
    RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;


    %% Initial Real-Time SCED
    %{
    RTSCED for the very first interval
    This interval is used just to set up initial conditions.
    %}

    tNow = toc(tStart);
    fprintf('Complete! \n');
    fprintf('Modeling Initial Real-Time Economic Dispatch...')

    rtsced_running = 1;
    
    %Gather in Default data before starting
    Gather_DEFAULT_DATA

    %TIMESTAMP
    RTD_LOOKAHEAD_INTERVAL_VAL = RTD_LOAD_FULL(1:HRTD,2)*24;%time must be converted to hours instead of days

    %Gather LOAD Forecasts
    LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(RTD_LOAD_FULL,RTSCED_binding_interval_index,HRTD);

    %Gather VG Forecasts
    VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(RTD_VG_FULL,RTD_VG_FIELD,RTSCED_binding_interval_index,HRTD,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(RTD_RESERVE_FULL,RTSCED_binding_interval_index,HRTD);

    %Gather INTERCHANGE schedules
    INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(RTD_INTERCHANGE_FULL,RTSCED_binding_interval_index,HRTD);

    INTERVAL_MINUTES_VAL = round([IRTD;60.*diff(RTD_LOOKAHEAD_INTERVAL_VAL)],3);

    %ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE and ACTUAL/LAST STATUS for gen and storage
    Gather_ACTUALS_and_LAST_GEN_SCHEDULE_for_RTSCED;
    
    %UNIT_STATUS, STARTINGUP, SHUTTINGDOWN, MINGENHELP
    Gather_UC_Parameters_for_RTSCED;
  
    % Initialize delivery factors based on initial conditions
    if lossesCheck > eps
        [RTD_BUS_DELIVERY_FACTORS_VAL,RTD_GEN_DELIVERY_FACTORS_VAL,RTD_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTD,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HRTD),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR_VAL,LOAD_DIST_VAL,LOAD_DIST_STRING);    
    else
        RTD_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTD);
        RTD_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTD);
        RTD_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTD);
    end

    for x=1:size(RTSCED_RULES_PRE_in,1)
        try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
    end;
    
    if strcmp(use_Default_RTSCED,'YES')

    RUN_RTSCED
    
    end
    for x=1:size(RTSCED_RULES_POST_in,1)
        try run(RTSCED_RULES_POST_in{x,1});catch;end;
    end;

    %Keep needed results
    Save_Needed_RTSCED_Results
    
    rtsced_running = 0;
    RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;


    %% Forced Outages

    for x=1:size(FORCED_OUTAGE_PRE_in,1)
        try run(FORCED_OUTAGE_PRE_in{x,1});catch;end;
    end;

    DETERMINE_FORCED_GENERATOR_OUTAGES

    for x=1:size(FORCED_OUTAGE_POST_in,1)
        try run(FORCED_OUTAGE_POST_in{x,1});catch;end;
    end;
    
    %% Data adjust for real-time loop

    Solving_Initial_Models = 0;

    %Various modifications to data prior to main simulation loop.
    DATA_ADJUST_FOR_SIM_LOOP;
    
    fprintf('Complete! \n');
    fprintf('Beginning FESTIV Simulation...\n');
    
    for x=1:size(RT_LOOP_PRE_in,1)
        try run(RT_LOOP_PRE_in{x,1});catch;end; 
    end;

    if use_gui
      fprintf(1,'Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
      fprintf(1,'Simulation Time = %03d days %02d hrs %02d min %02d sec',day,hour,minute,second);
    else
      fprintf('Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
    end
    
else %continuing from previous FESTIV run
    festivBanner;
    fprintf('\nNOTICE: Continuing FESTIV from previous Run.\nIf done by mistake, end run and enter ''clear execution_from_previous'' in command window to restart FESTIV.\n\n\n ');
    fprintf('Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
end;


%Entering the Time Loop
while(time < end_time)
%% Day-Ahead SCUC 
    if dascuc_update + eps >= tDAC && (DASCUC_binding_interval_index-1)*HDAC + eps < end_time
        
        dascuc_update = 0;
        dascuc_running = 1;
        
        %Gather in Default data before starting
        Gather_DEFAULT_DATA

        %TIMESTAMP
        DAC_LOOKAHEAD_INTERVAL_VAL = DAC_LOAD_FULL(HDAC*(DASCUC_binding_interval_index-1)+1:HDAC*(DASCUC_binding_interval_index-1)+HDAC,2)*24; %time must be converted to hours instead of days

        %Gather LOAD Forecasts
        LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(DAC_LOAD_FULL,DASCUC_binding_interval_index,HDAC);

        %Gather VG Forecasts
        VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(DAC_VG_FULL,DAC_VG_FIELD,DASCUC_binding_interval_index,HDAC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

        %Gather RESERVE levels
        RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(DAC_RESERVE_FULL,DASCUC_binding_interval_index,HDAC);
        
        %Gather INTERCHANGE schedules
        INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(DAC_INTERCHANGE_FULL,DASCUC_binding_interval_index,HDAC);

        %INITIAL STATUSES
        Gather_Initial_values_for_DASCUC;
        
        %Enforce commitments on or off in still in min run time or min down
        %time at start of horizon
        Gather_UC_Enforcement_Input_for_DASCUC;
    
        %whether unit forced off
        Gather_GEN_FORCED_OUT_Input_for_DASCUC;
        
        for x=1:size(DASCUC_RULES_PRE_in,1)
            try run(DASCUC_RULES_PRE_in{x,1});catch;end;
        end;
        if strcmp(use_Default_DASCUC,'YES')
            
            RUN_DASCUC;
            
        end
        
        try
        DAModelSolutionStatus=[DAModelSolutionStatus;time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed 
          dbstop if warning stophere:DACinfeasible;
        end
        if Stop_for_Infeasibilities && numberOfInfes ~= 0 
            DEBUG_DASCUC
            warning('stophere:DACinfeasible', 'Infeasible DAC Solution');
        end
        catch
        end;

        for x=1:size(DASCUC_RULES_POST_in,1)
            try run(DASCUC_RULES_POST_in{x,1});catch;end;
        end;

        Save_Needed_DASCUC_Results;
        
        Assign_DASCUC_Commitment_to_STATUS;
        
        dascuc_running = 0;
        DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;
    end;

%%  Real-Time SCUC  
    if rtscuc_update + eps >= tRTC
        
        rtscuc_update = 0;
        rtscuc_running = 1;

        %Gather in Default data before starting
        Gather_DEFAULT_DATA

        %TIMESTAMP
        RTC_LOOKAHEAD_INTERVAL_VAL = RTC_LOAD_FULL(HRTC*(RTSCUC_binding_interval_index-1)+1:HRTC*(RTSCUC_binding_interval_index-1)+HRTC,2)*24;%time must be converted to hours instead of days
        
        %Gather LOAD Forecasts
        LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(RTC_LOAD_FULL,RTSCUC_binding_interval_index,HRTC);

        %Gather VG Forecasts
        VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(RTC_VG_FULL,RTC_VG_FIELD,RTSCUC_binding_interval_index,HRTC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);
       
        %Gather RESERVE levels
        RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(RTC_RESERVE_FULL,RTSCUC_binding_interval_index,HRTC);
 
        %Gather INTERCHANGE schedules
        INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(RTC_INTERCHANGE_FULL,RTSCUC_binding_interval_index,HRTC);
        
        Gather_INITIAL_DISPATCH_SLACK
        rtscucinterval_index = round(time*rtscuc_I_perhour) + 1+1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!
              
        %Setting up the hard commitment constraints for nonquickstarts and other units.
        RTSCUCSTART_MODE = RTSCUCSTART_MODE_RTC;
        RTSCUCSTART;
        Gather_STATUS_ENFORCED_for_RTSCUCSTART_units;
        
        %For initial minimum on and down time constraints
        Gather_STATUS_ENFORCED_for_minrun_down_time_for_RTSCUC;
        
        %Get ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE
        Gather_ACTUALS_and_LAST_GEN_SCHEDULE_for_RTSCUC;

        %Get PREVIOUS_UNIT_STARTUP,INTERVALS_STARTED_AGO,STARTUP_MIN_GEN_HELPER, STARTUP_PERIOD AND SHUTDOWN_PERIOD FOR GEN AND STORAGE
        Gather_SU_Parameters_Input_for_RTSCUC;       
        
        for x=1:size(RTSCUC_RULES_PRE_in,1)
            try run(RTSCUC_RULES_PRE_in{x,1});catch; end; 
        end;
        
        if strcmp(use_Default_RTSCUC,'YES')

        RUN_RTSCUC
        
        end
        try
        RTCModelSolutionStatus(RTSCUC_binding_interval_index,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed
          dbstop if warning stophere:RTCinfeasible;
        end
        if numberOfInfes ~= 0 && (max(rpu_time) < time - PRTC/60 || max(rpu_time) > time)
            DEBUG_RTSCUC
        if Stop_for_Infeasibilities
            warning('stophere:RTCinfeasible', 'Infeasible RTC Solution');
        end
        end
        catch
        end;
        
        for x=1:size(RTSCUC_RULES_POST_in,1)
            try run(RTSCUC_RULES_POST_in{x,1});catch; end; 
        end;

        Save_Needed_RTSCUC_Results;

        rtscuc_running = 0;
        RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;
        
    end;
    
%% Real-Time SCED
    if rtsced_update + eps >= tRTD  
        
        rtsced_update = 0;
        rtsced_running = 1;
        
        %Gather in Default data before starting
        Gather_DEFAULT_DATA
        
        %TIMESTAMP
        RTD_LOOKAHEAD_INTERVAL_VAL = RTD_LOAD_FULL(HRTD*(RTSCED_binding_interval_index-1)+1:HRTD*(RTSCED_binding_interval_index-1)+HRTD,2)*24;%time must be converted to hours instead of days

        %Gather LOAD Forecasts
        LOAD_VAL=Gather_LOAD_Input_for_Scheduling_Process(RTD_LOAD_FULL,RTSCED_binding_interval_index,HRTD);

        %Gather VG Forecasts
        VG_FORECAST_VAL=Gather_VG_FORECAST_Input_for_Scheduling_Process(RTD_VG_FULL,RTD_VG_FIELD,RTSCED_binding_interval_index,HRTD,GEN_VAL,GENVALUE_VAL,ngen,nvcr);
        
        %Gather RESERVE levels
        RESERVELEVEL_VAL=Gather_RESERVE_Input_for_Scheduling_Process(RTD_RESERVE_FULL,RTSCED_binding_interval_index,HRTD);
        
        %Gather INTERCHANGE schedules
        INTERCHANGE_VAL=Gather_INTERCHANGE_Input_for_Scheduling_Process(RTD_INTERCHANGE_FULL,RTSCED_binding_interval_index,HRTD);
                
        Gather_INITIAL_DISPATCH_SLACK

        INTERVAL_MINUTES_VAL = round([IRTD;60.*diff(RTD_LOOKAHEAD_INTERVAL_VAL)],3);
        
        %ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE and ACTUAL/LAST STATUS for gen and storage
        Gather_ACTUALS_and_LAST_GEN_SCHEDULE_for_RTSCED;

        %UNIT_STATUS, STARTINGUP, SHUTTINGDOWN, MINGENHELP
        Gather_UC_Parameters_for_RTSCED;
        
        for x=1:size(RTSCED_RULES_PRE_in,1)
            try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
        end;
        
        if strcmp(use_Default_RTSCED,'YES')

        RUN_RTSCED
        
        end
        try
        RTDModelSolutionStatus(RTSCED_binding_interval_index,:)=[time modelSolveStatus numberOfInfes solverStatus];
        if ~isdeployed
          dbstop if warning stophere:RTDinfeasible;
        end
        if Stop_for_Infeasibilities && numberOfInfes ~= 0 && max(rpu_time) < time - PRTD/60 && max(rpu_time) < time
            warning('stophere:RTDinfeasible', 'Infeasible RTD Solution');
        end
        catch
        end;
        
        for x=1:size(RTSCED_RULES_POST_in,1)
            try run(RTSCED_RULES_POST_in{x,1});catch;end;
        end;

        %Save needed RTD results.
        Save_Needed_RTSCED_Results;
        
        rtsced_running = 0;
        RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;

    end;

%% Actual Generation
      
    for x=1:size(ACTUAL_OUTPUT_PRE_in,1)
        try run(ACTUAL_OUTPUT_PRE_in{x,1});catch;end;
    end;
    
    ACTUALS_SIMULATOR;
    
    for x=1:size(ACTUAL_OUTPUT_POST_in,1)
        try run(ACTUAL_OUTPUT_POST_in{x,1});catch;end;
    end;
    
%% ACE Calculator

    
    Gather_Losses_for_ACE_Calculator;
    
    Gather_current_gen_conditions_for_ACE_Calculator_and_AGC;
    
    Gather_Previous_ACE_for_ACE_Calculator
    
    for x=1:size(ACE_PRE_in,1)
        try run(ACE_PRE_in{x,1});catch;end; 
    end;
    
    ACE_calculator;

    for x=1:size(ACE_POST_in,1)
        try run(ACE_POST_in{x,1});catch;end; 
    end;

    Save_ACE_Results;

%% AGC
    Gather_DISPATCH_for_AGC;
    
    Gather_REGULATION_for_AGC;
    
    Gather_ramp_rates_for_AGC;
    
    for x=1:size(AGC_RULES_PRE_in,1)
        try run(AGC_RULES_PRE_in{x,1});catch;end;
    end;
    
    if strcmp(use_Default_AGC,'YES')
        
    AGC;
    
    end
    
    for x=1:size(AGC_RULES_POST_in,1)
        try run(AGC_RULES_POST_in{x,1});catch;end;
    end;
    
    AGC_SCHEDULE(AGC_interval_index,:)=AGC_BASEPOINT;

%% CTGC occurrence
    for i=1:ngen
        if time  >= gen_outage_time(i,1) && time < gen_repair_time(i,1)
            if actual_gen_forced_out(i,1) == 0
                ctgc_start = 1;
                ctgc_start_time = time;
            end;
            actual_gen_forced_out(i,1) = 1;
        else
            actual_gen_forced_out(i,1) = 0;
        end;
    end;
    
    
%% RPU
    
    if strcmp(ALLOW_RPU,'YES') ==1
        
        RPU_TRIGGER;
        
    if RPU_YES
        
        rpu_running = 1;

        %Gather in Default data before starting
        Gather_DEFAULT_DATA

        %TIMESTAMP values
        for t = 1:HRPU
            RPU_LOOKAHEAD_INTERVAL_VAL(t,1) = time + t*IRPU/60;
        end;

        %LOAD for RPU must be modified depending on the time that it is launched.
        Gather_LOAD_Input_for_RPU
        
        %VG_FORECAST for RPU must be modified depending on the time that it is launched.
        Gather_VG_FORECAST_Input_for_RPU

        %RESERVE_LEVEL for RPU must be modified depending on the time that it is launched.
        Gather_RESERVE_Input_for_RPU
 
        %INTERCHANGE for RPU must be modified depending on the time that it is launched.
        Gather_INTERCHANGE_Input_for_RPU
        
        Gather_INITIAL_DISPATCH_SLACK        

        RTSCUCSTART_MODE = RTSCUCSTART_MODE_RPU;
        RTSCUCSTART;
        %Setting up the hard commitment constraints for nonquickstarts and other units.
        Gather_STATUS_ENFORCED_for_RTSCUCSTART_units_for_RPU
        
        %For initial minimum on and down time constraints
        Gather_STATUS_ENFORCED_for_minrun_down_time_for_RTSCUC
        
        %ACTUALS, LAST_GEN_SCHEDULE, LAST_STATUS, and RAMP_SLACK_UP
        Gather_ACTUALS_and_LAST_GEN_SCHEDULE_for_RPU
        
        %If shutdowns cannot happen delay shutdowns so that infeasibilities are prevented.
        Modify_STATUS_ENFORCED_due_to_SD_Delay_for_RPU
       
        %For su and sd trajectories
        Gather_SU_Parameters_Input_for_RTSCUC
                
        for x=1:size(RPU_RULES_PRE_in,1)
            try run(RPU_RULES_PRE_in{x,1});catch;end; 
        end
        
        if strcmp(use_Default_SCRPU,'YES')

        RUN_RTSCUC
        
        end
        try
        RPUModelSolutionStatus(rpumodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed
          dbstop if warning stophere:RPUinfeasible;
        end
        if numberOfInfes ~= 0
            DEBUG_RTSCUC
        if Stop_for_Infeasibilities 
            warning('stophere:RPUinfeasible', 'Infeasible RPU Solution');
        end
        end
        catch
        end
        
        for x=1:size(RPU_RULES_POST_in,1)
            try run(RPU_RULES_POST_in{x,1});catch;end; 
        end
        
        Save_Needed_RPU_Results
        
        rpu_running = 0;
        RPU_binding_interval_index = RPU_binding_interval_index + 1;
        
    end;
    end;

    
%% End of Interval
    % End of real time loop rule execution
    % Breakpoints for debugging
   
    Stop_FESTIV
    
    if (stop == 1 || (debugcheck && time >= timefordebugstop)) && ~isdeployed
       Stack  = dbstack;
       stoppingpoint=Stack(1).line+4;
       stopcommand=sprintf('dbstop in FESTIV.m at %d',stoppingpoint);
       eval(stopcommand);
       time;
    end

    %Done with interval, go forward in time
    End_of_interval_move_forward;
    
    if use_gui
      fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b %03d days %02d hrs %02d min %02d sec',day,hour,minute,second);
    end
    
    for x=1:size(RT_LOOP_POST_in,1)
        try run(RT_LOOP_POST_in{x,1});catch;end; 
    end;
    
end;
if cancel
else
fprintf('\n')
tEnd = toc(tStart);
fprintf('Simulation Complete! (%02.0f min, %05.2f s)\n',floor(tEnd/60),rem(tEnd,60));
fprintf('\nOutputs\n-------\n')

%% Post Processing, Metrics, Displays, and Storing Results
for x=1:size(POST_PROCESSING_PRE_in,1)
    try run(POST_PROCESSING_PRE_in{x,1});catch;end; 
end

for x=1:size(RELIABILITY_PRE_in,1)
    try run(RELIABILITY_PRE_in{x,1});catch;end;
end;

Calculate_Reliability_Metrics

for x=1:size(RELIABILITY_POST_in,1)
    try run(RELIABILITY_POST_in{x,1});catch;end;
end;

for x=1:size(COST_PRE_in,1)
    try run(COST_PRE_in{x,1});catch;end;
end;

Calculate_Economic_Metrics

for x=1:size(COST_POST_in,1)
    try run(COST_POST_in{x,1});catch;end;
end;

for x=1:size(POST_PROCESSING_POST_in,1)
    try run(POST_PROCESSING_POST_in{x,1});catch;end; 
end

Display_Study_Metrics

for x=1:size(SAVING_PRE_in,1)
    try run(SAVING_PRE_in{x,1});catch;end;
end;

if ~ispc
  try
    SAVE_OUTPUT_TO_HDF5;  % HPC-HDF5
  catch
    tmp_err = lasterror;
    fprintf('Error calling SAVE_OUTPUT_TO_HDF5\n')
    disp(tmp_err)
  end
else
    SAVE_CURRENT_FESTIV_CASE;  % Windows-Excel
end

if strcmp(suppress_plots_in,'NO')
    CREATE_FESTIV_OUTPUT_PLOTS
end

for x=1:size(SAVING_POST_in,1)
    try run(SAVING_POST_in{x,1});catch;end;
end;
end;
%% Check For FESTIV End
try numberofFESTIVrun=numberofFESTIVrun+1;catch;end;
if exist('multiplefilecheck')==1
    if multiplefilecheck == 0
        finishedrunningFESTIV=1;
    else
        if numberofFESTIVrun <= numofinputfiles
            finishedrunningFESTIV=0;
            clearvars -except 'cancel' 'numberofFESTIVrun' 'finishedrunningFESTIV' 'multiplefilecheck' 'numofinputfiles' 'gamspath' 'on_hpc' 'use_gui' 'gams_mip_flag' 'gams_lp_flag';
        else
            finishedrunningFESTIV=1;
        end
    end
else
    finishedrunningFESTIV=1;
end

else
    finishedrunningFESTIV=1;
end
end;

