% Name of output file
outputtextfilename='tempws.txt';

% Define form of tempws data
sections.Simulation={'inputPath';'daystosimulate';'hours_to_simulate_in';'minutes_to_simulate_in';'seconds_to_simulate_in';'start_date_in';'multiplefilecheck';'multiplerunscheckvalue';'checkthenetwork';'solver_in';'useHDF5'};
sections.DASCUC={'DAC_RESERVE_FORECAST_MODE_in';'DAC_load_forecast_data_create_in';'DAC_vg_forecast_data_create_in';'GDAC_in';'HDAC_in';'IDAC_in';'PDAC_in';'tDAC_in';'DAHORIZONTYPE_in'};
sections.RTSCUC={'RTC_RESERVE_FORECAST_MODE_in';'RTC_load_forecast_data_create_in';'RTC_vg_forecast_data_create_in';'HRTC_in';'IRTC_in';'tRTC_in';'tRTCSTART_in';'PRTC_in'};
sections.RTSCED={'RTD_RESERVE_FORECAST_MODE_in';'RTD_load_forecast_data_create_in';'RTD_vg_forecast_data_create_in';'HRTD_in';'PRTD_in';'tRTD_in';'IRTDADV_in';'IRTD_in'};
sections.RPU={'ALLOW_RPU_in';'ACE_RPU_THRESHOLD_MW_in';'ACE_RPU_THRESHOLD_T_in';'HRPU_in';'IRPU_in';'PRPU_in';'restrict_multiple_rpu_time_in'};
sections.AGC={'CPS2_interval_in';'Type3_integral_in';'K1_in';'K2_in';'L10_in';'agcmode';'agc_deadband_in'};
sections.Contingency={'SIMULATE_CONTINGENCIES_in';'Contingency_input_check_in';'contingencycheck';'gen_outage_time_in'};
sections.Debug={'debugcheck_in';'autosavecheck';'suppress_plots_in';'timefordebugstop_in';'USE_INTEGER_in'};
sections.RULES={'DASCUC_RULES_PRE_in';'DASCUC_RULES_POST_in';'RTSCUC_RULES_PRE_in';'RTSCUC_RULES_POST_in';'RTSCED_RULES_PRE_in';'RTSCED_RULES_POST_in';'AGC_RULES_PRE_in';'AGC_RULES_POST_in';'RPU_RULES_PRE_in';'RPU_RULES_POST_in';'POST_PROCESSING_PRE_in';'POST_PROCESSING_POST_in';'DATA_INITIALIZE_PRE_in';'DATA_INITIALIZE_POST_in';'FORECASTING_PRE_in';'FORECASTING_POST_in';'RT_LOOP_PRE_in';'RT_LOOP_POST_in';'ACE_PRE_in';'ACE_POST_in';'FORCED_OUTAGE_PRE_in';'FORCED_OUTAGE_POST_in';'SHIFT_FACTOR_PRE_in';'SHIFT_FACTOR_POST_in';'ACTUAL_OUTPUT_PRE_in';'ACTUAL_OUTPUT_POST_in';'RELIABILITY_PRE_in';'RELIABILITY_POST_in';'COST_PRE_in';'COST_POST_in';'SAVING_PRE_in';'SAVING_POST_in'};

% Grab data from workspace and write the output text file
section_names=fieldnames(sections);
nsections=size(section_names,1);
fid=fopen(outputtextfilename,'w+');
for s=1:nsections
    if s < nsections
        fprintf(fid,';----- %s Options -----;\n',section_names{s});
        option_names=sections.(section_names{s});
        noptions=size(option_names,1);
        for o=1:noptions
            try
                value=eval(sprintf('eval(sections.%s{%d})',section_names{s},o));
                if ischar(value)
                    tmpline=[option_names{o},' = ',value];
                else
                    tmpline=[option_names{o},' = ',num2str(value)];
                end
            catch
                tmpline=[option_names{o},' = 0'];
            end
            fprintf(fid,'%s\n',tmpline);  
        end
    else
        fprintf(fid,';----- MODEL RULES -----;\n');
        option_names=sections.(section_names{s});
        noptions=size(option_names,1);
        for o=1:noptions
            value=eval(sprintf('eval(sections.%s{%d})',section_names{s},o));
            nrules=size(value,1);
            if nrules > 0
                tmpval=value{1};
                if nrules > 1
                    for r=1:nrules-1
                        tmpval=[tmpval,',',value{r+1}];
                    end
                end
                tmpline=[option_names{o},' = ',tmpval];
                fprintf(fid,'%s\n',tmpline); 
            end
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);