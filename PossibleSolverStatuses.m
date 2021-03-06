disp('1 NORMAL COMPLETION');
disp('This means that the solver terminated in a normal way: i.e., it was not');
disp('interrupted by a limit (resource, iterations, nodes, ...) or by internal');
disp('difficulties. The model status describes the characteristics of the');
disp('accompanying solution.');
disp(' ');
disp('2 ITERATION INTERRUPT');
disp('This means that the solver was interrupted because it used too many');
disp('iterations. Use option iterlim to increase the iteration limit if');
disp('everything seems normal.');
disp(' ');
disp('3 RESOURCE INTERRUPT');
disp('This means that the solver was interrupted because it used too much ');
disp('time. Use option reslim to increase the time limit if everything seems normal.');
disp(' ');
disp('4 TERMINATED BY SOLVER');
disp('This means that the solver encountered diculty and was unable to continue.');
disp('More detail will appear following the message.');
disp(' ');
disp('5 EVALUATION ERROR LIMIT');
disp('Too many evaluations of nonlinear terms at undefined values. You should use');
disp('variable bounds to prevent forbidden operations, such as division by zero.');
disp('The rows in which the errors occur are listed just before the solution.');
disp(' ');
disp('6 CAPABILITY PROBLEMS');
disp('The solver does not have the capability required by the model, for example,');
disp('some solvers do not support certain types of discrete variables or support');
disp('a more limited set of functions than other solvers.');
disp(' ');
disp('7 LICENSING PROBLEMS');
disp('The solver cannot find the appropriate license key needed to use a specific subsolver.');
disp(' ');
disp('8 USER INTERRUPT');
disp('The user has sent a message to interrupt the solver via the interrupt');
disp('button in the IDE or sending a Control+C from a command line.');
disp(' ');
disp('9 ERROR SETUP FAILURE');
disp('The solver encountered a fatal failure during problem set-up time.');
disp(' ');
disp('10 ERROR SOLVER FAILURE');
disp('The solver encountered a fatal error.');
disp(' ');
disp('11 ERROR INTERNAL SOLVER FAILURE');
disp('The solver encountered an internal fatal error.');
disp(' ');
disp('12 SOLVE PROCESSING SKIPPED');
disp('The entire solve step has been skipped. This happens if execution errors');
disp('were encountered and the GAMS parameter ExeErr has been set to a nonzero');
disp('value, or the property MaxExecError has a nonzero value.');
disp(' ');
disp('13 ERROR SYSTEM FAILURE');
disp('This indicates a completely unknown or unexpected error condition.');