%%DEBUG_DASCUC
%Debug DASCUC to see what infeasibilities occurred. Requires solution of LP
%and integers turned off.

% Create gck file
fid=fopen('DASCUC.gck','w+');
fprintf(fid,'%s','blockpic');
fprintf(fid,'\r\n');
fclose(fid);
Solving_Initial_Models_TMP=0;
if Solving_Initial_Models
    Solving_Initial_Models_TMP=1;
    Solving_Initial_Models =0;
end
    
DASCUC_GAMS_CALL_TMP = DASCUC_GAMS_CALL;
DASCUC_GAMS_CALL = ['gams ..\DASCUC.gms Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USE_INTEGER="NO"',' --USEGAMS="',USEGAMS,'"'];

RUN_DASCUC

Solving_Initial_Models = Solving_Initial_Models_TMP;

if exist('time','var') == 1
    [time modelSolveStatus numberOfInfes solverStatus relativeGap]
else
    [-1 modelSolveStatus numberOfInfes solverStatus relativeGap]
end
if modelSolveStatus == 1
    debugstr2='feasible.';
    fprintf(['The DASCUC solution was',' ',debugstr2,'\n']);
else
    debugstr2 = ['infeasible with',' ',num2str(numberOfInfes),' ','infeasible constraints.'];
    fprintf(['The DASCUC solution was',' ',debugstr2,'\n']);
    disp('Check DASCUC.lst file for infeasibilities.');
end;

DASCUC_GAMS_CALL = DASCUC_GAMS_CALL_TMP;


