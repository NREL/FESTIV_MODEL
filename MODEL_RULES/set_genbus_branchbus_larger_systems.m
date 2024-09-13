%
% After Data Initialization
%
%reduces memory requirements for large systems
%This code is not complete and should not be used until improved further


clear GENBUS BRANCHBUS INJECTION_FACTOR

% Branch Bus Data
if exist(['TEMP',filesep,'BRANCHBUS.inc'],'file') == 2
    delete(['TEMP',filesep,'BRANCHBUS.inc']);
end
if useHDF5==0
    [~,branchbusstrings]=xlsread(inputPath,'BRANCHDATA','B2:B10000');
else
    branchbusstrings=x.BRANCHBUS;
end
fid=fopen(['TEMP',filesep,'BRANCHBUS.inc'],'w+');
for i=1:size(branchbusstrings,1)
    fprintf(fid,branchbusstrings{i,1});
    fprintf(fid,'\r\n');
end
fclose(fid);
BRANCHBUS.val = 0;
BRANCHBUS.name = 'BRANCHBUS';
BRANCHBUS.form = 'full';
BRANCHBUS.uels = cell(1,0);
BRANCHBUS.type = 'parameter';
% Participation Factor Data
if exist(['TEMP',filesep,'PARTF.inc'],'file') == 2
    delete(['TEMP',filesep,'PARTF.inc']);
end

if useHDF5==0
    [genbusvalues,genbusstrings]=xlsread(inputPath,'GENBUS','A2:B10000');
else
    x=h5read(fileName,'/Main Input File/GENBUS');
    genbusstrings=x.GENBUS;
    genbusvalues=x.PARTICIPATION_FACTORS;
end
myformat='%s %.05f';
fid=fopen(['TEMP',filesep,'PARTF.inc'],'w+');
for i=1:size(genbusstrings,1)
    fprintf(fid,myformat,genbusstrings{i,1},genbusvalues(i,1));
    fprintf(fid,'\r\n');
end
fclose(fid);
INJECTION_FACTOR.val = 0;
INJECTION_FACTOR.name = 'INJECTION_FACTOR';
INJECTION_FACTOR.form = 'full';
INJECTION_FACTOR.uels = cell(1,0);
INJECTION_FACTOR.type = 'parameter';
% Gen Bus Data
if exist(['TEMP',filesep,'GENBUSSET.inc'],'file') == 2
    delete(['TEMP',filesep,'GENBUSSET.inc']);
end
fid=fopen(['TEMP',filesep,'GENBUSSET.inc'],'w+');
for i=1:size(genbusstrings,1)
    fprintf(fid,genbusstrings{i,1});
    fprintf(fid,'\r\n');
end
fclose(fid);
GENBUS.val = 0;
GENBUS.name = 'GENBUS';
GENBUS.form = 'full';
GENBUS.uels = cell(1,0);
GENBUS.type = 'parameter';
USEGAMS='YES';
