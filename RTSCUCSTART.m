%RTSCUCSTART_YES of 1 means the RTSCUC can have the option to turn/leave it on.
%RTSCUCSTART_YES of 0 means if STATUS is on, must stay on.
%RTSCUCSHUT_YES of 1 means the RTSCUC can have the option to turn/leave it off.
%RTSCUCSHUT_YES of 0 means if STATUS if off, must stay off.
%RTSCUCPUMPSTART_YES of 1 means the RTSCUC can have the option to turn/leave pump status on.
%RTSCUCPUMPSTART_YES of 0 means if PUMPSTATUS is on, must stay on.
%RTSCUCPUMPSHUT_YES of 1 means the RTSCUC can have the option to turn/leave pump status off.
%RTSCUCPUMPSHUT_YES of 0 means if PUMPSTATUS if off, must stay off.
%rtscucstart_2intervals_ago is what the status was two RTSCUC intervals ago
%RTSCUC_allow is a time index to determine which intervals across the RTSCUC horizon after which allow for RTSCUC commitment decisions. 
%   Those prior the index would not allow for RTSCUC commitment decisions. This prevents RTSCUC from making decisions when the unit is already in a startup or shutdown mode.
%RTSCUCSTART_USER_DEFINED goes to a separate program found in MODEL_RULES where the user can create his/her own code for determining these values. They must make sure RTSCUCSTART_MODE is set to any value other than 1 or 2.
%RTSCUCSTART_MODE and Fix_RT_Pump can be found in FESTIV_ADDL_OPTIONS

%Default mode
if RTSCUCSTART_MODE == 1 %RTSCUC
    RTSCUCSTART_YES = zeros(ngen,HRTC);
    RTSCUCSHUT_YES = zeros(ngen,HRTC);
    RTSCUCPUMPSTART_YES = zeros(nESR,HRTC);
    RTSCUCPUMPSHUT_YES = zeros(nESR,HRTC);
    if RTSCUC_binding_interval_index==1
    % if the unit has a start up time that is shorter than TRTCSTART (Input in GUI), and is not a pumped storage type when the option fixes the RT pumped storage status to day-ahead, then allow its UC status 
    % to be a decision variable in RTSCUC. Otherwise, don't.    
    for i=1:ngen
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) 
            RTSCUCSTART_YES(i,1:HRTC) = 1;
            RTSCUCSHUT_YES(i,1:HRTC) = 1;
        else
            RTSCUCSTART_YES(i,1:HRTC) = 0;
            RTSCUCSHUT_YES(i,HRTC) = 0;
        end
    end
    else
    for i=1:ngen
        %set the RTSCUC schedule from two intervals ago to help determine
        %if it is starting or shutting.
        if RTSCUC_binding_interval_index <=2
            rtscucstart_2intervals_ago = GENVALUE_VAL(i,initial_MW);
        else
            rtscucstart_2intervals_ago = RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) ;
        end
        % if the unit has a start up time that is shorter than TRTCSTART (Input in GUI), and is not a pumped storage type when the option fixes the RT pumped storage status to day-ahead, 
        % and it is not in start-up or shut-down mode, then allow its UC status to be a decision variable in RTSCUC.     
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) ...
                && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) < eps || RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)+eps >=GENVALUE_VAL(i,min_gen))
            RTSCUCSTART_YES(i,1:HRTC) = 1;
            RTSCUCSHUT_YES(i,1:HRTC) = 1;
        %if the unit is eligible for allowing its UC status to be a
        %decision variable in RTSCUC, but is in start-up or shut-down mode,
        %then we may prevent RTSCUC decisions in a subset of intervals in
        %RTSCUC depending on its startup or shutdown.
        elseif GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index ))
            %starting up
            if RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) - rtscucstart_2intervals_ago > 0
                t=RTSCUC_binding_interval_index;
                while t>=1
                    if STATUS(t,1+i)==0
                        RTSCUC_start_index=t;
                        t=0;
                    end
                    t=t-1;
                end
                RTSCUC_allow = RTSCUC_binding_interval_index - RTSCUC_start_index + rtscuc_I_perhour*ceil(GENVALUE_VAL(i,su_time)) + rtscuc_I_perhour*ceil(GENVALUE_VAL(i,mr_time));
                RTSCUCSTART_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSTART_YES(i,RTSCUC_allow:HRTC) = 1;
                RTSCUCSHUT_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSHUT_YES(i,RTSCUC_allow:HRTC) = 1;
            %shutting down
            elseif RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) - rtscucstart_2intervals_ago < 0
                RTSCUCSHUT_YES(i,1:HRTC) = 0;
                t=RTSCUC_binding_interval_index;
                RTSCUC_shut_index=RTSCUC_binding_interval_index+HRTC+1;
                while t<=RTSCUC_binding_interval_index+HRTC
                    if STATUS(t,1+i)==0
                        RTSCUC_shut_index=t;
                        t=RTSCUC_binding_interval_index+HRTC;
                    end
                    t=t+1;
                end
                RTSCUC_allow = RTSCUC_shut_index - RTSCUC_binding_interval_index + rtscuc_I_perhour*ceil(GENVALUE_VAL(i,md_time));
                RTSCUCSTART_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSTART_YES(i,RTSCUC_allow:HRTC) = 1;
                RTSCUCSHUT_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSHUT_YES(i,RTSCUC_allow:HRTC) = 1;
            else    %unlikely anything will make it to this else.
                RTSCUCSTART_YES(i,1:HRTC) = 0;
                RTSCUCSHUT_YES(i,HRTC) = 0;
            end
        else    %all resources that are not eligible for RTSCUC commitment decisions
            RTSCUCSTART_YES(i,1:HRTC) = 0;
            RTSCUCSHUT_YES(i,HRTC) = 0;
        end
    end
    end
    for i=1:nESR
        %For now, the code looking at ability for RTSCUC to make pump
        %status decisions ignores startups and shutdown transitions. This can be added
        %similar to above for generator status in a separate RTSCUCSTART_MODE.
        if STORAGEVALUE_VAL(i,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i,1:HRTC) = 1;
            RTSCUCPUMPSHUT_YES(i,1:HRTC) = 1;
        else
            RTSCUCPUMPSTART_YES(i,1:HRTC) = 0;
            RTSCUCPUMPSHUT_YES(i,HRTC) = 0;
        end
    end
    RTSCUCSTART_YES = RTSCUCSTART_YES(:,1:HRTC);
    RTSCUCSHUT_YES = RTSCUCSHUT_YES(:,1:HRTC);
    RTSCUCPUMPSTART_YES = RTSCUCPUMPSTART_YES(:,1:HRTC);
    RTSCUCPUMPSHUT_YES = RTSCUCPUMPSHUT_YES(:,1:HRTC);
elseif RTSCUCSTART_MODE == 2 %RPU
    RTSCUCSTART_YES = zeros(ngen,HRPU);
    RTSCUCSHUT_YES = zeros(ngen,HRPU);
    RTSCUCPUMPSTART_YES = zeros(nESR,HRPU);
    RTSCUCPUMPSHUT_YES = zeros(nESR,HRPU);
    for i=1:ngen
        % if the unit has a start up time that is shorter than TRTCSTART (Input in GUI), and is not a pumped storage type when the option fixes the RT pumped storage status to day-ahead, 
        % and it is not in start-up or shut-down mode, then allow its UC status to be a decision variable in RTSCUC.     
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) ...
            && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) < eps || RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)+eps >=GENVALUE_VAL(i,min_gen))
            RTSCUCSTART_YES(i,1:HRPU) = 1;
            RTSCUCSHUT_YES(i,1:HRPU) = 1;
        else
            if STATUS(lookahead_index-1,1+i) == 1
                %a key difference in the default RPU compared to RTSCUC, is
                %that the RPU is allowed to keep any unit on if it is already
                %online. In other words, even if the DASCUC had determined
                %a unit that is not otherwise an RTSCUC commitable unit to
                %turn off, the RPU can keep it on. It still cannot turn on
                %those units if they are offline.
                RTSCUCSTART_YES(i,1:HRPU) = 1;
            else
                RTSCUCSTART_YES(i,1:HRPU) = 0;
            end
            RTSCUCSHUT_YES(i,1:HRPU) = 0;
        end
    end
    for i=1:nESR
        %For now, the code looking at ability for RTSCUC to make pump
        %status decisions ignores startups and shutdown transitions. This can be added
        %similar to above for generator status in a separate RTSCUCSTART_MODE.
        if STORAGEVALUE_VAL(i,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i,1:HRPU) = 1;
            RTSCUCPUMPSHUT_YES(i,1:HRPU) = 1;
        else
            RTSCUCPUMPSTART_YES(i,1:HRPU) = 0;
            RTSCUCPUMPSHUT_YES(i,HRPU) = 0;
        end
    end
else %if not mode 1 or 2 then user defined mode is checked. User must enter code under RTSCUCSTART_USER_DEFINED. This script can be found in MODEL_RULES folder.
    RTSCUCSTART_USER_DEFINED
end
