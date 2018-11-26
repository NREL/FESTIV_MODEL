%adjust gams model
%
%before dascuc, rtscuc, or rtsced
%

GAMS_SOLVER.name = 'GAMS_SOLVER';
GAMS_SOLVER.form = 'full';
GAMS_SOLVER.type = 'parameter';
GAMS_SOLVER.uels = cell(1,0);
if strcmp(computer,'GLNX64')
  GAMS_SOLVER.val = 1;  % 1 = gurobi
else
  GAMS_SOLVER.val = 2;  % 2 = cplex
end
wgdx(['TEMP', filesep, 'Solver_Input'],GAMS_SOLVER);