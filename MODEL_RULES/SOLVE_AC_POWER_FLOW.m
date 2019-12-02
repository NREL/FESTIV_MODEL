% Solve AC power flow using MATPOWER

% AC power flow will be solved once every N AGC intervals
% Set N = AGC_interval_index-1 to solve at every AGC step
N = 300; % 300 = once every 30 minutes (60/6*30)
if mod(AGC_interval_index-1,N)==0
    % Create directory to save power flows
    if ~isdir(['TEMP',filesep,'AC_POWER_FLOWS'])
        mkdir(['TEMP',filesep,'AC_POWER_FLOWS']);
    end

    % Suppress all output information
    opt=mpoption;
    opt=mpoption(opt,'OUT_ALL',0,'VERBOSE',0);

    % Create input variable for power flow solve
    CREATE_AC_PF_INPUT;

    % Solve AC power flow
    [pfresults,pfsuccess]=runpf(mpc,opt);

    % Save the simulation time when the power flow was solved
    pfresults.simTime=time;
    
    % Extract bus base voltages
    pfresults.baseVoltages=pfresults.bus(:,10);

    % Save consecutive solutions
    ALL_PF_SOLUTIONS.(sprintf('pf_%.0f',round(time*60)))=pfresults;

    % Save results to a word document
    c=clock;
    fname=['TEMP',filesep,'AC_POWER_FLOWS',filesep,sprintf('%02.0f%02.0f%02.0f - %s at %.4f.txt',c(4),c(5),c(6),inputfilename,time)];
    opt=mpoption(opt,'OUT_ALL',1);
    [fd, msg] = fopen(fname, 'at');
    printpf(pfresults, fd, opt);
    fclose(fd);
end