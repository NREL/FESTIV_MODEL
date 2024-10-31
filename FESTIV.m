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
% type 'START_FESTIV_FROM_PREVIOUS_EXECUTION'.



%% midexecution
%start_execution is a rarely used feature to continue a FESTIV run from
%where it has just previously stopped. Users would run
%'START_FESTIV_FROM_PREVIOUS_EXECUTION.m' rather than 'FESTIV.m'
warning('off','all')
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

%% User options to be seen throughout
%A number of different options to change from default values if the user wishes. Users can modify this file.
FESTIV_ADDL_OPTIONS

%% Input Prompt
%if system allows, run GUI for user input. If not, user would have already
%loaded information into tempws workspace.
if feature('ShowFigureWindows') && use_gui
try load tempws;catch;end;
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
    FESTIVBANNER; 
    
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
    
    DIRECTORY = [pwd,filesep];
    %add path for unique model characteristics.
    addpath(strcat(DIRECTORY,filesep, 'MODEL_RULES'));   
    
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

    %Read in all the timeseries data, including actuals and forecasts for use within FESTIV.
    READ_IN_TIMESERIES_DATA;
    
    for x=1:size(FORECASTING_POST_in,1)
        try run(FORECASTING_POST_in{x,1});catch;end; 
    end;
    
    %Verify size of timeseries data.
    FORECAST_DATA_SIZE;
    
    for x=1:size(SHIFT_FACTOR_PRE_in,1)
        try run(SHIFT_FACTOR_PRE_in{x,1});catch;end;
    end;

    %Develop all network related parameters including shift factors.
    CREATE_SHIFT_FACTORS

    for x=1:size(SHIFT_FACTOR_POST_in,1)
        try run(SHIFT_FACTOR_POST_in{x,1});catch;end;
    end;
    
    
    %Initialize variables with zeros and others that need initialization before simulations start
    INITIALIZE_VARIABLES_FOR_RT

    %Allow FESTIV to know that initial models are being solved prior to the FESTIV Time Loop.
    Solving_Initial_Models = 1; 


    %% Initial Day-Ahead SCUC

    tNow = toc(tStart);
    fprintf('Complete! (%02.0f min, %05.2f s)\n',floor(tNow/60),rem(tNow,60));
    fprintf('Modeling Initial Day-Ahead Unit Commitment...')

    %Let FESTIV and all Functional Mods know that DASCUC is currently running.
    dascuc_running = 1;
    
    %Gather in Default data before starting.
    GATHER_DEFAULT_DATA
    
    %TIMESTAMP for intervals being used.
    DAC_LOOKAHEAD_INTERVAL_VAL = DAC_LOAD_FULL(1:HDAC,2)*1; %time must be converted to hours instead of days
    INTERVAL_MINUTES_VAL = round([60*IDAC;60.*diff(DAC_LOOKAHEAD_INTERVAL_VAL)],3);

    %Gather LOAD Forecasts
    LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(DAC_LOAD_FULL,DASCUC_binding_interval_index,HDAC);
    
    %Gather VG Forecasts
    VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(DAC_VG_FULL,DAC_VG_FIELD,DASCUC_binding_interval_index,HDAC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(DAC_RESERVE_FULL,DASCUC_binding_interval_index,HDAC);

    %Enforce commitments on or off in still in min run time or min down
    %time at start of horizon
    GATHER_UC_ENFORCEMENT_INPUT_FOR_DASCUC;
    
    %Gather startup and shutdown period parameters
    GATHER_SU_PARAMETERS_INPUT_FOR_DASCUC;
    
    %initialize delivery factors from initial schedules and loss bias
    GATHER_INITIAL_DELIVERY_FACTORS_INPUT_FOR_DASCUC;
    GATHER_LOSS_BIAS_INPUT_FOR_DASCUC;
    
    %QSC for offline reserve
    GATHER_QSC_INPUT_FOR_DASCUC;
    
    %Gather input for whether units forced off prior to gate closure.
    GATHER_GEN_FORCED_OUT_INPUT_FOR_DASCUC;

    for x=1:size(DASCUC_RULES_PRE_in,1)
        try run(DASCUC_RULES_PRE_in{x,1});catch;end;
    end;

    if strcmp(use_Default_DASCUC,'YES')

        %The following script converts all inputs to GAMS format, per
        %unitizes variables if applicable, writes input data to GDX, runs
        %GAMS, and reads output data from GDX.
        RUN_DASCUC;
        
    end

    try
    DAModelSolutionStatus=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
    if ~isdeployed 
      dbstop if warning stophere:DACinfeasible;
    end
    if Stop_for_Infeasibilities && numberOfInfes ~= 0 
        %if stopping for infeasibilities, an automatic LP is solved for
        %ease of debugging.
        DEBUG_DASCUC
        warning('stophere:DACinfeasible', 'Infeasible DAC Solution');
    end
    catch
    end
    for x=1:size(DASCUC_RULES_POST_in,1)
        try run(DASCUC_RULES_POST_in{x,1});catch;handleErrors;end;
    end;

    %Save all the default results that are needed for reporting and simulation.
    SAVE_NEEDED_DASCUC_RESULTS
    
    dascuc_running = 0;
    DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;


    %% Initial Real-Time SCUC

    tNow = toc(tStart);
    fprintf('Complete!\n');
    fprintf('Modeling Initial Real-Time Unit Commitment...')

    %Let FESTIV and all Functional Mods know that RTSCUC is currently running.
    rtscuc_running = 1;
    
    %Gather in Default data before starting
    GATHER_DEFAULT_DATA

    %TIMESTAMP for intervals being used.
    RTC_LOOKAHEAD_INTERVAL_VAL = RTC_LOAD_FULL(1:HRTC,2)*24; %time must be converted to hours instead of days
    INTERVAL_MINUTES_VAL = round([IRTC;60.*diff(RTC_LOOKAHEAD_INTERVAL_VAL)],3);
    rtscucinterval_index = round(time*rtscuc_I_perhour) + 1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!
        
    %Gather LOAD Forecasts
    LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(RTC_LOAD_FULL,RTSCUC_binding_interval_index,HRTC);

    %Gather VG Forecasts
    VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(RTC_VG_FULL,RTC_VG_FIELD,RTSCUC_binding_interval_index,HRTC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(RTC_RESERVE_FULL,RTSCUC_binding_interval_index,HRTC);

    %Get data pertaining to allowing ramp slacks in initial models
    GATHER_INITIAL_DISPATCH_SLACK

    %Distinguish between units that can have commitment decisions modified in RTSCUC and those that cannot.
    RTSCUCSTART_MODE = RTSCUCSTART_MODE_RTC;
    RTSCUCSTART;
    GATHER_STATUS_ENFORCED_FOR_RTSCUCSTART_UNITS;

    %Get ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE
    GATHER_ACTUALS_AND_LAST_GEN_SCHEDULE_FOR_RTSCUC;
    
    %Force commitment status for min run and min down time constraints not yet fulfilled.
    GATHER_STATUS_ENFORCED_FOR_MINRUN_DOWN_TIME_FOR_RTSCUC
    
    %For su and sd trajectories
    GATHER_SU_PARAMETERS_INPUT_FOR_RTSCUC;
    
    % Initialize delivery factors based on initial conditions
    GATHER_INITIAL_DELIVERY_FACTORS_INPUT_FOR_RTSCUC;
    
    %Set storage end of horizon target
    SET_STORAGE_END_TARGET
    
    for x=1:size(RTSCUC_RULES_PRE_in,1)
        try run(RTSCUC_RULES_PRE_in{x,1});catch;end;
    end
    
    if strcmp(use_Default_RTSCUC,'YES')
        %The following script converts all inputs to GAMS format, per
        %unitizes variables if applicable, writes input data to GDX, runs
        %GAMS, and reads output data from GDX.
        RUN_RTSCUC;
        
    end
    for x=1:size(RTSCUC_RULES_POST_in,1)
        try run(RTSCUC_RULES_POST_in{x,1});catch;end;
    end;

    %Save all the default results that are needed for reporting and simulation.
    SAVE_NEEDED_RTSCUC_RESULTS
    
    rtscuc_running = 0;
    RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;


    %% Initial Real-Time SCED

    tNow = toc(tStart);
    fprintf('Complete! \n');
    fprintf('Modeling Initial Real-Time Economic Dispatch...')

    %Let FESTIV and all Functional Mods know that RTSCED is currently running.
    rtsced_running = 1;
    
    %Gather in Default data before starting
    GATHER_DEFAULT_DATA

    %TIMESTAMP for intervals being used.
    RTD_LOOKAHEAD_INTERVAL_VAL = RTD_LOAD_FULL(1:HRTD,2)*24;%time must be converted to hours instead of days
    INTERVAL_MINUTES_VAL = round([IRTD;60.*diff(RTD_LOOKAHEAD_INTERVAL_VAL)],3);

    %Gather LOAD Forecasts
    LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(RTD_LOAD_FULL,RTSCED_binding_interval_index,HRTD);

    %Gather VG Forecasts
    VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(RTD_VG_FULL,RTD_VG_FIELD,RTSCED_binding_interval_index,HRTD,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

    %Gather RESERVE levels
    RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(RTD_RESERVE_FULL,RTSCED_binding_interval_index,HRTD);

    %Get data pertaining to allowing ramp slacks in initial models
    GATHER_INITIAL_DISPATCH_SLACK
    
    %ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE and ACTUAL/LAST STATUS for gen and storage
    GATHER_ACTUALS_AND_LAST_GEN_SCHEDULE_FOR_RTSCED;
    
    %Data inputs for UNIT_STATUS, STARTINGUP, SHUTTINGDOWN, MINGENHELP
    GATHER_UC_PARAMETERS_FOR_RTSCED;
  
    % Initialize delivery factors based on initial conditions
    GATHER_INITIAL_DELIVERY_FACTORS_INPUT_FOR_RTSCED;
    
    %Set storage end of horizon target
    SET_STORAGE_END_TARGET
    
    for x=1:size(RTSCED_RULES_PRE_in,1)
        try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
    end;
    
    if strcmp(use_Default_RTSCED,'YES')
        %The following script converts all inputs to GAMS format, per
        %unitizes variables if applicable, writes input data to GDX, runs
        %GAMS, and reads output data from GDX.
        RUN_RTSCED
    
    end
    for x=1:size(RTSCED_RULES_POST_in,1)
        try run(RTSCED_RULES_POST_in{x,1});catch;end;
    end;

    %Save all the default results that are needed for reporting and simulation.
    SAVE_NEEDED_RTSCED_RESULTS
    
    rtsced_running = 0;
    RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;


    %% Forced Outages

    for x=1:size(FORCED_OUTAGE_PRE_in,1)
        try run(FORCED_OUTAGE_PRE_in{x,1});catch;end;
    end;

    %If the user allowed forced outages from the FESTIV GUI, those are
    %applied here for the FESTIV Time Loop.
    DETERMINE_FORCED_GENERATOR_OUTAGES

    for x=1:size(FORCED_OUTAGE_POST_in,1)
        try run(FORCED_OUTAGE_POST_in{x,1});catch;end;
    end;
    
    %% Data adjust for real-time loop

    %Let FESTIV and Functional Mods know that it is no longer solving for the initial models. 
    Solving_Initial_Models = 0;

    %Various modifications to data prior to FESTIV Time Loop.
    DATA_ADJUST_FOR_SIM_LOOP;
    
    fprintf('Complete! \n');
    fprintf('Beginning FESTIV Time Loop...\n');
    
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
    FESTIVBANNER;
    fprintf('\nNOTICE: Continuing FESTIV from previous Run.\nIf done by mistake, end run and enter ''clear execution_from_previous'' in command window to restart FESTIV.\n\n\n ');
    fprintf('Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
end;


%Entering the Time Loop
while(time < end_time)
%% Day-Ahead SCUC 
    if dascuc_update + eps >= tDAC && (DASCUC_binding_interval_index-1)*IDAC*HDAC + eps < end_time
        
        dascuc_update = 0;
        %Let FESTIV and all Functional Mods know that DASCUC is currently running.
        dascuc_running = 1;
        
        %Gather in Default data before starting
        GATHER_DEFAULT_DATA

        %TIMESTAMP for intervals being used.
        DAC_LOOKAHEAD_INTERVAL_VAL = DAC_LOAD_FULL(HDAC*(DASCUC_binding_interval_index-1)+1:HDAC*(DASCUC_binding_interval_index-1)+HDAC,2)*1; %time must be converted to hours instead of days
        INTERVAL_MINUTES_VAL = round([60*IDAC;60.*diff(DAC_LOOKAHEAD_INTERVAL_VAL)],3);
        
        %Gather LOAD Forecasts
        LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(DAC_LOAD_FULL,DASCUC_binding_interval_index,HDAC);

        %Gather VG Forecasts
        VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(DAC_VG_FULL,DAC_VG_FIELD,DASCUC_binding_interval_index,HDAC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);

        %Gather RESERVE levels
        RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(DAC_RESERVE_FULL,DASCUC_binding_interval_index,HDAC);
        
        %INITIAL STATUSES
        GATHER_INITIAL_VALUES_FOR_DASCUC;
        
        %Enforce commitments on or off if unit still in min run time or min down time at start of horizon
        GATHER_UC_ENFORCEMENT_INPUT_FOR_DASCUC;
    
        %Gather startup and shutdown period parameters
        GATHER_SU_PARAMETERS_INPUT_FOR_DASCUC;
        
        %Gather input for whether units forced off prior to gate closure.
        GATHER_GEN_FORCED_OUT_INPUT_FOR_DASCUC;
        
        for x=1:size(DASCUC_RULES_PRE_in,1)
            try run(DASCUC_RULES_PRE_in{x,1});catch;end;
        end;
        if strcmp(use_Default_DASCUC,'YES')
            
            %The following script converts all inputs to GAMS format, per
            %unitizes variables if applicable, writes input data to GDX, runs
            %GAMS, and reads output data from GDX.
            RUN_DASCUC;
            
        end
        
        try
        DAModelSolutionStatus=[DAModelSolutionStatus;time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed 
          dbstop if warning stophere:DACinfeasible;
        end
        if Stop_for_Infeasibilities && numberOfInfes ~= 0 
            %if stopping for infeasibilities, an automatic LP is solved for
            %ease of debugging.
            DEBUG_DASCUC
            warning('stophere:DACinfeasible', 'Infeasible DAC Solution');
        end
        catch
        end;

        for x=1:size(DASCUC_RULES_POST_in,1)
            try run(DASCUC_RULES_POST_in{x,1});catch;end;
        end;

        %Save all the default results that are needed for reporting and simulation.
        SAVE_NEEDED_DASCUC_RESULTS;
               
        dascuc_running = 0;
        DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;
    end;

%%  Real-Time SCUC  
    if rtscuc_update + eps >= tRTC
        
        rtscuc_update = 0;
        %Let FESTIV and all Functional Mods know that RTSCUC is currently running.
        rtscuc_running = 1;

        %Gather in Default data before starting
        GATHER_DEFAULT_DATA

        %TIMESTAMP for intervals being used.
        RTC_LOOKAHEAD_INTERVAL_VAL = RTC_LOAD_FULL(HRTC*(RTSCUC_binding_interval_index-1)+1:HRTC*(RTSCUC_binding_interval_index-1)+HRTC,2)*24;%time must be converted to hours instead of days
        INTERVAL_MINUTES_VAL = round([IRTC;60.*diff(RTC_LOOKAHEAD_INTERVAL_VAL)],3);
        rtscucinterval_index = round(time*rtscuc_I_perhour) + 1+1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!
        
        %Gather LOAD Forecasts
        LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(RTC_LOAD_FULL,RTSCUC_binding_interval_index,HRTC);

        %Gather VG Forecasts
        VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(RTC_VG_FULL,RTC_VG_FIELD,RTSCUC_binding_interval_index,HRTC,GEN_VAL,GENVALUE_VAL,ngen,nvcr);
       
        %Gather RESERVE levels
        RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(RTC_RESERVE_FULL,RTSCUC_binding_interval_index,HRTC);
 
        %Get data pertaining to allowing ramp slacks in initial models
        GATHER_INITIAL_DISPATCH_SLACK
              
        %Distinguish between units that can have commitment decisions modified in RTSCUC and those that cannot.
        %RTSCUCSTART can be modified by the user. RTSCUCSTART_MODE_RTC can be modified in FESTIV_ADDL_OPTIONS
        RTSCUCSTART_MODE = RTSCUCSTART_MODE_RTC;
        RTSCUCSTART;
        GATHER_STATUS_ENFORCED_FOR_RTSCUCSTART_UNITS;
        
        %For initial minimum on and down time constraints
        GATHER_STATUS_ENFORCED_FOR_MINRUN_DOWN_TIME_FOR_RTSCUC;
        
        %Get ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE
        GATHER_ACTUALS_AND_LAST_GEN_SCHEDULE_FOR_RTSCUC;

        %Get PREVIOUS_UNIT_STARTUP,INTERVALS_STARTED_AGO,STARTUP_MIN_GEN_HELPER, STARTUP_PERIOD AND SHUTDOWN_PERIOD FOR GEN AND STORAGE
        GATHER_SU_PARAMETERS_INPUT_FOR_RTSCUC;  
        
        %Set storage end of horizon target
        SET_STORAGE_END_TARGET
        
        for x=1:size(RTSCUC_RULES_PRE_in,1)
            try run(RTSCUC_RULES_PRE_in{x,1});catch; end; 
        end;
        
        if strcmp(use_Default_RTSCUC,'YES')

            %The following script converts all inputs to GAMS format, per
            %unitizes variables if applicable, writes input data to GDX, runs
            %GAMS, and reads output data from GDX.
            RUN_RTSCUC
        
        end
        try
        RTCModelSolutionStatus(RTSCUC_binding_interval_index,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed
          dbstop if warning stophere:RTCinfeasible;
        end
        if numberOfInfes ~= 0 && (max(rpu_time) < time - PRTC/60 || max(rpu_time) > time)
            %if stopping for infeasibilities, an automatic LP is solved for
            %ease of debugging.
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

        %Save all the default results that are needed for reporting and simulation.
        SAVE_NEEDED_RTSCUC_RESULTS;

        rtscuc_running = 0;
        RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;
        
    end;
    
%% Real-Time SCED
    if rtsced_update + eps >= tRTD  
        
        rtsced_update = 0;
        %Let FESTIV and all Functional Mods know that RTSCED is currently running.
        rtsced_running = 1;
        
        %Gather in Default data before starting
        GATHER_DEFAULT_DATA
        
        %TIMESTAMP for intervals being used.
        RTD_LOOKAHEAD_INTERVAL_VAL = RTD_LOAD_FULL(HRTD*(RTSCED_binding_interval_index-1)+1:HRTD*(RTSCED_binding_interval_index-1)+HRTD,2)*24;%time must be converted to hours instead of days
        INTERVAL_MINUTES_VAL = round([IRTD;60.*diff(RTD_LOOKAHEAD_INTERVAL_VAL)],3);

        %Gather LOAD Forecasts
        LOAD_VAL=GATHER_LOAD_INPUT_FOR_SCHEDULING_PROCESS(RTD_LOAD_FULL,RTSCED_binding_interval_index,HRTD);

        %Gather VG Forecasts
        VG_FORECAST_VAL=GATHER_VG_FORECAST_INPUT_FOR_SCHEDULING_PROCESS(RTD_VG_FULL,RTD_VG_FIELD,RTSCED_binding_interval_index,HRTD,GEN_VAL,GENVALUE_VAL,ngen,nvcr);
        
        %Gather RESERVE levels
        RESERVELEVEL_VAL=GATHER_RESERVE_INPUT_FOR_SCHEDULING_PROCESS(RTD_RESERVE_FULL,RTSCED_binding_interval_index,HRTD);
        
        %Get data pertaining to allowing ramp slacks in initial models
        GATHER_INITIAL_DISPATCH_SLACK
        
        %ACTUAL_GEN_OUTPUT and LAST_GEN_SCHEDULE and ACTUAL/LAST STATUS for gen and storage
        GATHER_ACTUALS_AND_LAST_GEN_SCHEDULE_FOR_RTSCED;

        %Data inputs for UNIT_STATUS, STARTINGUP, SHUTTINGDOWN, MINGENHELP
        GATHER_UC_PARAMETERS_FOR_RTSCED;
        
        %Set storage end of horizon target
        SET_STORAGE_END_TARGET
        
        for x=1:size(RTSCED_RULES_PRE_in,1)
            try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
        end;
        
        if strcmp(use_Default_RTSCED,'YES')

            %The following script converts all inputs to GAMS format, per
            %unitizes variables if applicable, writes input data to GDX, runs
            %GAMS, and reads output data from GDX.
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

        %Save all the default results that are needed for reporting and simulation.
        SAVE_NEEDED_RTSCED_RESULTS;
        
        rtsced_running = 0;
        RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;

    end;

%% Actual Generation
      
    for x=1:size(ACTUAL_OUTPUT_PRE_in,1)
        try run(ACTUAL_OUTPUT_PRE_in{x,1});catch;end;
    end;
    
    %Run the Sub-model that calculates the actuals, or realized outputs of
    %all resources on the system
    ACTUALS_SIMULATOR;
    
    for x=1:size(ACTUAL_OUTPUT_POST_in,1)
        try run(ACTUAL_OUTPUT_POST_in{x,1});catch;end;
    end;
    
%% ACE Calculator

    %Calculate losses for the AGC time frame to calculate ACE
    if strcmp(NETWORK_CHECK,'YES')
        %Calculate losses for the AGC time frame to calculate ACE
        GATHER_LOSSES_FOR_ACE_CALCULATOR;
    else
        losses=0;
    end
    
    %All the current generator outputs and other inputs at AGC time frame
    GATHER_CURRENT_GEN_CONDITIONS_FOR_ACE_CALCULATOR_AND_AGC;
    
    %Previous ACE
    GATHER_PREVIOUS_ACE_FOR_ACE_CALCULATOR
    
    for x=1:size(ACE_PRE_in,1)
        try run(ACE_PRE_in{x,1});catch;end; 
    end;
    
    %Calculate all forms of ACE to be used by the AGC
    ACE_CALCULATOR;

    for x=1:size(ACE_POST_in,1)
        try run(ACE_POST_in{x,1});catch;end; 
    end;

    %All needed ACE results for reporting and in simulation.
    SAVE_ACE_RESULTS;

%% AGC
    
    %Dispatch results that are used as input in AGC Sub-Model
    GATHER_DISPATCH_FOR_AGC;
    
    %Regulation schedules determined by RTSCED (or other) that are used in AGC sub-model.
    GATHER_REGULATION_FOR_AGC;

    %Get ramp rate data for input into AGC sub-model.
    GATHER_RAMP_RATES_FOR_AGC;
    
    for x=1:size(AGC_RULES_PRE_in,1)
        try run(AGC_RULES_PRE_in{x,1});catch;end;
    end;
    
    if strcmp(use_Default_AGC,'YES')
    
        %Run AGC sub-model for AGC schedules   
        AGC;
    
    end
    
    for x=1:size(AGC_RULES_POST_in,1)
        try run(AGC_RULES_POST_in{x,1});catch;end;
    end;
    
    %AGC schedules are saved for reporting and in simulation.
    AGC_SCHEDULE(AGC_interval_index,:)=AGC_BASEPOINT;

%% CTGC occurrence
    
    %If generator contingencies are allowed, it will be determined here
    %whether they have occurred in the FESTIV Time Loop.
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
        
        %RPU_TRIGGER determines whether an event has occurred that requires
        %the use of RPU, an event-based RTSCUC. The user can modify
        %RPU_TRIGGER file.
        RPU_TRIGGER;
        
    if RPU_YES
        %Let FESTIV and all Functional Mods know that RPU is currently running.
        rpu_running = 1;

        %Gather in Default data before starting
        GATHER_DEFAULT_DATA

        %TIMESTAMP for intervals being used.
        for t = 1:HRPU
            RPU_LOOKAHEAD_INTERVAL_VAL(t,1) = time + t*IRPU/60;
        end;
        INTERVAL_MINUTES_VAL = round([IRPU;60.*diff(RPU_LOOKAHEAD_INTERVAL_VAL)],3);
        
        %LOAD for RPU must be modified depending on the time that it is launched.
        GATHER_LOAD_INPUT_FOR_RPU
        
        %VG_FORECAST for RPU must be modified depending on the time that it is launched.
        GATHER_VG_FORECAST_INPUT_FOR_RPU

        %RESERVE_LEVEL for RPU must be modified depending on the time that it is launched.
        GATHER_RESERVE_INPUT_FOR_RPU
 
        %Get data pertaining to allowing ramp slacks in initial models
        GATHER_INITIAL_DISPATCH_SLACK        

        %Distinguish between units that can have commitment decisions modified in RTSCUC and those that cannot.
        %RTSCUCSTART can be modified by the user. RTSCUCSTART_MODE_RPU can be modified in FESTIV_ADDL_OPTIONS
        RTSCUCSTART_MODE = RTSCUCSTART_MODE_RPU;
        RTSCUCSTART;
        GATHER_STATUS_ENFORCED_FOR_RTSCUCSTART_UNITS_FOR_RPU
        
        %For initial minimum on and down time constraints
        GATHER_STATUS_ENFORCED_FOR_MINRUN_DOWN_TIME_FOR_RTSCUC
        
        %ACTUALS, LAST_GEN_SCHEDULE, LAST_STATUS, and RAMP_SLACK_UP
        GATHER_ACTUALS_AND_LAST_GEN_SCHEDULE_FOR_RPU
        
        %For su and sd trajectories
        GATHER_SU_PARAMETERS_INPUT_FOR_RTSCUC
                
        %Set storage end of horizon target
        SET_STORAGE_END_TARGET

        for x=1:size(RPU_RULES_PRE_in,1)
            try run(RPU_RULES_PRE_in{x,1});catch;end; 
        end
        
        if strcmp(use_Default_SCRPU,'YES')

            %The following script converts all inputs to GAMS format, per
            %unitizes variables if applicable, writes input data to GDX, runs
            %GAMS, and reads output data from GDX.
            RUN_RTSCUC
        
        end
        try
        RPUModelSolutionStatus(rpumodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed
          dbstop if warning stophere:RPUinfeasible;
        end
        if numberOfInfes ~= 0
            %if stopping for infeasibilities, an automatic LP is solved for
            %ease of debugging.
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
        
        %Save all the default results that are needed for reporting and simulation.
        SAVE_NEEDED_RPU_RESULTS
        
        rpu_running = 0;
        RPU_binding_interval_index = RPU_binding_interval_index + 1;
        
    end;
    end;

    
%% End of Interval
    % End of single interval of tAGC length.
    % Breakpoints for debugging
   
    %Stop FESTIV in debug mode if a particular condition occurs as defined by user.
    %STOP_FESTIV can be modified by the user.
    STOP_FESTIV
    
    if (stop == 1 || (debugcheck && time >= timefordebugstop)) && ~isdeployed
       Stack  = dbstack;
       stoppingpoint=Stack(1).line+4;
       stopcommand=sprintf('dbstop in FESTIV.m at %d',stoppingpoint);
       eval(stopcommand);
       time;
    end

    %Done with interval, go forward in time
    END_OF_INTERVAL_MOVE_FORWARD;
    
    if use_gui
      fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b %03d days %02d hrs %02d min %02d sec',day,hour,minute,second);
    end
    
    for x=1:size(RT_LOOP_POST_in,1)
        try run(RT_LOOP_POST_in{x,1});catch;end; 
    end;
    
end;

%The FESTIV Time Loop is Complete.

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

%Calculate all reliability based metrics for the simulation.
CALCULATE_RELIABILITY_METRICS

for x=1:size(RELIABILITY_POST_in,1)
    try run(RELIABILITY_POST_in{x,1});catch;end;
end;

for x=1:size(COST_PRE_in,1)
    try run(COST_PRE_in{x,1});catch;end;
end;

%Calculate all economic based metrics for the simulation.
CALCULATE_ECONOMIC_METRICS

for x=1:size(COST_POST_in,1)
    try run(COST_POST_in{x,1});catch;end;
end;

for x=1:size(POST_PROCESSING_POST_in,1)
    try run(POST_PROCESSING_POST_in{x,1});catch;end; 
end

%On Matlab command window, show metrics to users
DISPLAY_STUDY_METRICS

for x=1:size(SAVING_PRE_in,1)
    try run(SAVING_PRE_in{x,1});catch;end;
end;

%Save results if requested
if ~ispc
  try
    SAVE_OUTPUT_TO_HDF5;  % HPC-HDF5
  catch
    tmp_err = lasterror;
    save(['OUTPUT',filesep,'Workspace.mat']);
    fprintf('Error calling SAVE_OUTPUT_TO_HDF5\n')
    %disp(tmp_err)
  end
else
    SAVE_CURRENT_FESTIV_CASE;  % Windows-Excel
end

%Present high-level figures if requested
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
        %Single simulation requested by user. All complete.
        finishedrunningFESTIV=1;
    else
        if numberofFESTIVrun <= numofinputfiles
            %There are more FESTIV simulations to run under a multiple simulation case.
            finishedrunningFESTIV=0;
            clearvars -except 'cancel' 'numberofFESTIVrun' 'finishedrunningFESTIV' 'multiplefilecheck' 'numofinputfiles' 'gamspath' 'on_hpc' 'use_gui' 'gams_mip_flag' 'gams_lp_flag' 'execution_from_previous';
        else
            %All FESTIV simulations are complete under a multiple simulation case.
            finishedrunningFESTIV=1;
        end
    end
else
    finishedrunningFESTIV=1;
end

else
    %User canceled the case during the GUI set up.
    finishedrunningFESTIV=1;
end
end;

fprintf('\nFESTIV execution complete.\n');