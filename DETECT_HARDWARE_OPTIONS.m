% As part of FESTIV and its use on different machines including NREL's
% super computer, hardware must be detected to ensure proper use throughout
% model run.

%The Following will set whether FESTIV uses GUI and for specific options
%related to high performance computing and other options.
GUI_HPC_Options;

%The following determines whether running on High Performance Computing at
%NREL. It is specific to NREL use.
[~,sysout] = system('dnsdomainname'); 
sysout = strtrim(sysout);
if strcmp(sysout, 'hpc.nrel.gov')
  fprintf('Detected host hpc.nrel.gov\n')
  on_hpc = 1;  % hpc flag
end

% Detects whether it is an option to use the gui
if use_gui && ~feature('ShowFigureWindows')
  fprintf('Warning: use_gui was set to 1 but cannot open figure windows.\n')
  use_gui = 0;
end
if ~use_gui
  fprintf('No-gui mode enabled (use_gui = 0).\n')
end

% set gams solver flags
if on_hpc
  gams_mip_flag = ' mip=gurobi ';
  fprintf(['Set gams MIP flag : ', gams_mip_flag, '\n'])
  gams_lp_flag = ' lp=gurobi ';
  fprintf(['Set gams LP flag : ', gams_lp_flag, '\n'])
end

if isunix
  hpc_convert_windows_paths;
end
