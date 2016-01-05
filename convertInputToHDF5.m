function convertInputToHDF5(fullinputfilepath)
% *************************************************************************
%         This file converts a FESTIV input file into an HDF5 file.
% *************************************************************************

[inputfilepath,inputfilename,~]=fileparts(fullinputfilepath);

% Delete the .h5 file if it already exists in order to recreate it
fileName = [inputfilepath,filesep,inputfilename,'.h5'];
if exist(fileName,'file')==2
    delete(fileName);
end

% Close any open HDF5 instances
try H5D.close (dset);catch;end;
try H5S.close (space);catch;end;
try H5T.close (filetype);catch;end;
try H5F.close (file);catch;end;
try H5G.close(mainif);catch;end;
try H5G.close(tmrref);catch;end;
try H5G.close(tmrref2);catch;end;

% Initialize status bar
h=waitbar(0,'Converting GEN tab','name','Status','visible','off');
set(findall(h,'type','text'),'Interpreter','none');
movegui(h,'center');
set(h,'visible','on')

%% Gen tab
clear offset memtype wdata filetype space dset
DATASET  = 'GEN';

% Initialize data. It is more efficient to use Structures with array fields
% than arrays of structures.
[generatordata,strings]=xlsread(fullinputfilepath,'GEN');
generatordata(isnan(generatordata))=0;
colHeaders=strings(1,2:end)';
clear wdata
wdata.genNames      = strings(2:end,1);
for i=1:size(generatordata,2)
    wdata.(sprintf('data%d',i))=generatordata(:,i);
end

ylen=size(generatordata,1);
DIM0 = ylen;
dims = DIM0;

% Create a new file using the default properties.
file = H5F.create (fileName, 'H5F_ACC_TRUNC','H5P_DEFAULT', 'H5P_DEFAULT');
mainif = H5G.create(file, '/Main Input File', 0);

% Create the required data types
sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) % number of columns starting from capacity
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

% Computer the offsets to each field. The first offset is always zero.
offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

% Create the compound datatype for memory.
memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Generator',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

% Create the compound datatype for the file.  Because the standard
% types we are using for the file may have different sizes than
% the corresponding native types, we must manually calculate the
% offset of each member.
filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Generator', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

% Create dataspace.  Setting maximum size to [] sets the maximum size to be the current size.
space = H5S.create_simple (1,fliplr( dims), []);

% Create the dataset and write the compound data to it.
dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

% Close and release resources.
H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Cost Tab
waitbar(1/27,h,'Converting COST tab');
clear offset memtype wdata filetype space dset
DATASET = 'COST';

[data,strings]=xlsread(fullinputfilepath,'COST');
data(isnan(data))=0;
colHeaders=strings(1,2:end)';
wdata.genNames  = strings(2:end,1);
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Generator',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Generator', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% System Tab
waitbar(2/27,h,'Converting SYSTEM tab');
clear offset memtype wdata filetype space dset
DATASET = 'SYSTEM';

[data,strings]=xlsread(fullinputfilepath,'SYSTEM');
data(isnan(data))=0;
colHeaders={'Value'};
wdata.genNames  = strings(1:end,1);
wdata.numbers     = data(:,1);

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1)
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Property',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Property', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Bus Tab
waitbar(3/27,h,'Converting BUS tab');
clear offset memtype wdata filetype space dset
DATASET = 'BUS';

[~,strings]=xlsread(fullinputfilepath,'BUS');
colHeaders={'BUSES'};
wdata.genNames  = strings(2:end,1);

ylen=size(strings,1)-1;
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);

offset(1)=0;

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'BUSES',offset(1), strType);

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'BUSES', offset(1), strType);

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Genbus Tab
waitbar(4/27,h,'Converting GENBUS tab');
clear offset memtype wdata filetype space dset
DATASET = 'GENBUS';

[data,strings]=xlsread(fullinputfilepath,'GENBUS');
data(isnan(data))=0;
colHeaders=strings(1,2:end)';
wdata.genbus  = strings(2:end,1);
wdata.pf     = data(:,1);

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'GENBUS',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'GENBUS', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Reserveparam Tab
waitbar(5/27,h,'Converting RESERVEPARAM tab');
clear offset memtype wdata filetype space dset
DATASET = 'RESERVEPARAM';

[data,strings]=xlsread(fullinputfilepath,'RESERVEPARAM');
data(isnan(data))=0;
colHeaders=strings(1,2:end)';
wdata.genNames  = strings(2:end,1);
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Reserve Name',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Reserve Name', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Load distribution Tab
waitbar(6/27,h,'Converting LOAD_DIST tab');
clear offset memtype wdata filetype space dset
DATASET = 'LOAD_DIST';

[data,strings]=xlsread(fullinputfilepath,'LOAD_DIST');
data(isnan(data))=0;
colHeaders=strings(1,2:end)';
wdata.genNames  = strings(2:end,1);
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'BUS',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'BUS', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% ASC Tab
waitbar(7/27,h,'Converting ASC tab');
clear offset memtype wdata filetype space dset
DATASET = 'ASC';

[data,strings]=xlsread(fullinputfilepath,'ASC');
data(isnan(data))=0;
colHeaders=strings(1,2:end)';
wdata.genNames  = strings(2:end,1);
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Generator',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Generator', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
try
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
catch
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    h2 = warndlg(sprintf('Please make sure the ASC tab does\n not have empty spaces and try again'),'!! Warning !!');
    movegui(h2,'center');
    close(h)
    return;
end

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Branchdata Tab
waitbar(8/27,h,'Converting BRANCHDATA tab');
clear offset memtype wdata filetype space dset
DATASET = 'BRANCHDATA';

[data,strings]=xlsread(fullinputfilepath,'BRANCHDATA');
data(isnan(data))=0;
if strcmp(strings(1,3),'REACTANCE')
    strings(:,4:end+1)=strings(:,3:end);
    strings(:,3)=strings(:,1);
end
colHeaders=strings(1,4:end)';
wdata.branchnames1       = strings(2:end,1);
wdata.branchconnections  = strings(2:end,2);
wdata.branchnames2       = strings(2:end,3);
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(2) = H5T.get_size(strType);
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(3) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+3)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'NAME1',offset(1), strType);
H5T.insert (memtype,'BRANCHBUS',offset(2), strType);
H5T.insert (memtype,'NAME2',offset(3), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+3), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'NAME1', offset(1), strType);
H5T.insert (filetype, 'BRANCHBUS', offset(2), strType);
H5T.insert (filetype, 'NAME2', offset(3), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+3), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);

%% Pumpefficiency Tab
waitbar(9/27,h,'Converting PUMPEFFICIENCY tab');
clear offset memtype wdata filetype space dset
DATASET = 'PUMPEFFICIENCY';

[data,strings]=xlsread(fullinputfilepath,'PUMPEFFICIENCY');
if ~isempty(data)
    data(isnan(data))=0;
    colHeaders=strings(1,2:end)';
    wdata.genNames  = strings(2:end,1);
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1) 
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Generator',offset(1), strType);
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Generator', offset(1), strType);
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% Genefficiency Tab
waitbar(10/27,h,'Converting GENEFFICIENCY tab');
clear offset memtype wdata filetype space dset
DATASET = 'GENEFFICIENCY';

[data,strings]=xlsread(fullinputfilepath,'GENEFFICIENCY');
if ~isempty(data)
    data(isnan(data))=0;
    colHeaders=strings(1,2:end)';
    wdata.genNames  = strings(2:end,1);
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1) 
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Generator',offset(1), strType);
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Generator', offset(1), strType);
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% Storage Tab
waitbar(11/27,h,'Converting STORAGE tab');
clear offset memtype wdata filetype space dset
DATASET = 'STORAGE';

[data,strings]=xlsread(fullinputfilepath,'STORAGE');
if ~isempty(data)
    data(isnan(data))=0;
    colHeaders=strings(1,2:end)';
    wdata.genNames  = strings(2:end,1);
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1) 
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Generator',offset(1), strType);
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Generator', offset(1), strType);
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
else
colHeaders=strings';
data=zeros(1,16);
wdata.genNames  = {'None'};
for i=1:size(data,2)
    wdata.(sprintf('data%d',i))=data(:,i);
end

ylen=size(data,1);
DIM0 = ylen;
dims = DIM0;

file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
mainif = H5G.open(file, '/Main Input File', 0);

sz=zeros(1,size(colHeaders,1)); 
strType = H5T.copy ('H5T_C_S1');
H5T.set_size (strType, 'H5T_VARIABLE');
sz(1) = H5T.get_size(strType);
for i=1:size(colHeaders,1) 
    doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
    sz(i+1)=H5T.get_size(doubleType);    
end

offset(1)=0;
offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

memtype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (memtype,'Generator',offset(1), strType);
for i=1:size(colHeaders,1) 
    H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
end

filetype = H5T.create ('H5T_COMPOUND', sum(sz));
H5T.insert (filetype, 'Generator', offset(1), strType);
for i=1:size(colHeaders,1)
    H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
end

space = H5S.create_simple (1,fliplr( dims), []);

dcpl = H5P.create('H5P_DATASET_CREATE');
[numdims,~,~]=H5S.get_simple_extent_dims(space);
chunk_dims = numdims;
h5_chunk_dims = fliplr(chunk_dims);
H5P.set_chunk(dcpl,h5_chunk_dims);
H5P.set_deflate(dcpl,9);
dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% Startup Tab
waitbar(12/27,h,'Converting STARTUP tab');
clear offset memtype wdata filetype space dset
DATASET = 'STARTUP';

[data,strings]=xlsread(fullinputfilepath,'STARTUP');
if ~isempty(data)
    data(isnan(data))=0;
    colHeaders=strings(1,2:end)';
    wdata.genNames  = strings(2:end,1);
    for i=1:size(data,2)
        wdata.(sprintf('data%d',i))=data(:,i);
    end

    ylen=size(data,1);
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);
    for i=1:size(colHeaders,1) 
        doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
        sz(i+1)=H5T.get_size(doubleType);    
    end

    offset(1)=0;
    offset(2:size(sz,2))=cumsum(sz(1:size(sz,2)-1));

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Generator',offset(1), strType);
    for i=1:size(colHeaders,1) 
        H5T.insert (memtype,colHeaders{i},offset(i+1), doubleType);
    end

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Generator', offset(1), strType);
    for i=1:size(colHeaders,1)
        H5T.insert (filetype,colHeaders{i},offset(i+1), doubleType);
    end

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% Actual Load Ref Tab
waitbar(13/27,h,'Converting ACTUAL_LOAD_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'ACTUAL_LOAD_REF';

[~,strings]=xlsread(fullinputfilepath,'ACTUAL_LOAD_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.create(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/Actual Load Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,~]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        if size(tempdata,2) > 2
            colHeaders2={'Time';'Load';'Q Load'};
        else
            colHeaders2={'Time';'Load'};
        end
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/Actual Load Data', 0);
        sz2=zeros(1,size(colHeaders2,1)); 
        for i=1:size(colHeaders2,1) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((13+(ds/size(strings,1)))/27,h,'Converting ACTUAL_LOAD_REF tab');
    end

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% Actual VG Ref Tab
waitbar(14/27,h,'Converting ACTUAL_VG_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'ACTUAL_VG_REF';

[~,strings]=xlsread(fullinputfilepath,'ACTUAL_VG_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/Actual VG Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        colHeaders2=tempstr;
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/Actual VG Data', 0);
        sz2=zeros(1,size(colHeaders2,2)); 
        for i=1:size(colHeaders2,2) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((14+(ds/size(strings,1)))/27,h,'Converting ACTUAL_VG_REF tab');
    end
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% RTC Load Ref Tab
waitbar(15/27,h,'Converting RTC_LOAD_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTC_LOAD_REF';

[~,strings]=xlsread(fullinputfilepath,'RTC_LOAD_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/RTC Load Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,~]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        if size(tempdata,2) > 3
            colHeaders2={'Time';'Hour';'Load';'Q Load'};
        else
            colHeaders2={'Time';'Hour';'Load'};
        end
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/RTC Load Data', 0);
        sz2=zeros(1,size(colHeaders2,1)); 
        for i=1:size(colHeaders2,1) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((15+(ds/size(strings,1)))/27,h,'Converting RTC_LOAD_REF tab');
    end

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% RTC VG Ref Tab
waitbar(16/27,h,'Converting RTC_VG_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTC_VG_REF';

[~,strings]=xlsread(fullinputfilepath,'RTC_VG_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/RTC VG Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        colHeaders2=tempstr;
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/RTC VG Data', 0);
        sz2=zeros(1,size(colHeaders2,2)); 
        for i=1:size(colHeaders2,2) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((16+(ds/size(strings,1)))/27,h,'Converting RTC_VG_REF tab');
    end
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% RTD Load Ref Tab
waitbar(17/27,h,'Converting RTD_LOAD_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTD_LOAD_REF';

[~,strings]=xlsread(fullinputfilepath,'RTD_LOAD_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/RTD Load Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,~]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        if size(tempdata,2) > 3
            colHeaders2={'Time';'Hour';'Load';'Q Load'};
        else
            colHeaders2={'Time';'Hour';'Load'};
        end
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/RTD Load Data', 0);
        sz2=zeros(1,size(colHeaders2,1)); 
        for i=1:size(colHeaders2,1) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,1)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((17+(ds/size(strings,1)))/27,h,'Converting RTD_LOAD_REF tab');
    end

    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% RTD VG Ref Tab
waitbar(18/27,h,'Converting RTD_VG_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTD_VG_REF';

[~,strings]=xlsread(fullinputfilepath,'RTD_VG_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/RTD VG Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        colHeaders2=tempstr;
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/RTD VG Data', 0);
        sz2=zeros(1,size(colHeaders2,2)); 
        for i=1:size(colHeaders2,2) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((18+(ds/size(strings,1)))/27,h,'Converting RTD_VG_REF tab');
    end
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% RTC Reserve Tab
waitbar(19/27,h,'Converting RTC_RESERVE tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTC_RESERVE';
try
    [~,strings]=xlsread(fullinputfilepath,'RTC_RESERVE');
    if ~isempty(strings)
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/RTC Reserve Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/RTC Reserve Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((19+(ds/size(strings,1)))/27,h,'Converting RTC_RESERVE tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

%% RTD Reserve Tab
waitbar(20/27,h,'Converting RTD_RESERVE tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTD_RESERVE';

try
    [~,strings]=xlsread(fullinputfilepath,'RTD_RESERVE');
    if ~isempty(strings)
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/RTD Reserve Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/RTD Reserve Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((20+(ds/size(strings,1)))/27,h,'Converting RTD_RESERVE tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

%% DA Reserve Tab
waitbar(21/27,h,'Converting DA_RESERVE_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'DA_RESERVE_REF';

try
    [~,strings]=xlsread(fullinputfilepath,'DA_RESERVE_REF');
    if ~isempty(strings)
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/DA Reserve Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/DA Reserve Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((21+(ds/size(strings,1)))/27,h,'Converting DA_RESERVE_REF tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

%% DA VG Tab
waitbar(22/27,h,'Converting DA_VG_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'DA_VG_REF';

[~,strings]=xlsread(fullinputfilepath,'DA_VG_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/DA VG Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        colHeaders2=tempstr;
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/DA VG Data', 0);
        sz2=zeros(1,size(colHeaders2,2)); 
        for i=1:size(colHeaders2,2) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((22+(ds/size(strings,1)))/27,h,'Converting DA_VG_REF tab');
    end
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% DA Load Tab
waitbar(23/27,h,'Converting DA_LOAD_REF tab');
clear offset memtype wdata filetype space dset
DATASET = 'DA_LOAD_REF';

[~,strings]=xlsread(fullinputfilepath,'DA_LOAD_REF');
if ~isempty(strings)
    colHeaders={'Data Files'};
    wdata.genNames  = strings(1:end,1);

    ylen=max(1,size(strings,1));
    DIM0 = ylen;
    dims = DIM0;

    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    tmrref = H5G.open(file,'/Time Series Data', 0);
    tmrref2= H5G.create(file,'/Time Series Data/DA Load Data', 0);

    sz=zeros(1,size(colHeaders,1)); 
    strType = H5T.copy ('H5T_C_S1');
    H5T.set_size (strType, 'H5T_VARIABLE');
    sz(1) = H5T.get_size(strType);

    offset(1)=0;

    memtype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (memtype,'Data Files',offset(1), strType);

    filetype = H5T.create ('H5T_COMPOUND', sum(sz));
    H5T.insert (filetype, 'Data Files', offset(1), strType);

    space = H5S.create_simple (1,fliplr( dims), []);

    dcpl = H5P.create('H5P_DATASET_CREATE');
    [numdims,~,~]=H5S.get_simple_extent_dims(space);
    chunk_dims = numdims;
    h5_chunk_dims = fliplr(chunk_dims);
    H5P.set_chunk(dcpl,h5_chunk_dims);
    H5P.set_deflate(dcpl,9);
    dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
    H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);
    
    clear offset2 memtype2 wdata2 filetype2 space2 dset2
    for ds=1:size(strings,1)
        DATASET2=strings{ds};
        [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
        if size(tempdata,2) > 3
            colHeaders2={'DASCUC';'Hour';'Load';'Q Load'};
        else
            colHeaders2=tempstr;
        end
        for i=1:size(tempdata,2)
            wdata2.(sprintf('data%d',i))=tempdata(:,i);
        end
        ylen2=size(tempdata,1);
        DIM02 = ylen2;
        dims2 = DIM02;
        file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif2 = H5G.open(file2, '/Time Series Data/DA Load Data', 0);
        sz2=zeros(1,size(colHeaders2,2)); 
        for i=1:size(colHeaders2,2) 
            doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
            sz2(i)=H5T.get_size(doubleType2);    
        end
        offset2(1)=0;
        offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
        memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2) 
            H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
        end
        filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
        for i=1:size(colHeaders2,2)
            H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
        end
        space2 = H5S.create_simple (1,fliplr( dims2), []);
        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space2);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
        H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
        H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
        waitbar((23+(ds/size(strings,1)))/27,h,'Converting DA_LOAD_REF tab');
    end
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
else
    file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
    mainif = H5G.open(file, '/Main Input File', 0);
    filetype = H5T.create ('H5T_COMPOUND', 8);
    strType = H5T.copy ('H5T_C_S1');
    H5T.insert (filetype, 'None', 0, strType);
    space = H5S.create_simple (1,fliplr(1), []);
    dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
    H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
end

%% DAC Interchange Tab
waitbar(24/27,h,'Converting DAC_INTERCHANGE tab');
clear offset memtype wdata filetype space dset
DATASET = 'DAC_INTERCHANGE';
intind=generatordata(:,8)==14;

try
    if sum(intind) > 0
        [~,strings]=xlsread(fullinputfilepath,'DAC_INTERCHANGE');
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/DAC Interchange Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/DAC Interchange Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((24+(ds/size(strings,1)))/27,h,'Converting DAC_INTERCHANGE tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

%% RTC Interchange Tab
waitbar(25/27,h,'Converting RTC_INTERCHANGE tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTC_INTERCHANGE';
intind=generatordata(:,8)==14;

try
    if sum(intind) > 0
        [~,strings]=xlsread(fullinputfilepath,'RTC_INTERCHANGE');
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/RTC Interchange Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/RTC Interchange Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((25+(ds/size(strings,1)))/27,h,'Converting RTC_INTERCHANGE tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

%% RTD Interchange Tab
waitbar(26/27,h,'Converting RTD_INTERCHANGE tab');
clear offset memtype wdata filetype space dset
DATASET = 'RTD_INTERCHANGE';
intind=generatordata(:,8)==14;

try
    if sum(intind) > 0
        [~,strings]=xlsread(fullinputfilepath,'RTD_INTERCHANGE');
        colHeaders={'Data Files'};
        wdata.genNames  = strings(1:end,1);

        ylen=max(1,size(strings,1));
        DIM0 = ylen;
        dims = DIM0;

        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        tmrref = H5G.open(file,'/Time Series Data', 0);
        tmrref2= H5G.create(file,'/Time Series Data/RTD Interchange Data', 0);

        sz=zeros(1,size(colHeaders,1)); 
        strType = H5T.copy ('H5T_C_S1');
        H5T.set_size (strType, 'H5T_VARIABLE');
        sz(1) = H5T.get_size(strType);

        offset(1)=0;

        memtype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (memtype,'Data Files',offset(1), strType);

        filetype = H5T.create ('H5T_COMPOUND', sum(sz));
        H5T.insert (filetype, 'Data Files', offset(1), strType);

        space = H5S.create_simple (1,fliplr( dims), []);

        dcpl = H5P.create('H5P_DATASET_CREATE');
        [numdims,~,~]=H5S.get_simple_extent_dims(space);
        chunk_dims = numdims;
        h5_chunk_dims = fliplr(chunk_dims);
        H5P.set_chunk(dcpl,h5_chunk_dims);
        H5P.set_deflate(dcpl,9);
        dset = H5D.create (mainif, DATASET, filetype, space, dcpl);
        H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata);

        clear offset2 memtype2 wdata2 filetype2 space2 dset2
        for ds=1:size(strings,1)
            DATASET2=strings{ds};
            [tempdata,tempstr]=xlsread([inputfilepath,filesep,'TIMESERIES',filesep,strings{ds}]);
            colHeaders2=tempstr;
            for i=1:size(tempdata,2)
                wdata2.(sprintf('data%d',i))=tempdata(:,i);
            end
            ylen2=size(tempdata,1);
            DIM02 = ylen2;
            dims2 = DIM02;
            file2 = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
            mainif2 = H5G.open(file2, '/Time Series Data/RTD Interchange Data', 0);
            sz2=zeros(1,size(colHeaders2,2)); 
            for i=1:size(colHeaders2,2) 
                doubleType2=H5T.copy('H5T_NATIVE_DOUBLE');
                sz2(i)=H5T.get_size(doubleType2);    
            end
            offset2(1)=0;
            offset2(2:size(sz2,2))=cumsum(sz2(1:size(sz2,2)-1));
            memtype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2) 
                H5T.insert (memtype2,colHeaders2{i},offset2(i), doubleType2);
            end
            filetype2 = H5T.create ('H5T_COMPOUND', sum(sz2));
            for i=1:size(colHeaders2,2)
                H5T.insert (filetype2,colHeaders2{i},offset2(i), doubleType2);
            end
            space2 = H5S.create_simple (1,fliplr( dims2), []);
            dcpl = H5P.create('H5P_DATASET_CREATE');
            [numdims,~,~]=H5S.get_simple_extent_dims(space2);
            chunk_dims = numdims;
            h5_chunk_dims = fliplr(chunk_dims);
            H5P.set_chunk(dcpl,h5_chunk_dims);
            H5P.set_deflate(dcpl,9);
            dset2 = H5D.create (mainif2, DATASET2, filetype2, space2, dcpl);
            H5D.write (dset2, memtype2, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', wdata2);
            H5D.close (dset2);H5S.close (space2);H5T.close (filetype2);H5F.close (file2);H5G.close(mainif2);
            waitbar((26+(ds/size(strings,1)))/27,h,'Converting RTD_INTERCHANGE tab');
        end
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);H5G.close(tmrref);H5G.close(tmrref2);
    else
        file = H5F.open (fileName, 'H5F_ACC_RDWR','H5P_DEFAULT');
        mainif = H5G.open(file, '/Main Input File', 0);
        filetype = H5T.create ('H5T_COMPOUND', 8);
        strType = H5T.copy ('H5T_C_S1');
        H5T.insert (filetype, 'None', 0, strType);
        space = H5S.create_simple (1,fliplr(1), []);
        dset = H5D.create (mainif, DATASET, filetype, space, 'H5P_DEFAULT');
        H5D.close (dset);H5S.close (space);H5T.close (filetype);H5F.close (file);H5G.close(mainif);
    end
catch
end

waitbar(27/27,h,'Done!');
pause on;pause(0.5);pause off;
delete(h);

end % end function