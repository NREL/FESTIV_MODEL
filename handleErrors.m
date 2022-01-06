e = lasterror;

if strcmp(e.identifier,'StopFESTIV:FESTIV')
    fprintf('Complete!\n')
    testerr.message='FESTIV execution terminated after day-ahead module.';
    testerr.identifier='';
    testerr.stack.file='';
    testerr.stack.name='real time modules';
    testerr.stack.line=0;
    error(testerr);
end