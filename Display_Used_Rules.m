% Display all the model rules currently configured in the simulation
% Note: some model rules may be live configured, so be careful with
% interpreting results
try
    if ~isempty(DASCUC_RULES_PRE_in)
        fprintf('\nThe following rules were used before the DASCUC:\n');
        for i=1:size(DASCUC_RULES_PRE_in,1)
            fprintf('\t%s\n',DASCUC_RULES_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(DASCUC_RULES_POST_in)
        fprintf('\nThe following rules were used after the DASCUC:\n');
        for i=1:size(DASCUC_RULES_POST_in,1)
            fprintf('\t%s\n',DASCUC_RULES_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(RTSCUC_RULES_PRE_in)
        fprintf('\nThe following rules were used before the RTSCUC:\n');
        for i=1:size(RTSCUC_RULES_PRE_in,1)
            fprintf('\t%s\n',RTSCUC_RULES_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(RTSCUC_RULES_POST_in)
        fprintf('\nThe following rules were used after the RTSCUC:\n');
        for i=1:size(RTSCUC_RULES_POST_in,1)
            fprintf('\t%s\n',RTSCUC_RULES_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(RTSCED_RULES_PRE_in)
        fprintf('\nThe following rules were used before the RTSCED:\n');
        for i=1:size(RTSCED_RULES_PRE_in,1)
            fprintf('\t%s\n',RTSCED_RULES_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(RTSCED_RULES_POST_in)
        fprintf('\nThe following rules were used after the RTSCED:\n');
        for i=1:size(RTSCED_RULES_POST_in,1)
            fprintf('\t%s\n',RTSCED_RULES_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(AGC_RULES_PRE_in)
        fprintf('\nThe following rules were used before the AGC:\n');
        for i=1:size(AGC_RULES_PRE_in,1)
            fprintf('\t%s\n',AGC_RULES_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(AGC_RULES_POST_in)
        fprintf('\nThe following rules were used after the AGC:\n');
        for i=1:size(AGC_RULES_POST_in,1)
            fprintf('\t%s\n',AGC_RULES_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(RPU_RULES_PRE_in)
        fprintf('\nThe following rules were used before the RPU:\n');
        for i=1:size(RPU_RULES_PRE_in,1)
            fprintf('\t%s\n',RPU_RULES_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(RPU_RULES_POST_in)
        fprintf('\nThe following rules were used after the RPU:\n');
        for i=1:size(RPU_RULES_POST_in,1)
            fprintf('\t%s\n',RPU_RULES_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(POST_PROCESSING_PRE_in)
        fprintf('\nThe following rules were used before the post processing process:\n');
        for i=1:size(POST_PROCESSING_PRE_in,1)
            fprintf('\t%s\n',POST_PROCESSING_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(POST_PROCESSING_POST_in)
        fprintf('\nThe following rules were used after the post processing process:\n');
        for i=1:size(POST_PROCESSING_POST_in,1)
            fprintf('\t%s\n',POST_PROCESSING_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(DATA_INITIALIZE_PRE_in)
        fprintf('\nThe following rules were used before the data was initialized:\n');
        for i=1:size(DATA_INITIALIZE_PRE_in,1)
            fprintf('\t%s\n',DATA_INITIALIZE_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(DATA_INITIALIZE_POST_in)
        fprintf('\nThe following rules were used after the data was initialized:\n');
        for i=1:size(DATA_INITIALIZE_POST_in,1)
            fprintf('\t%s\n',DATA_INITIALIZE_POST_in{i});
        end    
    end
catch
end
try
    if ~isempty(FORECASTING_PRE_in)
        fprintf('\nThe following rules were used before the forecasts were created:\n');
        for i=1:size(FORECASTING_PRE_in,1)
            fprintf('\t%s\n',FORECASTING_PRE_in{i});
        end    
    end
catch
end
try
    if ~isempty(FORECASTING_POST_in)
        fprintf('\nThe following rules were used after the forecasts were created:\n');
        for i=1:size(FORECASTING_POST_in,1)
            fprintf('\t%s\n',FORECASTING_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(RT_LOOP_PRE_in)
        fprintf('\nThe following rules were used before the real time loop:\n'); 
        for i=1:size(RT_LOOP_PRE_in,1)
            fprintf('\t%s\n',RT_LOOP_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(RT_LOOP_POST_in)
        fprintf('\nThe following rules were used after the real time loop:\n');
        for i=1:size(RT_LOOP_POST_in,1)
            fprintf('\t%s\n',RT_LOOP_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(ACE_PRE_in)
        fprintf('\nThe following rules were used before the ACE calculation:\n'); 
        for i=1:size(ACE_PRE_in,1)
            fprintf('\t%s\n',ACE_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(ACE_POST_in)
        fprintf('\nThe following rules were used after the ACE calculation:\n');
        for i=1:size(ACE_POST_in,1)
            fprintf('\t%s\n',ACE_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(FORCED_OUTAGE_PRE_in)
        fprintf('\nThe following rules were used before forced outages were determined:\n'); 
        for i=1:size(FORCED_OUTAGE_PRE_in,1)
            fprintf('\t%s\n',FORCED_OUTAGE_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(FORCED_OUTAGE_POST_in)
        fprintf('\nThe following rules were used after forced outages were determined:\n');
        for i=1:size(FORCED_OUTAGE_POST_in,1)
            fprintf('\t%s\n',FORCED_OUTAGE_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(SHIFT_FACTOR_PRE_in)
        fprintf('\nThe following rules were used before shift factor calculations:\n'); 
        for i=1:size(SHIFT_FACTOR_PRE_in,1)
            fprintf('\t%s\n',SHIFT_FACTOR_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(SHIFT_FACTOR_POST_in)
        fprintf('\nThe following rules were used after shift factor calculations:\n');
        for i=1:size(SHIFT_FACTOR_POST_in,1)
            fprintf('\t%s\n',SHIFT_FACTOR_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(ACTUAL_OUTPUT_PRE_in)
        fprintf('\nThe following rules were used before the determination of actual outputs:\n'); 
        for i=1:size(ACTUAL_OUTPUT_PRE_in,1)
            fprintf('\t%s\n',ACTUAL_OUTPUT_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(ACTUAL_OUTPUT_POST_in)
        fprintf('\nThe following rules were used after the determination of actual outputs:\n');
        for i=1:size(ACTUAL_OUTPUT_POST_in,1)
            fprintf('\t%s\n',ACTUAL_OUTPUT_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(RELIABILITY_PRE_in)
        fprintf('\nThe following rules were used before reliability metric calculations:\n'); 
        for i=1:size(RELIABILITY_PRE_in,1)
            fprintf('\t%s\n',RELIABILITY_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(RELIABILITY_POST_in)
        fprintf('\nThe following rules were used after reliability metric calculations:\n');
        for i=1:size(RELIABILITY_POST_in,1)
            fprintf('\t%s\n',RELIABILITY_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(COST_PRE_in)
        fprintf('\nThe following rules were used before cost calculations:\n'); 
        for i=1:size(COST_PRE_in,1)
            fprintf('\t%s\n',COST_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(COST_POST_in)
        fprintf('\nThe following rules were used after cost calculations:\n');
        for i=1:size(COST_POST_in,1)
            fprintf('\t%s\n',COST_POST_in{i});
        end
    end
catch
end
try
    if ~isempty(SAVING_PRE_in)
        fprintf('\nThe following rules were used before saving the results:\n'); 
        for i=1:size(SAVING_PRE_in,1)
            fprintf('\t%s\n',SAVING_PRE_in{i});
        end
    end
catch
end
try
    if ~isempty(SAVING_POST_in)
        fprintf('\nThe following rules were used after saving the results:\n');
        for i=1:size(SAVING_POST_in,1)
            fprintf('\t%s\n',SAVING_POST_in{i});
        end
    end
catch
end
fprintf('\n');